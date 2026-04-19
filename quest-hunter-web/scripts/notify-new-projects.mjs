/**
 * GitHub Actions cron: notify all push subscribers when a campaign (non-default)
 * has at least one playable published quest and we have not recorded a send yet.
 *
 * Required env: SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY,
 * VAPID_PUBLIC_KEY, VAPID_PRIVATE_KEY, VAPID_SUBJECT (e.g. mailto:ops@yourdomain.com)
 */

import wp from 'web-push'
import { createClient } from '@supabase/supabase-js'

const { setVapidDetails, sendNotification, WebPushError } = wp

function requireEnv(name) {
  const v = process.env[name]
  if (!v?.trim()) {
    console.error(`Missing env: ${name}`)
    process.exit(1)
  }
  return v.trim()
}

function playableQuest(q, nowMs) {
  if (q.archived) return false
  if (!q.is_published) return false
  if (!q.starts_at) return false
  if (new Date(q.starts_at).getTime() > nowMs) return false
  if (q.ends_at && new Date(q.ends_at).getTime() <= nowMs) return false
  const slug = (q.campaign_slug ?? '').trim().toLowerCase()
  if (!slug || slug === 'default') return false
  return true
}

async function main() {
  const url = requireEnv('SUPABASE_URL')
  const serviceKey = requireEnv('SUPABASE_SERVICE_ROLE_KEY')
  const vapidPublic = requireEnv('VAPID_PUBLIC_KEY')
  const vapidPrivate = requireEnv('VAPID_PRIVATE_KEY')
  const subject = process.env.VAPID_SUBJECT?.trim() || 'mailto:support@example.com'

  setVapidDetails(subject, vapidPublic, vapidPrivate)

  const supabase = createClient(url, serviceKey)

  const { data: sentRows, error: sentErr } = await supabase.from('project_push_notifications_sent').select('campaign_slug')
  if (sentErr) throw sentErr
  const sent = new Set((sentRows ?? []).map((r) => r.campaign_slug))

  const { data: quests, error: questsErr } = await supabase
    .from('quests')
    .select('campaign_slug, campaign_display_name, archived, is_published, starts_at, ends_at')

  if (questsErr) throw questsErr

  const nowMs = Date.now()
  /** @type {Map<string, { campaign_slug: string, display_name: string }>} */
  const liveBySlug = new Map()

  for (const q of quests ?? []) {
    if (!playableQuest(q, nowMs)) continue
    const slug = q.campaign_slug
    const label = (q.campaign_display_name ?? '').trim() || slug
    const prev = liveBySlug.get(slug)
    if (!prev || label.length > prev.display_name.length) {
      liveBySlug.set(slug, { campaign_slug: slug, display_name: label })
    }
  }

  const pending = [...liveBySlug.values()].filter((c) => !sent.has(c.campaign_slug))

  if (pending.length === 0) {
    console.log('No new campaigns to announce.')
    return
  }

  const { data: subs, error: subsErr } = await supabase.from('push_subscriptions').select('id, endpoint, p256dh, auth')

  if (subsErr) throw subsErr
  if (!subs?.length) {
    console.log('Pending campaigns:', pending.map((p) => p.campaign_slug).join(', '), '— no subscribers yet.')
    return
  }

  for (const c of pending) {
    const title = 'Nieuw project live'
    const body = `${c.display_name} staat online.`
    const payload = JSON.stringify({
      title,
      body,
      data: { url: '/quests' },
    })

    let anyOk = false
    for (const row of subs) {
      const subscription = {
        endpoint: row.endpoint,
        keys: {
          p256dh: row.p256dh,
          auth: row.auth,
        },
      }
      try {
        await sendNotification(subscription, payload)
        anyOk = true
      } catch (e) {
        const code = e instanceof WebPushError ? e.statusCode : undefined
        if (code === 404 || code === 410) {
          const { error: delErr } = await supabase.from('push_subscriptions').delete().eq('id', row.id)
          if (delErr) console.error('Failed to delete stale subscription', delErr)
        } else {
          console.error('sendNotification failed', e)
        }
      }
    }

    if (!anyOk) {
      console.error(`No successful delivery for ${c.campaign_slug}; not marking sent (will retry).`)
      continue
    }

    const { error: insErr } = await supabase.from('project_push_notifications_sent').insert({
      campaign_slug: c.campaign_slug,
      title,
      body,
    })
    if (insErr) {
      console.error(insErr)
      continue
    }
    console.log(`Announced campaign ${c.campaign_slug}`)
  }
}

main().catch((err) => {
  console.error(err)
  process.exit(1)
})
