import { type FormEvent, useCallback, useEffect, useMemo, useRef, useState } from 'react'
import { supabase } from '../lib/supabase'
import {
  ackQuestPreFinale,
  ensureQuestProgress,
  fetchPlayerQuestPayload,
  peekRevealedPuzzleHints,
  revealPuzzleHint,
  submitFinale,
  submitPuzzleAnswer,
} from '../lib/questPlay'
import { mergeQuestUi } from '../lib/questUiDefaults'
import type { PlayerQuestPayload, QuestSummary } from '../types/quest'
import { useAuth } from '../contexts/AuthContext'

const LIVES_DEFAULT_MAX = 5

function hintRpcErrorMessage(code: string): string {
  switch (code) {
    case 'all_hints_revealed':
      return 'All hints for this step are already revealed.'
    case 'no_hints':
      return 'No hints are configured for this step.'
    case 'wrong_puzzle':
      return 'Syncing puzzle state… try again.'
    default:
      return code
  }
}

function formatLivesCountdown(iso: string | null | undefined): string | null {
  if (!iso) return null
  const t = new Date(iso).getTime()
  if (Number.isNaN(t)) return null
  const ms = Math.max(0, t - Date.now())
  if (ms <= 0) return '0:00'
  const sec = Math.ceil(ms / 1000)
  const m = Math.floor(sec / 60)
  const r = sec % 60
  return `${m}:${r.toString().padStart(2, '0')}`
}

type Props = {
  summary: QuestSummary
  onDone?: () => void
}

export function QuestRunner({ summary, onDone }: Props) {
  const { user, refreshProfile } = useAuth()
  const [payload, setPayload] = useState<PlayerQuestPayload | null>(null)
  const [loadError, setLoadError] = useState<string | null>(null)
  const [busy, setBusy] = useState(false)
  const [shake, setShake] = useState(false)
  const [attempt, setAttempt] = useState('')
  const [puzzleError, setPuzzleError] = useState<string | null>(null)
  const [choiceConfirm, setChoiceConfirm] = useState<string | null>(null)
  const [finaleError, setFinaleError] = useState<string | null>(null)
  const [introAck, setIntroAck] = useState(false)
  const [liveHud, setLiveHud] = useState<{
    lives: number
    livesMax: number
    nextLifeAt: string | null
  }>({
    lives: LIVES_DEFAULT_MAX,
    livesMax: LIVES_DEFAULT_MAX,
    nextLifeAt: null,
  })
  /** Drives countdown re-renders */
  const [clockTick, setClockTick] = useState(0)

  /** Shown briefly after a correct puzzle (survives step advance). */
  const [xpFlash, setXpFlash] = useState<{
    xp: number
    base: number
    hints: number
    cleanBonus?: boolean
  } | null>(null)
  const [nearMissNote, setNearMissNote] = useState<string | null>(null)
  const [finaleXpFlash, setFinaleXpFlash] = useState<number | null>(null)
  const [revealedHints, setRevealedHints] = useState<string[]>([])
  const [hintTier, setHintTier] = useState(0)
  const [hintTotal, setHintTotal] = useState(0)
  const [hintBaseXp, setHintBaseXp] = useState(25)
  const [hintProjectedXp, setHintProjectedXp] = useState(25)
  const [hintRevealBusy, setHintRevealBusy] = useState(false)
  const [hintUiError, setHintUiError] = useState<string | null>(null)

  const xpFlashClearRef = useRef(0)

  const [prog, setProg] = useState<{
    step: number
    completed_at: string | null
    branch: string | null
    failed_at: string | null
    failed_puzzle_key: string | null
    state: Record<string, unknown> | null
  } | null>(null)

  const reloadProgress = useCallback(async () => {
    if (!user?.id) return
    const { data, error } = await supabase
      .from('user_quest_progress')
      .select('step, completed_at, branch, failed_at, failed_puzzle_key, state')
      .eq('user_id', user.id)
      .eq('quest_id', summary.id)
      .maybeSingle()

    if (error) {
      console.error(error)
      return
    }

    if (!data) {
      setProg({
        step: 0,
        completed_at: null,
        branch: null,
        failed_at: null,
        failed_puzzle_key: null,
        state: null,
      })
      return
    }

    const rawState = (data as { state?: unknown }).state
    const state =
      rawState && typeof rawState === 'object' && !Array.isArray(rawState)
        ? (rawState as Record<string, unknown>)
        : null

    setProg({
      step: data.step,
      completed_at: data.completed_at,
      branch: data.branch,
      failed_at: (data as { failed_at?: string | null }).failed_at ?? null,
      failed_puzzle_key: (data as { failed_puzzle_key?: string | null }).failed_puzzle_key ?? null,
      state,
    })
  }, [summary.id, user?.id])

  const syncPayloadLives = useCallback(async () => {
    const { payload: pl } = await fetchPlayerQuestPayload(summary.id)
    if (!pl) return
    setLiveHud({
      lives: typeof pl.lives === 'number' ? pl.lives : LIVES_DEFAULT_MAX,
      livesMax: typeof pl.livesMax === 'number' ? pl.livesMax : LIVES_DEFAULT_MAX,
      nextLifeAt: pl.nextLifeAt ?? null,
    })
  }, [summary.id])

  const applyLivesFromSubmit = useCallback((res: { lives?: number; nextLifeAt?: string | null }) => {
    if (res.lives === undefined) return
    setLiveHud((prev) => ({
      lives: res.lives!,
      livesMax: prev.livesMax,
      nextLifeAt: res.nextLifeAt !== undefined ? res.nextLifeAt : prev.nextLifeAt,
    }))
  }, [])

  const pushXpFlash = useCallback(
    (award: { xp: number; base: number; hints: number; cleanBonus?: boolean }) => {
      window.clearTimeout(xpFlashClearRef.current)
      setXpFlash(award)
      xpFlashClearRef.current = window.setTimeout(() => setXpFlash(null), 2800)
    },
    [],
  )

  useEffect(() => {
    const id = window.setInterval(() => setClockTick((n) => n + 1), 1000)
    return () => window.clearInterval(id)
  }, [])

  useEffect(() => {
    if (!liveHud.nextLifeAt || liveHud.lives >= liveHud.livesMax) return
    const target = new Date(liveHud.nextLifeAt).getTime()
    if (Number.isNaN(target)) return
    const id = window.setInterval(() => {
      if (Date.now() >= target) void syncPayloadLives()
    }, 2000)
    return () => window.clearInterval(id)
  }, [liveHud.nextLifeAt, liveHud.lives, liveHud.livesMax, syncPayloadLives])

  useEffect(() => {
    return () => window.clearTimeout(xpFlashClearRef.current)
  }, [])

  useEffect(() => {
    let cancelled = false

    async function boot() {
      setLoadError(null)
      await ensureQuestProgress(summary.id)

      const { payload: pl, error: payErr } = await fetchPlayerQuestPayload(summary.id)
      if (cancelled) return
      if (payErr || !pl) {
        setLoadError(payErr ?? 'payload')
        setPayload(null)
        return
      }

      setPayload(pl)
      setLiveHud({
        lives: typeof pl.lives === 'number' ? pl.lives : LIVES_DEFAULT_MAX,
        livesMax: typeof pl.livesMax === 'number' ? pl.livesMax : LIVES_DEFAULT_MAX,
        nextLifeAt: pl.nextLifeAt ?? null,
      })
      await reloadProgress()
    }

    void boot()
    return () => {
      cancelled = true
    }
  }, [summary.id, reloadProgress])

  useEffect(() => {
    if (!payload) return
    const key = `qh-intro-${summary.id}`
    if (sessionStorage.getItem(key) === '1') {
      setIntroAck(true)
    } else {
      setIntroAck(!(payload.intro && payload.intro.trim().length > 0))
    }
  }, [payload, summary.id])

  const puzzles = payload?.puzzles ?? []
  const step = prog?.step ?? 0

  const completedAt = prog?.completed_at ?? null
  const finaleBranch = prog?.branch ?? null
  const failedAt = prog?.failed_at ?? null

  const preFinaleAck = Boolean(prog?.state?.preFinaleAck === true)
  const hasPreFinaleCopy = useMemo(() => {
    const p = payload?.preFinale
    if (!p || typeof p !== 'object') return false
    const s = typeof p.summary === 'string' ? p.summary.trim() : ''
    const i = typeof p.implication === 'string' ? p.implication.trim() : ''
    return Boolean(s || i)
  }, [payload?.preFinale])

  const phase = useMemo(() => {
    if (!payload || !prog) return 'loading'
    if (completedAt) return 'done'
    if (failedAt) return 'failed'
    if (step < puzzles.length) return 'puzzle'
    if (hasPreFinaleCopy && !preFinaleAck) return 'preFinale'
    return 'finale'
  }, [completedAt, failedAt, hasPreFinaleCopy, payload, preFinaleAck, prog, puzzles.length, step])

  const currentPuzzleId = puzzles[step]?.id

  useEffect(() => {
    setNearMissNote(null)
  }, [currentPuzzleId])

  useEffect(() => {
    if (!currentPuzzleId || phase !== 'puzzle') return
    let cancelled = false
    void (async () => {
      const r = await peekRevealedPuzzleHints(summary.id, currentPuzzleId)
      if (cancelled) return
      const fallbackTotal = puzzles[step]?.hintCount ?? 0
      setHintUiError(null)
      if (r.ok) {
        setRevealedHints(r.hints)
        setHintTier(r.tier)
        setHintTotal(r.total > 0 ? r.total : fallbackTotal)
        setHintBaseXp(r.baseXp)
        setHintProjectedXp(r.projectedXp)
      } else {
        setRevealedHints([])
        setHintTier(0)
        setHintTotal(fallbackTotal)
        setHintBaseXp(25)
        setHintProjectedXp(25)
      }
    })()
    return () => {
      cancelled = true
    }
  }, [summary.id, currentPuzzleId, phase, puzzles, step])

  const ui = useMemo(() => mergeQuestUi(payload?.ui), [payload?.ui])

  const nextLifeLabel = useMemo(
    () => (liveHud.nextLifeAt ? formatLivesCountdown(liveHud.nextLifeAt) : null),
    [liveHud.nextLifeAt, clockTick],
  )

  const currentPuzzle = puzzles[step]

  const onRevealNextHint = useCallback(async () => {
    if (!currentPuzzle || hintRevealBusy) return
    const fromPayload = currentPuzzle.hintCount ?? 0
    const effTotal = hintTotal > 0 ? hintTotal : fromPayload
    if (effTotal < 1 || hintTier >= effTotal) return
    setHintRevealBusy(true)
    setHintUiError(null)
    const r = await revealPuzzleHint(summary.id, currentPuzzle.id)
    setHintRevealBusy(false)
    if (!r.ok) {
      setHintUiError(hintRpcErrorMessage(r.error ?? 'unknown'))
      return
    }
    if (r.hint) setRevealedHints((prev) => [...prev, r.hint!])
    setHintTier(r.tier)
    setHintTotal(r.total > 0 ? r.total : effTotal)
    setHintBaseXp(r.baseXp)
    setHintProjectedXp(r.projectedXp)
  }, [currentPuzzle, hintRevealBusy, hintTier, hintTotal, summary.id])

  async function onSubmitPuzzle(e: FormEvent) {
    e.preventDefault()
    if (!currentPuzzle || busy) return
    if (liveHud.lives < 1) {
      setPuzzleError('no_lives')
      return
    }
    setPuzzleError(null)
    setNearMissNote(null)
    setBusy(true)
    const res = await submitPuzzleAnswer(summary.id, currentPuzzle.id, attempt)
    setBusy(false)
    applyLivesFromSubmit(res)
    await refreshProfile()

    if (res.error === 'wrong_order') {
      setShake(true)
      window.setTimeout(() => setShake(false), 420)
      setAttempt('')
      return
    }

    if (res.error === 'no_lives') {
      setPuzzleError('no_lives')
      setShake(true)
      window.setTimeout(() => setShake(false), 420)
      setAttempt('')
      return
    }

    if (res.error) {
      setPuzzleError(res.error)
      setShake(true)
      window.setTimeout(() => setShake(false), 420)
      setAttempt('')
      return
    }

    if (!res.correct) {
      setNearMissNote(res.nearMiss ?? null)
      setShake(true)
      window.setTimeout(() => setShake(false), 420)
      setAttempt('')
      if (res.fatal) {
        await reloadProgress()
        await refreshProfile()
      }
      return
    }

    if (res.xpAwarded != null) {
      pushXpFlash({
        xp: res.xpAwarded,
        base: res.xpBase ?? 25,
        hints: res.hintsUsed ?? 0,
        cleanBonus: res.cleanSolveBonus === true,
      })
    }
    setAttempt('')
    await reloadProgress()
    await refreshProfile()
  }

  async function pickFinale(choice: 'CONTROL' | 'OBSERVE' | 'INFLUENCE') {
    setFinaleError(null)
    setBusy(true)
    const err = await submitFinale(summary.id, choice)
    setBusy(false)
    if (err.error) {
      setFinaleError(err.error)
      return
    }
    if (err.xpAwarded != null) {
      setFinaleXpFlash(err.xpAwarded)
    }
    await reloadProgress()
    await refreshProfile()
    onDone?.()
  }

  if (loadError) {
    return (
      <article className={`quest-terminal quiz-surface quiz-error ${shake ? 'shake' : ''}`}>
        <div className="quiz-error-inner">
          <p className="quiz-error-label mono">Signal interrupted</p>
          <p className="quiz-error-msg">
            {loadError === 'not_available'
              ? 'This dossier is sealed or outside the active window.'
              : loadError === 'not_found'
                ? 'Quest not found.'
                : loadError === 'auth'
                  ? 'Session lost.'
                  : `Signal lost: ${loadError}`}
          </p>
        </div>
      </article>
    )
  }

  if (!payload || !prog || phase === 'loading') {
    return (
      <article className="quest-terminal quiz-surface quiz-loading-card" aria-busy="true">
        <div className="quiz-loading">
          <div className="quiz-loading-orbit" aria-hidden />
          <p className="mono muted quiz-loading-text">{ui.loadingMessage}</p>
        </div>
      </article>
    )
  }

  if (
    payload.intro.trim().length > 0 &&
    !introAck &&
    phase !== 'done' &&
    step < puzzles.length
  ) {
    return (
      <article className="quest-intro-panel quiz-intro">
        <div className="quiz-intro-glow" aria-hidden />
        <div className="quiz-intro-inner">
          <p className="quiz-intro-kicker mono">{ui.introKicker}</p>
          <p className="narrative quiz-narrative">{payload.intro}</p>
          <button
            type="button"
            className="primary-btn mono quiz-intro-cta"
            onClick={() => {
              sessionStorage.setItem(`qh-intro-${summary.id}`, '1')
              setIntroAck(true)
            }}
          >
            {ui.introCta}
          </button>
        </div>
      </article>
    )
  }

  if (phase === 'done') {
    return (
      <article className="quest-terminal quiz-surface quiz-complete complete">
        <div className="quiz-complete-badge" aria-hidden>
          <span className="quiz-complete-check">✓</span>
        </div>
        <p className="mono quiz-complete-slug">
          {ui.completeSlugPrefix} {summary.slug}
        </p>
        <h2 className="quiz-complete-title">{ui.completeTitle}</h2>
        {finaleXpFlash != null ? (
          <p className="mono small quiz-complete-xp" role="status">
            Finale +{finaleXpFlash} XP
          </p>
        ) : null}
        <p className="muted quiz-complete-lede">
          {ui.completeLede.replace(/\{branch\}/g, finaleBranch ?? '—')}
        </p>
        <p className="muted small quiz-complete-note">{ui.completeNote}</p>
      </article>
    )
  }

  if (phase === 'failed') {
    return (
      <article className={`quest-terminal quiz-surface quiz-error ${shake ? 'shake' : ''}`}>
        <div className="quiz-error-inner">
          <p className="quiz-error-label mono">Dossier sealed</p>
          <p className="quiz-error-msg">
            You made a one-shot call and missed. ORACLE does not grant a second run on this dossier.
          </p>
          <p className="muted small quiz-complete-note">
            Tip: this mechanic is used only on specific choices. Most puzzles still allow retries.
          </p>
        </div>
      </article>
    )
  }

  if (phase === 'preFinale' && payload?.preFinale) {
    const pf = payload.preFinale
    const slotSummary = typeof pf.summary === 'string' ? pf.summary : ''
    const slotImplication = typeof pf.implication === 'string' ? pf.implication : ''
    return (
      <article className="quest-terminal quiz-surface quiz-prefinale">
        <header className="quiz-head mono">
          <span className="quiz-head-badge">{ui.preFinaleBadge}</span>
          <span className="quiz-head-step">{ui.preFinaleHeadline}</span>
        </header>
        <div className="quiz-body">
          {slotSummary ? <p className="narrative quiz-narrative">{slotSummary}</p> : null}
          {slotImplication ? (
            <p className="narrative quiz-narrative muted">{slotImplication}</p>
          ) : null}
          <button
            type="button"
            className="primary-btn mono quiz-intro-cta"
            disabled={busy}
            onClick={() => {
              void (async () => {
                setFinaleError(null)
                setBusy(true)
                const r = await ackQuestPreFinale(summary.id)
                setBusy(false)
                if (r.error) {
                  setFinaleError(r.error)
                  return
                }
                await reloadProgress()
              })()
            }}
          >
            {busy ? ui.submitBusyLabel : ui.preFinaleCta}
          </button>
          {finaleError ? (
            <p className="mono error small" role="alert">
              {finaleError}
            </p>
          ) : null}
        </div>
      </article>
    )
  }

  if (phase === 'puzzle' && currentPuzzle) {
    const isChoice = currentPuzzle.inputType === 'choice' && (currentPuzzle.choices?.length ?? 0) > 0
    const isSingleAttemptChoice = Boolean(isChoice && currentPuzzle.singleAttempt)
    const isFatalChoice = Boolean(isChoice && currentPuzzle.fatalWrong)

    const progressPct = puzzles.length > 0 ? ((step + 1) / puzzles.length) * 100 : 0
    const hintCountPayload = currentPuzzle.hintCount ?? 0
    const effectiveHintTotal = hintTotal > 0 ? hintTotal : hintCountPayload
    const canRevealMore = effectiveHintTotal > 0 && hintTier < effectiveHintTotal

    return (
      <article className={`quest-terminal quiz-surface ${shake ? 'shake glitch-border' : ''}`}>
        <div className="quiz-progress-track" aria-hidden>
          <div className="quiz-progress-fill" style={{ width: `${progressPct}%` }} />
        </div>
        <header className="quiz-head mono">
          <span className="quiz-head-badge">{ui.challengeBadge}</span>
          <span className="quiz-head-step">
            {step + 1} / {puzzles.length}
          </span>
        </header>
        <div className="quiz-lives-bar" aria-live="polite">
          <span className="quiz-lives-label muted small">Charges</span>
          <span className="quiz-lives-dots" title="Wrong answer uses one charge. +1 every 5 min up to 5.">
            {Array.from({ length: liveHud.livesMax }, (_, i) => (
              <span
                key={i}
                className={i < liveHud.lives ? 'quiz-life-dot quiz-life-dot--on' : 'quiz-life-dot quiz-life-dot--off'}
                aria-hidden
              />
            ))}
          </span>
          {liveHud.lives < liveHud.livesMax && nextLifeLabel ? (
            <span className="quiz-lives-next muted small">Next +1 in {nextLifeLabel}</span>
          ) : (
            <span className="quiz-lives-full small">Reserve full</span>
          )}
        </div>
        {liveHud.lives < 1 ? (
          <p className="mono small quiz-no-lives-note" role="alert">
            No charges left.{nextLifeLabel ? ` Next in ${nextLifeLabel}.` : ''}
          </p>
        ) : null}
        {xpFlash ? (
          <div className="quiz-xp-flash-wrap" role="status" aria-live="polite">
            <p className="quiz-xp-flash mono small">
              +{xpFlash.xp} XP
              {xpFlash.hints > 0
                ? ` · base ${xpFlash.base}, ${xpFlash.hints} hint tier${xpFlash.hints > 1 ? 's' : ''}`
                : ''}
              {xpFlash.cleanBonus ? ' · clean run bonus' : ''}
            </p>
          </div>
        ) : null}
        {nearMissNote ? (
          <p className="quiz-near-miss muted small" role="status">
            {nearMissNote}
          </p>
        ) : null}
        <div className="quiz-body">
          <p className="quiz-prompt">{currentPuzzle.prompt}</p>
          {effectiveHintTotal > 0 ? (
            <div className="quiz-hint-reveal-block">
              {revealedHints.length > 0 ? (
                <ol className="quiz-hint-stack" aria-label="Revealed hints">
                  {revealedHints.map((h, idx) => (
                    <li key={`${idx}-${h.slice(0, 24)}`} className="quiz-hint-tier">
                      <span className="quiz-hint-tier-label mono">
                        {ui.hintLabel} {idx + 1}/{effectiveHintTotal}
                      </span>
                      <p className="quiz-hint-tier-text">{h}</p>
                    </li>
                  ))}
                </ol>
              ) : null}
              <div className="quiz-hint-meta">
                <p className="quiz-hint-xp-line mono small muted">
                  {hintTier > 0
                    ? `Projected XP if solved now: ${hintProjectedXp} (max ${hintBaseXp})`
                    : `Max XP for this step: ${hintBaseXp}`}
                </p>
                <p className="quiz-hint-xp-note small muted">{ui.hintXpNote}</p>
                {hintUiError ? (
                  <p className="mono error small quiz-hint-err" role="alert">
                    {hintUiError}
                  </p>
                ) : null}
                <button
                  type="button"
                  className="ghost-btn mono quiz-hint-reveal-btn"
                  disabled={!canRevealMore || hintRevealBusy}
                  onClick={() => void onRevealNextHint()}
                >
                  {hintRevealBusy ? ui.submitBusyLabel : ui.hintRevealLabel}
                  <span className="quiz-hint-reveal-count" aria-hidden>
                    {' '}
                    ({hintTier}/{effectiveHintTotal})
                  </span>
                </button>
              </div>
            </div>
          ) : null}

          {isChoice ? (
            <div className="choice-shell">
              {isSingleAttemptChoice ? (
                <div className="choice-warning" role="note">
                  <p className="mono small choice-warning-title">One-shot choice</p>
                  <p className="muted small choice-warning-text">
                    First click arms the answer. Second click confirms. After that, this puzzle locks.
                    {isFatalChoice ? ' A wrong choice seals the dossier.' : null}
                  </p>
                </div>
              ) : null}
              {puzzleError ? (
                <p className="mono error small" role="alert">
                  {puzzleError === 'no_lives'
                    ? 'No charges left. Wait for the next regen.'
                    : puzzleError}
                </p>
              ) : null}
              <div className="choice-grid">
              {currentPuzzle.choices!.map((c, i) => (
                <button
                  key={c}
                  type="button"
                  className={`choice-btn mono ${choiceConfirm === c ? 'choice-btn--armed' : ''}`}
                  disabled={busy || liveHud.lives < 1}
            onClick={() => {
              void (async () => {
                setPuzzleError(null)
                setNearMissNote(null)
                if (liveHud.lives < 1) {
                  setPuzzleError('no_lives')
                  return
                }
                if (isSingleAttemptChoice) {
                  if (choiceConfirm !== c) {
                    setChoiceConfirm(c)
                    return
                  }
                }

                setAttempt(c)
                setBusy(true)
                const res = await submitPuzzleAnswer(summary.id, currentPuzzle.id, c)
                setBusy(false)
                applyLivesFromSubmit(res)
                await refreshProfile()

                if (res.error === 'wrong_order') {
                  setShake(true)
                  window.setTimeout(() => setShake(false), 420)
                  return
                }

                if (res.error === 'no_lives') {
                  setPuzzleError('no_lives')
                  setShake(true)
                  window.setTimeout(() => setShake(false), 420)
                  return
                }

                if (res.error) {
                  setPuzzleError(res.error)
                  setShake(true)
                  window.setTimeout(() => setShake(false), 420)
                  return
                }

                if (!res.correct) {
                  setNearMissNote(res.nearMiss ?? null)
                  setShake(true)
                  window.setTimeout(() => setShake(false), 420)
                  if (res.fatal) {
                    await reloadProgress()
                    await refreshProfile()
                  }
                  return
                }

                if (res.xpAwarded != null) {
                  pushXpFlash({
                    xp: res.xpAwarded,
                    base: res.xpBase ?? 25,
                    hints: res.hintsUsed ?? 0,
                    cleanBonus: res.cleanSolveBonus === true,
                  })
                }
                setChoiceConfirm(null)
                await reloadProgress()
                await refreshProfile()
              })()
            }}
                >
                  <span className="choice-index mono" aria-hidden>
                    {(i + 1).toString().padStart(2, '0')}
                  </span>
                  <span className="choice-label">{c}</span>
                </button>
              ))}
              </div>
            </div>
          ) : (
            <form className="puzzle-form quiz-answer-form" onSubmit={(e) => void onSubmitPuzzle(e)}>
              <label className="mono sr-only" htmlFor={`ans-${currentPuzzle.id}`}>
                {ui.answerPlaceholder}
              </label>
              <div className="quiz-input-row">
                <input
                  id={`ans-${currentPuzzle.id}`}
                  className="terminal-input mono wide quiz-answer-input"
                  value={attempt}
                  onChange={(e) => setAttempt(e.target.value)}
                  placeholder={ui.answerPlaceholder}
                  autoComplete="off"
                  spellCheck={false}
                  disabled={liveHud.lives < 1}
                />
                <button
                  type="submit"
                  className="primary-btn mono quiz-submit-btn"
                  disabled={busy || liveHud.lives < 1}
                >
                  {busy ? ui.submitBusyLabel : ui.submitLabel}
                </button>
              </div>
              {puzzleError ? (
                <p className="mono error small" role="alert">
                  {puzzleError === 'no_lives'
                    ? 'No charges left. Wait for the next regen.'
                    : puzzleError}
                </p>
              ) : null}
            </form>
          )}
        </div>
      </article>
    )
  }

  return (
    <article className={`quest-terminal quiz-surface quiz-finale-shell finale ${shake ? 'shake' : ''}`}>
      <header className="quiz-head mono quiz-head-finale">
        <span className="quiz-head-badge quiz-head-badge-finale">{ui.finaleBadge}</span>
        <span className="quiz-head-step">{ui.finaleHeadline}</span>
      </header>
      <div className="quiz-body">
        <p className="quiz-prompt quiz-finale-prompt">{payload.finalePrompt}</p>
        {finaleError ? (
          <p className="mono error small quiz-finale-error" role="alert">
            {finaleError}
          </p>
        ) : null}
        <div className="branch-grid">
          <button
            type="button"
            className="branch-card branch-card--control"
            disabled={busy}
            onClick={() => void pickFinale('CONTROL')}
          >
            <span className="branch-card-kicker mono">{ui.branches.CONTROL.kicker}</span>
            <span className="branch-card-title mono">{ui.branches.CONTROL.title}</span>
            <span className="branch-card-desc">{ui.branches.CONTROL.description}</span>
          </button>
          <button
            type="button"
            className="branch-card branch-card--observe"
            disabled={busy}
            onClick={() => void pickFinale('OBSERVE')}
          >
            <span className="branch-card-kicker mono">{ui.branches.OBSERVE.kicker}</span>
            <span className="branch-card-title mono">{ui.branches.OBSERVE.title}</span>
            <span className="branch-card-desc">{ui.branches.OBSERVE.description}</span>
          </button>
          <button
            type="button"
            className="branch-card branch-card--influence"
            disabled={busy}
            onClick={() => void pickFinale('INFLUENCE')}
          >
            <span className="branch-card-kicker mono">{ui.branches.INFLUENCE.kicker}</span>
            <span className="branch-card-title mono">{ui.branches.INFLUENCE.title}</span>
            <span className="branch-card-desc">{ui.branches.INFLUENCE.description}</span>
          </button>
        </div>
      </div>
    </article>
  )
}
