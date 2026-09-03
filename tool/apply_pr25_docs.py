from pathlib import Path


def replace_once(path: str, old: str, new: str) -> None:
    file = Path(path)
    text = file.read_text()
    if text.count(old) != 1:
        raise SystemExit(f"Expected exactly one marker in {path}: {old[:80]!r}")
    file.write_text(text.replace(old, new, 1))


replace_once(
    "docs/PRODUCT.md",
    "Search remains a separate retrieval mechanism. A Search result does not become a persistent Index item unless the user makes an explicit future product action that says so.\n\n### Migration and scheduling",
    """Search remains a separate retrieval mechanism. A Search result does not become a persistent Index item unless the user makes an explicit future product action that says so.\n\n### Search\n\nSearch is an explicit local retrieval surface over existing Entry content. It is not another owner, Collection, or persistent catalog.\n\nThe first Search surface:\n\n- runs only after the user deliberately submits text;\n- performs case-insensitive literal substring matching over existing Entry content;\n- shows the result's real Entry type/Task state and owning Daily, Monthly, Future, or Collection context;\n- remains read-only and exposes no Task, migration, scheduling, reference, or ownership actions;\n- presents a quiet prompt before a query and a quiet empty state when nothing matches;\n- refreshes the last submitted query when the retained Search section becomes active again so Task state does not remain stale after work elsewhere.\n\nSearch does not create Entries, Collection references, or Index items. It does not persist query history, maintain a Search cache, or introduce a relevance/ranking engine in this slice. Direct navigation from a result to its source, Collection-title search, richer filtering, and any future full-text indexing remain separate product decisions.\n\n### Migration and scheduling""",
)

replace_once(
    "docs/DOMAIN.md",
    "The Index and Search are retrieval/navigation structures rather than owners of duplicated entry content.",
    "The Index and Search are retrieval/navigation structures rather than owners of duplicated entry content. A Search result is a transient view of an existing Entry and never changes that Entry's identity, owner, content, or Task state.",
)
replace_once(
    "docs/DOMAIN.md",
    "Search is not the Index. Search may derive transient results from journal content, while the Index persists structures that the user intentionally chose to catalog.\n\n## Migration",
    """Search is not the Index. Search may derive transient results from journal content, while the Index persists structures that the user intentionally chose to catalog.\n\n## Search\n\nSearch is a transient read model over existing journal Entries. Matching an Entry does not create a new Entry, placement, Collection reference, migration edge, or Index item.\n\nA Search result preserves and reports the source Entry's stable identity, entry type, Task state when applicable, and actual owning context. Daily, Monthly, Future, and Collection ownership remain authoritative; Search never becomes an owner itself.\n\nThe current product matches submitted text against Entry content only. Query interpretation, result ranking, filtering, Collection-title search, and navigation to the source are presentation/retrieval concerns that may evolve without changing ownership or history semantics.\n\n## Migration""",
)

replace_once(
    "docs/ARCHITECTURE.md",
    "Daily Log, Monthly Log, Future Log, Migration, Collections, and Index belong to one coherent journal domain rather than pretending they are unrelated products.",
    "Daily Log, Monthly Log, Future Log, Migration, Collections, Index, and Search belong to one coherent journal domain rather than pretending they are unrelated products.",
)
replace_once(
    "docs/ARCHITECTURE.md",
    "- focused Daily, Monthly, Future, Collection, and Index repository/session boundaries.",
    "- focused Daily, Monthly, Future, Collection, Index, and Search repository/session boundaries.",
)
replace_once(
    "docs/ARCHITECTURE.md",
    "The Index uses a focused `IndexRepository` over the existing encrypted `index_items` schema. Presentation reaches it through `JournalIndexSession` extension methods, which serialize list/candidate/add operations with `JournalSession.run(...)` so Index I/O cannot escape the unlocked session lifetime. The repository owns target existence, duplicate prevention, and global ordinal allocation; the widget only presents existing candidates and the user's deliberate choice.\n\nForward Task migration",
    """The Index uses a focused `IndexRepository` over the existing encrypted `index_items` schema. Presentation reaches it through `JournalIndexSession` extension methods, which serialize list/candidate/add operations with `JournalSession.run(...)` so Index I/O cannot escape the unlocked session lifetime. The repository owns target existence, duplicate prevention, and global ordinal allocation; the widget only presents existing candidates and the user's deliberate choice.\n\nSearch uses a focused read-only `JournalSearchRepository` against the existing encrypted schema. It joins Entries to their one owning placement and to the corresponding Log or Collection so results retain method-native context. The first implementation deliberately uses a bounded case-insensitive literal substring query (`instr(lower(content), lower(?))`) rather than introducing an FTS table, Search cache, or schema v2; a submitted query returns at most 100 Entries ordered by most recent update. Presentation reaches Search through `JournalSearchSession`, so query I/O remains serialized inside `JournalSession.run(...)`.\n\nBecause Search is retained by `StatefulShellRoute.indexedStack`, `SearchScreen` keeps only its last submitted query as presentation state and observes `AppSectionScope` reactivation. Returning to Search reruns that query silently so a Task changed elsewhere does not keep a stale symbol/state. This is presentation freshness, not polling or persisted Search history. Search results remain read-only and do not reproduce Task/movement/reference semantics.\n\nForward Task migration""",
)

replace_once(
    "CHANGELOG.md",
    "- Basic deliberate Index of existing Daily, Monthly, and Future Logs and Collections, preserving user-chosen Index order without duplicating journal content or deriving persistent items from Search.\n",
    "- Basic deliberate Index of existing Daily, Monthly, and Future Logs and Collections, preserving user-chosen Index order without duplicating journal content or deriving persistent items from Search.\n- Basic local Search over existing Entry content, showing read-only Daily, Monthly, Future, or Collection ownership context without creating Search history, duplicate content, references, or Index items.\n",
)
replace_once(
    "CHANGELOG.md",
    "- Portuguese parent localization resources include the journal-access, Daily Log, Monthly Log, Future Log, Collection, migration, reference, and Index strings used by the Brazilian Portuguese locale.",
    "- Portuguese parent localization resources include the journal-access, Daily Log, Monthly Log, Future Log, Collection, migration, reference, Index, and Search strings used by the Brazilian Portuguese locale.",
)
replace_once(
    "CHANGELOG.md",
    "- Retained Collections navigation now reloads its list, owned entries, and references when the section becomes active, so migrations or references created from another retained section appear without requiring lock, restart, or screen remount.\n",
    "- Retained Collections navigation now reloads its list, owned entries, and references when the section becomes active, so migrations or references created from another retained section appear without requiring lock, restart, or screen remount.\n- Retained Search reruns the last submitted query when its section becomes active, so result Task state reflects changes made elsewhere without polling or persisting Search history.\n",
)
