# Daymark project checkpoint

This is Daymark's canonical living handoff. Read this file and `AGENTS.md` before meaningful work. The repository, not a chat transcript, is the project memory.

## Current state

- Phase: **feature-complete prerelease maintenance**.
- Integration branch: `main` only.
- Current integrated `main` baseline: `c5879d147958da33eec20f0332cd96e38693788e`, squash merge of PR #43 `docs: record alpha.3 publication`.
- Latest published prerelease: `v1.0.0-alpha.3` / `1.0.0-alpha.3+3`, published on 2026-09-06 for Linux x64 and Android.
- Published alpha.3 release source commit: `f09665a76e0eb7c068a02d9e4513c53bd2b48481`.
- Alpha.3 validated binary build-source head: `e19ab982d2898cae223e396a1c2e4e26fc0446b0`; later documentation/release commits are not presented as the binary build source.
- Alpha.3 Linux x64 archive SHA-256: `bf11b1a9df952fdc3d4ce333490872a1b885dab2a56a56b6ff1062bd6b9d0189`.
- Alpha.3 Android APK SHA-256: `007f23c006282cb3eb9a7a2c62a97018631e36641d1539278436ba8d4ee41199`.
- Alpha.3 Android release certificate SHA-256: `77bca227f0cd95eb9e3c5a2c24902ba9d20e296dbdba9fde87d024cd0febb311`.
- Alpha.3 generated-source/formatter/analyzer/full Flutter suite, Linux release validation, Android release validation, and alpha.2 encrypted Backup -> alpha.3 Restore migration validation passed before publication.
- Runtime targets are **Linux and Android**.
- Pinned toolchain: Flutter 3.47.2 / Dart 3.13.2.
- Production Argon2id baseline: 19 MiB / 2 iterations / p=1 / 32-byte output.
- `release/1.0.0-alpha.3` is retained as historical release evidence.
- Active release-stabilization branch: `release/1.0.0-beta.1`, created from `main` commit `c5879d147958da33eec20f0332cd96e38693788e`.
- Current release candidate application version: `1.0.0-beta.1+4`.
- Planned release tag: `v1.0.0-beta.1`.
- Latest published prerelease remains `v1.0.0-alpha.3` until beta.1 is explicitly promoted and published.
- Completed release and feature branches are retained as historical reference/backup and are not deleted as routine cleanup.

## Product scope is frozen

On 2026-09-05 the maintainer declared the current Daymark product shape **feature-complete and frozen**.

Daymark is intended to remain the application it is now. Normal development no longer includes new product features, new workflow concepts, new platforms, new language surfaces, new convenience layers, or roadmap expansion.

Allowed maintenance work is limited to what is necessary to preserve the existing product safely and correctly:

- bug fixes and regression fixes;
- security fixes and necessary hardening;
- compatibility and migration fixes for supported Daymark data/releases;
- dependency/toolchain/platform maintenance required to keep Linux and Android working;
- packaging, signing, build, CI, release, accessibility, localization, or documentation corrections that preserve existing behavior;
- narrowly necessary internal refactoring to support those maintenance goals without expanding product behavior.

The following are **not planned product work** and must not be treated as deferred roadmap items:

- device-assisted or biometric unlock;
- recovery-secret UX or account/password-reset systems;
- cloud sync, accounts, collaboration, network services, or AI features;
- additional platforms beyond Linux and Android;
- additional product languages beyond English, Portuguese (Brazil), and Spanish;
- richer Search/indexing, new migration destinations, new reflection systems, new Collection models, or other feature extensions;
- dashboards, gamification, planner/Kanban/workspace abstractions, freeform pages/canvas editing, or engagement mechanics.

Historical documents may describe ideas as "future", "deferred", or "later" because they record earlier design stages. Those references are historical context only. This checkpoint and `docs/PRODUCT.md` are authoritative for the frozen product scope.

A requested change that alters what Daymark *does* rather than fixing or preserving what Daymark already does requires an explicit reversal of this freeze by the maintainer before implementation begins.

## Release/maintenance doctrine

Release progression may continue even though feature development is frozen. Alpha, beta, RC, stable, and later maintenance releases are validation/stability milestones, not permission to reopen feature scope.

Alpha.3 has been published and its release-stabilization cycle is complete.

The maintainer has approved promotion work for `v1.0.0-beta.1`. The active beta.1 release branch is a stabilization and release-validation boundary only; product scope remains frozen and no feature expansion is permitted.

Beta.1 is intended to promote the existing feature-complete product line after additional compatibility, platform, persistence, signing, and release validation.

## Product doctrine

Daymark is a faithful digital Bullet Journal, not a generic productivity suite.

- local-first and offline-first;
- digital minimalism and low distraction;
- no feeds, ads, streaks, XP, productivity scoring, gamification, or attention-seeking UI;
- no automatic choices that replace deliberate reflection;
- no generic planner/Kanban/workspace abstractions;
- English is canonical/fallback; exact `pt_BR` and general Spanish `es` are the supported additional locales;
- primary navigation concepts are Today, Monthly, Future, Collections, Search, and Index;
- optional Daymark Trackers remain the one documented non-canonical adaptation and are already part of the frozen product.

## Mandatory working rules

- `main` is the only permanent integration branch. Use short-lived maintenance branches and PRs.
- PR titles use Conventional Commit form.
- New `feat/*` product branches are not permitted while the product freeze is active.
- Normal code work should use `fix/*`, `chore/*`, `docs/*`, `refactor/*`, `test/*`, `ci/*`, or an explicitly approved `release/*` branch as appropriate.
- The user makes every merge and release-promotion decision. Never enable auto-merge, merge implicitly, tag implicitly, or publish implicitly.
- The agent owns implementation design, Git/GitHub operations available through connected tooling, test design, command construction, and diagnosis of returned evidence.
- Local execution may replace routine CI iteration when explicitly agreed, but correctness/security boundaries must not be weakened.
- Treat formatter output from the pinned Dart version as authoritative.
- Treat CI evidence as SHA-specific. A green superseded run does not validate a newer head.
- Never weaken security, persistence invariants, tests, or CI merely to make a check green.
- Do not use `flutter clean` as routine hygiene.
- Keep `PROJECT.md` current and `CHANGELOG.md` release-facing.
- User shell blocks must follow `docs/LOCAL_EXECUTION.md`; never use `set -e` or a bare `exit` in interactive blocks that could close the user's terminal.
- Retain historical feature/release branches unless the user explicitly chooses otherwise.

## Frozen product baseline

The product now consists of:

- encrypted journal creation, unlock, manual lock, inactivity lock, Android screen-off locking, and Linux system-session locking;
- Today / Daily Rapid Logging for Task, Event, and Note;
- deliberate Task Complete, Migrate, Schedule, and Discard decisions;
- contextual Daily Reflection and immediate capture Undo;
- read-only Daily history;
- Monthly Calendar and Tasks with historical read-only browsing;
- rolling six-month Future Log;
- method-native Collections with owned entries and removable references;
- deliberate Index with reorder/remove and direct source navigation;
- local Search with direct source navigation and retained-result refresh;
- encrypted portable Backup / Restore;
- plaintext Open Export to versioned JSON and human-readable Markdown after master-password reauthentication, with Save and Copy outputs;
- System / Light / Dark appearance selection;
- optional finite Monthly Trackers with explicit `+1 / -1` marks, absence rendered as `0` within the effective period, early ending, historical read-only viewing, Today controls, and reflective graphing;
- adaptive Linux/Android navigation, Daymark branding, responsive bounded page layout, keyboard/focus behavior, accessibility semantics, and quiet empty states;
- localized About/support identity surface with project website, source, issue-reporting location, author, GPL-3.0-or-later license, and open-source license disclosure.

GitHub public Issue intake is for Bug Reports. Blank issues are disabled. Security vulnerabilities are routed away from public Issues to the repository security-policy flow. Feature Request intake is intentionally removed because the product scope is frozen.

## Stable domain and persistence baseline

Published schema v1 contains:

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

Current schema v2 extends that published baseline additively with:

- `trackers`;
- `tracker_marks`.

The v1-to-v2 path is represented by retained Drift schema snapshots, generated versioned migration helpers, and migration tests that preserve representative v1 journal data.

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
- forward migration (`>`) targets an explicitly selected existing Collection;
- movement preserves historical source content and creates a fresh destination Entry plus lineage;
- Index deliberately catalogs an existing Log or Collection and never duplicates Entry content;
- Search is transient read-only retrieval and is never an owner or persistent Index source;
- historical Monthly and Daily lookups are non-mutating;
- cross-table semantic writes remain transactional through repository/service boundaries;
- `JournalSession` serializes unlocked journal work and owns encrypted persistence/key lifetime;
- Trackers are separate optional finite entities and never create a daily Task or change Entry ownership.

Published compatibility is a maintenance obligation. Supported builds must keep explicit tested migration/compatibility paths rather than resetting or silently reinterpreting user data.

## Security and portability baseline

The authoritative security contract lives in `SECURITY.md`. Backup details live in `docs/BACKUP_FORMAT.md`; Open Export details live in `docs/OPEN_EXPORT_FORMAT.md`; release procedure lives in `docs/RELEASE.md`.

Current foundation includes:

- SQLite3MultipleCiphers ChaCha20-Poly1305 encrypted persistence;
- random 48-byte journal material: 32-byte key + 16-byte cipher salt;
- master password never used directly as the SQLite key and never persisted;
- Argon2id-derived KEK + XChaCha20-Poly1305 authenticated key envelope;
- explicit mutable key-material destruction where practical;
- Android OS backup/device-transfer exclusion;
- portable authenticated encrypted backup/restore with rollback/recovery protections;
- plaintext Open Export requiring master-password reauthentication before plaintext generation;
- Android release builds fail closed if dedicated release signing is absent;
- Android screen-off and Linux systemd-logind session-lock events request immediate lock through the same serialized session path as manual/inactivity locking.

Security maintenance may strengthen implementation safety when required by a concrete vulnerability or compatibility need, but it must not be used as a pretext to add unrelated convenience features.

## Published alpha.2 checkpoint

- application version: `1.0.0-alpha.2+2`;
- tag: `v1.0.0-alpha.2`;
- release source commit: `5c073c6bbbe298c15f975740a5499f2b9a0c98ba`;
- Android package: `io.github.marcelositr.daymark`;
- Linux x64 archive SHA-256: `490ce7c62126e8b9d5e9e78a3727f68c131e60ef197d0673d174ea0d44def9c4`;
- signed Android APK SHA-256: `96f69264a4fc0fead8d31893f96aac428db341303abdfab929daaee5760f20f0`;
- Android release certificate SHA-256: `44342dcd1343643bc56da2545ec10e5624fc2e49d1bcc3b418f4f9ab160e1b88`.

The private signing key corresponding to the alpha.2 certificate was not recoverable during alpha.3 release preparation. The published alpha.2 artifact and certificate remain immutable historical evidence, but alpha.3 cannot be an Android install-over update of that signing lineage.

## Published alpha.3 checkpoint

- application version: `1.0.0-alpha.3+3`;
- annotated tag: `v1.0.0-alpha.3`;
- published release source commit: `f09665a76e0eb7c068a02d9e4513c53bd2b48481`;
- validated binary build-source head: `e19ab982d2898cae223e396a1c2e4e26fc0446b0`;
- Linux x64 archive SHA-256: `bf11b1a9df952fdc3d4ce333490872a1b885dab2a56a56b6ff1062bd6b9d0189`;
- signed Android APK SHA-256: `007f23c006282cb3eb9a7a2c62a97018631e36641d1539278436ba8d4ee41199`;
- Android release certificate SHA-256: `77bca227f0cd95eb9e3c5a2c24902ba9d20e296dbdba9fde87d024cd0febb311`;
- retained alpha.2 encrypted backup used for compatibility validation SHA-256: `d6d6b7f94b869d95a61369ff675ba96dcc51633917995734e68dfac46628a23f`;
- GitHub Release published as a prerelease on 2026-09-06 with Linux, Android, and `SHA256SUMS` assets.

Release-critical compatibility result:

1. direct Android alpha.2 -> alpha.3 install-over is **not supported** because the alpha.2 private signing key was unavailable and alpha.3 establishes a new dedicated signing lineage;
2. the supported alpha.2 -> alpha.3 Android migration path is encrypted Backup / uninstall alpha.2 / clean-install alpha.3 / Restore using the existing master password;
3. a retained real alpha.2 encrypted backup restored successfully into a clean alpha.3 installation on physical Android hardware and remained usable after force-stop/relaunch;
4. schema-v1-to-v2 compatibility remains protected by the portable encrypted backup boundary plus the retained additive Drift migration tests;
5. Linux and Android release validation completed successfully before publication;
6. the alpha.3 signing keystore remains local-only and backed up outside the repository;
7. later Android releases intended for install-over upgrades must preserve the alpha.3 signing lineage unless an explicit platform-supported signing migration is deliberately adopted, tested, and documented.

The published tag and artifacts are immutable release evidence. Future maintenance starts from `main`.

## Active beta.1 release preparation

- candidate application version: `1.0.0-beta.1+4`;
- planned annotated tag: `v1.0.0-beta.1`;
- active branch: `release/1.0.0-beta.1`;
- Draft PR: #44 `build(release): prepare 1.0.0-beta.1`, opened from head `6bf9ff8b18dabb5e5913ba5d628f8d1fb17e7738`;
- release base: `c5879d147958da33eec20f0332cd96e38693788e`;
- latest published prerelease remains `v1.0.0-alpha.3`;
- schema remains v2; beta.1 does not introduce a schema change;
- Linux and Android remain the only release targets;
- English, Portuguese (Brazil), and Spanish are the only supported product languages; the maintainer explicitly approved Spanish as the sole language-scope expansion on 2026-09-06;
- Android beta.1 must preserve the alpha.3 signing certificate SHA-256 `77bca227f0cd95eb9e3c5a2c24902ba9d20e296dbdba9fde87d024cd0febb311`.

The beta.1 promotion gate must prove:

1. complete generated-source, formatting, analyzer, and Flutter test validation;
2. Linux release build, `.deb` and AppImage packaging validation, and maintainer smoke validation for both formats;
3. signed Android release build using the exact alpha.3 signing lineage;
4. direct Android `alpha.3 -> beta.1` install-over succeeds without uninstalling alpha.3;
5. the existing alpha.3 journal remains unlockable with the same master password after install-over;
6. journal data, schema-v2 Trackers, Task states, migration lineage, appearance, and persistence remain intact after upgrade and force-stop/relaunch;
7. encrypted Backup / Restore remains valid on beta.1;
8. Open Export reauthentication plus JSON/Markdown Save/Copy remains valid;
9. exact release artifact SHA-256 values and exact binary build-source head are recorded;
10. exact Ready PR head passes required CI and `merge-gate`;
11. publication occurs only after explicit maintainer promotion approval.

Local validation evidence gathered on 2026-09-06 for beta.1 implementation commit `70885b9a7f9906d0a54d696b43dc2cf18a966931`:

- locked dependency resolution, localization generation, Drift generation, migration snapshot verification, and generated-artifact drift check passed;
- pinned formatting check passed with no changes required;
- `flutter analyze` passed with no issues;
- the complete Flutter suite passed with 214 tests, including Spanish catalog parity, critical security-language assertions, general Spanish regional-locale resolution, and unsupported-locale English fallback;
- Linux debug and release builds passed, including a release rebuild after Spanish localization generation;
- beta.1 Linux distribution now replaces the raw `.tar.gz` candidate with `.deb` and AppImage packages generated from the same release bundle; the local packaging script produced and structurally validated both formats, and offline AppStream validation passed with `appstreamcli` 1.0.5;
- complete Portuguese (Brazil) user Wiki source now lives under `wiki/`; PRs to `main` validate it without write permission, and only a merged push to `main` synchronizes it automatically to `daymark.wiki.git`;
- Android debug and signed release APK builds passed;
- the signed release APK was verified as one signer with the required alpha.3 certificate SHA-256 `77bca227f0cd95eb9e3c5a2c24902ba9d20e296dbdba9fde87d024cd0febb311`;
- the backup recovery test emitted Drift's expected debug warning because it deliberately keeps the source database open while validating a separately restored snapshot; both databases are distinct and explicitly closed;
- the Android toolchain emitted non-blocking SDK XML-version and unused `CupertinoIcons` font warnings; no `CupertinoIcons` reference exists in Daymark source, tests, or dependency declarations.

Candidate artifacts regenerated from exact beta.1 implementation commit `70885b9a7f9906d0a54d696b43dc2cf18a966931`:

- Debian `amd64` candidate SHA-256: `41ae8d09bb4efcb2b7055a034809263331f4ed25879c52d4a5455f475231c301`;
- AppImage x86-64 candidate SHA-256: `bcaad4e3d777cb8d13cd4217ff28009eb60abc69147422125cb1806daf0ac2dc`;
- signed Android APK candidate SHA-256: `4ec6dd5166fc1ca343b4080b01d12c9e70bf6aabb565a83b23614169cde0aab9`;
- Android signer certificate SHA-256 remains `77bca227f0cd95eb9e3c5a2c24902ba9d20e296dbdba9fde87d024cd0febb311`.

Draft PR CI #533 (`https://github.com/marcelositr/daymark/actions/runs/34035717273`) passed `dev-check` on exact PR head `4e18ffbc1e3e14b6afe450d7c259de3fbbfb4ec3`. As expected for a Draft PR, `quality`, Linux, Android, dependency review, and `merge-gate` were skipped. This evidence validates the Draft tier only; the final documented Ready head still requires the complete merge tier.

This local evidence does not replace physical-device install-over/behavior validation, Linux smoke validation, final artifact identity recording, or exact final-head Ready CI and `merge-gate`.

No product capability beyond the maintainer-approved general Spanish localization belongs in this branch.

## Merged product baseline

- PR #13: encrypted create/unlock/manual lock plus Today.
- PR #14: inactivity lock.
- PR #15: Task complete/discard.
- PR #16: Monthly.
- PR #17: Future.
- PR #18: scheduling.
- PR #20: Collections.
- PR #21: migration to Collection.
- PR #22: Collection references.
- PR #23: Index.
- PR #24: historical Monthly.
- PR #25: Search.
- PR #26: Daily history.
- PR #27: stabilization handoff.
- PR #28: encrypted Backup / Restore.
- PR #29: documentation/performance benchmark.
- PR #30: Open Export.
- PR #31: Appearance.
- PR #32: `v1.0.0-alpha.2` release baseline.
- PR #34: accelerated post-alpha planning alignment.
- PR #35: navigation/organization controls.
- PR #36: reflection, Rapid Logging UX, Undo, notices.
- PR #37: Open Export reauthentication/clipboard plus immediate session locking.
- PR #38: optional Monthly Trackers and schema v2, squash `0c77e689e8feed8bdd5245f86b26774d47289d12`.
- PR #40: final branding/UI/UX/accessibility polish, squash `740120052b56f155a136ac640cbaa1831cdd1e74`.
- PR #41: About/support identity and structured issue entry points, squash `a08c5f8f1e2bc340801f9e3f33e9353d6cb9122b`.
- PR #42: alpha.3 release preparation and frozen release baseline, squash `f09665a76e0eb7c068a02d9e4513c53bd2b48481`.
- PR #43: post-alpha.3 publication-state documentation alignment, squash `c5879d147958da33eec20f0332cd96e38693788e`.

## Next development state

Daymark is currently validating `v1.0.0-beta.1` on `release/1.0.0-beta.1` after publication of `v1.0.0-alpha.3`.

There is no feature backlog to resume. New work begins only from observed bugs, vulnerabilities, compatibility failures, supported platform/toolchain breakage, release/packaging defects, accessibility/localization corrections, or documentation inaccuracies.

The selected next release is `v1.0.0-beta.1`. Draft PR #44 is open. The next concrete step is to continue the beta.1 gate with installed `.deb` and AppImage smoke checks plus physical Android `alpha.3 -> beta.1` install-over validation, then move the exact final PR head to Ready for required CI. No merge, tag, promotion, or publication is authorized until the required exact-head evidence is complete and the maintainer explicitly approves it.
