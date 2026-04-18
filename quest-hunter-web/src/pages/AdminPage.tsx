import { useState } from 'react'
import { AdminAnalyticsPanel } from '../components/admin/AdminAnalyticsPanel'
import { AdminQuestsPanel } from '../components/admin/AdminQuestsPanel'

export function AdminPage() {
  const [tab, setTab] = useState<'quests' | 'analytics'>('quests')

  return (
    <section className="panel admin-page">
      <h1>Admin</h1>
      <p className="muted small">
        Requires <code className="mono">app_metadata.role = &quot;admin&quot;</code> on your user in Supabase (Auth →
        Users → user → App metadata as JSON: <code className="mono">{`{ "role": "admin" }`}</code>
        ).
      </p>

      <div className="tab-row mono admin-tabs">
        <button
          type="button"
          className={tab === 'quests' ? 'tab active' : 'tab'}
          onClick={() => setTab('quests')}
        >
          Quests
        </button>
        <button
          type="button"
          className={tab === 'analytics' ? 'tab active' : 'tab'}
          onClick={() => setTab('analytics')}
        >
          Analytics
        </button>
      </div>

      {tab === 'quests' ? <AdminQuestsPanel /> : <AdminAnalyticsPanel />}
    </section>
  )
}
