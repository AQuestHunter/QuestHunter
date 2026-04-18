import { type FormEvent, useEffect, useState } from 'react'
import { supabase } from '../lib/supabase'
import { useAuth } from '../contexts/AuthContext'

type BoardRow = {
  hunter_name: string | null
  xp: number
}

export function ProfilePage() {
  const { user, profile, refreshProfile } = useAuth()
  const [hunterName, setHunterName] = useState(profile?.hunter_name ?? '')
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [board, setBoard] = useState<BoardRow[]>([])
  const [boardLoading, setBoardLoading] = useState(true)

  useEffect(() => {
    setHunterName(profile?.hunter_name ?? '')
  }, [profile?.hunter_name])

  useEffect(() => {
    let cancelled = false

    async function loadBoard() {
      setBoardLoading(true)
      const { data, error: err } = await supabase
        .from('profiles')
        .select('hunter_name, xp')
        .not('hunter_name', 'is', null)
        .order('xp', { ascending: false })
        .limit(25)

      if (cancelled) return
      if (err) {
        console.error(err)
        setBoard([])
      } else {
        setBoard((data ?? []) as BoardRow[])
      }
      setBoardLoading(false)
    }

    void loadBoard()
    return () => {
      cancelled = true
    }
  }, [])

  async function saveHunterName(e: FormEvent) {
    e.preventDefault()
    if (!user?.id) return
    setSaving(true)
    setError(null)

    const name = hunterName.trim()
    if (!name) {
      setError('Choose a hunter name.')
      setSaving(false)
      return
    }

    const { error: err } = await supabase
      .from('profiles')
      .update({ hunter_name: name, updated_at: new Date().toISOString() })
      .eq('id', user.id)

    setSaving(false)
    if (err) {
      if (err.code === '23505') {
        setError('That hunter name is already taken.')
      } else {
        setError(err.message)
      }
      return
    }

    await refreshProfile()
  }

  return (
    <section className="panel split">
      <div>
        <h1>Operator</h1>
        <p className="muted small">Linked account: {user?.email}</p>

        <form className="stack-form narrow" onSubmit={(e) => void saveHunterName(e)}>
          <label className="field">
            <span className="mono label-text">Hunter name</span>
            <input
              className="terminal-input mono"
              value={hunterName}
              onChange={(e) => setHunterName(e.target.value)}
              placeholder="Unique callsign"
              minLength={2}
              maxLength={32}
            />
          </label>
          {error ? (
            <p className="error mono small" role="alert">
              {error}
            </p>
          ) : null}
          <button type="submit" className="primary-btn mono" disabled={saving}>
            {saving ? 'Saving…' : 'Save'}
          </button>
        </form>
      </div>

      <div>
        <h2>Leaderboard</h2>
        <p className="muted small">Top hunters by XP (awarded per puzzle + finale).</p>
        {boardLoading ? (
          <p className="mono muted">loading ranks …</p>
        ) : (
          <ol className="leaderboard mono">
            {board.map((row, i) => (
              <li key={`${row.hunter_name}-${i}`}>
                <span className="rank">{i + 1}</span>
                <span className="name">{row.hunter_name}</span>
                <span className="xp">{row.xp} XP</span>
              </li>
            ))}
          </ol>
        )}
      </div>
    </section>
  )
}
