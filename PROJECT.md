# Daymark project checkpoint

This is Daymark's canonical living handoff. Read this file and `AGENTS.md` before meaningful work. The repository, not a chat transcript, is the project memory.

## Current state

- Phase: pre-alpha, vacation-ready stabilization and first distributable prerelease.
- Integration branch: `main` only.
- Current merged `main`: `5184f519eed723221206ce529c4f0e0a2fed8bcf`, squash merge of PR #31 `feat(appearance): add persistent appearance selection`.
- PR #31 exact Ready head: `e0474bbf873d1a20cf128e367850cac84228c19d`.
- PR #31 Ready CI #472 passed quality, Linux, Android, dependency review, and `merge-gate`.
- Post-merge `main` CI #473 passed on exact merged SHA `5184f519eed723221206ce529c4f0e0a2fed8bcf`.
- Active branch: `release/1.0.0-alpha.2`.
- Release target: `1.0.0-alpha.2+2`, eventual annotated tag `v1.0.0-alpha.2` only after final Ready CI, explicit user approval, squash merge, and post-merge verification.
- Runtime targets: Linux and Android.
- Pinned toolchain: Flutter 3.47.2 / Dart 3.13.2.
- Merge policy: never merge without explicit user approval; squash merge is the default.
- Production Argon2id baseline: 19 MiB / 2 iterations / p=1 / 32-byte output.
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
- Treat formatter output from the pinned Dart version as authoritative.
- Treat CI evidence as SHA-specific. A green superseded run does not validate a newer head.
- Never weaken security, persistence invariants, tests, or CI merely to make a check green.
- Do not use `flutter clean` as routine hygiene; preserve incremental build state unless evidence requires a controlled clean rebuild.
- Keep `PROJECT.md` current and `CHANGELOG.md` release-facing.
- Remove temporary workflow probes/scripts before Ready.
- User shell blocks must follow `docs/LOCAL_EXECUTION.md`.

## Local-first stabilization loop

For each substantive branch unless the change is too small to justify every step:

1. start from exact current `main` and create one short-lived branch with one coherent responsibility;
2. implement and add/update focused tests at the correct layer;
3. generate localization/Drift artifacts when applicable;
4. run the pinned formatter early;
5. run analyzer and focused tests;
6. run the complete Flutter suite and locally relevant native builds at meaningful checkpoints;
7. run the real manual flow for persistence, lifecycle, navigation, backup/restore, export, or platform behavior;
8. diagnose surprising results before changing production behavior;
9. align documentation on the final branch head;
10. use full Ready CI once the branch is reviewable;
11. merge only after exact-head CI is green and the user explicitly approves squash merge.

If GitHub Actions or API evidence is delayed, continue independent work where safe. `gh` is available on the local validation host as a fallback. Never infer a green result.

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
- `journal_metadata` identifies that journal with exactly one singleton row;
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
- portable authenticated encrypted backup with HMAC integrity and rollback/recovery protections;
- explicit plaintext Open Export to deterministic JSON and human-readable Markdown;
- Appearance is non-secret device/application state outside the encrypted journal database;
- Android release builds fail closed if dedicated release signing is absent and never silently use debug signing.

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

## Active stabilization slice: release 1.0.0-alpha.2

Release hardening is implemented on `release/1.0.0-alpha.2`.

### Packaging and signing

- version is `1.0.0-alpha.2+2`;
- Android and Linux user-facing application name is `Daymark`;
- Android release signing uses local-only `android/key.properties` plus `android/daymark-upload.jks`;
- signing files are ignored and passwords were never printed or committed;
- release Gradle tasks fail closed when signing configuration or keystore is absent;
- Android release builds run `flutter build apk --config-only` before `flutter build apk --release --no-pub` to avoid the pinned Flutter `integration_test` stale-registrant regression;
- generated `android/build/` output is ignored;
- no routine `flutter clean` was introduced.

### Journal metadata compatibility repair

Physical Open Export validation exposed a legacy compatibility defect: the real alpha.1 journal had zero `journal_metadata` rows even though the data-model contract requires exactly one.

The release branch now:

- initializes one UUID-v7 singleton metadata row when a new journal is created;
- repairs a legacy journal with zero rows on successful unlock;
- performs the repair transactionally and idempotently;
- keeps the generated identity stable after creation;
- fails closed when more than one metadata row exists instead of silently choosing or rewriting one;
- preserves existing encrypted journal content during the repair.

Focused metadata/session/export/backup tests, analyzer, the complete Flutter suite, Linux release build, Android configuration refresh, and signed Android release build passed after this change.

### Linux release evidence

Latest candidate directory on the validation host:

`~/Downloads/daymark-1.0.0-alpha.2-20260904T150736`

Latest candidate SHA-256 values:

- Linux x64 bundle archive: `490ce7c62126e8b9d5e9e78a3727f68c131e60ef197d0673d174ea0d44def9c4`;
- signed Android APK: `96f69264a4fc0fead8d31893f96aac428db341303abdfab929daaee5760f20f0`.

Linux release validation passed:

- analyzer and complete Flutter suite;
- native release build;
- `ldd` with no missing libraries;
- disposable XDG journal creation;
- Task/Note persistence across lock/unlock and restart;
- Dark Appearance persistence before unlock after restart;
- representative plaintext marker absent from application data.

The artifact checksums above supersede all earlier alpha.2 candidate checksums.

### Physical Android release evidence

Validation hardware: Multilaser `M7_3G_PLUS`, Android 8.1.0 / SDK 27.

Release certificate SHA-256:

`44342dcd1343643bc56da2545ec10e5624fc2e49d1bcc3b418f4f9ab160e1b88`

The existing physical `1.0.0-alpha.1` installation was a debug build signed with a different certificate. The migration flow therefore did not pretend that a direct signed upgrade was possible.

Validated migration path:

1. identify the installed alpha.1 version, debug status, and certificate before destructive work;
2. preserve the installed APK;
3. build current code in debug mode and confirm it uses the same old debug certificate;
4. `adb install -r` that temporary debug build to preserve the real alpha.1 journal while exposing current backup behavior;
5. create a portable encrypted backup and pull it to the host;
6. additionally preserve a raw encrypted database/key-envelope/device-preferences safety snapshot before uninstall;
7. verify the raw database does not expose the plaintext SQLite header;
8. uninstall only after both safety copies exist;
9. install the signed, non-debuggable alpha.2 release cleanly;
10. restore the portable alpha.1 backup into alpha.2 and verify real journal data;
11. revalidate lock/unlock and Appearance;
12. create an alpha.2 backup and validate its v1/schema-v1 structure;
13. `adb install -r` the same signed release and verify retained data again;
14. create a second post-reinstall backup and validate it.

Migration backup SHA-256:

`febbd3b2247ae9a434470ee1a6458b8bd7e14d0a49e5cea75b8629803255cdff`

Open Export on physical Android passed:

- Markdown format/version/schema header;
- explicit plaintext warning;
- complete section set;
- UTF-8;
- JSON format v1/schema v1 and ordered top-level structure;
- after metadata repair, exactly one UUID-v7 `journalMetadata` row;
- existing entries remained present after the repair/update.

Physical validation-copy checksums:

- Markdown: `ada5a36771280785f57417f17e4d6baeaeb0720618b28e97d3ba1fe7454b206f`;
- repaired JSON: `c6c0b7b37466c91486f7793fd714ed7033acfa46c707e2e13fa5eb965e27d91e`.

The local safety directory and tablet `.daymark-backup` files must be retained until the prerelease is fully published and verified.

## Remaining alpha.2 gate

1. final release documentation alignment;
2. Ready PR from `release/1.0.0-alpha.2` to `main`;
3. exact-head quality/full tests, Linux build, Android build, dependency review, and `merge-gate` green;
4. explicit user approval for squash merge;
5. post-merge `main` CI green on the exact squash SHA;
6. explicit release approval;
7. annotated tag `v1.0.0-alpha.2` on the approved merged commit;
8. GitHub Release marked prerelease with the exact Linux/APK artifacts and SHA-256 values.

No tag or GitHub Release is created before these gates pass.

## Deferred after alpha.2 unless a blocker appears

- direct source navigation from Search/Index;
- richer Reflection workflows;
- OS-level immediate lock hooks;
- device-assisted/biometric unlock;
- reference removal;
- Index reorder/remove;
- cloud/sync;
- broader Settings complexity;
- large refactors;
- AGP 9 built-in Kotlin migration, unless it becomes a release blocker.

## CI and handoff traps

- Ready PRs require quality/full tests, Linux, Android, dependency review, and `merge-gate` on the exact final head.
- CI evidence is SHA-specific; a green superseded run validates nothing newer.
- A red formatter or generated-source check may be mechanical evidence rather than a product defect; diagnose before changing behavior.
- Android release signing secrets never belong in CI merely to make a local signed release test reproducible there; CI debug Android build remains an appropriate code/build gate.
- The pinned Flutter toolchain may leave a dev-only `integration_test` registrant for Android `--no-pub`; use the documented `--config-only` refresh, not `flutter clean` or production dependency pollution.
- `StatefulShellRoute.indexedStack` retains screens; section navigation is not a remount lifecycle.
- If GitHub Actions/API results are delayed or incomplete, do not infer success. Continue independent work where safe and request only the smallest missing evidence when blocked.
