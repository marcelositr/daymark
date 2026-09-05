# Daymark

Daymark is a minimal, local-first Bullet Journal application for Linux and Android, designed to stay faithful to the original method while removing digital clutter.

> The interface should disappear during use. The journal, reflection, and decisions come first.

Project website: [devnux.com.br/daymark](https://devnux.com.br/daymark)

## Project status

Daymark is in **alpha development**.

The first controlled distributable prerelease, [`v1.0.0-alpha.2`](https://github.com/marcelositr/daymark/releases/tag/v1.0.0-alpha.2), was published on 2026-09-04 for Linux x64 and Android. It is prerelease software, not a stable `1.0.0` release.

Since alpha.2, the accelerated four-stage product plan has been completed: navigation/organization, contextual reflection and Rapid Logging calibration, optional Monthly Trackers, and a final Linux/Android UI/UX polish pass.

The current product line includes:

- encrypted journal creation, unlock, manual lock, five-minute inactivity lock, Android device non-interactive lock, and Linux system-session lock integration;
- Today / Daily Log with Rapid Logging for Task, Event, and Note plus read-only historical Daily browsing;
- deliberate Task completion, migration, scheduling, and discard;
- contextual Daily Reflection for unresolved Tasks and immediate capture Undo;
- a Monthly Log with interactive current-month Calendar and Tasks plus read-only historical month browsing;
- a rolling six-month Future Log;
- deliberate scheduling of open Tasks from Today and Monthly into real Future Log month buckets while preserving historical source state and movement lineage;
- method-native Collections with owned Task, Event, and Note entries;
- deliberate forward migration (`>`) of open Tasks from Today and Monthly Tasks into an explicitly selected existing Collection;
- Collection references that can be created and later removed without moving or deleting the source Entry;
- a deliberate ordered Index of existing Logs and Collections with reorder/remove controls and direct source navigation;
- local Search across existing Entry content with owner context, retained refresh, and direct navigation to the real source;
- optional finite Monthly Trackers with explicit `+1 / -1` marks, rendered `0` for absence inside the effective period, early ending, historical read-only viewing, compact Today controls, and a restrained reflection graph;
- user-facing portable authenticated encrypted Backup / Restore;
- explicit plaintext Open Export to deterministic JSON and human-readable Markdown after master-password reauthentication, with Save and Copy outputs;
- device-local System / Light / Dark appearance selection;
- Daymark application branding plus a restrained responsive visual system shared by Linux and Android;
- Linux keyboard/focus refinements, accessibility semantics, consistent empty states, and adaptive navigation;
- a localized About surface exposing the current app version, project website, source, issue-reporting location, author, license, and open-source licenses;
- structured public Bug Report and Feature Request forms, with security vulnerabilities directed away from public Issues;
- Linux and Android release packaging with dedicated Android release signing that fails closed if signing configuration is missing.

The pinned toolchain is Flutter 3.47.2 with Dart 3.13.2, targeting Linux and Android.

The canonical live development checkpoint is [`PROJECT.md`](PROJECT.md). It records the latest published release checkpoint, compatibility boundaries, validation evidence, completed work, and next intended decision.

Any human or AI contributor should read [`AGENTS.md`](AGENTS.md) before continuing work. The repository is intentionally structured so development can resume across chat limits, CLI restarts, API quotas, and different agents without relying on hidden conversation context.

## Product principles

- Faithful to the core Bullet Journal method.
- Digital minimalism by default.
- Local-first and offline-first.
- Encryption at rest for persisted journal data.
- Linux and Android are the initial supported platforms.
- Architecture remains portable to future desktop and mobile targets.
- Open, documented user-data portability.
- No advertising, engagement loops, streaks, productivity scoring, or attention-seeking UI.
- Automation must not remove deliberate reflection or migration decisions from the method.
- Daymark-specific adaptations must be explicit adaptations rather than being presented as canonical Bullet Journal rules.

## Current method shape

Daymark deliberately avoids turning Bullet Journal concepts into a generic planner.

- **Today / Daily Log** captures Task, Event, and Note entries for the current method date. Earlier Daily Logs can be browsed read-only without creating missing historical Logs merely by viewing a date.
- **Daily Reflection** is contextual inside Today. It isolates unresolved Tasks so the user deliberately decides whether each one is completed, migrated, scheduled, or discarded.
- **Monthly Log** keeps the current month interactive, with a dated Calendar section and separate Tasks section, while earlier months remain read-only.
- **Future Log** is a rolling overview of six future month buckets beginning with the month after the current month. It is month-addressed, not a second day-level calendar.
- **Collections** are simple method-native topic/project containers. They can own Task, Event, and Note entries without becoming configurable workspaces or dashboards.
- **Scheduling (`<`)** is available for open Tasks in Today and Monthly. The source remains in history as scheduled and a fresh open Task is created in the selected Future month with lineage preserved.
- **Forward migration (`>`)** is available for open Tasks in Today and Monthly Tasks into an explicitly selected existing Collection. The historical source becomes migrated and the Collection receives a fresh open Task with lineage.
- **Collection references** let an entry remain in its original location while also appearing in a Collection. Removing the reference does not delete or mutate the source Entry.
- **Index** is a deliberate ordered list of existing Logs and Collections. Items can be reordered or removed without changing the structures themselves, and selecting an item navigates to its real source.
- **Search** is an explicit local, read-only query over existing Entry content. Results preserve source identity/state, refresh when the retained Search section becomes active, and navigate to the actual Daily, Monthly, Future, or Collection owner.
- **Trackers** are an optional finite Daymark adaptation, not a canonical Bullet Journal requirement. They store deliberate daily `+1 / -1` marks, interpret absence as `0` only inside the Tracker's effective period, and remain separate from Tasks and Entry ownership.
- **Backup / Restore** is the protected recovery and migration boundary. Backups remain encrypted and authenticated and are portable across supported devices when the user has the portable credential.
- **Open Export** is a separate explicit plaintext portability boundary. JSON and Markdown exports are not protected by Daymark encryption and are not a restore format.

The accelerated post-alpha.2 plan is complete. No next feature slice is implied by that completion. Device-assisted/biometric unlock remains deferred, and release preparation begins only after a separate explicit product decision.

## Interface direction

Daymark uses Material 3 as a technical foundation, not as a stock visual identity.

The current presentation baseline includes:

- a small shared Daymark design-token layer for control radii, heights, spacing, page breakpoints, and bounded content width;
- responsive page framing with compact Android margins and centered bounded desktop content;
- consistent typography, controls, selected navigation states, dialogs, menus, and Tracker affordances;
- adaptive navigation: Today, Monthly, Future, and Collections remain directly available on compact layouts, while Search and Index live under More; expanded desktop layouts expose all six destinations;
- application branding on Linux and Android;
- quiet empty states and restrained feedback that do not cover Rapid Logging controls;
- keyboard/focus behavior designed for Linux without compromising Android touch behavior;
- accessibility semantics for journal entry type/state and Tracker selection state.

The visual rule remains digital minimalism: journal content gets the visual weight. Daymark intentionally avoids decorative notebook hardware, gamified progress signals, dashboard chrome, and freeform canvas/page editing.

## Technology direction

The reviewed baseline is documented in [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md), with the relational persistence contract in [`docs/DATA_MODEL.md`](docs/DATA_MODEL.md) and the current security contract in [`SECURITY.md`](SECURITY.md). [`docs/SECURITY_FOUNDATION.md`](docs/SECURITY_FOUNDATION.md) preserves the historical validation record for the security-foundation PR #7.

At a glance:

- Flutter 3.47.2 / Dart 3.13.2;
- Material 3 with a restrained custom Daymark presentation layer;
- Riverpod for state/dependency wiring;
- go_router for application routing;
- Drift for typed relational persistence and tested schema evolution;
- sqlite3 with SQLite3MultipleCiphers for encrypted native storage;
- `cryptography` 2.9.0 with Argon2id + XChaCha20-Poly1305 for the portable application key hierarchy;
- Flutter ARB / `gen_l10n` localization.

English is the canonical and fallback UI locale. An exact Brazilian Portuguese system locale selects Portuguese (Brazil); unsupported locales fall back to English.

The exact resolved dependency set is committed in `pubspec.lock` and changes only through reviewed dependency updates.

## Initial v1 scope

The first stable product milestone is expected to cover:

- Rapid Logging;
- Daily Log;
- Monthly Log;
- Future Log;
- deliberate Migration;
- Collections;
- Index;
- Search;
- master-password protection and locking;
- encrypted portable backup/restore;
- explicit open export formats;
- English and Portuguese (Brazil);
- light, dark, and system appearance.

Optional Trackers are a Daymark adaptation layered on top of that method core.

Cloud sync, collaboration, AI features inside the product, gamification, dashboards, unrelated productivity systems, and freeform page/canvas editing are outside the initial scope.

## Development workflow

Development uses one permanent integration branch (`main`), short-lived task branches, pull requests, squash merges by default, and explicit release gates.

See [`docs/WORKFLOW.md`](docs/WORKFLOW.md).

AI-assisted work follows a staged validation ladder: trustworthy baseline, the fastest trustworthy feedback path, layer-correct focused tests, complete local validation and manual platform validation when needed, documentation alignment, full non-Draft CI / `merge-gate` when required, and explicit user merge approval.

The public release train progresses deliberately through:

```text
v1.0.0-alpha.N
v1.0.0-beta.N
v1.0.0-rc.N
v1.0.0
```

Prereleases are not promoted automatically. Stable `1.0.0` happens only after deliberate testing and approval.

## Documentation map

- [`PROJECT.md`](PROJECT.md): canonical live checkpoint, published release evidence, compatibility boundaries, blockers, and next steps
- [`AGENTS.md`](AGENTS.md): mandatory operating contract and failure-prevention rules for AI-assisted development
- [`docs/PRODUCT.md`](docs/PRODUCT.md): product boundaries and principles
- [`docs/DOMAIN.md`](docs/DOMAIN.md): Bullet Journal semantics
- [`docs/DATA_MODEL.md`](docs/DATA_MODEL.md): relational schema, persistence invariants, and migration policy
- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md): technical architecture and technology baseline
- [`docs/TRACKERS.md`](docs/TRACKERS.md): provenance, method-fidelity boundary, and behavior of the optional Tracker adaptation
- [`SECURITY.md`](SECURITY.md): current threat model, supported prerelease line, and security constraints
- [`docs/SECURITY_FOUNDATION.md`](docs/SECURITY_FOUNDATION.md): historical PR #7 security-foundation validation record
- [`docs/ARGON2_BENCHMARK.md`](docs/ARGON2_BENCHMARK.md): Linux/Android KDF benchmark procedure and evidence
- [`docs/BACKUP_FORMAT.md`](docs/BACKUP_FORMAT.md): portable authenticated encrypted backup format and restore safety contract
- [`docs/OPEN_EXPORT_FORMAT.md`](docs/OPEN_EXPORT_FORMAT.md): plaintext JSON/Markdown portability contract
- [`docs/RELEASE.md`](docs/RELEASE.md): Linux/Android packaging, signing, and release verification procedure
- [`docs/WORKFLOW.md`](docs/WORKFLOW.md): branches, PRs, validation, versioning, and releases
- [`docs/LOCAL_ENVIRONMENT.md`](docs/LOCAL_ENVIRONMENT.md): primary local validation-host record
- [`docs/LOCAL_EXECUTION.md`](docs/LOCAL_EXECUTION.md): safe terminal-block contract for user-assisted local validation
- [`docs/PERFORMANCE_BENCHMARK.md`](docs/PERFORMANCE_BENCHMARK.md): measured local build/test baseline and tuning protocol
- [`CONTRIBUTING.md`](CONTRIBUTING.md): contribution expectations and local-validation safety rules
- [`CHANGELOG.md`](CHANGELOG.md): release-facing history

## License

Daymark is distributed under the GNU General Public License v3.0 or later (`GPL-3.0-or-later`).