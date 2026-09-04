# Daymark project checkpoint

This is Daymark's canonical living handoff. Read this file and `AGENTS.md` before meaningful work. The repository, not a chat transcript, is the project memory.

## Current state

- Phase: alpha development after the first controlled distributable prerelease.
- Integration branch: `main` only.
- Latest published release: `v1.0.0-alpha.2` / application version `1.0.0-alpha.2+2`.
- Published release source commit: `5c073c6bbbe298c15f975740a5499f2b9a0c98ba`, squash merge of PR #32 `build(release): prepare 1.0.0-alpha.2`.
- PR #32 exact Ready head: `ad3eff96d9b9459761d4bfcebb91dfbd560df95d`.
- PR #32 Ready CI #474 passed quality, Linux, Android, dependency review, and `merge-gate`; Draft-only `dev-check` was skipped as expected.
- Post-merge `main` CI #475 passed on exact release source SHA `5c073c6bbbe298c15f975740a5499f2b9a0c98ba`.
- Annotated tag `v1.0.0-alpha.2` points to that release source commit.
- GitHub Release `Daymark 1.0.0-alpha.2` is published as a prerelease with the final Linux archive, signed Android APK, and `SHA256SUMS`.
- Post-alpha.2 documentation audit merged via PR #33 as current `main` commit `76ef920d2c5d7ad56471b053d3446b530363c079`.
- Current `main` CI #477 passed on exact SHA `76ef920d2c5d7ad56471b053d3446b530363c079`.
- Next product slice selected: navigation and organization, to begin on `feat/navigation-and-organization` after this checkpoint alignment is merged.
- The completed `release/1.0.0-alpha.2` branch is retained as historical reference/backup and is not an active integration line.
- Runtime targets: Linux and Android.
- Pinned toolchain: Flutter 3.47.2 / Dart 3.13.2.
- Merge policy: never merge without explicit user approval; squash merge is the default.
- Production Argon2id baseline: 19 MiB / 2 iterations / p=1 / 32-byte output.
- Last release checkpoint: 2026-09-04 (America/Sao_Paulo).

A documentation-only commit after the release tag does not change the published release source. When exact source identity matters, use the release tag/commit above and verify current GitHub state separately rather than assuming this file's own commit is the application release commit.

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
- The user makes every merge and release-promotion decision. Never enable auto-merge or merge/publish implicitly.
- The agent owns implementation design, Git/GitHub operations available through connected tooling, test design, command construction, and diagnosis of returned evidence.
- When local execution is faster or GitHub Actions/API evidence is degraded, the user may act as an execution bridge using complete agent-provided command blocks.
- Local execution does not transfer debugging responsibility to the user. The agent interprets failures and decides the next safe step.
- Local-first validation may replace routine Draft-CI iteration, but it never weakens the final Ready PR merge gate.
- Treat formatter output from the pinned Dart version as authoritative.
- Treat CI evidence as SHA-specific. A green superseded run does not validate a newer head.
- Never weaken security, persistence invariants, tests, or CI merely to make a check green.
- Do not use `flutter clean` as routine hygiene; preserve incremental build state unless evidence requires a controlled clean rebuild.
- Keep `PROJECT.md` current and `CHANGELOG.md` release-facing.
- Remove temporary workflow probes/scripts before Ready.
- User shell blocks must follow `docs/LOCAL_EXECUTION.md`.

## Local-first engineering loop

For each substantive branch unless the change is too small to justify every step:

1. start from exact current `main` and create one short-lived branch with one coherent responsibility;
2. inspect existing code/tests and authoritative documentation before editing;
3. implement and add/update focused tests at the correct layer;
4. generate localization/Drift artifacts when applicable;
5. run the pinned formatter early;
6. run analyzer and focused tests;
7. run the complete Flutter suite and locally relevant native builds at meaningful checkpoints;
8. run the real manual flow for persistence, lifecycle, navigation, backup/restore, export, or platform behavior when those boundaries are affected;
9. diagnose surprising results before changing production behavior;
10. align documentation on the final branch head;
11. use full Ready CI once the branch is reviewable;
12. merge only after exact-head CI is green and the user explicitly approves squash merge.

If GitHub Actions or API evidence is delayed, continue independent work where safe. `gh` is available on the primary local validation host as a fallback. Never infer a green result.

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

- one encrypted Daymark database represents one journal;
- `journal_metadata` identifies that journal with exactly one singleton UUID-v7 row;
- new journals initialize that row and legacy prerelease journals with zero rows are repaired idempotently on unlock; more than one row fails closed as corruption;
- Task, Event, and Note are distinct entry types;
- Task states are open/completed/migrated/scheduled/discarded;
- Events and Notes do not acquire Task state;
- every Entry has exactly one owning placement;
- Monthly Calendar/Tasks placement and date invariants are enforced;
- Future is month-addressed, not a second day-level calendar;
- a Collection is a simple method-native owning container, not a configurable workspace;
- Collection references do not move the source Entry and remain distinct from migration;
- scheduling (`<`) targets Future;
- forward migration (`>`) currently targets an explicitly selected existing Collection;
- movement preserves historical source content and creates a fresh destination Entry plus lineage;
- Index deliberately catalogs an existing Log or Collection and never duplicates Entry content;
- Search is transient read-only retrieval and is never an owner or persistent Index source;
- historical Monthly and Daily lookups are non-mutating;
- cross-table semantic writes remain transactional through repository/service boundaries;
- `JournalSession` serializes unlocked journal work and owns encrypted persistence/key lifetime.

Schema v1 is now a published compatibility boundary because `v1.0.0-alpha.2` ships real user-journal support. Future supported builds must provide explicit tested compatibility/migration paths rather than silently regenerating or resetting published data.

## Retained-navigation lifecycle rule

The router uses `StatefulShellRoute.indexedStack`, so top-level sections remain mounted while inactive.

- returning to a section does not imply another `initState()`;
- a retained screen whose data can become stale because of work elsewhere must refresh when it becomes active;
- `AppSectionScope` is the current presentation-level activation signal;
- do not solve freshness by destroying all tabs, polling continuously, or adding an unrelated global cache.

This rule currently matters for Future after scheduling, Collections after migration/references, and Search after Task-state changes elsewhere.

## Security and portability baseline

The authoritative security contract lives in `SECURITY.md`. Backup details live in `docs/BACKUP_FORMAT.md`; Open Export details live in `docs/OPEN_EXPORT_FORMAT.md`; platform release procedure lives in `docs/RELEASE.md`.

Current foundation includes:

- SQLite3MultipleCiphers ChaCha20-Poly1305 encrypted persistence;
- random 48-byte journal material: 32-byte key + 16-byte cipher salt;
- master password never used directly as the SQLite key and never persisted;
- Argon2id-derived KEK + XChaCha20-Poly1305 authenticated key envelope;
- explicit mutable key-material destruction where practical;
- Android OS backup/device-transfer exclusion;
- user-facing portable authenticated encrypted backup/restore with rollback/recovery protections;
- explicit plaintext Open Export to deterministic JSON and human-readable Markdown;
- Appearance is non-secret device/application state outside the encrypted journal database;
- Android release builds fail closed if dedicated release signing is absent and never silently use debug signing.

The published `v1.0.0-alpha.2` key-envelope interpretation, 48-byte journal-key serialization, schema v1, backup format v1, and Open Export format v1 are compatibility-sensitive boundaries. Future changes require deliberate compatibility handling.

## Published alpha.2 release checkpoint

### Packaging

- application version: `1.0.0-alpha.2+2`;
- tag: `v1.0.0-alpha.2`;
- release source commit: `5c073c6bbbe298c15f975740a5499f2b9a0c98ba`;
- Android package: `io.github.marcelositr.daymark`;
- Android/Linux user-facing name: `Daymark`;
- Android release signing is local-only and fails closed when configuration/keystore is absent;
- Android release generation refreshes host/plugin configuration with `flutter build apk --config-only` before the `--no-pub` release build to avoid the pinned Flutter `integration_test` stale-registrant regression;
- no signing secret is stored in Git or CI.

Final distributed artifact SHA-256 values:

- Linux x64 archive: `490ce7c62126e8b9d5e9e78a3727f68c131e60ef197d0673d174ea0d44def9c4`;
- signed Android APK: `96f69264a4fc0fead8d31893f96aac428db341303abdfab929daaee5760f20f0`.

Android release certificate SHA-256:

`44342dcd1343643bc56da2545ec10e5624fc2e49d1bcc3b418f4f9ab160e1b88`

The release artifacts were built and locally validated from implementation head `b39be30c8e5635f93dddc5f6a2b07632e8a472ec`. The later pre-merge commits through Ready head `ad3eff96d9b9459761d4bfcebb91dfbd560df95d` were documentation-only, so Flutter/native build inputs did not change. Do not describe the artifacts as literally byte-built from the later squash SHA; describe the mapping precisely.

### Linux validation

Passed on the primary Debian validation host:

- analyzer and complete Flutter suite;
- native release build;
- `ldd` with no missing libraries;
- disposable XDG encrypted journal creation;
- Task/Note persistence across lock/unlock and restart;
- Dark Appearance persistence before unlock after restart;
- representative journal plaintext marker absent from application data.

### Physical Android validation

Hardware: Multilaser `M7_3G_PLUS`, Android 8.1.0 / SDK 27.

The pre-existing `1.0.0-alpha.1` development installation was debug-signed with a different certificate, so a direct install-over with the release-signed APK was impossible and was not falsely represented as an upgrade test.

Validated migration path:

1. identify and preserve the alpha.1 debug installation/certificate before destructive work;
2. update that installation with current code signed by the same debug certificate solely to expose the current portable backup behavior while retaining real data;
3. create and copy a portable encrypted migration backup;
4. preserve a second raw encrypted database/key-envelope/device-preferences safety snapshot;
5. verify the raw journal database does not expose the plaintext SQLite header;
6. uninstall the debug application only after both safety copies exist;
7. install the signed non-debuggable alpha.2 release cleanly;
8. restore the real alpha.1 portable backup into alpha.2;
9. verify existing journal data, lock/unlock, and Appearance;
10. create and structurally validate an alpha.2 backup;
11. reinstall the same signed release with `adb install -r` and verify retained data;
12. create and validate a second post-reinstall backup;
13. validate Markdown Open Export on physical Android;
14. after the metadata repair, update the signed release in place and validate JSON Open Export with exactly one UUID-v7 `journalMetadata` row and the existing entries still present.

Migration backup SHA-256:

`febbd3b2247ae9a434470ee1a6458b8bd7e14d0a49e5cea75b8629803255cdff`

Physical validation-copy SHA-256 values:

- Markdown Open Export: `ada5a36771280785f57417f17e4d6baeaeb0720618b28e97d3ba1fe7454b206f`;
- repaired JSON Open Export: `c6c0b7b37466c91486f7793fd714ed7033acfa46c707e2e13fa5eb965e27d91e`.

The local safety directory created during this migration should be retained through the immediate prerelease period. It is recovery evidence, not repository state, and must never be committed.

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
- PR #29: post-backup documentation and local performance benchmark. Squash `75380a863a64dd6d6e2b56f5fde2879ca517c2f4`.
- PR #30: explicit plaintext Open Export to deterministic JSON and human-readable Markdown. Squash `fecc5ea4b63297de0a8b1eb9da5c93e1ecf562e3`.
- PR #31: device-local System / Light / Dark Appearance selection. Squash `5184f519eed723221206ce529c4f0e0a2fed8bcf`.
- PR #32: alpha.2 packaging/signing hardening, legacy `journal_metadata` repair, release validation, and release documentation. Squash `5c073c6bbbe298c15f975740a5499f2b9a0c98ba`.
- PR #33: post-alpha.2 full documentation audit/alignment. Squash `76ef920d2c5d7ad56471b053d3446b530363c079`.

## Next development state

The post-alpha.2 documentation audit is complete and merged through PR #33. Current `main` is `76ef920d2c5d7ad56471b053d3446b530363c079`, and CI #477 passed on that exact SHA.

The accelerated post-alpha.2 execution plan is deliberately limited to four branches:

1. `chore/post-alpha2-alignment` - documentation-only correction of this living checkpoint. No product code.
2. `feat/navigation-and-organization` - direct source navigation from Search/Index, Index reorder/remove, and Collection-reference removal.
3. `feat/reflection-and-daily-ux` - richer Reflection, Linux keyboard/focus improvements, practical accessibility, and only the Settings needed by those flows.
4. `feat/security-and-next-release` - OS-level immediate lock hooks, device-assisted/biometric unlock, compatibility/migration work if required, backup/restore/export regression coverage, physical Linux/Android validation, and preparation of the next prerelease.

Execution rules for this accelerated plan:

- prefer local focused validation during development and avoid repeated CI merely for iteration;
- run full Ready CI once a branch is genuinely reviewable, because `merge-gate` remains mandatory;
- never trade away security, persistence, compatibility, or exact-head evidence for speed;
- retain merged feature/release branches as historical backup/reference if desired, but never reuse them as integration lines;
- do not split work merely for ceremony; split only when an independent security, migration, or review boundary makes isolation materially safer;
- merge only after exact-head CI is green and explicit user approval.

Still deferred beyond this plan:

- cloud/sync;
- broader Settings complexity unrelated to the selected flows;
- large refactors;
- AGP 9 built-in Kotlin migration unless it becomes a blocker.
