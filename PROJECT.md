# Daymark project checkpoint

This is Daymark's canonical living handoff. Read this file and `AGENTS.md` before meaningful work. Update this file before handing work off. The repository, not a chat transcript, is the project memory.

## Current state

- Phase: pre-alpha, core Bullet Journal flows in active development.
- Integration branch: `main` only.
- Current `main` head before the active feature PR: `bf8018c0e2250566af39e9f90632e5808c780783` (`docs: checkpoint PR 18 merge (#19)`).
- Current merged product baseline: PR #18 squash-merged as `03ef4d187845ff13128f28298336b540b3237e9e`.
- Active product implementation branch/PR: `feat/collections` / PR #20, `feat(journal): add basic collections`.
- PR #20 is Ready for review. Its current implementation provides a real minimal Collections surface without exposing forward migration (`>`), Index, references from chronological logs, planner abstractions, or schema changes.
- Current merged product scope already includes deliberate Task scheduling (`<`) from Today and Monthly into one of the six real Future Log month buckets.
- Deliberate migration (`>`) is **not** exposed yet. Collections now provide a real non-Future owning structure in PR #20, but merely having that structure does not justify exposing migration without a deliberate destination-selection flow and lifecycle coverage.
- Current focus: validate this final documentation-only head with the full Ready CI, perform proportionate manual product validation if needed, then stop for explicit user merge approval.
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
- Do not use the user as a routine CI/formatter runner when repository tooling can perform the work. Ask for local execution only when local hardware/product behavior genuinely matters.
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

PR #20 does not yet introduce a cross-surface write into Collections. Its Collection screen changes only its own selected/listed state, so an activation refresh hook is not required for this slice. When migration or references can change Collections from another retained section, add the corresponding reactivation regression coverage rather than relying on remount behavior.

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
- A Collection is a simple owning content container, not a configurable database/workspace.
- A Collection reference is distinct from Collection ownership and does not move the Entry.
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

PR #20 changes no database schema, crypto, key lifecycle, backup format, dependency set, or plaintext boundary. Collection reads/writes remain inside the already encrypted journal database and the serialized unlocked session.

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

### PR #18

Deliberate Task scheduling. Squash-merged as `03ef4d187845ff13128f28298336b540b3237e9e` on 2026-09-03.

Method-fidelity decision:

- `<` schedules an open Task into a real Future Log month;
- `>` remains reserved for deliberate forward migration into a method-faithful non-Future destination such as the next Monthly Log or an appropriate Collection;
- the discarded experiment Today -> current Monthly as `>` was removed before merge and must not be reintroduced.

Implemented behavior:

- Today open Tasks offer Complete / Schedule / Discard.
- Monthly open Tasks offer Complete / Schedule / Discard.
- Schedule opens a six-month selector matching the real Future horizon.
- The source Task remains historical and becomes `scheduled` (`<`).
- A new destination Task is created in the chosen Future month as `open` (`•`).
- Scheduling reuses `JournalService.schedule` / `JournalRepository` lineage semantics.
- `JournalSession.scheduleTaskToFuture` keeps destination resolution + movement inside the serialized unlocked session.
- `TaskActionService` / `TaskActionRepository` expose reusable persisted-source validation for Task-only actions.
- Event, Note, or already-terminal Task is rejected before creating/resolving the Future destination.
- No in-place owner move, fake Future container, general calendar, historical-month browser, Collection movement, or bulk reflection engine was added.

Retained-Future refresh fix:

- manual Linux testing found that scheduling persisted correctly while Future displayed stale snapshots until lock/restart;
- root cause was `StatefulShellRoute.indexedStack` retaining Future, so returning to the tab did not rerun `initState()`;
- `AppSectionScope` now publishes top-level activation and Future reloads its six snapshots on inactive -> active transition;
- a widget regression test proves externally changed Future data appears on reactivation without remount, lock, or restart;
- manual Linux retest confirmed immediate visibility.

Validation lineage:

- code-equivalent head `9bbcecc52777a64a86d001b6f311a062146cd678`: Draft CI #286 green; local `flutter gen-l10n` green; formatter 55 files / 0 changes; analyzer clean; **103 tests passed**; Linux debug build passed; worktree clean; manual Today/Monthly scheduling and retained-Future refresh passed; full CI #287 green;
- final documentation-audited PR head `d14c0796dca442f13a4fda52256762ced4c32d8a`: every change after `9bbcecc...` was documentation-only; README/changelog/product/domain/architecture/agent/contribution/workflow/backup/checkpoint guidance was reconciled; security/data-model/KDF docs were reviewed and intentionally unchanged where their contracts were unaffected;
- final full CI #300 on `d14c0796...`: `quality`, Linux build, Android build, dependency review, and `merge-gate` all green;
- explicit user approval was received; squash merge produced `03ef4d187845ff13128f28298336b540b3237e9e` on `main`.

## Active PR #20: basic Collections

Branch: `feat/collections`.

PR: #20, `feat(journal): add basic collections`.

Scope implemented:

- replaces the `/collections` placeholder with a minimal real Collections surface;
- adds a focused `CollectionRepository` for listing/loading Collections while keeping semantic writes in `JournalService`;
- exposes list/create/load/capture through the serialized `JournalSession`;
- lists and creates Collections;
- opens a Collection and Rapid Logs Task, Event, and Note entries owned by it;
- open Collection Tasks support Complete and Discard only;
- adds English, `pt`, and `pt_BR` localization resources for the new UI;
- repository tests cover ownership, ordering, and no-partial-write failure behavior;
- widget tests cover create/open/capture and Task complete/discard;
- session coverage proves Collection entries and Task state persist across lock/unlock;
- no schema, crypto, backup, dependency, or platform-contract change.

Explicit non-goals remain:

- no forward migration (`>`);
- no scheduling (`<`) from Collections in this slice;
- no Collection-reference UI from Today/Monthly;
- no Index;
- no reorder/drag-and-drop;
- no tags/properties/Kanban/planner workspace behavior;
- no historical/future Monthly browser;
- no schema v2.

Validation so far:

- CI #308 exposed a mechanical formatter failure in three new files before analyzer ran; it was not a production defect;
- the pinned Dart 3.13.2 formatter output was recovered exactly and applied, rather than changing behavior to satisfy CI;
- the first analyzer pass then exposed a test-only `isNull` import collision between Drift and `flutter_test`; the test import was narrowed with `hide isNull`;
- user-local validation of the resulting code-equivalent tree (before the later session-test-only commit): formatter **59 files / 0 changes**, analyzer **No issues found**, **108 tests passed**, Linux debug build passed;
- a temporary formatter-probe workflow was used only to recover exact formatter bytes through GitHub, then removed completely before Ready;
- Draft CI #315 on head `703cc3f61f900d2699d370141c834d84a0785d96`: `dev-check` green, including localization generation, Drift generation/snapshot checks, formatter, and analyzer;
- Draft CI #317 on head `d44a1d37febb5b84ed1fc9ffa63ee6da693e2ed4`: `dev-check` green after the architecture/handoff reconciliation;
- full Ready CI #318 on the same head `d44a1d37febb5b84ed1fc9ffa63ee6da693e2ed4`: `quality` including the full test suite, Linux build, Android build, dependency review, and `merge-gate` all green;
- this checkpoint commit is documentation-only and therefore changes the PR head after #318. The full Ready CI must still validate the final documentation head before merge approval is requested.

## Next work after PR #20

Do not automatically expose `>` merely because Collections now exist.

A method-faithful next slice should stay small and deliberate. Likely choices are:

1. expose deliberate Collection references from chronological entries while preserving original ownership; or
2. design the explicit destination-selection flow required to migrate an open Task into a real Collection using the existing lineage semantics; or
3. separately expose next-Monthly accessibility if that produces a clearer method-native migration path.

Index remains a distinct deliberate journal structure and should not be bundled into migration simply because its schema already exists. Search, backup UI, exports, OS lock hooks, accessibility/keyboard work, and packaging remain later focused slices.

Any future cross-surface write into Collections must add retained-tab activation refresh coverage before merge.

## CI and handoff traps to remember

- Draft PR: only `dev-check` is expected; non-Draft jobs are intentionally skipped.
- Ready/non-Draft: `quality`, `linux-build`, `android-build`, `dependency-review`; `merge-gate` requires them.
- A red formatter after semantic work is not evidence of a production defect. Apply the pinned formatter output exactly.
- GitHub contents writes can accidentally lose a trailing newline; verify final formatter result/blob rather than repeatedly editing by eye.
- A temporary workflow probe must not remain in the final PR diff.
- `StatefulShellRoute.indexedStack` retains screens; section navigation is not a remount lifecycle.
- Manual product tests remain important for cross-screen freshness, persistence behavior, and false-success/false-error UI that isolated repository tests cannot expose.
