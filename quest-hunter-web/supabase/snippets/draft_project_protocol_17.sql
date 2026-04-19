-- PROJECT: Het protocol van de vergeten mens (Protocol 17)
-- Na migraties in Supabase SQL Editor draaien. Set starts_at / ends_at in Admin bij publicatie.
--
-- Linear campaign: alle finale-takken → dezelfde volgende quest.
-- Finale-paden: CONTROL / OBSERVE / INFLUENCE (mapping in ui.branches per quest).

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
