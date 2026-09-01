# Daymark project checkpoint

This file is the canonical living checkpoint for ongoing Daymark development.

Every agent must read it before meaningful work and update it before handing work off. It exists so the project can survive chat limits, CLI restarts, API quotas, different agents, and long gaps without depending on hidden conversation context.

## Current state

- Phase: foundation / pre-alpha
- Public release status: no release yet
- Intended first public release stage: `v1.0.0-alpha.1`
- Integration branch: `main`
- Current working branch: `feat/security-foundation`
- Current pull request: `#7`
- Merge status: **DO NOT MERGE until explicitly requested by the user**
- Current focus: master-password key hierarchy and encrypted journal opening
- Initial runtime targets: Linux and Android
- Pinned toolchain: Flutter 3.47.2 / Dart 3.13.2
- Last updated: 2026-09-01

## How to maintain this file

This plan is intentionally organic.

A checked item may be reopened if later evidence shows that it needs rework. New items may be inserted when implementation reveals previously unknown requirements. Large items should be split when that improves clarity.

When direction changes, preserve the reason here or in the relevant authoritative document instead of silently replacing the old context.

The repository, not a chat session, is the development memory.

## Foundation status

### Completed

- [x] Repository baseline, GPL-3.0-or-later license, contribution and security documents
- [x] Product purpose and digital-minimalism principles
- [x] Bullet Journal domain semantics
- [x] Local-first requirement
- [x] Linux and Android initial platform scope
- [x] English canonical/fallback locale and Portuguese (Brazil) initial localization
- [x] RTL-safe architectural direction
- [x] Light/dark dotted-notebook visual direction without freeform canvas behavior
- [x] Security threat model for lost, stolen, sold, or removable storage
- [x] Required master-password model and optional device-assisted unlock direction
- [x] Encrypted portable backup as an initial product requirement
- [x] Explicit plaintext export boundary
- [x] AI continuity and handoff protocol through `AGENTS.md` and this file
- [x] Git branch, PR, squash-merge, SemVer prerelease, and release-gate policy
- [x] Technology baseline re-evaluated against the current Flutter/Drift ecosystem
- [x] Flutter 3.47.2 / Dart 3.13.2 pinned
- [x] Flutter/Linux/Android scaffold merged through PR #3
- [x] Permanent CI gates established: `quality`, `linux-build`, `android-build`, `dependency-review`
- [x] `actions/setup-java` updated through PR #4
- [x] `actions/checkout` updated through PR #5
- [x] Relational data contract and Drift schema v1 merged through PR #6
- [x] Drift exported schema and generated-artifact freshness validation integrated into CI
- [x] Database schema-evolution policy established before the first prerelease

### Still required before product feature work becomes the main focus

- [ ] Apply and verify required CI check names in the live `main` ruleset
- [ ] Complete security foundation PR #7
- [ ] Specify and implement the encrypted portable backup container / restore transaction
- [ ] Establish repository/application services that enforce semantic invariants spanning multiple tables

## Current PR #7: security foundation

Authoritative validation plan: `docs/SECURITY_FOUNDATION.md`.

### Portable trust foundation

- [ ] Confirm maintained Argon2id API/library on the pinned toolchain
- [ ] Confirm maintained AEAD API/library for key-envelope protection
- [ ] Generate journal data-encryption keys from a cryptographically secure random source
- [ ] Define versioned key-envelope format v1 outside the encrypted Drift database
- [ ] Derive a key-encryption key from master password + random salt + versioned Argon2id parameters
- [ ] Authenticated-wrap and unwrap the random journal key
- [ ] Never persist the master password or plaintext journal key
- [ ] Preserve architecture for optional independent offline recovery

### Failure behavior

- [ ] Wrong master password fails closed
- [ ] Modified ciphertext/authentication data fails closed
- [ ] Modified nonce/IV fails closed
- [ ] Modified authenticated metadata fails closed
- [ ] Truncated envelope fails closed
- [ ] Unsupported envelope/KDF version fails explicitly
- [ ] Failure reporting does not leak password-quality hints or sensitive material

### Encrypted database proof

- [ ] Verify SQLite3MultipleCiphers capability at runtime
- [ ] Refuse journal creation/open when expected encrypted SQLite support is unavailable
- [ ] Open Drift schema v1 using the recovered random journal key
- [ ] Correct journal key reopens the encrypted journal
- [ ] Incorrect journal key cannot open/read the journal
- [ ] Ordinary plaintext SQLite cannot read representative journal schema/content
- [ ] Representative sensitive test strings do not appear verbatim in the database file
- [ ] Existing Drift schema/invariant tests remain valid through encrypted persistence

### Password-hardening validation

- [ ] Add reproducible Argon2id benchmark harness
- [ ] Record Linux benchmark results
- [ ] Define Android physical-device benchmark procedure
- [ ] Freeze initial Argon2id parameters only after representative Android validation
- [ ] Keep KDF parameters versioned for future strengthening

### Key/session boundaries

- [ ] Define narrow secret/key ownership abstractions
- [ ] Avoid logging/persisting key material
- [ ] Document Dart runtime limits around guaranteed memory zeroization
- [ ] Make later manual/automatic lock capable of dropping application references deterministically

### Documentation / review

- [ ] Align `SECURITY.md` with proven implementation details
- [ ] Align `docs/ARCHITECTURE.md` with proven implementation details
- [ ] Update this checkpoint with decisions and remaining limitations
- [ ] Permanent CI green on reviewed PR head
- [ ] User review / merge decision

## Relational baseline

Schema v1 was merged through PR #6 and currently contains:

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
- Monthly calendar placements carry explicit dates instead of parsing dates from entry text;
- migration lineage preserves source/destination history;
- Collection references are not migrations;
- Search initially queries encrypted journal storage directly, with no plaintext side index;
- application preferences, key-envelope metadata, attachments, Reflection persistence, and generic trash are not speculative schema-v1 tables;
- after any prerelease containing user data, supported schema changes require explicit tested upgrades and representative data-preservation fixtures.

## Current technology baseline

The authoritative details live in `docs/ARCHITECTURE.md`.

- Flutter 3.47.2 stable / Dart 3.13.2
- Material 3 as widget/theme infrastructure
- Riverpod 3.x without generator use initially
- go_router 18.x
- Drift 2.34.x
- sqlite3 3.x with SQLite3MultipleCiphers through build hooks
- ChaCha20-Poly1305 as current encrypted-database direction unless the security spike demonstrates a better supported choice
- `cryptography` 2.9.x as the current candidate for Argon2id and application-level authenticated cryptography, subject to validation in PR #7
- platform secure storage deferred to a later device-assisted unlock task
- UUID v7 through `uuid`
- Flutter `gen_l10n`, English canonical/fallback, Portuguese (Brazil) first additional locale
- GitHub Actions with immutable action SHAs

`flutter_secure_storage` 11.0.0 was intentionally not retained in the baseline because its Android compileSdk requirement did not match the pinned Flutter-generated Android toolchain. Device-assisted unlock must be re-evaluated when that feature is actually implemented rather than distorting the baseline for an unused convenience layer.

## Alpha milestone

Target: `v1.0.0-alpha.1`.

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
- [ ] Search without plaintext side index
- [ ] Light, dark, and system theme modes
- [ ] English and Portuguese (Brazil) UI
- [ ] Manual encrypted backup and restore
- [ ] Explicit Markdown and machine-readable export
- [ ] Linux build passes
- [ ] Android build passes
- [ ] Core domain, persistence, and security tests pass
- [ ] No known unreviewed security advisory in shipped dependencies

## Beta gate

Beta begins only when the intended v1 core behavior exists and normal usage no longer requires structural redesign.

- [ ] Core flows feature-complete for v1 scope
- [ ] Database migrations fixture-tested
- [ ] Backup/restore tested across supported platforms
- [ ] Recovery flow tested
- [ ] Accessibility pass completed for core screens
- [ ] Desktop keyboard workflow reviewed
- [ ] Android compact workflow reviewed on physical devices
- [ ] No unresolved data-loss bug
- [ ] No unresolved high-severity security issue
- [ ] Documentation matches actual behavior

## Release-candidate gate

Release candidates target `1.0.0` directly and use tags such as `v1.0.0-rc.1`.

- [ ] v1 feature set frozen
- [ ] Only bug fixes, security fixes, documentation corrections, and release blockers accepted
- [ ] Upgrade path tested from previous prerelease data
- [ ] Encrypted backup compatibility tested/documented across supported prereleases
- [ ] Linux release build tested outside development checkout
- [ ] Android signed release build tested on physical hardware
- [ ] Security threat model reviewed against implementation
- [ ] Dependency and license review completed
- [ ] Release notes drafted

Stable `v1.0.0` is released only after RC testing is deliberately considered sufficient. There is no deadline-based automatic promotion.

## Open questions and required validation

These are not permission to invent behavior silently. Resolve them through focused work and update the authoritative document.

1. Exact key-envelope v1 AEAD and serialization.
2. Argon2id parameters after representative Linux and Android measurements.
3. Exact SQLite3MultipleCiphers raw-key and salt handling verified by working code.
4. Exact offline recovery-secret representation and UX.
5. Exact secure-storage integration for optional Android/Linux assisted unlock.
6. Exact backup container versioning, atomic restore, and rollback behavior.
7. Packaging/distribution formats for Linux and Android.
8. Live GitHub ruleset still needs the repository-defined required check names applied and verified.
9. Repository/application services must enforce cross-table semantic invariants that ordinary SQLite `CHECK` constraints cannot express.

## Recent work log

### 2026-09-01

- Established repository-first continuity for AI-assisted development.
- Defined Git/PR/release governance and explicit alpha, beta, and RC gates.
- Re-evaluated the stack and moved from the earlier Tauri/SQLCipher direction to Flutter/Drift/sqlite3 + SQLite3MultipleCiphers.
- Merged foundation documentation through PR #2.
- Merged pinned Flutter/Linux/Android scaffold and permanent CI through PR #3.
- Merged `actions/setup-java` 6.0.0 update through PR #4.
- Merged `actions/checkout` 7.0.1 update through PR #5.
- Merged relational model, Drift schema v1, schema snapshots, invariants, and migration-tooling baseline through PR #6 (`3efd445351df59d95d92da0bc73f6c4bdccb4063`).
- Corrected the unreleased schema v1 to persist Monthly Log calendar dates explicitly before any public user data existed.
- Opened draft PR #7 on `feat/security-foundation` for master-password key hierarchy and encrypted journal validation.
- Added `docs/SECURITY_FOUNDATION.md` as the focused security implementation/validation contract.

## Next concrete action

Validate the current crypto and SQLite3MultipleCiphers APIs against the pinned toolchain, then implement the smallest executable key-envelope prototype with failure tests. Do not add biometric/keyring convenience or backup-container scope to PR #7.

## Handoff

If work stops unexpectedly, the next agent should:

1. read `AGENTS.md` and this file;
2. inspect the current branch and PR rather than trusting stale chat context;
3. read `SECURITY.md` and `docs/SECURITY_FOUNDATION.md` before changing security code;
4. continue from the first genuinely actionable unchecked item unless the user sets another priority;
5. update this file again before stopping.
