# Daymark project checkpoint

This is Daymark's canonical living handoff. Read this file and `AGENTS.md` before meaningful work. The repository, not a chat transcript, is the project memory.

## Current state

- Phase: **feature-complete prerelease stabilization and maintenance**.
- Integration branch: `main` only.
- Current integrated `main` baseline: `a08c5f8f1e2bc340801f9e3f33e9353d6cb9122b`, squash merge of PR #41 `feat(app): add About and support entry points`.
- Active release-stabilization branch: `release/1.0.0-alpha.3`, created from that exact `main` baseline.
- Release candidate application version: `1.0.0-alpha.3+3`.
- Planned release tag: `v1.0.0-alpha.3`.
- Latest published release remains `v1.0.0-alpha.2` / `1.0.0-alpha.2+2` until alpha.3 is explicitly promoted and published.
- Published alpha.2 source commit: `5c073c6bbbe298c15f975740a5499f2b9a0c98ba`.
- Runtime targets are **Linux and Android**.
- Pinned toolchain: Flutter 3.47.2 / Dart 3.13.2.
- Production Argon2id baseline: 19 MiB / 2 iterations / p=1 / 32-byte output.
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
- additional product languages beyond English and Portuguese (Brazil);
- richer Search/indexing, new migration destinations, new reflection systems, new Collection models, or other feature extensions;
- dashboards, gamification, planner/Kanban/workspace abstractions, freeform pages/canvas editing, or engagement mechanics.

Historical documents may describe ideas as "future", "deferred", or "later" because they record earlier design stages. Those references are historical context only. This checkpoint and `docs/PRODUCT.md` are authoritative for the frozen product scope.

A requested change that alters what Daymark *does* rather than fixing or preserving what Daymark already does requires an explicit reversal of this freeze by the maintainer before implementation begins.

## Release/maintenance doctrine

Release progression may continue even though feature development is frozen. Alpha, beta, RC, stable, and later maintenance releases are validation/stability milestones, not permission to reopen feature scope.

The current alpha.3 goal is to publish the completed post-alpha.2 product line as a validated prerelease. No feature may be added to the alpha.3 release branch. Only release blockers or maintenance corrections discovered during validation may change its production behavior.

After alpha.3, development returns to `main` in maintenance mode. The next release version is chosen from actual stabilization/bug-fix needs, not from a feature roadmap.

## Product doctrine

Daymark is a faithful digital Bullet Journal, not a generic productivity suite.

- local-first and offline-first;
- digital minimalism and low distraction;
- no feeds, ads, streaks, XP, productivity scoring, gamification, or attention-seeking UI;
- no automatic choices that replace deliberate reflection;
- no generic planner/Kanban/workspace abstractions;
- English is canonical/fallback; exact `pt_BR` is the supported additional locale;
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

## Alpha.3 release preparation

The alpha.3 release branch freezes the current product as `1.0.0-alpha.3+3`.

Release-critical compatibility target:

1. start from a real public alpha.2 signed installation with controlled journal data;
2. install the signed alpha.3 candidate over alpha.2 using the same release-signing lineage;
3. confirm alpha.2 schema-v1 journal data migrates to schema v2 without loss;
4. confirm unlock, restart persistence, core journal navigation/actions, Trackers, Backup/Restore, Open Export, Appearance, and About remain functional;
5. separately verify an encrypted backup created by alpha.2 restores correctly into alpha.3;
6. validate Linux release bundle and signed Android release APK;
7. record exact SHA-256 identities for distributed artifacts.

The release branch may receive only fixes required by this validation. No product expansion is permitted.

Before promotion require:

- version/docs/changelog aligned;
- generated-source/formatter/analyzer/full test suite green;
- Linux release build and smoke test green;
- signed Android release build and physical-device smoke/upgrade test green;
- backup/restore and schema-v1-to-v2 compatibility green;
- Open Export reauthentication/save/copy checks green;
- dependency/security review complete;
- no secrets/local-only material committed;
- exact Ready PR `merge-gate` green;
- explicit user approval to merge;
- explicit user approval to create tag/GitHub Release and publish artifacts.

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

## Next development state

The only active work is alpha.3 release stabilization.

After publication, Daymark returns to maintenance mode. There is no feature backlog to resume. New work begins from observed bugs, vulnerabilities, compatibility failures, platform/toolchain breakage, release/packaging defects, or documentation inaccuracies.
