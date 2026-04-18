import { type FormEvent, useCallback, useEffect, useMemo, useState } from 'react'
import { supabase } from '../lib/supabase'
import {
  ensureQuestProgress,
  fetchPlayerQuestPayload,
  submitFinale,
  submitPuzzleAnswer,
} from '../lib/questPlay'
import { mergeQuestUi } from '../lib/questUiDefaults'
import type { PlayerQuestPayload, QuestSummary } from '../types/quest'
import { useAuth } from '../contexts/AuthContext'

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

  const [prog, setProg] = useState<{
    step: number
    completed_at: string | null
    branch: string | null
    failed_at: string | null
    failed_puzzle_key: string | null
  } | null>(null)

  const reloadProgress = useCallback(async () => {
    if (!user?.id) return
    const { data, error } = await supabase
      .from('user_quest_progress')
      .select('step, completed_at, branch, failed_at, failed_puzzle_key')
      .eq('user_id', user.id)
      .eq('quest_id', summary.id)
      .maybeSingle()

    if (error) {
      console.error(error)
      return
    }

    if (!data) {
      setProg({ step: 0, completed_at: null, branch: null, failed_at: null, failed_puzzle_key: null })
      return
    }

    setProg({
      step: data.step,
      completed_at: data.completed_at,
      branch: data.branch,
      failed_at: (data as { failed_at?: string | null }).failed_at ?? null,
      failed_puzzle_key: (data as { failed_puzzle_key?: string | null }).failed_puzzle_key ?? null,
    })
  }, [summary.id, user?.id])

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

  const ui = useMemo(() => mergeQuestUi(payload?.ui), [payload?.ui])

  const phase = useMemo(() => {
    if (!payload || !prog) return 'loading'
    if (completedAt) return 'done'
    if (failedAt) return 'failed'
    if (step < puzzles.length) return 'puzzle'
    return 'finale'
  }, [completedAt, failedAt, payload, prog, puzzles.length, step])

  const currentPuzzle = puzzles[step]

  async function onSubmitPuzzle(e: FormEvent) {
    e.preventDefault()
    if (!currentPuzzle || busy) return
    setPuzzleError(null)
    setBusy(true)
    const res = await submitPuzzleAnswer(summary.id, currentPuzzle.id, attempt)
    setBusy(false)

    if (res.error === 'wrong_order') {
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
      setShake(true)
      window.setTimeout(() => setShake(false), 420)
      setAttempt('')
      if (res.fatal) {
        await reloadProgress()
        await refreshProfile()
      }
      return
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
    phase !== 'done'
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

  if (phase === 'puzzle' && currentPuzzle) {
    const isChoice = currentPuzzle.inputType === 'choice' && (currentPuzzle.choices?.length ?? 0) > 0
    const isSingleAttemptChoice = Boolean(isChoice && currentPuzzle.singleAttempt)
    const isFatalChoice = Boolean(isChoice && currentPuzzle.fatalWrong)

    const progressPct = puzzles.length > 0 ? ((step + 1) / puzzles.length) * 100 : 0

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
        <div className="quiz-body">
          <p className="quiz-prompt">{currentPuzzle.prompt}</p>
          {currentPuzzle.hint ? (
            <aside className="quiz-hint">
              <span className="quiz-hint-label mono">{ui.hintLabel}</span>
              <p className="quiz-hint-text mono">{currentPuzzle.hint}</p>
            </aside>
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
                  {puzzleError}
                </p>
              ) : null}
              <div className="choice-grid">
              {currentPuzzle.choices!.map((c, i) => (
                <button
                  key={c}
                  type="button"
                  className={`choice-btn mono ${choiceConfirm === c ? 'choice-btn--armed' : ''}`}
                  disabled={busy}
                  onClick={() => {
                    void (async () => {
                      setPuzzleError(null)
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

                      if (res.error) {
                        setPuzzleError(res.error)
                        setShake(true)
                        window.setTimeout(() => setShake(false), 420)
                        return
                      }

                      if (!res.correct) {
                        setShake(true)
                        window.setTimeout(() => setShake(false), 420)
                        if (res.fatal) {
                          await reloadProgress()
                          await refreshProfile()
                        }
                        return
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
                />
                <button type="submit" className="primary-btn mono quiz-submit-btn" disabled={busy}>
                  {busy ? ui.submitBusyLabel : ui.submitLabel}
                </button>
              </div>
              {puzzleError ? (
                <p className="mono error small" role="alert">
                  {puzzleError}
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
