# Quest Hunter — authoring checklist & engine canon

Use this when designing or reviewing quests so they match the **Complete Ruleset** ([`Quest Hunter regels voor de quests zelf.txt`](../../Quest%20Hunter%20regels%20voor%20de%20quests%20zelf.txt)) and the behaviour implemented in this repo.

## Per puzzle (question)

- [ ] **Title / framing** — Short, readable challenge header inside `prompt` (first line or badge text).
- [ ] **Context** — 2–5 lines in `prompt` with subtle steering (not the answer).
- [ ] **Challenge** — Visually separated block (code fence / symbols) where the real puzzle lives.
- [ ] **Input** — `inputType` + `choices` if choice; placeholder expectations clear from copy.
- [ ] **Hints** — Prefer `hints` array with **three** tiers when possible:
  1. Direction (where to look)
  2. Mechanic (what transform applies)
  3. Starting point (first concrete step without giving the token)
- [ ] **Answer** — One normalized token; avoid ambiguity at submit time (interpretation belongs in the puzzle).
- [ ] **Wrong feedback** — Optional `wrongFeedback` per puzzle: near-miss tone (no “wrong”), per fairness rules.
- [ ] **Mechanics** — Note at authoring time: at least **two** mechanic categories from the ruleset per quest (spreadsheet/tags).

## Per quest

- [ ] **Outputs chain** — Early puzzles feed letters/codes/ideas used in a later step or finale.
- [ ] **Slot / lock** — Last puzzle or assembled outputs require interpretation, not only concatenation.
- [ ] **preFinale** (optional) — `body.preFinale.summary` + `implication`: mechanical yield vs narrative meaning before the branch choice.
- [ ] **Finale** — `finalePrompt` bridges to the three branches; each option has trade-offs in copy.
- [ ] **Escalation** — Roughly align difficulty layers with quest index (1–2 → … → 9–10) from the ruleset.

## XP & scoring (engine canon — points, not percentages)

The design doc uses percentages; **the deployed engine uses integer XP** with **equivalent multipliers**:

| Rule (design doc) | Implementation |
|-------------------|----------------|
| Hint tier 1 −5%, 2 −10%, 3 −20% | Per tier multiply base XP by **×0.95, ×0.90, ×0.80** (cumulative product for each tier revealed). |
| Wrong answer −2% stacking | Per wrong attempt on **this puzzle**, multiply award by **×0.98** (stacking). |
| Perfect / no-hint bonus | **+5%** if solve used **no hints** and **no wrong attempts** on that puzzle. |
| Finale path trade-off | Base `xpFinale` (default 75) × **OBSERVE 0.94**, **INFLUENCE 1.00**, **CONTROL 1.06** — higher XP paths skew “hotter”; observe path slightly lower XP (clarity framing). |

Profile XP remains a **single total** (`award_profile_xp`); quests still set per-puzzle `xp` overrides in JSON.

## Hidden axes (campaign hooks)

Each finale choice increments `user_quest_progress.state.hiddenAxes.CONTROL | OBSERVE | INFLUENCE`. Use for future branching/bias in SQL or app — **not shown to players** by default.

## QA (fairness)

- [ ] Solvable **without** hints (hints only accelerate).
- [ ] After a wrong submit, feedback feels **near-miss** (`wrongFeedback` or server default), not arbitrary.
- [ ] Failure should feel like “I missed a step”, not “this is nonsense”.

## Playtest loop

1. Dry-run solution path on paper.
2. One blind tester **without** hints.
3. One run **with** maximal hints to check tier tone (no outright answer in tier 3).
