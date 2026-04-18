import { type FormEvent, useCallback, useEffect, useMemo, useState } from 'react'
import { getProjectGroupLabel } from '../lib/projectLabels'
import { errorLooksLikeMissingFinaleHistoryRpc } from '../lib/questSchema'
import { supabase } from '../lib/supabase'
import { useAuth } from '../contexts/AuthContext'

type BoardRow = {
  hunter_name: string | null
  xp: number
}

type FinaleBranchRow = {
  quest_slug: string
  quest_title: string
  branch: string
  completed_at: string
  campaign_slug: string
  campaign_display_name?: string | null
}

const FINALE_PROJECT_COLLATOR = new Intl.Collator(undefined, { numeric: true, sensitivity: 'base' })

export function ProfilePage() {
  const { user, profile, refreshProfile } = useAuth()
  const [hunterName, setHunterName] = useState(profile?.hunter_name ?? '')
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [board, setBoard] = useState<BoardRow[]>([])
  const [boardLoading, setBoardLoading] = useState(true)
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

    async function loadBoard() {
      setBoardLoading(true)
      const { data, error: err } = await supabase
        .from('profiles')
        .select('hunter_name, xp')
        .not('hunter_name', 'is', null)
        .order('xp', { ascending: false })
        .limit(25)

      if (cancelled) return
      if (err) {
        console.error(err)
        setBoard([])
      } else {
        setBoard((data ?? []) as BoardRow[])
      }
      setBoardLoading(false)
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

  async function saveHunterName(e: FormEvent) {
    e.preventDefault()
    if (!user?.id) return
    setSaving(true)
    setError(null)

    const name = hunterName.trim()
    if (!name) {
      setError('Choose a display name.')
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
      } else {
        setError(err.message)
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
  }

  return (
    <section className="panel split">
      <div>
        <h1>Operator</h1>
        <p className="muted small">
          <strong className="display-name-label">Display name:</strong>{' '}
          {profile?.hunter_name?.trim() ? (
            <span className="mono accent-strong">{profile.hunter_name}</span>
          ) : (
            <span>not set yet</span>
          )}
        </p>
        <p className="muted small">Sign-in email (private): {user?.email}</p>

        <form className="stack-form narrow" onSubmit={(e) => void saveHunterName(e)}>
          <label className="field">
            <span className="mono label-text">Display name</span>
            <span className="field-hint muted small">
              Shown in the header, leaderboard, and logs. Must be unique (hunter callsign).
            </span>
            <input
              className="terminal-input mono"
              value={hunterName}
              onChange={(e) => setHunterName(e.target.value)}
              placeholder="Your public name"
              minLength={2}
              maxLength={32}
            />
          </label>
          {error ? (
            <p className="error mono small" role="alert">
              {error}
            </p>
          ) : null}
          <button type="submit" className="primary-btn mono" disabled={saving}>
            {saving ? 'Saving…' : 'Save'}
          </button>
        </form>

        <h2 className="mono small muted" style={{ marginTop: '2rem' }}>
          Finale paths
        </h2>
        <p className="muted small">
          Recent CONTROL / OBSERVE / INFLUENCE choices (per closed dossier). Same data the story engine uses for
          branching.
        </p>
        {finaleLoading ? (
          <p className="mono muted">loading branches …</p>
        ) : finaleRows.length === 0 ? (
          <p className="muted small">No finale choices logged yet.</p>
        ) : (
          <div className="finale-project-section">
            {finaleByProject.length > 1 ? (
              <div className="finale-project-toolbar">
                <button type="button" className="ghost-btn mono small" onClick={expandFinaleProjects}>
                  Expand projects
                </button>
                <button type="button" className="ghost-btn mono small" onClick={collapseFinaleProjects}>
                  Collapse projects
                </button>
              </div>
            ) : null}
            <div className="finale-project-groups">
              {finaleByProject.map(([camp, items]) => {
                const isOpen = finaleProjectOpen[camp] ?? true
                const { primary, secondary } = getProjectGroupLabel(camp, items)
                return (
                  <div key={camp} className="finale-project-group">
                    <button
                      type="button"
                      className="finale-project-toggle mono small"
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
                      <ul className="finale-branch-list mono small finale-branch-list-nested">
                        {items.map((row, i) => (
                          <li key={`${row.quest_slug}-${row.completed_at}-${i}`}>
                            <span className="accent-strong">{row.branch}</span>
                            <span className="muted"> · </span>
                            <span>{row.quest_slug}</span>
                          </li>
                        ))}
                      </ul>
                    ) : null}
                  </div>
                )
              })}
            </div>
          </div>
        )}
      </div>

      <div>
        <h2>Leaderboard</h2>
        <p className="muted small">Top hunters by XP (awarded per puzzle + finale).</p>
        {boardLoading ? (
          <p className="mono muted">loading ranks …</p>
        ) : (
          <ol className="leaderboard mono">
            {board.map((row, i) => (
              <li key={`${row.hunter_name}-${i}`}>
                <span className="rank">{i + 1}</span>
                <span className="name">{row.hunter_name}</span>
                <span className="xp">{row.xp} XP</span>
              </li>
            ))}
          </ol>
        )}
      </div>
    </section>
  )
}
