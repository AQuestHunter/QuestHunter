-- PROJECT: DE KLUIS DIE NIET BESTAAT (Black Vault) — vernieuwde arc (Q1..Q5)
-- Gebaseerd op de aangeleverde campaign/system/quests spec, gemapt naar quest-hunter body schema.
-- Na uitvoeren: publiceer vensters in Admin en zet next-quests live.

insert into public.quests (slug, title, body, is_published, archived)
values
  (
    'black-vault-01-kaart',
    'De kluis die niet bestaat — Quest 1 — De kaart die niet bestaat',
    $json$
{
  "intro": "QUEST 1 — DE KAART DIE NIET BESTAAT\n\nCampaign: black-vault\nMechanics: base XP 30 per puzzle, hidden wrong-answer decay, hint costs 5/10/20, behavior tracking enabled, persistent errors enabled, branching enabled.\n\nInterrupt signatures:\n- two_wrong_answers: Correctie gedetecteerd. Je leert sneller na fouten dan gemiddeld.\n- fast_answer: Beslissing genomen in abnormaal korte tijd. Kans op gokgedrag stijgt.\n- pattern_detected: Herhalend gedrag vastgesteld. Je begint voorspelbaar te worden.\n- mid_game: We hebben al genoeg data om je volgende keuze te voorspellen.\n\nJe ziet drie systemen in dezelfde ruimte, maar ze bevestigen elkaar niet. Zoek de plek waar energie ontbreekt, zicht ontbreekt, maar activiteit niet.",
  "puzzles": [
    {
      "id": "Q1_P1",
      "data": {
        "energy_kwh": [[42, 12, 9, 55], [18, 0, 41, 20]],
        "thermal_delta": [1, 2, 6, 1],
        "camera": ["cam", "cam", "∅", "cam"]
      },
      "prompt": "Drie systemen. Zelfde ruimte.\n\nEr is een plek waar:\n- energie ontbreekt\n- zicht ontbreekt\n- maar activiteit niet\n\nWaar kijk je?",
      "hints": [
        "Zoek waar iets ontbreekt.",
        "0 kWh maar wel thermiek.",
        "Camera is daar ook leeg."
      ],
      "wrongFeedback": "Bijna. Kijk naar de cel waar afwezigheid in meerdere bronnen tegelijk samenvalt.",
      "answer": "B3",
      "inputType": "text",
      "xp": 30
    },
    {
      "id": "Q1_P2",
      "data": { "mail_tags": [1800, 2100, 5123] },
      "prompt": "De getallen zijn niet afzonderlijk relevant.\n\nZe krijgen betekenis als je ze samen bekijkt.\nNiet de waarde telt. De rest wel.\n\nWaar wijzen ze naartoe?",
      "hints": [
        "Tel ze op.",
        "Neem de laatste twee cijfers."
      ],
      "wrongFeedback": "Herbereken de som en map opnieuw naar hetzelfde rooster.",
      "answer": "B3",
      "inputType": "text",
      "xp": 30
    },
    {
      "id": "Q1_P3",
      "prompt": "De kluis is zichtbaar.\nDe toegang niet.\nPersoneel gebruikt ze dagelijks.\nMaar ze bestaat niet op papier.\n\nHoe noem je zo'n doorgang?",
      "hints": [
        "Denk operationeel, niet architectonisch.",
        "Technische passage buiten publieke route.",
        "Engels, 7 letters."
      ],
      "wrongFeedback": "Niet de kluis zelf. De verborgen operationele doorgang ernaast.",
      "answer": "SERVICE",
      "inputType": "text",
      "xp": 30
    }
  ],
  "preFinale": {
    "summary": "B3 komt terug via meerdere bronnen; SERVICE beschrijft de niet-geadministreerde route.",
    "implication": "De afwijking zit niet in de kluis, maar in de manier waarop toegang buiten papier bestaat."
  },
  "finalePrompt": "Kies je aanpak:\n\nCONTROL — forceer controle op de route.\nOBSERVE — lees de sporen zonder in te grijpen.\nINFLUENCE — manipuleer data zodat anderen verkeerd lopen.\n\nWelke keuze log je?",
  "xpFinale": 75,
  "ui": {
    "hintXpNote": "Hint tiers cost XP: 5 / 10 / 20. Hidden wrong-answer penalty and behavior tracking are active in this campaign.",
    "branches": {
      "CONTROL": { "title": "CONTROL", "description": "future_traps: true" },
      "OBSERVE": { "title": "OBSERVE", "description": "unlock_hidden_logs: true" },
      "INFLUENCE": { "title": "INFLUENCE", "description": "inject_false_data: true" }
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
  "intro": "QUEST 2 — DE SLEUTELS TOT NIETS\n\nOSINT layer: badge_dump.txt\nHidden clue: timestamp mismatch",
  "puzzles": [
    {
      "id": "Q2_P1",
      "data": { "cipher": "EENX", "key": "BANK" },
      "prompt": "Een naam.\nMaar alleen als je weet hoe het systeem kijkt.\n\nWie zit hierachter?",
      "hints": [
        "Gebruik BANK als sleutel.",
        "Vigenere decrypt per karakter.",
        "Resultaat is een voornaam."
      ],
      "wrongFeedback": "Je zit op de juiste methode. Controleer de sleutelrotatie per positie.",
      "answer": "DEAN",
      "inputType": "text",
      "xp": 30
    },
    {
      "id": "Q2_P2",
      "data": { "time": "17:40", "blocks": "4h segments" },
      "prompt": "Tijd is opgesplitst.\nNiet voor jou. Voor het systeem.\n\nWaar zit je werkelijk?",
      "hints": [
        "Werk met 4-uursblokken.",
        "17:40 valt in blok 16:00-20:00.",
        "Geef alleen het bloknummer."
      ],
      "wrongFeedback": "Als je CONTROL-profiel opbouwt, kan een 6 als valpad opduiken. Voor de baseline-resolutie blijft dit 5.",
      "answer": "5",
      "inputType": "text",
      "xp": 30
    },
    {
      "id": "Q2_P3",
      "prompt": "Een identiteit zou niet meer bestaan.\nMaar systemen registreren door.\n\nWelke naam bewijst dat?",
      "hints": [
        "Koppel aan de eerdere decrypt.",
        "Zoek de ghost identity.",
        "Zelfde naam als puzzel 1."
      ],
      "wrongFeedback": "De ghost identity is niet nieuw; je hebt hem al eerder gezien.",
      "answer": "DEAN",
      "inputType": "text",
      "xp": 30
    }
  ],
  "preFinale": {
    "summary": "Naam, tijdblok en ghost identity convergeren op DEAN + rotatie-index 5.",
    "implication": "Het systeem laat inconsistenties toe zolang ze bruikbare patronen opleveren."
  },
  "finalePrompt": "Wat doe je met ghost-credentials?\n\nCONTROL — forceer lockgedrag.\nOBSERVE — volg zonder touch.\nINFLUENCE — stuur met valse sleutelsporen.\n\nKies je pad.",
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
  "intro": "QUEST 3 — STILTE VOOR DE FOUT\n\nAnalyse-event: mid_game.\nInterrupt: We hebben al genoeg data om je volgende keuze te voorspellen.",
  "puzzles": [
    {
      "id": "Q3_P1",
      "data": "01001000 01001001 01000100 01000101",
      "prompt": "Dit is geen code.\nDit is intentie.\n\nWat gebeurt hier?",
      "hints": [
        "Converteer binair naar ASCII.",
        "Vier bytes, vier letters.",
        "Engels werkwoord."
      ],
      "wrongFeedback": "Bijna. Controleer bit-naar-letter mapping op bytegrenzen.",
      "answer": "HIDE",
      "inputType": "text",
      "xp": 30
    },
    {
      "id": "Q3_P2",
      "data": "-- .. ... ...",
      "prompt": "Sneller dan woorden.\nOuder dan systemen.\n\nWat wordt bevestigd?",
      "hints": [
        "Dit is morse.",
        "Vier letters.",
        "Begint met M."
      ],
      "wrongFeedback": "Lees teken voor teken; een punt/streep-verwisseling breekt het hele woord.",
      "answer": "MISS",
      "inputType": "text",
      "xp": 30
    },
    {
      "id": "Q3_P3",
      "data": ["OPEN", "OPEN", "OPEN", "SILENT", "OPEN"],
      "prompt": "Niet alles wat verandert is belangrijk.\nMaar dit wel.\n\nWaar breekt het?",
      "hints": [
        "Zoek de afwijking in de reeks.",
        "Eerste niet-OPEN token.",
        "Exact overnemen."
      ],
      "wrongFeedback": "Je zoekt de patroonbreuk, niet de meerderheid.",
      "answer": "SILENT",
      "inputType": "text",
      "xp": 30
    },
    {
      "id": "Q3_P4",
      "prompt": "Alarmen trekken aandacht.\nStilte verzamelt data.\n\nWat gebeurt er echt?",
      "hints": [
        "Denk in systeemactie, niet emotie.",
        "Het doel is observatie van gedrag.",
        "Kies de sterkste kernterm."
      ],
      "wrongFeedback": "Je zit in de juiste semantische zone. Kies de primaire systeemfunctie.",
      "answer": "MONITORING",
      "inputType": "choice",
      "choices": ["MONITORING", "TRACKING", "LOGGING"],
      "xp": 30
    }
  ],
  "preFinale": {
    "summary": "HIDE, MISS, SILENT en MONITORING vormen een consistente gedragsmeting-keten.",
    "implication": "Stilte is geen afwezigheid; het is een actieve meetmodus."
  },
  "finalePrompt": "Analyse voltooid. Gedragspatroon opgeslagen.\n\nCONTROL — breek de lus.\nOBSERVE — laat het systeem praten.\nINFLUENCE — voer modelruis in.\n\nWelke zet registreer je?",
  "xpFinale": 75
}
$json$::jsonb,
    false,
    false
  ),
  (
    'black-vault-04-jacht',
    'De kluis die niet bestaat — Quest 4 — Jacht of val',
    $json$
{
  "intro": "QUEST 4 — JACHT OF VAL",
  "puzzles": [
    {
      "id": "Q4_P1",
      "data": ["·#···", "··#··", "S··#·", "·····", "···#X"],
      "prompt": "Je mag bewegen.\nMaar vrijheid is niet hetzelfde als controle.\n\nWat is het minimum?",
      "hints": [
        "Kortste pad in het raster.",
        "Geen diagonalen.",
        "Trap answer is 5."
      ],
      "wrongFeedback": "Bijna. Je moet een blokkade extra omzeilen.",
      "answer": "6",
      "inputType": "text",
      "xp": 30
    },
    {
      "id": "Q4_P2",
      "data": "48 4F 4C 44",
      "prompt": "De deur zegt niets.\nMaar de instructie wel.\n\nWat wordt verwacht?",
      "hints": [
        "Hex naar ASCII.",
        "Vier letters.",
        "Begint met H."
      ],
      "wrongFeedback": "Controleer de laatste byte opnieuw.",
      "answer": "HOLD",
      "inputType": "text",
      "xp": 30
    },
    {
      "id": "Q4_P3",
      "data": { "A": 0, "B": 40, "C": 20 },
      "prompt": "Volgorde is een illusie.\n\nWat klopt niet?",
      "hints": [
        "Sorteer op tijd: 0, 20, 40.",
        "Vergelijk met de geobserveerde volgorde.",
        "De out-of-place label is B."
      ],
      "wrongFeedback": "Kijk naar de positie, niet alleen naar de waarden.",
      "answer": "B",
      "inputType": "choice",
      "choices": ["A", "B", "C"],
      "xp": 30
    },
    {
      "id": "Q4_P4",
      "prompt": "Je dacht dat je ontsnapte.\nMaar je werd geselecteerd.\n\nWaarvoor?",
      "hints": [
        "Systeemdoel, geen menselijk motief.",
        "Denk in classificatie.",
        "Kernwoord: FILTER."
      ],
      "wrongFeedback": "Je antwoord zit dichtbij: het gaat om selectie als mechanisme.",
      "answer": "FILTER",
      "inputType": "choice",
      "choices": ["FILTER", "SELECTION"],
      "xp": 30
    }
  ],
  "preFinale": {
    "summary": "Pad, instructie, volgorde-anomalie en selectieclaim vormen een testketen.",
    "implication": "Jacht en val blijken hetzelfde systeemproces vanuit verschillende perspectieven."
  },
  "finalePrompt": "Wat doe je met het systeem dat jou selecteerde?\n\nCONTROL — stap erin.\nOBSERVE — verdwijn uit zicht.\nINFLUENCE — blijf, maar gemarkeerd.\n\nWelke keuze registreer je?",
  "xpFinale": 75
}
$json$::jsonb,
    false,
    false
  ),
  (
    'black-vault-05-waarheid',
    'De kluis die niet bestaat — Quest 5 — De waarheid',
    $json$
{
  "intro": "QUEST 5 — DE WAARHEID\n\nJe aarzelde bij cruciale momenten.\nJe koos vaker voor controle dan voor observatie.\nJe fouten daalden naarmate je verder ging.\nDat betekent dat je leert.\nDat betekent dat je bruikbaar bent.",
  "puzzles": [
    {
      "id": "Q5_P1",
      "data": "VIREX",
      "prompt": "Geen naam.\nEen sleutel.\n\nWat is zijn waarde?",
      "hints": [
        "A1Z26.",
        "Som van letters.",
        "Uitkomst is 78."
      ],
      "wrongFeedback": "Controleer de letterposities opnieuw, inclusief X.",
      "answer": "78",
      "inputType": "text",
      "xp": 30
    },
    {
      "id": "Q5_P2",
      "prompt": "Alles wat je nodig had was verspreid.\nNiet verborgen. Niet duidelijk.\n\nWat vormt zich als je het samenbrengt?",
      "hints": [
        "Gebruik de samengestelde sleutel.",
        "Vijf letters.",
        "Begint met S."
      ],
      "wrongFeedback": "Het is geen anagram; het is een geconstrueerde sleutelstring.",
      "answer": "SEDEK",
      "inputType": "text",
      "xp": 30
    },
    {
      "id": "Q5_P3",
      "prompt": "Je hebt niets gebroken.\nJe hebt niets gestolen.\nJe hebt alleen gedaan wat verwacht werd.\n\nWat ben je nu?",
      "hints": [
        "Systeemstatus, niet identiteit.",
        "Engels woord.",
        "Begint met R."
      ],
      "wrongFeedback": "Denk aan hoe systemen iemand markeren na succesvolle deelname.",
      "answer": "REGISTERED",
      "inputType": "text",
      "xp": 30
    }
  ],
  "preFinale": {
    "summary": "VIREX -> 78, sleutelstring -> SEDEK, status -> REGISTERED.",
    "implication": "De kluis beschermde geen object. Ze profileerde deelnemers."
  },
  "finalePrompt": "CONTROL — Je wordt onderdeel van het systeem.\nOBSERVE — Je verdwijnt uit het systeem.\nINFLUENCE — Je blijft, maar wordt gemarkeerd.\n\nWat kies je als eindstatus?",
  "xpFinale": 100,
  "ui": {
    "branches": {
      "CONTROL": { "title": "CONTROL", "description": "Je wordt onderdeel van het systeem." },
      "OBSERVE": { "title": "OBSERVE", "description": "Je verdwijnt uit het systeem." },
      "INFLUENCE": { "title": "INFLUENCE", "description": "Je blijft, maar wordt gemarkeerd." }
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

-- Campaign koppeling (lineair: alle finale-takken -> zelfde vervolg)
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
