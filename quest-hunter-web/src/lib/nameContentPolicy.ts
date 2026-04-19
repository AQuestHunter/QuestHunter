/** Block the substring "draft" in player-facing quest/project names (any case). */
export function nameContainsForbiddenDraftSubstring(name: string): boolean {
  return name.toLowerCase().includes('draft')
}
