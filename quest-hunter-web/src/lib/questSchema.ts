/** True when Supabase responds as if branching columns / RPCs were never migrated. */

export function errorLooksLikeMissingCampaignMigration(err: { message?: string }): boolean {
  const m = (err.message ?? '').toLowerCase()
  if (
    (m.includes('campaign_slug') || m.includes('sequence_idx') || m.includes('next_control')) &&
    (m.includes('does not exist') || m.includes('could not find'))
  ) {
    return true
  }
  if (m.includes('schema cache') && (m.includes('quests') || m.includes('campaign_slug'))) return true
  return false
}

/** RPC from `20260420000000_campaign_branching.sql` not deployed. */

export function errorLooksLikeMissingCampaignRpc(err: { message?: string }): boolean {
  const m = (err.message ?? '').toLowerCase()
  if (
    m.includes('get_player_resolved_quest_summary') ||
    (m.includes('could not find') && m.includes('function')) ||
    (m.includes('does not exist') && m.includes('function'))
  ) {
    return true
  }
  return false
}

/** Profile RPC `get_player_finale_branch_history` missing. */

export function errorLooksLikeMissingFinaleHistoryRpc(err: { message?: string }): boolean {
  const m = (err.message ?? '').toLowerCase()
  return (
    m.includes('get_player_finale_branch_history') ||
    (m.includes('could not find') && m.includes('function') && m.includes('finale_branch'))
  )
}
