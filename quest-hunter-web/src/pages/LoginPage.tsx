import { type FormEvent, useState } from 'react'
import { Navigate, useLocation, useNavigate } from 'react-router-dom'
import { useAuth } from '../contexts/AuthContext'

export function LoginPage() {
  const { session, loading, signIn, signUp } = useAuth()
  const navigate = useNavigate()
  const location = useLocation()
  const from =
    (location.state as { from?: string } | null)?.from && (location.state as { from?: string }).from !== '/login'
      ? (location.state as { from: string }).from
      : '/quests'

  const [mode, setMode] = useState<'signin' | 'signup'>('signin')
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState<string | null>(null)
  const [pending, setPending] = useState(false)
  const [signupAwaitingEmail, setSignupAwaitingEmail] = useState(false)

  if (!loading && session) {
    return <Navigate to={from} replace />
  }

  async function onSubmit(e: FormEvent) {
    e.preventDefault()
    setError(null)
    setPending(true)
    if (mode === 'signin') {
      const { error: err } = await signIn(email.trim(), password)
      setPending(false)
      if (err) {
        setError(err.message)
        return
      }
      navigate(from, { replace: true })
      return
    }

    const { error: err, needsEmailConfirmation } = await signUp(email.trim(), password)
    setPending(false)
    if (err) {
      setError(err.message)
      return
    }
    if (needsEmailConfirmation) {
      setSignupAwaitingEmail(true)
      setPassword('')
      return
    }
    navigate(from, { replace: true })
  }

  return (
    <div className="shell login-shell">
      <div className="login-card">
        <header className="login-brand">
          <div className="login-logo-ring" aria-hidden>
            <img className="login-logo" src="/favicon.svg" alt="" width={52} height={50} decoding="async" />
          </div>
          <p className="hero-tag mono flicker login-eyebrow">HET GEBROKEN SIGNAAL</p>
          <h1 className="login-title">
            <span className="login-title-brand">Quest Hunter</span>
          </h1>
          <p className="muted small login-lede">
            Authenticate to sync progress. Every channel is logged; nothing broadcasts raw.
          </p>
        </header>

        <div className="login-tab-seg mono" role="tablist" aria-label="Account mode">
          <button
            type="button"
            role="tab"
            aria-selected={mode === 'signin'}
            className={mode === 'signin' ? 'tab active' : 'tab'}
            onClick={() => {
              setMode('signin')
              setSignupAwaitingEmail(false)
              setError(null)
            }}
          >
            Sign in
          </button>
          <button
            type="button"
            role="tab"
            aria-selected={mode === 'signup'}
            className={mode === 'signup' ? 'tab active' : 'tab'}
            onClick={() => {
              setMode('signup')
              setSignupAwaitingEmail(false)
              setError(null)
            }}
          >
            Sign up
          </button>
        </div>

        {signupAwaitingEmail ? (
          <div className="login-verify-notice mono small" role="status">
            <p className="login-verify-title">Bevestig je e-mail</p>
            <p className="muted login-verify-lede">
              We hebben een link gestuurd naar <strong className="login-verify-email">{email.trim()}</strong>.
              Open de link in die mail om je account te activeren. Daarna kun je hier inloggen.
            </p>
            <p className="muted login-verify-tip">
              Zie je geen mail? Controleer je spam- of map Ongewenste e-mail; soms duurt het een paar minuten.
            </p>
            <button
              type="button"
              className="primary-btn mono login-submit"
              onClick={() => {
                setSignupAwaitingEmail(false)
                setMode('signin')
                setError(null)
              }}
            >
              Terug naar inloggen
            </button>
          </div>
        ) : null}

        {!signupAwaitingEmail ? (
        <form className="stack-form login-form" onSubmit={(e) => void onSubmit(e)}>
          <label className="field">
            <span className="mono label-text">Email</span>
            <input
              className="terminal-input mono login-input"
              type="email"
              autoComplete="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
            />
          </label>
          <label className="field">
            <span className="mono label-text">Password</span>
            <input
              className="terminal-input mono login-input"
              type="password"
              autoComplete={mode === 'signup' ? 'new-password' : 'current-password'}
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
              minLength={6}
            />
          </label>
          {error ? (
            <p className="error mono small login-error" role="alert">
              {error}
            </p>
          ) : null}
          <button type="submit" className="primary-btn mono login-submit" disabled={pending}>
            {pending ? '…' : mode === 'signin' ? 'Enter channel' : 'Create account'}
          </button>
        </form>
        ) : null}
      </div>
    </div>
  )
}
