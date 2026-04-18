import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'

type PingState =
  | { status: 'idle' }
  | { status: 'skipped'; reason: string }
  | { status: 'ok'; httpStatus: number; detail?: string }
  | { status: 'error'; message: string }

export function EnvCheckPage() {
  const rawUrl = import.meta.env.VITE_SUPABASE_URL as string | undefined
  const rawKey = import.meta.env.VITE_SUPABASE_ANON_KEY as string | undefined

  let hostname = ''
  let urlLooksLikeSupabase = false
  try {
    if (rawUrl) {
      const u = new URL(rawUrl)
      hostname = u.hostname
      urlLooksLikeSupabase = hostname.endsWith('.supabase.co') && u.protocol === 'https:'
    }
  } catch {
    hostname = ''
  }

  const hasPlaceholderUrl =
    !rawUrl ||
    rawUrl.includes('YOUR_PROJECT') ||
    rawUrl.includes('placeholder')
  const hasPlaceholderKey =
    !rawKey || rawKey.includes('YOUR_ANON') || rawKey.length < 40

  const [ping, setPing] = useState<PingState>({ status: 'idle' })

  useEffect(() => {
    let cancelled = false

    async function run() {
      if (!rawUrl || !rawKey || hasPlaceholderUrl || hasPlaceholderKey) {
        setPing({
          status: 'skipped',
          reason: 'Missing or placeholder env vars — Netlify build may not have seen them.',
        })
        return
      }

      try {
        const healthUrl = new URL('/auth/v1/health', rawUrl).toString()
        const res = await fetch(healthUrl, { method: 'GET' })
        const text = await res.text().catch(() => '')
        if (cancelled) return
        setPing({
          status: 'ok',
          httpStatus: res.status,
          detail: text?.slice(0, 120) || undefined,
        })
      } catch (e) {
        if (cancelled) return
        setPing({
          status: 'error',
          message: e instanceof Error ? e.message : String(e),
        })
      }
    }

    void run()
    return () => {
      cancelled = true
    }
  }, [rawUrl, rawKey, hasPlaceholderUrl, hasPlaceholderKey])

  return (
    <div className="shell env-check-shell">
      <main className="main-pane panel">
        <h1>Environment check</h1>
        <p className="muted small">
          Safe summary only — nothing here prints your anon key. Use this after a Netlify deploy to confirm build-time
          variables were embedded.
        </p>

        <section className="env-card">
          <h2 className="mono">VITE_SUPABASE_URL</h2>
          <ul className="env-list mono small">
            <li>
              <strong>Present:</strong> {rawUrl ? 'yes' : 'no'}
            </li>
            <li>
              <strong>Host:</strong> {hostname || '—'}
            </li>
            <li>
              <strong>HTTPS + *.supabase.co:</strong> {urlLooksLikeSupabase ? 'looks good' : 'check format'}
            </li>
            <li>
              <strong>Placeholder pattern:</strong> {hasPlaceholderUrl ? 'YES — fix in Netlify' : 'no'}
            </li>
          </ul>
        </section>

        <section className="env-card">
          <h2 className="mono">VITE_SUPABASE_ANON_KEY</h2>
          <ul className="env-list mono small">
            <li>
              <strong>Present:</strong> {rawKey ? 'yes' : 'no'}
            </li>
            <li>
              <strong>Length:</strong> {rawKey ? `${rawKey.length} chars` : '—'}
            </li>
            <li>
              <strong>Looks like placeholder:</strong> {hasPlaceholderKey ? 'YES — fix in Netlify' : 'no'}
            </li>
          </ul>
        </section>

        <section className="env-card">
          <h2 className="mono">Reachability</h2>
          <p className="muted small">
            GET <code className="mono">/auth/v1/health</code> on your project URL (public endpoint).
          </p>
          {ping.status === 'idle' ? <p className="mono muted">Checking…</p> : null}
          {ping.status === 'skipped' ? (
            <p className="mono error">{ping.reason}</p>
          ) : null}
          {ping.status === 'ok' ? (
            <p className="mono">
              HTTP {ping.httpStatus}
              {ping.detail ? ` — ${ping.detail}` : ''}
            </p>
          ) : null}
          {ping.status === 'error' ? <p className="mono error">{ping.message}</p> : null}
        </section>

        <section className="env-card muted small">
          <h2 className="mono">Netlify checklist</h2>
          <ol className="env-ol">
            <li>
              Names must be exactly <code className="mono">VITE_SUPABASE_URL</code> and{' '}
              <code className="mono">VITE_SUPABASE_ANON_KEY</code> (case-sensitive).
            </li>
            <li>Scopes: set for <strong>Production</strong> (and Preview if you use branch deploys).</li>
            <li>
              After changing variables, trigger <strong>Deploy → Clear cache and deploy site</strong> (Vite bakes env at
              build time).
            </li>
            <li>
              Compare values to Supabase <strong>Project Settings → API</strong> (Project URL + anon public key).
            </li>
          </ol>
        </section>

        <p>
          <Link to="/login" className="mono">
            ← Back to login
          </Link>
        </p>
      </main>
    </div>
  )
}
