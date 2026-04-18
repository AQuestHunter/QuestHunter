import { useCallback, useEffect, useMemo, useState } from 'react'
import { supabase } from '../../lib/supabase'

type AttemptRow = {
  quest_id: string | null
  is_correct: boolean
}

type ProgressRow = {
  quest_id: string
  started_at: string | null
  completed_at: string | null
}

type QuestTitle = { id: string; title: string }

export function AdminAnalyticsPanel() {
  const [attempts, setAttempts] = useState<AttemptRow[]>([])
  const [progress, setProgress] = useState<ProgressRow[]>([])
  const [quests, setQuests] = useState<QuestTitle[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  const load = useCallback(async () => {
    setLoading(true)
    setError(null)

    const [a, p, q] = await Promise.all([
      supabase.from('answer_attempts').select('quest_id, is_correct'),
      supabase
        .from('user_quest_progress')
        .select('quest_id, started_at, completed_at')
        .not('completed_at', 'is', null),
      supabase.from('quests').select('id, title'),
    ])

    if (a.error || p.error || q.error) {
      setError(a.error?.message ?? p.error?.message ?? q.error?.message ?? 'load failed')
      setLoading(false)
      return
    }

    setAttempts((a.data ?? []) as AttemptRow[])
    setProgress((p.data ?? []) as ProgressRow[])
    setQuests((q.data ?? []) as QuestTitle[])
    setLoading(false)
  }, [])

  useEffect(() => {
    void load()
  }, [load])

  const titleById = useMemo(() => {
    const m = new Map<string, string>()
    for (const r of quests) m.set(r.id, r.title)
    return m
  }, [quests])

  const attemptStats = useMemo(() => {
    const map = new Map<string, { wrong: number; total: number }>()
    for (const row of attempts) {
      if (!row.quest_id) continue
      const cur = map.get(row.quest_id) ?? { wrong: 0, total: 0 }
      cur.total += 1
      if (!row.is_correct) cur.wrong += 1
      map.set(row.quest_id, cur)
    }
    return [...map.entries()].map(([questId, v]) => ({
      questId,
      title: titleById.get(questId) ?? questId.slice(0, 8),
      wrong: v.wrong,
      total: v.total,
      rate: v.total ? Math.round((v.wrong / v.total) * 1000) / 10 : 0,
    }))
  }, [attempts, titleById])

  const durationStats = useMemo(() => {
    const map = new Map<string, { seconds: number; n: number }>()
    for (const row of progress) {
      if (!row.started_at || !row.completed_at) continue
      const start = new Date(row.started_at).getTime()
      const end = new Date(row.completed_at).getTime()
      if (Number.isNaN(start) || Number.isNaN(end) || end <= start) continue
      const sec = (end - start) / 1000
      const cur = map.get(row.quest_id) ?? { seconds: 0, n: 0 }
      cur.seconds += sec
      cur.n += 1
      map.set(row.quest_id, cur)
    }
    return [...map.entries()].map(([questId, v]) => ({
      questId,
      title: titleById.get(questId) ?? questId.slice(0, 8),
      avgSeconds: v.n ? Math.round(v.seconds / v.n) : 0,
      completions: v.n,
    }))
  }, [progress, titleById])

  return (
    <div className="admin-analytics">
      <div className="admin-toolbar">
        <button type="button" className="ghost-btn mono" onClick={() => void load()} disabled={loading}>
          Refresh
        </button>
      </div>

      {error ? (
        <p className="mono error small" role="alert">
          {error}
        </p>
      ) : null}

      {loading ? (
        <p className="muted mono">aggregating…</p>
      ) : (
        <div className="analytics-grid">
          <section className="analytics-card">
            <h2 className="mono">Wrong vs attempts</h2>
            <p className="muted small">Per quest, across all logged puzzle submissions.</p>
            {attemptStats.length === 0 ? (
              <p className="muted small">No attempts yet.</p>
            ) : (
              <div className="table-scroll">
                <table className="data-table mono">
                  <thead>
                    <tr>
                      <th>Quest</th>
                      <th>Wrong</th>
                      <th>Total</th>
                      <th>Wrong %</th>
                    </tr>
                  </thead>
                  <tbody>
                    {attemptStats.map((r) => (
                      <tr key={r.questId}>
                        <td>{r.title}</td>
                        <td>{r.wrong}</td>
                        <td>{r.total}</td>
                        <td>{r.rate}%</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </section>

          <section className="analytics-card">
            <h2 className="mono">Avg time (completed)</h2>
            <p className="muted small">From first progress touch to finale completion.</p>
            {durationStats.length === 0 ? (
              <p className="muted small">No completions with timestamps yet.</p>
            ) : (
              <div className="table-scroll">
                <table className="data-table mono">
                  <thead>
                    <tr>
                      <th>Quest</th>
                      <th>Avg seconds</th>
                      <th>Runs</th>
                    </tr>
                  </thead>
                  <tbody>
                    {durationStats.map((r) => (
                      <tr key={r.questId}>
                        <td>{r.title}</td>
                        <td>{r.avgSeconds}s</td>
                        <td>{r.completions}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </section>
        </div>
      )}
    </div>
  )
}
