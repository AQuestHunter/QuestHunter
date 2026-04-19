import { useEffect, useMemo, useState } from 'react'
import { Link } from 'react-router-dom'
import { fetchLeaderboard, type LeaderboardRow } from '../lib/leaderboard'
import { useAuth } from '../contexts/AuthContext'

const BOARD_LIMIT = 50

function PodiumSlot({
  rank,
  row,
  heightClass,
  toneClass,
  medal,
  isSelf,
}: {
  rank: 1 | 2 | 3
  row: LeaderboardRow | undefined
  heightClass: string
  toneClass: string
  medal: string
  isSelf: boolean
}) {
  const empty = !row?.hunter_name
  return (
    <div
      className={[
        'leaderboard-podium-slot',
        heightClass,
        toneClass,
        empty ? 'leaderboard-podium-slot--empty' : '',
        isSelf ? 'leaderboard-podium-slot--self' : '',
      ]
        .filter(Boolean)
        .join(' ')}
      role="group"
      aria-label={empty ? `Rank ${rank} vacant` : `Rank ${rank}, ${row.hunter_name}`}
    >
      <div className="leaderboard-podium-plate">
        <span className="leaderboard-podium-medal mono" aria-hidden>
          {medal}
        </span>
        <span className="leaderboard-podium-rank mono">#{rank}</span>
        {empty ? (
          <span className="leaderboard-podium-name muted">—</span>
        ) : (
          <>
            <span className="leaderboard-podium-name">{row.hunter_name}</span>
            <span className="leaderboard-podium-xp mono">{row.xp.toLocaleString()} XP</span>
          </>
        )}
      </div>
      <div className="leaderboard-podium-riser" />
    </div>
  )
}

export function LeaderboardPage() {
  const { profile } = useAuth()
  const callsign = profile?.hunter_name?.trim()
  const [rows, setRows] = useState<LeaderboardRow[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    let cancelled = false
    ;(async () => {
      setLoading(true)
      const data = await fetchLeaderboard(BOARD_LIMIT)
      if (!cancelled) {
        setRows(data)
        setLoading(false)
      }
    })()
    return () => {
      cancelled = true
    }
  }, [])

  const top = rows[0]
  const second = rows[1]
  const third = rows[2]
  const rest = rows.slice(3)

  const playerRank = useMemo(() => {
    if (!callsign) return null
    const idx = rows.findIndex((r) => r.hunter_name === callsign)
    return idx === -1 ? null : idx + 1
  }, [rows, callsign])

  const selfRankLabel =
    playerRank != null
      ? `You are #${playerRank}${playerRank > BOARD_LIMIT ? '+' : ''} on this board.`
      : callsign
        ? 'You are outside this listing — keep climbing.'
        : null

  return (
    <section className="panel leaderboard-page">
      <div className="hero-block hero-glitch leaderboard-page-hero">
        <p className="hero-tag mono flicker">Global standings</p>
        <h1>Leaderboard</h1>
        <p className="muted hero-sub">
          Top {BOARD_LIMIT} operators by lifetime XP — puzzles, finales, and runs that credit your profile.
        </p>
      </div>

      {selfRankLabel ? (
        <p className="leaderboard-you-banner mono small" role="status">
          {selfRankLabel}
        </p>
      ) : null}

      {loading ? (
        <p className="mono muted leaderboard-page-loading">Syncing ranks…</p>
      ) : rows.length === 0 ? (
        <p className="muted small">No ranked operators yet. Finish a quest to appear here.</p>
      ) : (
        <>
          <div className="leaderboard-podium-wrap">
            <div className="leaderboard-podium">
              <PodiumSlot
                rank={2}
                row={second}
                heightClass="leaderboard-podium-slot--h2"
                toneClass="leaderboard-podium-slot--silver"
                medal="◇"
                isSelf={Boolean(callsign && second?.hunter_name === callsign)}
              />
              <PodiumSlot
                rank={1}
                row={top}
                heightClass="leaderboard-podium-slot--h1"
                toneClass="leaderboard-podium-slot--gold"
                medal="◆"
                isSelf={Boolean(callsign && top?.hunter_name === callsign)}
              />
              <PodiumSlot
                rank={3}
                row={third}
                heightClass="leaderboard-podium-slot--h3"
                toneClass="leaderboard-podium-slot--bronze"
                medal="△"
                isSelf={Boolean(callsign && third?.hunter_name === callsign)}
              />
            </div>
          </div>

          {rest.length > 0 ? (
            <>
              <h2 className="leaderboard-rest-title mono">Rest of the board</h2>
              <ol className="leaderboard leaderboard--full mono">
                {rest.map((row, i) => {
                  const rank = i + 4
                  const isSelf = Boolean(callsign && row.hunter_name === callsign)
                  return (
                    <li
                      key={`${row.hunter_name}-${rank}`}
                      className={isSelf ? 'leaderboard-row--self' : ''}
                    >
                      <span className="rank" aria-label={`Rank ${rank}`}>
                        <span className="leaderboard-rank-num">{rank}</span>
                      </span>
                      <span className="name">{row.hunter_name}</span>
                      <span className="xp">{row.xp.toLocaleString()} XP</span>
                    </li>
                  )
                })}
              </ol>
            </>
          ) : null}

          <p className="muted small leaderboard-page-foot">
            Callsign missing?{' '}
            <Link to="/profile" className="mono accent-strong">
              Set it on Profile
            </Link>
            .
          </p>
        </>
      )}
    </section>
  )
}
