export type PuzzleInputType = 'text' | 'choice'

export type BranchPathKey = 'CONTROL' | 'OBSERVE' | 'INFLUENCE'

/** Optional copy for player UI (buttons, labels). Stored in quests.body.ui */
export type QuestBranchUiCopy = {
  kicker?: string
  title?: string
  description?: string
}

export type QuestUiCopy = {
  introKicker?: string
  introCta?: string
  loadingMessage?: string
  challengeBadge?: string
  hintLabel?: string
  answerPlaceholder?: string
  submitLabel?: string
  submitBusyLabel?: string
  finaleBadge?: string
  finaleHeadline?: string
  branches?: Partial<Record<BranchPathKey, QuestBranchUiCopy>>
  completeSlugPrefix?: string
  completeTitle?: string
  /** Available placeholder: {branch} */
  completeLede?: string
  completeNote?: string
}

/** Admin form only — not sent to players. Optional labels for branching dropdowns. */
export type QuestBodyAdmin = {
  nextAfterControlLabel?: string
  nextAfterObserveLabel?: string
  nextAfterInfluenceLabel?: string
}

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
    /**
     * If true, the player only gets one submission for this puzzle.
     * Enforced server-side via `answer_attempts`.
     */
    singleAttempt?: boolean
    /**
     * If true and the player answers wrong, the quest is sealed for that player.
     * Enforced server-side via `user_quest_progress.failed_at`.
     */
    fatalWrong?: boolean
  }[]
  finalePrompt: string
  /** Optional override; default server-side 75 XP */
  xpFinale?: number
  ui?: QuestUiCopy
  admin?: QuestBodyAdmin
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
    singleAttempt?: boolean
    fatalWrong?: boolean
  }[]
  finalePrompt: string
  ui?: QuestUiCopy
}

export type QuestSummary = {
  id: string
  slug: string
  title: string
  starts_at: string | null
  ends_at: string | null
}

/** Row from `get_player_resolved_quest_summary` — status when id may be null */
export type ResolvedQuestStatus =
  | 'active'
  | 'waiting_next'
  | 'campaign_complete'
  | 'none'
