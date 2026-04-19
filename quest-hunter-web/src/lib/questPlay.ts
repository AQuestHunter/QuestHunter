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

const PLAYER_CAMPAIGN_STORAGE_KEY = 'questHunter.playerCampaignSlug'

/**
 * Slug for `get_player_resolved_quest_summary`: per-device override, else `VITE_QUEST_CAMPAIGN_SLUG` / `default`.
 * When several projects are live, the Quests page lists them and stores the player’s choice here.
 */
export function getPlayerCampaignSlugForPlay(): string {
  if (typeof window === 'undefined') return getPlayerCampaignSlugFromEnv()
  try {
    const raw = window.localStorage.getItem(PLAYER_CAMPAIGN_STORAGE_KEY)
    if (raw != null && String(raw).trim() !== '') return String(raw).trim()
  } catch {
    /* private / blocked storage */
  }
  return getPlayerCampaignSlugFromEnv()
}

export function setPlayerCampaignSlugPreference(slug: string | null): void {
  if (typeof window === 'undefined') return
  try {
    if (slug == null || String(slug).trim() === '') {
      window.localStorage.removeItem(PLAYER_CAMPAIGN_STORAGE_KEY)
    } else {
      window.localStorage.setItem(PLAYER_CAMPAIGN_STORAGE_KEY, String(slug).trim())
    }
  } catch {
    /* ignore */
  }
}

export type ActivePlayerCampaign = { slug: string; label: string }

export async function fetchActivePlayerCampaigns(): Promise<ActivePlayerCampaign[]> {
  const { data, error } = await supabase.rpc('list_active_player_campaigns')
  if (error) {
    console.warn('list_active_player_campaigns:', error.message)
    return []
  }
  const rows = (data ?? []) as { campaign_slug: string; display_name: string }[]
  return rows.map((r) => ({
    slug: r.campaign_slug,
    label: (r.display_name?.trim() || r.campaign_slug).trim(),
  }))
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

export type PeekRevealedHintsResult = {
  ok: boolean
  error: string | null
  /** Decoded hint strings in order (0..used-1) */
  hints: string[]
  tier: number
  total: number
  baseXp: number
  projectedXp: number
}

function parseStringArray(r: unknown): string[] {
  if (!Array.isArray(r)) return []
  return r.map((x) => (typeof x === 'string' ? x : String(x)))
}

export async function peekRevealedPuzzleHints(
  questId: string,
  puzzleId: string,
): Promise<PeekRevealedHintsResult> {
  const { data, error } = await supabase.rpc('peek_revealed_puzzle_hints', {
    p_quest_id: questId,
    p_puzzle_id: puzzleId,
  })
  if (error) {
    return { ok: false, error: error.message, hints: [], tier: 0, total: 0, baseXp: 25, projectedXp: 25 }
  }
  const r = data as Record<string, unknown>
  if (r && r.ok === false) {
    return {
      ok: false,
      error: typeof r.error === 'string' ? r.error : 'unknown',
      hints: [],
      tier: 0,
      total: 0,
      baseXp: 25,
      projectedXp: 25,
    }
  }
  return {
    ok: r.ok === true,
    error: null,
    hints: parseStringArray(r.hints),
    tier: typeof r.tier === 'number' ? r.tier : 0,
    total: typeof r.total === 'number' ? r.total : 0,
    baseXp: typeof r.baseXp === 'number' ? r.baseXp : 25,
    projectedXp: typeof r.projectedXp === 'number' ? r.projectedXp : 25,
  }
}

export type RevealPuzzleHintResult = {
  ok: boolean
  error: string | null
  hint: string | null
  tier: number
  total: number
  baseXp: number
  projectedXp: number
}

export async function revealPuzzleHint(questId: string, puzzleId: string): Promise<RevealPuzzleHintResult> {
  const { data, error } = await supabase.rpc('reveal_puzzle_hint', {
    p_quest_id: questId,
    p_puzzle_id: puzzleId,
  })
  if (error) {
    return {
      ok: false,
      error: error.message,
      hint: null,
      tier: 0,
      total: 0,
      baseXp: 25,
      projectedXp: 25,
    }
  }
  const r = data as Record<string, unknown>
  if (r && r.ok === false) {
    return {
      ok: false,
      error: typeof r.error === 'string' ? r.error : 'unknown',
      hint: null,
      tier: 0,
      total: 0,
      baseXp: 25,
      projectedXp: 25,
    }
  }
  return {
    ok: true,
    error: null,
    hint: typeof r.hint === 'string' ? r.hint : null,
    tier: typeof r.tier === 'number' ? r.tier : 0,
    total: typeof r.total === 'number' ? r.total : 0,
    baseXp: typeof r.baseXp === 'number' ? r.baseXp : 25,
    projectedXp: typeof r.projectedXp === 'number' ? r.projectedXp : 25,
  }
}

function parseRpcNextLifeAt(r: Record<string, unknown>): string | null {
  const raw = r.next_life_at
  if (raw == null) return null
  if (typeof raw === 'string') return raw
  return null
}

function parseRpcLives(r: Record<string, unknown>): number | undefined {
  const raw = r.lives
  return typeof raw === 'number' && Number.isFinite(raw) ? raw : undefined
}

export async function submitPuzzleAnswer(
  questId: string,
  puzzleId: string,
  attempt: string,
): Promise<{
  correct: boolean
  fatal: boolean
  error: string | null
  lives?: number
  nextLifeAt?: string | null
  xpAwarded?: number
  xpBase?: number
  hintsUsed?: number
  wrongStrikes?: number
  nearMiss?: string | null
  cleanSolveBonus?: boolean
}> {
  const { data, error } = await supabase.rpc('submit_puzzle_answer', {
    p_quest_id: questId,
    p_puzzle_id: puzzleId,
    p_attempt: attempt,
  })
  if (error) {
    return { correct: false, fatal: false, error: error.message }
  }
  const r = data as Record<string, unknown>
  const lives = parseRpcLives(r)
  const nextLifeAt = parseRpcNextLifeAt(r)
  const xpAwarded = typeof r.xpAwarded === 'number' ? r.xpAwarded : undefined
  const xpBase = typeof r.xpBase === 'number' ? r.xpBase : undefined
  const hintsUsed = typeof r.hintsUsed === 'number' ? r.hintsUsed : undefined
  const wrongStrikes = typeof r.wrongStrikes === 'number' ? r.wrongStrikes : undefined
  const nearMiss = typeof r.nearMiss === 'string' ? r.nearMiss : null
  const cleanSolveBonus = typeof r.cleanSolveBonus === 'boolean' ? r.cleanSolveBonus : undefined
  if (r && r.ok === false) {
    return {
      correct: false,
      fatal: false,
      error: typeof r.error === 'string' ? r.error : 'unknown',
      lives,
      nextLifeAt,
    }
  }
  return {
    correct: r.correct === true,
    fatal: r.fatal === true,
    error: null,
    lives,
    nextLifeAt,
    xpAwarded,
    xpBase,
    hintsUsed,
    wrongStrikes,
    nearMiss,
    cleanSolveBonus,
  }
}

export async function ackQuestPreFinale(questId: string): Promise<{ error: string | null }> {
  const { data, error } = await supabase.rpc('ack_quest_pre_finale', {
    p_quest_id: questId,
  })
  if (error) return { error: error.message }
  const r = data as Record<string, unknown>
  if (r && r.ok === false) {
    return { error: typeof r.error === 'string' ? r.error : 'unknown' }
  }
  return { error: null }
}

export async function submitFinale(
  questId: string,
  choice: 'CONTROL' | 'OBSERVE' | 'INFLUENCE',
): Promise<{
  error: string | null
  xpAwarded?: number
  xpFinaleBase?: number
  finaleMultiplier?: number
}> {
  const { data, error } = await supabase.rpc('submit_finale_choice', {
    p_quest_id: questId,
    p_choice: choice,
  })
  if (error) return { error: error.message }
  const r = data as Record<string, unknown>
  if (r && r.ok === false) {
    return { error: typeof r.error === 'string' ? r.error : 'unknown' }
  }
  const xpAwarded = typeof r.xpAwarded === 'number' ? r.xpAwarded : undefined
  const xpFinaleBase = typeof r.xpFinaleBase === 'number' ? r.xpFinaleBase : undefined
  const finaleMultiplier =
    typeof r.finaleMultiplier === 'number' ? r.finaleMultiplier : undefined
  return { error: null, xpAwarded, xpFinaleBase, finaleMultiplier }
}
