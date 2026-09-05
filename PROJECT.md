# Daymark project checkpoint

This is Daymark's canonical living handoff. Read this file and `AGENTS.md` before meaningful work. The repository, not a chat transcript, is the project memory.

## Current state

- Phase: alpha development after the first controlled distributable prerelease.
- Integration branch: `main` only.
- Latest published release: `v1.0.0-alpha.2` / application version `1.0.0-alpha.2+2`.
- Published release source commit: `5c073c6bbbe298c15f975740a5499f2b9a0c98ba`, squash merge of PR #32.
- Current `main` baseline before the UI/UX merge: `0c77e689e8feed8bdd5245f86b26774d47289d12`, squash merge of PR #38 `feat(journal): add deliberate Monthly Trackers`.
- PR #40 `feat(ui): polish Daymark journal experience` is the final stage of the accelerated post-alpha.2 plan. Its reviewed implementation head before documentation alignment is `d6bc8657df729505be3c24e106836794c6cbdc51`.
- PR #40 has passed local static analysis, focused presentation/accessibility tests, the complete Flutter suite, and manual Linux/Android validation. The user explicitly approved its merge on 2026-09-05 after final documentation alignment; release/tag/artifact publication remains a separate approval boundary.
- The four-stage post-alpha.2 execution plan is complete: Today + Inbox, Review + Calibrate, Monthly Trackers, and UI/UX polish.
- No new product slice is selected by this checkpoint. Release preparation remains explicitly deferred until the user chooses it.
- Runtime targets: Linux and Android.
- Pinned toolchain: Flutter 3.47.2 / Dart 3.13.2.
- Production Argon2id baseline: 19 MiB / 2 iterations / p=1 / 32-byte output.
- The completed `release/1.0.0-alpha.2` and feature branches are retained as historical reference/backup and are not active integration lines.

A documentation-only commit after a published release does not change that release's source identity. When exact release identity matters, use the release tag/commit above.

## Product doctrine

Daymark is a faithful digital Bullet Journal, not a generic productivity suite.

- local-first and offline-first;
- digital minimalism and low distraction;
- no feeds, ads, streaks, XP, productivity scoring, gamification, or attention-seeking UI;
- no automatic choices that replace deliberate reflection;
- no generic planner/Kanban/workspace abstractions merely because digital software can support them;
- English is canonical/fallback; exact `pt_BR` is the first additional locale;
- primary navigation concepts are Today, Monthly, Future, Collections, Search, and Index; compact layouts group Search/Index behind More without merging their meaning;
- optional Daymark-specific adaptations such as Tracker must be labeled as adaptations, preserve the core method model, and document provenance instead of being presented as canonical Bullet Journal rules.

## Mandatory working rules

- `main` is the only permanent integration branch. Use short-lived branches and PRs.
- PR titles use Conventional Commit form.
- The user makes every merge and release-promotion decision. Never enable auto-merge, merge implicitly, or publish implicitly.
- The agent owns implementation design, Git/GitHub operations available through connected tooling, test design, command construction, and diagnosis of returned evidence.
- Local execution may replace routine CI iteration when explicitly agreed, but correctness/security boundaries must not be weakened.
- Treat formatter output from the pinned Dart version as authoritative.
- Treat CI evidence as SHA-specific. A green superseded run does not validate a newer head.
- Never weaken security, persistence invariants, tests, or CI merely to make a check green.
- Do not use `flutter clean` as routine hygiene; preserve incremental build state unless evidence requires a controlled clean rebuild.
- Keep `PROJECT.md` current and `CHANGELOG.md` release-facing.
- User shell blocks must follow `docs/LOCAL_EXECUTION.md`; avoid `set -e` in interactive blocks that could close the user's terminal.

## Current product baseline

The post-alpha.2 product now includes:

- Today / Daily Rapid Logging for Task, Event, and Note;
- deliberate Task Complete, Migrate, Schedule, and Discard decisions;
- contextual Daily Reflection and immediate capture Undo;
- read-only Daily history;
- Monthly Calendar and Tasks with historical read-only browsing;
- rolling six-month Future Log;
- simple method-native Collections with owned entries and removable references;
- deliberate Index with reorder/remove and direct source navigation;
- local Search with direct source navigation and retained-result refresh;
- encrypted portable Backup / Restore;
- plaintext Open Export to versioned JSON and human-readable Markdown after master-password reauthentication, with Save and Copy outputs;
- System / Light / Dark appearance selection;
- optional finite Monthly Trackers with explicit `+1 / -1` marks, rendered `0` for absence inside the effective period, early ending, historical read-only viewing, Today controls, and reflective graphing;
- adaptive Linux/Android navigation, coherent Daymark control styling, bounded journal page layout, application branding, improved keyboard/focus behavior, accessibility semantics, and quiet empty states.

## Stable domain and persistence baseline

Published schema v1 contains:

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

Current schema v2 extends that published baseline additively with:

- `trackers`;
- `tracker_marks`.

The v1-to-v2 path is represented by retained Drift schema snapshots, generated versioned migration helpers, and migration tests that preserve representative v1 journal data.

Durable rules:

- one encrypted Daymark database represents one journal;
- `journal_metadata` identifies that journal with exactly one singleton UUID-v7 row;
- new journals initialize that row and legacy prerelease journals with zero rows are repaired idempotently on unlock; more than one row fails closed as corruption;
- Task, Event, and Note are distinct entry types;
- Task states are open/completed/migrated/scheduled/discarded;
- Events and Notes do not acquire Task state;
- every Entry has exactly one owning placement;
- Monthly Calendar/Tasks placement and date invariants are enforced;
- Future is month-addressed, not a second day-level calendar;
- a Collection is a simple method-native owning container, not a configurable workspace;
- Collection references do not move the source Entry and remain distinct from migration;
- scheduling (`<`) targets Future;
- forward migration (`>`) currently targets an explicitly selected existing Collection;
- movement preserves historical source content and creates a fresh destination Entry plus lineage;
- Index deliberately catalogs an existing Log or Collection and never duplicates Entry content;
- Search is transient read-only retrieval and is never an owner or persistent Index source;
- historical Monthly and Daily lookups are non-mutating;
- cross-table semantic writes remain transactional through repository/service boundaries;
- `JournalSession` serializes unlocked journal work and owns encrypted persistence/key lifetime;
- Trackers are separate optional finite entities and never create a daily Task or change Entry ownership.

Schema v1 is a published compatibility boundary because `v1.0.0-alpha.2` supports real user journals. Schema v2 therefore migrates forward explicitly and additively; future supported builds must keep tested compatibility/migration paths rather than silently regenerating or resetting published data.

## Retained-navigation lifecycle rule

The router uses `StatefulShellRoute.indexedStack`, so top-level sections remain mounted while inactive.

- returning to a section does not imply another `initState()`;
- a retained screen whose data can become stale because of work elsewhere must refresh when it becomes active;
- `AppSectionScope` is the presentation-level activation signal;
- do not solve freshness by destroying all tabs, polling continuously, or adding an unrelated global cache.

This currently matters for Today/Monthly Tracker refresh, Future after scheduling, Collections after migration/references, and Search after Task-state changes elsewhere.

## UI/UX baseline

The final stage establishes a restrained Daymark visual grammar on Material 3 rather than replacing Flutter's foundation with another UI framework.

- application branding is installed for Linux and Android;
- shared design tokens define control radii/heights, page breakpoints, spacing, and bounded page width;
- principal journal screens use a shared responsive page frame, with compact Android spacing and centered bounded desktop content;
- typography and selected navigation states are consistent across the shell;
- common dropdown/control styling replaces scattered stock presentation choices;
- Linux composers restore focus after relevant actions and support the established keyboard submission behavior;
- journal entries expose semantic type/state labels without duplicating visual Bullet Journal symbols to assistive technology;
- Trackers expose selected mark state semantically;
- quiet empty states are visually consistent;
- UI polish remains subordinate to journal content and avoids decorative notebook hardware, gamified signals, dashboards, or attention-seeking chrome.

## Security and portability baseline

The authoritative security contract lives in `SECURITY.md`. Backup details live in `docs/BACKUP_FORMAT.md`; Open Export details live in `docs/OPEN_EXPORT_FORMAT.md`; platform release procedure lives in `docs/RELEASE.md`.

Current foundation includes:

- SQLite3MultipleCiphers ChaCha20-Poly1305 encrypted persistence;
- random 48-byte journal material: 32-byte key + 16-byte cipher salt;
- master password never used directly as the SQLite key and never persisted;
- Argon2id-derived KEK + XChaCha20-Poly1305 authenticated key envelope;
- explicit mutable key-material destruction where practical;
- Android OS backup/device-transfer exclusion;
- portable authenticated encrypted backup/restore with rollback/recovery protections;
- plaintext Open Export requiring master-password reauthentication before plaintext generation;
- Android release builds fail closed if dedicated release signing is absent;
- Android screen-off and Linux systemd-logind session-lock events request immediate lock through the same serialized journal-session path as manual/inactivity locking.

The published `v1.0.0-alpha.2` key-envelope interpretation, 48-byte journal-key serialization, schema v1, backup format v1, and Open Export format v1 are compatibility-sensitive boundaries. Open Export format v2 adds Tracker data explicitly.

## Published alpha.2 release checkpoint

- application version: `1.0.0-alpha.2+2`;
- tag: `v1.0.0-alpha.2`;
- release source commit: `5c073c6bbbe298c15f975740a5499f2b9a0c98ba`;
- Android package: `io.github.marcelositr.daymark`;
- Linux x64 archive SHA-256: `490ce7c62126e8b9d5e9e78a3727f68c131e60ef197d0673d174ea0d44def9c4`;
- signed Android APK SHA-256: `96f69264a4fc0fead8d31893f96aac428db341303abdfab929daaee5760f20f0`;
- Android release certificate SHA-256: `44342dcd1343643bc56da2545ec10e5624fc2e49d1bcc3b418f4f9ab160e1b88`.

The release was validated on Linux and physical Android, including encrypted-journal persistence, backup/restore migration from the earlier debug-signed lineage, reinstall retention, Appearance, and JSON/Markdown Open Export. Detailed release procedure/evidence remains in `docs/RELEASE.md`, `CHANGELOG.md`, and the GitHub Release.

## Merged product baseline

- PR #13: encrypted create/unlock/manual lock plus Today.
- PR #14: inactivity lock.
- PR #15: Task complete/discard.
- PR #16: Monthly.
- PR #17: Future.
- PR #18: scheduling.
- PR #20: Collections.
- PR #21: migration to Collection.
- PR #22: Collection references.
- PR #23: Index.
- PR #24: historical Monthly.
- PR #25: Search.
- PR #26: Daily history.
- PR #27: stabilization handoff.
- PR #28: encrypted Backup / Restore.
- PR #29: documentation/performance benchmark.
- PR #30: Open Export.
- PR #31: Appearance.
- PR #32: `v1.0.0-alpha.2` release baseline.
- PR #34: accelerated post-alpha planning alignment.
- PR #35: navigation/organization controls.
- PR #36: reflection, Rapid Logging UX, Undo, notices.
- PR #37: Open Export reauthentication/clipboard plus immediate session locking.
- PR #38: optional Monthly Trackers and schema v2. Squash `0c77e689e8feed8bdd5245f86b26774d47289d12`.
- PR #40: final application branding and UI/UX polish; merge explicitly approved after documentation alignment.

## Completed post-alpha.2 plan

1. **Today + Inbox** — complete.
2. **Review + Calibrate** — complete.
3. **Monthly Trackers** — complete and merged via PR #38.
4. **UI/UX polish** — implementation and validation complete in PR #40.

Stage 4 covered spacing, hierarchy, responsiveness, keyboard/focus behavior, accessibility, visual consistency, interaction friction, and restrained polish on Linux and Android without reopening stable domain/persistence/security architecture.

## Next development state

After PR #40 is merged, there is no unfinished stage in the accelerated post-alpha.2 plan.

Do not infer a next feature merely because the plan is complete. The next branch should begin only after an explicit product decision, for example another focused product slice, stabilization/release preparation, or a separately scoped deferred capability such as device-assisted unlock.

Release preparation is still deferred. Do not change application version/build numbers, create publication artifacts, create tags, or publish/promote a GitHub Release until the user explicitly changes that direction.