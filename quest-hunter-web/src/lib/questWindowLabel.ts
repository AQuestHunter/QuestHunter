import type { QuestSummary } from '../types/quest'

/** Player-facing note for playable window (starts / ends). */
export function dossierWindowHint(q: Pick<QuestSummary, 'starts_at' | 'ends_at'>): string | null {
  const now = Date.now()
  const startMs = q.starts_at ? new Date(q.starts_at).getTime() : NaN
  const endMs = q.ends_at ? new Date(q.ends_at).getTime() : NaN

  if (Number.isFinite(endMs)) {
    const end = new Date(endMs)
    const fmt = end.toLocaleString(undefined, {
      weekday: 'short',
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
    })
    const msLeft = endMs - now
    if (msLeft > 0 && msLeft < 72 * 60 * 60 * 1000) {
      const h = Math.ceil(msLeft / (60 * 60 * 1000))
      return `Window closes in ~${h}h (${fmt})`
    }
    return `Window closes ${fmt}`
  }

  if (Number.isFinite(startMs) && startMs > now) {
    const start = new Date(startMs)
    return `Opens ${start.toLocaleString(undefined, { month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' })}`
  }

  return null
}
