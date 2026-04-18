import { supabase } from './supabase'
import { errorLooksLikeMissingCampaignRpc } from './questSchema'
import type { PlayerQuestPayload, QuestSummary, ResolvedQuestStatus } from '../types/quest'

function pickLatestSummaries(rows: QuestSummary[]): QuestSummary | null {
  if (rows.length === 0) return null
  return [...rows].sort(
    (a, b) => new Date(b.starts_at ?? 0).getTime() - new Date(a.starts_at ?? 0).getTime(),
  )[0]
}

/** Defaults to `"default"` (legacy: newest playable quest globally). Non-default enables branch-aware resolution. */
export function getPlayerCampaignSlugFromEnv(): string {
  const raw = import.meta.env.VITE_QUEST_CAMPAIGN_SLUG
  if (raw == null || String(raw).trim() === '') return 'default'
  return String(raw).trim()
}

export async function fetchActiveQuestSummaries(): Promise<{
  data: QuestSummary[] | null
  error: string | null
}> {
  const { data, error } = await supabase.rpc('list_active_quest_summaries')
  if (error) return { data: null, error: error.message }
  return { data: (data ?? []) as QuestSummary[], error: null }
}

/** Campaign slug: `default` keeps legacy pickLatest (newest playable quest). Set e.g. `project-oracle` for branch resolution. */
export async function fetchResolvedQuestSummary(campaignSlug: string): Promise<{
  summary: QuestSummary | null
  resolveStatus: ResolvedQuestStatus
  error: string | null
}> {
  const slug = campaignSlug.trim() || 'default'
  const { data, error } = await supabase.rpc('get_player_resolved_quest_summary', {
    p_campaign: slug,
  })
  if (error) {
    if (errorLooksLikeMissingCampaignRpc(error)) {
      const fb = await fetchActiveQuestSummaries()
      if (fb.error) return { summary: null, resolveStatus: 'none', error: fb.error }
      const latest = pickLatestSummaries(fb.data ?? [])
      return {
        summary: latest,
        resolveStatus: latest ? 'active' : 'none',
        error: null,
      }
    }
    return { summary: null, resolveStatus: 'none', error: error.message }
  }

  const row = Array.isArray(data) ? data[0] : null
  if (!row || typeof row !== 'object') {
    return { summary: null, resolveStatus: 'none', error: null }
  }

  const r = row as {
    id: string | null
    slug: string | null
    title: string | null
    starts_at: string | null
    ends_at: string | null
    resolve_status: string | null
  }

  const resolveStatus = (r.resolve_status ?? 'none') as ResolvedQuestStatus
  if (!r.id || !r.slug || !r.title) {
    return { summary: null, resolveStatus, error: null }
  }

  const summary: QuestSummary = {
    id: r.id,
    slug: r.slug,
    title: r.title,
    starts_at: r.starts_at,
    ends_at: r.ends_at,
  }
  return { summary, resolveStatus, error: null }
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
