/// <reference lib="webworker" />

import { createHandlerBoundToURL, precacheAndRoute } from 'workbox-precaching'
import { NavigationRoute, registerRoute } from 'workbox-routing'
import type { PrecacheEntry } from 'workbox-precaching'

interface QhServiceWorkerGlobalScope extends ServiceWorkerGlobalScope {
  __WB_MANIFEST: Array<string | PrecacheEntry>
}

declare const self: QhServiceWorkerGlobalScope

precacheAndRoute(self.__WB_MANIFEST)

const handler = createHandlerBoundToURL('/index.html')
registerRoute(new NavigationRoute(handler))

type PushPayload = {
  title?: string
  body?: string
  data?: { url?: string }
}

self.addEventListener('push', (event: PushEvent) => {
  const fallback: PushPayload = {
    title: 'Quest Hunter',
    body: 'Er is nieuwe content beschikbaar.',
    data: { url: '/' },
  }
  let payload: PushPayload = fallback
  try {
    const raw = event.data?.text()
    if (raw) {
      const parsed = JSON.parse(raw) as PushPayload
      payload = {
        title: parsed.title ?? fallback.title,
        body: parsed.body ?? fallback.body,
        data: parsed.data ?? fallback.data,
      }
    }
  } catch {
    payload = fallback
  }

  event.waitUntil(
    self.registration.showNotification(payload.title ?? 'Quest Hunter', {
      body: payload.body,
      icon: '/favicon.svg',
      badge: '/favicon.svg',
      tag: 'quest-hunter-project',
      data: payload.data ?? { url: '/' },
    }),
  )
})

self.addEventListener('notificationclick', (event: NotificationEvent) => {
  event.notification.close()
  const raw = event.notification.data as { url?: string } | undefined
  const path = typeof raw?.url === 'string' ? raw.url : '/quests'
  const targetUrl = new URL(path, self.location.origin).href

  event.waitUntil(
    (async () => {
      const allClients = await self.clients.matchAll({ type: 'window', includeUncontrolled: true })
      for (const client of allClients) {
        const w = client as WindowClient
        if (typeof w.navigate === 'function') {
          await w.navigate(targetUrl)
          await w.focus()
          return
        }
      }
      await self.clients.openWindow(targetUrl)
    })(),
  )
})
