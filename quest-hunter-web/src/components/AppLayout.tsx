import { NavLink, Outlet } from 'react-router-dom'
import { useAuth } from '../contexts/AuthContext'

export function AppLayout() {
  const { signOut, isAdmin } = useAuth()

  return (
    <div className="shell">
      <header className="top-bar">
        <NavLink to="/quests" className="brand mono">
          QUEST HUNTER
        </NavLink>
        <nav className="nav-links mono">
          <NavLink to="/quests" end>
            Quests
          </NavLink>
          <NavLink to="/profile">Profile</NavLink>
          {isAdmin ? (
            <NavLink to="/admin">Admin</NavLink>
          ) : null}
        </nav>
        <button type="button" className="ghost-btn mono" onClick={() => void signOut()}>
          Sign out
        </button>
      </header>
      <main className="main-pane">
        <Outlet />
      </main>
    </div>
  )
}
