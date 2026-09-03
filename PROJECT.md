# Daymark project checkpoint

This is Daymark's canonical living handoff. Read this file and `AGENTS.md` before meaningful work. Update this file before handing work off. The repository, not a chat transcript, is the project memory.

## Current state

- Phase: pre-alpha, core Bullet Journal flows in active development.
- Integration branch: `main` only.
- Current `main` head before the active feature PR: `1a05c1cd71c2f442a538d21b2263ed39ed09efbe` (`feat(journal): add basic index (#23)`).
- Current merged product baseline: PR #23, basic deliberate Index, squash-merged as `1a05c1cd71c2f442a538d21b2263ed39ed09efbe`.
- Active branch/PR: `feat/monthly-history` / PR #24, `feat(journal): browse monthly history`.
- PR #24 is Draft while final documentation and exact-head validation are completed.
- Current merged product scope includes Today, current Monthly, six-month Future, basic Collections, deliberate Task terminal actions, scheduling (`<`), forward migration (`>`) into Collections, deliberate Collection references, and a basic persisted Index.
- PR #24 adds read-only historical Monthly browsing without creating empty historical Logs merely by navigating.
- Manual Linux validation of PR #24 passed on code head `a5d22f3602332f66db40b9a8c0e85c52282c4a88`.
- Draft CI #391 on that same code head is green, including localization generation, Drift generation/snapshot checks, formatter, and analyzer.
- Documentation-only commits follow that validated code head. The final documented head must receive exact-head Draft CI before Ready.
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
- primary navigation concepts: Today, Monthly, Future, Collections, Search, Index; compact layouts group Search/Index under More without merging their meaning.

## Mandatory working rules

- `main` is the only permanent integration branch. Use short-lived branches and PRs.
- Squash merge is the default merge strategy.
- PR titles use Conventional Commit form.
- The user makes the merge decision. Never enable auto-merge or merge implicitly.
- Read and obey `AGENTS.md`, `docs/WORKFLOW.md`, architecture/domain/security docs before changing their areas.
- Keep `PROJECT.md` current. Keep `CHANGELOG.md` release-facing rather than using it as scratchpad.
- Run `flutter gen-l10n` after ARB changes and before analyzer/tests that compile presentation code.
- Treat formatter output from the pinned Dart version as authoritative.
- Treat CI evidence as SHA-specific. A green superseded run does not validate a newer head.
- Distinguish mechanical CI failures and test-harness defects from production defects before changing behavior.
- Never weaken security, persistence invariants, tests, or CI to make a check green.
- Remove temporary probe workflows/diagnostic scaffolding before Ready.
- User terminal blocks must be safe for an interactive shell: no bare final `exit`, no accidental shell termination, exact branch/head checks when relevant.
- Do not use the user as a routine CI/formatter runner when repository tooling can perform the work. Ask for local execution only when local hardware/product behavior genuinely matters.
- Do not invent fake product destinations or temporary domain concepts merely to unblock UI.
- Do not reimplement repository/service semantics inside widgets or providers.
- Repository/API/CI work is assistant-owned. User interaction is reserved for genuine manual product/platform validation or explicit product/merge decisions.

## Critical UI lifecycle guardrail

The router uses `StatefulShellRoute.indexedStack`. Top-level sections are intentionally retained while another section is active.

Therefore:

- do not assume `initState()` runs again when a user returns to a retained tab;
- a screen that displays data which can be changed from another retained section must refresh that stale snapshot when its section becomes active again;
- do not fix this by destroying every tab, polling the database, or adding an unrelated global cache;
- `AppSectionScope` is the current presentation-level activation signal for retained top-level sections.

This rule originated from PR #18, where Future persistence was correct but the retained Future screen stayed stale after scheduling. PR #21/22 applied the same rule to Collections after migration/reference writes.

## Stable domain and persistence baseline

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
- Deliberate movement creates a new destination Entry plus lineage; do not move the source placement in place.
- The historical source remains visible with terminal state; a movement destination Task begins open.
- One source Entry has at most one direct outgoing movement lineage.
- Cross-table semantic writes stay transactional through `JournalRepository` / `JournalService`.
- `JournalSession` serializes unlocked journal operations and owns encrypted persistence/key lifetime.
- Indexing catalogs an existing Log or Collection. It does not duplicate Entry content or create the target.
- Historical Monthly lookup is non-mutating. Viewing a missing past month must not create a Log or make it an Index candidate.

## Security / backup baseline

Do not casually modify these contracts. Authoritative details live in `SECURITY.md`, `docs/SECURITY_FOUNDATION.md`, `docs/BACKUP_FORMAT.md`, and `docs/ARCHITECTURE.md`.

Current foundation includes:

- SQLite3MultipleCiphers ChaCha20-Poly1305 encrypted persistence;
- random 48-byte SQLite material: 32-byte key + 16-byte cipher salt;
- master password never used directly as the SQLite key and never persisted;
- Argon2id-derived KEK + XChaCha20-Poly1305 external versioned key envelope;
- explicit mutable key-material destruction;
- Android OS backup/device-transfer exclusion;
- portable authenticated encrypted backup with integrity validation and recovery protections.

PRs #20 through #24 do not change database schema, crypto, key lifecycle, backup format, dependency set, or platform contracts.

## Merged product history that matters

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

### PR #17

Six-month Future Log. Squash-merged as `8a9a74bb5158159818822487e71fcc220a0acbf8`.

### PR #18

Deliberate scheduling (`<`) from Today/Monthly into real Future month buckets. Squash-merged as `03ef4d187845ff13128f28298336b540b3237e9e`.

Important decision: Today -> current Monthly is not a valid shortcut for `>`. Scheduling uses Future; normal forward migration needs a valid non-Future destination.

### PR #20

Basic Collections. Squash-merged as `08199af85df7d10ba36b226d97b390da3acffbb9`.

### PR #21

Deliberate Task migration (`>`) from Today/Monthly into an explicitly selected existing Collection. Squash-merged as `89c1907d17d0507fd84c403c7343afc2ccbbd8da`.

### PR #22

Deliberate read-only Collection references from chronological entries. Squash-merged as `23fbc3e0b8d3e62f8db8ddc1ad403835e8fc5eee`.

Validation: manual Linux passed; Draft CI #349 green; full Ready CI #350 green; post-merge main CI #351 green.

### PR #23

Basic deliberate Index of existing Logs and Collections. Squash-merged as `1a05c1cd71c2f442a538d21b2263ed39ed09efbe`.

Implemented behavior:

- persisted Index order follows deliberate add order;
- target must already exist;
- duplicate targets are rejected;
- Index does not duplicate content or alter ownership/Task state;
- compact navigation exposes Search/Index through More; desktop exposes both directly;
- Index remains distinct from Search.

Validation/merge:

- manual Linux desktop/compact navigation and persistence validation passed;
- final full Ready CI #382 green on the final content-equivalent head;
- explicit user approval received;
- post-merge main CI #383 green.

## Active PR #24: read-only Monthly history

Branch: `feat/monthly-history`.

PR: #24, `feat(journal): browse monthly history`.

Scope implemented:

- previous/next-month controls live inside the Monthly surface;
- navigation may go backward through historical months but never forward past the current month;
- current month remains fully interactive;
- historical months are read-only and hide capture plus Task/entry-action controls;
- missing historical months render empty without creating a persisted Monthly Log;
- historical lookup uses a focused non-mutating repository/session path;
- returning to the current month restores normal interactive behavior;
- current-month rollover tracking is suspended while the user is intentionally viewing history;
- English, `pt`, and `pt_BR` labels are included;
- repository/widget/encrypted-session tests cover history lookup, UI behavior, lock/unlock persistence, and the no-phantom-Index invariant;
- no schema, crypto, backup, dependency, or platform-contract change.

Explicit non-goals:

- no editing or Task actions in historical months;
- no reflection workflow;
- no future Monthly creation;
- no direct Index/Search route into arbitrary Monthly history yet;
- no Search implementation;
- no schema v2.

Validation lineage so far:

- initial Draft CI #384 reached formatter and exposed two formatter-only files;
- pinned Dart 3.13.2 formatter output was applied by a temporary workflow and that workflow removed immediately;
- Draft CI #388 then exposed three analyzer-only test maintenance issues: two existing Monthly data-source fakes needed the new `find()` method and a Drift matcher import needed `isNotNull` hidden;
- those test-only issues were corrected without changing product semantics;
- code head `a5d22f3602332f66db40b9a8c0e85c52282c4a88`: Draft CI #391 green;
- manual Linux validation on that code head passed historical navigation, read-only controls, no future-Monthly navigation, return to current month, lock/unlock, and normal current-month behavior;
- README, PRODUCT, CHANGELOG, and this checkpoint are documentation-only changes after the manually validated code head;
- final documented head still requires exact-head Draft CI, then Ready/full CI before any merge decision.

## Next work after PR #24

Keep the next slice separate from Monthly history. Strong candidates are:

1. Search as a real query-driven retrieval surface, still distinct from Index;
2. real direct navigation from Index rows to structures now that historical Monthly can be represented without mutating persistence;
3. focused reflection behavior, only after its method semantics are deliberately specified.

Do not bundle Search into Index. Do not add generic planner/history abstractions around Monthly.

Backup UI, exports, OS lock hooks, accessibility/keyboard refinements, and packaging remain later focused slices.

## CI and handoff traps to remember

- Draft PR: only `dev-check` is expected; non-Draft jobs are intentionally skipped.
- Ready/non-Draft: `quality`, `linux-build`, `android-build`, `dependency-review`; `merge-gate` requires them.
- A red formatter after semantic work is not evidence of a production defect. Apply the pinned formatter output exactly.
- GitHub contents writes can accidentally lose a trailing newline; verify final formatter result/blob rather than repeatedly editing by eye.
- A temporary workflow probe must not remain in the final PR diff.
- Commits created by `github-actions[bot]` may produce `action_required` instead of a normal CI run; generate a useful normal commit for exact-head evidence rather than treating that status as a code failure.
- `StatefulShellRoute.indexedStack` retains screens; section navigation is not a remount lifecycle.
- Manual product tests remain important for lifecycle, persistence behavior, compact/desktop navigation, and false-success/false-error UI that isolated repository tests cannot expose.
