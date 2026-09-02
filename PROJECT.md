# Daymark project checkpoint

This file is the canonical living checkpoint for ongoing Daymark development.

Every agent must read it before meaningful work and update it before handing work off. The repository, not a chat session, is the development memory.

## Current state

- Phase: pre-alpha, first usable journal vertical slice under review
- Public release status: no release yet
- Intended first public release stage: `v1.0.0-alpha.1`
- Integration branch: `main`
- Current working branch: `feat/rebuild-unlock-daily-log`
- Current pull request: PR #13, `feat(journal): rebuild unlock and Daily Log flow`
- PR #13 status: Draft until documentation, full CI, manual Linux validation, and user review are complete
- Superseded work: PR #11 remains unmerged and is retained only as an audit/reference branch until PR #13 is proven
- Merge policy: agents never merge without explicit user approval
- Current focus: encrypted create/unlock/manual lock -> Today/Daily Log -> Rapid Logging -> persistence across relock/restart
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
- Diagnose CI/test failures at their source instead of treating a green check as proof of architecture quality.

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

## Merged foundation on `main`

### Repository / platform

- [x] Repository governance, GPL-3.0-or-later licensing, contribution and security policy
- [x] Flutter/Linux/Android scaffold
- [x] Flutter 3.47.2 / Dart 3.13.2 pinned
- [x] Riverpod 3.x, go_router 18.x, Drift 2.34.x baseline
- [x] Tiered CI: lightweight Draft validation and full merge validation
- [x] Live `main` ruleset requires the exact `merge-gate` status check
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

PR #10 merged after explicit user approval.

### Security / backup foundation

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
- [x] Android OS-managed backup/device transfer excluded
- [x] portable authenticated encrypted backup container
- [x] transactionally consistent encrypted SQLite snapshot through SQLite backup API
- [x] authenticated restore before destination mutation
- [x] integrity/FK/schema validation before replacement
- [x] staged restore with rollback copy and recovery marker
- [x] crash/interrupted-commit recovery tests

Authoritative security details remain in `SECURITY.md`, `docs/SECURITY_FOUNDATION.md`, `docs/BACKUP_FORMAT.md`, and `docs/ARCHITECTURE.md`.

## Audit of PR #11

PR #11 (`feat/unlock-daily-log`) was fully audited before further product work.

Healthy findings that were preserved conceptually:

- encrypted session ownership and fail-closed storage inspection;
- Daily Log repository boundary;
- writes through the existing semantic `JournalService`;
- persistence and security foundation remained healthy;
- 57 existing tests outside the Today widget regression test passed serially.

Problems that blocked merging PR #11:

- the Today regression test performed real filesystem/Argon2/SQLite work inside `testWidgets` and timed out before reaching `TodayScreen`;
- the test also bypassed the real application/router access transition;
- locked and unlocked states used different root `MaterialApp` configurations;
- presentation used generic `catch (_)` paths that discarded diagnostic context;
- empty master passwords were accepted by the creation flow;
- lock could compete conceptually with an in-flight journal operation;
- Today captured the date once at initialization and could remain on yesterday after midnight.

Decision: do not merge PR #11. Rebuild the vertical slice from the audited `main` baseline in PR #13 and retain #11 only as reference until the replacement is proven.

## Current work: PR #13

Goal: land the first usable end-to-end encrypted journal flow with simpler lifecycle boundaries and tests that reflect the correct layer.

Implemented on `feat/rebuild-unlock-daily-log`:

- [x] application-support paths for encrypted DB + external key envelope
- [x] incomplete DB/envelope pairs fail closed rather than being overwritten
- [x] `JournalSession` owns encrypted Drift DB, key material, repository, and application services while unlocked
- [x] create journal with master password
- [x] reject an empty master password in both UI and session manager
- [x] unlock existing encrypted journal with master password
- [x] wrong password returns to locked state without password-quality leakage
- [x] one stable `MaterialApp.router`; journal access is gated inside the route tree
- [x] manual lock closes DB before key destruction
- [x] journal operations are serialized; lock waits for an active operation before closing persistence
- [x] controller restores a known state after create/unlock/lock failures
- [x] create/unlock UI in English and pt_BR
- [x] parent Portuguese localization contains the same vertical-slice keys, eliminating the previous untranslated-message warning
- [x] Today route backed by a real Daily Log
- [x] one Daily Log per method date
- [x] Rapid Logging for Task, Event, and Note
- [x] Daily Log reads remain focused while writes continue through `JournalService`
- [x] Today refreshes after midnight and when the application resumes
- [x] widget test for Today uses an in-memory presentation boundary instead of real filesystem/cryptographic I/O
- [x] real session test proves Daily Log entries survive lock -> unlock
- [x] real session test proves manual lock waits for an active journal operation
- [x] Draft CI generation, migration snapshot, stale-artifact check, formatting, and analyzer passed on the implementation before documentation alignment
- [ ] final Draft CI after documentation alignment
- [ ] full non-Draft CI (`quality`, Linux build, Android build, dependency review, `merge-gate`)
- [ ] manual Linux create/capture/lock/unlock/restart validation
- [ ] user review / merge decision

Explicitly outside PR #13:

- automatic lock timers and operating-system lifecycle/session-lock integration;
- device-assisted unlock / platform secure storage;
- task completion/discard/migration controls in UI;
- Monthly, Future, Collections, Index, and Search product screens;
- backup/restore UI and recovery-secret UX;
- exports, sync, collaboration, or AI-generated journal content.

## Validation policy for PR #13

Before merge consideration:

1. Draft `dev-check` must be green after final documentation changes.
2. PR must be marked ready only after the Draft checks are clean.
3. Full CI must pass tests, Linux build, Android build, dependency review, and `merge-gate`.
4. The Today widget regression test must complete normally and must not perform real filesystem/Argon2/SQLite work inside `testWidgets`.
5. Manual Linux validation must use isolated test data and verify:
   - empty password rejected;
   - journal creation succeeds with a non-empty password;
   - Task, Event, and Note capture do not show a false save-failure message;
   - manual lock succeeds;
   - wrong password fails generically;
   - correct password unlocks;
   - entries remain after relock and application restart.
6. Merge remains an explicit user decision.

## Alpha milestone

Target: `v1.0.0-alpha.1` as an end-to-end but intentionally incomplete product.

### Security / journal lifecycle

- [ ] Create/open a journal with master password (PR #13 pending merge)
- [ ] Open encrypted persistence only after successful unlock (PR #13 pending merge)
- [ ] Manual lock (PR #13 pending merge)
- [ ] Automatic lock
- [ ] Recovery UX over an alternate protection path for the same random journal key
- [x] Manual encrypted backup/restore foundation
- [ ] Backup/restore product UI

### Bullet Journal product flows

- [ ] Daily Log and Rapid Logging (PR #13 pending merge)
- [ ] Task/Event/Note capture UI (PR #13 pending merge)
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
- [x] Linux CI build foundation
- [x] Android CI build foundation
- [x] core persistence/security test foundation
- [ ] physical-device review of normal Android journal flow
- [ ] desktop keyboard workflow review
- [ ] no known unresolved data-loss bug
- [ ] no known unresolved high-severity security issue

## Next work after PR #13

Do not start these until PR #13 is merged or deliberately abandoned.

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
5. Filesystem permission hardening for Linux journal files beyond the encrypted-at-rest guarantee.
6. Physical-device Android validation of the normal journal-access flow once PR #13 is stable.

## Recent work

### 2026-09-02

- Completed repository/security/domain foundation through the merged PR series.
- Merged portable encrypted backup/restore foundation through PR #9.
- Merged semantic journal application services through PR #10.
- Merged tiered CI validation through PR #12 and verified the live `merge-gate` ruleset requirement.
- Audited PR #11 after repeated CI/manual-test inconsistencies; isolated its Today widget-test timeout and chose not to merge the branch.
- Created PR #13 from clean `main` to rebuild encrypted access + Today/Daily Log with stable routing, serialized session operations, explicit password validation, date rollover, and layer-correct tests.
