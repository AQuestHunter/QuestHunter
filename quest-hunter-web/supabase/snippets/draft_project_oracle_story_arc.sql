-- PROJECT ORACLE — full story arc (drafts). English-only body text.
-- Order: Q1 leak → Q2–4 multiple incidents → Q5–7 doubt → Q8–10 experiment reveal.
-- Run after draft_project_oracle_quests.sql. ON CONFLICT replaces title/body.

insert into public.quests (slug, title, body, is_published, archived)
values
  (
    'oracle-02a-control',
    'PROJECT ORACLE — Quest 2A — CONTROL',
    $json$
{
  "intro": "Quest 2 — branch: CONTROL.\n\nYou keep intervening. ORACLE opens a second channel: your leak is mirrored to a buffer node.\n\nSync header (hex dump, each pair = one ASCII byte):\n`4F 52 41 43 4C 45`\n—that spells the six-letter kernel label in ASCII.\n\nBuffer rule: **ANCHOR_TIME = LEAK_TIME + 20 min** with LEAK_TIME = 23:40 (Quest 1). Record midnight as **00:00**.\n\nYour route name for this segment is literally your branch choice — here as the word for active steering.",
  "puzzles": [
    {
      "id": "q2a-p1",
      "prompt": "PUZZLE 1 — HEX → ASCII\n\nDecode the six header bytes (4F 52 41 43 4C 45) into the English kernel label (uppercase).",
      "hint": "Each pair is a hex byte → ASCII uppercase letter. Quick check: hex 4F corresponds to 'O'. Convert all six, then read as one word.",
      "answer": "ORACLE",
      "inputType": "text",
      "xp": 25
    },
    {
      "id": "q2a-p2",
      "prompt": "PUZZLE 2 — ANCHOR\n\nPer ANCHOR_TIME = LEAK_TIME + 20 min with LEAK_TIME = 23:40. What is ANCHOR_TIME (HH:MM)?",
      "hint": "Add 20 minutes to 23:40. If minutes exceed 59, carry to the hour; midnight is 00:00.",
      "answer": "00:00",
      "inputType": "text",
      "xp": 25
    },
    {
      "id": "q2a-p3",
      "prompt": "PUZZLE 3 — ROUTE\n\nWhich English word (7 letters) names your branch here — active steering / intervention?\n\nLetters (anagram): C O N T R O L",
      "hint": "Permute into one word.",
      "answer": "CONTROL",
      "inputType": "text",
      "xp": 25
    }
  ],
  "finalePrompt": "You named the mirror channel: the system copies your observation into a buffer and asks again — push harder or break the pattern.\n\nWhat is your next bearing?",
  "xpFinale": 75
}
$json$::jsonb,
    false,
    false
  ),
  (
    'oracle-02b-observe',
    'PROJECT ORACLE — Quest 2B — OBSERVE',
    $json$
{
  "intro": "Quest 2 — branch: OBSERVE.\n\nYou do not intervene — so you see double logging.\n\nPattern note (ORACLE internals): the ‘observer offset’ follows the Fibonacci sequence starting 1, 1 — i.e. 1, 1, 2, 3, 5, …\n\nThe dossier uses **variant** when the header matches but the footer differs.",
  "puzzles": [
    {
      "id": "q2b-p1",
      "prompt": "PUZZLE 1 — MATCH THE LEAK\n\nWhich row matches Quest 1 exactly (LENA / PARK / 23:40)?\n\nA → 23:40 – PARK – LENA\nB → 23:45 – PARK – LENA\nC → 23:40 – STATION – LENA",
      "hint": "Use the canon triplet you extracted in Quest 1 (name / zone / time). Only one row matches all three fields exactly.",
      "answer": "A",
      "inputType": "choice",
      "choices": ["A", "B", "C"],
      "xp": 25
    },
    {
      "id": "q2b-p2",
      "prompt": "PUZZLE 2 — FIBONACCI\n\nPer the pattern in the intro: 1, 1, 2, 3, 5, __\n\nFill in the next number.",
      "hint": "Each term is the sum of the previous two.",
      "answer": "8",
      "inputType": "text",
      "xp": 25
    },
    {
      "id": "q2b-p3",
      "prompt": "PUZZLE 3 — VARIANT\n\nWhich English word (7 letters) does the intro use for ‘same header, different footer’?\n\nAnagram: V E R S I O N",
      "hint": "Permute all letters.",
      "answer": "VERSION",
      "inputType": "text",
      "xp": 25
    }
  ],
  "finalePrompt": "You see ORACLE lay variants side by side without merging them. Your job is observation — but the system still asks for a bearing on the next segment.\n\nWhat do you do?",
  "xpFinale": 75
}
$json$::jsonb,
    false,
    false
  ),
  (
    'oracle-02c-influence',
    'PROJECT ORACLE — Quest 2C — INFLUENCE',
    $json$
{
  "intro": "Quest 2 — branch: INFLUENCE.\n\nYou use the leak as leverage.\n\nInternal schema (shown in your panel):\nINPUT → PROCESS → OUTPUT\n\nYou inject **NOISE** on the channel. To time impact: start **14:20**, add **50** minutes for the first measurement point.",
  "puzzles": [
    {
      "id": "q2c-p1",
      "prompt": "PUZZLE 1 — SCHEMA\n\nWhich word is missing between INPUT and OUTPUT in the intro schema (English, 7 letters)?",
      "hint": "The schema is written explicitly in the intro as three words with arrows. The missing middle word is the one between INPUT and OUTPUT.",
      "answer": "PROCESS",
      "inputType": "text",
      "xp": 25
    },
    {
      "id": "q2c-p2",
      "prompt": "PUZZLE 2 — TIME\n\nPer the intro: start 14:20, +50 minutes. Answer HH:MM.",
      "hint": "Add 50 minutes to 14:20. If you pass :59, carry into the next hour.",
      "answer": "15:10",
      "inputType": "text",
      "xp": 25
    },
    {
      "id": "q2c-p3",
      "prompt": "PUZZLE 3 — INJECTION\n\nWhich English word (5 letters) does the intro name for what you put on the channel?\n\nAnagram check: E O I S N",
      "hint": "Not signal — …",
      "answer": "NOISE",
      "inputType": "text",
      "xp": 25
    }
  ],
  "finalePrompt": "You showed the dataset mirrors your input. ORACLE recalibrates — and asks what you do with that mirror.\n\nNext move?",
  "xpFinale": 75
}
$json$::jsonb,
    false,
    false
  ),
  (
    'oracle-04a-control',
    'PROJECT ORACLE — Quest 4A — CONTROL',
    $json$
{
  "intro": "Quest 4 — branch: CONTROL.\n\nThree case files:\n• **23:40-PARK-LENA** — canon from Quest 1\n• **23:40-STATION-MARCO** — shifted location/id\n• **00:10-NODE-EMPTY** — empty node\n\nLocation labels in this set: PARK, STATION, NODE — each appears once.\n\nTo seize a stream ORACLE uses the CLI word SQL uses to delete rows — here meaning **hard override** of an active session.",
  "puzzles": [
    {
      "id": "q4a-p1",
      "prompt": "PUZZLE 1 — PRIORITY\n\nWhich dossier-id matches the original leak (Quest 1 canon)?\n\nA → 23:40-PARK-LENA\nB → 23:40-STATION-MARCO\nC → 00:10-NODE-EMPTY",
      "hint": "Match the canon triplet from Quest 1: same person, same place, same time.",
      "answer": "A",
      "inputType": "choice",
      "choices": ["A", "B", "C"],
      "xp": 25
    },
    {
      "id": "q4a-p2",
      "prompt": "PUZZLE 2 — SET\n\nHow many distinct location labels does the intro list in ‘PARK, STATION, NODE’?",
      "hint": "Count unique names in that list.",
      "answer": "3",
      "inputType": "text",
      "xp": 25
    },
    {
      "id": "q4a-p3",
      "prompt": "PUZZLE 3 — OVERRIDE\n\nWhich English word (8 letters) from **O V E R R I D E** describes hard overruling?",
      "hint": "Use every letter once.",
      "answer": "OVERRIDE",
      "inputType": "text",
      "xp": 25
    }
  ],
  "finalePrompt": "You cannot stop everything at once — only prioritize. ORACLE asks which incident you pull down first.\n\nWhat do you do?",
  "xpFinale": 75
}
$json$::jsonb,
    false,
    false
  ),
  (
    'oracle-04b-observe',
    'PROJECT ORACLE — Quest 4B — OBSERVE',
    $json$
{
  "intro": "Quest 4 — branch: OBSERVE.\n\nYou correlate three dossiers that share the same **header scaffold**.\n\nGrid (orientation only — letters repeat):\n\n```\nL E A K\nL E A K\nL E ?\n```\n\nRow 3 completes the same word as rows 1–2: **LEAK** stays the anchor word.\n\nFor sampling ORACLE often uses a **sample** — a subset of the population.",
  "puzzles": [
    {
      "id": "q4b-p1",
      "prompt": "PUZZLE 1 — INTRO\n\nWhich option best matches the first sentence of this quest?\n\nA → ORACLE logs your scroll direction\nB → You correlate three dossiers with the same header scaffold\nC → Your task is not picking who is right",
      "hint": "First sentence of the intro.",
      "answer": "B",
      "inputType": "choice",
      "choices": ["A", "B", "C"],
      "xp": 25
    },
    {
      "id": "q4b-p2",
      "prompt": "PUZZLE 2 — GRID\n\nThe grid finishes the same word as rows 1–2. Which letter is missing at row 3, column 3?",
      "hint": "Rows 1–2 spell the same 4-letter word. Row 3 is the start of that same word. Identify the missing character by position (row 3, col 3).",
      "answer": "K",
      "inputType": "text",
      "xp": 25
    },
    {
      "id": "q4b-p3",
      "prompt": "PUZZLE 3 — STATISTICS\n\nEnglish for ‘sample / subset’ (6 letters). Anagram: S A M P L E",
      "hint": "Use all letters.",
      "answer": "SAMPLE",
      "inputType": "text",
      "xp": 25
    }
  ],
  "finalePrompt": "You see repeating structure without a named cause. ORACLE asks: keep cataloguing the pattern or change your stance?\n\nYour choice?",
  "xpFinale": 75
}
$json$::jsonb,
    false,
    false
  ),
  (
    'oracle-04c-influence',
    'PROJECT ORACLE — Quest 4C — INFLUENCE',
    $json$
{
  "intro": "Quest 4 — branch: INFLUENCE.\n\nYou feed the network mini-leaks. ORACLE rescales **weights**: each class gets a coefficient.\n\nBinary integrity check on the smallest field:\nregister `0101` — **flip only the LSB** (last bit) for parity.\n\nWhen output returns into the model you close a **feedback** loop.",
  "puzzles": [
    {
      "id": "q4c-p1",
      "prompt": "PUZZLE 1 — WEIGHT\n\nWhich English word (7 letters) does the intro use for ‘how heavy a class counts’ in the score?\n\nLetters: W E I G H T",
      "hint": "Mass in optimization parlance.",
      "answer": "WEIGHT",
      "inputType": "text",
      "xp": 25
    },
    {
      "id": "q4c-p2",
      "prompt": "PUZZLE 2 — BITFLIP\n\nRegister 0101 — flip only the last bit (LSB). Give the new 4-bit pattern.",
      "hint": "LSB = last bit. Flip means 0↔1, leaving the first three bits unchanged.",
      "answer": "0100",
      "inputType": "text",
      "xp": 25
    },
    {
      "id": "q4c-p3",
      "prompt": "PUZZLE 3 — LOOP\n\nWhich English word (8 letters) names ‘output that becomes input again’?\n\nLetters: F E E D B A C K",
      "hint": "No permutation needed.",
      "answer": "FEEDBACK",
      "inputType": "text",
      "xp": 25
    }
  ],
  "finalePrompt": "You made the model oscillate. ORACLE stabilizes — and asks your next lever.\n\nWhat do you do?",
  "xpFinale": 75
}
$json$::jsonb,
    false,
    false
  ),
  (
    'oracle-06a-control',
    'PROJECT ORACLE — Quest 6A — CONTROL',
    $json$
{
  "intro": "Quest 6 — branch: CONTROL.\n\nInternal timer dump:\n```\npredicted_by=OBSERVER\nticks: T0=00:00, step=+7 min\n```\n\nEach tick adds **7 minutes**. **Interrupt** on vector **ABORT** stops the timer hard.\n\nIf you act before the tick — do you measure causality or yourself?",
  "puzzles": [
    {
      "id": "q6a-p1",
      "prompt": "PUZZLE 1 — LOG FIELD\n\nWhat value sits right of `predicted_by=` in the dump (uppercase)?",
      "hint": "Literal from the intro.",
      "answer": "OBSERVER",
      "inputType": "text",
      "xp": 25
    },
    {
      "id": "q6a-p2",
      "prompt": "PUZZLE 2 — TIMER\n\nStart T0=00:00, each step +7 min. Series: 00:00, 00:07, 00:14, ?\n\nGive the fourth timestamp (HH:MM).",
      "hint": "Add another 7 minutes to the previous timestamp (keep the same HH:MM format).",
      "answer": "00:21",
      "inputType": "text",
      "xp": 25
    },
    {
      "id": "q6a-p3",
      "prompt": "PUZZLE 3 — VECTOR\n\nWhich English command word (5 letters) names a hard stop?\n\nAnagram: A B O R T",
      "hint": "Use every letter.",
      "answer": "ABORT",
      "inputType": "text",
      "xp": 25
    }
  ],
  "finalePrompt": "You cannot prove causality — only break the timer. ORACLE asks: keep breaking or switch tactics?\n\nYour branch?",
  "xpFinale": 75
}
$json$::jsonb,
    false,
    false
  ),
  (
    'oracle-06b-observe',
    'PROJECT ORACLE — Quest 6B — OBSERVE',
    $json$
{
  "intro": "Quest 6 — branch: OBSERVE.\n\nTag logged after you look:\n`observer_effect=true`\n\nIf the system measures your **decisions** instead of only the outside world, the experiment is reflexive.\n\nPROJECT ORACLE chiefly measures **reactions** to incomplete information — plural noun from the manifest.",
  "puzzles": [
    {
      "id": "q6b-p1",
      "prompt": "PUZZLE 1 — BOOLEAN\n\nWhat value does `observer_effect` take per the intro?\n\nA → true\nB → false\nC → null",
      "hint": "Literal from the tag line.",
      "answer": "A",
      "inputType": "choice",
      "choices": ["A", "B", "C"],
      "xp": 25
    },
    {
      "id": "q6b-p2",
      "prompt": "PUZZLE 2 — REFLEXIVITY\n\nWhich word in the second paragraph names what ORACLE measures when it does not only see the world?\n\nA → external risks\nB → decisions\nC → weather data",
      "hint": "‘Your …’ in the intro.",
      "answer": "B",
      "inputType": "choice",
      "choices": ["A", "B", "C"],
      "xp": 25
    },
    {
      "id": "q6b-p3",
      "prompt": "PUZZLE 3 — MANIFEST\n\nEnglish plural (9 letters) for what ORACLE chiefly measures — anagram R E A C T I O N S",
      "hint": "Use every letter.",
      "answer": "REACTIONS",
      "inputType": "text",
      "xp": 25
    }
  ],
  "finalePrompt": "You named the paradox. ORACLE gives no answer — only a new branch.\n\nWhat do you do?",
  "xpFinale": 75
}
$json$::jsonb,
    false,
    false
  ),
  (
    'oracle-06c-influence',
    'PROJECT ORACLE — Quest 6C — INFLUENCE',
    $json$
{
  "intro": "Quest 6 — branch: INFLUENCE.\n\nYou force a different **top-1**: classes {A,B,C}. After injection **B** wins.\n\nTraining uses a **gradient** — update vector.\n\nIf manipulation fails ORACLE raises **loss** in the log.",
  "puzzles": [
    {
      "id": "q6c-p1",
      "prompt": "PUZZLE 1 — TOP-1\n\nAfter your injection class B wins. Which single letter is the new top-1?",
      "hint": "Read the intro.",
      "answer": "B",
      "inputType": "text",
      "xp": 25
    },
    {
      "id": "q6c-p2",
      "prompt": "PUZZLE 2 — OPTIMIZATION\n\nWhich English word (9 letters) names the update vector in training?\n\nLetters: G R A D I E N T",
      "hint": "Exactly as written.",
      "answer": "GRADIENT",
      "inputType": "text",
      "xp": 25
    },
    {
      "id": "q6c-p3",
      "prompt": "PUZZLE 3 — COST\n\nWhich English word (4 letters) names the penalty term on failure?\n\nAnagram: L O S S",
      "hint": "Base form.",
      "answer": "LOSS",
      "inputType": "text",
      "xp": 25
    }
  ],
  "finalePrompt": "You forced the model — and exposed yourself as input. ORACLE asks what you do with that exposure.\n\nNext move?",
  "xpFinale": 75
}
$json$::jsonb,
    false,
    false
  ),
  (
    'oracle-08a-control',
    'PROJECT ORACLE — Quest 8A — CONTROL',
    $json$
{
  "intro": "Quest 8 — branch: CONTROL.\n\nExport list: your operator id sits under column **`subject_pool`** — not a field console but a **randomisation block**.\n\nTo wipe a row root uses the CLI word **DELETE** (as in SQL).\n\nSubjects who do not know they are in a trial are often called **blind** in the protocol.",
  "puzzles": [
    {
      "id": "q8a-p1",
      "prompt": "PUZZLE 1 — COLUMN\n\nWhich column name (exact, with underscore) does the intro give for where your id sits?",
      "hint": "Backticks in the intro.",
      "answer": "SUBJECT_POOL",
      "inputType": "text",
      "xp": 25
    },
    {
      "id": "q8a-p2",
      "prompt": "PUZZLE 2 — SQL\n\nWhich English command (6 letters) does the intro name for deleting a row?\n\nAnagram: E E T L E D",
      "hint": "SQL DELETE.",
      "answer": "DELETE",
      "inputType": "text",
      "xp": 25
    },
    {
      "id": "q8a-p3",
      "prompt": "PUZZLE 3 — PROTOCOL\n\nWhich English word (5 letters) names subjects without allocation insight?",
      "hint": "Last sentence of the intro.",
      "answer": "BLIND",
      "inputType": "text",
      "xp": 25
    }
  ],
  "finalePrompt": "You can try to tear the experiment open — but every DELETE is logged. ORACLE asks your intent.\n\nWhat do you do?",
  "xpFinale": 75
}
$json$::jsonb,
    false,
    false
  ),
  (
    'oracle-08b-observe',
    'PROJECT ORACLE — Quest 8B — OBSERVE',
    $json$
{
  "intro": "Quest 8 — branch: OBSERVE.\n\nMetadata labels in the dossier (all three named):\n**cohort**, **wave**, **replication**\n\n‘Replication’ = repeated measurement / reproducibility.\n\nLetter puzzle: take the **first letters** of those three words in order — a three-letter acronym.\n\nYou are no longer a neutral spectator: you fall under the protocol.",
  "puzzles": [
    {
      "id": "q8b-p1",
      "prompt": "PUZZLE 1 — ACRONYM\n\nFirst letters of **cohort**, **wave**, **replication** (in that order). Give the 3-letter acronym (uppercase).",
      "hint": "Take the first character of each word in order, then write the three letters together (uppercase).",
      "answer": "CWR",
      "inputType": "text",
      "xp": 25
    },
    {
      "id": "q8b-p2",
      "prompt": "PUZZLE 2 — REPLICATION\n\nWhich word from the metadata list means repeated measurement / reproducibility (English, from the intro)?",
      "hint": "One word from the bold list.",
      "answer": "REPLICATION",
      "inputType": "text",
      "xp": 25
    },
    {
      "id": "q8b-p3",
      "prompt": "PUZZLE 3 — POSITION\n\nIf you are a data point in this quest — what are you no longer?\n\nA → a spectator outside the system\nB → a camera\nC → a router",
      "hint": "Last sentence of the intro.",
      "answer": "A",
      "inputType": "choice",
      "choices": ["A", "B", "C"],
      "xp": 25
    }
  ],
  "finalePrompt": "You can archive the protocol — or make it public. ORACLE asks your next bearing.\n\nWhat do you do?",
  "xpFinale": 75
}
$json$::jsonb,
    false,
    false
  ),
  (
    'oracle-08c-influence',
    'PROJECT ORACLE — Quest 8C — INFLUENCE',
    $json$
{
  "intro": "Quest 8 — branch: INFLUENCE.\n\nYou spoof a **cohort** tag. The protocol **checksum** for cohort ids is:\n**sum of ASCII codes of the letters in `COHORT` modulo 100** (A=65 for reference — count only C,O,H,O,R,T).\n\nWhen spoof detection fires ORACLE writes a **penalty**.",
  "puzzles": [
    {
      "id": "q8c-p1",
      "prompt": "PUZZLE 1 — STRING\n\nWhich English word (7 letters) do you try to falsify as a tag per the intro?",
      "hint": "First bold noun after ‘spoof a’.",
      "answer": "COHORT",
      "inputType": "text",
      "xp": 25
    },
    {
      "id": "q8c-p2",
      "prompt": "PUZZLE 2 — CHECKSUM\n\nSum ASCII values for C,O,H,O,R,T (decimal, uppercase) and take **mod 100**.\n\nGive that remainder as an integer.",
      "hint": "Look up ASCII codes for uppercase letters (e.g. A=65). Sum the six letters in COHORT, then take the remainder after dividing by 100.",
      "answer": "49",
      "inputType": "text",
      "xp": 25
    },
    {
      "id": "q8c-p3",
      "prompt": "PUZZLE 3 — SANCTION\n\nWhich English word (7 letters) does ORACLE log on detection?\n\nAnagram: P E N A L T Y",
      "hint": "Use all letters.",
      "answer": "PENALTY",
      "inputType": "text",
      "xp": 25
    }
  ],
  "finalePrompt": "You saw a price on fraudulent input. ORACLE asks: accept that price or switch strategy?\n\nWhat do you do?",
  "xpFinale": 75
}
$json$::jsonb,
    false,
    false
  ),
  (
    'oracle-09-lab',
    'PROJECT ORACLE — Quest 9 — The lab (linear)',
    $json$
{
  "intro": "Quest 9 — interlude.\n\nAll branches exit at the same door. The terminal reads:\n\n`Confirm subject awareness (y/n)`\n\nSecondary line (small type):\n`pipeline_stage = 7 | role = SUBJECT`\n\nYou are no longer outside the experiment — you are the **pipeline**.",
  "puzzles": [
    {
      "id": "q9-p1",
      "prompt": "PUZZLE 1 — CONFIRM\n\nWhich letter may you type to confirm per the terminal prompt (lowercase)?",
      "hint": "(y/n) in the prompt.",
      "answer": "y",
      "inputType": "text",
      "xp": 25
    },
    {
      "id": "q9-p2",
      "prompt": "PUZZLE 2 — STAGE\n\nWhich numeric **pipeline_stage** does the secondary line name?",
      "hint": "`pipeline_stage = ?`",
      "answer": "7",
      "inputType": "text",
      "xp": 25
    },
    {
      "id": "q9-p3",
      "prompt": "PUZZLE 3 — ROLE\n\nWhat value does `role` have on that line (uppercase)?",
      "hint": "After the pipe.",
      "answer": "SUBJECT",
      "inputType": "text",
      "xp": 25
    }
  ],
  "finalePrompt": "You face the last layer: not the story — the acknowledgement.\n\nORACLE only asks which mode you choose for the finale.",
  "xpFinale": 75
}
$json$::jsonb,
    false,
    false
  ),
  (
    'oracle-10-finale',
    'PROJECT ORACLE — Quest 10 — Finale / revelation (linear)',
    $json$
{
  "intro": "Quest 10 — finale.\n\nPROJECT ORACLE is not a prediction engine. It is an instrument measuring **behavior** under uncertainty.\n\nManifest rule (checksum): **ORACLE** → letter positions A=1 … Z=26 → **O(15)+R(18)+A(1)+C(3)+L(12)+E(5) = 54**. Hold that value as **slot code**.\n\nYou are a **replicate** in a wave. Every puzzle yielded **telemetry**.",
  "puzzles": [
    {
      "id": "q10-p1",
      "prompt": "PUZZLE 1 — NAME\n\nWhat is the project called (two words, as in the titles)?",
      "hint": "First sentence.",
      "answer": "PROJECT ORACLE",
      "inputType": "text",
      "xp": 25
    },
    {
      "id": "q10-p2",
      "prompt": "PUZZLE 2 — SLOT CODE\n\nPer the manifest rule: sum letter positions of ORACLE (A=1…Z=26). Give the integer.",
      "hint": "Use A1Z26 letter positions (A=1 … Z=26). Convert each letter in ORACLE to a number, then sum them.",
      "answer": "54",
      "inputType": "text",
      "xp": 25
    },
    {
      "id": "q10-p3",
      "prompt": "PUZZLE 3 — ROLE\n\nPer the intro: are you the hero or a replicate?\n\nA → hero\nB → replicate\nC → router",
      "hint": "Third paragraph.",
      "answer": "B",
      "inputType": "choice",
      "choices": ["A", "B", "C"],
      "xp": 25
    },
    {
      "id": "q10-p4",
      "prompt": "PUZZLE 4 — DATA\n\nWhich English word names what each puzzle produced?",
      "hint": "Last sentence.",
      "answer": "TELEMETRY",
      "inputType": "text",
      "xp": 25
    }
  ],
  "finalePrompt": "You know it now: you co-write the dossier while ORACLE tracks your cursor.\n\nLast bearing — not to beat the system, but to name what you do next with that knowledge.\n\nWhat do you choose?",
  "xpFinale": 100
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
