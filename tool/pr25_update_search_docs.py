from pathlib import Path

path = Path('docs/ARCHITECTURE.md')
text = path.read_text()
old = "The first implementation deliberately uses a bounded case-insensitive literal substring query (`instr(lower(content), lower(?))`) rather than introducing an FTS table, Search cache, or schema v2; a submitted query returns at most 100 Entries ordered by most recent update."
new = "The first implementation deliberately scans Entries in bounded ordered pages and performs Unicode-aware case-insensitive literal substring matching in Dart rather than relying on SQLite's ASCII-oriented `lower()` behavior or introducing an FTS table, Search cache, or schema v2; a submitted query returns at most 100 Entries ordered by most recent update."
if text.count(old) != 1:
    raise SystemExit('Expected exactly one Search query architecture marker.')
path.write_text(text.replace(old, new, 1))
