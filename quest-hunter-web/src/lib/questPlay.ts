import { supabase } from './supabase'
import type { PlayerQuestPayload, QuestSummary } from '../types/quest'

export async function fetchActiveQuestSummaries(): Promise<{
  data: QuestSummary[] | null
  error: string | null
}> {
  const { data, error } = await supabase.rpc('list_active_quest_summaries')
  if (error) return { data: null, error: error.message }
  return { data: (data ?? []) as QuestSummary[], error: null }
}

export async function fetchPlayerQuestPayload(questId: string): Promise<{
  payload: PlayerQuestPayload | null
  error: string | null
}> {
  const { data, error } = await supabase.rpc('get_player_quest_payload', {
    p_quest_id: questId,
  })
  if (error) return { payload: null, error: error.message }
  if (!data || typeof data !== 'object') return { payload: null, error: 'empty_payload' }
  const raw = data as Record<string, unknown>
  if (typeof raw.error === 'string') return { payload: null, error: raw.error }

  const payload = data as PlayerQuestPayload
  return { payload, error: null }
}

export async function ensureQuestProgress(questId: string): Promise<{ error: string | null }> {
  const { error } = await supabase.rpc('ensure_quest_progress', { p_quest_id: questId })
  return { error: error?.message ?? null }
}

export async function submitPuzzleAnswer(
  questId: string,
  puzzleId: string,
  attempt: string,
): Promise<{
  correct: boolean
  error: string | null
}> {
  const { data, error } = await supabase.rpc('submit_puzzle_answer', {
    p_quest_id: questId,
    p_puzzle_id: puzzleId,
    p_attempt: attempt,
  })
  if (error) return { correct: false, error: error.message }
  const r = data as Record<string, unknown>
  if (r && r.ok === false) {
    return {
      correct: false,
      error: typeof r.error === 'string' ? r.error : 'unknown',
    }
  }
  return { correct: r.correct === true, error: null }
}

export async function submitFinale(
  questId: string,
  choice: 'CONTROL' | 'OBSERVE' | 'INFLUENCE',
): Promise<{ error: string | null }> {
  const { data, error } = await supabase.rpc('submit_finale_choice', {
    p_quest_id: questId,
    p_choice: choice,
  })
  if (error) return { error: error.message }
  const r = data as Record<string, unknown>
  if (r && r.ok === false) {
    return { error: typeof r.error === 'string' ? r.error : 'unknown' }
  }
  return { error: null }
}
