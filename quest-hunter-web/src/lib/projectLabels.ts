/** Human-readable project title for grouped UI; falls back to campaign slug. */
export function getProjectGroupLabel(
  campaignSlug: string,
  rows: { campaign_display_name?: string | null }[],
): { primary: string; secondary: string | null } {
  const name = rows.map((r) => r.campaign_display_name?.trim()).find(Boolean)
  if (name) return { primary: name, secondary: campaignSlug }
  return { primary: campaignSlug, secondary: null }
}
