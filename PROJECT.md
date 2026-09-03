# Daymark project checkpoint

This is Daymark's canonical living handoff. Read this file and `AGENTS.md` before meaningful work. Update this file before handing work off. The repository, not a chat transcript, is the project memory.

## Current state

- Phase: pre-alpha, core Bullet Journal chronological flows in active development.
- Integration branch: `main` only.
- Current `main` baseline: PR #17 squash-merged as `8a9a74bb5158159818822487e71fcc220a0acbf8`.
- Current working branch: `feat/task-migration-scheduling`.
- Current pull request: Draft PR #18, `feat(journal): add deliberate task scheduling`.
- Current product scope: deliberate Task scheduling (`<`) from Today and Monthly into one of the six real Future Log month buckets.
- Deliberate migration (`>`) is **not** exposed yet. It remains deferred until Daymark has a method-faithful accessible destination such as the next Monthly Log or a Collection.
- Merge policy: never merge without explicit user approval.
- Runtime targets: Linux and Android.
- Pinned toolchain: Flutter 3.47.2 / Dart 3.13.2.
- Production Argon2id baseline: 19 MiB / 2 iterations / p=1 / 32-byte output.
- Last updated: 2026-09-03 (America/Sao_Paulo).

## Product doctrine

Daymark is a faithful digital Bullet Journal, not a generic productivity suite.

- local-first and offline-first;
- digital minimalism and low distraction;
- no feeds, ads, streaks, XP, productivity scoring, gamification, or attention-seeking UI;
- no automatic choices that replace deliberate reflection;
- notebook/sketchbook metaphor with restrained dotted-paper language, not a freeform canvas;
- English is canonical/fallback; exact `pt_BR` is the first additional locale;
- architecture remains RTL-safe;
- primary navigation: Today, Monthly, Future, Collections, Search; Index remains a distinct method concept.

## Mandatory working rules

- `main` is the only permanent integration branch. Use short-lived branches and PRs.
- Squash merge is the default merge strategy.
- PR titles use Conventional Commit form.
- The user makes the merge decision. Never enable auto-merge or merge implicitly.
- Read and obey `AGENTS.md`, `docs/WORKFLOW.md`, architecture/domain/security docs before changing their areas.
- Keep `PROJECT.md` current. Keep `CHANGELOG.md` release-facing rather than using it as scratchpad.
- Run `flutter gen-l10n` after ARB changes and before analyzer/tests that compile presentation code.
- Treat formatter output from the pinned Dart version as authoritative. When applying formatter output through an API, preserve the final newline and revalidate the exact blob/head.
- Treat CI evidence as SHA-specific. A green superseded run does not validate a newer head.
- Distinguish mechanical CI failures and test-harness defects from production defects before changing behavior.
- Never weaken security, persistence invariants, tests, or CI to make a check green.
- Remove temporary probe workflows/diagnostic scaffolding before Ready.
- User terminal blocks must be safe for an interactive shell: no bare final `exit`, no accidental shell termination, exact branch/head checks when relevant.
- Do not invent fake product destinations or temporary domain concepts merely to unblock UI.
- Do not reimplement repository/service semantics inside widgets or providers.

## Critical UI lifecycle guardrail

The router uses `StatefulShellRoute.indexedStack`. Top-level sections are intentionally retained while another tab is active.

Therefore:

- **do not assume `initState()` runs again when a user returns to a retained tab**;
- a screen that displays data which can be changed from another retained section must refresh that stale snapshot when its section becomes active again;
- do not fix this by destroying every tab, polling the database, or adding an unrelated global cache;
- `AppSectionScope` is the current presentation-level activation signal for retained top-level sections;
- the Future screen uses section activation to reload its six snapshots after Today/Monthly scheduling changes Future data.

This guardrail exists because PR #18 initially persisted scheduled Tasks correctly while Future displayed stale in-memory data until lock/restart. The user found the bug manually. It now has a regression test.

## Stable architecture and security baseline

### Domain / persistence

Schema v1 already contains the structures needed by current work:

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

Durable semantic rules:

- Task, Event, and Note are distinct entry types.
- Task states: open, completed, migrated, scheduled, discarded.
- Events and Notes do not inherit Task states.
- One owning placement per Entry.
- Monthly Calendar/Tasks placement/date invariants are enforced.
- Future is month-addressed, not a second day-level calendar.
- Scheduling targets a Future Log.
- Deliberate movement creates a **new destination Entry** plus lineage; do not move the source placement in place.
- The historical source remains visible with terminal state; a scheduled destination Task begins open.
- One source Entry has at most one direct outgoing movement lineage.
- Cross-table semantic writes stay transactional through `JournalRepository` / `JournalService`.
- `JournalSession` serializes unlocked journal operations and owns encrypted persistence/key lifetime.

### Security / backup

Do not casually modify these contracts. Authoritative details live in `SECURITY.md`, `docs/SECURITY_FOUNDATION.md`, `docs/BACKUP_FORMAT.md`, and `docs/ARCHITECTURE.md`.

Current foundation includes:

- SQLite3MultipleCiphers ChaCha20-Poly1305 encrypted persistence;
- random 48-byte SQLite material: 32-byte key + 16-byte cipher salt;
- master password never used directly as the SQLite key and never persisted;
- Argon2id-derived KEK + XChaCha20-Poly1305 external versioned key envelope;
- explicit mutable key-material destruction;
- Android OS backup/device-transfer exclusion;
- portable authenticated encrypted backup with integrity validation and recovery protections.

PR #18 changes no database schema, crypto, key lifecycle, or backup format.

## Merged product history that matters

### PR #11

Structurally unsound unlock/Daily attempt. Closed without merge and superseded. Do not revive it as a base.

### PR #13

Encrypted create/unlock/manual-lock flow and real Today/Daily Log with Rapid Logging Task/Event/Note, serialized session, persistence and rollover.

### PR #14

Automatic five-minute inactivity lock. Squash-merged as `d93563184c01ef406398619212410c540d00712a`.

### PR #15

Deliberate Task completion/discard. Squash-merged as `b3af861dc00b81402d27cbdec39e3c99212c6590`.

Visual states established:

- open `•`
- completed `×`
- migrated `>`
- scheduled `<`
- discarded remains historical `•` with marker/content struck through

### PR #16

Current-month Monthly Log. Squash-merged as `c93b78380f0efdd545d533db49b30ab2f907426b`.

- Calendar: every day + dated Event capture.
- Tasks: open monthly Tasks + complete/discard.
- current month only; historical browsing deferred.
- final local suite had 88 tests; Linux/manual/full CI green before explicit merge approval.

### PR #17

Six-month Future Log. Squash-merged as `8a9a74bb5158159818822487e71fcc220a0acbf8`.

- six Future buckets beginning next month;
- current month excluded;
- Task/Event/Note Rapid Logging;
- Future Task complete/discard;
- horizon rolls forward with month change;
- no schema changes;
- documentation/AI handoff was broadly hardened in this PR;
- final local suite had 98 tests, Linux build/manual/full CI green before explicit merge approval.

## Current work: PR #18 deliberate Task scheduling

### Method-fidelity decision

The branch initially experimented with exposing `>` from Today into the **current** Monthly Log. That implementation was removed during Draft review.

For Daymark's Bullet Journal method:

- `<` = schedule into a Future Log;
- `>` = migrate forward into the next Monthly Log or an appropriate Collection.

Current Monthly exposes the current month only, and Collections are not yet an implemented movement destination. Therefore shipping Today -> current Monthly as `>` would institutionalize the wrong method semantics.

**Do not reintroduce that shortcut.** Migration UI remains deferred until a real next-Monthly or Collection destination exists.

### Implemented scope

- Today open Tasks offer Complete / Schedule / Discard.
- Monthly open Tasks offer Complete / Schedule / Discard.
- Schedule opens a six-month selector matching the real Future horizon.
- The source Task remains in Today/Monthly and becomes `scheduled` (`<`).
- A new destination Task is created in the chosen Future month as `open` (`•`).
- Scheduling reuses `JournalService.schedule` / `JournalRepository` lineage semantics.
- `JournalSession.scheduleTaskToFuture` keeps resolution + movement inside the serialized session.
- `TaskActionService` / `TaskActionRepository` expose reusable persisted-source validation for Task-only actions.
- Event, Note, or already-terminal Task is rejected **before** creating/resolving the Future destination.
- No in-place owner move, fake Future container, general calendar, historical-month browser, Collection movement, or bulk reflection engine is part of PR #18.

### Retained-Future refresh fix

Manual Linux validation found that scheduling persisted correctly but Future did not display the destination immediately when navigating to it. Lock/restart made it appear.

Root cause: `StatefulShellRoute.indexedStack` retains Future, so its initial `_snapshotsFuture` did not automatically reload when Today/Monthly changed Future data.

Fix:

- added presentation-level `AppSectionScope` backed by the active section index;
- `AppShell` publishes section activation while preserving retained branches;
- `FutureScreen.didChangeDependencies` detects inactive -> Future activation and reloads the six snapshots;
- regression widget test proves external Future data becomes visible on section reactivation without remount, lock, or restart.

The user manually retested the exact scenario and confirmed immediate Future visibility now works.

### Validation already completed on implementation code

Implementation/manual baseline before this documentation checkpoint: `2090e47b90387cbbd3e485f6aede68f3d6cf4f2b`.

- focused analyzer: no issues;
- focused scheduling tests before the refresh fix: 11 tests passed;
- manual Linux: Today scheduling, Monthly scheduling, source `<`, destination `•`, correct Future month, lock/unlock persistence, no false error snackbar;
- manual Linux after refresh fix: destination appears immediately on entering Future, without lock/restart;
- regression test added for retained Future snapshot refresh;
- formatter output was taken from pinned Dart 3.13.2; final formatted blobs include the required trailing newline;
- temporary formatter probe was removed before finalization.

Because this documentation commit creates a newer PR head, final CI/local evidence must be collected on the **exact final documented SHA** before Ready.

### Remaining before PR #18 can become Ready

1. final Draft `dev-check` green on the documentation-hardened head;
2. local `flutter gen-l10n` on that same head;
3. formatter with zero changes on that same head;
4. analyzer with no issues;
5. complete local Flutter test suite;
6. Linux debug build;
7. clean worktree;
8. record final evidence in PR metadata without changing the validated head;
9. mark PR Ready;
10. require non-Draft `quality`, Linux, Android, dependency review, and `merge-gate` green;
11. ask the user for explicit merge approval;
12. squash merge only after approval.

## Next work after PR #18

Do not automatically assume the next PR should expose `>`.

A method-faithful migration UI needs a real destination. The likely dependency order is:

1. implement enough Collections/Index or next-Monthly access to provide a genuine migration target;
2. then expose deliberate `>` movement using the existing repository/service lineage semantics;
3. keep Search, backup UI, exports, OS lock hooks, accessibility/keyboard/Android packaging as later focused slices.

Before designing the next slice, inspect the existing migration repository/service tests and the current product surface. Never create a placeholder destination merely to make `>` clickable.

## CI and handoff traps to remember

- Draft PR: only `dev-check` is expected; non-Draft jobs are intentionally skipped.
- Ready/non-Draft: `quality`, `linux-build`, `android-build`, `dependency-review`; `merge-gate` requires them.
- A red formatter after semantic work is not evidence of a production defect. Apply the pinned formatter output exactly.
- GitHub contents writes can accidentally lose a trailing newline; verify final formatter result/blob rather than repeatedly editing by eye.
- A temporary workflow probe must not remain in the final PR diff.
- `StatefulShellRoute.indexedStack` retains screens; section navigation is not a remount lifecycle.
- Manual product tests remain important for cross-screen freshness, persistence behavior, and false-success/false-error UI that isolated repository tests cannot expose.
