# Daymark project checkpoint

This file is the canonical living checkpoint for ongoing Daymark development.

Every agent must read it before meaningful work and update it before handing work off. The repository, not a chat session, is the development memory.

## Current state

- Phase: pre-alpha, automatic journal-lock lifecycle in development
- Public release status: no release yet
- Intended first public release stage: `v1.0.0-alpha.1`
- Integration branch: `main`
- Current `main` baseline: PR #13 merged as `d9e2a5e334ce13f2efcdf99a43ac677c661eaa6d`
- Current working branch: `feat/automatic-lock-lifecycle`
- Current pull request: PR #14, `feat(session): add automatic inactivity lock`
- PR #14 status: Draft; implementation, focused local widget tests, and Draft CI #171 have passed; documentation alignment, progressive full validation, non-Draft CI, and explicit user merge approval remain
- Superseded work: PR #11 is closed and intentionally unmerged; PR #13 replaced it from a clean audited baseline
- Merge policy: agents never merge without explicit user approval
- Current focus: finish and validate the documented five-minute inactivity lock without disturbing the encrypted-session boundaries merged in PR #13
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
- Follow the staged engineering/validation ladder in `AGENTS.md` and `docs/WORKFLOW.md`: trustworthy baseline -> audit when needed -> Draft CI -> layer-correct tests -> progressive local validation -> documentation alignment -> full non-Draft CI -> explicit merge approval.
- When local-only evidence is required, agents provide complete safe command blocks with stop conditions and interpret the returned output rather than asking the user to improvise debugging.
- Command blocks intended for an interactive user shell must not terminate that shell as a side effect; report exit codes instead of calling a bare final `exit`.
- When GitHub/API data is delayed, missing, or contradictory, do not guess state; continue independent work or stop at the exact blocked boundary and request the smallest missing reference.
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
- [x] Staged AI/human development workflow in `AGENTS.md` and `docs/WORKFLOW.md`

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

### Usable encrypted journal vertical slice

Merged in PR #13 after the full audit/rebuild cycle.

- [x] application-support paths for encrypted DB + external key envelope
- [x] incomplete DB/envelope pairs fail closed rather than being overwritten
- [x] `JournalSession` owns encrypted Drift DB, key material, repository, and application services while unlocked
- [x] create journal with a non-empty master password
- [x] unlock existing encrypted journal with generic wrong-password failure
- [x] one stable `MaterialApp.router`; journal access is gated inside the route tree
- [x] manual lock closes DB before key destruction
- [x] journal operations are serialized; lock waits for an active operation before closing persistence
- [x] controller restores a known state after create/unlock/lock failures
- [x] Today route backed by one real Daily Log per method date
- [x] Rapid Logging for Task, Event, and Note
- [x] Daily Log writes continue through `JournalService`
- [x] Today refreshes after midnight and when the application resumes
- [x] widget tests keep filesystem/Argon2/SQLite outside `testWidgets`
- [x] real session tests prove persistence across lock -> unlock and lock waiting for active work
- [x] local 63-test suite, Linux debug build, manual Linux lifecycle/persistence flow, and full CI passed

## Historical audit: PR #11

PR #11 (`feat/unlock-daily-log`) was fully audited, closed, and intentionally not merged.

Healthy findings that were preserved conceptually:

- encrypted session ownership and fail-closed storage inspection;
- Daily Log repository boundary;
- writes through the existing semantic `JournalService`;
- persistence and security foundation remained healthy;
- 57 existing tests outside the invalid Today widget regression test passed serially.

Problems that blocked merging PR #11:

- the Today regression test performed real filesystem/Argon2/SQLite work inside `testWidgets` and timed out before reaching `TodayScreen`;
- the test bypassed the real application/router access transition;
- locked and unlocked states used different root `MaterialApp` configurations;
- presentation discarded diagnostic context through generic catches;
- empty master passwords were accepted;
- lock could compete conceptually with an in-flight journal operation;
- Today could remain on yesterday after midnight.

Decision: PR #13 rebuilt the vertical slice from audited `main`; #11 remains only as closed historical evidence of why the rebuild was necessary.

## Current work: PR #14 automatic inactivity lock

Goal: enforce the locking policy already defined by `SECURITY.md` without moving timeout/lifecycle concerns into cryptographic persistence code.

Implemented on `feat/automatic-lock-lifecycle`:

- [x] default automatic lock deadline is five minutes after the last journal interaction
- [x] inactivity timing lives in a presentation/lifecycle guard around unlocked journal UI; `JournalSessionManager` remains responsible for how a lock safely closes persistence
- [x] pointer/touch interaction renews the deadline
- [x] hardware keyboard interaction renews the deadline
- [x] text editing can explicitly renew the deadline so mobile IME input does not look inactive merely because it emits no Flutter `KeyEvent`
- [x] rebuilds do not count as user activity
- [x] background time does not reset the deadline
- [x] returning to foreground immediately re-evaluates elapsed wall-clock time, so a suspended platform timer cannot keep the journal open indefinitely
- [x] a backward wall-clock jump on resume fails closed instead of extending the unlocked period
- [x] automatic timeout delegates to the same session-controller lock path used by manual lock
- [x] existing serialized journal operations remain authoritative, so an operation already in progress completes before encrypted persistence is closed and key material is destroyed
- [x] timeout tests use controlled durations rather than waiting five real minutes
- [x] local focused suite passed 8 tests covering the activity guard and Today regression
- [x] Draft CI #171 passed generation, Drift snapshot/artifact checks, formatting, and analyzer

Explicitly outside PR #14:

- platform-specific immediate lock from Linux desktop-session lock or Android device-lock signals;
- configurable timeout UI or persistence of timeout preferences;
- device-assisted unlock / platform secure storage;
- operating-system recent-app/screenshot privacy hardening;
- task completion/discard/migration controls;
- Monthly, Future, Collections, Index, Search, or backup/restore product UI.

## Validation policy for PR #14

Before merge eligibility:

1. documentation must match the implemented five-minute inactivity policy and its platform boundary;
2. the full local test suite must pass on the exact final branch HEAD;
3. Linux debug build must pass locally;
4. manual Linux review must confirm normal create/unlock/use/manual-lock behavior remains intact and the real five-minute idle timeout locks an unlocked journal;
5. non-Draft CI must pass `quality`, Linux build, Android build, dependency review, and `merge-gate`;
6. merge remains an explicit user decision.

The focused automated coverage includes:

- timeout after the inactivity deadline;
- pointer/touch reset;
- physical-keyboard reset;
- explicit text-edit/IME-style reset;
- immediate lock after a background gap beyond the deadline;
- preservation of only the remaining deadline after a shorter background gap;
- fail-closed handling of a backward wall-clock jump;
- existing Today capture regression behavior.

## Alpha milestone

Target: `v1.0.0-alpha.1` as an end-to-end but intentionally incomplete product.

### Security / journal lifecycle

- [x] Create/open a journal with master password
- [x] Open encrypted persistence only after successful unlock
- [x] Manual lock
- [ ] Automatic inactivity lock (PR #14 pending validation/merge)
- [ ] Immediate lock from reliable operating-system protected-state signals
- [ ] Recovery UX over an alternate protection path for the same random journal key
- [x] Manual encrypted backup/restore foundation
- [ ] Backup/restore product UI

### Bullet Journal product flows

- [x] Daily Log and Rapid Logging
- [x] Task/Event/Note capture UI
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

## Next work after PR #14

Do not start these until PR #14 is merged or deliberately abandoned.

1. Add deliberate task actions: complete, discard, migrate, schedule.
2. Build Monthly Log and Future Log flows using the already-enforced semantic services.
3. Build Collections and deliberate Index behavior.
4. Add encrypted Search over journal storage with no plaintext side index.
5. Expose portable backup/restore in the product UI.
6. Add explicit open export formats.
7. Add platform-specific immediate lock/privacy hooks where reliable signals are available.
8. Continue accessibility, keyboard, compact Android, and packaging passes toward alpha.

## Open questions / follow-up validation

1. Exact offline recovery-secret human representation and UX.
2. Exact optional secure-storage integration for Android/Linux assisted unlock.
3. Reliable platform hooks for immediate lock on Android device lock and Linux desktop-session lock.
4. Whether timeout configurability belongs before or after the first alpha; five minutes remains the security default.
5. Packaging/distribution formats for Linux and Android.
6. Filesystem permission hardening for Linux journal files beyond the encrypted-at-rest guarantee.
7. Physical-device Android validation of the normal journal-access flow.

## Recent work

### 2026-09-02

- Completed repository/security/domain foundation through the merged PR series.
- Merged portable encrypted backup/restore foundation through PR #9.
- Merged semantic journal application services through PR #10.
- Merged tiered CI validation through PR #12 and verified the live `merge-gate` ruleset requirement.
- Audited PR #11 after repeated CI/manual-test inconsistencies; isolated its invalid Today widget-test design and closed the PR without merge.
- Rebuilt encrypted access + Today/Daily Log cleanly in PR #13 with stable routing, serialized session operations, password validation, date rollover, layer-correct tests, and the staged AI/human engineering workflow.
- Validated PR #13 locally and through full CI, then squash-merged it to `main` after explicit user approval.
- Opened PR #14 from the merged #13 baseline to implement the documented five-minute automatic inactivity lock.
- Added interaction-driven timeout handling for pointer/touch, hardware keyboard, and explicit text editing; background/resume elapsed-time enforcement; and fail-closed handling of backward wall-clock jumps.
- Passed 8 focused local tests and Draft CI #171 on the implementation HEAD before documentation alignment.
