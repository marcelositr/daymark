# Daymark

Daymark is a minimal, local-first Bullet Journal application for Linux and Android, designed to stay faithful to the original method while removing digital clutter.

> The interface should disappear during use. The journal, reflection, and decisions come first.

Project website: [devnux.com.br/daymark](https://devnux.com.br/daymark)

## Project status

Daymark is **feature-complete and in prerelease stabilization**.

The current functional scope is frozen. Daymark is intended to remain the application described in this repository rather than continue expanding with new product features.

Normal development is now limited to:

- bug and regression fixes;
- security fixes and necessary hardening;
- compatibility and migration fixes;
- dependency/toolchain/platform maintenance required to keep Linux and Android working;
- packaging, release, CI, accessibility, localization, and documentation corrections that preserve existing behavior.

New product features, additional platforms, additional product languages, cloud/account systems, biometric/device-assisted unlock, recovery-secret UX, AI features, collaboration, dashboards, richer planner abstractions, and other roadmap expansion are not planned while this freeze is active.

The latest published prerelease is [`v1.0.0-alpha.2`](https://github.com/marcelositr/daymark/releases/tag/v1.0.0-alpha.2), published on 2026-09-04 for Linux x64 and Android.

The current release-stabilization branch prepares **`v1.0.0-alpha.3` / `1.0.0-alpha.3+3`** from the completed product baseline. Alpha.3 does not add a new feature stage; it packages and validates the completed post-alpha.2 work.

## Current product

Daymark includes:

- encrypted journal creation and unlock with explicit manual locking;
- five-minute inactivity locking plus Android screen-off and Linux system-session lock handling;
- Today / Daily Log with Rapid Logging for Task, Event, and Note;
- deliberate Task completion, migration, scheduling, and discard;
- contextual Daily Reflection and immediate capture Undo;
- read-only historical Daily browsing;
- Monthly Log with Calendar, Tasks, historical read-only browsing, and optional finite Monthly Trackers;
- rolling six-month Future Log;
- method-native Collections with owned entries and removable references;
- deliberate Index with reorder/remove and source navigation;
- local Search with real source navigation and retained-result refresh;
- portable authenticated encrypted Backup / Restore;
- explicit plaintext Open Export to deterministic JSON and human-readable Markdown after master-password reauthentication, with Save and Copy outputs;
- device-local System / Light / Dark appearance selection;
- Daymark application branding and a restrained responsive Linux/Android visual system;
- Linux keyboard/focus refinements, accessibility semantics, consistent empty states, and adaptive navigation;
- a localized About surface exposing the app version, project website, source, bug-reporting location, author, GPL-3.0-or-later license, and open-source licenses;
- structured public Bug Report intake, with blank issues disabled and security vulnerabilities directed away from public Issues;
- Linux and Android release packaging with Android release signing that fails closed if signing configuration is missing.

The pinned toolchain is Flutter 3.47.2 with Dart 3.13.2.

## Product principles

- Faithful to the core Bullet Journal method.
- Digital minimalism by default.
- Local-first and offline-first.
- Encryption at rest for persisted journal data.
- Linux and Android are the supported platforms.
- English and Portuguese (Brazil) are the supported product languages.
- Open, documented user-data portability.
- No advertising, feeds, engagement loops, streaks, productivity scoring, gamification, or attention-seeking UI.
- Automation must not remove deliberate reflection or migration decisions from the method.
- Daymark-specific adaptations must be explicit adaptations rather than being presented as canonical Bullet Journal rules.

## Method shape

Daymark deliberately avoids turning Bullet Journal concepts into a generic planner.

- **Today / Daily Log** captures Task, Event, and Note entries for the current method date. Earlier Daily Logs are read-only retrieval.
- **Daily Reflection** isolates unresolved Tasks so the user deliberately decides whether each one is completed, migrated, scheduled, or discarded.
- **Monthly Log** keeps the current month interactive, with a dated Calendar, separate Tasks, and the optional Daymark Tracker adaptation. Earlier months remain read-only.
- **Future Log** is a rolling overview of six future month buckets beginning with the month after the current month. It is month-addressed, not a second day-level calendar.
- **Collections** are simple method-native topic/project containers, not configurable workspaces.
- **Scheduling (`<`)** moves an open Task deliberately into a selected Future month while preserving source history and lineage.
- **Forward migration (`>`)** moves an open Today/Monthly Task deliberately into an existing Collection while preserving source history and lineage.
- **Collection references** expose an existing entry inside a Collection without moving or copying the source entry.
- **Index** is a deliberate persisted catalog of existing Logs and Collections.
- **Search** is explicit local read-only retrieval over existing Entry content.
- **Trackers** are an optional finite Daymark adaptation with deliberate `+1 / -1` marks and reflective graphing, separate from Tasks and Entry ownership.
- **Backup / Restore** is the protected recovery/migration boundary.
- **Open Export** is the explicit plaintext portability boundary and is not a restore format.

This method/product shape is the frozen Daymark scope.

## Interface direction

Daymark uses Material 3 as a technical foundation, not as a stock visual identity.

The presentation baseline includes:

- shared Daymark design tokens for control radii, heights, spacing, page breakpoints, and bounded content width;
- compact Android margins and centered bounded desktop content;
- consistent typography, controls, navigation states, dialogs, menus, and Tracker affordances;
- adaptive navigation: Today, Monthly, Future, and Collections remain direct on compact layouts, while Search and Index live under More; expanded desktop layouts expose all six destinations;
- application branding on Linux and Android;
- quiet empty states and restrained feedback;
- Linux keyboard/focus behavior without compromising Android touch behavior;
- accessibility semantics for journal entry type/state and Tracker selection state.

The visual rule remains digital minimalism: journal content gets the visual weight. Daymark intentionally avoids decorative notebook hardware, gamified progress signals, dashboard chrome, and freeform canvas/page editing.

## Technology direction

The reviewed baseline is documented in [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md), with the relational persistence contract in [`docs/DATA_MODEL.md`](docs/DATA_MODEL.md) and the security contract in [`SECURITY.md`](SECURITY.md).

At a glance:

- Flutter 3.47.2 / Dart 3.13.2;
- Material 3 with a restrained custom Daymark presentation layer;
- Riverpod for state/dependency wiring;
- go_router for application routing;
- Drift for typed relational persistence and tested schema evolution;
- sqlite3 with SQLite3MultipleCiphers for encrypted native storage;
- `cryptography` 2.9.0 with Argon2id + XChaCha20-Poly1305 for the portable application key hierarchy;
- Flutter ARB / `gen_l10n` localization.

The exact resolved dependency set is committed in `pubspec.lock` and changes only through reviewed maintenance updates.

## Development workflow

Daymark uses one permanent integration branch (`main`), short-lived maintenance branches, pull requests, squash merges by default, and explicit release gates.

See [`docs/WORKFLOW.md`](docs/WORKFLOW.md).

The public release train may progress through prerelease/stable milestones without reopening feature scope:

```text
v1.0.0-alpha.N
v1.0.0-beta.N
v1.0.0-rc.N
v1.0.0
```

Promotion is never automatic. Each release is validated and explicitly approved.

## Documentation map

- [`PROJECT.md`](PROJECT.md): canonical live checkpoint, product freeze, release evidence, compatibility boundaries, and next maintenance/release step
- [`AGENTS.md`](AGENTS.md): mandatory operating contract for AI-assisted development
- [`docs/PRODUCT.md`](docs/PRODUCT.md): frozen product shape and maintenance boundary
- [`docs/DOMAIN.md`](docs/DOMAIN.md): Bullet Journal semantics
- [`docs/DATA_MODEL.md`](docs/DATA_MODEL.md): relational schema, persistence invariants, and migration policy
- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md): technical architecture and technology baseline
- [`docs/TRACKERS.md`](docs/TRACKERS.md): provenance and behavior of the optional Tracker adaptation
- [`SECURITY.md`](SECURITY.md): current threat model and security constraints
- [`docs/SECURITY_FOUNDATION.md`](docs/SECURITY_FOUNDATION.md): historical PR #7 security-foundation validation record
- [`docs/ARGON2_BENCHMARK.md`](docs/ARGON2_BENCHMARK.md): Linux/Android KDF benchmark procedure and evidence
- [`docs/BACKUP_FORMAT.md`](docs/BACKUP_FORMAT.md): portable authenticated encrypted backup format and restore safety contract
- [`docs/OPEN_EXPORT_FORMAT.md`](docs/OPEN_EXPORT_FORMAT.md): plaintext JSON/Markdown portability contract
- [`docs/RELEASE.md`](docs/RELEASE.md): Linux/Android packaging, signing, and release verification procedure
- [`docs/WORKFLOW.md`](docs/WORKFLOW.md): branches, validation, maintenance, versioning, and releases
- [`docs/LOCAL_ENVIRONMENT.md`](docs/LOCAL_ENVIRONMENT.md): primary local validation-host record
- [`docs/LOCAL_EXECUTION.md`](docs/LOCAL_EXECUTION.md): safe terminal-block contract for user-assisted local validation
- [`docs/PERFORMANCE_BENCHMARK.md`](docs/PERFORMANCE_BENCHMARK.md): measured local build/test baseline and tuning protocol
- [`CONTRIBUTING.md`](CONTRIBUTING.md): maintenance contribution expectations
- [`CHANGELOG.md`](CHANGELOG.md): release-facing history

## License

Daymark is distributed under the GNU General Public License v3.0 or later (`GPL-3.0-or-later`).
