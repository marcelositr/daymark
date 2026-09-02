# Daymark project checkpoint

This file is the canonical living checkpoint for ongoing Daymark development.

Every agent must read it before meaningful work and update it before handing work off. It exists so the project can survive chat limits, CLI restarts, API quotas, different agents, and long gaps without depending on hidden conversation context.

## Current state

- Phase: foundation / pre-alpha
- Public release status: no release yet
- Intended first public release stage: `v1.0.0-alpha.1`
- Integration branch: `main`
- Current working branch: `main` (no active feature branch)
- Current pull request: none; security foundation PR #7 is merged
- Merge status: PR #7 was merged after explicit user approval; future PRs remain gated by explicit user review/merge decisions
- Current focus: close the live `main` ruleset required-check gap, then begin the encrypted portable backup/restore foundation
- Initial runtime targets: Linux and Android
- Pinned toolchain: Flutter 3.47.2 / Dart 3.13.2
- Initial production Argon2id baseline: **frozen at 19 MiB / 2 iterations / p=1 / 32-byte output**
- Last updated: 2026-09-02

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
- [x] Security foundation completed and merged through PR #7

### Still required before product feature work becomes the main focus

- [ ] Apply and verify required CI check names in the live `main` ruleset
- [ ] Specify and implement the encrypted portable backup container / restore transaction
- [ ] Establish repository/application services that enforce semantic invariants spanning multiple tables

## Security foundation baseline (merged PR #7)

Authoritative validation plan: `docs/SECURITY_FOUNDATION.md`.

### Portable trust foundation

- [x] Confirm maintained Argon2id API/library on the pinned toolchain (`cryptography` 2.9.0)
- [x] Confirm maintained AEAD API/library for key-envelope protection (`XChaCha20-Poly1305` through `cryptography` 2.9.0)
- [x] Generate journal data-encryption keys from a cryptographically secure random source
- [x] Define versioned key-envelope format v1 outside the encrypted Drift database
- [x] Derive a key-encryption key from master password + random salt + explicit Argon2id parameters
- [x] Authenticated-wrap and unwrap random journal key material
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

The normal build matrix always bundles SQLite3MultipleCiphers, so CI does not manufacture a second native runtime containing only vanilla SQLite to exercise the unavailable-library branch. The runtime check remains mandatory implementation behavior.

### Password-hardening validation

- [x] Add reproducible Argon2id benchmark harness
- [x] Record representative Linux benchmark results
- [x] Define Android physical-device benchmark procedure
- [x] Record representative physical Android benchmark results
- [x] Compare OWASP-listed memory/iteration profiles on Linux and physical Android hardware
- [x] Preserve raw profile-matrix evidence under `docs/argon2-results/`
- [x] Freeze the initial production Argon2id parameters after Linux + physical Android review
- [x] Keep KDF parameters explicit in the envelope for future strengthening
- [x] Bound untrusted envelope parameters independently from the selected production work factor

Frozen initial production baseline:

- memory: 19 MiB (`19456 KiB`);
- iterations: 2;
- parallelism: 1;
- output: 32 bytes;
- random KDF salt: 16 bytes per envelope.

Benchmark procedure and rationale: `docs/ARGON2_BENCHMARK.md`.

Representative evidence includes:

- Debian 13 / Intel Core i5-2400;
- Samsung SM-A015M / Android 12 / 32-bit ARM runtime;
- M7 3G PLUS / Android 8.1 / 32-bit ARM as a deliberately conservative old-device point.

The lower-memory alternatives improved the oldest Android device only modestly and offered effectively no Linux latency advantage. Daymark therefore retains the higher-memory 19 MiB / 2 baseline instead of weakening memory hardness merely to make unusually slow hardware somewhat faster.

### Android OS-backup boundary

- [x] Disable Android app-data backup through `android:allowBackup="false"`
- [x] Provide Android 11-and-earlier full-backup exclusions for all Daymark app-data domains
- [x] Provide Android 12+ cloud-backup exclusions for all Daymark app-data domains
- [x] Provide Android 12+ device-transfer exclusions for all Daymark app-data domains
- [x] Document Android OS backup as distinct from Daymark's future explicit encrypted portable backup

The hardening was prompted by physical-device investigation: an Android full-backup job included Daymark and terminated a running Argon2 benchmark process. The observed interruption was platform backup behavior, not evidence of Argon2 OOM or cryptographic failure.

### Key/session boundaries

- [x] Define single-owner journal-key material through `JournalKeyMaterial`
- [x] Use overwrite-on-destroy secret-key storage and wipe owned mutable key/salt buffers where practical
- [x] Keep key destruction idempotent for converging lock/error/teardown paths
- [x] Avoid logging/persisting key material
- [x] Document Dart runtime limits around guaranteed memory zeroization
- [x] Document the immutable hexadecimal `String` limitation imposed by SQLite3MultipleCiphers' SQL `PRAGMA key` interface
- [x] Preserve an explicit destroy lifecycle that later manual/automatic lock can own through an unlocked-session abstraction

Actual lock timers, lifecycle UI, Android device-lock integration, and Linux session-lock integration remain later product tasks and were outside PR #7.

### Documentation / review

- [x] Align `SECURITY.md` with proven implementation details
- [x] Align `docs/SECURITY_FOUNDATION.md` with proven implementation details
- [x] Align `docs/ARCHITECTURE.md` with proven implementation details
- [x] Add reproducible Linux/Android Argon2id benchmark procedure
- [x] Record matrix evidence and KDF freeze rationale
- [x] Document Android OS-backup exclusions
- [x] Update `CHANGELOG.md` with the pre-alpha security foundation
- [x] CI #75 green on pre-benchmark baseline (`40312d01b9746874c8fb1f480984705c6f90f5cc`)
- [x] CI #88 green after physical benchmark evidence commit (`e3cdd95edc7c5006419a093bd536b193fb31bbdb`)
- [x] CI #99 green on the fully aligned reviewed implementation head (`5c790cc75cb6db7b421ae2b0ac82e1c81008ac1f`)
- [x] CI #100 green on the checkpoint-sync head (`82424f39836be103ed6db08f6b22a00b23517c65`)
- [x] User review / merge decision completed; PR #7 merged into `main` as `e29e3fa26521e9a67c58e36ef73b45ea16b48d8e`

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
- frozen initial Argon2id production baseline: 19 MiB / 2 / p=1 / 32-byte output
- platform secure storage deferred to a later device-assisted unlock task
- UUID v7 through `uuid`
- Flutter `gen_l10n`, English canonical/fallback, Portuguese (Brazil) first additional locale
- GitHub Actions with immutable action SHAs

`flutter_secure_storage` 11.0.0 was intentionally not retained in the baseline because its Android compileSdk requirement did not match the pinned Flutter-generated Android toolchain. Device-assisted unlock must be re-evaluated when that feature is implemented rather than distorting the baseline for an unused convenience layer.

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

1. Exact offline recovery-secret human representation and UX. The cryptographic relationship to the random journal key is established.
2. Exact secure-storage integration for optional Android/Linux assisted unlock.
3. Exact encrypted backup container versioning, atomic restore, and rollback behavior.
4. Packaging/distribution formats for Linux and Android.
5. Live GitHub ruleset still needs the repository-defined required check names applied and verified.
6. Repository/application services must enforce cross-table semantic invariants that ordinary SQLite `CHECK` constraints cannot express.

Resolved during PR #7:

- key-envelope v1 uses Argon2id + XChaCha20-Poly1305 through `cryptography` 2.9.0;
- envelope metadata/serialization and negative failure paths are implemented and tested;
- SQLite3MultipleCiphers uses the documented ChaCha20 32-byte raw key + 16-byte salt representation;
- encrypted database opening requires an actual read after `PRAGMA key`;
- Drift creation is forced through its lazy-open lifecycle before `createNew()` returns;
- journal-key ownership has explicit idempotent destruction boundaries;
- recovery is architecturally a second portable protection path over the same random journal key rather than a device/account reset mechanism;
- the initial Argon2id production baseline is frozen at 19 MiB / 2 / p=1 / 32 bytes after Linux and physical Android benchmarking;
- Android OS-managed backup/cloud migration is explicitly excluded from Daymark app-private state; Daymark's own encrypted backup/restore path remains the portable migration mechanism.

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
- Opened draft PR #7 on `feat/security-foundation` for master-password key hierarchy and encrypted journal validation.
- Implemented random journal-key material and version-1 Argon2id/XChaCha20-Poly1305 key envelope.
- Implemented SQLite3MultipleCiphers encrypted journal creation/opening and runtime cipher capability checking.
- Proved correct-key reopen, wrong-key rejection, unkeyed SQLite unreadability, representative plaintext absence, and schema constraints through encrypted persistence.
- Added Argon2id benchmark tooling and security documentation.
- CI #75 completed successfully on baseline head `40312d01b9746874c8fb1f480984705c6f90f5cc`.

### 2026-09-02

- Recorded the representative Linux Argon2id profile matrix on Intel Core i5-2400 hardware.
- Recorded physical Android profile matrices on Samsung SM-A015M and M7 3G PLUS hardware.
- Preserved raw profile-matrix evidence under `docs/argon2-results/`.
- Compared OWASP-listed Argon2id memory/iteration tradeoffs across all three physical systems.
- Froze the initial production baseline at 19 MiB memory, 2 iterations, parallelism 1, 32-byte output.
- Investigated an interrupted M7 matrix run and traced the process termination to an Android full-backup job rather than Argon2/OOM behavior.
- Disabled Android app-data backup and added explicit Android 11-and-earlier and Android 12+ cloud/device-transfer exclusions.
- CI #88 completed successfully after the Samsung matrix evidence commit.
- Aligned the core security and architecture documents with the KDF freeze and Android backup boundary.
- CI #99 completed successfully on the fully aligned reviewed implementation head `5c790cc75cb6db7b421ae2b0ac82e1c81008ac1f`; all four permanent jobs were green.
- Re-audited PR #7 after the previous agent session ended before recording CI #99, and synchronized this checkpoint without expanding PR scope.
- CI #100 completed successfully on checkpoint-sync head `82424f39836be103ed6db08f6b22a00b23517c65`.
- User reviewed and merged security foundation PR #7 into `main` as `e29e3fa26521e9a67c58e36ef73b45ea16b48d8e`.

## Next concrete action

Apply and verify the repository-defined permanent CI checks in the live `main` ruleset: `quality`, `linux-build`, `android-build`, and `dependency-review`.

After that governance gap is closed, start a focused branch/PR to specify and implement the encrypted portable backup container and atomic/rollback-safe restore transaction.

Do not mix biometric/keyring convenience, lock UI, journal product screens, sync, or unrelated feature work into the backup-foundation task.

## Handoff

If work stops unexpectedly, the next agent should:

1. read `AGENTS.md` and this file;
2. inspect `main`, the live ruleset, and any active PR rather than trusting stale chat context;
3. treat security foundation PR #7 as merged baseline, not active work;
4. read `SECURITY.md`, `docs/SECURITY_FOUNDATION.md`, `docs/ARGON2_BENCHMARK.md`, and `docs/ARCHITECTURE.md` before changing security code;
5. treat 19 MiB / 2 / p=1 / 32-byte output as the frozen initial production KDF baseline unless a new reviewed retuning cycle explicitly changes it;
6. preserve the Android OS-backup exclusion boundary;
7. close the live required-check ruleset gap before starting the next feature branch unless the user explicitly reprioritizes;
8. update this file again before stopping.