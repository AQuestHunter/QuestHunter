import { type FormEvent, useCallback, useEffect, useMemo, useState } from 'react'
import { Link } from 'react-router-dom'
import {
  hasActivePushSubscription,
  pushNotificationsConfigured,
  pushNotificationsSupported,
  subscribeToProjectLivePushes,
  unsubscribeFromProjectLivePushes,
} from '../lib/pushNotifications'
import { getProjectGroupLabel } from '../lib/projectLabels'
import { errorLooksLikeMissingFinaleHistoryRpc } from '../lib/questSchema'
import { fetchLeaderboard, type LeaderboardRow } from '../lib/leaderboard'
import { supabase } from '../lib/supabase'
import { useAuth } from '../contexts/AuthContext'

type FinaleBranchRow = {
  quest_slug: string
  quest_title: string
  branch: string
  completed_at: string
  campaign_slug: string
  campaign_display_name?: string | null
}

const FINALE_PROJECT_COLLATOR = new Intl.Collator(undefined, { numeric: true, sensitivity: 'base' })

function branchKey(branch: string): 'control' | 'observe' | 'influence' | 'other' {
  const u = branch.trim().toUpperCase()
  if (u === 'CONTROL') return 'control'
  if (u === 'OBSERVE') return 'observe'
  if (u === 'INFLUENCE') return 'influence'
  return 'other'
}

function formatCompletedAt(iso: string): string {
  try {
    const d = new Date(iso)
    if (Number.isNaN(d.getTime())) return iso
    return new Intl.DateTimeFormat(undefined, {
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
    }).format(d)
  } catch {
    return iso
  }
}

export function ProfilePage() {
  const { user, profile, refreshProfile } = useAuth()
  const [hunterName, setHunterName] = useState(profile?.hunter_name ?? '')
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [board, setBoard] = useState<LeaderboardRow[]>([])
  const [finaleRows, setFinaleRows] = useState<FinaleBranchRow[]>([])
  const [finaleLoading, setFinaleLoading] = useState(true)

  const finaleByProject = useMemo(() => {
    const map = new Map<string, FinaleBranchRow[]>()
    for (const row of finaleRows) {
      const k = row.campaign_slug?.trim() || 'default'
      const arr = map.get(k) ?? []
      arr.push(row)
      map.set(k, arr)
    }
    return [...map.entries()].sort(([a], [b]) => FINALE_PROJECT_COLLATOR.compare(a, b))
  }, [finaleRows])

  const [finaleProjectOpen, setFinaleProjectOpen] = useState<Record<string, boolean>>({})

  const [pushAlertsOn, setPushAlertsOn] = useState(false)
  const [pushAlertsBusy, setPushAlertsBusy] = useState(false)
  const [pushAlertsErr, setPushAlertsErr] = useState<string | null>(null)
  const [feedback, setFeedback] = useState<{ kind: 'success' | 'error'; message: string } | null>(null)

  const showIosPwaPushHint = useMemo(
    () => typeof navigator !== 'undefined' && /iPhone|iPad|iPod/.test(navigator.userAgent),
    [],
  )

  useEffect(() => {
    setFinaleProjectOpen((prev) => {
      const next = { ...prev }
      let changed = false
      for (const [camp] of finaleByProject) {
        if (!(camp in next)) {
          next[camp] = true
          changed = true
        }
      }
      return changed ? next : prev
    })
  }, [finaleByProject])

  const expandFinaleProjects = useCallback(() => {
    const next: Record<string, boolean> = {}
    for (const [camp] of finaleByProject) next[camp] = true
    setFinaleProjectOpen(next)
  }, [finaleByProject])

  const collapseFinaleProjects = useCallback(() => {
    const next: Record<string, boolean> = {}
    for (const [camp] of finaleByProject) next[camp] = false
    setFinaleProjectOpen(next)
  }, [finaleByProject])

  useEffect(() => {
    setHunterName(profile?.hunter_name ?? '')
  }, [profile?.hunter_name])

  useEffect(() => {
    let cancelled = false

    async function syncPushState() {
      if (!user?.id || !pushNotificationsSupported()) {
        if (!cancelled) setPushAlertsOn(false)
        return
      }
      const on = await hasActivePushSubscription()
      if (!cancelled) setPushAlertsOn(on)
    }

    void syncPushState()
    return () => {
      cancelled = true
    }
  }, [user?.id])

  useEffect(() => {
    let cancelled = false

    async function loadBoard() {
      const data = await fetchLeaderboard(25)
      if (cancelled) return
      setBoard(data)
    }

    void loadBoard()
    return () => {
      cancelled = true
    }
  }, [])

  useEffect(() => {
    let cancelled = false

    async function loadFinaleHistory() {
      setFinaleLoading(true)
      const { data, error: err } = await supabase.rpc('get_player_finale_branch_history', {
        p_limit: 12,
      })
      if (cancelled) return
      if (err) {
        if (!errorLooksLikeMissingFinaleHistoryRpc(err)) {
          console.error(err)
        }
        setFinaleRows([])
      } else {
        setFinaleRows((data ?? []) as FinaleBranchRow[])
      }
      setFinaleLoading(false)
    }

    void loadFinaleHistory()
    return () => {
      cancelled = true
    }
  }, [])

  const playerRank = useMemo(() => {
    const name = profile?.hunter_name?.trim()
    if (!name) return null
    const idx = board.findIndex((r) => r.hunter_name === name)
    return idx === -1 ? null : idx + 1
  }, [board, profile?.hunter_name])

  const callsign = profile?.hunter_name?.trim()
  const initials = (callsign || user?.email || '?')
    .split(/[\s@._-]+/)
    .filter(Boolean)
    .slice(0, 2)
    .map((s) => s[0]?.toUpperCase() ?? '')
    .join('')
    .slice(0, 2)
  const xpTotal = profile?.xp ?? 0
  const livesNow = profile?.lives
  const livesMax = 5

  const milestonePills = useMemo(() => {
    const pills: { key: string; label: string }[] = []
    if (finaleRows.length >= 1) pills.push({ key: 'first-finale', label: 'First finale' })
    const paths = new Set<'control' | 'observe' | 'influence'>()
    for (const row of finaleRows) {
      const k = branchKey(row.branch)
      if (k === 'control' || k === 'observe' || k === 'influence') paths.add(k)
    }
    if (paths.size >= 3) pills.push({ key: 'triad', label: 'All three paths' })
    if (xpTotal >= 500) pills.push({ key: 'seasoned', label: 'Seasoned hunter' })
    return pills
  }, [finaleRows, xpTotal])

  async function saveHunterName(e: FormEvent) {
    e.preventDefault()
    if (!user?.id) return
    setSaving(true)
    setError(null)

    const name = hunterName.trim()
    if (!name) {
      setError('Choose a display name.')
      setFeedback({ kind: 'error', message: 'Choose a display name before saving.' })
      setSaving(false)
      return
    }

    const { error: err } = await supabase
      .from('profiles')
      .update({ hunter_name: name, updated_at: new Date().toISOString() })
      .eq('id', user.id)

    if (err) {
      setSaving(false)
      if (err.code === '23505') {
        setError('That display name is already taken.')
        setFeedback({ kind: 'error', message: 'Display name already taken.' })
      } else {
        setError(err.message)
        setFeedback({ kind: 'error', message: err.message })
      }
      return
    }

    const { error: metaErr } = await supabase.auth.updateUser({
      data: {
        display_name: name,
        full_name: name,
      },
    })

    setSaving(false)
    if (metaErr) {
      console.warn('Auth display name sync:', metaErr.message)
    }

    await refreshProfile()
    setBoard(await fetchLeaderboard(25))
    setFeedback({ kind: 'success', message: 'Callsign saved.' })
  }

  const toggleProjectPushAlerts = useCallback(async () => {
    if (!user?.id || !pushNotificationsSupported()) return
    setPushAlertsBusy(true)
    setPushAlertsErr(null)
    const nextOn = !pushAlertsOn
    const res = nextOn
      ? await subscribeToProjectLivePushes(user.id)
      : await unsubscribeFromProjectLivePushes(user.id)
    setPushAlertsBusy(false)
    if (!res.ok) {
      setPushAlertsErr(res.message ?? 'Kon push niet bijwerken.')
      setFeedback({ kind: 'error', message: res.message ?? 'Push preferences could not be updated.' })
      return
    }
    setPushAlertsOn(nextOn)
    setFeedback({
      kind: 'success',
      message: nextOn ? 'Project notifications enabled.' : 'Project notifications disabled.',
    })
  }, [pushAlertsOn, user?.id])

  useEffect(() => {
    if (!feedback) return
    const t = window.setTimeout(() => setFeedback(null), 2600)
    return () => window.clearTimeout(t)
  }, [feedback])

  return (
    <section className="panel profile-page">
      {feedback ? (
        <p
          className={`mono small app-toast ${feedback.kind === 'success' ? 'app-toast--success' : 'app-toast--error'}`}
          role="status"
        >
          {feedback.message}
        </p>
      ) : null}
      <header className="profile-hero">
        <span className="profile-avatar mono" aria-hidden>
          {initials || '?'}
        </span>
        <p className="profile-hero-tag mono">Operator file</p>
        <h1 className="profile-hero-title">{callsign || 'Unsigned operator'}</h1>
        <p className="profile-hero-email mono small muted">
          <span className="profile-hero-email-label">Channel</span>{' '}
          <span className="profile-hero-email-val">{user?.email ?? '—'}</span>
        </p>
      </header>

      <div className="profile-stat-grid">
        <article className="profile-stat-card profile-stat-card--xp">
          <span className="profile-stat-label mono">XP total</span>
          <span className="profile-stat-value">{xpTotal.toLocaleString()}</span>
          <span className="profile-stat-hint muted small">From puzzles &amp; finales</span>
        </article>
        <article className="profile-stat-card profile-stat-card--lives">
          <span className="profile-stat-label mono">Charges</span>
          <span className="profile-stat-value">
            {typeof livesNow === 'number' ? (
              <>
                {livesNow}
                <span className="profile-stat-max muted"> / {livesMax}</span>
              </>
            ) : (
              '—'
            )}
          </span>
          <span className="profile-stat-hint muted small">Wrong answers spend one · +1 / 5 min</span>
        </article>
        <article className="profile-stat-card profile-stat-card--rank">
          <span className="profile-stat-label mono">Leaderboard</span>
          <span className="profile-stat-value">
            {playerRank != null ? (
              <>
                #{playerRank}
                <span className="profile-stat-max muted"> / 25</span>
              </>
            ) : callsign ? (
              <span className="profile-stat-unranked">Outside top 25</span>
            ) : (
              '—'
            )}
          </span>
          <span className="profile-stat-hint muted small">
            <Link to="/leaderboard" className="mono accent-strong">
              Podium · full board
            </Link>
          </span>
        </article>
      </div>

      <section className="profile-card profile-card--milestones">
        <h2 className="profile-card-title mono">Milestones</h2>
        <p className="muted small profile-card-lede">Light recognition — no grind.</p>
        {finaleLoading ? (
          <p className="muted small mono">Loading…</p>
        ) : milestonePills.length === 0 ? (
          <p className="muted small">Finish a dossier finale to earn your first badge.</p>
        ) : (
          <ul className="profile-milestone-list" aria-label="Milestones">
            {milestonePills.map((p) => (
              <li key={p.key} className="profile-milestone-pill mono small">
                {p.label}
              </li>
            ))}
          </ul>
        )}
      </section>

      <div className="profile-layout">
        <div className="profile-main">
          <div className="profile-card profile-card--form">
            <h2 className="profile-card-title mono">Callsign</h2>
            <p className="muted small profile-card-lede">
              Public handle — header, leaderboard, logs. Unique across operators.
            </p>
            <form className="stack-form profile-form" onSubmit={(e) => void saveHunterName(e)}>
              <label className="field">
                <span className="mono label-text">Display name</span>
                <input
                  className="terminal-input mono"
                  value={hunterName}
                  onChange={(e) => setHunterName(e.target.value)}
                  placeholder="Your callsign"
                  minLength={2}
                  maxLength={32}
                  autoComplete="nickname"
                />
              </label>
              {error ? (
                <p className="error mono small" role="alert">
                  {error}
                </p>
              ) : null}
              <button type="submit" className="primary-btn mono" disabled={saving}>
                {saving ? 'Committing…' : 'Save callsign'}
              </button>
            </form>
          </div>

          <div className="profile-card profile-card--push">
            <h2 className="profile-card-title mono">Projectmeldingen</h2>
            <p className="muted small profile-card-lede">
              PWA: een korte melding wanneer een nieuw project (campagne) online gaat — niet voor de standaard
              <span className="mono"> default</span> lijst.
            </p>
            {showIosPwaPushHint ? (
              <p className="muted small profile-empty-hint">
                iPhone/iPad: zet de site op je beginscherm (Safari → Deel → Zet op beginscherm) zodat
                installatie- en pushvoorwaarden van iOS het goed doen.
              </p>
            ) : null}
            {!pushNotificationsConfigured() ? (
              <p className="muted small profile-empty-hint">
                Push is niet ingesteld op deze omgeving (ontbreekt <span className="mono">VITE_VAPID_PUBLIC_KEY</span>).
              </p>
            ) : !user?.id ? (
              <p className="muted small profile-empty-hint">Log in om meldingen in te schakelen.</p>
            ) : (
              <>
                <div className="profile-push-row">
                  <button
                    type="button"
                    className={pushAlertsOn ? 'ghost-btn mono' : 'primary-btn mono'}
                    disabled={pushAlertsBusy}
                    onClick={() => void toggleProjectPushAlerts()}
                  >
                    {pushAlertsBusy
                      ? 'Bezig…'
                      : pushAlertsOn
                        ? 'Meldingen uit'
                        : 'Meldingen aan'}
                  </button>
                  <span className="mono small muted profile-push-status">
                    {pushAlertsOn ? 'Ingeschakeld op dit apparaat' : 'Uit'}
                  </span>
                </div>
                {pushAlertsErr ? (
                  <p className="error mono small" role="alert">
                    {pushAlertsErr}
                  </p>
                ) : null}
              </>
            )}
          </div>

          <section className="profile-card profile-card--finale">
            <h2 className="profile-card-title mono">Finale paths</h2>
            <p className="muted small profile-card-lede">
              Recent CONTROL · OBSERVE · INFLUENCE resolutions. Used by the story engine for branching.
            </p>
            {finaleLoading ? (
              <p className="mono muted profile-card-loading">Syncing branch log…</p>
            ) : finaleRows.length === 0 ? (
              <p className="muted small profile-empty-hint">No finale choices logged yet.</p>
            ) : (
              <div className="finale-project-section">
                {finaleByProject.length > 1 ? (
                  <div className="finale-project-toolbar">
                    <button type="button" className="ghost-btn mono small" onClick={expandFinaleProjects}>
                      Expand all
                    </button>
                    <button type="button" className="ghost-btn mono small" onClick={collapseFinaleProjects}>
                      Collapse all
                    </button>
                  </div>
                ) : null}
                <div className="finale-project-groups">
                  {finaleByProject.map(([camp, items]) => {
                    const isOpen = finaleProjectOpen[camp] ?? true
                    const { primary, secondary } = getProjectGroupLabel(camp, items)
                    return (
                      <div key={camp} className="finale-project-group profile-finale-group">
                        <button
                          type="button"
                          className="finale-project-toggle mono small profile-finale-toggle"
                          onClick={() =>
                            setFinaleProjectOpen((prev) => ({
                              ...prev,
                              [camp]: !(prev[camp] ?? true),
                            }))
                          }
                          aria-expanded={isOpen}
                        >
                          <span className="admin-project-caret" aria-hidden>
                            {isOpen ? '▼' : '▶'}
                          </span>
                          <span className="admin-project-toggle-text">
                            <span className="admin-project-line1">
                              <span className="muted">Project ·</span>{' '}
                              <span className="accent-strong">{primary}</span>
                              <span className="muted finale-project-count"> ({items.length})</span>
                            </span>
                            {secondary ? (
                              <span className="admin-project-secondary mono muted">{secondary}</span>
                            ) : null}
                          </span>
                        </button>
                        {isOpen ? (
                          <ul className="finale-branch-list finale-branch-list--enhanced mono small">
                            {items.map((row, i) => {
                              const bk = branchKey(row.branch)
                              return (
                                <li
                                  key={`${row.quest_slug}-${row.completed_at}-${i}`}
                                  className="finale-branch-row"
                                >
                                  <div className="finale-branch-row-main">
                                    <span
                                      className={`finale-branch-pill finale-branch-pill--${bk}`}
                                      title="Finale branch"
                                    >
                                      {row.branch}
                                    </span>
                                    <div className="finale-branch-text">
                                      <span className="finale-branch-title">{row.quest_title}</span>
                                      <span className="finale-branch-slug muted">{row.quest_slug}</span>
                                    </div>
                                  </div>
                                  <time className="finale-branch-time muted" dateTime={row.completed_at}>
                                    {formatCompletedAt(row.completed_at)}
                                  </time>
                                </li>
                              )
                            })}
                          </ul>
                        ) : null}
                      </div>
                    )
                  })}
                </div>
              </div>
            )}
          </section>
        </div>
      </div>
    </section>
  )
}
