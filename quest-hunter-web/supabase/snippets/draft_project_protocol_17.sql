-- PROTOCOL-17 — vernieuwde lineaire Q1..Q5 arc
-- Gebaseerd op aangeleverde campaign JSON; gemapt naar quest-hunter body schema.
-- Run in Supabase SQL Editor na migraties. Publiceer vensters in Admin.

insert into public.quests (slug, title, body, is_published, archived)
values
  (
    'protocol-17-01-identiteit',
    'Het protocol van de vergeten mens — Quest 1 — Wie ben jij?',
    $json$
{
  "intro": "PROTOCOL-17 — Q1\n\nMechanics:\n- XP per puzzle: 30\n- Hint costs: 5 / 10 / 20\n- Wrong penalty: hidden exponential decay (2%)\n- Behavior tracking: enabled\n\nData:\nchain: 18-5-19-5-20\nhex: 50 52 4F 4F 46\nwipe:\nA=FULL\nB=PARTIAL\nC=SOFT",
  "puzzles": [
    {
      "id": "Q1_P1",
      "prompt": "De keten is intact.\nGeen vervorming, geen ruis.\n\nVraag:\nWat wordt hier gevormd?",
      "answer": "RESET",
      "inputType": "text",
      "xp": 30
    },
    {
      "id": "Q1_P2",
      "prompt": "Niet verborgen.\nAlleen anders geschreven.\n\nVraag:\nWat lees je?",
      "answer": "PROOF",
      "inputType": "text",
      "xp": 30
    },
    {
      "id": "Q1_P3",
      "prompt": "Niet vernietigen, niet half wissen.\nMaar verdwijnen zonder impact.\n\nVraag:\nWelke klasse beschrijft dit?",
      "answer": "C",
      "inputType": "choice",
      "choices": ["A", "B", "C"],
      "xp": 30
    }
  ],
  "preFinale": {
    "summary": "Chain -> RESET; hex -> PROOF; wipe-klasse -> C.",
    "implication": "Protocol-17 verwijdert niet altijd hard; het kan je ook sociaal laten verdwijnen."
  },
  "finalePrompt": "Je eerste bewijslaag staat vast. Welke houding kies je voor de architectuurlaag?\n\nCONTROL / OBSERVE / INFLUENCE",
  "xpFinale": 75
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
  "intro": "PROTOCOL-17 — Q2\n\nData:\ncipher: ZBGURE\nimpact: 44, 51, 49\nthreshold: 50\nsplit: M + OTHER",
  "puzzles": [
    {
      "id": "Q2_P1",
      "prompt": "Niet verborgen.\nAlleen verschoven.\n\nVraag:\nWat wordt hier genoemd?",
      "answer": "MOTHER",
      "inputType": "text",
      "xp": 30
    },
    {
      "id": "Q2_P2",
      "prompt": "Niet alles blijft.\nAlleen wat zwaar genoeg is.\n\nVraag:\nWelke waarde overleeft?",
      "answer": "51",
      "inputType": "text",
      "xp": 30
    },
    {
      "id": "Q2_P3",
      "prompt": "Geen persoon, geen naam.\nMaar een systeem dat beslist.\n\nVraag:\nWat is het?",
      "answer": "MODEL",
      "inputType": "text",
      "xp": 30
    }
  ],
  "preFinale": {
    "summary": "ZBGURE -> MOTHER; threshold overlevende -> 51; beslissende laag -> MODEL.",
    "implication": "De architect is geen individu maar een beslissysteem."
  },
  "finalePrompt": "Je hebt de kern van selectie gezien. Hoe beweeg je door naar uitwissing?\n\nCONTROL / OBSERVE / INFLUENCE",
  "xpFinale": 75
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
  "intro": "PROTOCOL-17 — Q3\n\nData:\ncipher: RENFRQ\ndecay:\nstart=100\nstep=-17\ncycles=3\nriddle: achter je, zichtbaar door licht",
  "puzzles": [
    {
      "id": "Q3_P1",
      "prompt": "Niet verloren. Niet vergeten.\nVerwijderd.\n\nVraag:\nWat staat hier?",
      "answer": "ERASED",
      "inputType": "text",
      "xp": 30
    },
    {
      "id": "Q3_P2",
      "prompt": "Altijd bij je.\nNooit voor je.\n\nVraag:\nWat volgt je?",
      "answer": "SHADOW",
      "inputType": "text",
      "xp": 30
    },
    {
      "id": "Q3_P3",
      "prompt": "Elke cyclus kost je iets.\n\nVraag:\nWat blijft er over?",
      "answer": "49",
      "inputType": "text",
      "xp": 30
    }
  ],
  "preFinale": {
    "summary": "RENFRQ -> ERASED; riddle -> SHADOW; decay restwaarde -> 49.",
    "implication": "Uitwissing is een proces met verlies per cyclus, geen instant event."
  },
  "finalePrompt": "Je kent nu de dynamiek van verdwijnen. Wat doe je met dat inzicht?\n\nCONTROL / OBSERVE / INFLUENCE",
  "xpFinale": 75
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
  "intro": "PROTOCOL-17 — Q4\n\nData:\ngoal: MINIMISE TURBULENCE\ncorrelation:\nENGAGEMENT=0.91\nSLEEP=0.12\nINCOME=0.44\nimpact:\nA=21\nB=9\nC=17\nD=9",
  "puzzles": [
    {
      "id": "Q4_P1",
      "prompt": "Niet mensen. Niet moraal.\n\nVraag:\nWat wordt geminimaliseerd?",
      "answer": "A",
      "inputType": "choice",
      "choices": ["A", "B", "C", "D"],
      "xp": 30
    },
    {
      "id": "Q4_P2",
      "prompt": "Niet wat logisch voelt,\nmaar wat het sterkst werkt.\n\nVraag:\nWat domineert?",
      "answer": "ENGAGEMENT",
      "inputType": "text",
      "xp": 30
    },
    {
      "id": "Q4_P3",
      "prompt": "Niet uniek. Niet eerlijk.\nMaar consistent.\n\nVraag:\nWie valt eerst?",
      "answer": "B",
      "inputType": "choice",
      "choices": ["A", "B", "C", "D"],
      "xp": 30
    }
  ],
  "preFinale": {
    "summary": "Doelfunctie -> optie A; dominante correlatie -> ENGAGEMENT; eerste val -> B.",
    "implication": "Het model optimaliseert stabiliteit, niet rechtvaardigheid."
  },
  "finalePrompt": "Breken of buigen is geen ethische vraag meer maar systeemstrategie. Wat kies je?\n\nCONTROL / OBSERVE / INFLUENCE",
  "xpFinale": 75
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
  "intro": "PROTOCOL-17 — Q5\n\nData:\nword: MEDIAN\nsources: ENGAGEMENT, SHADOW, MOTHER, ERASED, RESET",
  "puzzles": [
    {
      "id": "Q5_P1",
      "prompt": "Alles heeft een waarde.\n\nVraag:\nWat is de som?",
      "answer": "46",
      "inputType": "text",
      "xp": 30
    },
    {
      "id": "Q5_P2",
      "prompt": "Niet herschikken. Niet gokken.\n\nVraag:\nWat vormt zich?",
      "answer": "GHOST",
      "inputType": "text",
      "xp": 30
    },
    {
      "id": "Q5_P3",
      "prompt": "Niet slecht. Niet bijzonder.\n\nVraag:\nWat ben je?",
      "answer": "REPLACEABLE",
      "inputType": "text",
      "xp": 30
    }
  ],
  "preFinale": {
    "summary": "Slotsom = 46; tokenvorm = GHOST; status = REPLACEABLE.",
    "implication": "Bestaan wordt binnen Protocol-17 conditioneel gemaakt door classificatie."
  },
  "finalePrompt": "Je eindigt niet met bevrijding maar met positionering. Wat registreer je als slotkeuze?\n\nCONTROL / OBSERVE / INFLUENCE",
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

-- Campaign koppeling: lineair Q1 -> Q5
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
