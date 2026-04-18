import { useEffect, useMemo, useState } from 'react'
import { Link } from 'react-router-dom'
import { QuestRunner } from '../components/QuestRunner'
import { fetchActiveQuestSummaries } from '../lib/questPlay'
import type { QuestSummary } from '../types/quest'
import { useAuth } from '../contexts/AuthContext'

function pickLatest(rows: QuestSummary[]): QuestSummary | null {
  if (rows.length === 0) return null
  return [...rows].sort(
    (a, b) => new Date(b.starts_at ?? 0).getTime() - new Date(a.starts_at ?? 0).getTime(),
  )[0]
}

export function QuestsPage() {
  const { profile } = useAuth()
  const [rows, setRows] = useState<QuestSummary[]>([])
  const [loading, setLoading] = useState(true)
  const [message, setMessage] = useState<string | null>(null)

  const quest = useMemo(() => pickLatest(rows), [rows])

  useEffect(() => {
    let cancelled = false

    async function load() {
      setLoading(true)
      const { data, error } = await fetchActiveQuestSummaries()
      if (cancelled) return
      if (error) {
        setMessage(error)
        setRows([])
      } else {
        setMessage(null)
        setRows(data ?? [])
      }
      setLoading(false)
    }

    void load()
    return () => {
      cancelled = true
    }
  }, [])

  const needsName = !profile?.hunter_name?.trim()

  return (
    <section className="panel quests-page">
      <div className="hero-block hero-glitch">
        <p className="mono hero-tag flicker">HET GEBROKEN SIGNAAL</p>
        <h1>Active dossier</h1>
        <p className="muted hero-sub">
          One live operation at a time. Archives seal automatically after the window closes—then decay from the public
          feed.
        </p>
      </div>

      {needsName ? (
        <article className="quest-card warn">
          <h2>Callsign required</h2>
          <p className="muted">
            Choose a unique hunter name before continuing—leaderboard and logs bind to that identity.
          </p>
          <Link className="primary-btn mono link-btn" to="/profile">
            Set hunter name →
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
            <span className="muted">FILE</span>
            <span className="accent-strong">{quest.slug}</span>
            <span className="muted">///</span>
            <span>{quest.title}</span>
          </article>
          <QuestRunner summary={quest} />
        </div>
      ) : !needsName ? (
        <article className="quest-card empty">
          <h2>No live quest</h2>
          <p className="muted">
            Publish a windowed quest in Admin (start ≤ now, end unset or future). Ensure the new migration with RPCs is
            applied so answers stay server-side.
          </p>
        </article>
      ) : null}
    </section>
  )
}
