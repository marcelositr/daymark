# Daymark

Daymark is a minimal, local-first Bullet Journal application for Linux and Android, designed to stay faithful to the original method while removing digital clutter.

> The interface should disappear during use. The journal, reflection, and decisions come first.

## Project status

Daymark is in **alpha development**.

The first controlled distributable prerelease, [`v1.0.0-alpha.2`](https://github.com/marcelositr/daymark/releases/tag/v1.0.0-alpha.2), was published on 2026-09-04 for Linux x64 and Android. It is prerelease software, not a stable `1.0.0` release.

The current product line includes:

- encrypted journal creation, unlock, manual lock, and automatic inactivity lock;
- Today / Daily Log with Rapid Logging for Task, Event, and Note plus read-only historical Daily browsing;
- deliberate Task completion and discard;
- a Monthly Log with a fully interactive current month plus read-only historical month browsing;
- a rolling six-month Future Log;
- deliberate scheduling of open Tasks from Today and Monthly into real Future Log month buckets, preserving historical source state and movement lineage;
- basic Collections with owned Task, Event, and Note entries;
- deliberate forward migration (`>`) of open Tasks from Today and Monthly Tasks into an explicitly selected existing Collection;
- deliberate Collection references from chronological entries without moving the source or changing Task state;
- a deliberate basic Index of existing Logs and Collections, preserving user-chosen Index order;
- basic local Search across existing Entry content, with read-only owner context and no Search-to-Index side effect;
- user-facing portable authenticated encrypted Backup / Restore;
- explicit plaintext Open Export to deterministic JSON and human-readable Markdown;
- device-local System / Light / Dark appearance selection;
- Linux and Android release packaging with dedicated Android release signing that fails closed if signing configuration is missing.

The pinned toolchain is Flutter 3.47.2 with Dart 3.13.2, targeting Linux and Android.

The canonical live development checkpoint is [`PROJECT.md`](PROJECT.md). It records the latest published release checkpoint, compatibility boundaries, validation evidence, open work, and next intended decision.

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

## Current method shape

Daymark deliberately avoids turning Bullet Journal concepts into a generic planner.

- **Today / Daily Log** captures Task, Event, and Note entries for the current method date. Earlier Daily Logs can be browsed read-only without creating missing historical Logs merely by viewing a date; historical Daily entries expose no capture or Task actions.
- **Monthly Log** keeps the current month fully interactive, with a dated Calendar section and separate Tasks section, while earlier months can be browsed read-only without creating empty historical Logs merely by navigating.
- **Future Log** is a rolling overview of six future month buckets beginning with the month after the current month. It is month-addressed, not a second day-level calendar.
- **Collections** are simple method-native topic/project containers. They can own Task, Event, and Note entries without becoming configurable workspaces or dashboards.
- **Scheduling (`<`)** is available for open Tasks in Today and Monthly. The source remains in history as scheduled and a fresh open Task is created in the selected Future month with lineage preserved.
- **Forward migration (`>`)** is available for open Tasks in Today and Monthly Tasks into an explicitly selected existing Collection. The historical source becomes migrated and the Collection receives a fresh open Task with lineage.
- **Collection references** let a Today, Monthly, or Future entry remain in its original location while also appearing in a Collection. The same Entry identity and Task state are preserved, and the reference is read-only from the Collection surface.
- **Index** is a deliberate ordered list of existing Logs and Collections. Adding a structure to the Index does not duplicate its content, change ownership, or derive persistent items from Search results.
- **Search** is an explicit local, read-only query over existing Entry content. Results keep the original Entry identity/state and show whether the source belongs to Daily, Monthly, Future, or a Collection; Search does not create Entries, references, or Index items.
- **Backup / Restore** is the protected recovery and migration boundary. Backups remain encrypted and authenticated and are portable across supported devices when the user has the portable credential.
- **Open Export** is a separate explicit plaintext portability boundary. JSON and Markdown exports are not protected by Daymark encryption and are not a restore format.

Richer reflection flows, direct retrieval navigation from Index/Search, reference removal, Index reorder/remove, OS-level immediate-lock integration, and device-assisted unlock remain later focused work. No next alpha feature slice is selected merely because `alpha.2` is published.

## Technology direction

The reviewed baseline is documented in [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md), with the relational persistence contract in [`docs/DATA_MODEL.md`](docs/DATA_MODEL.md) and the current security contract in [`SECURITY.md`](SECURITY.md). [`docs/SECURITY_FOUNDATION.md`](docs/SECURITY_FOUNDATION.md) preserves the historical validation record for the security-foundation PR #7.

At a glance:

- Flutter 3.47.2 / Dart 3.13.2;
- Material 3 with a custom minimal dotted-notebook visual language;
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

Cloud sync, collaboration, AI features inside the product, gamification, dashboards, unrelated productivity systems, and freeform page/canvas editing are outside the initial scope.

## Development workflow

Development uses one permanent integration branch (`main`), short-lived task branches, pull requests, squash merges by default, and explicit release gates.

See [`docs/WORKFLOW.md`](docs/WORKFLOW.md).

AI-assisted work follows a staged validation ladder: trustworthy baseline, the fastest trustworthy feedback path, layer-correct focused tests, complete local validation and manual platform validation when needed, documentation alignment, full non-Draft CI / `merge-gate`, and explicit user merge approval.

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
