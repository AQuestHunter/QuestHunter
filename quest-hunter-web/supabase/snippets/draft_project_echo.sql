-- PROJECT ECHO: De tijd die terugkijkt — volledige 10-quest arc voor quest-hunter-web
-- Na migraties in Supabase SQL Editor draaien. Set starts_at / ends_at + is_published in Admin.
--
-- Linear campaign: alle finale-takken → dezelfde volgende quest.
-- Finale-paden: CONTROL / OBSERVE / INFLUENCE — gemapt naar vernietigen / beheren / loslaten (zie ui.branches op slot).

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
