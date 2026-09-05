from pathlib import Path


def replace_once(path: str, old: str, new: str) -> None:
    file = Path(path)
    text = file.read_text()
    count = text.count(old)
    if count != 1:
        raise SystemExit(f"{path}: expected one match, found {count}: {old[:80]!r}")
    file.write_text(text.replace(old, new, 1))


# PRODUCT: keep the method-native Monthly Log distinct from the Daymark adaptation.
replace_once(
    "docs/PRODUCT.md",
    """Today remains the interactive current Daily Log. Navigating historical dates is retrieval over existing chronology, not a change of Entry ownership or an alternative calendar model.\n\nThis history surface is retrieval, not a generic calendar workspace or reflection engine. Search and Index source navigation use the real historical Daily route for past dates while the current Daily Log continues to resolve to Today.\n""",
    """Today remains the interactive current Daily Log. Navigating historical dates is retrieval over existing chronology, not a change of Entry ownership or an alternative calendar model.\n\nActive Daymark Trackers may appear in Today as a compact `+ / -` marking surface. A Tracker is not a Daily Entry and does not create a Task per day; this is an optional Daymark adaptation whose provenance and limits are documented in `docs/TRACKERS.md`.\n\nThis history surface is retrieval, not a generic calendar workspace or reflection engine. Search and Index source navigation use the real historical Daily route for past dates while the current Daily Log continues to resolve to Today.\n""",
)
replace_once(
    "docs/PRODUCT.md",
    """Monthly preserves the method's two different areas:\n\n- **Calendar**: one row per date, with dated Event entries;\n- **Tasks**: a monthly Task list.\n\nThe **current month** remains the active Monthly Log and supports capture plus deliberate Task actions.\n""",
    """Monthly preserves the method's two method-native areas:\n\n- **Calendar**: one row per date, with dated Event entries;\n- **Tasks**: a monthly Task list.\n\nDaymark additionally hosts an optional **Tracker** section on the Monthly surface. Tracker is a Daymark-specific digital adaptation for finite daily commitments and reflection; it is not a third canonical Monthly Log entry-placement type and must not be presented as an official Ryder Carroll rule. Its exact semantics, maintainer origin, five-color graph, and exclusions are documented in `docs/TRACKERS.md`.\n\nThe **current month** remains the active Monthly Log and supports capture plus deliberate Task actions. The current Tracker view may create, mark, and deliberately end Trackers; historical Monthly views may display intersecting Tracker history but remain read-only.\n""",
)

# DOMAIN: Tracker is intentionally separate from the core Entry/Log ownership model.
replace_once(
    "docs/DOMAIN.md",
    """Capturing a new entry directly in Future is different from scheduling an existing entry into Future. Scheduling must create deliberate migration lineage.\n\n## Index\n""",
    """Capturing a new entry directly in Future is different from scheduling an existing entry into Future. Scheduling must create deliberate migration lineage.\n\n## Trackers (optional Daymark adaptation)\n\nA Tracker is a separate finite observation/commitment entity. It is **not** an `EntryType`, Task state, Log, Collection, placement, migration destination, or Index target. The core Bullet Journal ownership model therefore remains unchanged.\n\nA Tracker has a deliberate start date, planned end date, one stable visual slot, and an optional deliberate early-end date. Its effective data interval is inclusive from start through the planned or early end. Outside that interval there is no Tracker datum.\n\nOnly explicit daily outcomes are persisted:\n\n- `+1` means the user explicitly marked the commitment fulfilled;\n- `-1` means the user explicitly marked it not fulfilled;\n- absence of an explicit mark is rendered as `0` inside the active interval.\n\n`0` is not a persisted outcome and must not be reinterpreted as failure. Removing a `+1` or `-1` mark returns the date to absence.\n\nEnding a Tracker early preserves history through the chosen end date and removes any marks that would lie after the new effective end. Continuing a finished Tracker requires another deliberate action; Daymark does not automatically renew it.\n\nThe combined graph and five fixed visual slots are presentation/product constraints of the Daymark adaptation, not canonical Bullet Journal semantics. See `docs/TRACKERS.md` for provenance, responsive behavior, and exclusions.\n\n## Index\n""",
)

# DATA MODEL: retain published v1 as history and document the additive v2 contract.
replace_once(
    "docs/DATA_MODEL.md",
    """The Index stores references to journal structures, not duplicated entry content.\n\n## Deliberately absent from schema v1\n""",
    """The Index stores references to journal structures, not duplicated entry content.\n\n## Schema version 2\n\nSchema version 2 is the first post-`v1.0.0-alpha.2` migration and extends published schema v1 additively for the optional Daymark Tracker adaptation. Existing v1 tables and semantic values are not reinterpreted.\n\n### `trackers`\n\nStores one finite Tracker independently from Bullet Journal Entries and placements.\n\nFields:\n\n- `id` — UUID v7 primary key;\n- `title` — non-empty user content;\n- `start_date` — inclusive ISO method date;\n- `planned_end_date` — inclusive ISO method date, not earlier than `start_date`;\n- `ended_date` — nullable inclusive early-end method date between start and planned end;\n- `color_slot` — stable integer visual slot `0..4`;\n- `created_at` — UTC microseconds;\n- `updated_at` — UTC microseconds.\n\nA Tracker's effective end is `ended_date` when present, otherwise `planned_end_date`. The persisted slot keeps one visual identity for the Tracker across the months it intersects. Version 1 of the feature requires one slot to be available across the entire proposed period; this deliberately favors stable color identity over recoloring existing Tracker history.\n\n### `tracker_marks`\n\nStores only explicit daily Tracker outcomes.\n\nFields / primary key:\n\n- `tracker_id` — foreign key to `trackers`, cascading when that Tracker is explicitly destroyed;\n- `method_date` — ISO method date;\n- `value` — exactly `-1` or `1`;\n- `created_at` — UTC microseconds;\n- `updated_at` — UTC microseconds;\n- primary key `(tracker_id, method_date)`.\n\nThere is deliberately no persisted zero row. Inside the Tracker's effective interval, absence of a row means `0` / no explicit mark. Outside the interval there is no datum at all. Repository validation rejects marks outside the Tracker interval.\n\n### Migration from v1\n\nThe v1-to-v2 migration uses Drift's generated versioned-schema helper and creates `trackers`, `tracker_marks`, and their declared indexes without rewriting v1 journal rows. CI retains the v1 and v2 schema snapshots and migration verification. A representative v1 journal is migrated in tests to prove existing data survives while the new Tracker tables begin empty.\n\n## Deliberately absent from schema v1\n""",
)
replace_once(
    "docs/DATA_MODEL.md",
    """Schema version 1 is published in `v1.0.0-alpha.2`. The earlier pre-publication freedom to regenerate an unreleased schema no longer applies to the supported release line.\n\nAny later build that claims to support alpha.2 data must have an explicit tested path from published schema v1. A future schema version may migrate forward, but it must not silently reinterpret semantic values, delete journal content, or solve incompatibility by deleting/recreating the database.\n""",
    """Schema version 1 is published in `v1.0.0-alpha.2`. The earlier pre-publication freedom to regenerate an unreleased schema no longer applies to the supported release line.\n\nSchema version 2 is the current additive Tracker migration. Its supported predecessor is published schema v1, and that exact upgrade path is retained in Drift schema snapshots and migration tests.\n\nAny later build that claims to support alpha.2 data must have an explicit tested path from published schema v1. A future schema version may migrate forward, but it must not silently reinterpret semantic values, delete journal content, or solve incompatibility by deleting/recreating the database.\n""",
)

# OPEN EXPORT: v1 remains historical; v2 adds Tracker records explicitly.
replace_once("docs/OPEN_EXPORT_FORMAT.md", "## JSON format v1", "## JSON format v2")
replace_once(
    "docs/OPEN_EXPORT_FORMAT.md",
    """- `formatVersion`: `1`;\n- `databaseSchemaVersion`: the Daymark database schema version used to interpret the exported records;\n""",
    """- `formatVersion`: `2`;\n- `databaseSchemaVersion`: the Daymark database schema version used to interpret the exported records;\n""",
)
replace_once(
    "docs/OPEN_EXPORT_FORMAT.md",
    """- `entrySignifiers`;\n- `indexItems`.\n\nField names are language-neutral camelCase keys. Stable IDs, Task states, owners, ordering fields, migration lineage, Collection references, signifier relationships, and Index targets are preserved rather than flattened into display text.\n""",
    """- `entrySignifiers`;\n- `indexItems`;\n- `trackers`;\n- `trackerMarks`.\n\nField names are language-neutral camelCase keys. Stable IDs, Task states, owners, ordering fields, migration lineage, Collection references, signifier relationships, Index targets, Tracker periods/visual slots, and explicit Tracker marks are preserved rather than flattened into display text. `0` Tracker values are not exported as synthetic rows because the Tracker model persists only explicit `+1` and `-1` marks.\n""",
)
replace_once("docs/OPEN_EXPORT_FORMAT.md", "## Markdown format v1", "## Markdown format v2")
replace_once(
    "docs/OPEN_EXPORT_FORMAT.md",
    """Version 1 is published in `v1.0.0-alpha.2` with database schema version 1.\n\nA future Daymark release may add a new Open Export format version, but it must not silently reinterpret the meaning of version-1 keys. If backward machine readability is claimed, compatibility must be explicit and tested.\n""",
    """Version 1 is published in `v1.0.0-alpha.2` with database schema version 1. Its keys retain their published meaning.\n\nVersion 2 accompanies database schema version 2 and adds `trackers` and `trackerMarks` after the version-1 sections. This is an explicit format-version change rather than silently changing the version-1 machine-readable contract.\n\nA future Daymark release may add another Open Export format version, but it must not silently reinterpret the meaning of published keys. If backward machine readability is claimed, compatibility must be explicit and tested.\n""",
)

# TRACKERS: make the stable-slot consequence explicit instead of hiding it.
replace_once(
    "docs/TRACKERS.md",
    """The five visual identities are fixed slots. Version 1 does not expose a color picker. A slot may be reused by another Tracker only when their active periods do not overlap.\n""",
    """The five visual identities are fixed slots. Version 1 does not expose a color picker. A slot may be reused by another Tracker only when their active periods do not overlap. To keep one Tracker's color stable across its whole history, creation requires one slot to be free for the Tracker's entire proposed period; in unusual fragmented schedules this can be stricter than merely counting five Trackers on each individual day. Version 1 deliberately prefers stable visual identity over silently recoloring existing Tracker history.\n""",
)

# CHANGELOG: release-facing visibility and compatibility.
replace_once(
    "CHANGELOG.md",
    """- Open Export can copy the selected Markdown or JSON representation directly to the system clipboard.\n""",
    """- Open Export can copy the selected Markdown or JSON representation directly to the system clipboard.\n- Optional finite Monthly Trackers add deliberate daily `+ / -` marking, a combined five-color `+1 / 0 / -1` reflection graph, early ending, historical read-only viewing, and compact active-Tracker controls in Today.\n- Database schema v2 adds persisted Tracker periods and explicit `+1 / -1` marks with a tested additive migration from the published alpha.2 schema v1.\n""",
)
replace_once(
    "CHANGELOG.md",
    """- Open Export now uses one format selector with Copy and Save actions rather than separate format-specific save buttons.\n""",
    """- Open Export now uses one format selector with Copy and Save actions rather than separate format-specific save buttons.\n- Open Export advances to format version 2 and includes Tracker periods plus explicit Tracker marks while preserving the published meaning of version-1 fields.\n""",
)

# PROJECT: align living handoff with PR37/main, current Tracker work, and the established merge boundary.
replace_once(
    "PROJECT.md",
    """- Reflection and Rapid Logging UX merged via PR #36 as current `main` commit `0b7c79c96a17f76479aa81ea7002ab7c0971028c`.\n- PR #36 Ready CI #482 passed on exact head `596b4ad678a2d08a9e7f5d60f1ef847eabd2abd9`; post-merge `main` CI #483 passed on exact squash SHA `0b7c79c96a17f76479aa81ea7002ab7c0971028c`.\n- Current development branch: `feat/security-and-next-release`, adding Open Export reauthentication and clipboard output before the next prerelease preparation.\n""",
    """- Reflection and Rapid Logging UX merged via PR #36 as `main` commit `0b7c79c96a17f76479aa81ea7002ab7c0971028c`.\n- PR #36 Ready CI #482 passed on exact head `596b4ad678a2d08a9e7f5d60f1ef847eabd2abd9`; post-merge `main` CI #483 passed on exact squash SHA `0b7c79c96a17f76479aa81ea7002ab7c0971028c`.\n- Security/Open Export/session-lock work merged via PR #37 as current `main` commit `70a4206ccaf7d29f83a89c29f16abbb25baffcc7`. PR #37 Ready CI #484 passed on exact head `6e91e4a64c7e8589bac0f9df325c35571512ee9a`; post-merge `main` CI #485 passed on the squash SHA.\n- Current development branch: `feat/monthly-trackers`, PR #38 (Draft), implementing the explicitly documented optional Daymark Tracker adaptation and schema v2 from exact `main` `70a4206ccaf7d29f83a89c29f16abbb25baffcc7`.\n""",
)
replace_once(
    "PROJECT.md",
    """- Merge policy: never merge without explicit user approval; squash merge is the default.\n""",
    """- Merge policy: ordinary technically Ready PRs may be squash-merged under standing user authorization after exact-head required CI and `merge-gate` are green; release/tag/artifact publication remains an explicit user-approval boundary.\n""",
)
replace_once(
    "PROJECT.md",
    """- primary navigation concepts are Today, Monthly, Future, Collections, Search, and Index; compact layouts group Search/Index behind More without merging their meaning.\n""",
    """- primary navigation concepts are Today, Monthly, Future, Collections, Search, and Index; compact layouts group Search/Index behind More without merging their meaning;\n- optional Daymark-specific adaptations such as Tracker must be labeled as adaptations, preserve the core method model, and document provenance instead of being presented as canonical Bullet Journal rules.\n""",
)
replace_once(
    "PROJECT.md",
    """- The user makes every merge and release-promotion decision. Never enable auto-merge or merge/publish implicitly.\n""",
    """- Ordinary technically Ready PRs may be squash-merged under the user's standing authorization only after exact-head required CI and `merge-gate` are green. Release/tag/artifact publication and promotion still require explicit user approval. Never enable auto-merge or publish implicitly.\n""",
)
replace_once(
    "PROJECT.md",
    """12. merge only after exact-head CI is green and the user explicitly approves squash merge.\n""",
    """12. squash-merge an ordinary Ready PR only after exact-head CI is green under the standing authorization; stop for explicit user approval before any release/tag/artifact publication or promotion.\n""",
)
replace_once("PROJECT.md", "Schema v1 contains:\n", "Published schema v1 contains:\n")
replace_once(
    "PROJECT.md",
    """- `index_items`\n\nDurable rules:\n""",
    """- `index_items`\n\nCurrent development schema v2 extends that published baseline additively with:\n\n- `trackers`;\n- `tracker_marks`.\n\nThe v1-to-v2 path is represented by retained Drift schema snapshots, generated versioned migration helpers, and migration tests that preserve representative v1 journal data.\n\nDurable rules:\n""",
)
replace_once(
    "PROJECT.md",
    """- `JournalSession` serializes unlocked journal work and owns encrypted persistence/key lifetime.\n""",
    """- `JournalSession` serializes unlocked journal work and owns encrypted persistence/key lifetime;\n- Trackers are separate optional finite entities: explicit marks persist only `+1 / -1`, absence renders as `0` inside the effective period, and the feature never creates a daily Task or changes Entry ownership.\n""",
)
replace_once(
    "PROJECT.md",
    """Schema v1 is now a published compatibility boundary because `v1.0.0-alpha.2` ships real user-journal support. Future supported builds must provide explicit tested compatibility/migration paths rather than silently regenerating or resetting published data.\n""",
    """Schema v1 is now a published compatibility boundary because `v1.0.0-alpha.2` ships real user-journal support. Current schema v2 therefore migrates forward explicitly and additively; future supported builds must continue to provide tested compatibility/migration paths rather than silently regenerating or resetting published data.\n""",
)
replace_once(
    "PROJECT.md",
    """- Android release builds fail closed if dedicated release signing is absent and never silently use debug signing.\n""",
    """- Android release builds fail closed if dedicated release signing is absent and never silently use debug signing;\n- Android screen-off and Linux systemd-logind session-lock events request immediate lock through the same serialized journal-session path as manual/inactivity locking.\n""",
)

# Export tests: prove v2 carries the new data instead of only bumping a number.
replace_once(
    "test/export/open_export_service_test.dart",
    """      final Map<String, Object?> indexItem = _maps(payload['indexItems'])\n          .single;\n      expect(indexItem['collectionId'], 'collection-1');\n""",
    """      final Map<String, Object?> indexItem = _maps(payload['indexItems'])\n          .single;\n      expect(indexItem['collectionId'], 'collection-1');\n\n      final Map<String, Object?> tracker = _maps(payload['trackers']).single;\n      expect(tracker['id'], 'tracker-1');\n      expect(tracker['title'], 'Leitura diária');\n      expect(tracker['startDate'], '2026-09-01');\n      expect(tracker['plannedEndDate'], '2026-09-30');\n      expect(tracker['colorSlot'], 2);\n\n      final Map<String, Object?> trackerMark = _maps(\n        payload['trackerMarks'],\n      ).single;\n      expect(trackerMark['trackerId'], 'tracker-1');\n      expect(trackerMark['methodDate'], '2026-09-04');\n      expect(trackerMark['value'], 1);\n""",
)
replace_once(
    "test/export/open_export_service_test.dart",
    """  await database.customStatement('''\n    INSERT INTO index_items (\n      id, ordinal, log_id, collection_id, created_at\n    ) VALUES ('index-1', 0, NULL, 'collection-1', 70)\n    ''');\n}\n""",
    """  await database.customStatement('''\n    INSERT INTO index_items (\n      id, ordinal, log_id, collection_id, created_at\n    ) VALUES ('index-1', 0, NULL, 'collection-1', 70)\n    ''');\n  await database.customStatement('''\n    INSERT INTO trackers (\n      id, title, start_date, planned_end_date, ended_date, color_slot,\n      created_at, updated_at\n    ) VALUES (\n      'tracker-1', 'Leitura diária', '2026-09-01', '2026-09-30', NULL, 2,\n      80, 80\n    )\n    ''');\n  await database.customStatement('''\n    INSERT INTO tracker_marks (\n      tracker_id, method_date, value, created_at, updated_at\n    ) VALUES ('tracker-1', '2026-09-04', 1, 81, 81)\n    ''');\n}\n""",
)
