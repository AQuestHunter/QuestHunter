-- PROJECT ORACLE — vernieuwde lineaire Q1..Q5 arc
-- Gebaseerd op aangeleverde campaign JSON; gemapt naar quest-hunter body schema.
-- Run in Supabase SQL Editor na migraties. Publiceer vensters in Admin.

insert into public.quests (slug, title, body, is_published, archived)
values
  (
    'oracle-01-lek',
    'PROJECT ORACLE — Quest 1 — Het lek',
    $json$
{
  "intro": "PROJECT ORACLE — Q1 — Het lek\n\nMechanics:\n- XP per puzzle: 25\n- Hint costs: 5 / 10 / 20\n- Wrong penalty: hidden exponential decay (2%)\n- Behavior tracking: enabled\n\nData fragment:\nINCIDENTNOTE v0.7 | integrity: DEGRADED\n\nSUBJECT_CODE: 12-5-14-1\n\nTIMELINE:\n23:20\n23:30\n??:??\n\nSYSTEM FLAG:\nDelta = constant\n\nZONE_TOKEN:\nP R A K",
  "puzzles": [
    {
      "id": "Q1_P1",
      "prompt": "Het fragment is beschadigd.\nMaar SUBJECT_CODE lijkt intact.\n\nVraag:\nWie wordt hier gecodeerd?",
      "hints": [
        "A=1 mapping.",
        "12=L, 5=E.",
        "14=N, 1=A."
      ],
      "answer": "LENA",
      "inputType": "text",
      "xp": 25
    },
    {
      "id": "Q1_P2",
      "prompt": "De tijdlijn mist een element.\nHet systeem laat alleen achter: Delta = constant.\n\nVraag:\nWat ontbreekt?",
      "hints": [
        "Kijk naar het vaste interval.",
        "23:20 -> 23:30 is +10.",
        "Trek hetzelfde door."
      ],
      "answer": "23:40",
      "inputType": "text",
      "xp": 25
    },
    {
      "id": "Q1_P3",
      "prompt": "Niet alles is gecodeerd.\nSommige dingen zijn herschikt.\n\nVraag:\nWat betekent ZONE_TOKEN?",
      "hints": [
        "Anagram van P R A K.",
        "Openbare plek.",
        "Engels woord."
      ],
      "answer": "PARK",
      "inputType": "text",
      "xp": 25
    }
  ],
  "preFinale": {
    "summary": "SUBJECT_CODE -> LENA, timeline -> 23:40, token -> PARK.",
    "implication": "Het lek is geen ruis; het is een gecontroleerde opening."
  },
  "finalePrompt": "Je eerste reconstructie staat vast.\nHoe ga je verder met ORACLE?\n\nCONTROL / OBSERVE / INFLUENCE",
  "xpFinale": 75
}
$json$::jsonb,
    false,
    false
  ),
  (
    'oracle-02-sleutels',
    'PROJECT ORACLE — Quest 2 — De sleutels',
    $json$
{
  "intro": "PROJECT ORACLE — Q2 — De sleutels\n\nData fragment:\nAUTH LOG - PARTIAL\n\nBADGE: EENX\nKEY: BANK\n\nSTATUS:\nactive\nactive\nactive\nUNKNOWN",
  "puzzles": [
    {
      "id": "Q2_P1",
      "prompt": "Eén badge wijkt af.\nMaar alleen als je kijkt wat erachter zit.\n\nVraag:\nWelke naam zit achter EENX?",
      "hints": [
        "Gebruik key BANK.",
        "Vigenere decrypt.",
        "Resultaat is een voornaam."
      ],
      "answer": "DEAN",
      "inputType": "text",
      "xp": 25
    },
    {
      "id": "Q2_P2",
      "prompt": "De logs lijken consistent.\nTot ze dat niet meer zijn.\n\nVraag:\nWelke status hoort hier niet?",
      "hints": [
        "Drie regels matchen.",
        "Een regel breekt patroon.",
        "Exact token overnemen."
      ],
      "answer": "UNKNOWN",
      "inputType": "text",
      "xp": 25
    }
  ],
  "preFinale": {
    "summary": "Badge decode wijst naar DEAN; statusanomalie is UNKNOWN.",
    "implication": "Wat als afwijking verschijnt, kan juist de echte sleutel zijn."
  },
  "finalePrompt": "De sleutellaag is geopend.\nKies je vervolghouding.\n\nCONTROL / OBSERVE / INFLUENCE",
  "xpFinale": 75
}
$json$::jsonb,
    false,
    false
  ),
  (
    'oracle-03-stilte',
    'PROJECT ORACLE — Quest 3 — Stilte',
    $json$
{
  "intro": "PROJECT ORACLE — Q3 — Stilte\n\nData fragment:\nSYS LOG\n\n01001000 01001001 01000100 01000101\n-- .. ... ...\n\nSTATUS:\nOPEN\nOPEN\nSILENT\nOPEN",
  "puzzles": [
    {
      "id": "Q3_P1",
      "prompt": "Dit is geen ruis.\n\nVraag:\nWat betekent de binaire reeks?",
      "hints": [
        "Binair naar ASCII.",
        "Vier bytes, vier letters.",
        "Engels woord."
      ],
      "answer": "HIDE",
      "inputType": "text",
      "xp": 25
    },
    {
      "id": "Q3_P2",
      "prompt": "Sneller dan woorden.\n\nVraag:\nWat betekent het morsefragment?",
      "hints": [
        "Internationale morse.",
        "Vier letters.",
        "Begint met M."
      ],
      "answer": "MISS",
      "inputType": "text",
      "xp": 25
    },
    {
      "id": "Q3_P3",
      "prompt": "Niet alles wat verandert is belangrijk.\nMaar dit wel.\n\nVraag:\nWat breekt het patroon?",
      "hints": [
        "Zoek eerste afwijking.",
        "Niet OPEN.",
        "Exact token."
      ],
      "answer": "SILENT",
      "inputType": "text",
      "xp": 25
    }
  ],
  "preFinale": {
    "summary": "HIDE, MISS en SILENT leggen de structuur van de loglaag bloot.",
    "implication": "Stilte is hier een signaal, geen afwezigheid."
  },
  "finalePrompt": "Je leest nu de stille laag van ORACLE.\nWelke houding neem je mee naar de jacht?\n\nCONTROL / OBSERVE / INFLUENCE",
  "xpFinale": 75
}
$json$::jsonb,
    false,
    false
  ),
  (
    'oracle-04-jacht',
    'PROJECT ORACLE — Quest 4 — Jacht',
    $json$
{
  "intro": "PROJECT ORACLE — Q4 — Jacht\n\nData:\nGRID\n·#···\n··#··\nS··#·\n·····\n···#X\n\nCODE\n48 4F 4C 44",
  "puzzles": [
    {
      "id": "Q4_P1",
      "prompt": "Je mag bewegen.\nMaar niet alles is efficient.\n\nVraag:\nWat is de minimale route?",
      "hints": [
        "Kortste pad in raster.",
        "Geen diagonalen.",
        "Antwoord is een integer."
      ],
      "answer": "6",
      "inputType": "text",
      "xp": 25
    },
    {
      "id": "Q4_P2",
      "prompt": "De code spreekt.\n\nVraag:\nWat staat hier?",
      "hints": [
        "Hex -> ASCII.",
        "Vier letters.",
        "Begint met H."
      ],
      "answer": "HOLD",
      "inputType": "text",
      "xp": 25
    }
  ],
  "preFinale": {
    "summary": "Route minimum = 6 en code decode = HOLD.",
    "implication": "Jacht gaat minder over snelheid en meer over gecontroleerde timing."
  },
  "finalePrompt": "De route ligt open, de instructie is duidelijk.\nWat kies je nu?\n\nCONTROL / OBSERVE / INFLUENCE",
  "xpFinale": 75
}
$json$::jsonb,
    false,
    false
  ),
  (
    'oracle-05-waarheid',
    'PROJECT ORACLE — Quest 5 — De waarheid',
    $json$
{
  "intro": "PROJECT ORACLE — Q5 — De waarheid\n\nData:\nTOKENS = SILENT, DEAN, HIDE, VIREX, BLACK",
  "puzzles": [
    {
      "id": "Q5_P1",
      "prompt": "VIREX\n\nVraag:\nWat is de A1Z26 som?",
      "hints": [
        "A=1 ... Z=26.",
        "Tel alle letters op.",
        "Controleer X zorgvuldig."
      ],
      "answer": "78",
      "inputType": "text",
      "xp": 25
    },
    {
      "id": "Q5_P2",
      "prompt": "Neem letters:\nSILENT(1)\nDEAN(2)\nHIDE(3)\nVIREX(4)\nBLACK(5)\n\nVraag:\nWat vormt zich?",
      "hints": [
        "Neem exact die posities.",
        "Vijf letters totaal.",
        "Begint met S."
      ],
      "answer": "SEDEK",
      "inputType": "text",
      "xp": 25
    },
    {
      "id": "Q5_P3",
      "prompt": "Je dacht dat je het oploste.\n\nVraag:\nWat ben je geworden?",
      "hints": [
        "Systeemstatus.",
        "Engels woord.",
        "Begint met R."
      ],
      "answer": "REGISTERED",
      "inputType": "text",
      "xp": 25
    }
  ],
  "preFinale": {
    "summary": "VIREX -> 78, tokenconstructie -> SEDEK, eindstatus -> REGISTERED.",
    "implication": "De waarheid is niet wat je vond, maar hoe ORACLE jou classificeert."
  },
  "finalePrompt": "PROJECT ORACLE sluit niet af met zekerheid, maar met positionering.\nWat kies je als eindhouding?\n\nCONTROL / OBSERVE / INFLUENCE",
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
  campaign_slug = 'project-oracle',
  campaign_display_name = 'PROJECT ORACLE',
  sequence_idx = 1,
  next_control_id = (select id from public.quests where slug = 'oracle-02-sleutels' limit 1),
  next_observe_id = (select id from public.quests where slug = 'oracle-02-sleutels' limit 1),
  next_influence_id = (select id from public.quests where slug = 'oracle-02-sleutels' limit 1)
where slug = 'oracle-01-lek';

update public.quests
set
  campaign_slug = 'project-oracle',
  campaign_display_name = 'PROJECT ORACLE',
  sequence_idx = 2,
  next_control_id = (select id from public.quests where slug = 'oracle-03-stilte' limit 1),
  next_observe_id = (select id from public.quests where slug = 'oracle-03-stilte' limit 1),
  next_influence_id = (select id from public.quests where slug = 'oracle-03-stilte' limit 1)
where slug = 'oracle-02-sleutels';

update public.quests
set
  campaign_slug = 'project-oracle',
  campaign_display_name = 'PROJECT ORACLE',
  sequence_idx = 3,
  next_control_id = (select id from public.quests where slug = 'oracle-04-jacht' limit 1),
  next_observe_id = (select id from public.quests where slug = 'oracle-04-jacht' limit 1),
  next_influence_id = (select id from public.quests where slug = 'oracle-04-jacht' limit 1)
where slug = 'oracle-03-stilte';

update public.quests
set
  campaign_slug = 'project-oracle',
  campaign_display_name = 'PROJECT ORACLE',
  sequence_idx = 4,
  next_control_id = (select id from public.quests where slug = 'oracle-05-waarheid' limit 1),
  next_observe_id = (select id from public.quests where slug = 'oracle-05-waarheid' limit 1),
  next_influence_id = (select id from public.quests where slug = 'oracle-05-waarheid' limit 1)
where slug = 'oracle-04-jacht';

update public.quests
set
  campaign_slug = 'project-oracle',
  campaign_display_name = 'PROJECT ORACLE',
  sequence_idx = 5,
  next_control_id = null,
  next_observe_id = null,
  next_influence_id = null
where slug = 'oracle-05-waarheid';
