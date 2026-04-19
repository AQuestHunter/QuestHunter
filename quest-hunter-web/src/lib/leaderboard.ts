import { supabase } from './supabase'

export type LeaderboardRow = {
  hunter_name: string | null
  xp: number
}

export async function fetchLeaderboard(limit = 25): Promise<LeaderboardRow[]> {
  const { data, error } = await supabase
    .from('profiles')
    .select('hunter_name, xp')
    .not('hunter_name', 'is', null)
    .order('xp', { ascending: false })
    .limit(limit)

  if (error) {
    console.error(error)
    return []
  }
  return (data ?? []) as LeaderboardRow[]
}
