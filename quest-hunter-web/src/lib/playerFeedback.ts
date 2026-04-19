/** Light haptics when supported; skips when user prefers reduced motion. Never stores gameplay state. */

function prefersReducedMotion(): boolean {
  if (typeof window === 'undefined' || !window.matchMedia) return false
  return window.matchMedia('(prefers-reduced-motion: reduce)').matches
}

export function pulseCorrect(): void {
  if (prefersReducedMotion() || typeof navigator === 'undefined' || !navigator.vibrate) return
  try {
    navigator.vibrate([12, 35, 18])
  } catch {
    /* ignore */
  }
}

export function pulseWrong(): void {
  if (prefersReducedMotion() || typeof navigator === 'undefined' || !navigator.vibrate) return
  try {
    navigator.vibrate([45, 28, 45])
  } catch {
    /* ignore */
  }
}
