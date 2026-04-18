import { type FormEvent, useCallback, useEffect, useMemo, useState } from 'react'
import type { Json } from '../../lib/database.types'
import { supabase } from '../../lib/supabase'
import type { PuzzleInputType, QuestBody } from '../../types/quest'

type QuestRow = {
  id: string
  slug: string
  title: string
  body: Json
  starts_at: string | null
  ends_at: string | null
  is_published: boolean
  archived: boolean
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
  return {
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

  const [slug, setSlug] = useState('')
  const [title, setTitle] = useState('')
  const [isPublished, setIsPublished] = useState(false)
  const [archivedManual, setArchivedManual] = useState(false)
  const [startsAt, setStartsAt] = useState('')
  const [endsAt, setEndsAt] = useState('')
  const [intro, setIntro] = useState('')
  const [finalePrompt, setFinalePrompt] = useState('')
  const [xpFinale, setXpFinale] = useState('')
  const [puzzles, setPuzzles] = useState<PuzzleDraft[]>([emptyPuzzle()])
  const [saving, setSaving] = useState(false)

  const loadRows = useCallback(async () => {
    setLoading(true)
    const { data, error: err } = await supabase
      .from('quests')
      .select('id, slug, title, body, starts_at, ends_at, is_published, archived')
      .order('starts_at', { ascending: false })

    setLoading(false)
    if (err) {
      setError(err.message)
      setRows([])
      return
    }
    setError(null)
    setRows((data ?? []) as QuestRow[])
  }, [])

  useEffect(() => {
    void loadRows()
  }, [loadRows])

  const visibleRows = useMemo(
    () => rows.filter((r) => showArchived || !r.archived),
    [rows, showArchived],
  )

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
    setPuzzles([emptyPuzzle()])
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
    setPuzzles(draftsFromBody(body))
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

    const payload = {
      slug: slugClean,
      title: titleClean,
      body: body as unknown as Json,
      starts_at: startsIso,
      ends_at: endsIso,
      is_published: isPublished,
      ...(editingId ? { archived: archivedManual } : {}),
      updated_at: new Date().toISOString(),
    }

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
      </div>

      {error ? (
        <p className="mono error small" role="alert">
          {error}
        </p>
      ) : null}

      <div className="admin-split">
        <div className="admin-list">
          <h2 className="mono small muted">Existing</h2>
          {loading ? (
            <p className="muted mono">loading…</p>
          ) : rows.length === 0 ? (
            <p className="muted small">No quests yet.</p>
          ) : visibleRows.length === 0 ? (
            <p className="muted small">No matching quests — enable “Show archived”.</p>
          ) : (
            <ul className="admin-list-ul">
              {visibleRows.map((r) => (
                <li key={r.id}>
                  <button type="button" className="admin-list-btn" onClick={() => editRow(r)}>
                    <span className="mono slug">{r.slug}</span>
                    <span className="title">{r.title}</span>
                    <span className={`pill ${r.is_published ? 'on' : 'off'}`}>
                      {r.is_published ? 'live' : 'draft'}
                    </span>
                    {r.archived ? (
                      <span className="pill arc">archived</span>
                    ) : null}
                  </button>
                  <button type="button" className="icon-del mono" title="Delete" onClick={() => void remove(r.id)}>
                    ×
                  </button>
                </li>
              ))}
            </ul>
          )}
        </div>

        <form className="admin-form stack-form" onSubmit={(e) => void save(e)}>
          <h2 className="mono small muted">{editingId ? `Edit · ${editingId.slice(0, 8)}…` : 'Create'}</h2>

          <label className="field">
            <span className="mono label-text">Slug</span>
            <input className="terminal-input mono" value={slug} onChange={(e) => setSlug(e.target.value)} required />
          </label>
          <label className="field">
            <span className="mono label-text">Title</span>
            <input className="terminal-input mono" value={title} onChange={(e) => setTitle(e.target.value)} required />
          </label>

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
              <span className="mono small">Archived (manual restore / force archive)</span>
            </label>
          ) : null}

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

          <button type="submit" className="primary-btn mono" disabled={saving}>
            {saving ? 'Saving…' : editingId ? 'Update quest' : 'Create quest'}
          </button>
        </form>
      </div>
    </div>
  )
}
