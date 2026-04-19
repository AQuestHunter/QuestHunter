"""One-off helper to regenerate questupdate_01.sql — run from snippets dir: python _build_questupdate_01.py"""
from pathlib import Path

root = Path(__file__).resolve().parent

header = """-- =============================================================================
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

"""


def extract_from_insert(text: str) -> str:
    i = text.index("insert into public.quests")
    return text[i:].rstrip() + "\n"


chunks = [
    ("PROJECT ORACLE — draft_project_oracle_quests.sql", "draft_project_oracle_quests.sql"),
    ("BLACK VAULT — draft_project_black_vault.sql", "draft_project_black_vault.sql"),
    ("PROTOCOL 17 — draft_project_protocol_17.sql", "draft_project_protocol_17.sql"),
    ("PROJECT ECHO — draft_project_echo.sql", "draft_project_echo.sql"),
]

out = [header]
for title, fn in chunks:
    body = extract_from_insert((root / fn).read_text(encoding="utf-8"))
    out.append("-- -----------------------------------------------------------------------------")
    out.append(f"-- {title}")
    out.append("-- -----------------------------------------------------------------------------")
    out.append("")
    out.append(body)
    out.append("")

out_path = root / "questupdate_01.sql"
out_path.write_text("\n".join(out), encoding="utf-8")
print("Wrote", out_path, "size", out_path.stat().st_size)
