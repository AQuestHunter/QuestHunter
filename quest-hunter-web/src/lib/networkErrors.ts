/** Heuristic for transient failures worth retrying (network / timeout). */

export function isLikelyNetworkError(message: string): boolean {
  const m = message.toLowerCase()
  if (m.includes('fetch') || m.includes('network') || m.includes('failed to fetch')) return true
  if (m.includes('timeout') || m.includes('timed out')) return true
  if (m.includes('load failed') || m.includes('connection')) return true
  if (m.includes('503') || m.includes('502') || m.includes('504')) return true
  return false
}

export function friendlyLoadFailure(message: string): string {
  if (isLikelyNetworkError(message)) {
    return 'No stable connection — check Wi‑Fi or cellular, then retry.'
  }
  return message
}

/** Maps transient RPC/network strings to a single friendly line (gameplay codes pass through). */
export function formatPlayerFacingRpcError(raw: string): string {
  return friendlyLoadFailure(raw)
}
