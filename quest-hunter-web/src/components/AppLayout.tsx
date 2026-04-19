import { useEffect, useState } from 'react'
import { NavLink, Outlet, useLocation } from 'react-router-dom'
import { useAuth } from '../contexts/AuthContext'

export function AppLayout() {
  const { signOut, isAdmin, profile, user } = useAuth()
  const location = useLocation()
  const [menuOpen, setMenuOpen] = useState(false)
  const [theme, setTheme] = useState<'dark' | 'dim'>(() => {
    if (typeof window === 'undefined') return 'dark'
    return window.localStorage.getItem('qh-theme') === 'dim' ? 'dim' : 'dark'
  })

  const displayName =
    profile?.hunter_name?.trim() ||
    (typeof user?.user_metadata?.display_name === 'string' ? user.user_metadata.display_name.trim() : '') ||
    ''
  const navInitial = (displayName || user?.email || '?')
    .trim()
    .slice(0, 1)
    .toUpperCase()

  useEffect(() => {
    setMenuOpen(false)
  }, [location.pathname])

  useEffect(() => {
    if (!menuOpen) return
    const prev = document.body.style.overflow
    document.body.style.overflow = 'hidden'
    return () => {
      document.body.style.overflow = prev
    }
  }, [menuOpen])

  useEffect(() => {
    document.documentElement.setAttribute('data-ui-theme', theme)
    window.localStorage.setItem('qh-theme', theme)
  }, [theme])

  const closeMenu = () => setMenuOpen(false)

  const navClass = ({ isActive }: { isActive: boolean }) =>
    isActive ? 'mono nav-sheet-link nav-sheet-link--active' : 'mono nav-sheet-link'

  return (
    <div className="shell">
      <header className="top-bar">
        <NavLink to="/quests" className="brand mono" onClick={closeMenu}>
          QUEST HUNTER
        </NavLink>
        <span className="top-avatar mono" aria-hidden>
          {navInitial}
        </span>
        <button
          type="button"
          className="ghost-btn mono small top-theme-btn"
          onClick={() => setTheme((prev) => (prev === 'dark' ? 'dim' : 'dark'))}
          aria-label="Toggle interface theme"
        >
          {theme === 'dark' ? 'Dim' : 'Dark'}
        </button>

        <button
          type="button"
          className="nav-menu-btn mono"
          aria-expanded={menuOpen}
          aria-controls="mobile-nav"
          onClick={() => setMenuOpen((o) => !o)}
        >
          <span className="sr-only">{menuOpen ? 'Close menu' : 'Open menu'}</span>
          <span className="nav-menu-icon" aria-hidden>
            <span />
            <span />
            <span />
          </span>
        </button>
      </header>

      {menuOpen ? (
        <>
          <div
            className="nav-backdrop"
            aria-hidden
            onClick={closeMenu}
          />
          <aside id="mobile-nav" className="nav-sheet" aria-label="Main navigation">
            <nav className="nav-sheet-inner mono">
              <NavLink to="/quests" end className={navClass} onClick={closeMenu}>
                Quests
              </NavLink>
              <NavLink to="/leaderboard" className={navClass} onClick={closeMenu}>
                Leaderboard
              </NavLink>
              <NavLink to="/profile" className={navClass} onClick={closeMenu}>
                Profile
              </NavLink>
              {isAdmin ? (
                <NavLink to="/admin" className={navClass} onClick={closeMenu}>
                  Admin
                </NavLink>
              ) : null}
            </nav>
            <div className="nav-sheet-footer">
              <p className="nav-sheet-user mono muted small">{displayName || user?.email || '—'}</p>
              <button type="button" className="ghost-btn mono nav-sheet-signout" onClick={() => void signOut()}>
                Sign out
              </button>
            </div>
          </aside>
        </>
      ) : null}

      <main className="main-pane">
        <Outlet />
      </main>
    </div>
  )
}
