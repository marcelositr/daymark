# Daymark project checkpoint

This file is the canonical living checkpoint for ongoing Daymark development.

Every agent must read it before meaningful work and update it before handing work off. The repository, not a chat session, is the development memory.

## Current state

- Phase: pre-alpha, core Bullet Journal chronological flows in active development
- Public release status: no release yet
- Intended first public release stage: `v1.0.0-alpha.1`
- Integration branch: `main`
- Current `main` baseline: PR #16 squash-merged as `c93b78380f0efdd545d533db49b30ab2f907426b`
- Current working branch: `feat/future-log`
- Current pull request: Draft PR #17, `feat(journal): add Future Log flow`
- PR #17 product scope: rolling six-month Future Log, beginning with the month after the current month, with Rapid Logging of Task/Event/Note and deliberate complete/discard actions for Future Tasks
- PR #17 deliberately does **not** expose migrate/schedule UI; that is the next focused slice after Future is merged
- Merge policy: agents never merge without explicit user approval
- Current focus: finish documentation/AI-handoff alignment on PR #17, validate the final documented head with the complete local suite and Linux debug build, then promote to Ready for full non-Draft CI
- Initial runtime targets: Linux and Android
- Pinned toolchain: Flutter 3.47.2 / Dart 3.13.2
- Initial production Argon2id baseline: **19 MiB / 2 iterations / p=1 / 32-byte output**
- Last updated: 2026-09-02 (America/Sao_Paulo)

## Mandatory working rules

- `main` is the only permanent integration branch.
- Use short-lived task branches and pull requests.
- Squash merge is the default merge strategy.
- PR titles use Conventional Commit form.
- The user makes the merge decision. AI agents do not merge implicitly or enable auto-merge.
- Read and obey `AGENTS.md` before changing code or documentation.
- Keep `PROJECT.md` current before handing work off.
- Keep `CHANGELOG.md` release-facing rather than using it as a development scratchpad.
- Follow the staged validation ladder in `AGENTS.md` and `docs/WORKFLOW.md`.
- When ARB files change, run `flutter gen-l10n` before analyzer/tests that compile presentation code.
- User terminal command blocks must be safe for an interactive shell: no bare final `exit`, no accidental shell termination, and exact branch/head checks when relevant.
- Treat CI evidence as SHA-specific. A green superseded run does not validate a later head.
- Distinguish test-harness defects from production defects before changing behavior.
- Do not weaken security, data-integrity invariants, tests, or CI merely to make a check pass.
- Remove temporary probe workflows/diagnostic scaffolding before Ready.
- Do not create placeholder product concepts merely to unblock future UI. Use real method-native destinations.

## Product doctrine

Daymark is a faithful digital Bullet Journal, not a generic productivity suite.

- local-first and offline-first;
- digital minimalism: the interface should disappear during use;
- no ads, feeds, streaks, badges, XP, gamification, productivity scoring, attention-seeking notifications, or unsolicited suggestions;
- no collaboration/social core or automatic choices that replace intentional reflection;
- notebook/sketchbook metaphor with restrained dotted-paper visual language, not a freeform canvas;
- English is canonical/fallback; exact `pt_BR` is the first additional product locale;
- architecture remains RTL-safe;
- primary navigation: Today, Monthly, Future, Collections, Search; Index remains a distinct method concept.

## Stable architecture and security baseline

### Repository / platform

- [x] GPL-3.0-or-later licensing and repository governance
- [x] Flutter/Linux/Android scaffold
- [x] Flutter 3.47.2 / Dart 3.13.2 pinned
- [x] Riverpod 3.x, go_router 18.x, Drift 2.34.x baseline
- [x] tiered CI: lightweight Draft `dev-check` and full non-Draft merge validation
- [x] live `main` ruleset requires the exact `merge-gate` status
- [x] generated Drift artifact and schema-snapshot freshness checks
- [x] English fallback, exact Brazilian Portuguese locale, light/dark/system theme foundations
- [x] staged AI/human development workflow in `AGENTS.md` and `docs/WORKFLOW.md`

### Relational / domain foundation

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

Established semantic rules:

- [x] Task, Event, and Note are distinct entry types
- [x] Task states: open, completed, migrated, scheduled, discarded
- [x] Events and Notes do not inherit task states
- [x] stable UUIDv7 identity
- [x] UTC-microsecond instants and timezone-neutral ISO method dates
- [x] one owning placement per Entry
- [x] Monthly Calendar/Tasks placement/date invariants
- [x] Future Logs are month-addressable buckets, not a second day-level calendar
- [x] Collection references are distinct from ownership and migration
- [x] deliberate migration creates a new destination Entry and preserves lineage
- [x] repeated lineage chains such as A -> B -> C remain representable
- [x] scheduling is restricted to Future Log destinations
- [x] capture creates Tasks as `open`; migrated/scheduled states arise through deliberate migration operations
- [x] cross-table semantic writes are transactional through `JournalRepository` / `JournalService`

### Security / backup foundation

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
- [x] Android OS backup/device transfer excluded
- [x] portable authenticated encrypted backup container
- [x] transactionally consistent encrypted SQLite snapshot through SQLite backup API
- [x] authenticated restore before destination mutation
- [x] integrity/FK/schema validation before replacement
- [x] staged restore with rollback copy and recovery marker
- [x] crash/interrupted-commit recovery tests

Authoritative security details remain in `SECURITY.md`, `docs/SECURITY_FOUNDATION.md`, `docs/BACKUP_FORMAT.md`, and `docs/ARCHITECTURE.md`.

## Merged user-facing journal slices

### PR #13: encrypted access + Today / Daily Log

- create/unlock/lock encrypted journal flow;
- one stable application/router root with journal access gated inside the route tree;
- serialized unlocked `JournalSession` owns encrypted persistence and key material;
- Today backed by one real Daily Log per method date;
- Rapid Logging for Task, Event, and Note;
- automatic day rollover and resume refresh;
- real session persistence tests and pure widget presentation tests.

PR #11 was the structurally unsound predecessor and was intentionally closed without merge. Do not revive it as a base.

### PR #14: automatic inactivity lock

Merged as `d93563184c01ef406398619212410c540d00712a`.

- five-minute default inactivity lock;
- pointer/touch, hardware keyboard, and text editing renew activity;
- rebuilds do not count as activity;
- background time counts;
- resume rechecks wall-clock elapsed time;
- backwards wall-clock movement fails closed;
- automatic lock uses the same serialized controller path as manual lock.

### PR #15: deliberate Task completion/discard

Merged as `b3af861dc00b81402d27cbdec39e3c99212c6590`.

- open Tasks can become completed or discarded deliberately;
- Events/Notes reject Task-only actions;
- terminal Tasks reject contradictory repeated transitions;
- completed Tasks render `×`;
- discarded Tasks retain historical `•` and strike through marker/content;
- actions preserve placement/content and persist across encrypted lock/unlock;
- final local 80-test suite, Linux debug build, Draft CI #204, full CI #205, `merge-gate`, and manual validation passed before explicit merge approval.

### PR #16: current-month Monthly Log

Squash-merged as `c93b78380f0efdd545d533db49b30ab2f907426b`.

Implemented:

- one real Monthly Log per month using existing schema v1;
- current-month screen only; historical month browsing remains deferred;
- Calendar section renders each day and captures dated Events;
- Tasks section captures open Monthly Tasks;
- complete/discard actions reuse existing deliberate Task semantics;
- Calendar/Tasks section/month/day are snapshotted before asynchronous save so UI switching cannot redirect an in-flight entry;
- month rollover occurs on resume and via a foreground month-boundary timer;
- all operations remain inside the serialized unlocked session;
- English, pt, and pt_BR localization;
- pure widget tests, repository invariant tests, and real encrypted session persistence tests.

Final evidence before merge:

- [x] local complete suite: **88 tests passed**
- [x] local Linux debug build passed
- [x] manual Linux validation passed for Calendar, Tasks, complete/discard, lock/unlock persistence, and Today regression
- [x] Draft CI #223 passed on final documented head
- [x] full non-Draft CI #224 passed `quality`, Linux, Android, dependency review, and `merge-gate`
- [x] explicit user approval received before squash merge

## Current work: PR #17 Future Log

Goal: replace the Future placeholder with a real method-faithful Future Log while reusing the existing schema and encrypted session model.

### Product shape

The initial Future Log is a rolling overview of **six future month buckets**:

- the first bucket is the month immediately after the current month;
- the current month does not appear in Future;
- each visible month maps to one existing `JournalLogKind.future` period using the first day of that month;
- Future is month-addressed, not day-addressed: do **not** add a day picker or a parallel planner/calendar system;
- Rapid Logging supports Task, Event, and Note entries in the selected future month;
- Future Tasks reuse deliberate complete/discard actions;
- the six-month horizon rolls forward when the current month changes;
- migrate/schedule UI remains outside this PR.

### Implemented on `feat/future-log`

- [x] focused `FutureLogRepository` loads/creates one Future Log bucket per month
- [x] repository capture validates that the provided owner is actually a Future Log before writing
- [x] invalid non-Future capture causes no partial Entry write
- [x] Task/Event/Note type, Task state, ordinal order, and month isolation are preserved
- [x] `JournalSession` serializes Future load/capture with all other journal operations
- [x] Future Task completion/discard reuses the existing `TaskActionService`
- [x] `/future` now renders a real Future screen instead of a placeholder
- [x] six-month horizon begins next month and crosses year boundaries naturally
- [x] Future screen snapshots selected month/type before asynchronous capture
- [x] horizon refreshes on resume and via a foreground month-boundary timer
- [x] English, pt, and pt_BR Future strings are present
- [x] pure widget tests cover six-month horizon, Task capture, Event capture, complete, and discard
- [x] repository tests cover one bucket/month, type/state/order, month isolation, invalid period, and invalid owner
- [x] real encrypted session test proves Future Task/Event data and terminal Task state survive lock -> unlock

### Validation evidence already completed

Implementation head `5fea59fb811274393a4ba86dfb9198b8cddeb1a8`:

- [x] Draft CI #233 passed locked deps, l10n, Drift generation/snapshot/stale-artifact checks, formatter, and analyzer
- [x] local `flutter gen-l10n` passed
- [x] local formatter passed with 0 changes
- [x] local analyzer passed with no issues
- [x] 5 Future repository tests passed
- [x] 4 Future widget tests passed
- [x] 1 real encrypted Future session test passed
- [x] local worktree was clean after focused validation
- [x] manual Linux product validation passed: six correct future months, Task/Event/Note capture into separate month buckets, complete/discard visuals, no false save snackbar, encrypted lock/unlock persistence, and Today/Monthly regression checks

The later documentation-hardening commits intentionally create a new final PR head. Implementation/manual evidence above remains valid for the implementation head; the final documented head must still receive the final validation required by policy before Ready.

### Remaining before PR #17 merge eligibility

1. finish documentation/AI-handoff review on this branch;
2. run final Draft CI on the documented head;
3. run the complete local Flutter test suite on the exact final documented head;
4. run Linux debug build on the same head;
5. update this checkpoint with final head/evidence if needed;
6. mark PR Ready without changing implementation;
7. require full non-Draft `quality`, Linux, Android, dependency review, and `merge-gate`;
8. ask the user for explicit merge approval;
9. squash merge only after approval.

## Next focused work after PR #17: deliberate migration/scheduling UI

Do not start this until PR #17 is merged or deliberately abandoned.

The next slice should expose the semantic migration/scheduling model that already exists in `JournalService` / `JournalRepository`, now using **real Monthly and Future destinations**.

### Required method semantics

- Migration and scheduling are deliberate user decisions. Never auto-roll unresolved Tasks because time changed.
- Only an **open Task** may be migrated or scheduled through Task actions.
- `schedule` targets a real Future Log month and marks the source Task `scheduled` (`<`).
- `migrate` must not target Future; a Future destination uses scheduling semantics.
- Migration creates a **new destination Entry** and a lineage record. Do not move the source placement in place.
- The source remains visible in its historical owner with its terminal migrated/scheduled state.
- Destination entries begin with the appropriate fresh state: a destination Task is open; Event/Note state remains null.
- One source Entry has at most one direct outgoing migration; do not offer contradictory second movement after lineage exists.
- Events/Notes may participate in traceable movement where the product flow requires it, but do not invent Task state for them.

### Product boundary for the next PR

- Reuse real `MonthlyLogRepository` / `FutureLogRepository` destinations rather than creating a temporary destination picker backed by fake containers.
- Prefer the smallest UI that proves deliberate movement end-to-end.
- Do not build historical month browsing, a general calendar, Collections migration, or a bulk reflection engine in the same PR unless a concrete dependency makes it unavoidable.
- Preserve the existing complete/discard actions and their invariants.
- Add lineage/persistence tests at repository/session level and pure presentation tests for destination selection/actions.
- Manually verify the source symbol/state, destination appearance, lock/unlock persistence, and no duplicate/contradictory migration path.

A future agent must inspect the existing migration tests and repository implementation before designing UI; do not reimplement migration semantics in widgets/providers.

## Alpha milestone

Target: `v1.0.0-alpha.1` as an end-to-end but intentionally incomplete product.

### Security / journal lifecycle

- [x] create/open encrypted journal with master password
- [x] open encrypted persistence only after successful unlock
- [x] manual lock
- [x] automatic inactivity lock
- [ ] immediate lock from reliable operating-system protected-state signals
- [ ] recovery UX over an alternate protection path for the same random journal key
- [x] encrypted backup/restore foundation
- [ ] backup/restore product UI

### Bullet Journal product flows

- [x] Daily Log and Rapid Logging
- [x] Task/Event/Note capture UI
- [x] Task completion and discard UI
- [x] Monthly Log, current-month implementation
- [x] Future Log implementation on PR #17 branch; merge still pending at this checkpoint
- [x] migration/scheduling semantic persistence and lineage
- [ ] migration/scheduling UI
- [ ] Collections
- [ ] Index
- [ ] Search without plaintext side index

### Product completeness

- [x] light, dark, and system theme infrastructure
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

## Work after migration/scheduling UI

Likely order unless new evidence changes dependencies:

1. Collections and deliberate Index behavior;
2. encrypted Search over journal storage with no plaintext side index;
3. portable backup/restore product UI;
4. explicit open export formats;
5. platform-specific immediate lock/privacy hooks where reliable signals exist;
6. accessibility, keyboard, compact Android, physical-device, and packaging passes toward alpha.

## Open questions / follow-up validation

1. Exact offline recovery-secret human representation and UX.
2. Exact optional secure-storage integration for Android/Linux assisted unlock.
3. Reliable platform hooks for immediate lock on Android device lock and Linux desktop-session lock.
4. Whether automatic-lock timeout configurability belongs before or after the first alpha; five minutes remains the security default.
5. Exact compact destination-selection UX for deliberate migration/scheduling after Future is merged.
6. Packaging/distribution formats for Linux and Android.
7. Filesystem permission hardening for Linux journal files beyond encrypted-at-rest guarantees.
8. Physical-device Android validation of the normal journal-access flow.
9. Whether historical month browsing belongs before the first alpha or can follow the initial current-month implementation.

## Historical decisions worth preserving

- PR #11 (`feat/unlock-daily-log`) was audited, closed, and intentionally not merged after structural UI/session-test problems were found.
- PR #13 rebuilt that vertical slice from clean audited `main` and established the current session/presentation testing boundary.
- Do not revive PR #11 implementation history as a base for new work.
- Do not weaken tests or security to preserve a branch that has become structurally unsound; rebuild the smallest affected slice from a healthy baseline when evidence warrants it.
- Monthly and Future were deliberately implemented before migration/scheduling UI so the latter can target real method-native destinations.
