import { type FormEvent, useCallback, useEffect, useMemo, useState } from 'react'
import { supabase } from '../lib/supabase'
import {
  ensureQuestProgress,
  fetchPlayerQuestPayload,
  submitFinale,
  submitPuzzleAnswer,
} from '../lib/questPlay'
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
  const [finaleError, setFinaleError] = useState<string | null>(null)
  const [introAck, setIntroAck] = useState(false)

  const [prog, setProg] = useState<{
    step: number
    completed_at: string | null
    branch: string | null
  } | null>(null)

  const reloadProgress = useCallback(async () => {
    if (!user?.id) return
    const { data, error } = await supabase
      .from('user_quest_progress')
      .select('step, completed_at, branch')
      .eq('user_id', user.id)
      .eq('quest_id', summary.id)
      .maybeSingle()

    if (error) {
      console.error(error)
      return
    }

    if (!data) {
      setProg({ step: 0, completed_at: null, branch: null })
      return
    }

    setProg({
      step: data.step,
      completed_at: data.completed_at,
      branch: data.branch,
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

  const phase = useMemo(() => {
    if (!payload || !prog) return 'loading'
    if (completedAt) return 'done'
    if (step < puzzles.length) return 'puzzle'
    return 'finale'
  }, [completedAt, payload, prog, puzzles.length, step])

  const currentPuzzle = puzzles[step]

  async function onSubmitPuzzle(e: FormEvent) {
    e.preventDefault()
    if (!currentPuzzle || busy) return
    setBusy(true)
    const res = await submitPuzzleAnswer(summary.id, currentPuzzle.id, attempt)
    setBusy(false)

    if (res.error === 'wrong_order') {
      setShake(true)
      window.setTimeout(() => setShake(false), 420)
      setAttempt('')
      return
    }

    if (!res.correct) {
      setShake(true)
      window.setTimeout(() => setShake(false), 420)
      setAttempt('')
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
      <article className={`quest-terminal ${shake ? 'shake' : ''}`}>
        <p className="mono error">
          {loadError === 'not_available'
            ? 'This dossier is sealed or outside the active window.'
            : loadError === 'not_found'
              ? 'Quest not found.'
              : loadError === 'auth'
                ? 'Session lost.'
                : `Signal lost: ${loadError}`}
        </p>
      </article>
    )
  }

  if (!payload || !prog || phase === 'loading') {
    return (
      <article className="quest-terminal">
        <p className="mono muted">decrypting dossier …</p>
      </article>
    )
  }

  if (
    payload.intro.trim().length > 0 &&
    !introAck &&
    phase !== 'done'
  ) {
    return (
      <article className="quest-intro-panel">
        <p className="narrative">{payload.intro}</p>
        <button
          type="button"
          className="primary-btn mono"
          onClick={() => {
            sessionStorage.setItem(`qh-intro-${summary.id}`, '1')
            setIntroAck(true)
          }}
        >
          Open channel →
        </button>
      </article>
    )
  }

  if (phase === 'done') {
    return (
      <article className="quest-terminal complete">
        <p className="mono small muted">CLOSED /// {summary.slug}</p>
        <h2>Dossier archived</h2>
        <p className="muted">
          Path logged:{' '}
          <span className="mono accent-strong">{finaleBranch ?? '—'}</span>. XP applied to your
          operator record.
        </p>
      </article>
    )
  }

  if (phase === 'puzzle' && currentPuzzle) {
    const isChoice = currentPuzzle.inputType === 'choice' && (currentPuzzle.choices?.length ?? 0) > 0

    return (
      <article className={`quest-terminal ${shake ? 'shake glitch-border' : ''}`}>
        <header className="terminal-head mono">
          <span>PUZZLE</span>
          <span>
            {step + 1}/{puzzles.length}
          </span>
        </header>
        <div className="terminal-body">
          <p className="prompt mono">{currentPuzzle.prompt}</p>
          {currentPuzzle.hint ? (
            <p className="hint mono">
              <span className="muted">hint ►</span> {currentPuzzle.hint}
            </p>
          ) : null}

          {isChoice ? (
            <div className="choice-grid">
              {currentPuzzle.choices!.map((c) => (
                <button
                  key={c}
                  type="button"
                  className="choice-btn mono"
                  disabled={busy}
                  onClick={() => {
                    setAttempt(c)
                    void (async () => {
                      setBusy(true)
                      const res = await submitPuzzleAnswer(summary.id, currentPuzzle.id, c)
                      setBusy(false)
                      if (!res.correct || res.error) {
                        setShake(true)
                        window.setTimeout(() => setShake(false), 420)
                        return
                      }
                      await reloadProgress()
                      await refreshProfile()
                    })()
                  }}
                >
                  {c}
                </button>
              ))}
            </div>
          ) : (
            <form className="puzzle-form" onSubmit={(e) => void onSubmitPuzzle(e)}>
              <label className="mono sr-only" htmlFor={`ans-${currentPuzzle.id}`}>
                Answer
              </label>
              <input
                id={`ans-${currentPuzzle.id}`}
                className="terminal-input mono wide"
                value={attempt}
                onChange={(e) => setAttempt(e.target.value)}
                placeholder="████"
                autoComplete="off"
                spellCheck={false}
              />
              <button type="submit" className="primary-btn mono" disabled={busy}>
                {busy ? '…' : 'Transmit'}
              </button>
            </form>
          )}
        </div>
      </article>
    )
  }

  return (
    <article className={`quest-terminal finale ${shake ? 'shake' : ''}`}>
      <header className="terminal-head mono">
        <span>FINALE</span>
        <span>branch</span>
      </header>
      <div className="terminal-body">
        <p className="prompt">{payload.finalePrompt}</p>
        {finaleError ? (
          <p className="mono error small" role="alert">
            {finaleError}
          </p>
        ) : null}
        <div className="branch-grid">
          <button type="button" className="branch-btn mono" disabled={busy} onClick={() => void pickFinale('CONTROL')}>
            CONTROL
          </button>
          <button type="button" className="branch-btn mono" disabled={busy} onClick={() => void pickFinale('OBSERVE')}>
            OBSERVE
          </button>
          <button
            type="button"
            className="branch-btn mono"
            disabled={busy}
            onClick={() => void pickFinale('INFLUENCE')}
          >
            INFLUENCE
          </button>
        </div>
      </div>
    </article>
  )
}
