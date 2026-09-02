# Daymark project checkpoint

This file is the canonical living checkpoint for ongoing Daymark development.

Every agent must read it before meaningful work and update it before handing work off. The repository, not a chat session, is the development memory.

## Current state

- Phase: pre-alpha, first product vertical slice in progress
- Public release status: no release yet
- Intended first public release stage: `v1.0.0-alpha.1`
- Integration branch: `main`
- Current working branch: `feat/unlock-daily-log`
- Current pull request: PR #11, `feat(journal): unlock into a functional Daily Log`
- PR #11 status: Draft until implementation, documentation, and CI are fully reviewed
- Merge policy: agents never merge without explicit user approval
- Current focus: create/open encrypted journal session -> manual lock -> Today/Daily Log -> Rapid Logging
- Initial runtime targets: Linux and Android
- Pinned toolchain: Flutter 3.47.2 / Dart 3.13.2
- Initial production Argon2id baseline: **19 MiB / 2 iterations / p=1 / 32-byte output**
- Last updated: 2026-09-02

## Working rules

- `main` is the only permanent integration branch.
- Use short-lived task branches and pull requests.
- Squash merge is the default merge strategy.
- PR titles use Conventional Commit form.
- The user makes the merge decision. AI agents do not merge implicitly or through auto-merge.
- Keep `PROJECT.md` current before handing work off.
- Keep `CHANGELOG.md` release-facing rather than using it as a development scratchpad.
- Do not weaken security or data-integrity behavior merely to make a build or test pass.
- Do not add speculative framework layers when a focused concrete boundary is sufficient.

## Product doctrine

Daymark is a faithful digital Bullet Journal, not a generic productivity suite.

- local-first and offline-first;
- digital minimalism: the interface should disappear during use;
- no ads, feeds, streaks, badges, XP, gamification, productivity scoring, attention-seeking notifications, or unsolicited suggestions;
- no collaboration/social core or automatic choices that replace intentional reflection;
- notebook/sketchbook metaphor with restrained dotted-paper visual language, not a freeform canvas;
- English is canonical/fallback; exact `pt_BR` is the first additional locale;
- architecture remains RTL-safe;
- initial navigation: Today, Monthly, Future, Collections, Search; Index remains a distinct method concept.

## Merged foundation

### Repository / platform

- [x] Repository governance, GPL-3.0-or-later licensing, contribution and security policy
- [x] Flutter/Linux/Android scaffold
- [x] Flutter 3.47.2 / Dart 3.13.2 pinned
- [x] Riverpod 3.x, go_router 18.x, Drift 2.34.x baseline
- [x] Permanent CI jobs: `quality`, `linux-build`, `android-build`, `dependency-review`
- [x] Generated Drift artifact and schema-snapshot freshness checks in CI
- [x] English fallback, exact Brazilian Portuguese locale, light/dark/system theme foundations

### Relational / domain foundation

Merged through PR #6 and PR #10.

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

Domain/application rules already enforced:

- [x] Task, Event, and Note are distinct entry types
- [x] Task states: open, completed, migrated, scheduled, discarded
- [x] Events and Notes do not inherit task states
- [x] stable UUIDv7 identity
- [x] UTC-microsecond instants and timezone-neutral ISO method dates
- [x] one owning placement per Entry
- [x] Monthly placement/date invariants
- [x] Collection references are distinct from ownership and migration
- [x] deliberate migration creates a new destination Entry and preserves lineage
- [x] repeated lineage chains such as A -> B -> C remain representable
- [x] scheduling is restricted to Future Log destinations
- [x] capture creates Tasks as `open`; migrated/scheduled states arise through deliberate migration operations
- [x] cross-table semantic writes are transactional through `JournalRepository` / `JournalService`

PR #10 merged to `main` as `2c70a990c1714ca4280ba0ecd1d803d43306eb9f` after explicit user approval.

### Security foundation

Merged through PR #7 and extended through PR #9.

- [x] one encrypted database file represents one journal
- [x] SQLite3MultipleCiphers ChaCha20-Poly1305 persistence
- [x] random 48-byte raw SQLite material: 32-byte journal key + 16-byte cipher salt
- [x] master password never used directly as SQLite key
- [x] versioned external key envelope
- [x] Argon2id KEK derivation
- [x] XChaCha20-Poly1305 authenticated wrapping
- [x] frozen production Argon2id baseline: 19 MiB / 2 / p=1 / 32 bytes
- [x] hostile/untrusted KDF parameter bounds
- [x] wrong password, tamper, truncation, unsupported format, wrong DB key, and plaintext-leakage negative tests
- [x] explicit mutable `JournalKeyMaterial` ownership and destroy lifecycle
- [x] Android OS-managed backup/device-transfer excluded from Daymark private app data
- [x] portable authenticated encrypted backup container
- [x] transactionally consistent encrypted SQLite snapshot through SQLite backup API
- [x] authenticated restore before destination mutation
- [x] integrity/FK/schema validation before replacement
- [x] staged restore with rollback copy and recovery marker
- [x] crash/interrupted-commit recovery tests

PR #9 merged to `main` as `949a2feb27d97880be684d0525239f2ca7138531` after explicit user approval.

Authoritative security details remain in `SECURITY.md`, `docs/SECURITY_FOUNDATION.md`, `docs/BACKUP_FORMAT.md`, and `docs/ARCHITECTURE.md`.

## Current work: PR #11

Goal: turn the encrypted foundation into the first usable end-to-end journal flow without expanding into the rest of the v1 product.

Implemented on `feat/unlock-daily-log`:

- [x] application-support paths for encrypted DB + external key envelope
- [x] incomplete DB/envelope pairs fail closed rather than being overwritten
- [x] `JournalSession` owns encrypted Drift DB, key material, repository, and application services while unlocked
- [x] create journal with master password
- [x] unlock existing encrypted journal with master password
- [x] wrong password returns to locked state
- [x] manual lock closes DB before key destruction
- [x] Riverpod session controller without generator use
- [x] create/unlock UI in English and pt_BR
- [x] Today route backed by a real Daily Log
- [x] one Daily Log per method date
- [x] Rapid Logging for Task, Event, and Note
- [x] Daily Log reads remain focused while writes continue through `JournalService`
- [x] tests for create/lock/unlock, wrong password, incomplete storage, Daily Log identity, entry order/type/state, and app bootstrap
- [ ] final documentation alignment
- [ ] final CI green on the reviewed PR head
- [ ] user review / merge decision

Explicitly outside PR #11:

- automatic lock timers and app lifecycle lock;
- device-assisted unlock / platform secure storage;
- task completion/discard/migration controls in UI;
- Monthly, Future, Collections, Index, and Search product screens;
- backup/restore UI and recovery-secret UX;
- exports, sync, collaboration, or AI-generated journal content.

## Alpha milestone

Target: `v1.0.0-alpha.1` as an end-to-end but intentionally incomplete product.

### Security / journal lifecycle

- [ ] Create/open a journal with master password (implemented in PR #11, pending merge)
- [ ] Open encrypted persistence only after successful unlock (implemented in PR #11, pending merge)
- [ ] Manual lock (implemented in PR #11, pending merge)
- [ ] Automatic lock
- [ ] Recovery UX over an alternate protection path for the same random journal key
- [x] Manual encrypted backup/restore foundation
- [ ] Backup/restore product UI

### Bullet Journal product flows

- [ ] Daily Log and Rapid Logging (implemented in PR #11, pending merge)
- [ ] Task/Event/Note capture UI (implemented in PR #11, pending merge)
- [ ] Task completion and discard UI
- [x] Migration/scheduling semantic persistence and lineage
- [ ] Migration/scheduling UI
- [ ] Monthly Log
- [ ] Future Log
- [ ] Collections
- [ ] Index
- [ ] Search without plaintext side index

### Product completeness

- [x] Light, dark, and system theme infrastructure
- [x] English and Portuguese (Brazil) localization infrastructure
- [ ] complete core-screen localization copy
- [ ] explicit Markdown export
- [ ] machine-readable export
- [x] Linux CI build
- [x] Android CI build
- [x] core persistence/security test foundation
- [ ] physical-device review of normal Android journal flow
- [ ] desktop keyboard workflow review
- [ ] no known unresolved data-loss bug
- [ ] no known unresolved high-severity security issue

## Next work after PR #11

Do not start these until PR #11 is merged or deliberately abandoned.

1. Add automatic lock/lifecycle behavior on top of the explicit session owner.
2. Add deliberate task actions: complete, discard, migrate, schedule.
3. Build Monthly Log and Future Log flows using the already-enforced semantic services.
4. Build Collections and deliberate Index behavior.
5. Add encrypted Search over journal storage with no plaintext side index.
6. Expose portable backup/restore in the product UI.
7. Add explicit open export formats.
8. Continue accessibility, keyboard, compact Android, and packaging passes toward alpha.

## Open questions / follow-up validation

1. Exact offline recovery-secret human representation and UX.
2. Exact optional secure-storage integration for Android/Linux assisted unlock.
3. Automatic lock policy: timeout, app background behavior, and Linux session-lock integration.
4. Packaging/distribution formats for Linux and Android.
5. Live GitHub `main` ruleset status remains difficult to confirm reliably through the connector API; the repository copy defines required checks `quality`, `linux-build`, `android-build`, and `dependency-review`.
6. Day rollover behavior for a continuously open Today screen should be handled before alpha so midnight cannot leave the UI on yesterday indefinitely.

## Recent work

### 2026-09-02

- Completed and merged the encrypted portable backup/restore foundation through PR #9.
- Completed and merged journal repository/application semantic services through PR #10.
- Started PR #11 for the first usable encrypted journal session + Daily Log vertical slice.

### 2026-09-01

- Established repository-first AI continuity and Git/PR/release governance.
- Merged project documentation foundation through PR #2.
- Merged Flutter/Linux/Android scaffold and CI through PR #3.
- Updated pinned GitHub Actions through PRs #4 and #5.
- Merged relational Drift schema v1 through PR #6.
- Completed the encrypted master-password/key-envelope foundation through PR #7.
