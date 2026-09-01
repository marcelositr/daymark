# Daymark project checkpoint

This file is the canonical living checkpoint for ongoing Daymark development.

Every agent must read it before meaningful work and update it before handing work off. It exists so the project can survive chat limits, CLI restarts, API quotas, different agents, and long gaps without losing development context.

## Current state

- Phase: foundation / pre-alpha
- Public release status: no release yet
- Intended first public release stage: `v1.0.0-alpha.1`
- Current integration branch: `main`
- Current working branch: `feat/data-schema`
- Current pull request: `#6`
- Merge status: **DO NOT MERGE until explicitly requested by the user**
- Initial runtime targets: Linux and Android
- Pinned toolchain: Flutter 3.47.2 / Dart 3.13.2
- Current focus: relational schema v1 and migration discipline
- Last updated: 2026-09-01

## How to maintain this file

This plan is intentionally organic.

A checked item may be reopened if later evidence shows that it needs rework. New items may be inserted when implementation reveals previously unknown requirements. Large items should be split when that improves clarity.

When direction changes, preserve the reason in the work log or relevant authoritative document instead of silently replacing the old context.

The goal is not to pretend development is linear. The goal is to make the next correct step obvious.

## Foundation checklist

- [x] Repository baseline, license, contribution and security documents
- [x] Product purpose and digital-minimalism principles
- [x] Bullet Journal domain semantics
- [x] Local-first requirement
- [x] Initial platform scope: Linux and Android
- [x] Internationalization baseline: English and Portuguese (Brazil)
- [x] English canonical/fallback locale policy with exact `pt_BR` system matching
- [x] RTL-safe architectural direction for future locales
- [x] Visual direction: light/dark dotted-notebook metaphor without a freeform canvas
- [x] Security threat model for lost, stolen, sold, or removable storage
- [x] Required master-password model and optional device-assisted unlock
- [x] Encrypted portable backup as an initial requirement
- [x] Explicit plaintext export boundary
- [x] AI continuity and handoff protocol
- [x] Git branch, pull request, versioning, and release policy
- [x] Technology baseline re-evaluated against current Flutter/Drift ecosystem
- [x] Pin Flutter 3.47.2 / Dart 3.13.2 for the initial scaffold
- [x] Complete the Flutter scaffold with committed Android/Linux platform files and `pubspec.lock`
- [x] Replace scaffold bootstrap with permanent CI quality gates
- [x] Merge reviewed Flutter scaffold through PR #3
- [ ] Apply and verify the required CI check names in the live main-branch ruleset
- [ ] Finalize and review the initial relational data schema in PR #6
- [ ] Finalize and review database schema-evolution/migration tooling in PR #6
- [ ] Build a security spike for key derivation, key wrapping, encrypted database opening, lock, and recovery
- [ ] Specify the encrypted backup container format and restore transaction behavior

## Current PR #6 checklist

- [x] Define the relational persistence contract in `docs/DATA_MODEL.md`
- [x] Keep one encrypted database file scoped to one journal
- [x] Implement Drift schema version 1
- [x] Preserve Task/Event/Note semantics separately from task lifecycle state
- [x] Preserve migration lineage as source/destination chains
- [x] Keep Collection references distinct from migration
- [x] Persist the Index deliberately instead of deriving it from Search
- [x] Preserve Monthly Log calendar/task sections and explicit calendar dates
- [x] Keep key-envelope metadata outside the encrypted Drift database
- [x] Generate and commit Drift schema v1 snapshot and generated database code
- [x] Add schema/invariant tests with foreign-key enforcement
- [x] Configure Drift exported-schema / `make-migrations` tooling for future versions
- [x] Remove the temporary Drift bootstrap workflow
- [x] Add Drift generated-artifact/snapshot freshness checks to permanent `quality` CI
- [ ] Final permanent CI green on the reviewed PR head
- [ ] User review / merge decision

## Alpha milestone

Target: `v1.0.0-alpha.1`

The first alpha should be an end-to-end, intentionally incomplete product rather than a visual prototype.

- [ ] Create/open a journal with master password
- [ ] Open encrypted persistence only after successful unlock
- [ ] Manual lock and automatic lock
- [ ] Daily Log and Rapid Logging
- [ ] Task, Event, and Note entry types
- [ ] Task completion, discard, migration, and scheduling semantics
- [ ] Migration lineage preserved in storage
- [ ] Monthly Log
- [ ] Future Log
- [ ] Collections
- [ ] Index
- [ ] Search without a plaintext side index
- [ ] Light, dark, and system theme modes
- [ ] English and Portuguese (Brazil) UI
- [ ] Manual encrypted backup and restore
- [ ] Explicit Markdown and machine-readable export
- [ ] Linux build passes
- [ ] Android build passes
- [ ] Core domain and persistence tests pass
- [ ] No known unreviewed security advisory in shipped dependencies

## Beta gate

Beta begins only when the intended v1 core behavior exists and normal usage no longer requires structural redesign.

Before the first beta:

- [ ] Core flows are feature-complete for the v1 scope
- [ ] Database migrations have fixture-based tests
- [ ] Backup/restore is tested across supported platforms
- [ ] Recovery flow is tested
- [ ] Accessibility pass completed for core screens
- [ ] Keyboard workflow reviewed on desktop
- [ ] Android compact workflow reviewed on physical devices
- [ ] No unresolved data-loss bug
- [ ] No unresolved high-severity security issue
- [ ] Documentation matches actual behavior

## Release-candidate gate

Release candidates target `1.0.0` directly and use tags such as `v1.0.0-rc.1`.

Before the first RC:

- [ ] v1 feature set frozen
- [ ] Only bug fixes, security fixes, documentation corrections, and release blockers accepted
- [ ] Upgrade and migration path tested from previous prerelease data
- [ ] Encrypted backups from supported prereleases can be restored or a documented compatibility decision exists
- [ ] Linux release build tested outside the development checkout
- [ ] Android signed release build tested on physical hardware
- [ ] Security threat model reviewed against implementation
- [ ] Dependency and license review completed
- [ ] Release notes drafted

Stable `v1.0.0` is released only after RC testing is deliberately considered sufficient. There is no deadline-based automatic promotion from RC to stable.

## Current technology baseline

The authoritative technical details live in `docs/ARCHITECTURE.md`. The relational contract lives in `docs/DATA_MODEL.md`. This section is only the operational snapshot.

- Flutter 3.47.2 stable, pinned in the repository
- Dart 3.13.2 supplied by Flutter
- Material 3 as the widget/theme foundation
- Riverpod 3.x for presentation/application state and dependency wiring, without generator use initially
- go_router 18.x for application routing
- Drift 2.34.x for typed relational persistence and migrations
- sqlite3 3.x with SQLite3MultipleCiphers selected through build hooks for encrypted native storage
- ChaCha20-Poly1305 database cipher as the current encrypted-storage default unless the security spike finds a concrete reason to change it
- `cryptography` 2.9.x for Argon2id and application-level authenticated cryptography
- platform secure storage for optional device-assisted unlock, with the concrete package/version deferred to the security spike
- UUID v7 identifiers through the `uuid` package
- Flutter `gen_l10n` with English as canonical/fallback and Portuguese (Brazil) as the first additional product locale
- official Flutter file/path plugins where native file selection or application directories are required
- GitHub Actions for CI

`flutter_secure_storage` 11.0.0 was intentionally removed from the scaffold dependency set after validation showed that it requires Android `compileSdk` 37 while the Flutter 3.47.2 generated Android project currently uses API 36 with Android Gradle Plugin 9.1.0. Re-evaluate secure-storage integration when the device-assisted unlock security spike is implemented rather than distorting the baseline toolchain for an unused convenience layer.

Exact resolved dependency versions and package hashes are committed in `pubspec.lock`. Dependency changes must update and review that lockfile rather than silently floating beneath an unchanged source commit.

## Relational baseline

Schema v1 currently contains:

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

Important boundaries:

- one encrypted database file represents one journal;
- UUID v7 text IDs are domain identity;
- instants are UTC microseconds while method dates are timezone-neutral ISO dates;
- Monthly calendar placements carry an explicit calendar date instead of parsing it from entry text;
- Search initially queries encrypted journal storage directly; no plaintext side index;
- application preferences, key-envelope metadata, attachments, Reflection persistence, and generic trash are not speculative schema-v1 tables;
- schema v1 is still unreleased, so corrections before the first alpha regenerate v1 rather than manufacture migrations no user could have encountered;
- after any prerelease with user data, supported schema changes require explicit tested upgrades and representative data-preservation fixtures.

## Open questions and required validation

These are not permission to invent behavior silently. Resolve them through a focused task and update the appropriate authoritative document.

1. Exact application-level AEAD format for wrapping the journal key, recovery material, and portable backup payloads.
2. Argon2id parameters after benchmarking representative Linux and Android hardware.
3. Exact SQLite3MultipleCiphers raw-key and salt handling after a working prototype.
4. Exact secure-storage package and behavior when Android Keystore assistance or the Linux keyring is unavailable or locked.
5. Exact backup container versioning, atomic restore, and rollback behavior.
6. Packaging/distribution formats for Linux and Android. Packaging must not dictate core architecture.
7. The repository copy of the main ruleset records required checks `quality`, `linux-build`, `android-build`, and `dependency-review`, but the connected GitHub tool available in this session exposes ruleset reads rather than a live ruleset mutation action. The live repository ruleset must therefore be applied and verified separately before this checklist item is closed.
8. Repository/application services must enforce cross-table semantic invariants that ordinary SQLite `CHECK` constraints cannot express, including Monthly calendar dates belonging to their Monthly Log period and migration kind/state/location consistency.

## Recent work log

### 2026-09-01

- Established the repository as the continuity source for AI-assisted development.
- Added a mandatory agent start/end protocol through `AGENTS.md` and this checkpoint.
- Defined GitHub-flow-style branches, squash PR integration, SemVer prereleases, and explicit alpha/beta/RC gates.
- Re-evaluated the technical stack and selected Flutter/Drift/sqlite3 with SQLite3MultipleCiphers rather than the earlier Tauri/SQLCipher assumptions.
- Merged the foundation contract through PR #2.
- Built, audited, CI-validated, and merged the Flutter/Linux/Android scaffold through PR #3 (`759b86cc7ca5d3a3d1dff7f621361d4cbb701553`).
- Deferred device secure-storage integration after `flutter_secure_storage` 11.0.0 exposed a compileSdk mismatch with the pinned Flutter Android baseline.
- Clarified localization behavior: English is canonical and fallback; exact `pt_BR` system locale selects Brazilian Portuguese.
- Established permanent CI jobs `quality`, `linux-build`, `android-build`, and `dependency-review`.
- Opened draft PR #6 on `feat/data-schema` for relational schema v1.
- Defined one encrypted database file per journal and kept unlock/key-envelope data outside the encrypted relational file.
- Modeled logs, Collections, entries, ownership placements, migration lineage, Collection references, signifiers, and Index as distinct relational concerns.
- Added DB constraints for task-state validity, ownership exclusivity, ordering, lineage uniqueness, and referential integrity.
- Added `monthly_calendar_date` after audit showed that the Monthly Log calendar must not infer dates from free text.
- Generated Drift schema v1 and generated database code with the pinned toolchain; bootstrap validation passed code generation, `make-migrations`, strict analysis, and tests.
- Learned from the current toolchain that `build_runner` no longer accepts the obsolete `--delete-conflicting-outputs` flag and removed it from project automation.
- Removed the temporary schema bootstrap after it regenerated the corrected unreleased v1 snapshot.
- Extended permanent `quality` CI to regenerate Drift sources, run `make-migrations`, and reject stale committed generated artifacts.

## Next concrete action

Let the permanent CI validate the final PR #6 documentation/schema head. If green, perform one last PR audit, mark the PR ready for user review, and do not merge until the user explicitly approves it.

## Handoff

If work stops unexpectedly, the next agent should:

1. read `AGENTS.md` and this file;
2. inspect the current branch and PR rather than assuming the values above are still current;
3. read the authoritative document for the next unchecked foundation item;
4. continue from the first genuinely actionable unchecked item, unless the user sets a different priority;
5. update this file again before stopping.
