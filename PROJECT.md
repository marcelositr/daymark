# Daymark project checkpoint

This file is the canonical living checkpoint for ongoing Daymark development.

Every agent must read it before meaningful work and update it before handing work off. The repository, not a chat session, is the development memory.

## Current state

- Phase: pre-alpha, Monthly Log in development
- Public release status: no release yet
- Intended first public release stage: `v1.0.0-alpha.1`
- Integration branch: `main`
- Current `main` baseline: PR #15 squash-merged as `b3af861dc00b81402d27cbdec39e3c99212c6590`
- Current working branch: `feat/monthly-log`
- Current pull request: Draft PR #16, `feat(journal): add Monthly Log flow`
- PR #16 scope: current-month Monthly Log with Calendar and Tasks, dated Events, Monthly Tasks, and complete/discard actions; month browsing, Future Log, and migration/scheduling destination UI remain deferred
- Merge policy: agents never merge without explicit user approval
- Current focus: validate the final documented PR #16 head with the complete local suite and Linux debug build, then promote to Ready for full non-Draft CI
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
- Follow the staged engineering/validation ladder in `AGENTS.md` and `docs/WORKFLOW.md`: trustworthy baseline -> audit when needed -> Draft CI -> layer-correct tests -> progressive local validation -> documentation alignment -> full non-Draft CI -> explicit user merge approval.
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

### Deliberate Task completion/discard

Merged in PR #15 as `b3af861dc00b81402d27cbdec39e3c99212c6590`.

- [x] focused Task action repository/service validates persisted type and open state before terminal mutation
- [x] open Tasks can deliberately become completed or discarded
- [x] Events/Notes reject Task-only actions
- [x] terminal Tasks reject repeated or contradictory terminal transitions
- [x] original placement and content remain intact
- [x] completed Task uses `×`
- [x] discarded Task preserves the original `•` and strikes through bullet/content
- [x] task actions share the serialized session path with capture and lock
- [x] terminal state persists across encrypted lock/unlock
- [x] local 80-test suite, Linux debug build, manual Linux validation, Draft CI #204, full CI #205, and `merge-gate` all passed before explicit user-authorized squash merge

Migration/scheduling remain semantically implemented in `JournalService`/`JournalRepository`; product UI stays deferred until real destination screens exist.

## Historical decisions

- PR #11 (`feat/unlock-daily-log`) was audited, closed, and intentionally not merged after structural UI/session-test problems were found.
- PR #13 rebuilt that vertical slice from clean audited `main` and established the current staged AI/human workflow.
- Do not revive PR #11 implementation history as a base for new work.

## Current work: PR #16 Monthly Log

Goal: replace the Monthly placeholder with the first real Monthly Log while preserving Bullet Journal semantics and avoiding a generic planner/calendar product shape.

### Scope decision

PR #16 handles only the **current month**:

- Calendar section renders the dates of the month and accepts dated Event entries;
- Tasks section accepts open Task entries;
- Monthly Tasks can be completed/discarded through the same deliberate terminal-action semantics already used in Today;
- all Monthly reads/writes remain behind the unlocked serialized journal session;
- month browsing, Future Log, and migration/scheduling destination UI remain outside this PR.

### Implemented on `feat/monthly-log`

- [x] focused `MonthlyLogRepository` loads/creates one Monthly Log per month without schema changes
- [x] Monthly reads split Calendar and Tasks sections from encrypted persistence
- [x] Calendar capture delegates to `JournalService` with Monthly Calendar placement/date invariants
- [x] Tasks capture delegates to `JournalService` with Monthly Tasks placement invariants
- [x] `JournalSession` serializes Monthly load/capture with all other journal operations
- [x] Monthly Task completion/discard reuses the existing `TaskActionService`
- [x] `/monthly` route now renders a real Monthly screen instead of a placeholder
- [x] current month rolls over on resume and via a month-boundary timer while the app remains open
- [x] Calendar/Tasks section selection is captured before asynchronous saves so switching sections cannot redirect an in-flight entry
- [x] English, pt, and pt_BR Monthly strings are present
- [x] real repository tests cover one log per month, dated Calendar Events, Tasks separation, and invalid date/month behavior
- [x] pure widget tests cover dated Event capture, Task capture/completion, and discarded Task history without real filesystem/crypto work
- [x] real encrypted session test proves Monthly Event/Task state survives lock -> unlock
- [x] local focused validation passed on implementation head `63f4a672bbd3ef5e8289b24798a4811ce255d688`: repository tests green, 3 Monthly widget tests green, encrypted session tests green, analyzer clean after l10n generation
- [x] manual Linux behavior validation passed on implementation head: current-month Calendar/Tasks UI, dated Event capture, Task completion/discard, persistence across lock/unlock, and Today regression check all behaved correctly
- [x] Draft CI #221 passed generation, Drift snapshot/artifact checks, formatting, and analyzer on implementation head `63f4a672bbd3ef5e8289b24798a4811ce255d688`
- [ ] complete local suite and Linux debug build on the final documented head
- [ ] final Draft CI on the documented head
- [ ] full non-Draft CI and `merge-gate`
- [ ] explicit user merge approval

### Validation policy for PR #16

Before merge eligibility:

1. repository tests must prove one Monthly Log per month and correct Calendar/Tasks placement semantics;
2. real session tests must prove Monthly data/state persists across encrypted lock/unlock;
3. pure Monthly widget tests must validate capture and Task terminal actions without real filesystem/Argon2/SQLite work;
4. Draft CI must pass generation, Drift snapshot/artifact checks, formatting, and analyzer;
5. focused local tests must pass on the exact implementation HEAD;
6. manual Linux review must confirm Calendar/Tasks behavior, persistence, and no obvious Today regression;
7. documentation must reflect the merged PR #15 baseline and current PR #16 evidence;
8. full local suite and Linux debug build must pass on the final documented HEAD before promotion from Draft;
9. non-Draft CI must pass `quality`, Linux build, Android build, dependency review, and `merge-gate`;
10. merge remains an explicit user decision.

### Explicitly outside PR #16

- browsing previous/next months;
- Future Log product screen;
- migration/scheduling destination UI;
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
- [x] Task completion and discard UI
- [x] Migration/scheduling semantic persistence and lineage
- [ ] Migration/scheduling UI
- [ ] Monthly Log (PR #16)
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

## Next work after PR #16

Do not start these until PR #16 is merged or deliberately abandoned.

1. Build the Future Log product flow from the existing semantic model.
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
9. Whether historical month browsing belongs before the first alpha or can follow the first current-month implementation.

## Recent work

### 2026-09-02

- Completed repository/security/domain foundation through the merged PR series.
- Merged portable encrypted backup/restore foundation through PR #9.
- Merged semantic journal application services through PR #10.
- Merged tiered CI validation through PR #12 and verified the live `merge-gate` ruleset requirement.
- Audited and abandoned PR #11 rather than weakening tests or patching around structural problems.
- Rebuilt encrypted access + Today/Daily Log cleanly in PR #13 and merged after staged local/manual/full-CI validation.
- Implemented and validated automatic five-minute inactivity locking in PR #14; full CI #177 passed and the PR was squash-merged as `d93563184c01ef406398619212410c540d00712a` after explicit user approval.
- Implemented and validated deliberate Task completion/discard in PR #15; local 80-test suite, Linux build, manual validation, Draft CI #204, full CI #205, and `merge-gate` passed before squash merge as `b3af861dc00b81402d27cbdec39e3c99212c6590` after explicit user approval.
- Opened Draft PR #16 from merged `main` for the current-month Monthly Log.
- PR #16 implementation head `63f4a672bbd3ef5e8289b24798a4811ce255d688` passed focused repository/widget/session validation, manual Linux behavior validation, and Draft CI #221 before this documentation checkpoint.
