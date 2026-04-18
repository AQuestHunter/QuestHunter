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

  if (!loading && session) {
    return <Navigate to={from} replace />
  }

  async function onSubmit(e: FormEvent) {
    e.preventDefault()
    setError(null)
    setPending(true)
    const fn = mode === 'signin' ? signIn : signUp
    const { error: err } = await fn(email.trim(), password)
    setPending(false)
    if (err) {
      setError(err.message)
      return
    }
    navigate(from, { replace: true })
  }

  return (
    <div className="shell login-shell">
      <div className="login-card">
        <p className="hero-tag mono flicker">HET GEBROKEN SIGNAAL</p>
        <h1 className="login-title">Access</h1>
        <p className="muted small">
          Authenticate to sync progress. No signal leaves this channel unlogged.
        </p>

        <div className="tab-row mono">
          <button
            type="button"
            className={mode === 'signin' ? 'tab active' : 'tab'}
            onClick={() => setMode('signin')}
          >
            Sign in
          </button>
          <button
            type="button"
            className={mode === 'signup' ? 'tab active' : 'tab'}
            onClick={() => setMode('signup')}
          >
            Sign up
          </button>
        </div>

        <form className="stack-form" onSubmit={(e) => void onSubmit(e)}>
          <label className="field">
            <span className="mono label-text">Email</span>
            <input
              className="terminal-input mono"
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
              className="terminal-input mono"
              type="password"
              autoComplete={mode === 'signup' ? 'new-password' : 'current-password'}
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
              minLength={6}
            />
          </label>
          {error ? (
            <p className="error mono small" role="alert">
              {error}
            </p>
          ) : null}
          <button type="submit" className="primary-btn mono" disabled={pending}>
            {pending ? '…' : mode === 'signin' ? 'Enter' : 'Create account'}
          </button>
        </form>
      </div>
    </div>
  )
}
