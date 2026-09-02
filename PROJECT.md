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
- Current focus: finish security-foundation evidence, representative Argon2id benchmarking, and review readiness
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

- [x] Confirm maintained Argon2id API/library on the pinned toolchain (`cryptography` 2.9.0)
- [x] Confirm maintained AEAD API/library for key-envelope protection (`XChaCha20-Poly1305` through `cryptography` 2.9.0)
- [x] Generate journal data-encryption keys from a cryptographically secure random source
- [x] Define versioned key-envelope format v1 outside the encrypted Drift database
- [x] Derive a key-encryption key from master password + random salt + explicit Argon2id parameters
- [x] Authenticated-wrap and unwrap the random journal key material
- [x] Never persist the master password or plaintext journal key
- [x] Preserve architecture for optional independent offline recovery over the same random journal key

### Failure behavior

- [x] Wrong master password fails closed
- [x] Modified ciphertext/authentication data fails closed
- [x] Modified nonce fails closed
- [x] Modified authenticated metadata fails closed
- [x] Truncated envelope payload fails closed
- [x] Unsupported envelope version / KDF identifier fails explicitly
- [x] Failure reporting does not leak password-quality hints or sensitive material
- [x] Reject excessive untrusted Argon2id parameters before allocation/derivation

### Encrypted database proof

- [x] Verify SQLite3MultipleCiphers capability at runtime
- [x] Refuse journal creation/open when expected encrypted SQLite support is unavailable rather than falling back to plaintext
- [x] Open Drift schema v1 using recovered random journal key material
- [x] Force Drift initialization before `createNew()` returns
- [x] Correct journal key reopens the encrypted journal
- [x] Incorrect journal key cannot open/read the journal
- [x] Ordinary unkeyed SQLite cannot read representative journal schema/content
- [x] Representative sensitive test strings do not appear verbatim in the database file
- [x] Existing Drift schema/invariant behavior remains active through encrypted persistence
- [x] Verify/document SQLite3MultipleCiphers raw ChaCha20 representation as 32-byte key + 16-byte cipher salt

The normal build matrix always bundles SQLite3MultipleCiphers, so CI does not currently manufacture a second native runtime containing only vanilla SQLite to exercise the unavailable-library branch. The runtime check remains mandatory implementation behavior and must not be removed merely because the production build normally satisfies it.

### Password-hardening validation

- [x] Add reproducible Argon2id benchmark harness
- [ ] Record representative Linux benchmark results
- [x] Define Android physical-device benchmark procedure
- [ ] Record representative physical Android benchmark results
- [ ] Freeze initial Argon2id parameters only after Linux + physical Android validation
- [x] Keep KDF parameters explicit in the envelope for future strengthening
- [x] Bound untrusted envelope parameters independently from the selected production work factor

Current pre-alpha Argon2id candidate, not yet frozen:

- 19 MiB memory;
- 2 iterations;
- parallelism 1;
- 32-byte output.

Benchmark procedure: `docs/ARGON2_BENCHMARK.md`.

### Key/session boundaries

- [x] Define narrow journal-key ownership through `JournalKeyMaterial`
- [x] Use overwrite-on-destroy secret-key storage and wipe owned mutable key/salt buffers where practical
- [x] Avoid logging/persisting key material
- [x] Document Dart runtime limits around guaranteed memory zeroization
- [x] Document the immutable hexadecimal `String` limitation imposed by SQLite3MultipleCiphers' SQL `PRAGMA key` interface
- [x] Preserve an explicit destroy lifecycle that later manual/automatic lock can own through an unlocked-session abstraction

Actual lock timers, lifecycle UI, Android device-lock integration, and Linux session-lock integration remain later product tasks and are outside PR #7.

### Documentation / review

- [x] Align `SECURITY.md` with proven implementation details
- [x] Align `docs/SECURITY_FOUNDATION.md` with proven implementation details
- [x] Align `docs/ARCHITECTURE.md` with proven implementation details
- [x] Add reproducible Linux/Android Argon2id benchmark procedure
- [x] Update this checkpoint with decisions and remaining limitations
- [ ] Correct README / PR status text to current PR #7 state
- [ ] Permanent CI green on the final reviewed PR head
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
- SQLite3MultipleCiphers ChaCha20-Poly1305 for encrypted journal persistence
- `cryptography` 2.9.0 with Argon2id + XChaCha20-Poly1305 for portable key-envelope protection
- key-envelope format v1 outside the encrypted Drift database
- 48-byte SQLite raw journal material: 32-byte random journal key + 16-byte random cipher salt
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

1. Final Argon2id parameters after representative Linux and physical Android measurements.
2. Exact offline recovery-secret human representation and UX. The cryptographic relationship to the random journal key is established.
3. Exact secure-storage integration for optional Android/Linux assisted unlock.
4. Exact backup container versioning, atomic restore, and rollback behavior.
5. Packaging/distribution formats for Linux and Android.
6. Live GitHub ruleset still needs the repository-defined required check names applied and verified.
7. Repository/application services must enforce cross-table semantic invariants that ordinary SQLite `CHECK` constraints cannot express.

Resolved during PR #7:

- key-envelope v1 uses Argon2id + XChaCha20-Poly1305 through `cryptography` 2.9.0;
- envelope metadata/serialization and negative failure paths are implemented and tested;
- SQLite3MultipleCiphers uses the documented ChaCha20 32-byte raw key + 16-byte salt representation;
- encrypted database opening requires an actual read after `PRAGMA key`;
- the journal-key holder has explicit ownership/destruction boundaries;
- recovery is architecturally a second portable protection path over the same random journal key rather than a device/account reset mechanism.

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
- Implemented random journal-key material and version-1 Argon2id/XChaCha20-Poly1305 key envelope.
- Added generic fail-closed unlock/format error boundaries and negative-path envelope tests.
- Implemented SQLite3MultipleCiphers encrypted journal creation/opening and runtime cipher capability checking.
- Fixed the Drift lazy-open lifecycle so `createNew()` completes schema initialization before returning; CI #57 validated the wrong-key regression fix.
- Proved correct-key reopen, wrong-key rejection, unreadability through unkeyed SQLite, absence of representative plaintext content, and schema constraints through encrypted persistence.
- Added direct Argon2id determinism/salt tests and bounded untrusted KDF metadata.
- Added `tool/argon2_benchmark.dart` and `docs/ARGON2_BENCHMARK.md` for representative Linux/physical-Android parameter validation.
- Hardened journal-key ownership to reduce temporary plaintext copies and explicitly destroy owned mutable key/salt buffers where practical.
- Documented the Dart immutable-string limitation around SQLite3MultipleCiphers raw-key PRAGMA handling instead of claiming guaranteed zeroization.
- Aligned `SECURITY.md`, `docs/SECURITY_FOUNDATION.md`, and `docs/ARCHITECTURE.md` with the implemented pre-alpha security baseline.

## Next concrete action

Correct stale README/PR status, obtain green CI on the documentation/security-hardening head, then run and record the Argon2id benchmark on representative Linux and physical Android hardware. Do not freeze the production KDF parameters until both platform measurements are reviewed.

Do not add biometric/keyring convenience, lock UI, journal product screens, sync, or the final backup-container implementation to PR #7.

## Handoff

If work stops unexpectedly, the next agent should:

1. read `AGENTS.md` and this file;
2. inspect the current branch and PR rather than trusting stale chat context;
3. read `SECURITY.md`, `docs/SECURITY_FOUNDATION.md`, and `docs/ARGON2_BENCHMARK.md` before changing security code;
4. treat the Argon2id candidate as unfrozen until representative Linux and physical Android measurements exist;
5. continue from the first genuinely actionable unchecked item unless the user sets another priority;
6. update this file again before stopping.
