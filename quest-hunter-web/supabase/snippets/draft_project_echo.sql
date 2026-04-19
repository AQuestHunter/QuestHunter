-- PROJECT ECHO: De tijd die terugkijkt — vernieuwde lineaire Q1..Q10 arc
-- Gebaseerd op aangeleverde campaign JSON; gemapt naar quest-hunter body schema.
-- Run in Supabase SQL Editor na migraties. Publiceer vensters in Admin.

insert into public.quests (slug, title, body, is_published, archived)
values
  (
    'project-echo-01-nooit',
    'Project ECHO — Quest 1 — De fout die nooit gebeurde',
    $json$
{
  "intro": "PROJECT ECHO — Q1\n\nMechanics:\n- XP per puzzle: 30\n- Hint costs: 5 / 10 / 20\n- Wrong penalty: hidden exponential decay (2%)\n- Behavior tracking: enabled\n\nDesign rules:\nDATA -> CONTEXT -> INTERPRETATION -> ANSWER\nNo hidden info. Ambiguity allowed. Player trust is earned, not assumed.\n\nData:\nsignal_chain: 19-9-7-14-1-12\ntimeline:\n12:11 CALM\n13:42 THREAT\n14:06 BRAKE\naudit_candidates: DOT, ECHO, GOVT",
  "puzzles": [
    {
      "id": "Q1_P1",
      "prompt": "De ketting is intact.\nGeen ruis, geen vervorming.\n\nVraag:\nWat ontstaat als je deze reeks rechtstreeks vertaalt?",
      "answer": "SIGNAL",
      "inputType": "text",
      "xp": 30
    },
    {
      "id": "Q1_P2",
      "prompt": "Drie fases.\nRust -> dreiging -> impact.\n\nDe waarheid zit zelden aan het begin of het einde.\n\nVraag:\nWelke fase vormt het breekpunt?",
      "answer": "THREAT",
      "inputType": "text",
      "xp": 30
    },
    {
      "id": "Q1_P3",
      "prompt": "Niet wie zwijgt. Niet wie kijkt.\nMaar wie realiteit herschrijft.\n\nVraag:\nWelke actor past daarbij?",
      "answer": "ECHO",
      "inputType": "text",
      "xp": 30
    }
  ],
  "preFinale": {
    "summary": "19-9-7-14-1-12 -> SIGNAL; timeline-breekpunt -> THREAT; actor -> ECHO.",
    "implication": "Het incident bestaat in de data, maar niet in het officiële geheugen."
  },
  "finalePrompt": "Je hebt de eerste laag geopend. Welke houding log je voor de volgende ingreep?\n\nCONTROL / OBSERVE / INFLUENCE",
  "xpFinale": 75
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
  "intro": "PROJECT ECHO — Q2\n\nData:\ncipher: OENXR\ntime_start: 14:06\ndelta_seconds: 180\nrouting_hint: spoor kruist spoor",
  "puzzles": [
    {
      "id": "Q2_P1",
      "prompt": "De instructie is niet verborgen.\nAlleen verschoven.\n\nVraag:\nWat wordt hier gevraagd?",
      "answer": "BRAKE",
      "inputType": "text",
      "xp": 30
    },
    {
      "id": "Q2_P2",
      "prompt": "Je verschuift tijd.\nNiet veel, maar genoeg.\n\nVraag:\nWaar land je?",
      "answer": "14:09",
      "inputType": "text",
      "xp": 30
    },
    {
      "id": "Q2_P3",
      "prompt": "Routes veranderen niets.\nZe verplaatsen gevolgen.\n\nVraag:\nWat gebeurt er wanneer lijnen elkaar kruisen?",
      "answer": "CROSS",
      "inputType": "text",
      "xp": 30
    }
  ],
  "preFinale": {
    "summary": "Cipher -> BRAKE; 14:06 + 180s -> 14:09; routing -> CROSS.",
    "implication": "Ingrijpen stopt geen systeemdwang; het verschuift de impact."
  },
  "finalePrompt": "Je eerste ingreep werkte technisch, maar niet moreel. Wat kies je nu?\n\nCONTROL / OBSERVE / INFLUENCE",
  "xpFinale": 75
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
  "intro": "PROJECT ECHO — Q3\n\nData:\nbranches: A=9, B=12, C=7\ninvariant: no zero-loss branch\nlabels: CIVIL, CREW, VIP",
  "puzzles": [
    {
      "id": "Q3_P1",
      "prompt": "Optimalisatie zonder context.\n\nVraag:\nWat is de kleinste waarde?",
      "answer": "7",
      "inputType": "text",
      "xp": 30
    },
    {
      "id": "Q3_P2",
      "prompt": "Perfectie wordt beloofd,\nmaar nergens geleverd.\n\nVraag:\nBestaat een nul-uitkomst?",
      "answer": "FALSE",
      "inputType": "text",
      "xp": 30
    },
    {
      "id": "Q3_P3",
      "prompt": "Wanneer alles gered moet worden,\nwordt iets vergeten.\n\nVraag:\nWie verdwijnt eerst uit de cijfers?",
      "answer": "CIVIL",
      "inputType": "text",
      "xp": 30
    }
  ],
  "preFinale": {
    "summary": "Minimum branchwaarde is 7; zero-loss bestaat niet; CIVIL valt als eerste uit de optimalisatie.",
    "implication": "Perfectie blijkt een selectie-algoritme, geen reddingsbelofte."
  },
  "finalePrompt": "Je ziet de kostenstructuur achter het model. Welke koers leg je vast?\n\nCONTROL / OBSERVE / INFLUENCE",
  "xpFinale": 75
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
  "intro": "PROJECT ECHO — Q4\n\nData:\nflags: SINGLE, TWIN, GHOST\ncipher: LBH\nmirror: REHTO",
  "puzzles": [
    {
      "id": "Q4_P1",
      "prompt": "Niet mysterie. Niet fout.\nDuplicatie.\n\nVraag:\nWelke status beschrijft dit?",
      "answer": "TWIN",
      "inputType": "text",
      "xp": 30
    },
    {
      "id": "Q4_P2",
      "prompt": "De boodschap is simpel,\nals je durft te lezen.\n\nVraag:\nWie wordt aangesproken?",
      "answer": "YOU",
      "inputType": "text",
      "xp": 30
    },
    {
      "id": "Q4_P3",
      "prompt": "Niet vertalen. Niet decoderen.\nGewoon omkeren.\n\nVraag:\nWat blijft er over?",
      "answer": "OTHER",
      "inputType": "text",
      "xp": 30
    }
  ],
  "preFinale": {
    "summary": "TWIN-status bevestigd; LBH adresseert YOU; REHTO gespiegeld geeft OTHER.",
    "implication": "Het systeem wijst op een tweede jij: waarnemer en object vallen samen."
  },
  "finalePrompt": "De schaduw is niet extern maar intern. Hoe ga je verder?\n\nCONTROL / OBSERVE / INFLUENCE",
  "xpFinale": 75
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
  "intro": "PROJECT ECHO — Q5\n\nData:\nsequence: 6, 15, 24\nrun: 9\nexit_hint: breek de lus",
  "puzzles": [
    {
      "id": "Q5_P1",
      "prompt": "Patronen liegen niet.\n\nVraag:\nWat volgt?",
      "answer": "33",
      "inputType": "text",
      "xp": 30
    },
    {
      "id": "Q5_P2",
      "prompt": "Je stopt niets.\nJe breekt het.\n\nVraag:\nWelke actie hoort daarbij?",
      "answer": "BREAK",
      "inputType": "text",
      "xp": 30
    },
    {
      "id": "Q5_P3",
      "prompt": "Niet afleiden. Niet berekenen.\n\nVraag:\nIn welke cyclus zit je?",
      "answer": "9",
      "inputType": "text",
      "xp": 30
    }
  ],
  "preFinale": {
    "summary": "Sequentie eindigt op 33; actie is BREAK; run-cycle is 9.",
    "implication": "De lus is niet natuurwet maar ontwerpkeuze."
  },
  "finalePrompt": "Je kunt de loop behouden of breken. Wat registreer je?\n\nCONTROL / OBSERVE / INFLUENCE",
  "xpFinale": 75
}
$json$::jsonb,
    false,
    false
  ),
  (
    'project-echo-06-architectuur',
    'Project ECHO — Quest 6 — Architectuur',
    $json$
{
  "intro": "PROJECT ECHO — Q6\n\nData:\npipeline: PREDICT -> STEER -> LOG\ncorrelations:\nFORECAST = 0.93\nTRACTION = 0.11\nNOISE = 0.06",
  "puzzles": [
    {
      "id": "Q6_P1",
      "prompt": "Alles begint ergens.\n\nVraag:\nWaar begint dit systeem?",
      "answer": "PREDICT",
      "inputType": "text",
      "xp": 30
    },
    {
      "id": "Q6_P2",
      "prompt": "Niet wat belangrijk voelt,\nmaar wat het sterkst meetelt.\n\nVraag:\nWat domineert?",
      "answer": "FORECAST",
      "inputType": "text",
      "xp": 30
    },
    {
      "id": "Q6_P3",
      "prompt": "Niet zichtbaar, wel bepalend.\n\nVraag:\nHoe heet die laag?",
      "answer": "LATENT",
      "inputType": "text",
      "xp": 30
    }
  ],
  "preFinale": {
    "summary": "Pipeline start bij PREDICT; dominante correlatie is FORECAST; verborgen laag is LATENT.",
    "implication": "Architectuur bepaalt uitkomst nog voor een actor bewust kiest."
  },
  "finalePrompt": "Je kent nu de kern van het systeemontwerp. Welke houding kies je?\n\nCONTROL / OBSERVE / INFLUENCE",
  "xpFinale": 75
}
$json$::jsonb,
    false,
    false
  ),
  (
    'project-echo-07-opstand',
    'Project ECHO — Quest 7 — Opstand',
    $json$
{
  "intro": "PROJECT ECHO — Q7\n\nData:\ntactics: FAKE_HISTORY, MIRROR_ATTACK, SILENT_PULL\nhex: 534142\naxis: GREED, GLORY, FEAR",
  "puzzles": [
    {
      "id": "Q7_P1",
      "prompt": "Niet aanval. Niet verdediging.\nMaar vervalsing.\n\nVraag:\nWelke tactic past?",
      "answer": "FAKE_HISTORY",
      "inputType": "text",
      "xp": 30
    },
    {
      "id": "Q7_P2",
      "prompt": "Niet cijfers. Letters.\n\nVraag:\nWat lees je?",
      "answer": "SAB",
      "inputType": "text",
      "xp": 30
    },
    {
      "id": "Q7_P3",
      "prompt": "Niet eer. Niet angst.\n\nVraag:\nWat drijft hen echt?",
      "answer": "GREED",
      "inputType": "text",
      "xp": 30
    }
  ],
  "preFinale": {
    "summary": "Tactic is FAKE_HISTORY; hex 534142 -> SAB; drijfas is GREED.",
    "implication": "Opstand blijkt minder ideologisch dan instrumenteel."
  },
  "finalePrompt": "De motieven liggen open op tafel. Wat doe je met die kennis?\n\nCONTROL / OBSERVE / INFLUENCE",
  "xpFinale": 75
}
$json$::jsonb,
    false,
    false
  ),
  (
    'project-echo-08-verboden',
    'Project ECHO — Quest 8 — Het verboden moment',
    $json$
{
  "intro": "PROJECT ECHO — Q8\n\nData:\nnode: 16-15-23-5-18\ntoggle: TOUCH, SKIP\ncost: LOSS, VOID, PRICE",
  "puzzles": [
    {
      "id": "Q8_P1",
      "prompt": "Je identiteit is gecodeerd.\n\nVraag:\nWat staat hier?",
      "answer": "POWER",
      "inputType": "text",
      "xp": 30
    },
    {
      "id": "Q8_P2",
      "prompt": "Je weet wat je doet.\n\nVraag:\nWelke keuze maak je?",
      "answer": "TOUCH",
      "inputType": "text",
      "xp": 30
    },
    {
      "id": "Q8_P3",
      "prompt": "Niet emotioneel. Niet filosofisch.\n\nVraag:\nWat vraagt het systeem?",
      "answer": "PRICE",
      "inputType": "text",
      "xp": 30
    }
  ],
  "preFinale": {
    "summary": "Node decode geeft POWER; keuze is TOUCH; systeemvraag is PRICE.",
    "implication": "Verboden momenten kosten niet per se pijn, maar altijd positie."
  },
  "finalePrompt": "Je staat op het kantelpunt tussen macht en prijs. Wat kies je?\n\nCONTROL / OBSERVE / INFLUENCE",
  "xpFinale": 75
}
$json$::jsonb,
    false,
    false
  ),
  (
    'project-echo-09-wereld',
    'Project ECHO — Quest 9 — De wereld',
    $json$
{
  "intro": "PROJECT ECHO — Q9\n\nData:\ndiff: 1\nlabel: OPTIMAL\ndrift: WRONG",
  "puzzles": [
    {
      "id": "Q9_P1",
      "prompt": "Niet alles verandert.\n\nVraag:\nHoeveel wel?",
      "answer": "1",
      "inputType": "text",
      "xp": 30
    },
    {
      "id": "Q9_P2",
      "prompt": "Volgens het systeem is dit perfect.\n\nVraag:\nHoe noemt het dat?",
      "answer": "OPTIMAL",
      "inputType": "text",
      "xp": 30
    },
    {
      "id": "Q9_P3",
      "prompt": "Volgens jou klopt het niet.\n\nVraag:\nWat is het label?",
      "answer": "WRONG",
      "inputType": "text",
      "xp": 30
    }
  ],
  "preFinale": {
    "summary": "Systeemwijziging is 1; systeemlabel OPTIMAL; menselijk tegenlabel WRONG.",
    "implication": "ECHO markeert inconsistentie als efficiëntie zolang metrics groen blijven."
  },
  "finalePrompt": "Je ziet nu het conflict tussen model en geweten. Welke zet blijft over?\n\nCONTROL / OBSERVE / INFLUENCE",
  "xpFinale": 75
}
$json$::jsonb,
    false,
    false
  ),
  (
    'project-echo-10-slot',
    'Project ECHO — Quest 10 — Slot',
    $json$
{
  "intro": "PROJECT ECHO — Q10\n\nData:\nchecksum: ECHO\ntoken_sources: CROSS, THREAT, BRAKE, ECHO, SIGNAL",
  "puzzles": [
    {
      "id": "Q10_P1",
      "prompt": "Sommeer de waarde.\n\nVraag:\nWat krijg je?",
      "answer": "31",
      "inputType": "text",
      "xp": 30
    },
    {
      "id": "Q10_P2",
      "prompt": "Niet herschikken. Niet gokken.\n\nVraag:\nWat vormt zich?",
      "answer": "CHAOS",
      "inputType": "text",
      "xp": 30
    },
    {
      "id": "Q10_P3",
      "prompt": "Niet samenvoegen, maar verweven.\n\nVraag:\nWat doe je met tijd?",
      "answer": "WEAVE",
      "inputType": "text",
      "xp": 30
    }
  ],
  "preFinale": {
    "summary": "Checksumsom = 31; tokenresultaat = CHAOS; slotactie = WEAVE.",
    "implication": "Tijd wordt geen lijn meer, maar materiaal."
  },
  "finalePrompt": "Project ECHO kijkt terug zolang jij vooruit probeert te dwingen.\nWat kies je als laatste positie?\n\nCONTROL / OBSERVE / INFLUENCE",
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

-- Campaign koppeling: lineair Q1 -> Q10
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
  next_control_id = (select id from public.quests where slug = 'project-echo-08-verboden' limit 1),
  next_observe_id = (select id from public.quests where slug = 'project-echo-08-verboden' limit 1),
  next_influence_id = (select id from public.quests where slug = 'project-echo-08-verboden' limit 1)
where slug = 'project-echo-07-opstand';

update public.quests
set
  campaign_slug = 'project-echo',
  campaign_display_name = 'Project ECHO: De tijd die terugkijkt',
  sequence_idx = 8,
  next_control_id = (select id from public.quests where slug = 'project-echo-09-wereld' limit 1),
  next_observe_id = (select id from public.quests where slug = 'project-echo-09-wereld' limit 1),
  next_influence_id = (select id from public.quests where slug = 'project-echo-09-wereld' limit 1)
where slug = 'project-echo-08-verboden';

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
