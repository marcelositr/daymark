# Daymark project checkpoint

This file is the canonical living checkpoint for ongoing Daymark development.

Every agent must read it before meaningful work and update it before handing work off. It exists so the project can survive chat limits, CLI restarts, API quotas, different agents, and long gaps without losing development context.

## Current state

- Phase: foundation / pre-alpha
- Public release status: no release yet
- Intended first public release stage: `v1.0.0-alpha.1`
- Current integration branch: `main`
- Current working branch: `docs/foundation-decisions`
- Current pull request: `#2`
- Merge status: **DO NOT MERGE until explicitly requested by the user**
- Initial runtime targets: Linux and Android
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
- [x] RTL-safe architectural direction for future locales
- [x] Visual direction: light/dark dotted-notebook metaphor without a freeform canvas
- [x] Security threat model for lost, stolen, sold, or removable storage
- [x] Required master-password model and optional device-assisted unlock
- [x] Encrypted portable backup as an initial requirement
- [x] Explicit plaintext export boundary
- [x] AI continuity and handoff protocol
- [x] Git branch, pull request, versioning, and release policy
- [x] Technology baseline re-evaluated against current Flutter/Drift ecosystem
- [ ] Finalize the initial relational data schema
- [ ] Define and test database migration strategy with real schema fixtures
- [ ] Build a security spike for key derivation, key wrapping, encrypted database opening, lock, and recovery
- [ ] Specify the encrypted backup container format and restore transaction behavior
- [ ] Scaffold the Flutter application with the exact pinned SDK and dependencies
- [ ] Add CI quality gates and then bind real check names into the main-branch ruleset

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

The authoritative technical details live in `docs/ARCHITECTURE.md`. This section is only the operational snapshot.

Current direction after the 2026-09-01 review:

- Flutter stable 3.47 line, with the exact patch pinned when the scaffold is created
- Dart 3.13 line supplied by Flutter
- Material 3 as the widget/theme foundation
- Riverpod 3.x for presentation/application state and dependency wiring, without generator use initially
- go_router 18.x for application routing
- Drift 2.34.x for typed relational persistence and migrations
- sqlite3 3.x with SQLite3MultipleCiphers selected through build hooks for encrypted native storage
- ChaCha20-Poly1305 database cipher as the current encrypted-storage default unless the security spike finds a concrete reason to change it
- `cryptography` 2.9.x for Argon2id and application-level authenticated cryptography
- `flutter_secure_storage` 11.x only for device-local assisted unlock material, never as the sole portable security model
- UUID v7 identifiers through the `uuid` package
- Flutter `gen_l10n` with ARB resources
- official Flutter file/path plugins where native file selection or application directories are required
- GitHub Actions for CI

Do not treat these version families as permission to float dependencies. Exact resolved versions belong in the committed lockfile once the scaffold exists.

## Open questions and required validation

These are not permission to invent behavior silently. Resolve them through a focused task and update the appropriate authoritative document.

1. Exact relational schema for entries, logs, collections, references, migration lineage, settings, and security metadata.
2. Exact application-level AEAD format for wrapping the journal key, recovery material, and portable backup payloads.
3. Argon2id parameters after benchmarking representative Linux and Android hardware.
4. Exact SQLite3MultipleCiphers raw-key and salt handling after a working prototype.
5. Exact secure-storage behavior when the Linux keyring is unavailable or locked.
6. Exact backup container versioning, atomic restore, and rollback behavior.
7. Exact Flutter stable patch to pin at scaffold time. Re-check the current stable channel instead of relying on an old chat.
8. Packaging/distribution formats for Linux and Android. Packaging must not dictate core architecture.

## Recent work log

### 2026-09-01

- Established the repository as the continuity source for AI-assisted development.
- Added a mandatory agent start/end protocol through `AGENTS.md`.
- Defined a single living project checkpoint in this file.
- Defined GitHub-flow-style branches, squash PR integration, SemVer prereleases, and explicit alpha/beta/RC gates.
- Re-evaluated the technical stack against the current Flutter and Drift ecosystem.
- Superseded the earlier SQLCipher-first assumption with Drift's current native encrypted-database direction: `sqlite3` 3.x plus SQLite3MultipleCiphers.
- Kept the current foundation work in PR #2 and explicitly left it unmerged.

## Handoff

If work stops unexpectedly, the next agent should:

1. read `AGENTS.md` and this file;
2. inspect the current branch and PR rather than assuming the values above are still current;
3. read the authoritative document for the next unchecked foundation item;
4. continue from the first genuinely actionable unchecked item, unless the user sets a different priority;
5. update this file again before stopping.
