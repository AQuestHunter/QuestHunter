import { useCallback, useEffect, useMemo, useState } from 'react'
import { Link } from 'react-router-dom'
import { QuestRunner } from '../components/QuestRunner'
import {
  fetchActivePlayerCampaigns,
  fetchResolvedQuestSummary,
  getPlayerCampaignSlugForPlay,
  getPlayerCampaignSlugFromEnv,
  setPlayerCampaignSlugPreference,
  type ActivePlayerCampaign,
} from '../lib/questPlay'
import { dossierWindowHint } from '../lib/questWindowLabel'
import type { QuestSummary, ResolvedQuestStatus } from '../types/quest'
import { useAuth } from '../contexts/AuthContext'

function resolvedMessage(status: ResolvedQuestStatus): string | null {
  if (status === 'waiting_next') {
    return 'Your finale choice is logged. The next dossier unlocks once that chapter is published inside its window — check back after release.'
  }
  if (status === 'campaign_complete') {
    return 'This campaign arc has no further linked chapter — or your path has ended here for now.'
  }
  return null
}

export function QuestsPage() {
  const { profile } = useAuth()
  const [campaignSlug, setCampaignSlug] = useState(() => getPlayerCampaignSlugForPlay())
  const [density, setDensity] = useState<'expanded' | 'compact'>(() => {
    if (typeof window === 'undefined') return 'expanded'
    return window.localStorage.getItem('qh-density') === 'compact' ? 'compact' : 'expanded'
  })
  const [campaignChoices, setCampaignChoices] = useState<ActivePlayerCampaign[]>([])
  const [quest, setQuest] = useState<QuestSummary | null>(null)
  const [resolveStatus, setResolveStatus] = useState<ResolvedQuestStatus>('none')
  const [loading, setLoading] = useState(true)
  const [message, setMessage] = useState<string | null>(null)

  useEffect(() => {
    let cancelled = false
    void (async () => {
      const rows = await fetchActivePlayerCampaigns()
      if (cancelled) return
      setCampaignChoices(rows)
      if (rows.length === 0) return

      const valid = new Set(rows.map((r) => r.slug))
      const pref = getPlayerCampaignSlugForPlay()
      if (valid.has(pref)) return

      const envSlug = getPlayerCampaignSlugFromEnv()
      const fallback = valid.has(envSlug) ? envSlug : rows[0].slug
      setPlayerCampaignSlugPreference(fallback)
      setCampaignSlug(fallback)
    })()
    return () => {
      cancelled = true
    }
  }, [])

  const loadQuest = useCallback(async () => {
    setLoading(true)
    const { summary, resolveStatus: st, error } = await fetchResolvedQuestSummary(campaignSlug)
    if (error) {
      setMessage(error)
      setQuest(null)
      setResolveStatus('none')
    } else {
      setMessage(null)
      setQuest(summary)
      setResolveStatus(st)
    }
    setLoading(false)
  }, [campaignSlug])

  useEffect(() => {
    void loadQuest()
  }, [loadQuest])

  const showProjectPicker = campaignChoices.length > 1
  const singleProjectLabel = useMemo(() => {
    if (campaignChoices.length !== 1) return null
    return campaignChoices[0].label
  }, [campaignChoices])

  const needsName = !profile?.hunter_name?.trim()
  const waitCopy = resolvedMessage(resolveStatus)
  const showIdleCard = !quest && !needsName && !message && !loading
  const showWaitingOrComplete = showIdleCard && waitCopy

  const dossierWindowCopy = useMemo(() => (quest ? dossierWindowHint(quest) : null), [quest])
  const isCompact = density === 'compact'

  useEffect(() => {
    window.localStorage.setItem('qh-density', density)
  }, [density])

  return (
    <section className={`panel quests-page ${isCompact ? 'quests-page--compact' : ''}`}>
      <div className="hero-block hero-glitch">
        <p className="mono hero-tag flicker">HET GEBROKEN SIGNAAL</p>
        <h1>Active dossier</h1>
        <p className="muted hero-sub">
          Pick a project when several are live; otherwise you see the dossier for your selected arc (or the newest
          window globally when using the default campaign).
        </p>
      </div>
      <div className="quests-display-bar">
        <span className="mono muted small">Card density</span>
        <div className="quests-density-toggle" role="group" aria-label="Quest card density">
          <button
            type="button"
            className={`ghost-btn mono small quests-density-btn ${!isCompact ? 'quests-density-btn--active' : ''}`}
            onClick={() => setDensity('expanded')}
            aria-pressed={!isCompact}
          >
            Expanded
          </button>
          <button
            type="button"
            className={`ghost-btn mono small quests-density-btn ${isCompact ? 'quests-density-btn--active' : ''}`}
            onClick={() => setDensity('compact')}
            aria-pressed={isCompact}
          >
            Compact
          </button>
        </div>
      </div>
      {campaignChoices.length > 0 ? (
        <div className="campaign-progress" aria-label="Active campaign list">
          <p className="mono muted small campaign-progress-label">
            Active campaigns · {campaignChoices.length}
          </p>
          <div className="campaign-progress-track" role="list">
            {campaignChoices.map((c) => (
              <span
                key={c.slug}
                role="listitem"
                className={`campaign-progress-chip ${c.slug === campaignSlug ? 'campaign-progress-chip--active' : ''}`}
                title={c.label}
              >
                <span className="campaign-progress-dot" aria-hidden />
                <span className="campaign-progress-name">{c.label}</span>
              </span>
            ))}
          </div>
        </div>
      ) : null}

      {!needsName && showProjectPicker ? (
        <label className="field quest-project-picker mono small">
          <span className="label-text">Project</span>
          <select
            className="terminal-input mono quest-project-picker-select"
            value={campaignSlug}
            aria-label="Playable project"
            onChange={(e) => {
              const v = e.target.value
              setPlayerCampaignSlugPreference(v)
              setCampaignSlug(v)
            }}
          >
            {campaignChoices.map((c) => (
              <option key={c.slug} value={c.slug}>
                {c.label}
              </option>
            ))}
          </select>
        </label>
      ) : null}

      {!needsName && !showProjectPicker && singleProjectLabel ? (
        <p className="muted small mono quest-project-single">
          Project: <span className="accent-strong">{singleProjectLabel}</span>
          {campaignSlug !== 'default' ? (
            <span className="muted"> ({campaignSlug})</span>
          ) : null}
        </p>
      ) : null}

      {!needsName && campaignChoices.length === 0 && campaignSlug !== 'default' ? (
        <p className="muted small mono">
          Campaign: <span className="accent-strong">{campaignSlug}</span>
        </p>
      ) : null}

      {needsName ? (
        <article className="quest-card warn">
          <h2>Display name required</h2>
          <p className="muted">
            Choose a unique display name before continuing—it is your public identity on quests and the leaderboard.
          </p>
          <Link className="primary-btn mono link-btn" to="/profile">
            Set display name →
          </Link>
        </article>
      ) : null}

      {loading ? (
        <article className="quest-card quest-loading-skeleton" aria-hidden>
          <div className="skeleton-line skeleton-line--title" />
          <div className="skeleton-line" />
          <div className="skeleton-line skeleton-line--short" />
          <div className="skeleton-block" />
        </article>
      ) : message ? (
        <p className="mono error quest-feedback quest-feedback--error">{message}</p>
      ) : quest && !needsName ? (
        <div className={`quest-stack ${isCompact ? 'quest-stack--compact' : ''}`}>
          <article className="dossier-strip mono">
            <span className="muted dossier-meta">LIVE</span>
            <span className="quest-status-badge quest-status-badge--live">In window</span>
            <span className="muted dossier-meta">///</span>
            <span className="muted dossier-meta">FILE</span>
            <span className="accent-strong dossier-slug">{quest.slug}</span>
            <span className="muted dossier-meta">///</span>
            <span className="dossier-title">{quest.title}</span>
          </article>
          {dossierWindowCopy ? (
            <p className="dossier-window-hint mono small muted">{dossierWindowCopy}</p>
          ) : null}
          <QuestRunner summary={quest} onDone={() => void loadQuest()} />
        </div>
      ) : showIdleCard ? (
        showWaitingOrComplete ? (
          <article className="quest-card">
            <h2 className="mono small">
              {resolveStatus === 'waiting_next' ? 'Standing by' : 'Campaign arc'}
            </h2>
            <p className="quest-status-line">
              <span className="quest-status-badge quest-status-badge--standby">
                {resolveStatus === 'waiting_next' ? 'Standby' : 'Complete'}
              </span>
            </p>
            <p className="muted">{waitCopy}</p>
          </article>
        ) : (
          <article className="quest-card empty">
            <p className="quest-empty-illustration" aria-hidden>
              // NO SIGNAL //
            </p>
            <h2>No live quest</h2>
            <p className="muted">
              Publish a windowed quest in Admin (start ≤ now, end unset or future). Ensure migrations with RPCs are
              applied so answers stay server-side.
            </p>
            <p className="muted small">
              Use Admin to publish quests in their time window. With multiple live projects, a project picker appears
              above; you can also pin a default via <code className="mono">VITE_QUEST_CAMPAIGN_SLUG</code> at build time.
            </p>
          </article>
        )
      ) : null}
    </section>
  )
}
