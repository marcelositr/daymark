# Daymark project checkpoint

This is Daymark's canonical living handoff. Read this file and `AGENTS.md` before meaningful work. Update it before handing work off. The repository, not a chat transcript, is the project memory.

## Current state

- Phase: pre-alpha, core Bullet Journal flows are implemented and the project is in the vacation-ready stabilization cycle.
- Integration branch: `main` only.
- Current merged `main`: `e4659c14e84759150060e4f834a1a2fc50b20910`, squash merge of PR #28 `feat(backup): add user-facing encrypted backup restore`.
- PR #28 exact Ready head: `a7fd2dfd5b408b0285ac88a7bf610041cf8c299d`.
- PR #28 Ready CI #464 passed `quality`, Linux build, Android build, dependency review, and `merge-gate` on that exact head.
- Post-merge `main` CI #465 started on exact merged SHA `e4659c14e84759150060e4f834a1a2fc50b20910`; its final result was still pending at this documentation checkpoint.
- User-facing encrypted backup/restore is now merged into `main` and passed real disposable Linux backup/restore validation before merge.
- Next planned product slice: **Open Export**.
- Runtime targets: Linux and Android.
- Pinned toolchain: Flutter 3.47.2 / Dart 3.13.2.
- Primary local validation host details: `docs/LOCAL_ENVIRONMENT.md`.
- Local terminal execution contract: `docs/LOCAL_EXECUTION.md`.
- Local performance benchmark protocol and baseline: `docs/PERFORMANCE_BENCHMARK.md`.
- Merge policy: never merge without explicit user approval; squash merge is the default.
- Production Argon2id baseline: 19 MiB / 2 iterations / p=1 / 32-byte output.
- Stabilization target: have a vacation-ready prerelease completed no later than 2026-09-06, preferably by 2026-09-05, without weakening architecture, security, persistence, tests, or merge protection.
- Last updated: 2026-09-04 (America/Sao_Paulo).

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
- When local execution is faster or GitHub Actions/API evidence is degraded, the user may act as an execution bridge using complete agent-provided command blocks.
- Local execution does not transfer debugging responsibility to the user. The agent interprets failures and decides the next safe step.
- Local-first validation may replace routine Draft-CI iteration, but it never weakens the final Ready PR merge gate.
- Use the pinned formatter early. If ARB resources changed, run `flutter gen-l10n` before formatter/analyzer/tests that compile localization-dependent code.
- Keep `PROJECT.md` current and `CHANGELOG.md` release-facing.
- Treat formatter output from the pinned Dart version as authoritative.
- Treat CI evidence as SHA-specific. A green superseded run does not validate a newer head.
- Distinguish mechanical CI/test-harness failures from product defects before changing behavior.
- Never weaken security, persistence invariants, tests, or CI merely to make a check green.
- Remove temporary workflow probes/scripts before Ready.
- User shell blocks must follow `docs/LOCAL_EXECUTION.md`.
- Do not invent fake product destinations or temporary domain concepts to unblock UI.
- Do not duplicate repository/service semantics inside widgets/providers.

## Local-first stabilization loop

For each substantive branch unless the change is too small to justify every step:

1. start from exact current `main` and create one short-lived branch with one coherent responsibility;
2. implement and add/update focused tests at the correct layer;
3. if localization changed, run `flutter gen-l10n` first;
4. run the pinned Dart formatter immediately and incorporate its exact output before expensive validation;
5. run analyzer and focused tests;
6. when the slice appears correct, run the complete Flutter suite and the locally relevant native build(s);
7. run the real manual user flow when persistence, lifecycle, navigation, rendering, import/export, backup/restore, or platform behavior is involved;
8. diagnose surprising results before changing production behavior;
9. align documentation on the final branch head;
10. use GitHub full Ready CI once the branch is reviewable;
11. merge only after the exact final head is green and the user explicitly approves squash merge.

If GitHub Actions or the API is slow, delayed, or incomplete, continue independent local/product work that does not depend on the missing evidence. `gh` is available on the local validation host as a fallback for GitHub status inspection. Never infer a green result.

## Local performance rule

Normal development should preserve warm incremental state. Do not use `flutter clean` as routine hygiene.

A controlled benchmark is a separate diagnostic workflow defined in `docs/PERFORMANCE_BENCHMARK.md`. The 2026-09-04 baseline showed:

- full Flutter suite: 54.99 s;
- Linux debug rebuild: 9.37 s;
- Linux warm incremental: 4.30 s;
- Android debug rebuild: 140.96 s;
- Android warm incremental: 31.71 s.

The Android rebuild already reached roughly 390% sampled CPU on the four-core local host and pushed the machine into about 0.94 GiB of swap. Therefore future Gradle caching, parallelism, or heap tuning must be A/B measured rather than enabled by assumption.

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
- Task states are open/completed/migrated/scheduled/discarded.
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
- Historical Monthly and Daily lookups are non-mutating.
- Cross-table semantic writes remain transactional through repository/service boundaries.
- `JournalSession` serializes unlocked journal work and owns encrypted persistence/key lifetime.

## Security / backup baseline

The current security contract lives in `SECURITY.md`; `docs/SECURITY_FOUNDATION.md` is the historical PR #7 validation record. Backup-format details live in `docs/BACKUP_FORMAT.md`, with architecture boundaries in `docs/ARCHITECTURE.md`.

Current foundation includes:

- SQLite3MultipleCiphers ChaCha20-Poly1305 encrypted persistence;
- random 48-byte SQLite material: 32-byte journal key + 16-byte cipher salt;
- master password never used directly as the SQLite key and never persisted;
- Argon2id-derived KEK + XChaCha20-Poly1305 versioned key envelope;
- explicit mutable key-material destruction where practical;
- Android OS backup/device-transfer exclusion;
- portable authenticated encrypted backup with integrity and rollback/recovery protections.

## Merged product baseline

- PR #13: encrypted create/unlock/manual-lock flow plus functional Today/Daily Rapid Logging.
- PR #14: automatic five-minute inactivity lock. Squash `d93563184c01ef406398619212410c540d00712a`.
- PR #15: deliberate Task completion/discard. Squash `b3af861dc00b81402d27cbdec39e3c99212c6590`.
- PR #16: current-month Monthly Log. Squash `c93b78380f0efdd545d533db49b30ab2f907426b`.
- PR #17: rolling six-month Future Log. Squash `8a9a74bb5158159818822487e71fcc220a0acbf8`.
- PR #18: deliberate scheduling (`<`) into Future. Squash `03ef4d187845ff13128f28298336b540b3237e9e`.
- PR #20: basic Collections. Squash `08199af85df7d10ba36b226d97b390da3acffbb9`.
- PR #21: deliberate Task migration (`>`) into an existing Collection. Squash `89c1907d17d0507fd84c403c7343afc2ccbbd8da`.
- PR #22: read-only Collection references. Squash `23fbc3e0b8d3e62f8db8ddc1ad403835e8fc5eee`.
- PR #23: basic deliberate Index. Squash `1a05c1cd71c2f442a538d21b2263ed39ed09efbe`.
- PR #24: read-only historical Monthly browsing. Squash `04daa185a6db3cc2a8588ab71a1327a91f893639`.
- PR #25: basic local Search. Squash `6a7fa2e0167099f0b975f5479ab12ef37a1883c7`.
- PR #26: read-only Daily history. Squash `ab6b194e155cc225b4dc4ee1f82e202565eaeac2`.
- PR #27: local-first stabilization handoff alignment. Squash `b6d8ed5904d5e587cec91ed597b297b2c75672b5`.
- PR #28: user-facing encrypted backup/restore. Squash `e4659c14e84759150060e4f834a1a2fc50b20910`.

### PR #28 backup/restore checkpoint

Implemented behavior:

- unlocked journals can create a portable authenticated encrypted Daymark backup after master-password verification;
- Linux save-file flow copies the encrypted container without buffering the full file;
- Android uses the platform file-picker/document-provider boundary;
- restore is exposed only when the journal is locked or absent, never over a live encrypted database session;
- restore validates authentication, compatibility, database integrity, foreign keys, and staged files before replacement;
- wrong password or failed restore leaves the existing journal locked and unchanged;
- successful restore reopens only from the committed database/key-envelope pair;
- interrupted restore recovery runs before normal locked-journal inspection;
- backup/restore errors are localized and raw crypto/filesystem errors are not shown to the user;
- `file_picker` is pinned to `12.1.3` for compatibility with the current AGP 9 / Gradle 9 toolchain.

Validation evidence:

- formatter, analyzer, focused backup/restore tests, complete Flutter suite, Linux debug build, and Android debug build passed locally;
- manual Linux restore used an isolated disposable XDG root;
- the manual flow proved snapshot rollback semantics, wrong-password rejection, auto-unlock after correct restore, and restored-state persistence across a second launch;
- Ready CI #464 passed on exact head `a7fd2dfd5b408b0285ac88a7bf610041cf8c299d` including `merge-gate`;
- squash merge produced `main` SHA `e4659c14e84759150060e4f834a1a2fc50b20910`.

## Next product slice: Open Export

Open Export is the next P0 stabilization slice.

Expected boundary:

- explicit user action only;
- structured JSON for machine-readable portability;
- Markdown for human-readable archival use;
- clear warning that exported files are plaintext and no longer protected by Daymark's encrypted journal storage;
- technically and conceptually separate from encrypted backup;
- deterministic/versioned output where appropriate;
- preserve stable IDs, owners, states, and relationships needed for meaningful portability;
- tests for escaping, Unicode, states, and relationships;
- no cloud/sync semantics and no hidden automatic export.

## Vacation-ready stabilization plan

Priority order:

1. **User-facing encrypted backup/restore**: merged in PR #28.
2. **Open export**: next active product slice.
3. **Appearance selection**: expose System / Light / Dark without turning settings into a configuration surface.
4. **Release hardening**: packaging/versioning, Android release signing setup, Linux and Android release builds, installation/upgrade smoke tests, dependency/security review, documentation alignment, and final controlled recovery validation.
5. **Final stabilization only**: after the above closes, fix blockers and regressions; do not add unrelated features merely because time remains.

Explicitly deferrable when they threaten stability or the date boundary:

- direct source navigation from Search/Index;
- richer Reflection workflows;
- OS-level immediate lock hooks;
- device-assisted/biometric unlock;
- accessibility/keyboard refinement beyond release-blocking defects;
- cloud/sync or other out-of-scope product expansion.

## CI and handoff traps

- Local-first is the preferred development feedback loop when it is faster or GitHub is degraded.
- Draft PRs may run `dev-check`; repeated remote Draft iterations are not required when equivalent pinned local checks are available and recorded.
- Ready PRs still require quality/full tests, Linux, Android, dependency review, and `merge-gate` on the exact final head.
- A red formatter is mechanical evidence, not automatically a product defect.
- Commits created by `github-actions[bot]` may show `action_required`; do not treat that status alone as code failure.
- Temporary workflow probes must not remain in the final PR diff.
- `StatefulShellRoute.indexedStack` retains screens; section navigation is not a remount lifecycle.
- Manual product testing remains important for lifecycle freshness, compact/desktop navigation, persistence, backup/restore, import/export, and false-success/false-error UI behavior.
- If GitHub Actions/API results are delayed or incomplete, do not infer success. Continue independent work where safe, then request only the smallest missing evidence when a merge decision is blocked.
