-- PROJECT ORACLE — draft quests (body text can be NL; puzzle answers stay as validated tokens)
-- Run in Supabase SQL Editor after migrations. Adjust starts_at / ends_at in Admin when going live.
--
-- Rules alignment: tiered hints (richting → mechaniek → startpunt), near-miss wrongFeedback where useful,
-- preFinale (mechanisch + implicatie) voor slot→keuze brug, geen antwoord in intro dat de puzzel trivialiseert.

insert into public.quests (slug, title, body, is_published, archived)
values
  (
    'oracle-01-lek',
    'PROJECT ORACLE — Quest 1 — Het lek',
    $json$
{
  "intro": "PROJECT ORACLE — Hoofdstuk 1 — Het lek\n\nDit is je materiaal: een corrupt incidentfragment uit ORACLE’s buffer — geen aparte tekst erbuiten. Alles wat je nodig hebt staat in het blok hieronder.\n\n```\nINCIDENTNOTE v0.7 | integrity: DEGRADED\nSUBJECT_CODE: 12–5–14–1   (decode: A=1, B=2, … Z=26; lees de parels op volgorde)\nTIMELINE: tick₁ = 23:20   tick₂ = 23:30   tick₃ = ?\nREGEL: Δ tussen opeenvolgende ticks is constant (+10 min ten opzichte van de vorige).\nZONE_TOKEN: herschik P R A K tot één woord — een typische openbare groene plek in een stad (Engels, 4 letters).\n```\n\nORACLE lekt precies genoeg om te laten zien dat reconstructie mogelijk is — nog niet waarom dit dossier jouw naam zal raken.\n\nReconstrueer wie (voornaam), wanneer (tick₃), waar (zone). Elk antwoord gebruik je mentaal opnieuw in het slot.",
  "puzzles": [
    {
      "id": "q1-naam",
      "prompt": "PUZZLE 1 — SUBJECT_CODE\n\nContext: de subjectcode staat als parels gescheiden door lange en-strepen — geen rekenmachine, alleen het alfabet.\n\nOpdracht: decodeer **12–5–14–1** met A=1 … Z=26. Één woord: de voornaam (hoofdletters).",
      "hints": [
        "Richting: alle signalen voor de naam zitten alleen in het veld SUBJECT_CODE bovenin het incidentblok.",
        "Mechaniek: A1Z26 — elk getal mapt naar precies één hoofdletter, in de volgorde van de parels.",
        "Startpunt: het eerste getal is 12; bepaal welke letter dat is en herhaal de mapping voor elk volgend getal."
      ],
      "wrongFeedback": "De mapping zit dicht bij de kern — tel de posities nog eens langs in volgorde, zonder tussenstappen over te slaan.",
      "answer": "LENA",
      "inputType": "text",
      "xp": 25
    },
    {
      "id": "q1-tijd",
      "prompt": "PUZZLE 2 — TIJDLIJN\n\nContext: de REGEL in het fragment definieert het tijdsverschil tussen opeenvolgende ticks — geen kalenderdatum, alleen HH:MM binnen één avond.\n\nOpdracht: volgens die REGEL: tick₃ = ? (notatie **HH:MM**).",
      "hints": [
        "Richting: gebruik alleen tick₁ en tick₂ uit het geblokkeerde fragment — geen andere bron.",
        "Mechaniek: het verschil in minuten tussen opeenvolgende ticks blijft constant; herhaal datzelfde verschil vanaf tick₂.",
        "Startpunt: werk het interval tussen tick₁ en tick₂ één keer door naar het volgende tijdstip na tick₂."
      ],
      "wrongFeedback": "De cadans klopt bijna — controleer of je hetzelfde minutenverschil toepast op de laatste stap.",
      "answer": "23:40",
      "inputType": "text",
      "xp": 25
    },
    {
      "id": "q1-plaats",
      "prompt": "PUZZLE 3 — ZONE_TOKEN\n\nContext: ZONE_TOKEN is een permutatie — één gangbaar Engels woord, geen afkorting.\n\nOpdracht: herschik **P R A K** tot dat woord voor een typische openbare groene zone in een stad (hoofdletters).",
      "hints": [
        "Richting: je zoekt één woord uit precies deze vier letters, elk een keer gebruikt.",
        "Mechaniek: anagram — alleen herschikken; er is geen tweede decode-stap.",
        "Startpunt: denk aan een compact Engels woord voor een typische buitenruimte in een stad — geen straatnaam."
      ],
      "wrongFeedback": "De letters kloppen als set — herschikken tot een woord dat letterlijk ‘open groen’ in de stad suggereert.",
      "answer": "PARK",
      "inputType": "text",
      "xp": 25
    }
  ],
  "preFinale": {
    "summary": "Mechanisch slot: SUBJECT_CODE ⇒ LENA; tijdlijn ⇒ 23:40; ZONE_TOKEN ⇒ PARK — het incident is reconstructeerbaar uit het lek.",
    "implication": "ORACLE heeft dit expres zichtbaar gemaakt: observatie zonder ingrijpen is nog mogelijk — elke latere keuze verandert wat je hierna mag geloven."
  },
  "finalePrompt": "Je legt het lek als ketting:\n→ Persoon: LENA\n→ Plek: PARK\n→ Tijd: 23:40\n\nNog geen ingrijpen — alleen vaststellen. Het systeem vraagt een eerste koers voor het volgende segment.\n\nWelk pad log je? (CONTROL = direct bijsturen · OBSERVE = niet ingrijpen, alleen registreren · INFLUENCE = indirect sturen via randvoorwaarden)",
  "xpFinale": 75
}
$json$::jsonb,
    false,
    false
  ),
  (
    'oracle-03a-control',
    'PROJECT ORACLE — Quest 3A — CONTROL',
    $json$
{
  "intro": "Quest 3A — CONTROL — mirror buffer.\n\nJe probeert het eerste incident te stoppen. De buffer spiegelt je dossier met een andere encoding — ORACLE verschuift mee met wat je probeert te breken.\n\n```\nBUFFER excerpt (ARC-7):\nPRIMARY_ID rot13: ZNEPB\nANCHOR_STRING (7 letters, elke letter 1×): NITASOT\nCLOCK: 23:40 → 23:50 → 00:00 → ?   (+10 min per stap; middernacht = 00:00)\n```\n\nAls ORACLE alleen verschuift wat jij probeert te breken — wat blijft er dan over?",
  "puzzles": [
    {
      "id": "q3a-p1",
      "prompt": "PUZZLE 1 — ROT13\n\nContext: PRIMARY_ID staat in het excerpt als ROT13 — het plaintext is een voornaam.\n\nOpdracht: decodeer PRIMARY_ID. Antwoord: alleen de voornaam (hoofdletters).",
      "hints": [
        "Richting: werk alleen op het veld PRIMARY_ID in het excerpt — niet op andere regels.",
        "Mechaniek: ROT13 — elke letter +13 posities in het alfabet (A↔N, B↔O, enz.).",
        "Startpunt: decodeer Z als begin van een voornaam; ga letter voor letter door het token."
      ],
      "wrongFeedback": "Het alfabet klopt nog — tel de ROT13-shift opnieuw letter voor letter.",
      "answer": "MARCO",
      "inputType": "text",
      "xp": 25
    },
    {
      "id": "q3a-p2",
      "prompt": "PUZZLE 2 — ANCHOR\n\nContext: ANCHOR_STRING is één veelvoorkomend woord voor een drukke openbare plek — Engels, zeven letters.\n\nOpdracht: herschik **NITASOT** tot dat woord (hoofdletters).",
      "hints": [
        "Richting: het is een plek waar routes en mensen samenkomen — geen abstract begrip.",
        "Mechaniek: anagram — zeven letters, elk exact één keer.",
        "Startpunt: denk aan haltes, perrons, en overstap — een woord dat vaak op stadsplattegronden staat."
      ],
      "wrongFeedback": "Alle letters zijn er — het is een herordening tot een bekende ruimtelijke ‘plek’, geen eigennaam.",
      "answer": "STATION",
      "inputType": "text",
      "xp": 25
    },
    {
      "id": "q3a-p3",
      "prompt": "PUZZLE 3 — CLOCK\n\nContext: de CLOCK-regel is +10 minuten per stap; middernacht is 00:00 en daarna loopt de klok normaal door.\n\nOpdracht: het vierde tijdstip in de keten (HH:MM).",
      "hints": [
        "Richting: verleng alleen de gegeven keten — geen extra tussenstappen buiten het excerpt.",
        "Mechaniek: tel +10 minuten op het vorige tijdstip; bij >59 minuten correct door naar het volgende uur (incl. na 23:59 → 00:xx).",
        "Startpunt: na 00:00 komt het volgende tick in dezelfde stapgrootte."
      ],
      "wrongFeedback": "Het interval is gelijk aan de vorige schakels — alleen +10 tellen vanaf het laatste gegeven tijdstip.",
      "answer": "00:10",
      "inputType": "text",
      "xp": 25
    }
  ],
  "preFinale": {
    "summary": "Mechanisch: MARCO (ROT13), anker STATION, klokslot 00:10 — het mirror-buffer incident is als set leesbaar.",
    "implication": "CONTROL betekent hier: jij forceert uitkomst — ORACLE heeft al laten zien dat ingrijpen het incident kan verplaatsen in plaats van te stoppen."
  },
  "finalePrompt": "Je hebt:\n• Id: MARCO\n• Anchor: STATION\n• Time: 00:10\n\nJe vorige interventie stopte het incident niet — het verschuift mee.\n\nWelk pad kies je nu? Elk pad heeft een prijs op de volgende run (CONTROL / OBSERVE / INFLUENCE).",
  "xpFinale": 75
}
$json$::jsonb,
    false,
    false
  ),
  (
    'oracle-03b-observe',
    'PROJECT ORACLE — Quest 3B — OBSERVE',
    $json$
{
  "intro": "Quest 3B — OBSERVE.\n\nJe grijpt niet in — dus zie je hoe ORACLE varianten naast elkaar zet.\n\nLegenda:\n- **Canon** = exact wat Quest 1 uit het lek haalde: **23:40 · PARK · LENA**\n- **Variant** = hetzelfde skelet, ander veld ingevuld\n\n```\nRij A: 23:40 | PARK | LENA\nRij B: 23:45 | PARK | LENA\nRij C: 23:40 | STATION | LENA\n```\n\nSlechts één rij is volledig canon.",
  "puzzles": [
    {
      "id": "q3b-p1",
      "prompt": "PUZZLE 1 — CANON\n\nContext: je vergelijkt tijdzone, zone en naam met de canon-triplet uit Quest 1.\n\nOpdracht: welke rij (A, B of C) matcht exact op alle drie de velden?\n\nA → 23:40 – PARK – LENA\nB → 23:45 – PARK – LENA\nC → 23:40 – STATION – LENA",
      "hints": [
        "Richting: canon is geen interpretatie — het zijn drie harde tokens tegelijk juist.",
        "Mechaniek: vergelijk per kolom (tijd, zone, naam) met de Quest-1-output.",
        "Startpunt: twee rijen zijn bewust ‘bijna’ goed — één veld per rij afwijkend ten opzichte van canon."
      ],
      "wrongFeedback": "Je zit dichtbij — tel de drie velden als één handtekening, niet afzonderlijk ‘goed genoeg’.",
      "answer": "A",
      "inputType": "choice",
      "choices": ["A", "B", "C"],
      "xp": 25
    },
    {
      "id": "q3b-p2",
      "prompt": "PUZZLE 2 — RIDDLE\n\nContext: de zin in het dossier contrasteert wat vastligt met wat verandert — zelfde ‘plek’, ander verschijnsel.\n\nOpdracht: vul in (Engels, 5 letters): ‘Same clock, same place — but another _____’",
      "hints": [
        "Richting: het antwoord is geen naam of tijd — het beschrijft wat er anders kan gebeuren op dezelfde coördinaten.",
        "Mechaniek: één zelfstandig naamwoord dat ‘voorval’ of ‘optreden’ dekt.",
        "Startpunt: een gangbaar Engels woord voor ‘gebeurtenis’ op een vaste plek — geen naam van een persoon."
      ],
      "wrongFeedback": "De structuur van de zin wil een abstractum — iets dat op dezelfde plek opnieuw kan plaatsvinden.",
      "answer": "EVENT",
      "inputType": "text",
      "xp": 25
    },
    {
      "id": "q3b-p3",
      "prompt": "PUZZLE 3 — PATTERN\n\nContext: ORACLE toont meerdere uitkomsten die hetzelfde dossier-layout delen.\n\nOpdracht: kies de juiste beschrijving — A, B of C.\n\nA → één objectieve waarheid\nB → alleen sensor-ruis\nC → varianten / parallelle beschrijvingen van hetzelfde skelet",
      "hints": [
        "Richting: dit vraagt naar je **rol** als waarnemer wanneer het skelet gelijk blijft maar velden verschillen.",
        "Mechaniek: je kiest tussen ‘één waarheid’, ‘ruis’, of ‘gestructureerde varianten’.",
        "Startpunt: de legenda van deze quest definieert ‘variant’ expliciet — welk antwoord hoort daarbij?"
      ],
      "wrongFeedback": "De intro definieert Variant tegenover Canon — welk antwoord beschrijft meerdere consistente fills?",
      "answer": "C",
      "inputType": "choice",
      "choices": ["A", "B", "C"],
      "xp": 25
    }
  ],
  "preFinale": {
    "summary": "Mechanisch: canonrij A bevestigd; het verschijnsel dat varieert is het ‘event’ terwijl tijd en plek gelijk kunnen blijven; je beschrijft parallelle uitkomsten.",
    "implication": "OBSERVE betekent hier: je erkent dat ORACLE meer dan één leesbare werkelijkheid toestaat — dat beïnvloekt hoe betrouwbaar je volgende intel is."
  },
  "finalePrompt": "Je ziet dat één incident meerdere varianten heeft — niet als fout, maar als structureel gedrag.\n\nWat doe je met die kennis? Drie paden (CONTROL / OBSERVE / INFLUENCE) wegen door op hoeveel je nog vertrouwt versus hoeveel je nu probeert te sturen.",
  "xpFinale": 75
}
$json$::jsonb,
    false,
    false
  ),
  (
    'oracle-03c-influence',
    'PROJECT ORACLE — Quest 3C — INFLUENCE',
    $json$
{
  "intro": "Quest 3C — INFLUENCE.\n\nJe gebruikt het lek als hefboom: je raakt **input** aan en leest **output** af.\n\nMini-spec (lees dit als contract, niet als rekenvoorbeeld):\n```\nf(input) → output\nAls je input verschuift met vector Δ, registreert de log een output-shift Δ²\n  (Δ = (+1 uur, −7 minuten) relatief ten opzichte van baseline 21:31)\n```\n\nBaseline in het dossier: **21:31**. Pas Δ toe in twee stappen: eerst het uur, dan de minuten — rond zoals een klok (geen datumrollen).\n\nDe uitkomst van die berekening is het antwoord voor puzzel 2 — die staat hier bewust **niet** in één zin geschreven, zodat je het zelf moet vastleggen.",
  "puzzles": [
    {
      "id": "q3c-p1",
      "prompt": "PUZZLE 1 — PIPELINE\n\nContext: de eerste zin van de quest-intro beschrijft jouw positie tussen bron en resultaat.\n\nOpdracht: vul de keten aan (Engels, 7 letters):\nINPUT → _____ → OUTPUT",
      "hints": [
        "Richting: zoek een woord dat staat tussen ruwe invoer en wat er uit het systeem komt.",
        "Mechaniek: het is een pipeline-term — niet ‘model’ of ‘buffer’, maar het tussenstation waar transformatie gebeurt.",
        "Startpunt: zoek het standaard Engelse label voor de stap tussen ruwe invoer en uitvoer in een gegevens- of productiestroom — zeven letters."
      ],
      "wrongFeedback": "Het woord zit letterlijk in de eerste regel van de intro — een bekende 7-letter keten tussen input en output.",
      "answer": "PROCESS",
      "inputType": "text",
      "xp": 25
    },
    {
      "id": "q3c-p2",
      "prompt": "PUZZLE 2 — TIME SHIFT\n\nContext: baseline **21:31**. Vector Δ = (+1 uur, −7 minuten). Pas Δ op de baseline toe in twee stappen; resultaat als **HH:MM**.\n\nOpdracht: noteer het resulterende tijdstip.",
      "hints": [
        "Richting: gebruik alleen baseline + Δ — geen extra offsets uit de rest van de tekst.",
        "Mechaniek: pas Δ in twee schijven toe op de klok (uur, dan minuten) zonder datum te rollen.",
        "Startpunt: controleer vooral dat minuten na +1 uur nog netjes binnen het uur blijven voor je de minuutcorrectie doet."
      ],
      "wrongFeedback": "De delta is klein na de uursprong — controleer vooral de minuut-stap na 22:31.",
      "answer": "22:24",
      "inputType": "text",
      "xp": 25
    },
    {
      "id": "q3c-p3",
      "prompt": "PUZZLE 3 — AIM\n\nContext: wanneer je het systeem stuurt, spreek je een doel aan — niet de hele keten.\n\nOpdracht: anagram (Engels, 6 letters): **T E G R A T** — het woord voor wat je kiest om te richten (hoofdletters).",
      "hints": [
        "Richting: het woord beschrijft je doelvector in besturing, geen emotie.",
        "Mechaniek: anagram van zes letters; geen dubbele betekenis nodig.",
        "Startpunt: een standaardwoord in KPI- en besturingstaal — ‘what you optimize for’."
      ],
      "wrongFeedback": "Alle letters zijn er — herschik tot het woord dat architecten en planners ‘het doel’ noemen.",
      "answer": "TARGET",
      "inputType": "text",
      "xp": 25
    }
  ],
  "preFinale": {
    "summary": "Mechanisch: keten INPUT→PROCESS→OUTPUT; tijdsverschuiving uit baseline+Δ ⇒ 22:24; doelwoord TARGET — je hebt het dossier als hefboom gelezen.",
    "implication": "INFLUENCE betekent hier: je wijzigde logs en waarneming — ORACLE kan daarop verschalen; je volgende bronnen kunnen bewust ‘gekleurd’ zijn."
  },
  "finalePrompt": "Je acties veranderen de data die anderen zien.\n\nWat doe je hierna? Elk pad (CONTROL / OBSERVE / INFLUENCE) verandert hoe agressief je nog in het systeem duwt versus hoeveel je nog alleen registreert.",
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
