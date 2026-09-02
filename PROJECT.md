# Daymark project checkpoint

This file is the canonical living checkpoint for ongoing Daymark development.

Every agent must read it before meaningful work and update it before handing work off. The repository, not a chat session, is the development memory.

## Current state

- Phase: pre-alpha, deliberate Task actions in development
- Public release status: no release yet
- Intended first public release stage: `v1.0.0-alpha.1`
- Integration branch: `main`
- Current `main` baseline: PR #14 merged as `d93563184c01ef406398619212410c540d00712a`
- Current working branch: `feat/deliberate-task-actions`
- Current pull request: Draft PR #15, `feat(journal): add deliberate task completion and discard`
- PR #15 scope: complete/discard open Tasks in Today while preserving history; migration/scheduling UI remains deferred until real Monthly/Future destinations exist
- Merge policy: agents never merge without explicit user approval
- Current focus: finish repository/session/widget coverage for Task completion/discard, pass Draft CI, then perform progressive local/manual/full-CI validation
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
- [x] journal operations are serialized; lock waits for active work before closing persistence
- [x] controller restores a known state after create/unlock/lock failures
- [x] Today route backed by one real Daily Log per method date
- [x] Rapid Logging for Task, Event, and Note
- [x] Daily Log writes continue through semantic application services
- [x] Today refreshes after midnight and when the application resumes
- [x] widget tests keep filesystem/Argon2/SQLite outside `testWidgets`
- [x] real session tests prove persistence across lock/unlock and lock waiting for active work

### Automatic inactivity lock

Merged in PR #14 as `d93563184c01ef406398619212410c540d00712a`.

- [x] default automatic lock after five minutes without journal interaction
- [x] pointer/touch, hardware keyboard, and text editing renew the deadline
- [x] widget rebuilds do not count as activity
- [x] background time continues to count
- [x] resume immediately re-evaluates elapsed inactivity
- [x] backwards wall-clock movement fails closed on resume
- [x] automatic timeout uses the same serialized session-controller lock path as manual lock
- [x] local 71-test suite, Linux build, manual Linux behavior review, and full CI #177 passed before merge

Platform-specific immediate lock from Linux desktop-session lock or Android device-lock remains a separate future integration.

## Historical decisions

- PR #11 (`feat/unlock-daily-log`) was audited, closed, and intentionally not merged after structural UI/session-test problems were found.
- PR #13 rebuilt that vertical slice from clean audited `main` and established the current staged AI/human workflow.
- Do not revive PR #11 implementation history as a base for new work.

## Current work: PR #15 deliberate Task completion/discard

Goal: add the first visible Task lifecycle actions without creating a temporary migration/scheduling UX before destination screens exist.

### Scope decision

PR #15 handles only terminal in-place Task actions:

- complete: `open -> completed`;
- discard: `open -> discarded`.

Migration/scheduling remain semantically implemented in `JournalService`/`JournalRepository`, but their UI is deferred until real Monthly/Future destinations are available. Do not invent a temporary destination picker just to expose those operations early.

### Implemented on `feat/deliberate-task-actions`

- [x] focused `TaskActionRepository` validates persisted entry type/state before mutation
- [x] focused `TaskActionService` exposes completion/discard application operations
- [x] Event/Note entries reject Task-only terminal actions
- [x] terminal Tasks reject repeated or contradictory terminal transitions
- [x] original entry placement/content remain intact when a Task is completed/discarded
- [x] `JournalSession` serializes Task actions with capture and lock operations
- [x] real encrypted session test covers completion/discard persistence across lock -> unlock
- [x] Today data-source boundary exposes completion/discard without filesystem/crypto work in widget tests
- [x] open Task marker exposes a minimal action menu
- [x] completed Task uses `×`
- [x] discarded Task remains in journal history with a discarded marker and struck-through content
- [x] Task-action failure leaves the Task open and reports a generic UI error
- [x] English, pt, and pt_BR strings added for Task actions/failure
- [ ] final Draft CI on the implementation/documentation HEAD
- [ ] focused local tests
- [ ] complete local suite and Linux debug build
- [ ] manual Linux behavior validation
- [ ] full non-Draft CI and `merge-gate`
- [ ] explicit user merge approval

### Validation policy for PR #15

Before merge eligibility:

1. repository/application tests must prove only open Tasks can complete/discard and historical placement remains intact;
2. real session tests must prove terminal state persists across encrypted lock/unlock;
3. pure Today widget tests must prove success and fail-closed UI behavior without real filesystem/Argon2/SQLite work;
4. final Draft CI must pass generation, Drift snapshot/artifact checks, formatting, and analyzer;
5. focused local tests must pass on the exact final implementation HEAD;
6. full local suite and Linux debug build must pass before promotion from Draft;
7. manual Linux review must confirm completion/discard behavior and persistence without breaking auto-lock or capture;
8. non-Draft CI must pass `quality`, Linux build, Android build, dependency review, and `merge-gate`;
9. merge remains an explicit user decision.

### Explicitly outside PR #15

- migration/scheduling destination UI;
- Monthly Log and Future Log product screens;
- Collections/Index/Search product UI;
- configurable automatic-lock timeout;
- platform-specific immediate OS lock hooks;
- recovery/device-assisted unlock;
- backup/restore product UI or export UI.

## Alpha milestone

Target: `v1.0.0-alpha.1` as an end-to-end but intentionally incomplete product.

### Security / journal lifecycle

- [x] Create/open a journal with master password
- [x] Open encrypted persistence only after successful unlock
- [x] Manual lock
- [x] Automatic inactivity lock
- [ ] Immediate lock from reliable operating-system protected-state signals
- [ ] Recovery UX over an alternate protection path for the same random journal key
- [x] Manual encrypted backup/restore foundation
- [ ] Backup/restore product UI

### Bullet Journal product flows

- [x] Daily Log and Rapid Logging
- [x] Task/Event/Note capture UI
- [ ] Task completion and discard UI (PR #15)
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

## Next work after PR #15

Do not start these until PR #15 is merged or deliberately abandoned.

1. Build Monthly Log and Future Log product flows from the existing semantic model.
2. Expose deliberate migrate/schedule Task actions using real Monthly/Future destinations.
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
5. Exact Monthly/Future interaction design for deliberate migration and scheduling.
6. Packaging/distribution formats for Linux and Android.
7. Filesystem permission hardening for Linux journal files beyond the encrypted-at-rest guarantee.
8. Physical-device Android validation of the normal journal-access flow.

## Recent work

### 2026-09-02

- Completed repository/security/domain foundation through the merged PR series.
- Merged portable encrypted backup/restore foundation through PR #9.
- Merged semantic journal application services through PR #10.
- Merged tiered CI validation through PR #12 and verified the live `merge-gate` ruleset requirement.
- Audited and abandoned PR #11 rather than weakening tests or patching around structural problems.
- Rebuilt encrypted access + Today/Daily Log cleanly in PR #13 and merged after staged local/manual/full-CI validation.
- Implemented and validated automatic five-minute inactivity locking in PR #14; full CI #177 passed and the PR was squash-merged as `d93563184c01ef406398619212410c540d00712a` after explicit user approval.
- Opened Draft PR #15 from merged `main` for deliberate Task completion/discard, keeping migration/scheduling UI deferred until Monthly/Future destinations exist.
