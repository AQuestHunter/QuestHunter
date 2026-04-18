import type { ReactNode } from 'react'
import { Navigate } from 'react-router-dom'
import { useAuth } from '../contexts/AuthContext'

export function AdminRoute({ children }: { children: ReactNode }) {
  const { loading, session, isAdmin } = useAuth()

  if (loading) {
    return (
      <div className="shell loading-screen">
        <p className="mono muted">verifying clearance …</p>
      </div>
    )
  }

  if (!session) {
    return <Navigate to="/login" replace />
  }

  if (!isAdmin) {
    return <Navigate to="/quests" replace />
  }

  return <>{children}</>
}
