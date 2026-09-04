# Daymark project checkpoint

This is Daymark's canonical living handoff. Read this file and `AGENTS.md` before meaningful work. Update it before handing work off. The repository, not a chat transcript, is the project memory.

## Current state

- Phase: pre-alpha, core Bullet Journal flows are implemented and the project is entering a focused vacation-ready stabilization cycle.
- Integration branch: `main` only.
- Current merged `main`: `ab6b194e155cc225b4dc4ee1f82e202565eaeac2` (`feat(journal): browse Daily history (#26)`).
- PR #26 full Ready CI #455 is green on final head `ab155f3a3439346be009a4224b1e5b1864f897d7`.
- Post-merge `main` CI #456 is green on exact merged SHA `ab6b194e155cc225b4dc4ee1f82e202565eaeac2`.
- Active branch: `docs/local-first-release-handoff`, created from that exact `main` SHA to synchronize repository handoff/workflow documentation before the next product slice.
- No product PR is active while this documentation alignment is in progress.
- Runtime targets: Linux and Android.
- Pinned toolchain: Flutter 3.47.2 / Dart 3.13.2.
- Merge policy: never merge without explicit user approval; squash merge is the default.
- Production Argon2id baseline: 19 MiB / 2 iterations / p=1 / 32-byte output.
- Stabilization target: have a vacation-ready prerelease completed no later than 2026-09-06, preferably by 2026-09-05, without weakening architecture, security, persistence, tests, or merge protection.
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
- The agent owns implementation design, Git/GitHub operations available through connected tooling, test design, command construction, and diagnosis of returned evidence.
- When local execution is faster or GitHub Actions/API evidence is degraded, the user may act as an execution bridge for formatter, analyzer, tests, builds, and manual product checks using complete agent-provided command blocks.
- Local execution does not transfer debugging responsibility to the user. The agent interprets failures and decides the next safe step.
- Local-first validation may replace routine Draft-CI iteration, but it does not weaken the final repository merge gate. The live `main` ruleset still requires the exact `merge-gate` status before merge.
- Use the pinned local Dart formatter early, before spending time on expensive tests. If ARB resources changed, run `flutter gen-l10n` before formatter/analyzer/tests that compile localization-dependent code.
- Keep `PROJECT.md` current and `CHANGELOG.md` release-facing.
- Treat formatter output from the pinned Dart version as authoritative.
- Treat CI evidence as SHA-specific. A green superseded run does not validate a newer head.
- Distinguish mechanical CI/test-harness failures from product defects before changing behavior.
- Never weaken security, persistence invariants, tests, or CI merely to make a check green.
- Remove temporary workflow probes/scripts before Ready.
- User shell blocks must be safe for an interactive shell and must not end with a bare `exit`.
- Do not invent fake product destinations or temporary domain concepts to unblock UI.
- Do not duplicate repository/service semantics inside widgets/providers.

## Local-first stabilization loop

During the current stabilization cycle, use this default sequence for each substantive branch unless the change is too small to justify every step:

1. start from exact current `main` and create one short-lived branch with one coherent responsibility;
2. implement and add/update focused tests at the correct layer;
3. if localization changed, run `flutter gen-l10n` first;
4. run the pinned Dart formatter immediately and incorporate its exact output before expensive validation;
5. run analyzer and focused tests;
6. when the slice appears correct, run the complete Flutter suite and the locally available native build(s);
7. run the real manual user flow when persistence, lifecycle, navigation, rendering, import/export, backup/restore, or platform behavior is involved;
8. if any result is surprising, diagnose before changing production behavior and repeat the proportionate local checks;
9. align documentation on the final branch head;
10. use GitHub full Ready CI once the branch is reviewable, treating it as final independent merge evidence rather than the routine development runner;
11. merge only after the exact final head is green and the user explicitly approves squash merge.

If GitHub Actions or the API is slow, delayed, or incomplete, continue independent local/product work that does not depend on the missing evidence. When the missing fact blocks merge, ask the user only for the smallest concrete CI/job reference needed. Never infer a green result.

## Critical retained-navigation lifecycle rule

The router uses `StatefulShellRoute.indexedStack`, so top-level sections remain mounted while inactive.

Therefore:

- returning to a section does not imply another `initState()`;
- a retained screen whose data can become stale because of work elsewhere must refresh when it becomes active;
- `AppSectionScope` is the current presentation-level activation signal;
- do not solve freshness by destroying all tabs, polling continuously, or adding an unrelated global cache.

This rule first mattered for Future after scheduling, then Collections after migration/references, and Search reruns the last submitted query on reactivation. Any future cross-surface write must preserve the same immediate-freshness rule.

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
- Monthly Calendar/Tasks placement and date invariants are enforced.
- Future is month-addressed, not a second day-level calendar.
- A Collection is a simple method-native owning container, not a configurable workspace.
- Collection references do not move the source Entry and remain distinct from migration.
- Scheduling (`<`) targets Future.
- Forward migration (`>`) currently targets an explicitly selected existing Collection.
- Movement preserves the historical source and creates a fresh destination Entry plus lineage; do not move ownership in place.
- Index deliberately catalogs an existing Log or Collection and never duplicates Entry content.
- Search is transient read-only retrieval over existing Entries and is never an owner or persistent Index source.
- Historical Monthly lookup is non-mutating; viewing a missing past month must not create a Log or Index candidate.
- Historical Daily lookup is non-mutating; viewing a missing past day must not create a Log or Index candidate.
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

## Merged product baseline

### PR #13

Encrypted create/unlock/manual-lock flow and functional Today/Daily Log with Rapid Logging Task/Event/Note, serialized session, persistence, and day rollover.

### PR #14

Automatic five-minute inactivity lock. Squash: `d93563184c01ef406398619212410c540d00712a`.

### PR #15

Deliberate Task completion/discard. Squash: `b3af861dc00b81402d27cbdec39e3c99212c6590`.

Task symbols established: open `•`, completed `×`, migrated `>`, scheduled `<`, discarded historical `•` with strike-through.

### PR #16

Current-month Monthly Log with Calendar and Tasks. Squash: `c93b78380f0efdd545d533db49b30ab2f907426b`.

### PR #17

Rolling six-month Future Log. Squash: `8a9a74bb5158159818822487e71fcc220a0acbf8`.

### PR #18

Deliberate scheduling (`<`) from Today/Monthly into real Future months. Squash: `03ef4d187845ff13128f28298336b540b3237e9e`.

Important method decision: Today -> current Monthly is not a valid shortcut for `>`.

### PR #20

Basic Collections. Squash: `08199af85df7d10ba36b226d97b390da3acffbb9`.

### PR #21

Deliberate Task migration (`>`) from Today/Monthly into an explicitly selected existing Collection. Squash: `89c1907d17d0507fd84c403c7343afc2ccbbd8da`.

### PR #22

Deliberate read-only Collection references from chronological entries. Squash: `23fbc3e0b8d3e62f8db8ddc1ad403835e8fc5eee`.

### PR #23

Basic deliberate Index of existing Logs and Collections. Squash: `1a05c1cd71c2f442a538d21b2263ed39ed09efbe`.

### PR #24

Read-only historical Monthly browsing. Squash: `04daa185a6db3cc2a8588ab71a1327a91f893639`.

### PR #25

Basic local Search. Squash: `6a7fa2e0167099f0b975f5479ab12ef37a1883c7`.

- explicit user-submitted read-only queries;
- Unicode-aware case-insensitive literal substring matching with literal accents;
- result context for Daily, Monthly, Future, and Collection owners;
- no FTS/schema change, Search cache, persisted query history, or Search-to-Index side effect;
- retained Search refreshes the last submitted query on reactivation without letting an older refresh overwrite a newer query;
- manual Linux validation passed;
- Ready CI #438 green;
- post-merge main CI #439 green.

### PR #26

Read-only Daily history. Squash: `ab6b194e155cc225b4dc4ee1f82e202565eaeac2`.

Implemented scope:

- real `/daily/:date` historical route inside the Today branch;
- History action from Today opens yesterday;
- historical days can be browsed backward and forward while never advancing into Today;
- Today remains the current interactive Rapid Logging surface;
- historical Daily Logs are read-only and expose no capture, Task, migration, scheduling, reference, completion, or discard actions;
- missing historical days render a quiet empty state and do not create a Daily Log;
- `DailyLogRepository.find(...)` is non-creating and exposed through serialized `JournalDailyHistorySession` work;
- viewing a missing historical day does not create an Index candidate;
- existing Entry symbols and discarded strike-through remain visible in history;
- EN, `pt`, and `pt_BR` copy added;
- no schema, crypto, backup-format, dependency, or platform-contract change.

Validation:

- focused Daily-history validation and complete Daymark suite passed during development;
- manual Linux validation passed on the final implementation/documentation line;
- full Ready CI #455 green on final PR head `ab155f3a3439346be009a4224b1e5b1864f897d7`;
- squash merge produced `main` SHA `ab6b194e155cc225b4dc4ee1f82e202565eaeac2`;
- post-merge `main` CI #456 green on that exact SHA.

## Vacation-ready stabilization plan

The goal is not to rush to a nominal stable `1.0.0`. The goal is a trustworthy end-to-end prerelease that can be used intensively during the user's vacation, with September 6 as the final safety boundary and September 5 preferred if the required work closes cleanly.

Priority order:

1. **User-facing encrypted backup/restore**: connect the already-tested encrypted backup/restore service to the existing session lifecycle and explicit file-selection UX without changing the backup format or cryptographic design.
2. **Open export**: provide explicit human-readable/non-proprietary export, expected to cover structured JSON plus Markdown, with clear plaintext-boundary messaging and no confusion with encrypted backup.
3. **Appearance selection**: expose the already-supported System / Light / Dark choice without turning settings into a configuration surface.
4. **Release hardening**: packaging/versioning, Android release signing setup, Linux and Android release builds, installation/upgrade smoke tests, dependency/security review, documentation alignment, and a complete real backup/restore test on disposable/controlled data before relying on the prerelease for daily use.
5. **Final stabilization only**: after the above closes, fix blockers and regressions. Do not add unrelated features simply because time remains.

Explicitly deferrable when they threaten stability or the date boundary:

- direct source navigation from Search/Index;
- richer Reflection workflows;
- OS-level immediate lock hooks;
- device-assisted/biometric unlock;
- accessibility/keyboard refinement beyond release-blocking defects;
- cloud/sync or other out-of-scope product expansion.

A feature is not entitled to ship merely because it appeared on an older roadmap. For the current stabilization cycle it must materially improve safe daily use, portability, recovery, or release readiness without creating disproportionate risk.

## CI and handoff traps

- Local-first is the preferred development feedback loop during the current stabilization cycle when it is faster or GitHub is degraded.
- Draft PRs may still run `dev-check`, but repeated remote Draft iterations are not required when equivalent pinned local checks are available and recorded.
- Ready PRs still require quality/full tests, Linux, Android, dependency review, and `merge-gate` on the exact final head because the live ruleset requires `merge-gate`.
- A red formatter is mechanical evidence, not automatically a product defect. Apply the pinned Dart formatter early rather than guessing reflow.
- Commits created by `github-actions[bot]` may show `action_required`; use a useful normal commit for exact-head evidence rather than treating that status as code failure.
- Temporary workflow probes must not remain in the final PR diff.
- `StatefulShellRoute.indexedStack` retains screens; section navigation is not a remount lifecycle.
- Manual product testing remains important for lifecycle freshness, compact/desktop navigation, persistence, backup/restore, import/export, and false-success/false-error UI behavior.
- If GitHub Actions/API results are delayed or incomplete, do not infer success. Continue independent work where safe, then request only the smallest missing evidence when a merge decision is blocked.
