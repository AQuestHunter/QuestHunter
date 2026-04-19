-- PROJECT: DE KLUIS DIE NIET BESTAAT (Black Vault) — volledige story arc voor quest-hunter-web
-- Na migraties in Supabase SQL Editor draaien. Publiceer venster en next-quests in Admin zetten indien nodig.
--
-- Rules: 3 hint-tiers (richting → mechaniek → startpunt), wrongFeedback (near-miss), preFinale + finale,
-- minstens twee mechanic-categorieën per quest (encoding / logica / context / OSINT-feel / etc.).
-- Finale-paden: CONTROL / OBSERVE / INFLUENCE (verborgen assen voor campaigns).
--
-- Linear campaign: alle takken gaan naar dezelfde volgende quest (keuze beïnvloelt XP + hiddenAxes, niet routing).

insert into public.quests (slug, title, body, is_published, archived)
values
  (
    'black-vault-01-kaart',
    'De kluis die niet bestaat — Quest 1 — De kaart die niet bestaat',
    $json$
{
  "intro": "🔐 QUEST 1 — VOORBEREIDINGEN: DE KAART DIE NIET BESTAAT\n\nGerucht: een black vault — off-books, geen registratie. Jij krijgt drie bronnen die elkaar zouden moeten dekken… en dat doen ze niet.\n\n**Laag A — Fragment uit energie-dashboard (kWh / uur, peak):**\n```\n       1     2     3     4\nA     42    12     9    55\nB     18     0    41    20    ← rij B: kWh; 0 = ‘geen meting / leeg’\nC    cam   cam    ∅    cam   ← ∅ = geen camerastream (niet offline, bewust leeg)\nD     +1    +2    +6    +1    ← thermisch verschil (°C vs omgeving), laatste meetronde\n```\n**Laag B — Officieel plattegrond-label (zelfde rooster):** cellen met een naam op de getekende plaat: A1 LOBBY, B1 TRAP, A4 TRESOR, D4 ARCHIEF — alles behalve **B3** heeft een contour op de tekening. Cel **B3** staat op de plot als massieve muur.\n**Laag C — Interne mailtrail (codetaal):** elk bericht eindigt met een TAG in het honderdvoud:\n```\nM1 TAG:1800 / init: NV (Niet Verklaard)\nM2 TAG:2100 / init: NV\nM3 TAG:5123 / init: NV\n```\n**Regel:** tel de drie TAG-waarden op (**1800 + 2100 + 5123 = 9023**). Neem de **laatste twee cijfers** → **23**. Lees **23** als **tweede cijfer = rij** en **laatste cijfer = kolom**: rij **2** → **B** (1=A, 2=B, 3=C, 4=D); kolom **3**. Notatie: **B3** (kruis met laag A en B).\n\nKopregel op het interceptblad (classificatie): **BLACK**.\n\nNiet de kluisruimte zelf is het anker — iets naast het plangebied liegt. Waar klampt de werkelijkheid los van het papier?",
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
        "Startpunt: als EENX → DEAN, bevestig dat de anderen geen DEAN zijn."
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
        "Startpunt: H, I, D, E — lees als één woord."
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
        "Startpunt: M-I-S-S — controleer de derde en vierde telstreek."
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
        "Startpunt: op 12:01:30 is iets stilgevraagd — wat staat daar letterlijk?"
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
      "wrongFeedback": "Je decimale omzetting kloopt bijna — controleer de laatste byte als letter ‘D’.",
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
      "wrongFeedback": "Alle drie zijn technisch geldige ACK’s — focust op **documentpositie** versus **tijdsorde**.",
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
