import { useCallback, useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import { QuestRunner } from '../components/QuestRunner'
import { fetchResolvedQuestSummary, getPlayerCampaignSlugFromEnv } from '../lib/questPlay'
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
  const campaignSlug = getPlayerCampaignSlugFromEnv()
  const [quest, setQuest] = useState<QuestSummary | null>(null)
  const [resolveStatus, setResolveStatus] = useState<ResolvedQuestStatus>('none')
  const [loading, setLoading] = useState(true)
  const [message, setMessage] = useState<string | null>(null)

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

  const needsName = !profile?.hunter_name?.trim()
  const waitCopy = resolvedMessage(resolveStatus)
  const showIdleCard = !quest && !needsName && !message && !loading
  const showWaitingOrComplete = showIdleCard && waitCopy

  return (
    <section className="panel quests-page">
      <div className="hero-block hero-glitch">
        <p className="mono hero-tag flicker">HET GEBROKEN SIGNAAL</p>
        <h1>Active dossier</h1>
        <p className="muted hero-sub">
          One live operation at a time. Archives seal automatically after the window closes—then decay from the public
          feed.
        </p>
        {campaignSlug !== 'default' ? (
          <p className="muted small mono">
            Campaign: <span className="accent-strong">{campaignSlug}</span>
          </p>
        ) : null}
      </div>

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
        <p className="mono muted">tuning frequency …</p>
      ) : message ? (
        <p className="mono error">{message}</p>
      ) : quest && !needsName ? (
        <div className="quest-stack">
          <article className="dossier-strip mono">
            <span className="muted dossier-meta">FILE</span>
            <span className="accent-strong dossier-slug">{quest.slug}</span>
            <span className="muted dossier-meta">///</span>
            <span className="dossier-title">{quest.title}</span>
          </article>
          <QuestRunner summary={quest} onDone={() => void loadQuest()} />
        </div>
      ) : showIdleCard ? (
        showWaitingOrComplete ? (
          <article className="quest-card">
            <h2 className="mono small">
              {resolveStatus === 'waiting_next' ? 'Standing by' : 'Campaign arc'}
            </h2>
            <p className="muted">{waitCopy}</p>
          </article>
        ) : (
          <article className="quest-card empty">
            <h2>No live quest</h2>
            <p className="muted">
              Publish a windowed quest in Admin (start ≤ now, end unset or future). Ensure migrations with RPCs are
              applied so answers stay server-side.
            </p>
            <p className="muted small mono">
              Branching campaigns: set Admin campaign fields + <code>VITE_QUEST_CAMPAIGN_SLUG</code> to match your story
              slug.
            </p>
          </article>
        )
      ) : null}
    </section>
  )
}
