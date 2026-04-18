-- PROJECT ORACLE — Quests 5 & 7 (draft) — English-only body text
-- Run after draft_project_oracle_story_arc.sql

insert into public.quests (slug, title, body, is_published, archived)
values
  (
    'oracle-05a-control',
    'PROJECT ORACLE — Quest 5A — CONTROL (draft)',
    $json$
{
  "intro": "Quest 5 — branch: CONTROL.\n\nThree incidents nest in the same clock hour but at different map points. The screen raises `resolve_conflict=true`.\n\nThe risk logbook uses **EXPOSURE** for exposure severity.\n\nFirst minimise the point with the highest **risk_vector** in the legend:\n→ points **A**, **B**, **C** have vectors **3**, **5**, **4** — highest is **B** (value **5**).\n\nLocked accounts often end in a **LOCKOUT**.",
  "puzzles": [
    {
      "id": "q5a-p1",
      "prompt": "PUZZLE 1 — FIELD NAME\n\nWhich English word (10 letters) does the intro name for exposure in risk audits?",
      "hint": "The term is bolded in the intro. Copy the exact word (uppercase).",
      "answer": "EXPOSURE",
      "inputType": "text",
      "xp": 25
    },
    {
      "id": "q5a-p2",
      "prompt": "PUZZLE 2 — TOP RISK\n\nWhich point letter (one uppercase letter) has the highest risk_vector per the legend?",
      "hint": "Compare the three risk_vector numbers in the legend and pick the letter tied to the largest value.",
      "answer": "B",
      "inputType": "text",
      "xp": 25
    },
    {
      "id": "q5a-p3",
      "prompt": "PUZZLE 3 — LOCKOUT\n\nEnglish word for a hard account lock (7 letters).\nAnagram: O C K L O U T",
      "hint": "Use every letter.",
      "answer": "LOCKOUT",
      "inputType": "text",
      "xp": 25
    }
  ],
  "finalePrompt": "You cannot save every point at once. ORACLE asks which you close first.\n\nWhat do you do?",
  "xpFinale": 75
}
$json$::jsonb,
    false,
    false
  ),
  (
    'oracle-05b-observe',
    'PROJECT ORACLE — Quest 5B — OBSERVE (draft)',
    $json$
{
  "intro": "Quest 5 — branch: OBSERVE.\n\nTimeline with fixed cadence across **midnight**:\nIncident **A**: **23:40**\nIncident **B**: **A + 12 min**\nIncident **C**: **B + 18 min**\n\nORACLE defines an observer as someone who does not intervene — your role string is **`OBSERVER`**.",
  "puzzles": [
    {
      "id": "q5b-p1",
      "prompt": "PUZZLE 1 — TIME B\n\nWhat time is incident B (HH:MM)?",
      "hint": "Incident B is defined as incident A plus 12 minutes. Keep HH:MM format.",
      "answer": "23:52",
      "inputType": "text",
      "xp": 25
    },
    {
      "id": "q5b-p2",
      "prompt": "PUZZLE 2 — TIME C\n\nWhat time is incident C per the intro (HH:MM)?",
      "hint": "Incident C is incident B plus 18 minutes. If you pass 23:59, wrap to 00:xx.",
      "answer": "00:10",
      "inputType": "text",
      "xp": 25
    },
    {
      "id": "q5b-p3",
      "prompt": "PUZZLE 3 — ROLE STRING\n\nWhat value does your role string take per the intro (uppercase)?",
      "hint": "The role string is written literally in backticks in the intro. Enter that exact value in uppercase.",
      "answer": "OBSERVER",
      "inputType": "text",
      "xp": 25
    }
  ],
  "finalePrompt": "You plotted the cadence. ORACLE asks whether you publish it or keep it hidden.\n\nYour choice?",
  "xpFinale": 75
}
$json$::jsonb,
    false,
    false
  ),
  (
    'oracle-05c-influence',
    'PROJECT ORACLE — Quest 5C — INFLUENCE (draft)',
    $json$
{
  "intro": "Quest 5 — branch: INFLUENCE.\n\nYou shift one log by **+9 min**. Then two logs match exactly.\n\nYou call that an **ECHO** — the **SCRIPT** stays the same; only your shift repeats as a signature.\n\nTo prove it you also note **ECHO** under ROT13 → **RPUB** (decode check).\n\nShift-chain start in this dossier: **23:52**. **+9 minutes** ⇒ **24:01** ⇒ write as **00:01**.",
  "puzzles": [
    {
      "id": "q5c-p1",
      "prompt": "PUZZLE 1 — ROT13\n\nDecode RPUB to the real keyword (uppercase).",
      "hint": "Use ROT13 (A↔N, B↔O, …). Apply it to each letter of RPUB to recover the keyword.",
      "answer": "ECHO",
      "inputType": "text",
      "xp": 25
    },
    {
      "id": "q5c-p2",
      "prompt": "PUZZLE 2 — TIME\n\nPer intro: start 23:52, then +9 minutes — answer HH:MM.",
      "hint": "Add 9 minutes to 23:52. If minutes exceed 59, carry to the next hour (and wrap past 23:59 to 00:xx).",
      "answer": "00:01",
      "inputType": "text",
      "xp": 25
    },
    {
      "id": "q5c-p3",
      "prompt": "PUZZLE 3 — SCRIPT\n\nWhich English word (6 letters) names the fixed pattern software follows?",
      "hint": "Two identical logs share the same _____.",
      "answer": "SCRIPT",
      "inputType": "text",
      "xp": 25
    }
  ],
  "finalePrompt": "Echo or mirror — ORACLE asks what you do with that knowledge.\n\nWhat do you do?",
  "xpFinale": 75
}
$json$::jsonb,
    false,
    false
  ),
  (
    'oracle-07a-control',
    'PROJECT ORACLE — Quest 7A — CONTROL (draft)',
    $json$
{
  "intro": "Quest 7 — branch: CONTROL.\n\nYou force:\n```\nprediction_source = internal\n```\nThe separator in dumps is **`|`** (ASCII name **PIPE**).\n\nThen you apply a **LOCK** to this branch.",
  "puzzles": [
    {
      "id": "q7a-p1",
      "prompt": "PUZZLE 1 — SOURCE\n\nWhat value sits right of `=` in the code block?",
      "hint": "Read the code block: it’s a key/value assignment. Take the value to the right of the equals sign.",
      "answer": "INTERNAL",
      "inputType": "text",
      "xp": 25
    },
    {
      "id": "q7a-p2",
      "prompt": "PUZZLE 2 — PIPE\n\nWhich English word (4 letters) names the `|` character?",
      "hint": "ASCII name.",
      "answer": "PIPE",
      "inputType": "text",
      "xp": 25
    },
    {
      "id": "q7a-p3",
      "prompt": "PUZZLE 3 — LOCK\n\nWhich English word (4 letters) names locking?",
      "hint": "Last sentence.",
      "answer": "LOCK",
      "inputType": "text",
      "xp": 25
    }
  ],
  "finalePrompt": "Source clamped — but your role remains. ORACLE asks your next bearing.\n\nWhat do you do?",
  "xpFinale": 75
}
$json$::jsonb,
    false,
    false
  ),
  (
    'oracle-07b-observe',
    'PROJECT ORACLE — Quest 7B — OBSERVE (draft)',
    $json$
{
  "intro": "Quest 7 — branch: OBSERVE.\n\nYou compare **forecast** (ahead) with **post-hoc** (after the fact).\n\nAcronym drill: first letters of **Forecast Risk Under Uncertainty** → **FRUU** (attention check only).\n\nIf labels are adjusted after the fact to save a score — is it still **accuracy**?",
  "puzzles": [
    {
      "id": "q7b-p1",
      "prompt": "PUZZLE 1 — PREFIX\n\nWhich English prefix (4 letters) goes with predictive, as in **forecast**?",
      "hint": "Look at the word **forecast** and take its 4-letter prefix (the start of the word).",
      "answer": "FORE",
      "inputType": "text",
      "xp": 25
    },
    {
      "id": "q7b-p2",
      "prompt": "PUZZLE 2 — ETHICS\n\nIf labels are tweaked after the fact to rescue a score — is that still accuracy?\n\nA → yes\nB → no\nC → only on Tuesdays",
      "hint": "Post-hoc tweak.",
      "answer": "B",
      "inputType": "choice",
      "choices": ["A", "B", "C"],
      "xp": 25
    },
    {
      "id": "q7b-p3",
      "prompt": "PUZZLE 3 — ACRONYM\n\nFirst letters of Forecast Risk Under Uncertainty — give the 4-letter token (uppercase).",
      "hint": "Take the first letter of each word in the phrase, in order, then write them together in uppercase.",
      "answer": "FRUU",
      "inputType": "text",
      "xp": 25
    }
  ],
  "finalePrompt": "You named the measurement problem. ORACLE offers no excuse — only a new branch.\n\nWhat do you do?",
  "xpFinale": 75
}
$json$::jsonb,
    false,
    false
  ),
  (
    'oracle-07c-influence',
    'PROJECT ORACLE — Quest 7C — INFLUENCE (draft)',
    $json$
{
  "intro": "Quest 7 — branch: INFLUENCE.\n\nYou simulate **external** behaviour while staying internal — an **OVERLAY** on your logs.\n\nIt is a **NESTED** experiment: a test inside a test.",
  "puzzles": [
    {
      "id": "q7c-p1",
      "prompt": "PUZZLE 1 — MASK\n\nWhich English word (7 letters) names the masking layer?",
      "hint": "First bold word.",
      "answer": "OVERLAY",
      "inputType": "text",
      "xp": 25
    },
    {
      "id": "q7c-p2",
      "prompt": "PUZZLE 2 — SIMULATION\n\nWill you simulate external while staying internal?\n\nA → yes\nB → no",
      "hint": "This branch is about actively shaping the system. Pick the option that matches taking action.",
      "answer": "A",
      "inputType": "choice",
      "choices": ["A", "B"],
      "xp": 25
    },
    {
      "id": "q7c-p3",
      "prompt": "PUZZLE 3 — STRUCTURE\n\nWhich English word (6 letters) means nested per the intro?",
      "hint": "Second bold word.",
      "answer": "NESTED",
      "inputType": "text",
      "xp": 25
    }
  ],
  "finalePrompt": "Second layer added. ORACLE now also measures your simulation depth.\n\nWhat do you do?",
  "xpFinale": 75
}
$json$::jsonb,
    false,
    false
  )
on conflict (slug) do update
set
  title = excluded.title,
  body = excluded.body,
  is_published = excluded.is_published,
  archived = excluded.archived,
  updated_at = now();
