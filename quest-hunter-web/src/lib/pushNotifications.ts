import { supabase } from './supabase'

const VAPID_PUBLIC_KEY = import.meta.env.VITE_VAPID_PUBLIC_KEY as string | undefined

export function pushNotificationsConfigured(): boolean {
  return Boolean(VAPID_PUBLIC_KEY?.trim())
}

export function pushNotificationsSupported(): boolean {
  return (
    typeof window !== 'undefined' &&
    'serviceWorker' in navigator &&
    'PushManager' in window &&
    pushNotificationsConfigured()
  )
}

function urlBase64ToUint8Array(base64String: string): Uint8Array {
  const padding = '='.repeat((4 - (base64String.length % 4)) % 4)
  const base64 = (base64String + padding).replace(/-/g, '+').replace(/_/g, '/')
  const rawData = window.atob(base64)
  const outputArray = new Uint8Array(rawData.length)
  for (let i = 0; i < rawData.length; ++i) {
    outputArray[i] = rawData.charCodeAt(i)
  }
  return outputArray
}

export async function hasActivePushSubscription(): Promise<boolean> {
  try {
    const reg = await navigator.serviceWorker.ready
    const sub = await reg.pushManager.getSubscription()
    return sub != null
  } catch {
    return false
  }
}

export async function subscribeToProjectLivePushes(userId: string): Promise<{ ok: boolean; message?: string }> {
  const vapid = VAPID_PUBLIC_KEY?.trim()
  if (!vapid) {
    return { ok: false, message: 'Push is niet geconfigureerd op deze omgeving.' }
  }

  if (!('Notification' in window)) {
    return { ok: false, message: 'Meldingen worden niet ondersteund op dit apparaat.' }
  }

  const permission = await Notification.requestPermission()
  if (permission !== 'granted') {
    return { ok: false, message: 'Meldingen geweigerd. Schakel ze in via de browserinstellingen.' }
  }

  const reg = await navigator.serviceWorker.ready
  const existing = await reg.pushManager.getSubscription()
  const key = urlBase64ToUint8Array(vapid) as BufferSource
  const sub =
    existing ??
    (await reg.pushManager.subscribe({
      userVisibleOnly: true,
      applicationServerKey: key,
    }))

  const json = sub.toJSON()
  const endpoint = json.endpoint
  const keys = json.keys
  if (!endpoint || !keys?.p256dh || !keys?.auth) {
    return { ok: false, message: 'Kon het push-abonnement niet voltooien.' }
  }

  const { error } = await supabase.from('push_subscriptions').upsert(
    {
      user_id: userId,
      endpoint,
      p256dh: keys.p256dh,
      auth: keys.auth,
      user_agent: typeof navigator.userAgent === 'string' ? navigator.userAgent.slice(0, 512) : null,
      updated_at: new Date().toISOString(),
    },
    { onConflict: 'user_id,endpoint' },
  )

  if (error) {
    return { ok: false, message: error.message }
  }
  return { ok: true }
}

export async function unsubscribeFromProjectLivePushes(userId: string): Promise<{ ok: boolean; message?: string }> {
  try {
    const reg = await navigator.serviceWorker.ready
    const sub = await reg.pushManager.getSubscription()
    const endpoint = sub?.endpoint
    if (sub) {
      await sub.unsubscribe()
    }
    if (endpoint) {
      const { error } = await supabase
        .from('push_subscriptions')
        .delete()
        .eq('user_id', userId)
        .eq('endpoint', endpoint)
      if (error) {
        return { ok: false, message: error.message }
      }
    }
    return { ok: true }
  } catch (e) {
    const msg = e instanceof Error ? e.message : String(e)
    return { ok: false, message: msg }
  }
}
