# Daymark project checkpoint

This is Daymark's canonical living handoff. Read this file and `AGENTS.md` before meaningful work. Update it before handing work off. The repository, not a chat transcript, is the project memory.

## Current state

- Phase: pre-alpha, core Bullet Journal flows in active development.
- Integration branch: `main` only.
- Current merged `main`: `6a7fa2e0167099f0b975f5479ab12ef37a1883c7` (`feat(journal): add basic local search (#25)`).
- Post-merge main CI #439 is green on that exact SHA, including quality/tests, Linux, and Android.
- Active branch/PR: `feat/daily-history` / PR #26, `feat(journal): browse Daily history`.
- PR #26 remains Draft until exact-head Draft CI, complete-suite validation, and manual Linux validation are complete.
- Runtime targets: Linux and Android.
- Pinned toolchain: Flutter 3.47.2 / Dart 3.13.2.
- Merge policy: never merge without explicit user approval; squash merge is the default.
- Production Argon2id baseline: 19 MiB / 2 iterations / p=1 / 32-byte output.
- Last updated: 2026-09-03 (America/Sao_Paulo).

## Product doctrine

Daymark is a faithful digital Bullet Journal, not a generic productivity suite.

- local-first and offline-first;
- digital minimalism and low distraction;
- no feeds, ads, streaks, XP, productivity scoring, gamification, or attention-seeking UI;
- no automatic choices that replace deliberate reflection;
- no generic planner/Kanban/workspace abstractions merely because digital software can support them;
- English is canonical/fallback; exact `pt_BR` is the first additional locale;
- primary navigation concepts are Today, Monthly, Future, Collections, Search, and Index; compact layouts group Search/Index behind More without merging their meaning.

## Mandatory working rules

- `main` is the only permanent integration branch. Use short-lived branches and PRs.
- PR titles use Conventional Commit form.
- The user makes every merge decision. Never enable auto-merge or merge implicitly.
- Repository/API/CI work is assistant-owned. Do not use the user as a routine CI, formatter, or test runner.
- Ask the user to run locally only when genuine product/platform behavior needs manual validation.
- Keep `PROJECT.md` current and `CHANGELOG.md` release-facing.
- Run `flutter gen-l10n` after ARB changes.
- Treat formatter output from the pinned Dart version as authoritative.
- Treat CI evidence as SHA-specific. A green superseded run does not validate a newer head.
- Distinguish mechanical CI/test-harness failures from product defects before changing behavior.
- Never weaken security, persistence invariants, tests, or CI merely to make a check green.
- Remove temporary workflow probes/scripts before Ready.
- User shell blocks must be safe for an interactive shell and must not end with a bare `exit`.
- Do not invent fake product destinations or temporary domain concepts to unblock UI.
- Do not duplicate repository/service semantics inside widgets/providers.

## Critical retained-navigation lifecycle rule

The router uses `StatefulShellRoute.indexedStack`, so top-level sections remain mounted while inactive.

Therefore:

- returning to a section does not imply another `initState()`;
- a retained screen whose data can become stale because of work elsewhere must refresh when it becomes active;
- `AppSectionScope` is the current presentation-level activation signal;
- do not solve freshness by destroying all tabs, polling continuously, or adding an unrelated global cache.

This rule currently applies to Future after scheduling, Collections after migration/references, and Search after source Task-state changes.

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

Durable rules:

- Task, Event, and Note are distinct entry types.
- Task states are open, completed, migrated, scheduled, and discarded.
- Events and Notes do not acquire Task state.
- Every Entry has exactly one owning placement.
- Daily belongs to one method date; historical Daily lookup is non-creating and read-only in the current product.
- Monthly Calendar/Tasks placement and date invariants are enforced; historical Monthly lookup is non-creating/read-only.
- Future is month-addressed, not a second day-level calendar.
- A Collection is a simple method-native owning container, not a configurable workspace.
- Collection references do not move the source Entry and remain distinct from migration.
- Scheduling (`<`) targets Future.
- Forward migration (`>`) currently targets an explicitly selected existing Collection.
- Movement preserves the historical source and creates a fresh destination Entry plus lineage; do not move ownership in place.
- Index deliberately catalogs an existing Log or Collection and never duplicates Entry content.
- Search is transient read-only retrieval over existing Entries and is never an owner or persistent Index source.
- Cross-table semantic writes remain transactional through repository/service boundaries.
- `JournalSession` serializes unlocked journal work and owns encrypted persistence/key lifetime.

## Security / backup baseline

Do not casually modify these contracts. Authoritative details live in `SECURITY.md`, `docs/SECURITY_FOUNDATION.md`, `docs/BACKUP_FORMAT.md`, and `docs/ARCHITECTURE.md`.

Current foundation includes:

- SQLite3MultipleCiphers ChaCha20-Poly1305 encrypted persistence;
- random 48-byte SQLite material: 32-byte journal key + 16-byte cipher salt;
- master password never used directly as the SQLite key and never persisted;
- Argon2id-derived KEK + XChaCha20-Poly1305 versioned key envelope;
- explicit mutable key-material destruction where practical;
- Android OS backup/device-transfer exclusion;
- portable authenticated encrypted backup with integrity and rollback/recovery protections.

PRs #20 through #26 do not change schema version, crypto, key lifecycle, backup format, dependency set, or platform contracts.

## Recent merged baseline

### PR #23

Basic deliberate Index of existing Logs and Collections. Squash: `1a05c1cd71c2f442a538d21b2263ed39ed09efbe`.

### PR #24

Read-only historical Monthly browsing. Squash: `04daa185a6db3cc2a8588ab71a1327a91f893639`.

### PR #25

Basic local read-only Search. Squash: `6a7fa2e0167099f0b975f5479ab12ef37a1883c7`.

- searches existing Entry content without FTS/schema v2;
- reports real Daily/Monthly/Future/Collection context;
- Unicode-aware case-insensitive matching keeps accents literal;
- retained Search refresh cannot overwrite a newer explicit query;
- 8 focused Search tests and 140 complete-suite tests passed before merge;
- manual Linux validation passed;
- Ready CI #438 green;
- post-merge main CI #439 green.

## Active PR #26: read-only Daily history

Branch: `feat/daily-history`.

PR: #26, `feat(journal): browse Daily history`.

Implemented scope:

- Today remains the interactive current Daily Log;
- Today gains a History action that opens yesterday;
- real `/daily/:date` route represents a historical Daily method date;
- historical screen browses backward/forward among past dates but never forward into Today;
- historical Daily display is read-only: no composer, complete/discard, migrate, schedule, reference, or other mutation actions;
- missing historical date stays absent and shows a quiet empty state;
- `DailyLogRepository.find(...)` is non-creating;
- `JournalDailyHistorySession.findDailyLog(...)` serializes historical lookup through the unlocked session;
- viewing an absent historical day must not create a Log or Index candidate;
- existing historical Task/Event/Note symbols and discarded strike-through remain visible;
- EN, `pt`, and `pt_BR` copy added;
- no schema/crypto/backup/dependency/platform-contract change.

Validation lineage:

- focused finalizer applied the Today launcher with exact markers and pinned Dart formatting;
- first analyzer pass found one test-only `isNotNull` import collision between Drift and matcher;
- import was disambiguated without changing product behavior;
- finalizer rerun passed analyzer and all focused Daily-history tests, then removed its temporary workflow/trigger;
- README, PRODUCT, DOMAIN, ARCHITECTURE, and CHANGELOG are aligned with the implemented Daily-history behavior;
- temporary documentation helper was removed; no helper should remain in the final PR diff;
- exact-head Draft CI and complete-suite validation remain before manual Linux validation.

Explicit non-goals:

- no direct Index/Search navigation in PR #26;
- no historical editing or reflection workflow;
- no generic date picker/calendar workspace;
- no schema or FTS changes.

## Next work after PR #26

Keep subsequent slices separate. Strong candidates:

1. direct navigation from Index/Search into real existing structures/entries, now using genuine Daily historical routes rather than fake current-screen substitutions;
2. focused Reflection behavior after its method semantics are deliberately specified;
3. backup/restore UI and explicit open export flows;
4. OS lock integration, keyboard/accessibility refinements, Android/Linux polish, packaging, and final release audits.

Do not bundle Search into Index. Do not turn retrieval into another owning workspace. Do not create a Log merely to make a navigation target exist.

## CI and handoff traps

- Draft PRs run `dev-check`; Ready PRs run quality/full tests, Linux, Android, dependency review, and `merge-gate`.
- A red formatter is mechanical evidence, not automatically a product defect.
- Commits created by `github-actions[bot]` may show `action_required`; use a useful normal commit for exact-head evidence rather than treating that status as code failure.
- Temporary workflow probes must not remain in the final PR diff.
- `StatefulShellRoute.indexedStack` retains screens; section navigation is not a remount lifecycle.
- Manual product testing remains important for lifecycle freshness, navigation, persistence, and false-success/false-error UI behavior.
