#!/usr/bin/env python3
"""Validate the versioned source for the Daymark GitHub Wiki."""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
WIKI = ROOT / "wiki"
REQUIRED_PAGES = {
    "Home.md",
    "_Sidebar.md",
    "_Footer.md",
    "Instalacao-e-atualizacao.md",
    "Primeiros-passos-e-senha.md",
    "Navegacao.md",
    "Today-Rapid-Logging-Reflexao-e-Undo.md",
    "Historico-e-Monthly.md",
    "Future.md",
    "Collections-migracao-e-referencias.md",
    "Trackers.md",
    "Search-e-Index.md",
    "Backup-e-Restore.md",
    "Open-Export.md",
    "Aparencia.md",
    "Suporte-e-privacidade.md",
}
WIKI_LINK = re.compile(r"\[\[(?:[^\]|]+\|)?([^\]#|]+)(?:#[^\]]+)?\]\]")
ASCII_FILENAME = re.compile(r"^[A-Za-z0-9_-]+\.md$")


def main() -> int:
    errors: list[str] = []
    pages = sorted(WIKI.glob("*.md"))
    page_names = {page.name for page in pages}

    missing = sorted(REQUIRED_PAGES - page_names)
    if missing:
        errors.append(f"Missing required pages: {', '.join(missing)}")

    unexpected_directories = sorted(path for path in WIKI.iterdir() if path.is_dir())
    if unexpected_directories:
        errors.append("Wiki source must remain flat: " + ", ".join(str(path.relative_to(ROOT)) for path in unexpected_directories))

    for page in pages:
        if not ASCII_FILENAME.fullmatch(page.name):
            errors.append(f"Non-ASCII or unsupported page filename: {page.name}")

        content = page.read_text(encoding="utf-8")
        if not content.strip():
            errors.append(f"Empty page: {page.name}")
            continue

        targets: list[str] = WIKI_LINK.findall(content)
        for target in targets:
            target_file = f"{target.strip().replace(' ', '-')}.md"
            if target_file not in page_names:
                errors.append(f"Broken Wiki link in {page.name}: {target}")

    if errors:
        print("Wiki validation failed:", file=sys.stderr)
        for error in errors:
            print(f"- {error}", file=sys.stderr)
        return 1

    print(f"Wiki validation passed: {len(pages)} pages and all internal links resolved.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
