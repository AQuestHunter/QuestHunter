export type PuzzleInputType = 'text' | 'choice'

/** Stored in quests.body — includes answers (admin-only via direct DB or admin UI). */
export type QuestBody = {
  intro: string
  puzzles: {
    id: string
    prompt: string
    hint?: string
    answer: string
    /** Optional override; default server-side 25 XP */
    xp?: number
    inputType: PuzzleInputType
    choices?: string[]
  }[]
  finalePrompt: string
  /** Optional override; default server-side 75 XP */
  xpFinale?: number
}

/** Returned by get_player_quest_payload — answers stripped server-side */
export type PlayerQuestPayload = {
  intro: string
  puzzles: {
    id: string
    prompt: string
    hint?: string
    inputType: PuzzleInputType
    choices?: string[]
  }[]
  finalePrompt: string
}

export type QuestSummary = {
  id: string
  slug: string
  title: string
  starts_at: string | null
  ends_at: string | null
}
