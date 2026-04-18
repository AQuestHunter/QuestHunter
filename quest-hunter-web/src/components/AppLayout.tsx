import { useEffect, useState } from 'react'
import { NavLink, Outlet, useLocation } from 'react-router-dom'
import { useAuth } from '../contexts/AuthContext'

export function AppLayout() {
  const { signOut, isAdmin, profile, user } = useAuth()
  const location = useLocation()
  const [menuOpen, setMenuOpen] = useState(false)

  const displayName =
    profile?.hunter_name?.trim() ||
    (typeof user?.user_metadata?.display_name === 'string' ? user.user_metadata.display_name.trim() : '') ||
    ''

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

  const closeMenu = () => setMenuOpen(false)

  const navClass = ({ isActive }: { isActive: boolean }) =>
    isActive ? 'mono nav-sheet-link nav-sheet-link--active' : 'mono nav-sheet-link'

  const navDesktopClass = ({ isActive }: { isActive: boolean }) =>
    isActive ? 'mono active' : 'mono'

  return (
    <div className="shell">
      <header className="top-bar">
        <NavLink to="/quests" className="brand mono" onClick={closeMenu}>
          QUEST HUNTER
        </NavLink>

        <nav className="nav-links nav-links--desktop mono" aria-label="Main">
          <NavLink to="/quests" end className={navDesktopClass}>
            Quests
          </NavLink>
          <NavLink to="/profile" className={navDesktopClass}>
            Profile
          </NavLink>
          {isAdmin ? (
            <NavLink to="/admin" className={navDesktopClass}>
              Admin
            </NavLink>
          ) : null}
        </nav>

        <div className="top-bar-actions top-bar-actions--desktop">
          <span className="top-bar-display mono" title={displayName || user?.email || ''}>
            {displayName || '—'}
          </span>
          <button type="button" className="ghost-btn mono" onClick={() => void signOut()}>
            Sign out
          </button>
        </div>

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
