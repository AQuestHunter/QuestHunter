import type { BranchPathKey, QuestBranchUiCopy, QuestUiCopy } from '../types/quest'

/** Flat form state in Admin — empty fields mean “use built-in default”. */
export type QuestUiDraft = {
  introKicker: string
  introCta: string
  loadingMessage: string
  challengeBadge: string
  hintLabel: string
  answerPlaceholder: string
  submitLabel: string
  submitBusyLabel: string
  finaleBadge: string
  finaleHeadline: string
  completeSlugPrefix: string
  completeTitle: string
  completeLede: string
  completeNote: string
  branchControlKicker: string
  branchControlTitle: string
  branchControlDesc: string
  branchObserveKicker: string
  branchObserveTitle: string
  branchObserveDesc: string
  branchInfluenceKicker: string
  branchInfluenceTitle: string
  branchInfluenceDesc: string
}

export type ResolvedBranchUi = { kicker: string; title: string; description: string }

export type ResolvedQuestUi = {
  introKicker: string
  introCta: string
  loadingMessage: string
  challengeBadge: string
  hintLabel: string
  answerPlaceholder: string
  submitLabel: string
  submitBusyLabel: string
  finaleBadge: string
  finaleHeadline: string
  completeSlugPrefix: string
  completeTitle: string
  completeLede: string
  completeNote: string
  branches: Record<BranchPathKey, ResolvedBranchUi>
}

const BRANCH_KEYS: BranchPathKey[] = ['CONTROL', 'OBSERVE', 'INFLUENCE']

const DEFAULT_BRANCH: Record<BranchPathKey, ResolvedBranchUi> = {
  CONTROL: {
    kicker: 'Path A',
    title: 'CONTROL',
    description: 'Steer the outcome directly.',
  },
  OBSERVE: {
    kicker: 'Path B',
    title: 'OBSERVE',
    description: 'Watch without intervening.',
  },
  INFLUENCE: {
    kicker: 'Path C',
    title: 'INFLUENCE',
    description: 'Shape events indirectly.',
  },
}

export const DEFAULT_QUEST_UI = {
  introKicker: 'Briefing',
  introCta: 'Enter operation',
  loadingMessage: 'Decrypting dossier…',
  challengeBadge: 'Challenge',
  hintLabel: 'Hint',
  answerPlaceholder: 'Your answer',
  submitLabel: 'Submit',
  submitBusyLabel: '…',
  finaleBadge: 'Finale',
  finaleHeadline: 'Pick a path',
  completeSlugPrefix: 'CLOSED ///',
  completeTitle: 'Dossier archived',
  completeLede:
    'Finale path: {branch}. Logged for your campaign branch; XP is on your operator record.',
  completeNote: 'When the next chapter goes live for your path, return here to open the new dossier.',
  branches: DEFAULT_BRANCH,
}

export function emptyUiDraft(): QuestUiDraft {
  return {
    introKicker: '',
    introCta: '',
    loadingMessage: '',
    challengeBadge: '',
    hintLabel: '',
    answerPlaceholder: '',
    submitLabel: '',
    submitBusyLabel: '',
    finaleBadge: '',
    finaleHeadline: '',
    completeSlugPrefix: '',
    completeTitle: '',
    completeLede: '',
    completeNote: '',
    branchControlKicker: '',
    branchControlTitle: '',
    branchControlDesc: '',
    branchObserveKicker: '',
    branchObserveTitle: '',
    branchObserveDesc: '',
    branchInfluenceKicker: '',
    branchInfluenceTitle: '',
    branchInfluenceDesc: '',
  }
}

function readBranch(u: QuestUiCopy | undefined, key: BranchPathKey): QuestBranchUiCopy | undefined {
  return u?.branches?.[key]
}

/** Build Admin draft from stored quest body JSON. */
export function parseUiDraftFromBody(raw: unknown): QuestUiDraft {
  const d = emptyUiDraft()
  if (!raw || typeof raw !== 'object') return d
  const o = raw as Record<string, unknown>
  const u = o.ui
  if (!u || typeof u !== 'object') return d
  const ui = u as Record<string, unknown>
  const str = (k: string) => (typeof ui[k] === 'string' ? (ui[k] as string) : '')
  d.introKicker = str('introKicker')
  d.introCta = str('introCta')
  d.loadingMessage = str('loadingMessage')
  d.challengeBadge = str('challengeBadge')
  d.hintLabel = str('hintLabel')
  d.answerPlaceholder = str('answerPlaceholder')
  d.submitLabel = str('submitLabel')
  d.submitBusyLabel = str('submitBusyLabel')
  d.finaleBadge = str('finaleBadge')
  d.finaleHeadline = str('finaleHeadline')
  d.completeSlugPrefix = str('completeSlugPrefix')
  d.completeTitle = str('completeTitle')
  d.completeLede = str('completeLede')
  d.completeNote = str('completeNote')

  const branches = ui.branches as Record<string, unknown> | undefined
  function readPath(
    key: BranchPathKey,
    kicker: keyof QuestUiDraft,
    title: keyof QuestUiDraft,
    desc: keyof QuestUiDraft,
  ) {
    const b = branches?.[key]
    if (!b || typeof b !== 'object') return
    const x = b as Record<string, unknown>
    ;(d[kicker] as string) = typeof x.kicker === 'string' ? x.kicker : ''
    ;(d[title] as string) = typeof x.title === 'string' ? x.title : ''
    ;(d[desc] as string) = typeof x.description === 'string' ? x.description : ''
  }
  readPath('CONTROL', 'branchControlKicker', 'branchControlTitle', 'branchControlDesc')
  readPath('OBSERVE', 'branchObserveKicker', 'branchObserveTitle', 'branchObserveDesc')
  readPath('INFLUENCE', 'branchInfluenceKicker', 'branchInfluenceTitle', 'branchInfluenceDesc')
  return d
}

function pickBranchDraft(
  d: QuestUiDraft,
  key: BranchPathKey,
): { kicker: string; title: string; description: string } {
  if (key === 'CONTROL') {
    return {
      kicker: d.branchControlKicker.trim(),
      title: d.branchControlTitle.trim(),
      description: d.branchControlDesc.trim(),
    }
  }
  if (key === 'OBSERVE') {
    return {
      kicker: d.branchObserveKicker.trim(),
      title: d.branchObserveTitle.trim(),
      description: d.branchObserveDesc.trim(),
    }
  }
  return {
    kicker: d.branchInfluenceKicker.trim(),
    title: d.branchInfluenceTitle.trim(),
    description: d.branchInfluenceDesc.trim(),
  }
}

/** Persists only non-empty overrides; undefined = omit from body (defaults apply). */
export function compactUiDraft(draft: QuestUiDraft): QuestUiCopy | undefined {
  const out: QuestUiCopy = {}
  const w = (v: string): string | undefined => {
    const t = v.trim()
    return t ? t : undefined
  }
  const a = w(draft.introKicker)
  const b = w(draft.introCta)
  const c = w(draft.loadingMessage)
  if (a) out.introKicker = a
  if (b) out.introCta = b
  if (c) out.loadingMessage = c
  const d1 = w(draft.challengeBadge)
  const d2 = w(draft.hintLabel)
  const d3 = w(draft.answerPlaceholder)
  const d4 = w(draft.submitLabel)
  const d5 = w(draft.submitBusyLabel)
  if (d1) out.challengeBadge = d1
  if (d2) out.hintLabel = d2
  if (d3) out.answerPlaceholder = d3
  if (d4) out.submitLabel = d4
  if (d5) out.submitBusyLabel = d5
  const e1 = w(draft.finaleBadge)
  const e2 = w(draft.finaleHeadline)
  const e3 = w(draft.completeSlugPrefix)
  const e4 = w(draft.completeTitle)
  const e5 = w(draft.completeLede)
  const e6 = w(draft.completeNote)
  if (e1) out.finaleBadge = e1
  if (e2) out.finaleHeadline = e2
  if (e3) out.completeSlugPrefix = e3
  if (e4) out.completeTitle = e4
  if (e5) out.completeLede = e5
  if (e6) out.completeNote = e6

  const branches: Partial<Record<BranchPathKey, QuestBranchUiCopy>> = {}
  for (const key of BRANCH_KEYS) {
    const { kicker, title, description } = pickBranchDraft(draft, key)
    if (!kicker && !title && !description) continue
    const b: QuestBranchUiCopy = {}
    if (kicker) b.kicker = kicker
    if (title) b.title = title
    if (description) b.description = description
    branches[key] = b
  }
  if (Object.keys(branches).length > 0) out.branches = branches

  return Object.keys(out).length > 0 ? out : undefined
}

export function mergeQuestUi(ui?: QuestUiCopy | null): ResolvedQuestUi {
  const branches = {} as Record<BranchPathKey, ResolvedBranchUi>
  for (const key of BRANCH_KEYS) {
    const ov = readBranch(ui ?? undefined, key)
    const def = DEFAULT_BRANCH[key]
    branches[key] = {
      kicker: ov?.kicker?.trim() || def.kicker,
      title: ov?.title?.trim() || def.title,
      description: ov?.description?.trim() || def.description,
    }
  }

  const u = ui ?? undefined
  const pick = (k: keyof QuestUiCopy, fallback: string) => {
    const v = u?.[k]
    if (typeof v !== 'string') return fallback
    const t = v.trim()
    return t ? t : fallback
  }

  return {
    introKicker: pick('introKicker', DEFAULT_QUEST_UI.introKicker),
    introCta: pick('introCta', DEFAULT_QUEST_UI.introCta),
    loadingMessage: pick('loadingMessage', DEFAULT_QUEST_UI.loadingMessage),
    challengeBadge: pick('challengeBadge', DEFAULT_QUEST_UI.challengeBadge),
    hintLabel: pick('hintLabel', DEFAULT_QUEST_UI.hintLabel),
    answerPlaceholder: pick('answerPlaceholder', DEFAULT_QUEST_UI.answerPlaceholder),
    submitLabel: pick('submitLabel', DEFAULT_QUEST_UI.submitLabel),
    submitBusyLabel: pick('submitBusyLabel', DEFAULT_QUEST_UI.submitBusyLabel),
    finaleBadge: pick('finaleBadge', DEFAULT_QUEST_UI.finaleBadge),
    finaleHeadline: pick('finaleHeadline', DEFAULT_QUEST_UI.finaleHeadline),
    completeSlugPrefix: pick('completeSlugPrefix', DEFAULT_QUEST_UI.completeSlugPrefix),
    completeTitle: pick('completeTitle', DEFAULT_QUEST_UI.completeTitle),
    completeLede: pick('completeLede', DEFAULT_QUEST_UI.completeLede),
    completeNote: pick('completeNote', DEFAULT_QUEST_UI.completeNote),
    branches,
  }
}
