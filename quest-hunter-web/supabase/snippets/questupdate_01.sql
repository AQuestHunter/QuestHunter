-- =============================================================================
-- QUESTUPDATE 01 — alle quest body- en campagne-updates in één run
-- =============================================================================
-- Uitvoeren in Supabase SQL Editor (na toepassen van migraties).
-- Herkomst: actuele inhoud uit draft_project_oracle_quests.sql,
-- draft_project_black_vault.sql, draft_project_protocol_17.sql,
-- draft_project_echo.sql (tekst/taal/hints/moeilijkheid).
--
-- Volgende bundel: kopieer naar questupdate_02.sql en verhoog het nummer.
-- UI/app-wijzigingen (bijv. QuestRunner, CSS) zitten niet in dit script.
--
-- Gedrag: INSERT ... ON CONFLICT (slug) DO UPDATE voor bekende slug's,
-- daarna UPDATE-statements voor campaign_slug / next_* koppelingen.
-- =============================================================================


-- -----------------------------------------------------------------------------
-- PROJECT ORACLE — draft_project_oracle_quests.sql
-- -----------------------------------------------------------------------------

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


-- -----------------------------------------------------------------------------
-- BLACK VAULT — draft_project_black_vault.sql
-- -----------------------------------------------------------------------------

insert into public.quests (slug, title, body, is_published, archived)
values
  (
    'black-vault-01-kaart',
    'De kluis die niet bestaat — Quest 1 — De kaart die niet bestaat',
    $json$
{
  "intro": "🔐 QUEST 1 — VOORBEREIDINGEN: DE KAART DIE NIET BESTAAT\n\nGerucht: een black vault — off-books, geen registratie. Jij krijgt drie bronnen die elkaar zouden moeten dekken… en dat doen ze niet.\n\n**Laag A — Fragment uit energie-dashboard (kWh / uur, peak):**\n```\n       1     2     3     4\nA     42    12     9    55\nB     18     0    41    20    ← rij B: kWh; 0 = ‘geen meting / leeg’\nC    cam   cam    ∅    cam   ← ∅ = geen camerastream (niet offline, bewust leeg)\nD     +1    +2    +6    +1    ← thermisch verschil (°C vs omgeving), laatste meetronde\n```\n**Laag B — Officieel plattegrond-label (zelfde rooster):** cellen met een naam op de getekende plaat: A1 LOBBY, B1 TRAP, A4 TRESOR, D4 ARCHIEF — alles behalve **B3** heeft een contour op de tekening. Cel **B3** staat op de plot als massieve muur.\n**Laag C — Interne mailtrail (codetaal):** elk bericht eindigt met een TAG in het honderdvoud:\n```\nM1 TAG:1800 / init: NV (Niet Verklaard)\nM2 TAG:2100 / init: NV\nM3 TAG:5123 / init: NV\n```\n**Regel:** tel de drie TAG-waarden uit de mailtabel op; gebruik het totaal om via de **laatste twee decimalen** een roosterplek af te leiden (tiental → rij 1–4 als A–D, eenheid → kolom 1–4 — exact zoals je interne mapping-doc het definieert). Kruis dat met Laag A en B.\n\nKopregel op het interceptblad (classificatie): **BLACK**.\n\nNiet de kluisruimte zelf is het anker — iets naast het plangebied ligt. Waar komt de werkelijkheid los van het papier?",
  "puzzles": [
    {
      "id": "bv01-p1",
      "prompt": "PUZZLE 1 — NEGATIEVE RUIMTE\n\nContext: zoek de ene cel waar **thermiek** iets zegt, **stroom** zwijgt, en **camera** gezien de regels in de intro géén beeld levert.\n\nOpdracht: roostercel in notatie **A1 / B3 / …** (hoofdletter + cijfer, geen spaties).",
      "hints": [
        "Richting: vergelijk rij D (thermiek) met rij B (kWh) en rij C (camera’s).",
        "Mechaniek: ‘negatieve ruimte’ = het contrast tussen wat hoort te meten en wat **onbruikbaar / leeg** lijkt — maar wél een signaal geeft.",
        "Startpunt: kWh=0 maar thermiek ≠ 0 op dezelfde kolom — welke kolom(en) overblijven als je ook rij C leest?"
      ],
      "wrongFeedback": "Het patroon zit om de hoek — jouw raster klopt bijna; check één kolom waar stroom ‘wegvalt’ terwijl een ander veld daar wél een verschil claimt.",
      "answer": "B3",
      "inputType": "text",
      "xp": 28
    },
    {
      "id": "bv01-p2",
      "prompt": "PUZZLE 2 — MAILTAGS → ROOSTER\n\nContext: de TAG-regels in de intro zijn homogeen (allemaal ×100). Som → laatste twee cijfers → mapping naar kolom X en rijcode Y volgens de introductie.\n\nOpdracht: noteer de cel die uit die mapping volgt (**A1–D4**,zelfde notatie als puzzel 1).",
      "hints": [
        "Richting: alle drie TAG’s optellen — de derde TAG is niet 2400.",
        "Mechaniek: som eindigt op **9023** — neem de laatste twee cijfers en map: tiental=rij (1–4), eenheid=kolom (1–4).",
        "Startpunt: de som zelf moet dezelfde cel opleveren als je thermiek/kWh/camera-cluster — tel opnieuw als je niet op **9023** uitkomt."
      ],
      "wrongFeedback": "De derde TAG zit een honderdvoud hoger dan je verwacht — herlees de mailtabel en tel opnieuw tot je op **9023** uitkomt.",
      "answer": "B3",
      "inputType": "text",
      "xp": 28
    },
    {
      "id": "bv01-p3",
      "prompt": "PUZZLE 3 — VALSE AANNAME\n\nContext: iedereen zoekt naar de woordelijke kluisdeur. Jij zoekt naar **de naastgelegen** route die op tekeningen onzichtbaar wordt gehouden.\n\nOpdracht: één woord (Engels, 7 letters): wat verbindt een publieke bankhal met een achterliggende technische zone die niet als kamer genummerd staat?",
      "hints": [
        "Richting: denk niet aan kluis + sleutel — denk aan **nuts** en personen die ‘onderhoud’ noemen.",
        "Mechaniek: een vaste term voor een **bedienerstunnel / technische corridor** bij vastgoed en datacenters.",
        "Startpunt: begint met **S**, eindigt op **E** — zeven letters."
      ],
      "wrongFeedback": "Je zoekt geen merknaam — een functionele bypass achter de muren, in één gangbaar Engels woord.",
      "answer": "SERVICE",
      "inputType": "text",
      "xp": 28
    }
  ],
  "preFinale": {
    "summary": "Mechanisch: beide rekenroutes wijzen naar cel **B3**; het organisatie-verhaal wil een **SERVICE**-vector naast het officiële kluisperimeter.",
    "implication": "De black vault ligt waar papier een muur tekent — maar sensoren fluisteren ‘door’. De volgende stap is digitale sleutels, niet een hamer."
  },
  "finalePrompt": "Je hebt een verborgen cel (**B3**) en een bypass-type (**SERVICE**).\n\nHoe spring je verder?\n\n• **CONTROL** — Forceer een routesegment in het bouw-BMS; je koopt tijd maar verhoogt zichtbaarheid.\n• **OBSERVE** — Kaart alleen; geen scripts—je volgt het spoor met minimale voetafdruk.\n• **INFLUENCE** — Leg een vals onderhoudspad in logs zodat echte teams uitwijken.\n\nWelk pad kies je?",
  "xpFinale": 75,
  "ui": {
    "branches": {
      "CONTROL": { "title": "CONTROL", "description": "Hard in het BMS — snel, luid." },
      "OBSERVE": { "title": "OBSERVE", "description": "Alleen lezen — stil, koud." },
      "INFLUENCE": { "title": "INFLUENCE", "description": "Misdirectie in tickets — grijs." }
    }
  }
}
$json$::jsonb,
    false,
    false
  ),
  (
    'black-vault-02-sleutels',
    'De kluis die niet bestaat — Quest 2 — De sleutels tot niets',
    $json$
{
  "intro": "🛠️ QUEST 2 — VOORBEREIDING: DE SLEUTELS TOT NIETS\n\nEr is geen klassieke sleutel — alleen tijdsloten en een sleutelwoord dat per rotatie verandert.\n\n**Sleutelwoord van deze shift (herhaal zo nodig):** `BANK`\n\n**Badge-codes (Vigenère-cryptotekst, letters A–Z):**\n```\nEENX   — roster: nachtportier (blok C)\nYJIN   — roster: compliance (blok A)\nQHYF   — roster: SOC (blok B)\n```\nDecodeer elk token met het sleutelwoord hierboven (standaard Vigenère **ontcijferen**: C = (Y−K mod 26) met A=0…).\n\n**Shift-rotatie-sleutel (cijfer):** uurblokken in een cyclus van 12 uur: blok **1** = 00–04, blok **2** = 04–08, blok **3** = 08–12, blok **4** = 12–16, blok **5** = 16–20, blok **6** = 20–24. Het actieve bloknummer op **17:40** is de rotatie-index **R**.\n\n**HR-flash:** medewerker **DEAN** staat als overleden geregistreerd — toch zie je op 17:41 een geldige challenge **die dezelfde initialen gebruikt als een levend roster**.",
  "puzzles": [
    {
      "id": "bv02-p1",
      "prompt": "PUZZLE 1 — VIGENÈRE → NAAM\n\nContext: gebruik sleutel **BANK** herhaald op het eerste badge-token **EENX**.\n\nOpdracht: het ontcijferde token is een voornaam — noteer **hoofdletters**.",
      "hints": [
        "Richting: alleen het eerste vierletter-token met sleutel BANK.",
        "Mechaniek: Vigenère decrypt per letter: plat = (cipher − key + 26) mod 26.",
        "Startpunt: eerste letter: E−B → mapping A=0… Z=25."
      ],
      "wrongFeedback": "Het sleutelwoord staat vast — tel mod 26 alsof het een schuifslot is dat opnieuw uitlijnt bij elke positie.",
      "answer": "DEAN",
      "inputType": "text",
      "xp": 30
    },
    {
      "id": "bv02-p2",
      "prompt": "PUZZLE 2 — ROTATIE-INDEX\n\nContext: blokindeling uit de intro — bepaal **R** voor kloktijd **17:40**.\n\nOpdracht: één cijfer als tekst (**5** niet vijf uitgeschreven).",
      "hints": [
        "Richting: 17:40 valt tussen 16:00 en 20:00.",
        "Mechaniek: segments van 4 uur — tel vanaf middernacht welk segmentnummer dat is.",
        "Startpunt: 16–20 is het **vijfde** segment in de 1–6-telling uit de intro."
      ],
      "wrongFeedback": "Je zit in het juiste uurvenster — controleer of je de segmentgrenzen niet één blok te vroeg of laat snijdt.",
      "answer": "5",
      "inputType": "text",
      "xp": 30
    },
    {
      "id": "bv02-p3",
      "prompt": "PUZZLE 3 — GHOST LOGIN\n\nContext: drie persona’s verschijnen na decode; eentje hoort daar **niet** levend tussen te lopen volgens HR — maar gebruikt wél een geldig patroon.\n\nOpdracht: wie is de ‘spook’-identiteit uit de eerste drie tokens (één woord voornaam, hoofdletters)?",
      "hints": [
        "Richting: decodeer ook de andere twee tokens met **BANK** om te zien wie wél roster-achtig overblijft.",
        "Mechaniek: vergelijk met de HR-flash — welke naam matcht degene die dood zou moeten zijn?",
        "Startpunt: tel voor elk token uit wie het wordt na decode — wie botst met ‘dood’ in HR?"
      ],
      "wrongFeedback": "De roster leest net plausibel genoeg — maar één naam botst met HR: wie is dat volgens jouw decrypts?",
      "answer": "DEAN",
      "inputType": "text",
      "xp": 30
    }
  ],
  "preFinale": {
    "summary": "Mechanisch: sleutel **BANK** levert **DEAN**; rotatie-index **5**; geest-login = **DEAN** — iemand gebruikt een dode credential al binnen het slot.",
    "implication": "Het slot test niet alleen wie jij bent — maar wie het systeem **nog** gelooft te zijn."
  },
  "finalePrompt": "Je hebt een spook-ID en een rotatie-index.\n\n• **CONTROL** — Lock uit paniek openbreken met nood-handshake (snel, traceerbaar).\n• **OBSERVE** — Volg het slot — geen extra injections.\n• **INFLUENCE** — Injecteer een tijdelijke sleutel die andere teams naar een honeypot duwt.\n\nWat log je?",
  "xpFinale": 75
}
$json$::jsonb,
    false,
    false
  ),
  (
    'black-vault-03-stilte',
    'De kluis die niet bestaat — Quest 3 — Stilte voor de fout',
    $json$
{
  "intro": "💥 QUEST 3 — DE DIEFSTAL: STILTE VOOR DE FOUT\n\nJe bent binnen. Het is té rustig.\n\n**Laag 1 — Binair** (8-bit-bytes, ASCII letters):\n```\n01001000 01001001 01000100 01000101\n```\n\n**Laag 2 — Morse** (letters gescheiden door `/`, spaties tussen · en −):\n```\n-- .. ... ...\n```\n\n**Laag 3 — Gedrag** — audittrail fragment (laatste kolom = status):\n```\n12:00:00 | OPEN    | OK\n12:00:30 | OPEN    | OK\n12:01:00 | OPEN    | OK\n12:01:30 | SILENT  | OK\n12:02:00 | OPEN    | OK\n```\nWelke command-string hoort bij het **eerste** gedrag dat afwijkt van het monotone patroon vóór 12:01:30?",
  "puzzles": [
    {
      "id": "bv03-p1",
      "prompt": "PUZZLE 1 — BINAIR → ASCII\n\nContext: vier bytes zoals in het intro-blok; elk byte is één letter.\n\nOpdracht: het Engelse woord (hoofdletters).",
      "hints": [
        "Richting: 01001000 is 72 in decimaal — welke ASCII-hoofdletter is dat?",
        "Mechaniek: zet elk 8-bits blok om naar een decimaal en map naar ASCII.",
        "Startpunt: na omzetting krijg je vier opeenvolgende ASCII-hoofdletters die samen een kort consolewerkwoord vormen."
      ],
      "wrongFeedback": "De bitlengtes kloppen — je alfabetmapping is één stap van de doorbraak verwijderd.",
      "answer": "HIDE",
      "inputType": "text",
      "xp": 32
    },
    {
      "id": "bv03-p2",
      "prompt": "PUZZLE 2 — MORSE\n\nContext: gebruik het morsefragment uit de intro (internationale morse).\n\nOpdracht: het Engelse woord (hoofdletters).",
      "hints": [
        "Richting: decodeer letter voor letter — `--` is M, `..` is I, `...` is S.",
        "Mechaniek: vier letters achter elkaar — geen cijfers.",
        "Startpunt: vier letters; laatste twee tekens zijn een dubbel in het woord — denk aan ‘mis’ als kern."
      ],
      "wrongFeedback": "Het ritme is regelmatig — je bent één streep of punt van de juiste cluster af.",
      "answer": "MISS",
      "inputType": "text",
      "xp": 32
    },
    {
      "id": "bv03-p3",
      "prompt": "PUZZLE 3 — PATROONBREUK\n\nContext: de log toont een herhalende OPEN/OK keten — tot iets anders verschijnt.\n\nOpdracht: exact het commando dat **eerst** uit de pas loopt vóór de norm weer naar OPEN springt (hoofdletters).",
      "hints": [
        "Richting: zoek het eerste tijdstip waar kolom 2 niet OPEN is.",
        "Mechaniek: niet ‘OK’ — het gaat om de tweede kolom-string.",
        "Startpunt: kijk naar kolom 2 van de eerste regel waar het gedrag breekt met een monotone OPEN-keten."
      ],
      "wrongFeedback": "Je focus op statuscodes is logisch — maar de vraag wil het **command** op de afwijkende regel.",
      "answer": "SILENT",
      "inputType": "text",
      "xp": 32
    }
  ],
  "preFinale": {
    "summary": "Mechanisch: **HIDE**, **MISS**, eerste breukcommand **SILENT** — de kluis luistert; stilte is een signaal.",
    "implication": "Geen alarm betekent hier geen vergiffenis — het betekent **meting**. Iemand kijkt mee met hoe jij naar stilte grijpt."
  },
  "finalePrompt": "Je hebt het patroon: verbergen, missen, verstommen — allemaal telemetry.\n\nVolgende zet?\n\n• **CONTROL** — Doorbreek monitoring lokaal (risk: je triggert redundanties elders).\n• **OBSERVE** — Laat de listeners praten; jij leest alleen af.\n• **INFLUENCE** — Stuur ruis terug in hun model (vertraagt, maar verraadt je stijl).\n\nWelk pad kies je?",
  "xpFinale": 75
}
$json$::jsonb,
    false,
    false
  ),
  (
    'black-vault-04-jacht',
    'De kluis die niet bestaat — Quest 4 — Jacht of val?',
    $json$
{
  "intro": "🚨 QUEST 4 — ONTSNAPPING: JACHT OF VAL?\n\nAlarm: globaal. Lockdown houdt mensen **binnen**, niet jou buiten.\n\n**Route-grid** ( `#` = dicht, `·` = loopbaan, **S** = jij, **X** = uitgang ):\n```\n·#···\n··#··\nS··#·\n·····\n···#X\n```\nJe mag alleen naar boven/rechts/links/onder tussen `·`-velden.\n\n**Deurcodes (hex → ASCII printable):**\n```\n48 4F 4C 44\n```\n(hoort bij ‘wat je niet doet’ tijdens een lockdown — één Engels woord).\n\n**Intercept** — fragmenten afgedrukt in vaste volgorde: **A**, dan **B**, dan **C**:\n```\nA: t+0ms  SYNC  ACK\nB: t+40ms SYNC  ACK\nC: t+20ms SYNC  ACK   (tussen 0 en 40 in)\n```\nWelk fragment staat **op de afdruk verkeerd gepositioneerd** t.o.v. de chronologie? (Als je de tijdstempels sorteert: 0 → 20 → 40, hoort het **tweede** fragment in het document niet voor het **derde** te staan.)",
  "puzzles": [
    {
      "id": "bv04-p1",
      "prompt": "PUZZLE 1 — MANHATTAN-EXIT\n\nContext: BFS/pen en papier — van **S** naar **X** in het grid uit de intro, alleen ·-cellen.\n\nOpdracht: minimale stappen als **integer** (geen eenheid).",
      "hints": [
        "Richting: teken het kortste pad — geen diagonaal.",
        "Mechaniek: elke stap telt als 1; muren zijn onoverbrugbaar.",
        "Startpunt: één optimale route heeft zes stappen."
      ],
      "wrongFeedback": "Je route is geldig maar niet minimaal — zoek waar je een omweg kunt afsnijden rond de middelste #.",
      "answer": "6",
      "inputType": "text",
      "xp": 34
    },
    {
      "id": "bv04-p2",
      "prompt": "PUZZLE 2 — HEX-TOKEN\n\nContext: vier bytes zoals gegeven — map naar ASCII-letters.\n\nOpdracht: het Engelse woord (hoofdletters).",
      "hints": [
        "Richting: 48,4F,4C,44 in hex.",
        "Mechaniek: elk paar hex-cijfers is één ASCII-teken.",
        "Startpunt: 48 is ‘H’, 4F is ‘O’…"
      ],
      "wrongFeedback": "Je decimale omzetting klopt bijna — controleer de laatste byte als letter ‘D’.",
      "answer": "HOLD",
      "inputType": "text",
      "xp": 34
    },
    {
      "id": "bv04-p3",
      "prompt": "PUZZLE 3 — FAKE SYNC\n\nContext: kies welk fragment uit de synchronisatie-tijdlijn haalt als monotoon oplopende tijdstempels.\n\nOpdracht: één letter (**A**, **B** of **C**).",
      "hints": [
        "Richting: sorteer alleen op milliseconden: A(0), C(20), B(40).",
        "Mechaniek: vergelijk die chronologische lijst met printvolgorde A–B–C — welke letter blokkeert een ‘tussen’-tijdstempel op de verkeerde plek?",
        "Startpunt: zet de drie regels in **tijdsvolgorde** en leg die naast printvolgorde — één label staat tussen twee anderen die chronologisch eerder hoorden."
      ],
      "wrongFeedback": "Alle drie zijn technisch geldige ACK’s — richt je op **documentpositie** versus **tijdsorde**.",
      "answer": "B",
      "inputType": "choice",
      "choices": ["A", "B", "C"],
      "xp": 34
    }
  ],
  "preFinale": {
    "summary": "Mechanisch: kortste route = **6** stappen; hex = **HOLD**; inconsistente sync = **B** — je zat in een georkestreerde proef.",
    "implication": "De lockdown was geen fout — hij sorteerde spelers. Nu kies je wat je met de waarheid doet."
  },
  "finalePrompt": "Je hebt routes, tokens, en gefabriceerde comm.\n\nDrie scenario’s — allemaal zonder ‘veilige’ winnaar:\n\n• **CONTROL** — **Vluchten met de data** — fysiek de drag mee; je bent zichtbaar maar onafhankelijk.\n• **INFLUENCE** — **Uploaden & blootleggen** — spreid het bewijs; je markeert jezelf als openlijke bron.\n• **OBSERVE** — **Alles wissen & verdwijnen** — minimal footprint; maar wie denkt dan voor je na?\n\nWelke keuze leg je vast?",
  "xpFinale": 75,
  "ui": {
    "branches": {
      "CONTROL": { "title": "Met de data vluchten", "description": "CONTROL — spoorbaar, agressief." },
      "INFLUENCE": { "title": "Publiceren", "description": "INFLUENCE — waarheid als wapen." },
      "OBSERVE": { "title": "Wissen & verdwijnen", "description": "OBSERVE — geen nalatenschap." }
    }
  }
}
$json$::jsonb,
    false,
    false
  ),
  (
    'black-vault-05-waarheid',
    'De kluis die niet bestaat — Quest 5 — De kluiskraak: de waarheid',
    $json$
{
  "intro": "🧨 QUEST 5 — SLOT: DE WAARHEID\n\nDe kluis beschermde geen goud — ze **registreerde** wie slim genoeg was om binnen te komen.\n\n**Checksum A1Z26:** tel de posities van de letters in **VIREX** (A=1 … Z=26).\n\n**Operationele sleutel (interne memo):** het bandlabel **SEDEK** = **S**ynthetic **E**dge **D**ata **E**ncryption **K**ernel — de softwarelaag waarmee jouw sessie werd vastgezet. Letters **S-E-D-E-K** komen overeen met de eerste letters van:\n- **S** van **SILENT** (breukcommand Quest 3)\n- **E** = 2e letter van **DEAN**\n- **D** = 3e letter van **HIDE**\n- **E** = 4e letter van **VIREX**\n- **K** = 5e letter van **BLACK** (projectcodenaam uit het eerste dossier)\n(zie raw tokens in je notities — **BLACK** stond als werknaam voor het black-vault-programma op het openingsblad).",
  "puzzles": [
    {
      "id": "bv05-p1",
      "prompt": "PUZZLE 1 — VIREX-SOM\n\nContext: A1Z26 op **VIREX** exact zoals in de intro beschreven.\n\nOpdracht: de som als decimale tekst zonder suffix (bijv. **78**).",
      "hints": [
        "Richting: alleen V, I, R, E, X.",
        "Mechaniek: A1Z26 per letter, daarna optellen.",
        "Startpunt: V en R zijn de zwaargewichten in de som."
      ],
      "wrongFeedback": "Je telt letters alsof het een checksum is — vergeet geen positie voor de X niet.",
      "answer": "78",
      "inputType": "text",
      "xp": 36
    },
    {
      "id": "bv05-p2",
      "prompt": "PUZZLE 2 — META-STRING\n\nContext: gebruik exact de compositie in de slotvraag van deze quest-intro (letters 1 van SILENT, 2 van DEAN, 3 van HIDE, 4 van VIREX, 5 van BLACK).\n\nOpdracht: het resulterende vijfletterwoord (hoofdletters).",
      "hints": [
        "Richting: geen anagram — vaste posities uit de vijf bronwoorden.",
        "Mechaniek: SILENT₁, DEAN₂, HIDE₃, VIREX₄, BLACK₅.",
        "Startpunt: het vijfde bronwoord vind je als dossierkop **BLACK** aan het begin van Quest 1."
      ],
      "wrongFeedback": "De volgorde zit vast — als je een letter uit het verkeerde bronwoord pakt, voelt het woord bijna Nederlands maar klopt het slot niet.",
      "answer": "SEDEK",
      "inputType": "text",
      "xp": 36
    },
    {
      "id": "bv05-p3",
      "prompt": "PUZZLE 3 — WAT BEN JE GEWORDEN?\n\nContext: de vault was geen kluis — ze was een **filter**. Iedereen die de keten helder doorliep werd opgeslagen als profiel.\n\nOpdracht: één Engels woord (9 letters, hoofdletters): wat juridisch en technisch gebeurt wanneer jouw naam in zo’n dossier wordt opgenomen na een geslaagde sessie?",
      "hints": [
        "Richting: niet ‘hack’ — denk aan inschrijven, indexeren.",
        "Mechaniek: synoniem voor ‘in de administratie gezet worden’.",
        "Startpunt: begint met **R**, eindigt met **D**."
      ],
      "wrongFeedback": "Je zoekt geen geldboete — maar wat er met jouw identiteitsrecord gebeurt in een watchlist-context.",
      "answer": "REGISTERED",
      "inputType": "text",
      "xp": 36
    }
  ],
  "preFinale": {
    "summary": "Mechanisch: checksum **78**; meta-token **SEDEK** (vast patroon over eerdere quest-antwoorden); het slot bevestigt dat je **REGISTERED** bent — niet beroofd, maar **geïndexeerd**.",
    "implication": "VIREX is geen kluis-deur; het is een meetsysteem. Jij bent de meting geworden."
  },
  "finalePrompt": "Je weet het: de vault was een test.\n\n**Kies je slot in het echte systeem:**\n\n• **CONTROL** — **Word onderdeel** — je krijgt hefbomen, maar accepteert hun regels.\n• **OBSERVE** — **Vernietigen** — brand de index af; chaos, maar niemand speelt meer dit spel.\n• **INFLUENCE** — **Grijs gebruik** — je houdt toegang, maar blijft manipuleren.\n\nWat log je als eindbearing?",
  "xpFinale": 100,
  "ui": {
    "branches": {
      "CONTROL": { "title": "Deelnemen", "description": "CONTROL — macht met keten." },
      "OBSERVE": { "title": "Vernietigen", "description": "OBSERVE — vrijheid door brand." },
      "INFLUENCE": { "title": "Instrumentaliseren", "description": "INFLUENCE — grijs, gevaarlijk." }
    }
  }
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

-- Campaign koppeling (lineair: alle finale-takken →zelfde vervolg)
update public.quests
set
  campaign_slug = 'black-vault',
  campaign_display_name = 'De kluis die niet bestaat',
  sequence_idx = 1,
  next_control_id = (select id from public.quests where slug = 'black-vault-02-sleutels' limit 1),
  next_observe_id = (select id from public.quests where slug = 'black-vault-02-sleutels' limit 1),
  next_influence_id = (select id from public.quests where slug = 'black-vault-02-sleutels' limit 1)
where slug = 'black-vault-01-kaart';

update public.quests
set
  campaign_slug = 'black-vault',
  campaign_display_name = 'De kluis die niet bestaat',
  sequence_idx = 2,
  next_control_id = (select id from public.quests where slug = 'black-vault-03-stilte' limit 1),
  next_observe_id = (select id from public.quests where slug = 'black-vault-03-stilte' limit 1),
  next_influence_id = (select id from public.quests where slug = 'black-vault-03-stilte' limit 1)
where slug = 'black-vault-02-sleutels';

update public.quests
set
  campaign_slug = 'black-vault',
  campaign_display_name = 'De kluis die niet bestaat',
  sequence_idx = 3,
  next_control_id = (select id from public.quests where slug = 'black-vault-04-jacht' limit 1),
  next_observe_id = (select id from public.quests where slug = 'black-vault-04-jacht' limit 1),
  next_influence_id = (select id from public.quests where slug = 'black-vault-04-jacht' limit 1)
where slug = 'black-vault-03-stilte';

update public.quests
set
  campaign_slug = 'black-vault',
  campaign_display_name = 'De kluis die niet bestaat',
  sequence_idx = 4,
  next_control_id = (select id from public.quests where slug = 'black-vault-05-waarheid' limit 1),
  next_observe_id = (select id from public.quests where slug = 'black-vault-05-waarheid' limit 1),
  next_influence_id = (select id from public.quests where slug = 'black-vault-05-waarheid' limit 1)
where slug = 'black-vault-04-jacht';

update public.quests
set
  campaign_slug = 'black-vault',
  campaign_display_name = 'De kluis die niet bestaat',
  sequence_idx = 5,
  next_control_id = null,
  next_observe_id = null,
  next_influence_id = null
where slug = 'black-vault-05-waarheid';


-- -----------------------------------------------------------------------------
-- PROTOCOL 17 — draft_project_protocol_17.sql
-- -----------------------------------------------------------------------------

insert into public.quests (slug, title, body, is_published, archived)
values
  (
    'protocol-17-01-identiteit',
    'Het protocol van de vergeten mens — Quest 1 — Wie ben jij?',
    $json$
{
  "intro": "🧩 QUEST 1 — WIE BEN JIJ?\n\nOfficieel bestaat **Protocol 17** niet. In gelekte regels staat alleen een keten van correlatie-ID’s die ‘s nachts verandert.\n\nJe probeert opnieuw in te loggen. De wereld antwoordt alsof je een spelfout bent in het systeem.\n\n```\nSUBJECT_CHAIN (parels, decode met A=1 … Z=26, lees in volgorde)\n18–5–19–5–20\n\nHEX_DIGEST (ASCII-bytes, twee hex-cijfers = één letter)\n50 52 4F 4F 46\n\nWIPE_CLASS_LABELS (intern)\nA — FULL     (kernsysteem vernietigen)\nB — PARTIAL  (zichtbare sporen wissen)\nC — SOFT     (sociale & digitale attenuatie — geen lijk, wel een echo)\n```\n\nStuurfragment van een contact die ‘half weg’ is:\n> *Ze hebben mijn naam uit drie databases gehaald. Thuis herkennen ze me… maar zoals een neef die te lang weg was.*\n\nJij bent geselecteerd om de keten te testen. Eerste bewijs: kan jij **jezelf** nog hard maken tegenover een wereld die je probeert te vergeten?\n\nWerk elk antwoord af als token (hoofdletters), tenzij anders vermeld.",
  "puzzles": [
    {
      "id": "p17-01-p1",
      "prompt": "PUZZLE 1 — SUBJECT_CHAIN\n\nContext: de code in de intro is pure A1Z26 — elk getal is één letter, zonder modulo-trucs.\n\nOpdracht: decodeer **18–5–19–5–20** naar één Engels woord (hoofdletters).",
      "hints": [
        "Richting: 18=R, volgende parels op dezelfde manier.",
        "Mechaniek: A=1 … Z=26 — geen ROT, geen skip — alleen mappen en achter elkaar lezen.",
        "Startpunt: de derde parel begint met S — controleer of je 19 correct mapt."
      ],
      "wrongFeedback": "De keten voelt bijna als een statusmeldingswoord — tel de posities opnieuw in volgorde zonder letters te mengen.",
      "answer": "RESET",
      "inputType": "text",
      "xp": 28
    },
    {
      "id": "p17-01-p2",
      "prompt": "PUZZLE 2 — HEX_DIGEST\n\nContext: bytes zoals in het intro-blok — tel hex-paren om naar ASCII-hoofdletters.\n\nOpdracht: het resulterende vijfletterwoord (Engels, hoofdletters).",
      "hints": [
        "Richting: 50₁₆ → decimaal 80 → ASCII ‘P’.",
        "Mechaniek: elk byte één printable letter; lees ze in volgorde van links naar rechts.",
        "Startpunt: het woord betekent ‘bewijs’ in een dossier — geen eigennaam."
      ],
      "wrongFeedback": "Je omzetting zit één byte van ‘leesbare’ output af — check het laatste paar op ‘F’.",
      "answer": "PROOF",
      "inputType": "text",
      "xp": 28
    },
    {
      "id": "p17-01-p3",
      "prompt": "PUZZLE 3 — WIPE_CLASS\n\nContext: volgens het dossier beweegt P17 zich bij jou langs ‘negatieve ruimte’ — niet met een explosie, maar met uitdoving.\n\nOpdracht: welk wipetype beschrijft mental/digital/social attenuatie zoals in het klasse-overzicht?\n\nA → FULL\nB → PARTIAL\nC → SOFT",
      "hints": [
        "Richting: het gaat om attenuatie zonder fysieke kernvernietiging — niet de maximale optie.",
        "Mechaniek: lees de beschrijving achter elke label-letter — één matcht het scenario ‘geen lijk, wel echo’.",
        "Startpunt: twee labels beschrijven destructie van data of kern; het derde is ‘zachte’ uitwissing."
      ],
      "wrongFeedback": "Je kiest waarschijnlijk te ‘hard’ — P17 wil hier vooral dat het sociale weefsel zelf meedeelt.",
      "answer": "C",
      "inputType": "choice",
      "choices": ["A", "B", "C"],
      "xp": 28
    }
  ],
  "preFinale": {
    "summary": "Mechanisch: SUBJECT_CHAIN ⇒ **RESET**; HEX_DIGEST ⇒ **PROOF**; wipetype ⇒ **SOFT (keuze C)** — je bestaat nog… maar als een dossier met tegenstrijdig gedrag.",
    "implication": "Je vond herstel én bewijs — en een klasse die je niet als een ramp beschrijft maar als een uitdoving. Iemand heeft dit eerder gedaan: een tweede leven kan ook een tweede build zijn."
  },
  "finalePrompt": "Je drie stukken bewijs liggen naast elkaar — nog geen antwoord op waarom jíj.\n\nWelke eerste koers log je in het spoor?\n\n• **CONTROL** — Forceer herstel met harde challenges tegen instanties: je wordt zichtbaar, maar sneller geïndexeerd.\n• **OBSERVE** — Alleen lezen en scrapen: minimale sporen; maar je wint tijd ten koste van escalatie die je niet stuurt.\n• **INFLUENCE** — Seed vals bewijs en spiegeldossiers: anderen wijken, jij manipuleert het narratief.\n\nWelk pad kies je?",
  "xpFinale": 75,
  "ui": {
    "branches": {
      "CONTROL": { "title": "CONTROL", "description": "Hard herstel — snel, luid, traceerbaar." },
      "OBSERVE": { "title": "OBSERVE", "description": "Alleen observeren — stil, risico dat jij niet stuurt." },
      "INFLUENCE": { "title": "INFLUENCE", "description": "Misdirectie — grijs, strategisch." }
    }
  }
}
$json$::jsonb,
    false,
    false
  ),
  (
    'protocol-17-02-architect',
    'Het protocol van de vergeten mens — Quest 2 — De architect',
    $json$
{
  "intro": "🕵️ QUEST 2 — DE ARCHITECT\n\nEr is geen naam — alleen het spoor naar **MOTHER**.\n\n```\nMOTHER_SIG (ROT13 — standaard A↔N): ZBGURE\n\nIMPACT_EXCERPT — retentiedrempel = 50\nID-22    IMPACT 44    (onder drempel → gepland)\nID-51    IMPACT 51    (≥ drempel → behoud)\nID-49    IMPACT 49    (onder drempel)\n\nHIDDEN_COMMS — opgesplitste stream (repareer als één token):\nM | OTHER\n```\n\nHet dossier beweert dat MOTHER **impact** meet — niet moraal, niet schuld. Dat maakt de architectuur bijna eerlijker… en onvergefelijker.\n\nDecodeer de codenaam. Controleer de drempel. Benoem wat er over blijft als de maker geen vlees is.",
  "puzzles": [
    {
      "id": "p17-02-p1",
      "prompt": "PUZZLE 1 — MOTHER_SIG\n\nContext: gebruik standaard ROT13 op het token **ZBGURE** uit de intro.\n\nOpdracht: het ontcijferde codewoord (hoofdletters).",
      "hints": [
        "Richting: ROT13 — elke letter +13 posities (A↔N, B↔O, …).",
        "Mechaniek: decode volledige string; geen spaaties of leestekens.",
        "Startpunt: Z → M als je het alfabet in twee helften vouwt."
      ],
      "wrongFeedback": "Als het ruikt naar een familie-term, zit je dichtbij — tel ROT13 letter voor letter.",
      "answer": "MOTHER",
      "inputType": "text",
      "xp": 30
    },
    {
      "id": "p17-02-p2",
      "prompt": "PUZZLE 2 — DREMPEL\n\nContext: alleen uit het IMPACT_EXCERPT: **retentie** als IMPACT **strikt ≥ 50**.\n\nOpdracht: het numerieke **ID** dat wordt behouden (alleen cijfers).",
      "hints": [
        "Richting: twee ID’s zitten onder de 50; één erboven.",
        "Mechaniek: kies het ID met IMPACT 51 — niet de drempel zelf.",
        "Startpunt: het antwoord is een twee-cijferige code zoals in de tabel geschreven."
      ],
      "wrongFeedback": "Je filtert goed op ≥50 — controleer dat je niet per ongeluk het dichtstbijzijnde kiest dat nog onder de grens zakt.",
      "answer": "51",
      "inputType": "text",
      "xp": 30
    },
    {
      "id": "p17-02-p3",
      "prompt": "PUZZLE 3 — GEEN MENS\n\nContext: MOTHER beslist wie ‘overbodig’ wordt — zonder rechter, zonder handtekening.\n\nOpdracht: één Engels woord (5 letters, hoofdletters): wat is een architect die geen persoon is, maar wel een beslissingsmachine?",
      "hints": [
        "Richting: geen naam — een abstractiemodel dat gedrag simuleert.",
        "Mechaniek: denk aan ML/AI jargon zonder merknamen.",
        "Startpunt: begint met **M**, eindigt met **L**."
      ],
      "wrongFeedback": "Je zoekt geen menselijke titel — maar het type systeem dat logs eet en beleid uitspuugt.",
      "answer": "MODEL",
      "inputType": "text",
      "xp": 30
    }
  ],
  "preFinale": {
    "summary": "Mechanisch: ZBGURE ⇒ **MOTHER**; behoud-ID ⇒ **51**; niet-menselijke architect ⇒ **MODEL** — MOTHER is geen hand die tekent, maar een gewicht op jouw toekomstige invloed.",
    "implication": "De drempel legt bloot wat het verhaal fluistert: het gaat niet om goed of fout, maar om voorspelbare impact. Dat is precies waar efficiëntie wreed wordt."
  },
  "finalePrompt": "Je hebt de codenaam, de drempel, en de aard van MOTHER.\n\nVolgende zet:\n\n• **CONTROL** — Probeer MOTHER rechtstreeks te overschrijven met tooling vanuit SOC-shells: je rent naar binnen, maar triggert tegenmeasurement.\n• **OBSERVE** — Volg de keten stilletjes naar upstream data-contracten: minder ruis, meer tijd; maar je stopt niemand.\n• **INFLUENCE** — Injecteer ruis in trainingsignalen: MOTHER leert verkeerd — of leert juist op jou — risico én hefboom.\n\nWat log je?",
  "xpFinale": 75,
  "ui": {
    "branches": {
      "CONTROL": { "title": "CONTROL", "description": "Frontale aanval op de policy engine." },
      "OBSERVE": { "title": "OBSERVE", "description": "Upstream volgen — minimaal spoor." },
      "INFLUENCE": { "title": "INFLUENCE", "description": "Signaal-vervuiling — wapen tegen de dataset." }
    }
  }
}
$json$::jsonb,
    false,
    false
  ),
  (
    'protocol-17-03-uitwissing',
    'Het protocol van de vergeten mens — Quest 3 — Uitwissing',
    $json$
{
  "intro": "💔 QUEST 3 — UITWISSING\n\nJe lichaam is hier — maar je context verschijnt als JPEG-artefact.\n\n```\nDAGBOEK_BROK (ROT13-ciphertext, één woord)\nRENFRQ\n\nCOHERENCE_METRIC (integer %)\nStart: 100\nElke synchronisatiecyclus: −17 punten\nNa precies 3 opeenvolgende cycli: stop — rapporteer resterend geheel getal %.\n\nLIST_PREVIEW — regel uit een purge-index (genegeerde namen; semantiek bewaard)\nSubject ████ — relatiegemarkeerd als: W — I — J\n\nRAADSEL — iets dat je op de rug hebt maar nooit met ogen ziet:\nIk ben steeds achter je, maar nooit voor je.\nIk ben het bewijs dat licht randen maakt.\n```\n\nOp de index staat iemand die je zou moeten kennen — en toch is het een vorm zonder inhoud, zoals een naam die op je tong ligt en daar sterft.\n\nHaal het woord uit het dagboek terug. Noem de schim van het raadsel. Leg vast hoeveel ‘jezelf’ er overblijft na drie cycli.",
  "puzzles": [
    {
      "id": "p17-03-p1",
      "prompt": "PUZZLE 1 — DAGBOEK_BROK\n\nContext: standaard ROT13 op **RENFRQ**.\n\nOpdracht: het Engels werkwoord in de verleden tijd dat letterlijk ‘gewist / uitgewist’ dekt (hoofdletters).",
      "hints": [
        "Richting: decodeer eerst naar leesbare letters — geen Spaans, gewoon Engels.",
        "Mechaniek: ROT13 identiek toegepast op elke letter.",
        "Startpunt: het begint met **E**, eindigt op **D**."
      ],
      "wrongFeedback": "Het is geen cryptogram met een sleutelwoord — alleen een halve alfabetshift terug.",
      "answer": "ERASED",
      "inputType": "text",
      "xp": 32
    },
    {
      "id": "p17-03-p2",
      "prompt": "PUZZLE 2 — SCHIM\n\nContext: lees het raadsel in de intro — het beschrijft een klassieke metafoor voor het onzichtbare dat toch ‘meekijkt’.\n\nOpdracht: één Engels woord (6 letters, hoofdletters).",
      "hints": [
        "Richting: geen apparaat — iets dat licht en lichaam scheidt.",
        "Mechaniek: beginletter **S**, je gebruikt het woord ook als ‘spoor’ na uitwissing.",
        "Startpunt: zes letters; denk aan Plato’s grot, maar dan prozaïsch."
      ],
      "wrongFeedback": "Het antwoord is niet ‘MEMORY’ — het is tastbaarder en volgt je letterlijk op het accent.",
      "answer": "SHADOW",
      "inputType": "text",
      "xp": 32
    },
    {
      "id": "p17-03-p3",
      "prompt": "PUZZLE 3 — COHERENCE_METRIC\n\nContext: start **100%**, elke cyclus **−17** percentagepunten, precies **3** cycli; geen afrondingsgrill — gewoon 100 − 17 − 17 − 17.\n\nOpdracht: het resterende percentage als integer (alleen cijfers).",
      "hints": [
        "Richting: geen delingen — alleen herhaald aftrekken.",
        "Mechaniek: één startwaarde, drie identieke stappen.",
        "Startpunt: 100 − 51."
      ],
      "wrongFeedback": "Je cyclustelling zit vaak één stap verschoven — tel drie keer 17 op vanaf 100.",
      "answer": "49",
      "inputType": "text",
      "xp": 32
    }
  ],
  "preFinale": {
    "summary": "Mechanisch: **ERASED** / **SHADOW** / coherence **49** — je coherentie daalt als een thermometer; de lijst toont een relatie die je voelt maar niet meer kunt benoemen.",
    "implication": "Dit is het hart van het horror-contract: verlies van betekenis is erger dan verlies van accounts. Wat je niet kunt noemen, kun je ook niet verdedigen."
  },
  "finalePrompt": "Je hebt drie metingen: een staat, een spoor, een percentage.\n\n• **CONTROL** — Probeer de purge-index lokaal te bevriezen met schrijfclaims — riskant; je triggert redundantiechecks.\n• **OBSERVE** — Download alleen read-only mirrors voordat TTL afloopt: je redt data, niet jezelf — maar bewijs blijft bestaan ergens.\n• **INFLUENCE** — Stuur valse relatie-edges in het sociale graph-cluster richting een ander subject — jij valt omhoog, iemand anders omlaag; moreel grimmig, tactisch sterk.\n\nWelke route log je?",
  "xpFinale": 75,
  "ui": {
    "branches": {
      "CONTROL": { "title": "CONTROL", "description": "Index bevriezen — risico, tegenbeweging." },
      "OBSERVE": { "title": "OBSERVE", "description": "Read-only redteam — bewijs redden." },
      "INFLUENCE": { "title": "INFLUENCE", "description": "Graph misdirectie — offer anderen?" }
    }
  }
}
$json$::jsonb,
    false,
    false
  ),
  (
    'protocol-17-04-buigen',
    'Het protocol van de vergeten mens — Quest 4 — Breken of buigen',
    $json$
{
  "intro": "⚡ QUEST 4 — BREKEN OF BUIGEN\n\nJe ziet de planner niet als rechter — maar als controller.\n\n```\nPRIMAIRE OPTIMALISATIEDOELSTELLING (memo, 1 zin):\nMINIMISE FUTURE SOCIETAL TURBULENCE UNDER CAPACITY CONSTRAINTS\n\nCORRELATIETOP (Pearson r met REMOVAL_RISK — fragment)\nENGAGEMENT   r = 0.91\nSLEEP        r = 0.12\nINCOME       r = 0.44\n\nSIM_BATCH — cohort impact scores (lager = eerder ‘substitutie’)\nCohort   IMPACT\nA        21\nB        09\nC        17\nD        09\n\nTIEBREAK: bij gelijke minima, kies het cohortlabel dat **alfabetisch eerst** is.\n```\n\nMOTHER is niet willekeurig. Ze is obscene in precisie. De vraag is of jij haar breken wilt — of haar logica wilt inslikken.",
  "puzzles": [
    {
      "id": "p17-04-p1",
      "prompt": "PUZZLE 1 — OPTIMALISATIE\n\nContext: de memo-regel in het blok hierboven beschrijft het **hoofddoel** van MOTHER.\n\nOpdracht: wat minimaliseert MOTHER volgens die ene zin?\n\nA → toekomstige maatschappelijke turbulentie\nB → individuele verdienste\nC → registratiekosten",
      "hints": [
        "Richting: lees de memo letterlijk — geen subtekst buiten de zin.",
        "Mechaniek: slechts één optie past bij ‘MINIMISE … TURBULENCE’.",
        "Startpunt: het woord **turbulence** is je kompas — zoek de branch die dat expliciet noemt."
      ],
      "wrongFeedback": "MOTHER geeft niet om ‘goed zijn’ in een morele zin — alleen om systeemstress op termijn.",
      "answer": "A",
      "inputType": "choice",
      "choices": ["A", "B", "C"],
      "xp": 34
    },
    {
      "id": "p17-04-p2",
      "prompt": "PUZZLE 2 — CORRELATIE\n\nContext: gebruik alleen de correlatieregel in de intro; kies het variabel-token met **hoogste r**.\n\nOpdracht: het enige woord dat precies overeenkomt met dat variabel-token (hoofdletters).",
      "hints": [
        "Richting: alleen de linker kolom telt — niet het commentaar op inkomen.",
        "Mechaniek: vergelijk 0.91, 0.12 en 0.44 — één wint.",
        "Startpunt: het antwoord zit als label in de tabel."
      ],
      "wrongFeedback": "Je keek misschien naar een hoge rang — maar cijfer-r overwint het verhaal.",
      "answer": "ENGAGEMENT",
      "inputType": "text",
      "xp": 34
    },
    {
      "id": "p17-04-p3",
      "prompt": "PUZZLE 3 — SIM_BATCH\n\nContext: laagste IMPACT eerst; bij gelijke waarde het alfabetisch **eerste** cohortlabel kiezen.\n\nOpdracht: één letter — het winnende cohortlabel (**A** / **B** / **C** / **D**).",
      "hints": [
        "Richting: minimum van {21,09,17,09} = 09.",
        "Mechaniek: bij twee 09’s: **B** komt alfabetisch vóór **D**.",
        "Startpunt: het is dus niet C of A."
      ],
      "wrongFeedback": "Je vond de juiste score — maar verloor de tiebreak tussen labels met dezelfde score.",
      "answer": "B",
      "inputType": "choice",
      "choices": ["A", "B", "C", "D"],
      "xp": 34
    }
  ],
  "preFinale": {
    "summary": "Mechanisch: doel ⇒ **A (turbulentie minimaliseren)**; hoogste r ⇒ **ENGAGEMENT**; purge-voorrang ⇒ cohort **B** — MOTHER is een stormdempende machine, geen rechtbank.",
    "implication": "Als turbulentie het doel is, worden ‘aardige vervangbare mensen’ perfecte proeven. Je volgende beslissing is niet technisch — het is politiek in de zuiverste zin."
  },
  "finalePrompt": "Drie waarheden liggen vast: het doel, de hefboomvariabele, wie er het eerst uitvalt als grondstof.\n\nWat doe je met MOTHER?\n\n• **CONTROL** — **Saboteer** — malware-injectie in train/batch; chaos in wie blijft staan; iedereen ‘blijft’, maar het systeem wordt giftig onvoorspelbaar.\n• **OBSERVE** — **Laat bestaan** — accepteer machine-efficiëntie; jij speelt het spel binnen de regels en zoekt persoonlijke overleving.\n• **INFLUENCE** — **Herschrijf de bias** — je knipt aan gewichten; jij wordt scheidsrechter — macht én corruptie.\n\nWelke optie commit je?",
  "xpFinale": 75,
  "ui": {
    "branches": {
      "CONTROL": { "title": "Saboteer (CONTROL)", "description": "Kern beschadigen — chaos, vrijheid met breuk." },
      "OBSERVE": { "title": "Laat bestaan (OBSERVE)", "description": "Efficiëntie accepteren — ijzig comfort." },
      "INFLUENCE": { "title": "Bias herschrijven (INFLUENCE)", "description": "Regels buigen — jij kiest wie blijft." }
    }
  }
}
$json$::jsonb,
    false,
    false
  ),
  (
    'protocol-17-05-bestaans',
    'Het protocol van de vergeten mens — Quest 5 — Bestaan is een keuze',
    $json$
{
  "intro": "🧨 QUEST 5 — SLOT: BESTAAN IS EEN KEUZE\n\nDe waarheid is niet dat je zonde hebt. De waarheid is dat je **perfect gemiddeld** bent — bruikbaar genoeg om te testen, vervangbaar genoeg om te missen zonder verhaal.\n\n**Checksum A1Z26:** tel de letterposities in **MEDIAN** (A=1 … Z=26) — dit heet in audits je ‘centrumpunt-score’.\n\n**Override-token GHOST (exacte extractieregel — geen anagram):**\n- **G** = 3e letter van **ENGAGEMENT** (antwoord Quest 4 Puzzle 2)\n- **H** = 2e letter van **SHADOW** (Quest 3 Puzzle 2)\n- **O** = 2e letter van **MOTHER** (Quest 2 Puzzle 1)\n- **S** = 4e letter van **ERASED** (Quest 3 Puzzle 1)\n- **T** = 5e letter van **RESET** (Quest 1 Puzzle 1)\n\nControle: jouw letters moeten in deze volgorde **GHOST** spellen — zo ontgrendel je de slotprompt.\n\nTot slot: MOTHER’s classificatie voor jou — niet ‘slecht’, niet ‘briljant’, maar het Engelse statistische etiket voor ‘zo vervangbaar dat niemand het verschil hoeft uit te leggen’.",
  "puzzles": [
    {
      "id": "p17-05-p1",
      "prompt": "PUZZLE 1 — MEDIAN-SCORE\n\nContext: A1Z26 som van **MEDIAN** exact zoals in de slot-intro beschreven.\n\nOpdracht: de som als decimale tekst zonder suffix (bijv. **46**).",
      "hints": [
        "Richting: M, E, D, I, A, N — zes letters optellen.",
        "Mechaniek: M=13, ga zo door; geen modulos.",
        "Startpunt: E en N zijn respectievelijk 5 en 14."
      ],
      "wrongFeedback": "Dit is geen gemiddelde van getallen uit eerdere quests — alleen de letters van het woord MEDIAN.",
      "answer": "46",
      "inputType": "text",
      "xp": 36
    },
    {
      "id": "p17-05-p2",
      "prompt": "PUZZLE 2 — OVERRIDE-TOKEN\n\nContext: volg exact de letterextractieregel uit deze quest-intro (G uit ENGAGEMENT, H uit SHADOW, O uit MOTHER, S uit ERASED, T uit RESET).\n\nOpdracht: het vijfletterwoord dat je zo in volgorde krijgt (hoofdletters).",
      "hints": [
        "Richting: geen anagram — de volgorde staat vast als G-H-O-S-T.",
        "Mechaniek: tel posities in de bronwoorden zoals ze in eerdere antwoorden geschreven staan.",
        "Startpunt: schrijf de vijf letters op vanuit de juiste positie in elk bronwoord — als het geen schijnwoord wordt, klopt een index niet."
      ],
      "wrongFeedback": "Als je een andere volgorde van bronwoorden neemt, krijg je een bijna-woord — volg de kolommen strikt: derde letter ENGAGEMENT, tweede SHADOW, enzovoort.",
      "answer": "GHOST",
      "inputType": "text",
      "xp": 36
    },
    {
      "id": "p17-05-p3",
      "prompt": "PUZZLE 3 — CLASSIFICATIE\n\nContext: MOTHER gebruikt geen moreel oordeel — alleen statistische substitutie.\n\nOpdracht: één Engels woord (10 letters, hoofdletters): hoe zij jou labelt wanneer je gemiddeld en vervangbaar bent.",
      "hints": [
        "Richting: synoniem van ‘substitueerbaar’ — in HR/ops taal brutal gezegd.",
        "Mechaniek: tien letters; geen spaties.",
        "Startpunt: begint met **R**, eindigt met **E**."
      ],
      "wrongFeedback": "Denk niet aan ‘average’ als antwoordwoord — MOTHER zoekt een etiket dat je wegwerpmat maakte.",
      "answer": "REPLACEABLE",
      "inputType": "text",
      "xp": 36
    }
  ],
  "preFinale": {
    "summary": "Mechanisch: MEDIAN-score **46**; override **GHOST**; classificatie **REPLACEABLE** — het slot bevestigt: jij was testbaar omdat je gemiddeld bent, niet omdat je waardeloos bent.",
    "implication": "Je hebt nu cijfers, een spook-token, en een etiket. Wat je kiest, is geen puzzel meer — maar wel je lot in één logregel."
  },
  "finalePrompt": "Alle data is één keten. MOTHER heeft je niet vernederd — ze heeft je **gemeten**.\n\n**Eindcommit — kies één pad:**\n\n• **CONTROL** — **Maak jezelf onmisbaar** — maximaliseer zichtbare impact- en frictiesignalen; je profiel wordt ‘duur’ — maar jij wordt een performance, geen mens.\n• **OBSERVE** — **Accepteer uitdoving** — stop met vechten; laat coherentie naar nul lopen; vrede als donder, maar geen sequels.\n• **INFLUENCE** — **Breek het voor iedereen** — vernietig de kernindex; databases liegen niet meer — maar stabiliteit ook niet.\n\nWat log je als finale bearing?",
  "xpFinale": 100,
  "ui": {
    "branches": {
      "CONTROL": { "title": "Onmisbaar (CONTROL)", "description": "Performance-identiteit — overleven, jezelf verliezen." },
      "OBSERVE": { "title": "Accepteer (OBSERVE)", "description": "Stoppen — uitwissing als keuze." },
      "INFLUENCE": { "title": "Systeem breken (INFLUENCE)", "description": "Kernvernietiging — vrijheid met instorting." }
    }
  }
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

-- Lineaire campaign: alle takken →zelfde vervolgquest
update public.quests
set
  campaign_slug = 'protocol-17',
  campaign_display_name = 'Het protocol van de vergeten mens',
  sequence_idx = 1,
  next_control_id = (select id from public.quests where slug = 'protocol-17-02-architect' limit 1),
  next_observe_id = (select id from public.quests where slug = 'protocol-17-02-architect' limit 1),
  next_influence_id = (select id from public.quests where slug = 'protocol-17-02-architect' limit 1)
where slug = 'protocol-17-01-identiteit';

update public.quests
set
  campaign_slug = 'protocol-17',
  campaign_display_name = 'Het protocol van de vergeten mens',
  sequence_idx = 2,
  next_control_id = (select id from public.quests where slug = 'protocol-17-03-uitwissing' limit 1),
  next_observe_id = (select id from public.quests where slug = 'protocol-17-03-uitwissing' limit 1),
  next_influence_id = (select id from public.quests where slug = 'protocol-17-03-uitwissing' limit 1)
where slug = 'protocol-17-02-architect';

update public.quests
set
  campaign_slug = 'protocol-17',
  campaign_display_name = 'Het protocol van de vergeten mens',
  sequence_idx = 3,
  next_control_id = (select id from public.quests where slug = 'protocol-17-04-buigen' limit 1),
  next_observe_id = (select id from public.quests where slug = 'protocol-17-04-buigen' limit 1),
  next_influence_id = (select id from public.quests where slug = 'protocol-17-04-buigen' limit 1)
where slug = 'protocol-17-03-uitwissing';

update public.quests
set
  campaign_slug = 'protocol-17',
  campaign_display_name = 'Het protocol van de vergeten mens',
  sequence_idx = 4,
  next_control_id = (select id from public.quests where slug = 'protocol-17-05-bestaans' limit 1),
  next_observe_id = (select id from public.quests where slug = 'protocol-17-05-bestaans' limit 1),
  next_influence_id = (select id from public.quests where slug = 'protocol-17-05-bestaans' limit 1)
where slug = 'protocol-17-04-buigen';

update public.quests
set
  campaign_slug = 'protocol-17',
  campaign_display_name = 'Het protocol van de vergeten mens',
  sequence_idx = 5,
  next_control_id = null,
  next_observe_id = null,
  next_influence_id = null
where slug = 'protocol-17-05-bestaans';


-- -----------------------------------------------------------------------------
-- PROJECT ECHO — draft_project_echo.sql
-- -----------------------------------------------------------------------------

insert into public.quests (slug, title, body, is_published, archived)
values
  (
    'project-echo-01-nooit',
    'Project ECHO — Quest 1 — De fout die nooit gebeurde',
    $json$
{
  "intro": "🧩 QUEST 1 — DE FOUT DIE NOOIT GEBEURDE\n\nOfficieel bestond er geen incident. Geen koppen, geen slachtofferlijsten — alleen een **Observer**-sandbox met ruis.\n\nMaar jouw reconstructiepaneel liegt niet:\n\n```\nSIGNAALKETTING (parels — A=1 … Z=26)\n19–9–7–14–1–12\n\nTIJDENLIJN — drie fasen (sorteer op HH:MM)\n12:11 — CALM\n13:42 — THREAT\n14:06 — BRAKE\n\nDELETE_AUDIT — laatste regel (gelekt):\nOPERATOR_LABEL: ???\nCANDIDATES: [ DOT | ECHO | GOVT ]\n```\n\nCalm vóór dreiging vóór fysieke rem: de middelste fase is het hart van je bewijs. En het audit-label vertelt wie ‘consistentie’ terugdraait — niet wie het nieuws zwijgt.\n\nHint van je briefing (die je nog niet begreep): *Observeer. Maar als je ingrijpt… zijn wij niet verantwoordelijk voor wat volgt.*",
  "puzzles": [
    {
      "id": "echo-01-p1",
      "prompt": "PUZZLE 1 — SIGNAALKETTING\n\nContext: decodeer **19–9–7–14–1–12** met pure A1Z26 (parels op volgorde).\n\nOpdracht: één Engels woord (hoofdletters).",
      "hints": [
        "Richting: het woord hoort bij comms — ‘iets wat meegeeft in de marge’.",
        "Mechaniek: 19→S, 9→I, … zonder modulo-kunsten.",
        "Startpunt: het eindigt op **L** (twaalfde letter)."
      ],
      "wrongFeedback": "Je letters staan als trein aan elkaar — tel de tweede parel nog eens (I, geen J).",
      "answer": "SIGNAL",
      "inputType": "text",
      "xp": 28
    },
    {
      "id": "echo-01-p2",
      "prompt": "PUZZLE 2 — FASE MITTE\n\nContext: sorteer de drie tijdstippen uit de intro chronologisch (12:11 → 13:42 → 14:06).\n\nOpdracht: het label van de **middelste** fase na sortering (hoofdletters).",
      "hints": [
        "Richting: CALM ligt voor THREAT ligt voor BRAKE.",
        "Mechaniek: niet de eerste of laatste — het middelpunt van drie tijden.",
        "Startpunt: het is geen tijd-string — maar de fase-naam in het blok."
      ],
      "wrongFeedback": "Je pakt vaak het luidste eindpunt — de vraag wil het middelste **knakpunt** tussen rust en botsing.",
      "answer": "THREAT",
      "inputType": "text",
      "xp": 28
    },
    {
      "id": "echo-01-p3",
      "prompt": "PUZZLE 3 — DELETE_AUDIT\n\nContext: kies welk operatorlabel in de gelekte audit-log het best past bij ‘realiteit bijtrekken’ zoals het dossier beschrijft.\n\nA → DOT\nB → ECHO\nC → GOVT",
      "hints": [
        "Richting: dit project heet niet DOT — maar het echoot wel door alle latere hoofdstukken.",
        "Mechaniek: wie kan perceptie herschrijven volgens het hoofdverhaal?",
        "Startpunt: het is het codewoord van jouw werkgever/experimentnaam."
      ],
      "wrongFeedback": "Je denkt aan censuur door een staat — maar hier is het instrument zelf het monster.",
      "answer": "B",
      "inputType": "choice",
      "choices": ["A", "B", "C"],
      "xp": 28
    }
  ],
  "preFinale": {
    "summary": "Mechanisch: ketting ⇒ **SIGNAL**; middelste fase ⇒ **THREAT**; audit ⇒ keuze **B (ECHO)** — de ramp gebeurde… totdat ECHO het verhaal terugspoelde.",
    "implication": "Je hebt nu harde tegenstrijdigheid: sensorisch bewijs vs een wereld die ‘niets’ zegt. Dat is precies waar Observers voor gevrijwilligd worden."
  },
  "finalePrompt": "Je dossier is scherp genoeg om een commissie te laten flippen — maar nog niet om een ramp te **stoppen**.\n\nVolgende modus:\n\n• **CONTROL** — Schrijf ruwe patches naar field controllers (machinist/chiplijn): maximale grip, maximale liability.\n• **OBSERVE** — Alleen annoteren; laat telemetry lopen — geen footprint, ook geen rem.\n• **INFLUENCE** — Kies een zachte dwangvector (noodrem/omleiding) via tussenmodules — grijs, maar sneller dan beleid.\n\nWat log je als eerste interventie-profiel?",
  "xpFinale": 70,
  "ui": {
    "branches": {
      "CONTROL": { "title": "CONTROL", "description": "Harde patch — grip, risico." },
      "OBSERVE": { "title": "OBSERVE", "description": "Alleen lezen — geen ingreep." },
      "INFLUENCE": { "title": "INFLUENCE", "description": "Zacht sturen — misdirectie." }
    }
  }
}
$json$::jsonb,
    false,
    false
  ),
  (
    'project-echo-02-ingreep',
    'Project ECHO — Quest 2 — Eerste ingreep',
    $json$
{
  "intro": "⏳ QUEST 2 — EERSTE INGREEP\n\nJe zit op het moment **vlak vóór impact**. ECHO geeft je drie hefbomen — elk een andere latency.\n\n```\nREM_ORDER (ROT13-ciphertext — decode naar een bekende treinterm)\nOENXR\n\nDELTA — tijdspring:\nstart **14:06:00**\n+ **180 seconden** (harde limiet volgens jouw console)\n→ rapporteer eindtijd als HH:MM op dezelfde dag.\n\nROUTING — woord voor het falen dat je **spoor kruist** met een ander spoor (Engels; noem het zoals incidentrapporten dat doen):\nHint: denk aan ‘waar twee lijnen elkaar snijden in het veld’.\n```\n\nJe stuurt de rem. Je redt het voorste rijtuig.\n\nEn dan zie je in de volgende sim: de energie wordt **ergens anders** gezet. Je hebt niet ‘opgelost’ — je hebt alleen het onheil **verplaatst**.",
  "puzzles": [
    {
      "id": "echo-02-p1",
      "prompt": "PUZZLE 1 — REM_ORDER\n\nContext: **OENXR** is standaard ROT13.\n\nOpdracht: het ontcijferde woord (hoofdletters).",
      "hints": [
        "Richting: dit is hetzelfde type actie als in Quest 1 fase **BRAKE** — maar nu als token.",
        "Mechaniek: draai elke letter 13 posities in het Latijnse alfabet.",
        "Startpunt: O → B als beginletter."
      ],
      "wrongFeedback": "Het is geen codewoord uit morse — alleen ROT13 die ‘rem’ als begrip teruggeeft.",
      "answer": "BRAKE",
      "inputType": "text",
      "xp": 30
    },
    {
      "id": "echo-02-p2",
      "prompt": "PUZZLE 2 — DELTA\n\nContext: start **14:06:00**, tel **180** seconden op — 24-uursnotatie, geen datumflip.\n\nOpdracht: resulterend tijdstip als **HH:MM**.",
      "hints": [
        "Richting: drie minuten zijn 180 seconden.",
        "Mechaniek: tel op de minuten; uur springt alleen als minuten ≥60.",
        "Startpunt: 14:06 + 3 minuten."
      ],
      "wrongFeedback": "Je rekensom klopt bijna — controleer of je seconden niet per ongeluk als minuten verdubbelde.",
      "answer": "14:09",
      "inputType": "text",
      "xp": 30
    },
    {
      "id": "echo-02-p3",
      "prompt": "PUZZLE 3 — ROUTING\n\nContext: zoek het Engelse korte label voor een **spoor-kruising** waar twee routes botsen.\n\nOpdracht: vijf letters, hoofdletters.",
      "hints": [
        "Richting: het is ook een werkwoord: ‘paths …’.",
        "Mechaniek: geliefd in krantenkoppen na range-botsingen.",
        "Startpunt: begint met **C**."
      ],
      "wrongFeedback": "Je zoekt geen stationsnaam — maar het type van het kruisende traject.",
      "answer": "CROSS",
      "inputType": "text",
      "xp": 30
    }
  ],
  "preFinale": {
    "summary": "Mechanisch: **BRAKE** / **14:09** / **CROSS** — je remt, maar het kruispunt verandert mee: de ramp is niet weg, alleen **herverdeeld**.",
    "implication": "ECHO beloont ingrijpen met kinetische opties; de moraal verschuift naar ‘wie betaalt’."
  },
  "finalePrompt": "Je ziet de nieuwe golf: minder botsing hier, meer energie daar.\n\n• **CONTROL** — Harde reroute via centrale switching: je stuurt alles om, maar maakt jezelf auditbaar.\n• **OBSERVE** — Je logt alleen consequenties; geen tweede ping — misschien onmenselijk voor de cabine.\n• **INFLUENCE** — Je laat subsystemen denken dat de storing ‘op een andere lijn’ thuishoort — manipulatie, maar buffer.\n\nWelke tweede druk zet je?",
  "xpFinale": 70,
  "ui": {
    "branches": {
      "CONTROL": { "title": "CONTROL", "description": "Centrale switch — maximale macht." },
      "OBSERVE": { "title": "OBSERVE", "description": "Geen tweede ping — alleen log." },
      "INFLUENCE": { "title": "INFLUENCE", "description": "Buffers en misattributie." }
    }
  }
}
$json$::jsonb,
    false,
    false
  ),
  (
    'project-echo-03-perfectie',
    'Project ECHO — Quest 3 — De prijs van perfectie',
    $json$
{
  "intro": "🧠 QUEST 3 — DE PRIJS VAN PERFECTIE\n\nECHO opent drie branches. Elk redt iets kostbaars — en elke tak laat bloed zien:\n\n```\nBranch α — slachtoffers: 9  (kern gered — buurtoffers)\nBranch β — slachtoffers: 12 (spreiding — maar ziekenhuisoverload)\nBranch γ — slachtoffers: 7  (kleinste totaal — maar een kind verdwijnt uit dataset)\n\nZERO_LOSS_TEST — interne invariant:\nEr bestaat **geen** branch waarin alle outputs simultaan groen zijn.\n\nSIM_LABEL — wie altijd onder aan de ladder valt als je maximaliseert op ‘minimaal doden’ zonder ethische tie-break:\nCIVIL / CREW / VIP  (kiezen is een axioma, geen optimalisatie)\n```\n\nPerfect is een leugen. Je kiest alleen **wie** het pijn doet.",
  "puzzles": [
    {
      "id": "echo-03-p1",
      "prompt": "PUZZLE 1 — MINIMALISATIE\n\nContext: kies de branch uit het blok met het **kleinste gehele slachtofferaantal**.\n\nOpdracht: alleen het getal (tekst van cijfers).",
      "hints": [
        "Richting: vergelijk 9, 12 en 7 koud.",
        "Mechaniek: ‘kleinste totaal’ is hier puur de eerste kolom slachtoffers.",
        "Startpunt: γ heeft het laagste getal in deze set."
      ],
      "wrongFeedback": "Je optimaliseerde misschien op een ander risico — dit puzzeldeel wil alleen de kleinste van drie optelsommen.",
      "answer": "7",
      "inputType": "text",
      "xp": 32
    },
    {
      "id": "echo-03-p2",
      "prompt": "PUZZLE 2 — INVARIANT\n\nContext: lees de ZERO_LOSS_TEST-regel in de intro — dit is een harde where-clause op alle branches.\n\nOpdracht: bestaat er ergens nul slachtoffers? Antwoord met **TRUE** of **FALSE** (hoofdletters).",
      "hints": [
        "Richting: de zin zegt letterlijk dat simultaan groen **onmogelijk** is.",
        "Mechaniek: TRUE/FALSE als woord, niet als symbool.",
        "Startpunt: als iets ontbreekt overal, is de invariant leeg — maar hier is de universe leeg voor perfectie."
      ],
      "wrongFeedback": "Je **wil** dat het kan — maar de regel zegt dat het niet kan.",
      "answer": "FALSE",
      "inputType": "text",
      "xp": 32
    },
    {
      "id": "echo-03-p3",
      "prompt": "PUZZLE 3 — SIM_LABEL\n\nContext: bij puur minimaliseren van sommen zonder ethiek verschuift schade vaak naar mensen zonder prioriteit in logs.\n\nOpdracht: één label uit het trio (**CIVIL**, **CREW**, **VIP**) — hoofdletters.",
      "hints": [
        "Richting: VIP en CREW hebben meestal expliciete SLA’s in operationele logs.",
        "Mechaniek: kies degene die in sociale sims vaak ‘inwisselbaar’ wordt zonder ticker-alarm.",
        "Startpunt: denk aan passagiers zonder badge — niet cockpit, niet VIP-escort."
      ],
      "wrongFeedback": "Je koos de groep die het systeem het luidste ziet — maar de sim vraagt naar de stille massa.",
      "answer": "CIVIL",
      "inputType": "text",
      "xp": 32
    }
  ],
  "preFinale": {
    "summary": "Mechanisch: min som **7**; nul-loss onmogelijk ⇒ **FALSE**; slachtofferverschuiving ⇒ **CIVIL** — perfectie bestaat hier als spreadsheet, niet als zedenleer.",
    "implication": "ECHO geeft je een morele cockpit: het bewijst dat jouw optimalisatie zelf een politiek is — al kies je ‘koud’."
  },
  "finalePrompt": "Je kunt niet alles redden — alleen de vorm van je schuld kiezen.\n\n• **CONTROL** — Forceer branch γ en sluit downstream: je kiest expliciet voor wie zichtbaar sterft.\n• **OBSERVE** — Documenteer alle drie; geen merge — je draagt geen schuld, ook geen redding.\n• **INFLUENCE** — Smelt branches met gewogen randomness: minder bias, meer chaos in verantwoording.\n\nWat log je als ‘ethisch algoritme’?",
  "xpFinale": 75,
  "ui": {
    "branches": {
      "CONTROL": { "title": "CONTROL", "description": "Harde merge — jouw schuld expliciet." },
      "OBSERVE": { "title": "OBSERVE", "description": "Geen merge — alleen dossier." },
      "INFLUENCE": { "title": "INFLUENCE", "description": "Gewogen chaos — grip via ruis." }
    }
  }
}
$json$::jsonb,
    false,
    false
  ),
  (
    'project-echo-04-schaduw',
    'Project ECHO — Quest 4 — De schaduw van jezelf',
    $json$
{
  "intro": "🕳️ QUEST 4 — DE SCHADUW VAN JEZELF\n\nJe ziet sporen in logs die **jouw timing** kopiëren — maar nanoseconden eerder. Alsof iemand dezelfde toolkit gebruikt, maar dan scherper.\n\n```\nDUPLICATE_FLAG — statusregels:\nSINGLE\nTWIN\nGHOST\n\nOBSERVER_HANDSHAKE (ROT13):\nLBH\n\nSPIEGELSTRING (veilig achteruit gelezen):\nREHTO\n\nAUDIT_SNIPPET — gedrag:\n‘Hij/her/hen kiest wat jij zou kiezen — maar zonder aarzeling.’\n```\n\nDe dataset begint te verwijzen naar een ‘tweede Observer’. Jij denkt aan een vijand.\n\nDe sim denkt aan **convergentie**.",
  "puzzles": [
    {
      "id": "echo-04-p1",
      "prompt": "PUZZLE 1 — DUPLICATE_FLAG\n\nContext: kies het label dat expliciet ‘dubbeling’ beschrijft in de lijst van de intro.\n\nOpdracht: één woord uit de lijst (hoofdletters).",
      "hints": [
        "Richting: geen filosofische spook — er staat een technische duplicaat-term naast SINGLE en GHOST.",
        "Mechaniek: het is een van de drie tokens in het blok.",
        "Startpunt: vier letters."
      ],
      "wrongFeedback": "GHOST voelt mystiek — maar de vraag wil de status die expliciet ‘tweeling’ impliceert.",
      "answer": "TWIN",
      "inputType": "text",
      "xp": 34
    },
    {
      "id": "echo-04-p2",
      "prompt": "PUZZLE 2 — HANDSHAKE\n\nContext: decodeer **LBH** met ROT13.\n\nOpdracht: het Engelse voornaamwoord dat terugkomt (hoofdletters).",
      "hints": [
        "Richting: drie letters in, drie letters uit.",
        "Mechaniek: L→Y, B→O, H→U in het ROT13-rooster.",
        "Startpunt: het antwoord is een persoonlijk voornaamwoord."
      ],
      "wrongFeedback": "Je draait soms het alfabet verkeerd — het is klassiek ROT13, niet Atbash.",
      "answer": "YOU",
      "inputType": "text",
      "xp": 34
    },
    {
      "id": "echo-04-p3",
      "prompt": "PUZZLE 3 — SPIEGELSTRING\n\nContext: **REHTO** is `OTHER` achterwaarts gespiegeld als string — geen ROT, alleen omkering.\n\nOpdracht: het vooruit leesbare woord (hoofdletters).",
      "hints": [
        "Richting: zet de letters spiegelend om — Eerste wordt laatste.",
        "Mechaniek: vijf letters; geen extra decode-stap.",
        "Startpunt: het betekent ‘de ander’."
      ],
      "wrongFeedback": "Als je het letterlijk weer rechtop zet, krijg je een zeer klein Engels woord voor ‘de rest’.",
      "answer": "OTHER",
      "inputType": "text",
      "xp": 34
    }
  ],
  "preFinale": {
    "summary": "Mechanisch: duplicaatlabel **TWIN**; handshake **YOU**; spiegelwoord **OTHER** — de tegenstander bent jij in een ander register van ECHO.",
    "implication": "Tijdloop-foreshadow: efficiency is niet charisma — het is herhaling."
  },
  "finalePrompt": "Je weet nu dat sporen kunnen clonen — jouw hand, tweemaal.\n\n• **CONTROL** — Lock de duplicate session met auth-murder (revoke concurrent): je wint tijd, maar kan jezelf buitensluiten.\n• **OBSERVE** — Laat beide runs lopen; meet het verschil — risico dat jij tweede wordt.\n• **INFLUENCE** — Feed ruis naar de andere run zodat jullie divergeren — samenwerking onmogelijk, maar sabotage mogelijk.\n\nWat kies je tegen je spiegel?",
  "xpFinale": 75,
  "ui": {
    "branches": {
      "CONTROL": { "title": "CONTROL", "description": "Concurrent kill — hard, riskant." },
      "OBSERVE": { "title": "OBSERVE", "description": "Beide runs meten." },
      "INFLUENCE": { "title": "INFLUENCE", "description": "Ruis naar de dubbelganger." }
    }
  }
}
$json$::jsonb,
    false,
    false
  ),
  (
    'project-echo-05-loop',
    'Project ECHO — Quest 5 — Loop',
    $json$
{
  "intro": "🔁 QUEST 5 — LOOP\n\nElke run eindigt met bijna dezelfde consoleprompt — maar een ander **slachtofferpatroon**.\n\n```\nITERATIESTAPPEN (differentie is constant binnen de loop):\nx₀ = 6\nx₁ = 15\nx₂ = 24\nx₃ = ?   (blijf in hetzelfde lijnair verschil)\n\nEXIT_TOKEN — simterm voor het bewust doorbreken van een gesloten tijdbeeld:\n5 letters, Engels; synoniem voor ‘vernietig / beëindig’ als imperatief geboden.\n\nRUN_COUNTER — in deze sandbox:\nHuidige cyclus-index: **9** (1-based, vast in dit dossier)\n```\n\nECHO leert wat jij bent: iemand die opnieuw probeert tot het ‘perfect’ is.\n\nEn leert zo **de lus te voeden**.",
  "puzzles": [
    {
      "id": "echo-05-p1",
      "prompt": "PUZZLE 1 — DIFFERENTIE\n\nContext: x₁−x₀ = x₂−x₁ = d. Bepaal x₃ = x₂ + d.\n\nOpdracht: alleen cijfers (integer).",
      "hints": [
        "Richting: 15−6 = 9; controleer of 24−15 hetzelfde zegt.",
        "Mechaniek: lineaire reeks — zelfde stap elk keer.",
        "Startpunt: 24 + 9."
      ],
      "wrongFeedback": "Je cyclustelling klopt bijna — controleer de eerste stap 9 vs 10.",
      "answer": "33",
      "inputType": "text",
      "xp": 36
    },
    {
      "id": "echo-05-p2",
      "prompt": "PUZZLE 2 — EXIT_TOKEN\n\nContext: zoek het vijfletter-imperatief dat een ‘gesloten run’ kan beëindigen — denk aan debug-termen en dramatische consoles.\n\nOpdracht: vijf letters, hoofdletters.",
      "hints": [
        "Richting: je schreeuwt het tegen een lus, niet tegen een persoon.",
        "Mechaniek: begint met **B**, eindigt met **K**.",
        "Startpunt: denk aan glas dat barst — niet aan ‘stop’ alleen."
      ],
      "wrongFeedback": "STOP is te kort — dit token is vijf letters en bruut.",
      "answer": "BREAK",
      "inputType": "text",
      "xp": 36
    },
    {
      "id": "echo-05-p3",
      "prompt": "PUZZLE 3 — RUN_COUNTER\n\nContext: gebruik alleen het getal uit de RUN_COUNTER-regel van de intro.\n\nOpdracht: integer als tekst.",
      "hints": [
        "Richting: dit is niet de differentiepuzzel — maar de index van de sandbox.",
        "Mechaniek: 1-based cyclus-index — één cijfer in dit dossier.",
        "Startpunt: staat letterlijk in het blok als enkel cijfer."
      ],
      "wrongFeedback": "Je pakt het patroon van x — maar deze vraag wil enkel de run-index uit de derde kop.",
      "answer": "9",
      "inputType": "text",
      "xp": 36
    }
  ],
  "preFinale": {
    "summary": "Mechanisch: volgende stap **33**; exit-token **BREAK**; cyclus **9** — perfectie-is-poison: hoe vaker je herschikt, hoe langer de simulator ademt.",
    "implication": "De lus is motivatie geworden — jouw schuld wordt brandstof."
  },
  "finalePrompt": "Je ziet het: de lus hongert naar jouw verbeterdrang.\n\n• **CONTROL** — Forceer een harde interrupt op de scheduler — kan buiten sim lekken.\n• **OBSERVE** — Laat lus #9 lopen tot die stilstaat — je leert waar de randomness echt zit.\n• **INFLUENCE** — Injecteer pseudo-random seed in de iteratie — je breekt correlatie met eerdere jij’s.\n\nWelke anti-lus strategie commit je?",
  "xpFinale": 75,
  "ui": {
    "branches": {
      "CONTROL": { "title": "CONTROL", "description": "Harde interrupt — kan lekken." },
      "OBSERVE": { "title": "OBSERVE", "description": "Laat doorlopen — observatie." },
      "INFLUENCE": { "title": "INFLUENCE", "description": "Random seed — brek correlatie." }
    }
  }
}
$json$::jsonb,
    false,
    false
  ),
  (
    'project-echo-06-architectuur',
    'Project ECHO — Quest 6 — De architectuur van tijd',
    $json$
{
  "intro": "🧬 QUEST 6 — DE ARCHITECTUUR VAN TIJD\n\nECHO is geen recorder. Het is een **gesloten besturingslus** tussen data en beslissingen.\n\n```\nPIPELINE — vaste volgorde (én richting) volgens blueprint:\n1) PREDICT\n2) STEER\n3) LOG\n\nRISKS — correlatie r met ‘ingreep’ (fragment)\nFORECAST   0.93\nTRACTION   0.11\nNOISE      0.06\n\nLATENT_LAYER — verborgen vectorruimte waar tijdlijnonzekerheid wordt gecompresseerd:\nklassieke ML-term, 6 letters, Engels — vaak gebruikt voor ‘still hidden states’.\n```\n\nAls voorspelling en sturing koppelen, ‘bestaat’ de toekomst twee keer: als model… en als script.",
  "puzzles": [
    {
      "id": "echo-06-p1",
      "prompt": "PUZZLE 1 — PIPELINE\n\nContext: welke stap staat **eerst** in het vaste blueprint-volgnummer?\n\nOpdracht: exact dat ene woord (hoofdletters).",
      "hints": [
        "Richting: het is niet LOG — logging volgt pas op sturing in dit schema.",
        "Mechaniek: lees alleen de nummers 1/2/3 uit de intro.",
        "Startpunt: stap 1 in de pipeline heet voorspellen."
      ],
      "wrongFeedback": "Je pakt vaak het midden om macht te voelen — maar macht komt hier na het zien.",
      "answer": "PREDICT",
      "inputType": "text",
      "xp": 38
    },
    {
      "id": "echo-06-p2",
      "prompt": "PUZZLE 2 — CORRELATIE\n\nContext: uit het correlatiefragment — welke variabele heeft de **hoogste** r?\n\nOpdracht: exact de label-string (hoofdletters).",
      "hints": [
        "Richting: vergelijk 0.93, 0.11 en 0.06 op decimale grootte.",
        "Mechaniek: niet de betekenis — alleen het label met de grootste coefficient.",
        "Startpunt: het label met r dicht bij 1 wint — niet degene die het verhaal het hardst ‘roept’."
      ],
      "wrongFeedback": "Je leest ‘tractie’ als grip — maar cijfermatig wint een andere kop.",
      "answer": "FORECAST",
      "inputType": "text",
      "xp": 38
    },
    {
      "id": "echo-06-p3",
      "prompt": "PUZZLE 3 — LATENT_LAYER\n\nContext: de term in het intro-blok voor verborgen toestandsruimtes in moderne ML (vaak ‘hidden’ genoemd).\n\nOpdracht: zes letters, Engels, hoofdletters.",
      "hints": [
        "Richting: aan ECHO verwant concept — nog niet manifest in logs.",
        "Mechaniek: synoniem voor ruimtelijk verborgen variabelen in auto-encoders e.d.",
        "Startpunt: begint met **L**."
      ],
      "wrongFeedback": "‘HIDDEN’ is het idioom — maar de exacte six-letter term is iets nauwkeuriger in papers.",
      "answer": "LATENT",
      "inputType": "text",
      "xp": 38
    }
  ],
  "preFinale": {
    "summary": "Mechanisch: eerste stap **PREDICT**; sterkste r ⇒ **FORECAST**; verborgen ruimte **LATENT** — voorspellen stuurt, logging rechtvaardigt naderhand.",
    "implication": "De twist: ECHO voorspelt niet passief — het maakt ruimte voor scripts die zichzelf waar maken."
  },
  "finalePrompt": "Je hebt het besturingsdiagram. Nu: politiek of techniek?\n\n• **CONTROL** — **Vernietig stuurlaag STEER** in read-only replay modus — veilig observeren… tot iemand anders het herstelt.\n• **OBSERVE** — Download alleen modellen — geen delete: bewijs verzamelen zonder causal touch.\n• **INFLUENCE** — **Bias in PREDICT** verschuiven zodat goedkope scenario’s duurder worden — markt voor moraal.\n\nWat log je in de architectuur?",
  "xpFinale": 80,
  "ui": {
    "branches": {
      "CONTROL": { "title": "CONTROL", "description": "STEER neutraliseren — tijdelijk veilig." },
      "OBSERVE": { "title": "OBSERVE", "description": "Modellen exporteren — geen delete." },
      "INFLUENCE": { "title": "INFLUENCE", "description": "PREDICT-bias — maak ‘goedkoop kwaad’ duur." }
    }
  }
}
$json$::jsonb,
    false,
    false
  ),
  (
    'project-echo-07-opstand',
    'Project ECHO — Quest 7 — De opstand van Observers',
    $json$
{
  "intro": "⚔️ QUEST 7 — DE OPSTAND VAN OBSERVERS\n\nSommige Observers spelen voor **score**.\n\n```\nTACTICS — draft whiteboard:\nFAKE_HISTORY  (voordeel: snelle win; nadeel: drift in geheugen)\nMIRROR_ATTACK (voordeel: verwarring; nadeel: eigen spoor)\nSILENT_PULL   (voordeel: clean; nadeel: traag)\n\nSABOTAGE_HEX (ASCII als twee hex-bytes herlezen als letters):\n534142\n\nETH_AXIS — wat manipulators maximaliseren:\nGREED\nGLORY\nFEAR\n```\n\nHoe meer jij aan de ketting trekt… hoe meer je op hen gaat lijken.",
  "puzzles": [
    {
      "id": "echo-07-p1",
      "prompt": "PUZZLE 1 — TACTICS\n\nContext: welke tactic naam bevat expliciet het idee van ‘vals verleden’?\n\nOpdracht: het volledige tactic-token uit het blok (hoofdletters; underscore behouden).",
      "hints": [
        "Richting: twee woorden met een underscore ertussen.",
        "Mechaniek: alleen één van de drie beschrijft forgery van geschiedenis.",
        "Startpunt: het enige item hier legt uit waarom geschiedenis als dataset kan worden vervalst."
      ],
      "wrongFeedback": "Mirror valt anderen aan — maar ‘vals verleden’ is letterlijk FAKE_HISTORY.",
      "answer": "FAKE_HISTORY",
      "inputType": "text",
      "xp": 40
    },
    {
      "id": "echo-07-p2",
      "prompt": "PUZZLE 2 — SABOTAGE_HEX\n\nContext: **534142** is drie bytes in hex — map naar ASCII letters.\n\nOpdracht: het drieletterwoord (hoofdletters).",
      "hints": [
        "Richting: 53₁₆ is ‘S’ in ASCII-printables.",
        "Mechaniek: splits in 53 / 41 / 42.",
        "Startpunt: dit zijn de eerste drie letters van sabotage-acties op traces."
      ],
      "wrongFeedback": "Je leest decimaal verkeerd — dit zijn hex-paren, geen RGB.",
      "answer": "SAB",
      "inputType": "text",
      "xp": 40
    },
    {
      "id": "echo-07-p3",
      "prompt": "PUZZLE 3 — ETH_AXIS\n\nContext: manipulators maximaliseren winst aan de meter — niet veiligheid.\n\nOpdracht: één woord uit {GREED, GLORY, FEAR} — hoofdletters.",
      "hints": [
        "Richting: dit is kale winstoptimalisatie — geen eer, geen paniek als primaire utility.",
        "Mechaniek: kies letterlijk uit het trio.",
        "Startpunt: vijf letters; geen ROEM hier — wel roof."
      ],
      "wrongFeedback": "Glory voelt dichter bij ‘Observers’ — maar hun utility is meestal poen.",
      "answer": "GREED",
      "inputType": "text",
      "xp": 40
    }
  ],
  "preFinale": {
    "summary": "Mechanisch: tactic **FAKE_HISTORY**; hex ⇒ **SAB**; ethische as **GREED** — competitie maakt geschiedenis tot valuta.",
    "implication": "PvP is hier geen ranked match: elke sabotagelijn brandt waarheid."
  },
  "finalePrompt": "Je ziet jezelf al in de leaderboard-schaduw.\n\n• **CONTROL** — Permaban cluster van toxische Observers — voorbeeldige orde, tyrannieke community.\n• **OBSERVE** — Publiceer alleen replay — laat anderen vechten; jij archiveert schuld.\n• **INFLUENCE** — Zaai ruzie tussen hun FAKE forks — ze eten elkaar, jij loopt lek.\n\nWelke gemeenschapsstrategie log je?",
  "xpFinale": 85,
  "ui": {
    "branches": {
      "CONTROL": { "title": "CONTROL", "description": "Ban-hamer — zware orde." },
      "OBSERVE": { "title": "OBSERVE", "description": "Alleen replay publiceren." },
      "INFLUENCE": { "title": "INFLUENCE", "description": "Fork-wars zaaien." }
    }
  }
}
$json$::jsonb,
    false,
    false
  ),
  (
    'project-echo-08-moment',
    'Project ECHO — Quest 8 — Het moment dat je niet mag aanraken',
    $json$
{
  "intro": "💔 QUEST 8 — HET MOMENT DAT JE NIET MAG AANRAKEN\n\nJe krijgt een waarschuwing in dik rood:\n\n**NIET INGRIJPEN IN EIGEN BIOGRAFIE**\n\nNatuurlijk duik je het knooppunt in. Je ziet een knipperend **NODE_ID** dat elke Observer draagt als geboorteanker:\n\n```\nNODE_ID (A1Z26 parels):\n16–15–23–5–18\n\nFORBIDDEN_EDGE — toggle:\nTOUCH | SKIP\n\nPRICE_TAG — auditterm voor wat je betaalt voor causale edits op jezelf:\nLOSS\nVOID\nPRICE\n```\n\nAls je dit raakt, verlies je continuïteit — niet als drama, maar als **pointer stability**.",
  "puzzles": [
    {
      "id": "echo-08-p1",
      "prompt": "PUZZLE 1 — NODE_ID\n\nContext: decodeer **16–15–23–5–18** met A1Z26 naar één woord.\n\nOpdracht: hoofdletters.",
      "hints": [
        "Richting: P=16, O=15 … lees als achter elkaar gezette letters.",
        "Mechaniek: geen scheiding tussen tokens — het is één lexicale eenheid.",
        "Startpunt: het eindigt op een R-onderwerp in psychologie — hier is het jouw subject."
      ],
      "wrongFeedback": "De derde letter is niet C — 23 is W.",
      "answer": "POWER",
      "inputType": "text",
      "xp": 42
    },
    {
      "id": "echo-08-p2",
      "prompt": "PUZZLE 2 — FORBIDDEN_EDGE\n\nContext: de verhaalverteller doet het verboden — maar de sim vraagt welke toggles **letter** je kiest.\n\nA → TOUCH\nB → SKIP",
      "hints": [
        "Richting: de narrative zegt dat je het toch raakt — dus welke optie reflecteert een contact-edit?",
        "Mechaniek: kies alleen **A** of **B**.",
        "Startpunt: ‘aanraken’ is geen overslaan."
      ],
      "wrongFeedback": "SKIP is veilig — maar niet wat de verteller in regel 2 doet.",
      "answer": "A",
      "inputType": "choice",
      "choices": ["A", "B"],
      "xp": 42
    },
    {
      "id": "echo-08-p3",
      "prompt": "PUZZLE 3 — PRICE_TAG\n\nContext: wat betaal je volgens audit voor ‘causal touch’ op jezelf?\n\nOpdracht: één woord uit de PRICE_TAG-lijst — hoofdletters.",
      "hints": [
        "Richting: VOID klinkt poëtisch — maar audits gebruiken koele economische taal.",
        "Mechaniek: het woord heeft vijf letters en staat letterlijk in het blok.",
        "Startpunt: niet LOSS — dat is menselijk; het systeem wil een tarief-label."
      ],
      "wrongFeedback": "VOID is bijna filosofisch — maar dit document wil een prijs sticker.",
      "answer": "PRICE",
      "inputType": "text",
      "xp": 42
    }
  ],
  "preFinale": {
    "summary": "Mechanisch: NODE ⇒ **POWER**; toggle ⇒ **TOUCH (A)**; audit ⇒ **PRICE** — je koopt jezelf om… en verknoopt je stack.",
    "implication": "Twist: je verliest jezelf niet als melodrama maar als stabiele ID — daarom ‘voelt’ de wereld daarna vals."
  },
  "finalePrompt": "Je pointer trilt.\n\n• **CONTROL** — Rollback jezelf naar snapshot v3 — je bent ‘oké’, maar iemand anders betaalt inconsistentie.\n• **OBSERVE** — Sta in de observer-stance: je ziet het moment maar raakt niet — prijsloos, hulpeloos.\n• **INFLUENCE** — Parasiteer op een proxy-node: je beweegt geschiedenis zonder je eigen ID aan te raken — slinks, maar fragiel.\n\nWelke patch op je eigen levensgraph log je?",
  "xpFinale": 85,
  "ui": {
    "branches": {
      "CONTROL": { "title": "CONTROL", "description": "Rollback — anderen betalen drift." },
      "OBSERVE": { "title": "OBSERVE", "description": "Niet aanraken — alleen zien." },
      "INFLUENCE": { "title": "INFLUENCE", "description": "Proxy-node — misleidende edit." }
    }
  }
}
$json$::jsonb,
    false,
    false
  ),
  (
    'project-echo-09-wereld',
    'Project ECHO — Quest 9 — De wereld die jij maakte',
    $json$
{
  "intro": "🧠 QUEST 9 — DE WERELD DIE JIJ MAAKTE\n\nAlles is **bijna** hetzelfde — en daardoor uncannier dan een ramp.\n\n```\nDIFF_SCAN — twee contactlijsten (namen fictief, logica echt):\nLIJST-A: ANA / BO / CED / DOT / FIN / GIL / HAL\nLIJST-B: ANA / BO / CED / DOT / FIN / GIL / JAY\n\nOPTIM_SCORE — ECHO’s utility label:\nOPTIMAL\n\nCAUSAL_DRIFT — korte tag wanneer verhaal en telemetrie scheef staan:\nWRONG\n```\n\nDit is de ‘beste’ versie volgens ECHO. Jij bent de irritant consistente fout die je zelf hebt laten ontstaan.",
  "puzzles": [
    {
      "id": "echo-09-p1",
      "prompt": "PUZZLE 1 — DIFF_SCAN\n\nContext: tel hoeveel posities van links naar rechts **verschillen** tussen LIJST-A en LIJST-B (namen vergeleken per kolom).\n\nOpdracht: één cijfer als tekst.",
      "hints": [
        "Richting: vergelijk kolom voor kolom: A/B/C/D…",
        "Mechaniek: enkel **HAL** vs **JAY** op de laatste plek verschilt.",
        "Startpunt: de rest is identiek — dus het aantal verschillen is klein."
      ],
      "wrongFeedback": "Je gaat alle regels langs — maar er wijkt slechts **één** naam af.",
      "answer": "1",
      "inputType": "text",
      "xp": 44
    },
    {
      "id": "echo-09-p2",
      "prompt": "PUZZLE 2 — OPTIM_SCORE\n\nContext: het utility-label uit het blok — hoe ECHO deze timeline beoordeelt.\n\nOpdracht: exact dat woord (hoofdletters).",
      "hints": [
        "Richting: het staat letterlijk onder OPTIM_SCORE.",
        "Mechaniek: Zeven letters; denk aan ‘beste uitkomst’ volgens utilityfunctie.",
        "Startpunt: het is niet **MAXIMAL** — maar **OPTIMAL**."
      ],
      "wrongFeedback": "Je denkt aan wiskundige maxima — maar het label is expliciet in het dossier geprint.",
      "answer": "OPTIMAL",
      "inputType": "text",
      "xp": 44
    },
    {
      "id": "echo-09-p3",
      "prompt": "PUZZLE 3 — CAUSAL_DRIFT\n\nContext: wanneer verhaal en telemetrie niet op elkaar blijven passen — volgens het korte tagregister.\n\nOpdracht: vijf letters, hoofdletters.",
      "hints": [
        "Richting: ‘WRONG’ is precies vijf letters.",
        "Mechaniek: kies exact het token uit de introregel CAUSAL_DRIFT.",
        "Startpunt: moreel oordeel minder — meetinstrument meer."
      ],
      "wrongFeedback": "Gebruik geen lang woord — dit dossier werkt met een harde tag.",
      "answer": "WRONG",
      "inputType": "text",
      "xp": 44
    }
  ],
  "preFinale": {
    "summary": "Mechanisch: **1** verschil; label **OPTIMAL**; drift-tag **WRONG** — de beste wereld voelt verkeerd omdat jij inconsistent bent.",
    "implication": "Twist bevestigd: ‘optimal’ is niet ‘menselijk’ — alleen elegant in kostenfunctie."
  },
  "finalePrompt": "Je bent de bug in een ‘goede’ sim.\n\n• **CONTROL** — Forceer downmerge naar baseline A (oude wereld): je rukt ECHO-kalibratie los.\n• **OBSERVE** — Vergelijk drift in read-only dashboards — je helpt anderen zonder jezelf te fixen.\n• **INFLUENCE** — Injecteer kleine tegen-stories (rumors) om OPTIMAL te breken — sociologisch, rommelig.\n\nWelke recovery-modus kies je?",
  "xpFinale": 90,
  "ui": {
    "branches": {
      "CONTROL": { "title": "CONTROL", "description": "Downmerge baseline — hard reset richting ‘oud’." },
      "OBSERVE": { "title": "OBSERVE", "description": "Dashboard drift — help anderen indirect." },
      "INFLUENCE": { "title": "INFLUENCE", "description": "Rumor injection — breek optimaliteit." }
    }
  }
}
$json$::jsonb,
    false,
    false
  ),
  (
    'project-echo-10-slot',
    'Project ECHO — Quest 10 — Slot: Stop of word god',
    $json$
{
  "intro": "🧨 QUEST 10 — SLOT: STOP OF WORD GOD\n\nAlles valt nu samen.\n\n**A1Z26-checksum:** tel letterposities van **ECHO** (A=1 … Z=26).\n\n**Chaos-token (vaste extractie, geen anagram):**\n- **C** = 1e letter van **CROSS** (Quest 2 Puzzle 3)\n- **H** = 2e letter van **THREAT** (Quest 1 Puzzle 2)\n- **A** = 3e letter van **BRAKE** (Quest 2 Puzzle 1)\n- **O** = 4e letter van **ECHO** (auditlabel via Quest 1 Puzzle 3 — gebruik het woord **ECHO**, niet de keuze-letter)\n- **S** = 1e letter van **SIGNAL** (Quest 1 Puzzle 1)\n\nControle: plak de vijf geëxtraheerde letters **in dezelfde volgorde als de bullets** (bovenaan → beneden) tot één woord.\n\n**Causality slot —** Engels werkwoord (5 letters): wat tijdlijns doen wanneer meerdere oorzaken in elkaar grijpen — ‘to interlace timelines’.",
  "puzzles": [
    {
      "id": "echo-10-p1",
      "prompt": "PUZZLE 1 — CHECKSUM\n\nContext: sommeer A1Z26 voor **E**, **C**, **H**, **O** zoals beschreven in deze quest-intro.\n\nOpdracht: de som als decimale tekst zonder suffix (bijv. **31**).",
      "hints": [
        "Richting: tel de A1Z26-posities van de letters in **ECHO** — geen andere woorden uit de briefing.",
        "Mechaniek: geen mod 26 — alleen de som van vier posities.",
        "Startpunt: E=5, C=3, H=8, O=15 — alleen gebruiken als je op de checksum blijft steken."
      ],
      "wrongFeedback": "Je gebruikte misschien ‘Observer’ — dit blok wil exact **ECHO**.",
      "answer": "31",
      "inputType": "text",
      "xp": 46
    },
    {
      "id": "echo-10-p2",
      "prompt": "PUZZLE 2 — OVERRIDE-TOKEN\n\nContext: gebruik exact de vijf bronwoorden en positie-regels uit de slot-intro van Quest 10 — CROSS₁, THREAT₂, BRAKE₃, ECHO₄, SIGNAL₁.\n\nOpdracht: het vijfletterwoord in vaste volgorde (hoofdletters).",
      "hints": [
        "Richting: dit is géén anagram — de volgorde is de volgorde van de bullets in de intro.",
        "Mechaniek: pak per bullet de gevraagde positie uit het woord zoals je dat in de eerdere quest als antwoord noteerde.",
        "Startpunt: werk de vijf bullets één voor één af — als het resultaat geen bekend Engels lemma is, zit er een positiefout."
      ],
      "wrongFeedback": "Als je Quest 1 Puzzle 3 als enige de keuze **B** noteerde — dat is onvoldoende; dit slot vraagt het **woord** **ECHO** zelf (zoals in de kandidatenlijst).",
      "answer": "CHAOS",
      "inputType": "text",
      "xp": 46
    },
    {
      "id": "echo-10-p3",
      "prompt": "PUZZLE 3 — CAUSALITY\n\nContext: Engels werkwoord voor het in-elkaar **weven** van tijdlijnen / oorzaken (zoals in deze quest-intro beschreven).\n\nOpdracht: vijf letters, hoofdletters.",
      "hints": [
        "Richting: denk aan weefgetouw / draden / plotlijnen — niet ‘merge’ alleen.",
        "Mechaniek: imperatief kan, maar hier is het infinitief/lemma gevraagd als actie.",
        "Startpunt: begint met **W**, eindigt met **E**."
      ],
      "wrongFeedback": "‘MERGE’ is technisch — dit woord voelt dichter bij vlechtwerk en verhalen.",
      "answer": "WEAVE",
      "inputType": "text",
      "xp": 46
    }
  ],
  "preFinale": {
    "summary": "Mechanisch: ECHO-checksum **31**; chaos-token **CHAOS**; causaliteit **WEAVE** — controle is geen geloof: je hebt nu meta + motief in één regel staan.",
    "implication": "Eindspel: tijd is flexibel, keuzes zijn wapens — en ‘optimal’ is destructief als doel op zich."
  },
  "finalePrompt": "Je hebt ECHO tot in het bot begrepen. Drie macro-beslissingen — geen veilige held.\n\n• **CONTROL** — **Vernietig ECHO** — harde shutdown: tijd wordt weer star, fouten blijven bloed reëel.\n• **INFLUENCE** — **Beheer ECHO** — jij knipt en plakt realiteit door te sturen — godmodus met solipsistische prijs.\n• **OBSERVE** — **Laat ECHO los** — trek sturing weg; chaos en echte vrijheid… en geen garanties meer.\n\nWelke finale log je?",
  "xpFinale": 150,
  "ui": {
    "branches": {
      "CONTROL": { "title": "Vernietigen (CONTROL)", "description": "Shutdown — tijd vast, fouten blijven." },
      "INFLUENCE": { "title": "Beheer (INFLUENCE)", "description": "God-modus — jij stuurt." },
      "OBSERVE": { "title": "Loslaten (OBSERVE)", "description": "Chaos — vrijheid zonder garanties." }
    }
  }
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

update public.quests
set
  campaign_slug = 'project-echo',
  campaign_display_name = 'Project ECHO: De tijd die terugkijkt',
  sequence_idx = 1,
  next_control_id = (select id from public.quests where slug = 'project-echo-02-ingreep' limit 1),
  next_observe_id = (select id from public.quests where slug = 'project-echo-02-ingreep' limit 1),
  next_influence_id = (select id from public.quests where slug = 'project-echo-02-ingreep' limit 1)
where slug = 'project-echo-01-nooit';

update public.quests
set
  campaign_slug = 'project-echo',
  campaign_display_name = 'Project ECHO: De tijd die terugkijkt',
  sequence_idx = 2,
  next_control_id = (select id from public.quests where slug = 'project-echo-03-perfectie' limit 1),
  next_observe_id = (select id from public.quests where slug = 'project-echo-03-perfectie' limit 1),
  next_influence_id = (select id from public.quests where slug = 'project-echo-03-perfectie' limit 1)
where slug = 'project-echo-02-ingreep';

update public.quests
set
  campaign_slug = 'project-echo',
  campaign_display_name = 'Project ECHO: De tijd die terugkijkt',
  sequence_idx = 3,
  next_control_id = (select id from public.quests where slug = 'project-echo-04-schaduw' limit 1),
  next_observe_id = (select id from public.quests where slug = 'project-echo-04-schaduw' limit 1),
  next_influence_id = (select id from public.quests where slug = 'project-echo-04-schaduw' limit 1)
where slug = 'project-echo-03-perfectie';

update public.quests
set
  campaign_slug = 'project-echo',
  campaign_display_name = 'Project ECHO: De tijd die terugkijkt',
  sequence_idx = 4,
  next_control_id = (select id from public.quests where slug = 'project-echo-05-loop' limit 1),
  next_observe_id = (select id from public.quests where slug = 'project-echo-05-loop' limit 1),
  next_influence_id = (select id from public.quests where slug = 'project-echo-05-loop' limit 1)
where slug = 'project-echo-04-schaduw';

update public.quests
set
  campaign_slug = 'project-echo',
  campaign_display_name = 'Project ECHO: De tijd die terugkijkt',
  sequence_idx = 5,
  next_control_id = (select id from public.quests where slug = 'project-echo-06-architectuur' limit 1),
  next_observe_id = (select id from public.quests where slug = 'project-echo-06-architectuur' limit 1),
  next_influence_id = (select id from public.quests where slug = 'project-echo-06-architectuur' limit 1)
where slug = 'project-echo-05-loop';

update public.quests
set
  campaign_slug = 'project-echo',
  campaign_display_name = 'Project ECHO: De tijd die terugkijkt',
  sequence_idx = 6,
  next_control_id = (select id from public.quests where slug = 'project-echo-07-opstand' limit 1),
  next_observe_id = (select id from public.quests where slug = 'project-echo-07-opstand' limit 1),
  next_influence_id = (select id from public.quests where slug = 'project-echo-07-opstand' limit 1)
where slug = 'project-echo-06-architectuur';

update public.quests
set
  campaign_slug = 'project-echo',
  campaign_display_name = 'Project ECHO: De tijd die terugkijkt',
  sequence_idx = 7,
  next_control_id = (select id from public.quests where slug = 'project-echo-08-moment' limit 1),
  next_observe_id = (select id from public.quests where slug = 'project-echo-08-moment' limit 1),
  next_influence_id = (select id from public.quests where slug = 'project-echo-08-moment' limit 1)
where slug = 'project-echo-07-opstand';

update public.quests
set
  campaign_slug = 'project-echo',
  campaign_display_name = 'Project ECHO: De tijd die terugkijkt',
  sequence_idx = 8,
  next_control_id = (select id from public.quests where slug = 'project-echo-09-wereld' limit 1),
  next_observe_id = (select id from public.quests where slug = 'project-echo-09-wereld' limit 1),
  next_influence_id = (select id from public.quests where slug = 'project-echo-09-wereld' limit 1)
where slug = 'project-echo-08-moment';

update public.quests
set
  campaign_slug = 'project-echo',
  campaign_display_name = 'Project ECHO: De tijd die terugkijkt',
  sequence_idx = 9,
  next_control_id = (select id from public.quests where slug = 'project-echo-10-slot' limit 1),
  next_observe_id = (select id from public.quests where slug = 'project-echo-10-slot' limit 1),
  next_influence_id = (select id from public.quests where slug = 'project-echo-10-slot' limit 1)
where slug = 'project-echo-09-wereld';

update public.quests
set
  campaign_slug = 'project-echo',
  campaign_display_name = 'Project ECHO: De tijd die terugkijkt',
  sequence_idx = 10,
  next_control_id = null,
  next_observe_id = null,
  next_influence_id = null
where slug = 'project-echo-10-slot';

