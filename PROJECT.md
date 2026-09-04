# Daymark project checkpoint

This is Daymark's canonical living handoff. Read this file and `AGENTS.md` before meaningful work. Update it before handing work off. The repository, not a chat transcript, is the project memory.

## Current state

- Phase: pre-alpha, core Bullet Journal flows in active development.
- Integration branch: `main` only.
- Current merged `main`: `04daa185a6db3cc2a8588ab71a1327a91f893639` (`feat(journal): browse monthly history (#24)`).
- Post-merge `main` CI #400 is green on that exact SHA.
- Active branch/PR: `feat/basic-search` / PR #25, `feat(journal): add basic local search`.
- PR #25 remains Draft until exact-head Draft CI and manual Linux validation are complete.
- Runtime targets: Linux and Android.
- Pinned toolchain: Flutter 3.47.2 / Dart 3.13.2.
- Merge policy: never merge without explicit user approval; squash merge is the default.
- Production Argon2id baseline: 19 MiB / 2 iterations / p=1 / 32-byte output.
- Last updated: 2026-09-03 (America/Sao_Paulo).

## Product doctrine

Daymark is a faithful digital Bullet Journal, not a generic productivity suite.

- local-first and offline-first;
- digital minimalism and low distraction;
- no feeds, ads, streaks, XP, productivity scoring, gamification, or attention-seeking UI;
- no automatic choices that replace deliberate reflection;
- no generic planner/Kanban/workspace abstractions merely because digital software can support them;
- English is canonical/fallback; exact `pt_BR` is the first additional locale;
- primary navigation concepts are Today, Monthly, Future, Collections, Search, and Index; compact layouts group Search/Index behind More without merging their meaning.

## Mandatory working rules

- `main` is the only permanent integration branch. Use short-lived branches and PRs.
- PR titles use Conventional Commit form.
- The user makes every merge decision. Never enable auto-merge or merge implicitly.
- Repository/API/CI work is assistant-owned. Do not use the user as a routine CI, formatter, or test runner.
- Ask the user to run locally only when genuine product/platform behavior needs manual validation.
- Keep `PROJECT.md` current and `CHANGELOG.md` release-facing.
- Run `flutter gen-l10n` after ARB changes.
- Treat formatter output from the pinned Dart version as authoritative.
- Treat CI evidence as SHA-specific. A green superseded run does not validate a newer head.
- Distinguish mechanical CI/test-harness failures from product defects before changing behavior.
- Never weaken security, persistence invariants, tests, or CI merely to make a check green.
- Remove temporary workflow probes/scripts before Ready.
- User shell blocks must be safe for an interactive shell and must not end with a bare `exit`.
- Do not invent fake product destinations or temporary domain concepts to unblock UI.
- Do not duplicate repository/service semantics inside widgets/providers.

## Critical retained-navigation lifecycle rule

The router uses `StatefulShellRoute.indexedStack`, so top-level sections remain mounted while inactive.

Therefore:

- returning to a section does not imply another `initState()`;
- a retained screen whose data can become stale because of work elsewhere must refresh when it becomes active;
- `AppSectionScope` is the current presentation-level activation signal;
- do not solve freshness by destroying all tabs, polling continuously, or adding an unrelated global cache.

This rule first mattered for Future after scheduling, then Collections after migration/references, and PR #25 applies it to Search by rerunning the last submitted query on reactivation.

## Stable domain and persistence baseline

Schema v1 contains:

- `journal_metadata`
- `logs`
- `collections`
- `entries`
- `entry_placements`
- `migrations`
- `collection_references`
- `signifiers`
- `entry_signifiers`
- `index_items`

Durable rules:

- Task, Event, and Note are distinct entry types.
- Task states are open, completed, migrated, scheduled, and discarded.
- Events and Notes do not acquire Task state.
- Every Entry has exactly one owning placement.
- Monthly Calendar/Tasks placement and date invariants are enforced.
- Future is month-addressed, not a second day-level calendar.
- A Collection is a simple method-native owning container, not a configurable workspace.
- Collection references do not move the source Entry and remain distinct from migration.
- Scheduling (`<`) targets Future.
- Forward migration (`>`) currently targets an explicitly selected existing Collection.
- Movement preserves the historical source and creates a fresh destination Entry plus lineage; do not move ownership in place.
- Index deliberately catalogs an existing Log or Collection and never duplicates Entry content.
- Search is transient read-only retrieval over existing Entries and is never an owner or persistent Index source.
- Historical Monthly lookup is non-mutating; viewing a missing past month must not create a Log or Index candidate.
- Cross-table semantic writes remain transactional through repository/service boundaries.
- `JournalSession` serializes unlocked journal work and owns encrypted persistence/key lifetime.

## Security / backup baseline

Do not casually modify these contracts. Authoritative details live in `SECURITY.md`, `docs/SECURITY_FOUNDATION.md`, `docs/BACKUP_FORMAT.md`, and `docs/ARCHITECTURE.md`.

Current foundation includes:

- SQLite3MultipleCiphers ChaCha20-Poly1305 encrypted persistence;
- random 48-byte SQLite material: 32-byte journal key + 16-byte cipher salt;
- master password never used directly as the SQLite key and never persisted;
- Argon2id-derived KEK + XChaCha20-Poly1305 versioned key envelope;
- explicit mutable key-material destruction where practical;
- Android OS backup/device-transfer exclusion;
- portable authenticated encrypted backup with integrity and rollback/recovery protections.

PRs #20 through #25 do not change schema version, crypto, key lifecycle, backup format, dependency set, or platform contracts.

## Merged product baseline

### PR #13

Encrypted create/unlock/manual-lock flow and functional Today/Daily Log with Rapid Logging Task/Event/Note, serialized session, persistence, and day rollover.

### PR #14

Automatic five-minute inactivity lock. Squash: `d93563184c01ef406398619212410c540d00712a`.

### PR #15

Deliberate Task completion/discard. Squash: `b3af861dc00b81402d27cbdec39e3c99212c6590`.

Task symbols established: open `•`, completed `×`, migrated `>`, scheduled `<`, discarded historical `•` with strike-through.

### PR #16

Current-month Monthly Log with Calendar and Tasks. Squash: `c93b78380f0efdd545d533db49b30ab2f907426b`.

### PR #17

Rolling six-month Future Log. Squash: `8a9a74bb5158159818822487e71fcc220a0acbf8`.

### PR #18

Deliberate scheduling (`<`) from Today/Monthly into real Future months. Squash: `03ef4d187845ff13128f28298336b540b3237e9e`.

Important method decision: Today -> current Monthly is not a valid shortcut for `>`.

### PR #20

Basic Collections. Squash: `08199af85df7d10ba36b226d97b390da3acffbb9`.

### PR #21

Deliberate Task migration (`>`) from Today/Monthly into an explicitly selected existing Collection. Squash: `89c1907d17d0507fd84c403c7343afc2ccbbd8da`.

### PR #22

Deliberate read-only Collection references from chronological entries. Squash: `23fbc3e0b8d3e62f8db8ddc1ad403835e8fc5eee`.

### PR #23

Basic deliberate Index of existing Logs and Collections. Squash: `1a05c1cd71c2f442a538d21b2263ed39ed09efbe`.

- deliberate persisted order;
- duplicates rejected;
- no Entry duplication/state/ownership change;
- desktop exposes Search/Index directly; compact navigation exposes both through More;
- Index remains distinct from Search.

### PR #24

Read-only historical Monthly browsing. Squash: `04daa185a6db3cc2a8588ab71a1327a91f893639`.

- browse backward month by month;
- never browse forward past the current month;
- current month stays interactive;
- historical months are read-only;
- visiting a missing past month does not create a Monthly Log or Index candidate;
- manual Linux validation passed;
- final Ready CI #399 green;
- post-merge main CI #400 green.

## Active PR #25: basic local Search

Branch: `feat/basic-search`.

PR: #25, `feat(journal): add basic local search`.

Implemented scope:

- Search placeholder replaced by a real Search surface;
- explicit user-submitted queries only, not live-as-you-type search;
- case-insensitive literal substring matching against existing `entries.content`;
- no FTS table, schema v2, Search cache, or persisted query history;
- one query returns at most 100 results, ordered by Entry update time;
- result read model reports stable Entry identity, type, Task state, and real owning context;
- owner context covers Daily, Monthly Calendar/Tasks, Future, and Collection;
- results are read-only: no complete/discard/migrate/schedule/reference actions from Search;
- Search never creates Entries, placements, Collection references, migrations, or Index items;
- Search stays separate from the deliberate persisted Index;
- query execution is serialized through `JournalSearchSession` / `JournalSession.run(...)`;
- retained Search keeps only the last submitted query in presentation state and silently reruns it on section reactivation so result Task state does not remain stale;
- EN, `pt`, and `pt_BR` copy added;
- Search was the final use of the generic placeholder screen, so that obsolete screen and placeholder strings were removed.

Explicit non-goals:

- no direct navigation from Search results to their source yet;
- no Collection-title search;
- no ranking/relevance engine or richer filters;
- no FTS/schema change;
- no persisted Search history;
- no Search-to-Index shortcut;
- no mutations through Search results.

Validation lineage:

- initial Draft CI #404 reached the formatter and identified five new Dart files requiring pinned Dart 3.13.2 formatting;
- the pinned formatter output was applied and the temporary formatter workflow removed;
- Draft CI #411 then passed localization, Drift generation/snapshot, generated-artifact freshness, and formatter, and found one test-only `prefer_initializing_formals` lint in the Search fake;
- the fake constructor was corrected without changing product behavior;
- temporary full-validation workflow ran the Search-focused set: **6 tests passed**;
- the same workflow then ran the complete Daymark suite: **138 tests passed**;
- the known Drift multiple-database debug warning in the backup recovery test remains informational and green; PR #25 does not change that path;
- the full-validation workflow removed itself after success;
- README, PRODUCT, DOMAIN, ARCHITECTURE, and CHANGELOG are reconciled with the Search behavior;
- failed documentation-helper attempts were mechanical/fail-closed and published no unintended product changes; all temporary PR25 documentation workflow/script files were removed before this checkpoint;
- final exact-head Draft CI still must pass after this checkpoint before manual Linux product validation.

## Next work after PR #25

Keep subsequent slices separate. Strong candidates:

1. direct navigation from Index/Search retrieval results into real existing structures, using genuine routes rather than fake current-screen substitutions;
2. focused Reflection behavior after its method semantics are deliberately specified;
3. backup/restore UI and explicit open export flows;
4. OS lock integration, keyboard/accessibility refinements, Android/Linux polish, packaging, and final release audits.

Do not bundle Search into Index. Do not turn retrieval into another owning workspace. Do not introduce schema/FTS merely because future scale might benefit from it without evidence.

## CI and handoff traps

- Draft PRs run `dev-check`; Ready PRs run quality/full tests, Linux, Android, dependency review, and `merge-gate`.
- A red formatter is mechanical evidence, not automatically a product defect.
- Commits created by `github-actions[bot]` may show `action_required`; use a useful normal commit for exact-head evidence rather than treating that status as code failure.
- Temporary workflow probes must not remain in the final PR diff.
- `StatefulShellRoute.indexedStack` retains screens; section navigation is not a remount lifecycle.
- Manual product testing remains important for lifecycle freshness, compact/desktop navigation, persistence, and false-success/false-error UI behavior.
