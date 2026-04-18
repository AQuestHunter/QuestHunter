import { type FormEvent, useCallback, useEffect, useMemo, useState } from 'react'
import type { Json } from '../../lib/database.types'
import { getProjectGroupLabel } from '../../lib/projectLabels'
import { errorLooksLikeMissingCampaignMigration } from '../../lib/questSchema'
import { supabase } from '../../lib/supabase'
import { AdminQuestPlayerUiFields } from './AdminQuestPlayerUiFields'
import {
  compactUiDraft,
  emptyUiDraft,
  parseUiDraftFromBody,
  type QuestUiDraft,
} from '../../lib/questUiDefaults'
import type { PuzzleInputType, QuestBody, QuestBodyAdmin } from '../../types/quest'

const DEFAULT_ADMIN_NEXT_AFTER = {
  CONTROL: 'Next quest after CONTROL',
  OBSERVE: 'Next quest after OBSERVE',
  INFLUENCE: 'Next quest after INFLUENCE',
} as const

const QUEST_SELECT_CAMPAIGN =
  'id, slug, title, body, starts_at, ends_at, is_published, archived, campaign_slug, campaign_display_name, sequence_idx, next_control_id, next_observe_id, next_influence_id'
const QUEST_SELECT_LEGACY =
  'id, slug, title, body, starts_at, ends_at, is_published, archived'

type LegacyQuestRow = {
  id: string
  slug: string
  title: string
  body: Json
  starts_at: string | null
  ends_at: string | null
  is_published: boolean
  archived: boolean
}

function fillCampaignDefaults(r: LegacyQuestRow): QuestRow {
  return {
    ...r,
    campaign_slug: 'default',
    campaign_display_name: null,
    sequence_idx: 1,
    next_control_id: null,
    next_observe_id: null,
    next_influence_id: null,
  }
}

type QuestRow = {
  id: string
  slug: string
  title: string
  body: Json
  starts_at: string | null
  ends_at: string | null
  is_published: boolean
  archived: boolean
  campaign_slug: string
  campaign_display_name: string | null
  sequence_idx: number
  next_control_id: string | null
  next_observe_id: string | null
  next_influence_id: string | null
}

/** Groups list + branch dropdowns: number (sequence_idx) then letter(s) in slug (natural order). */
const QUEST_SLUG_COLLATOR = new Intl.Collator(undefined, { numeric: true, sensitivity: 'base' })

function compareWithinProject(a: QuestRow, b: QuestRow): number {
  const seqA = a.sequence_idx ?? 1
  const seqB = b.sequence_idx ?? 1
  if (seqA !== seqB) return seqA - seqB
  return QUEST_SLUG_COLLATOR.compare(a.slug, b.slug)
}

function compareProjectKeys(a: string, b: string): number {
  return QUEST_SLUG_COLLATOR.compare(a, b)
}

function compareQuestRowsAdminOrder(a: QuestRow, b: QuestRow): number {
  const p = compareProjectKeys(a.campaign_slug || 'default', b.campaign_slug || 'default')
  if (p !== 0) return p
  return compareWithinProject(a, b)
}

/** Player-facing lifecycle for list grouping + editor banner (not the same as DB flags alone). */
type QuestLifecycleBucket = 'live' | 'scheduled' | 'ended' | 'draft' | 'archived'

const QUEST_BUCKET_ORDER: QuestLifecycleBucket[] = ['live', 'scheduled', 'ended', 'draft', 'archived']

const QUEST_BUCKET_LIST_TITLE: Record<QuestLifecycleBucket, string> = {
  live: 'Live — open to players',
  scheduled: 'Scheduled — starts later',
  ended: 'Ended — window closed',
  draft: 'Draft — not published',
  archived: 'Archived',
}

const QUEST_BUCKET_SHORT: Record<QuestLifecycleBucket, string> = {
  live: 'live',
  scheduled: 'scheduled',
  ended: 'ended',
  draft: 'draft',
  archived: 'archived',
}

const QUEST_BUCKET_HINT: Record<QuestLifecycleBucket, string> = {
  live: 'In the active time window; hunters can run this dossier.',
  scheduled: 'Published but start time is in the future.',
  ended: 'Published past its end time; players no longer see it as active.',
  draft: 'Not published yet — safe to edit freely.',
  archived: 'Marked archived for retention; hidden from players.',
}

function questLifecycleBucket(r: QuestRow): QuestLifecycleBucket {
  if (r.archived) return 'archived'
  if (!r.is_published) return 'draft'
  const now = Date.now()
  const startMs = r.starts_at ? new Date(r.starts_at).getTime() : NaN
  const endMs = r.ends_at ? new Date(r.ends_at).getTime() : NaN
  if (!Number.isFinite(startMs)) return 'draft'
  if (startMs > now) return 'scheduled'
  if (Number.isFinite(endMs) && endMs <= now) return 'ended'
  return 'live'
}

function groupQuestRowsByBucket(items: QuestRow[]): [QuestLifecycleBucket, QuestRow[]][] {
  const map = new Map<QuestLifecycleBucket, QuestRow[]>()
  for (const b of QUEST_BUCKET_ORDER) map.set(b, [])
  for (const r of items) {
    const b = questLifecycleBucket(r)
    map.get(b)!.push(r)
  }
  for (const [, arr] of map) {
    arr.sort(compareWithinProject)
  }
  const out: [QuestLifecycleBucket, QuestRow[]][] = []
  for (const b of QUEST_BUCKET_ORDER) {
    const arr = map.get(b)!
    if (arr.length > 0) out.push([b, arr])
  }
  return out
}

function pillClassForBucket(bucket: QuestLifecycleBucket): string {
  if (bucket === 'live') return 'pill pill--live'
  if (bucket === 'scheduled') return 'pill pill--scheduled'
  if (bucket === 'ended') return 'pill pill--ended'
  if (bucket === 'archived') return 'pill arc'
  return 'pill pill--draft'
}

type PuzzleDraft = {
  id: string
  prompt: string
  hint: string
  answer: string
  xp: string
  inputType: PuzzleInputType
  choices: string
}

const emptyPuzzle = (): PuzzleDraft => ({
  id: '',
  prompt: '',
  hint: '',
  answer: '',
  xp: '',
  inputType: 'text',
  choices: '',
})

function parseAdminFromRaw(o: Record<string, unknown>): QuestBodyAdmin | undefined {
  const adm = o.admin
  if (!adm || typeof adm !== 'object') return undefined
  const a = adm as Record<string, unknown>
  const admin: QuestBodyAdmin = {}
  const take = (key: keyof QuestBodyAdmin, rawKey: string) => {
    const v = a[rawKey]
    const s = typeof v === 'string' ? v.trim() : ''
    if (s) admin[key] = s
  }
  take('nextAfterControlLabel', 'nextAfterControlLabel')
  take('nextAfterObserveLabel', 'nextAfterObserveLabel')
  take('nextAfterInfluenceLabel', 'nextAfterInfluenceLabel')
  return Object.keys(admin).length ? admin : undefined
}

function compactAdminFromDraft(c: string, o: string, i: string): QuestBodyAdmin | undefined {
  const admin: QuestBodyAdmin = {}
  const tc = c.trim()
  const to = o.trim()
  const ti = i.trim()
  if (tc) admin.nextAfterControlLabel = tc
  if (to) admin.nextAfterObserveLabel = to
  if (ti) admin.nextAfterInfluenceLabel = ti
  return Object.keys(admin).length ? admin : undefined
}

function parseBody(raw: Json): QuestBody {
  const o = raw as Record<string, unknown>
  const puzzlesRaw = Array.isArray(o.puzzles) ? o.puzzles : []
  const puzzles = puzzlesRaw.map((p, i) => {
    const x = p as Record<string, unknown>
    const inputType = x.inputType === 'choice' ? 'choice' : 'text'
    const choicesArr = Array.isArray(x.choices) ? x.choices.map(String) : []
    return {
      id: typeof x.id === 'string' && x.id ? x.id : `puzzle-${i + 1}`,
      prompt: String(x.prompt ?? ''),
      hint: typeof x.hint === 'string' ? x.hint : '',
      answer: String(x.answer ?? ''),
      xp: typeof x.xp === 'number' ? String(x.xp) : '',
      inputType,
      choices: inputType === 'choice' ? choicesArr.join(', ') : '',
    } satisfies PuzzleDraft
  })
  const base: QuestBody = {
    intro: String(o.intro ?? ''),
    puzzles: puzzles.map((pz) => ({
      id: pz.id,
      prompt: pz.prompt,
      hint: pz.hint || undefined,
      answer: pz.answer,
      xp: pz.xp.trim() ? Number(pz.xp) : undefined,
      inputType: pz.inputType,
      choices:
        pz.inputType === 'choice'
          ? pz.choices
              .split(',')
              .map((s) => s.trim())
              .filter(Boolean)
          : undefined,
    })),
    finalePrompt: String(o.finalePrompt ?? ''),
    xpFinale: typeof o.xpFinale === 'number' ? o.xpFinale : undefined,
  }
  const adminParsed = parseAdminFromRaw(o)
  return adminParsed ? { ...base, admin: adminParsed } : base
}

function draftsFromBody(body: QuestBody): PuzzleDraft[] {
  if (body.puzzles.length === 0) return [emptyPuzzle()]
  return body.puzzles.map((pz, i) => ({
    id: pz.id || `puzzle-${i + 1}`,
    prompt: pz.prompt,
    hint: pz.hint ?? '',
    answer: pz.answer,
    xp: pz.xp != null ? String(pz.xp) : '',
    inputType: pz.inputType,
    choices: pz.choices?.join(', ') ?? '',
  }))
}

function toIsoFromLocal(dtLocal: string): string | null {
  if (!dtLocal) return null
  const d = new Date(dtLocal)
  return Number.isNaN(d.getTime()) ? null : d.toISOString()
}

function toLocalInput(iso: string | null): string {
  if (!iso) return ''
  const d = new Date(iso)
  if (Number.isNaN(d.getTime())) return ''
  const pad = (n: number) => String(n).padStart(2, '0')
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}T${pad(d.getHours())}:${pad(d.getMinutes())}`
}

export function AdminQuestsPanel() {
  const [rows, setRows] = useState<QuestRow[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [editingId, setEditingId] = useState<string | null>(null)
  const [showArchived, setShowArchived] = useState(false)
  const [sweepBusy, setSweepBusy] = useState(false)
  const [campaignFilter, setCampaignFilter] = useState<string>('')

  const [slug, setSlug] = useState('')
  const [title, setTitle] = useState('')
  const [isPublished, setIsPublished] = useState(false)
  const [archivedManual, setArchivedManual] = useState(false)
  const [startsAt, setStartsAt] = useState('')
  const [endsAt, setEndsAt] = useState('')
  const [intro, setIntro] = useState('')
  const [finalePrompt, setFinalePrompt] = useState('')
  const [xpFinale, setXpFinale] = useState('')
  const [uiDraft, setUiDraft] = useState<QuestUiDraft>(() => emptyUiDraft())
  const [puzzles, setPuzzles] = useState<PuzzleDraft[]>([emptyPuzzle()])
  const [saving, setSaving] = useState(false)

  const [campaignSlug, setCampaignSlug] = useState('default')
  const [campaignDisplayName, setCampaignDisplayName] = useState('')
  const [sequenceIdx, setSequenceIdx] = useState('1')
  const [nextControlId, setNextControlId] = useState('')
  const [nextObserveId, setNextObserveId] = useState('')
  const [nextInfluenceId, setNextInfluenceId] = useState('')
  const [adminNextAfterControlLabel, setAdminNextAfterControlLabel] = useState('')
  const [adminNextAfterObserveLabel, setAdminNextAfterObserveLabel] = useState('')
  const [adminNextAfterInfluenceLabel, setAdminNextAfterInfluenceLabel] = useState('')
  /** False when DB has not had `20260420000000_campaign_branching.sql` applied — Admin uses legacy columns only. */
  const [hasCampaignSchema, setHasCampaignSchema] = useState(true)

  type QuestEditorTab = 'basics' | 'campaign' | 'story' | 'playerUi'
  const [editorTab, setEditorTab] = useState<QuestEditorTab>('basics')

  const loadRows = useCallback(async () => {
    setLoading(true)
    const full = await supabase.from('quests').select(QUEST_SELECT_CAMPAIGN).order('starts_at', { ascending: false })

    if (full.error && errorLooksLikeMissingCampaignMigration(full.error)) {
      const legacy = await supabase.from('quests').select(QUEST_SELECT_LEGACY).order('starts_at', { ascending: false })
      setLoading(false)
      if (legacy.error) {
        setError(legacy.error.message)
        setRows([])
        return
      }
      setHasCampaignSchema(false)
      setError(null)
      setRows((legacy.data ?? []).map((row) => fillCampaignDefaults(row as LegacyQuestRow)))
      return
    }

    setLoading(false)
    if (full.error) {
      setError(full.error.message)
      setRows([])
      return
    }
    setHasCampaignSchema(true)
    setError(null)
    setRows((full.data ?? []) as QuestRow[])
  }, [])

  useEffect(() => {
    void loadRows()
  }, [loadRows])

  const visibleRows = useMemo(
    () =>
      rows.filter((r) => {
        if (!showArchived && r.archived) return false
        if (!campaignFilter.trim()) return true
        return r.campaign_slug === campaignFilter.trim()
      }),
    [rows, showArchived, campaignFilter],
  )

  const campaignOptions = useMemo(() => {
    const set = new Set<string>()
    for (const r of rows) {
      if (r.campaign_slug) set.add(r.campaign_slug)
    }
    return [...set].sort(compareProjectKeys)
  }, [rows])

  const groupedForList = useMemo(() => {
    const map = new Map<string, QuestRow[]>()
    for (const r of visibleRows) {
      const key = r.campaign_slug || 'default'
      const arr = map.get(key) ?? []
      arr.push(r)
      map.set(key, arr)
    }
    for (const [, items] of map) {
      items.sort(compareWithinProject)
    }
    return [...map.entries()].sort(([ka], [kb]) => compareProjectKeys(ka, kb))
  }, [visibleRows])

  /** Per campaign_slug: expanded or collapsed quest list (default expanded). */
  const [projectListOpen, setProjectListOpen] = useState<Record<string, boolean>>({})

  useEffect(() => {
    setProjectListOpen((prev) => {
      const next = { ...prev }
      let changed = false
      for (const [camp] of groupedForList) {
        if (!(camp in next)) {
          next[camp] = true
          changed = true
        }
      }
      return changed ? next : prev
    })
  }, [groupedForList])

  const expandAllProjects = useCallback(() => {
    const next: Record<string, boolean> = {}
    for (const [camp] of groupedForList) next[camp] = true
    setProjectListOpen(next)
  }, [groupedForList])

  const collapseAllProjects = useCallback(() => {
    const next: Record<string, boolean> = {}
    for (const [camp] of groupedForList) next[camp] = false
    setProjectListOpen(next)
  }, [groupedForList])

  const editingLifecycleBucket = useMemo(() => {
    if (!editingId) return null
    const row = rows.find((r) => r.id === editingId)
    return row ? questLifecycleBucket(row) : null
  }, [editingId, rows])

  const [projectNameEditSlug, setProjectNameEditSlug] = useState<string | null>(null)
  const [projectNameDraft, setProjectNameDraft] = useState('')
  const [projectNameSaving, setProjectNameSaving] = useState(false)

  function projectDisplayNameFromRows(questItems: QuestRow[]): string {
    return questItems.map((r) => r.campaign_display_name?.trim()).find(Boolean) ?? ''
  }

  function openProjectNameEdit(camp: string) {
    const questItems = rows.filter((r) => (r.campaign_slug || 'default') === camp)
    setProjectNameEditSlug(camp)
    setProjectNameDraft(projectDisplayNameFromRows(questItems))
  }

  async function saveProjectDisplayNameForCampaign(camp: string) {
    if (!hasCampaignSchema) return
    const name = projectNameDraft.trim()
    setProjectNameSaving(true)
    setError(null)
    const { error: err } = await supabase
      .from('quests')
      .update({
        campaign_display_name: name || null,
        updated_at: new Date().toISOString(),
      })
      .eq('campaign_slug', camp)
    setProjectNameSaving(false)
    if (err) {
      setError(err.message)
      return
    }
    const normCamp = campaignSlug.trim() || 'default'
    if (editingId && normCamp === camp) setCampaignDisplayName(name)
    setProjectNameEditSlug(null)
    await loadRows()
  }

  const downloadProjectJson = useCallback(
    (campaignSlugKey: string) => {
      const campaignQuests = rows
        .filter((r) => (r.campaign_slug || 'default') === campaignSlugKey)
        .sort(compareWithinProject)
      const displayName =
        campaignQuests.map((r) => r.campaign_display_name?.trim()).find(Boolean) ?? null
      const payload = {
        exportVersion: 1 as const,
        exportedAt: new Date().toISOString(),
        schema: { hasCampaignBranching: hasCampaignSchema },
        project: {
          campaign_slug: campaignSlugKey,
          campaign_display_name: displayName,
        },
        quests: campaignQuests.map((r) => ({
          id: r.id,
          slug: r.slug,
          title: r.title,
          body: r.body,
          starts_at: r.starts_at,
          ends_at: r.ends_at,
          is_published: r.is_published,
          archived: r.archived,
          campaign_slug: r.campaign_slug,
          campaign_display_name: r.campaign_display_name,
          sequence_idx: r.sequence_idx,
          next_control_id: r.next_control_id,
          next_observe_id: r.next_observe_id,
          next_influence_id: r.next_influence_id,
        })),
      }
      const safeName = campaignSlugKey.replace(/[^\w.-]+/g, '_').slice(0, 80) || 'project'
      const blob = new Blob([JSON.stringify(payload, null, 2)], { type: 'application/json;charset=utf-8' })
      const a = document.createElement('a')
      const url = URL.createObjectURL(blob)
      a.href = url
      a.download = `${safeName}-quest-export.json`
      a.click()
      URL.revokeObjectURL(url)
    },
    [rows, hasCampaignSchema],
  )

  const branchTargetOptions = useMemo(() => {
    const others = rows.filter((r) => r.id !== editingId)
    return [...others].sort(compareQuestRowsAdminOrder)
  }, [rows, editingId])

  async function runArchiveSweep() {
    setSweepBusy(true)
    setError(null)
    const { data, error: err } = await supabase.rpc('run_quest_archive_sweep_admin')
    setSweepBusy(false)
    if (err) {
      setError(err.message)
      return
    }
    const r = data as { ok?: boolean; archived_count?: number; error?: string }
    if (r && r.ok === false) {
      setError(r.error ?? 'sweep failed')
      return
    }
    await loadRows()
  }

  function resetForm() {
    setEditingId(null)
    setSlug('')
    setTitle('')
    setIsPublished(false)
    setArchivedManual(false)
    setStartsAt('')
    setEndsAt('')
    setIntro('')
    setFinalePrompt('')
    setXpFinale('')
    setUiDraft(emptyUiDraft())
    setPuzzles([emptyPuzzle()])
    setCampaignSlug('default')
    setCampaignDisplayName('')
    setSequenceIdx('1')
    setNextControlId('')
    setNextObserveId('')
    setNextInfluenceId('')
    setAdminNextAfterControlLabel('')
    setAdminNextAfterObserveLabel('')
    setAdminNextAfterInfluenceLabel('')
    setEditorTab('basics')
  }

  function editRow(row: QuestRow) {
    const body = parseBody(row.body)
    setEditingId(row.id)
    setSlug(row.slug)
    setTitle(row.title)
    setIsPublished(row.is_published)
    setArchivedManual(row.archived)
    setStartsAt(toLocalInput(row.starts_at))
    setEndsAt(toLocalInput(row.ends_at))
    setIntro(body.intro)
    setFinalePrompt(body.finalePrompt)
    setXpFinale(body.xpFinale != null ? String(body.xpFinale) : '')
    setUiDraft(parseUiDraftFromBody(row.body))
    setPuzzles(draftsFromBody(body))
    setCampaignSlug(row.campaign_slug?.trim() ? row.campaign_slug : 'default')
    setCampaignDisplayName(row.campaign_display_name?.trim() ?? '')
    setSequenceIdx(String(row.sequence_idx ?? 1))
    setNextControlId(row.next_control_id ?? '')
    setNextObserveId(row.next_observe_id ?? '')
    setNextInfluenceId(row.next_influence_id ?? '')
    setAdminNextAfterControlLabel(body.admin?.nextAfterControlLabel?.trim() ?? '')
    setAdminNextAfterObserveLabel(body.admin?.nextAfterObserveLabel?.trim() ?? '')
    setAdminNextAfterInfluenceLabel(body.admin?.nextAfterInfluenceLabel?.trim() ?? '')
  }

  function buildBody(): QuestBody | null {
    const cleaned = puzzles.map((pz, index) => {
      const id = (pz.id.trim() || `puzzle-${index + 1}`).slice(0, 64)
      const choices =
        pz.inputType === 'choice'
          ? pz.choices
              .split(',')
              .map((s) => s.trim())
              .filter(Boolean)
          : undefined
      return {
        id,
        prompt: pz.prompt.trim(),
        hint: pz.hint.trim() || undefined,
        answer: pz.answer.trim(),
        xp: pz.xp.trim() ? Number(pz.xp) : undefined,
        inputType: pz.inputType,
        choices,
      }
    })

    if (!cleaned.every((p) => p.prompt && p.answer)) {
      setError('Each puzzle needs prompt and answer.')
      return null
    }

    if (cleaned.some((p) => p.inputType === 'choice' && (!p.choices || p.choices.length === 0))) {
      setError('Choice puzzles need comma-separated choices.')
      return null
    }

    const uiPatch = compactUiDraft(uiDraft)
    const adminPatch = compactAdminFromDraft(
      adminNextAfterControlLabel,
      adminNextAfterObserveLabel,
      adminNextAfterInfluenceLabel,
    )
    return {
      intro: intro.trim(),
      puzzles: cleaned.map((p) => ({
        id: p.id,
        prompt: p.prompt,
        hint: p.hint || undefined,
        answer: p.answer,
        xp: p.xp != null && !Number.isNaN(p.xp) ? p.xp : undefined,
        inputType: p.inputType,
        choices: p.inputType === 'choice' ? p.choices : undefined,
      })),
      finalePrompt: finalePrompt.trim(),
      xpFinale: xpFinale.trim() ? Number(xpFinale) : undefined,
      ...(uiPatch ? { ui: uiPatch } : {}),
      ...(adminPatch ? { admin: adminPatch } : {}),
    }
  }

  async function save(e: FormEvent) {
    e.preventDefault()
    setSaving(true)
    setError(null)

    const body = buildBody()
    if (!body) {
      setSaving(false)
      return
    }

    const slugClean = slug.trim().toLowerCase().replace(/\s+/g, '-')
    const titleClean = title.trim()
    if (!slugClean || !titleClean) {
      setError('Slug and title are required.')
      setSaving(false)
      return
    }

    const startsIso = toIsoFromLocal(startsAt)
    const endsIso = endsAt.trim() ? toIsoFromLocal(endsAt) : null

    if (!startsIso) {
      setError('Start time is required for scheduling.')
      setSaving(false)
      return
    }

    const seqParsed = Number.parseInt(sequenceIdx.trim(), 10)
    const seqClean = Number.isFinite(seqParsed) && seqParsed > 0 ? seqParsed : 1
    const campClean = campaignSlug.trim() || 'default'

    const basePayload = {
      slug: slugClean,
      title: titleClean,
      body: body as unknown as Json,
      starts_at: startsIso,
      ends_at: endsIso,
      is_published: isPublished,
      ...(editingId ? { archived: archivedManual } : {}),
      updated_at: new Date().toISOString(),
    }

    const payload = hasCampaignSchema
      ? {
          ...basePayload,
          campaign_slug: campClean,
          campaign_display_name: campaignDisplayName.trim() || null,
          sequence_idx: seqClean,
          next_control_id: nextControlId.trim() || null,
          next_observe_id: nextObserveId.trim() || null,
          next_influence_id: nextInfluenceId.trim() || null,
        }
      : basePayload

    const q = editingId
      ? await supabase.from('quests').update(payload).eq('id', editingId).select('id').maybeSingle()
      : await supabase.from('quests').insert(payload).select('id').maybeSingle()

    setSaving(false)
    if (q.error) {
      setError(q.error.message)
      return
    }

    resetForm()
    await loadRows()
  }

  async function remove(id: string) {
    if (!window.confirm('Delete this quest permanently?')) return
    const { error: err } = await supabase.from('quests').delete().eq('id', id)
    if (err) {
      setError(err.message)
      return
    }
    if (editingId === id) resetForm()
    await loadRows()
  }

  const puzzleHint = useMemo(
    () => 'Answers are validated server-side; players never receive them in API payloads.',
    [],
  )

  return (
    <div className="admin-quests">
      <div className="admin-toolbar admin-toolbar-wrap">
        <button type="button" className="ghost-btn mono" onClick={() => resetForm()}>
          New quest
        </button>
        <button type="button" className="ghost-btn mono" onClick={() => void loadRows()} disabled={loading}>
          Refresh
        </button>
        <button
          type="button"
          className="ghost-btn mono"
          disabled={sweepBusy}
          onClick={() => void runArchiveSweep()}
          title="Mark quests archived when ends_at + 1 day has passed"
        >
          {sweepBusy ? 'Sweep…' : 'Archive sweep'}
        </button>
        <label className="field row-inline toolbar-check mono small">
          <input
            type="checkbox"
            checked={showArchived}
            onChange={(e) => setShowArchived(e.target.checked)}
          />
          Show archived
        </label>
        <label className="field row-inline mono small">
          <span>Project</span>
          <select
            className="terminal-input mono small"
            value={campaignFilter}
            onChange={(e) => setCampaignFilter(e.target.value)}
          >
            <option value="">All</option>
            {campaignOptions.map((c) => {
              const sample =
                rows.find((r) => r.campaign_slug === c && r.campaign_display_name?.trim()) ??
                rows.find((r) => r.campaign_slug === c)
              const { primary, secondary } = getProjectGroupLabel(c, sample ? [sample] : [])
              const label = secondary ? `${primary} · ${secondary}` : primary
              return (
                <option key={c} value={c}>
                  {label}
                </option>
              )
            })}
          </select>
        </label>
        {groupedForList.length > 0 ? (
          <>
            <button type="button" className="ghost-btn mono small" onClick={expandAllProjects}>
              Expand projects
            </button>
            <button type="button" className="ghost-btn mono small" onClick={collapseAllProjects}>
              Collapse projects
            </button>
          </>
        ) : null}
      </div>

      {error ? (
        <p className="mono error small" role="alert">
          {error}
        </p>
      ) : null}

      {!hasCampaignSchema ? (
        <p className="mono small muted" role="status">
          Branching columns are not in the database yet. Run migration{' '}
          <code className="mono">supabase/migrations/20260420000000_campaign_branching.sql</code> in the Supabase SQL
          Editor, then refresh. Drafts load in legacy mode; saves work without campaign fields.
        </p>
      ) : null}

      <div className="admin-split">
        <div className="admin-list">
          <div className="admin-list-heading">
            <h2 className="mono small muted admin-list-heading-title">Quests in this workspace</h2>
            <p className="admin-list-legend mono small muted">
              Within each project, dossiers are split by{' '}
              <span className="admin-list-legend-strong">lifecycle</span>
              : what players see depends on publish, schedule, and archive — not only the “Published” checkbox.
            </p>
          </div>
          {loading ? (
            <p className="muted mono">loading…</p>
          ) : rows.length === 0 ? (
            <p className="muted small">No quests yet.</p>
          ) : visibleRows.length === 0 ? (
            <p className="muted small">No matching quests — adjust project filter or enable “Show archived”.</p>
          ) : (
            <div className="admin-campaign-groups">
              {groupedForList.map(([camp, items]) => {
                const isOpen = projectListOpen[camp] ?? true
                const { primary, secondary } = getProjectGroupLabel(camp, items)
                const totalInCampaign = rows.filter((r) => (r.campaign_slug || 'default') === camp).length
                return (
                  <div key={camp} className="admin-campaign-group">
                    <div className="admin-campaign-group-header">
                      <button
                        type="button"
                        className="admin-project-caret-btn mono small"
                        aria-expanded={isOpen}
                        aria-label={isOpen ? 'Collapse project' : 'Expand project'}
                        onClick={() =>
                          setProjectListOpen((prev) => ({
                            ...prev,
                            [camp]: !(prev[camp] ?? true),
                          }))
                        }
                      >
                        <span className="admin-project-caret" aria-hidden>
                          {isOpen ? '▼' : '▶'}
                        </span>
                      </button>
                      {hasCampaignSchema && projectNameEditSlug === camp ? (
                        <div
                          className="admin-project-name-editor"
                          onClick={(e) => e.stopPropagation()}
                          role="group"
                          aria-label="Edit project display name"
                        >
                          <label className="sr-only" htmlFor={`admin-proj-name-${camp}`}>
                            Project display name
                          </label>
                          <input
                            id={`admin-proj-name-${camp}`}
                            className="terminal-input mono small admin-project-name-input"
                            value={projectNameDraft}
                            onChange={(e) => setProjectNameDraft(e.target.value)}
                            disabled={projectNameSaving}
                            placeholder="Project display name"
                            onKeyDown={(e) => {
                              if (e.key === 'Escape') {
                                e.preventDefault()
                                setProjectNameEditSlug(null)
                              }
                              if (e.key === 'Enter') {
                                e.preventDefault()
                                void saveProjectDisplayNameForCampaign(camp)
                              }
                            }}
                          />
                          <button
                            type="button"
                            className="primary-btn mono small"
                            disabled={projectNameSaving}
                            onClick={() => void saveProjectDisplayNameForCampaign(camp)}
                          >
                            {projectNameSaving ? '…' : 'Save'}
                          </button>
                          <button
                            type="button"
                            className="ghost-btn mono small"
                            disabled={projectNameSaving}
                            onClick={() => setProjectNameEditSlug(null)}
                          >
                            Cancel
                          </button>
                        </div>
                      ) : hasCampaignSchema ? (
                        <button
                          type="button"
                          className="admin-project-name-hit mono small"
                          title="Edit project display name"
                          onClick={() => openProjectNameEdit(camp)}
                        >
                          <span className="admin-project-toggle-text">
                            <span className="admin-project-line1">
                              <span className="muted">Project ·</span>{' '}
                              <span className="accent-strong">{primary}</span>
                              <span className="muted admin-project-count">
                                {' '}
                                ({totalInCampaign} dossier{totalInCampaign === 1 ? '' : 's'})
                              </span>
                            </span>
                            {secondary ? (
                              <span className="admin-project-secondary mono muted">{secondary}</span>
                            ) : null}
                          </span>
                        </button>
                      ) : (
                        <div className="admin-project-name-static mono small">
                          <span className="admin-project-toggle-text">
                            <span className="admin-project-line1">
                              <span className="muted">Project ·</span>{' '}
                              <span className="accent-strong">{primary}</span>
                              <span className="muted admin-project-count">
                                {' '}
                                ({totalInCampaign} dossier{totalInCampaign === 1 ? '' : 's'})
                              </span>
                            </span>
                            {secondary ? (
                              <span className="admin-project-secondary mono muted">{secondary}</span>
                            ) : null}
                          </span>
                        </div>
                      )}
                      <button
                        type="button"
                        className="ghost-btn mono small admin-project-download"
                        onClick={(e) => {
                          e.stopPropagation()
                          downloadProjectJson(camp)
                        }}
                        title="Download this project: all quests (including archived if any), full body JSON and branching fields"
                      >
                        JSON
                      </button>
                    </div>
                    {isOpen ? (
                      <div className="admin-quest-bucket-stack">
                        {groupQuestRowsByBucket(items).map(([bucket, bucketItems]) => (
                          <section
                            key={`${camp}-${bucket}`}
                            className={`admin-quest-bucket admin-quest-bucket--${bucket}`}
                            aria-labelledby={`bucket-${camp}-${bucket}`}
                          >
                            <div className="admin-quest-bucket-head">
                              <h3 className="admin-quest-bucket-heading mono small" id={`bucket-${camp}-${bucket}`}>
                                <span>{QUEST_BUCKET_LIST_TITLE[bucket]}</span>
                                <span className="admin-quest-bucket-count muted">({bucketItems.length})</span>
                              </h3>
                              <p className="admin-quest-bucket-hint muted small">{QUEST_BUCKET_HINT[bucket]}</p>
                            </div>
                            <ul className="admin-list-ul admin-list-ul--bucket">
                              {bucketItems.map((r) => (
                                  <li key={r.id} className={`admin-list-li admin-list-li--${bucket}`}>
                                    <button
                                      type="button"
                                      className={`admin-list-btn admin-list-btn--${bucket}`}
                                      onClick={() => editRow(r)}
                                    >
                                      <span className="mono muted">#{r.sequence_idx}</span>
                                      <span className="mono slug">{r.slug}</span>
                                      <span className="title">{r.title}</span>
                                      <span className={pillClassForBucket(bucket)}>
                                        {QUEST_BUCKET_SHORT[bucket]}
                                      </span>
                                    </button>
                                    <button
                                      type="button"
                                      className="icon-del mono"
                                      title="Delete"
                                      onClick={() => void remove(r.id)}
                                    >
                                      ×
                                    </button>
                                  </li>
                              ))}
                            </ul>
                          </section>
                        ))}
                      </div>
                    ) : null}
                  </div>
                )
              })}
            </div>
          )}
        </div>

        <form className="admin-form stack-form admin-editor-form" onSubmit={(e) => void save(e)}>
          <div className="admin-editor-toolbar">
            <div className="admin-editor-toolbar-top">
              <h2 className="admin-editor-title mono small muted">
                {editingId ? `Edit · ${editingId.slice(0, 8)}…` : 'Create quest'}
              </h2>
              <nav className="admin-editor-tabs" role="tablist" aria-label="Quest editor">
                {(
                  [
                    ['basics', 'Basics'],
                    ['campaign', 'Campaign'],
                    ['story', 'Story & puzzles'],
                    ['playerUi', 'Player UI'],
                  ] as const
                ).map(([id, label]) => (
                  <button
                    key={id}
                    type="button"
                    role="tab"
                    aria-selected={editorTab === id}
                    id={`editor-tab-${id}`}
                    className={`admin-editor-tab mono small ${editorTab === id ? 'active' : ''}`}
                    onClick={() => setEditorTab(id)}
                  >
                    {label}
                  </button>
                ))}
              </nav>
            </div>
            {editingLifecycleBucket ? (
              <div
                className={`admin-editor-live-status admin-editor-live-status--${editingLifecycleBucket}`}
                role="status"
              >
                <span className="admin-editor-live-status-dot" aria-hidden />
                <span className="mono small admin-editor-live-status-title">
                  {QUEST_BUCKET_LIST_TITLE[editingLifecycleBucket]}
                </span>
                <span className="muted small admin-editor-live-status-detail">
                  {QUEST_BUCKET_HINT[editingLifecycleBucket]}
                </span>
              </div>
            ) : null}
          </div>

          <div className="admin-editor-panels">
            {editorTab === 'basics' && (
              <div
                className="admin-editor-panel"
                role="tabpanel"
                aria-labelledby="editor-tab-basics"
              >
                <p className="admin-editor-panel-lede muted small">
                  Identity, visibility, and when this dossier is playable.
                </p>
                <div className="admin-form-grid-2">
                  <label className="field">
                    <span className="mono label-text">Slug</span>
                    <input
                      className="terminal-input mono"
                      value={slug}
                      onChange={(e) => setSlug(e.target.value)}
                      required
                    />
                  </label>
                  <label className="field">
                    <span className="mono label-text">Title</span>
                    <input
                      className="terminal-input mono"
                      value={title}
                      onChange={(e) => setTitle(e.target.value)}
                      required
                    />
                  </label>
                </div>
                <div className="admin-editor-inline-options">
                  <label className="field row-inline">
                    <input type="checkbox" checked={isPublished} onChange={(e) => setIsPublished(e.target.checked)} />
                    <span className="mono small">Published</span>
                  </label>
                  {editingId ? (
                    <label className="field row-inline">
                      <input
                        type="checkbox"
                        checked={archivedManual}
                        onChange={(e) => setArchivedManual(e.target.checked)}
                      />
                      <span className="mono small">Archived</span>
                    </label>
                  ) : null}
                </div>
                <div className="admin-form-grid-2">
                  <label className="field">
                    <span className="mono label-text">Starts at (local)</span>
                    <input
                      className="terminal-input mono"
                      type="datetime-local"
                      value={startsAt}
                      onChange={(e) => setStartsAt(e.target.value)}
                      required
                    />
                  </label>
                  <label className="field">
                    <span className="mono label-text">Ends at (optional)</span>
                    <input
                      className="terminal-input mono"
                      type="datetime-local"
                      value={endsAt}
                      onChange={(e) => setEndsAt(e.target.value)}
                    />
                  </label>
                </div>
              </div>
            )}

            {editorTab === 'campaign' && (
              <div
                className="admin-editor-panel"
                role="tabpanel"
                aria-labelledby="editor-tab-campaign"
              >
                <p className="admin-editor-panel-lede muted small">
                  Story arc slug, chapter order, and finale branch routing to the next dossier.
                </p>
                {hasCampaignSchema ? (
                  <fieldset className="campaign-fieldset admin-campaign-fieldset-flat">
                    <legend className="mono small muted">Campaign & branching</legend>
              <label className="field">
                <span className="mono label-text">Campaign slug</span>
                <span className="field-hint muted small">
                  Use one slug per story arc (e.g. project-oracle). “default” = global latest dossier on the Quests page.
                </span>
                <input
                  className="terminal-input mono"
                  value={campaignSlug}
                  onChange={(e) => setCampaignSlug(e.target.value)}
                  placeholder="default"
                />
              </label>
              <label className="field">
                <span className="mono label-text">Project display name</span>
                <span className="field-hint muted small">
                  Optional. Shown in grouped lists (Admin + Profile). Same value on any chapter in the project is fine.
                </span>
                <input
                  className="terminal-input mono"
                  value={campaignDisplayName}
                  onChange={(e) => setCampaignDisplayName(e.target.value)}
                  placeholder="e.g. PROJECT ORACLE"
                />
              </label>
              <label className="field">
                <span className="mono label-text">Sequence</span>
                <span className="field-hint muted small">Chapter order within the campaign (1 = entry).</span>
                <input
                  className="terminal-input mono"
                  inputMode="numeric"
                  value={sequenceIdx}
                  onChange={(e) => setSequenceIdx(e.target.value)}
                  min={1}
                />
              </label>
              <label className="field">
                <span className="mono label-text">CONTROL → next chapter</span>
                <span className="field-hint muted small">
                  Title above this dropdown (optional). Default: {DEFAULT_ADMIN_NEXT_AFTER.CONTROL}
                </span>
                <input
                  className="terminal-input mono small admin-branch-dropdown-title"
                  value={adminNextAfterControlLabel}
                  onChange={(e) => setAdminNextAfterControlLabel(e.target.value)}
                  placeholder={DEFAULT_ADMIN_NEXT_AFTER.CONTROL}
                  autoComplete="off"
                />
                <select
                  className="terminal-input mono"
                  value={nextControlId}
                  onChange={(e) => setNextControlId(e.target.value)}
                  aria-label={
                    adminNextAfterControlLabel.trim() || DEFAULT_ADMIN_NEXT_AFTER.CONTROL
                  }
                >
                  <option value="">— none —</option>
                  {branchTargetOptions.map((r) => (
                    <option key={r.id} value={r.id}>
                      [{r.sequence_idx}] {r.slug}
                    </option>
                  ))}
                </select>
              </label>
              <label className="field">
                <span className="mono label-text">OBSERVE → next chapter</span>
                <span className="field-hint muted small">
                  Default: {DEFAULT_ADMIN_NEXT_AFTER.OBSERVE}
                </span>
                <input
                  className="terminal-input mono small admin-branch-dropdown-title"
                  value={adminNextAfterObserveLabel}
                  onChange={(e) => setAdminNextAfterObserveLabel(e.target.value)}
                  placeholder={DEFAULT_ADMIN_NEXT_AFTER.OBSERVE}
                  autoComplete="off"
                />
                <select
                  className="terminal-input mono"
                  value={nextObserveId}
                  onChange={(e) => setNextObserveId(e.target.value)}
                  aria-label={
                    adminNextAfterObserveLabel.trim() || DEFAULT_ADMIN_NEXT_AFTER.OBSERVE
                  }
                >
                  <option value="">— none —</option>
                  {branchTargetOptions.map((r) => (
                    <option key={`o-${r.id}`} value={r.id}>
                      [{r.sequence_idx}] {r.slug}
                    </option>
                  ))}
                </select>
              </label>
              <label className="field">
                <span className="mono label-text">INFLUENCE → next chapter</span>
                <span className="field-hint muted small">
                  Default: {DEFAULT_ADMIN_NEXT_AFTER.INFLUENCE}
                </span>
                <input
                  className="terminal-input mono small admin-branch-dropdown-title"
                  value={adminNextAfterInfluenceLabel}
                  onChange={(e) => setAdminNextAfterInfluenceLabel(e.target.value)}
                  placeholder={DEFAULT_ADMIN_NEXT_AFTER.INFLUENCE}
                  autoComplete="off"
                />
                <select
                  className="terminal-input mono"
                  value={nextInfluenceId}
                  onChange={(e) => setNextInfluenceId(e.target.value)}
                  aria-label={
                    adminNextAfterInfluenceLabel.trim() || DEFAULT_ADMIN_NEXT_AFTER.INFLUENCE
                  }
                >
                  <option value="">— none —</option>
                  {branchTargetOptions.map((r) => (
                    <option key={`i-${r.id}`} value={r.id}>
                      [{r.sequence_idx}] {r.slug}
                    </option>
                  ))}
                </select>
              </label>
            </fieldset>
                ) : (
                  <p className="muted small admin-editor-migrate-hint">
                    Apply{' '}
                    <code className="mono">supabase/migrations/20260420000000_campaign_branching.sql</code> in the SQL
                    editor, refresh Admin, then campaign fields appear here.
                  </p>
                )}
              </div>
            )}

            {editorTab === 'story' && (
              <div
                className="admin-editor-panel"
                role="tabpanel"
                aria-labelledby="editor-tab-story"
              >
                <p className="admin-editor-panel-lede muted small">
                  Narrative copy, finale, XP overrides, and puzzle definitions for this dossier.
                </p>

          <label className="field">
            <span className="mono label-text">Intro narrative</span>
            <textarea
              className="terminal-input mono tall"
              value={intro}
              onChange={(e) => setIntro(e.target.value)}
              rows={5}
            />
          </label>

          <label className="field">
            <span className="mono label-text">Finale prompt</span>
            <textarea
              className="terminal-input mono tall"
              value={finalePrompt}
              onChange={(e) => setFinalePrompt(e.target.value)}
              rows={3}
              required
            />
          </label>

          <label className="field">
            <span className="mono label-text">Finale XP override</span>
            <input
              className="terminal-input mono"
              inputMode="numeric"
              placeholder="default 75"
              value={xpFinale}
              onChange={(e) => setXpFinale(e.target.value)}
            />
          </label>

          <div className="puzzle-blocks">
            <div className="mono small muted">Puzzles · {puzzleHint}</div>
            <p className="muted small admin-puzzle-lede">
              Steps run in order. Answers stay server-side. Choice puzzles: comma-separated options.
            </p>
            {puzzles.map((pz, idx) => (
              <fieldset key={`${pz.id}-${idx}`} className="puzzle-fieldset">
                <legend className="mono">Puzzle {idx + 1}</legend>
                <label className="field">
                  <span className="mono label-text">Id</span>
                  <input
                    className="terminal-input mono"
                    value={pz.id}
                    onChange={(e) => {
                      const next = [...puzzles]
                      next[idx] = { ...pz, id: e.target.value }
                      setPuzzles(next)
                    }}
                    placeholder={`puzzle-${idx + 1}`}
                  />
                </label>
                <label className="field">
                  <span className="mono label-text">Prompt</span>
                  <textarea
                    className="terminal-input mono tall"
                    value={pz.prompt}
                    onChange={(e) => {
                      const next = [...puzzles]
                      next[idx] = { ...pz, prompt: e.target.value }
                      setPuzzles(next)
                    }}
                    rows={3}
                    required
                  />
                </label>
                <label className="field">
                  <span className="mono label-text">Hint (optional)</span>
                  <input
                    className="terminal-input mono"
                    value={pz.hint}
                    onChange={(e) => {
                      const next = [...puzzles]
                      next[idx] = { ...pz, hint: e.target.value }
                      setPuzzles(next)
                    }}
                  />
                </label>
                <label className="field">
                  <span className="mono label-text">Correct answer</span>
                  <input
                    className="terminal-input mono"
                    value={pz.answer}
                    onChange={(e) => {
                      const next = [...puzzles]
                      next[idx] = { ...pz, answer: e.target.value }
                      setPuzzles(next)
                    }}
                    required
                    autoComplete="off"
                  />
                </label>
                <label className="field">
                  <span className="mono label-text">XP override</span>
                  <input
                    className="terminal-input mono"
                    inputMode="numeric"
                    placeholder="default 25"
                    value={pz.xp}
                    onChange={(e) => {
                      const next = [...puzzles]
                      next[idx] = { ...pz, xp: e.target.value }
                      setPuzzles(next)
                    }}
                  />
                </label>
                <label className="field">
                  <span className="mono label-text">Input</span>
                  <select
                    className="terminal-input mono"
                    value={pz.inputType}
                    onChange={(e) => {
                      const next = [...puzzles]
                      next[idx] = { ...pz, inputType: e.target.value as PuzzleInputType }
                      setPuzzles(next)
                    }}
                  >
                    <option value="text">Free text</option>
                    <option value="choice">Multiple choice</option>
                  </select>
                </label>
                {pz.inputType === 'choice' ? (
                  <label className="field">
                    <span className="mono label-text">Choices (comma-separated)</span>
                    <input
                      className="terminal-input mono"
                      value={pz.choices}
                      onChange={(e) => {
                        const next = [...puzzles]
                        next[idx] = { ...pz, choices: e.target.value }
                        setPuzzles(next)
                      }}
                      placeholder="ALPHA, BRAVO, CHARLIE"
                    />
                  </label>
                ) : null}
                <div className="puzzle-actions">
                  <button
                    type="button"
                    className="ghost-btn mono"
                    onClick={() => {
                      const next = puzzles.filter((_, i) => i !== idx)
                      setPuzzles(next.length === 0 ? [emptyPuzzle()] : next)
                    }}
                  >
                    Remove puzzle
                  </button>
                </div>
              </fieldset>
            ))}
            <button
              type="button"
              className="ghost-btn mono"
              onClick={() => setPuzzles([...puzzles, emptyPuzzle()])}
            >
              + Add puzzle
            </button>
          </div>
              </div>
            )}

            {editorTab === 'playerUi' && (
              <div
                className="admin-editor-panel admin-player-ui-tab"
                role="tabpanel"
                aria-labelledby="editor-tab-playerUi"
              >
                <p className="admin-editor-panel-lede muted small">
                  Optional overrides for buttons and labels during play. Sections below are collapsible.
                </p>
                <AdminQuestPlayerUiFields uiDraft={uiDraft} setUiDraft={setUiDraft} />
              </div>
            )}
          </div>

          <div className="admin-editor-footer">
            <button type="submit" className="primary-btn mono" disabled={saving}>
              {saving ? 'Saving…' : editingId ? 'Update quest' : 'Create quest'}
            </button>
            <p className="muted small admin-editor-save-hint">
              Saves everything in all tabs at once.
            </p>
          </div>
        </form>
      </div>
    </div>
  )
}
