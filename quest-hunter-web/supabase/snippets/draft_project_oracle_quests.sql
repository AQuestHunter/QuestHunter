-- PROJECT ORACLE — draft quests (body text can be NL; puzzle answers stay as validated tokens)
-- Run in Supabase SQL Editor after migrations. Adjust starts_at / ends_at in Admin when going live.

insert into public.quests (slug, title, body, is_published, archived)
values
  (
    'oracle-01-lek',
    'PROJECT ORACLE — Quest 1 — Het lek (draft)',
    $json$
{
  "intro": "PROJECT ORACLE — Hoofdstuk 1 — Het lek\n\nDit is je materiaal: een corrupt incidentfragment uit ORACLE’s buffer — geen aparte tekst erbuiten. Alles wat je nodig hebt staat in het blok hieronder.\n\n---\nINCIDENTNOTE v0.7 | integrity: DEGRADED\nSUBJECT_CODE: 12–5–14–1   (decode: A=1, B=2, … Z=26; lees de parels op volgorde)\nTIMELINE: tick₁ = 23:20   tick₂ = 23:30   tick₃ = ?\nREGEL: Δ tussen opeenvolgende ticks is constant (+10 min ten opzichte van de vorige).\nZONE_TOKEN: herschik **P R A K** tot één woord — een typische openbare groene plek in een stad (Engels, 4 letters).\n---\n\nORACLE lekt precies genoeg om je te laten handelen. Reconstrueer wie (voornaam), wanneer (tick₃), waar (zone). Daarna volgt het volgende segment.",
  "puzzles": [
    {
      "id": "q1-naam",
      "prompt": "PUZZLE 1 — SUBJECT_CODE\n\nDecodeer 12–5–14–1 met A=1 … Z=26. Geef de voornaam als één woord (hoofdletters).",
      "hint": "Gebruik A1Z26: 1=A, 2=B, 3=C … 26=Z. Zet elk getal om naar een letter en lees ze achter elkaar. (Check: 12 = L.)",
      "answer": "LENA",
      "inputType": "text",
      "xp": 25
    },
    {
      "id": "q1-tijd",
      "prompt": "PUZZLE 2 — TIJDLIJN\n\nVolgens de REGEL in het fragment: tick₃ = ? (notatie HH:MM).",
      "hint": "De regel zegt dat het verschil tussen ticks constant is. Kijk naar tick₁→tick₂ en pas hetzelfde verschil toe op tick₂→tick₃.",
      "answer": "23:40",
      "inputType": "text",
      "xp": 25
    },
    {
      "id": "q1-plaats",
      "prompt": "PUZZLE 3 — ZONE_TOKEN\n\nHerschik P R A K tot dat Engelse woord voor een stedelijke groene zone (één woord, hoofdletters).",
      "hint": "Zoek een Engels woord van 4 letters voor een groene plek in de stad. Gebruik alle letters precies één keer.",
      "answer": "PARK",
      "inputType": "text",
      "xp": 25
    }
  ],
  "finalePrompt": "Je zet het lek weer samen:\n→ Persoon: LENA\n→ Plek: PARK\n→ Tijd: 23:40\n\nNog geen ingrijpen — alleen observatie. Het systeem vraagt om een eerste koers voor het volgende segment. Wat doe je?",
  "xpFinale": 75
}
$json$::jsonb,
    false,
    false
  ),
  (
    'oracle-03a-control',
    'PROJECT ORACLE — Quest 3A — CONTROL (draft)',
    $json$
{
  "intro": "Quest 3A — CONTROL — mirror buffer.\n\nYou try to stop the first incident. The buffer mirrors your dossier with a different encoding.\n\n---\nBUFFER excerpt (ARC-7):\nPRIMARY_ID rot13: **ZNEPB**\nANCHOR_STRING anagram (7 letters, use every letter once): **NITASOT**\nCLOCK: 23:40 → 23:50 → 00:00 → ?  (+10 min each step; midnight is 00:00)\n---\n\nIf ORACLE only shifts what you try to break — what remains?",
  "puzzles": [
    {
      "id": "q3a-p1",
      "prompt": "PUZZLE 1 — ROT13\n\nDecode PRIMARY_ID from the buffer excerpt (ROT13). Give only the first name (uppercase).",
      "hint": "ROT13: rotate each letter by 13 (A↔N, B↔O, …).",
      "answer": "MARCO",
      "inputType": "text",
      "xp": 25
    },
    {
      "id": "q3a-p2",
      "prompt": "PUZZLE 2 — ANCHOR\n\nSolve ANCHOR_STRING into a busy public place (one English word).",
      "hint": "It’s an anagram: rearrange NITASOT into a common public place word. Use every letter exactly once.",
      "answer": "STATION",
      "inputType": "text",
      "xp": 25
    },
    {
      "id": "q3a-p3",
      "prompt": "PUZZLE 3 — CLOCK\n\nGive the fourth timestamp per the CLOCK rule (HH:MM).",
      "hint": "The clock advances in constant +10 minute steps. Continue the sequence one step after 00:00.",
      "answer": "00:10",
      "inputType": "text",
      "xp": 25
    }
  ],
  "finalePrompt": "You have:\n• Id: MARCO (from rot13)\n• Anchor: STATION\n• Time: 00:10\n\nYour last intervention did not stop the incident — it moved it.\n\nWhat do you do now?",
  "xpFinale": 75
}
$json$::jsonb,
    false,
    false
  ),
  (
    'oracle-03b-observe',
    'PROJECT ORACLE — Quest 3B — OBSERVE (draft)',
    $json$
{
  "intro": "Quest 3B — OBSERVE.\n\nYou do not intervene — so you see ORACLE placing variants side by side.\n\nLegend:\n- **Canon** = exactly what Quest 1 extracted from the leak: LENA / PARK / 23:40\n- **Variant** = same scaffold, different field filled in\n\nYour logs show three rows. Only one row is fully canon.",
  "puzzles": [
    {
      "id": "q3b-p1",
      "prompt": "PUZZLE 1 — CANON\n\nWhich row matches Quest 1 exactly (time — zone — name)?\n\nA → 23:40 – PARK – LENA\nB → 23:45 – PARK – LENA\nC → 23:40 – STATION – LENA",
      "hint": "Use the canon triplet you extracted in Quest 1 (time / zone / name). Only one row matches all three.",
      "answer": "A",
      "inputType": "choice",
      "choices": ["A", "B", "C"],
      "xp": 25
    },
    {
      "id": "q3b-p2",
      "prompt": "PUZZLE 2 — RIDDLE\n\nThe dossier says: ‘Same clock, same place — but another _____’ (English, 5 letters).\nStarts with: E _ _ _ _",
      "hint": "What changes when the header stays identical but content does not?",
      "answer": "EVENT",
      "inputType": "text",
      "xp": 25
    },
    {
      "id": "q3b-p3",
      "prompt": "PUZZLE 3 — PATTERN\n\nIf ORACLE shows multiple outcomes that share the same skeleton, what are you studying?\n\nA → a single objective truth\nB → sensor noise only\nC → variants / parallel descriptions of the same scaffold",
      "hint": "Read this quest intro.",
      "answer": "C",
      "inputType": "choice",
      "choices": ["A", "B", "C"],
      "xp": 25
    }
  ],
  "finalePrompt": "You see that one incident has multiple variants.\n\nWhat do you do with that knowledge?",
  "xpFinale": 75
}
$json$::jsonb,
    false,
    false
  ),
  (
    'oracle-03c-influence',
    'PROJECT ORACLE — Quest 3C — INFLUENCE (draft)',
    $json$
{
  "intro": "Quest 3C — INFLUENCE.\n\nYou use the leak as leverage: you touch **input** and read **output**.\n\nMini-spec in the dossier:\n---\nf(input) → output\nIf you shift input by vector Δ, the log records output shift Δ²:\nΔ = (+1 hour, −7 minutes) relative to baseline **21:31**\n---\n\nBaseline **21:31**. Apply Δ: +1 hour → 22:31; then −7 min → **22:24**. That is the new timestamp in the log.",
  "puzzles": [
    {
      "id": "q3c-p1",
      "prompt": "PUZZLE 1 — PIPELINE\n\nComplete the chain: INPUT → _____ → OUTPUT (English, 7 letters).\n\nThe hook is in the first sentence of this intro.",
      "hint": "What sits between raw input and result?",
      "answer": "PROCESS",
      "inputType": "text",
      "xp": 25
    },
    {
      "id": "q3c-p2",
      "prompt": "PUZZLE 2 — TIME SHIFT\n\nPer the dossier: baseline 21:31, then Δ = +1 hour and −7 minutes. Resulting time (HH:MM)?",
      "hint": "Apply the shift in two steps: add 1 hour, then subtract 7 minutes. Keep the HH:MM format.",
      "answer": "22:24",
      "inputType": "text",
      "xp": 25
    },
    {
      "id": "q3c-p3",
      "prompt": "PUZZLE 3 — AIM\n\nAnagram (English, 6 letters): what you pick when you steer the system — **T E G R A T**.",
      "hint": "Rearrange the letters into one common word meaning what you aim at when steering a system. One word, no spaces.",
      "answer": "TARGET",
      "inputType": "text",
      "xp": 25
    }
  ],
  "finalePrompt": "Your actions change the data.\n\nWhat do you do next?",
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
