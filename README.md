# Daymark

Daymark is a minimal, local-first Bullet Journal application for Linux and Android, designed to stay faithful to the original method while removing digital clutter.

> The interface should disappear during use. The journal, reflection, and decisions come first.

## Project status

Daymark is in foundation / pre-alpha development. The product, domain, security, data, workflow, and toolchain constraints are being established before journal features are implemented.

The first Flutter scaffold is currently under review in PR #3. The pinned toolchain is Flutter 3.47.2 with Dart 3.13.2, targeting Linux and Android.

The canonical live development checkpoint is [`PROJECT.md`](PROJECT.md).

Any human or AI contributor should read [`AGENTS.md`](AGENTS.md) before continuing work. The repository is designed so development can be resumed across chat limits, CLI restarts, API quotas, and different agents without depending on hidden conversation context.

## Product principles

- Faithful to the core Bullet Journal method.
- Digital minimalism by default.
- Local-first and offline-first.
- Encryption at rest from the first persisted journal.
- Linux and Android are the initial supported platforms.
- Architecture remains portable to future desktop and mobile targets.
- Open, exportable user data.
- No advertising, engagement loops, streaks, productivity scoring, or attention-seeking UI.
- Automation must not remove deliberate reflection or migration decisions from the method.

## Technology direction

The current reviewed baseline is documented in [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md).

At a glance:

- Flutter 3.47.2 / Dart 3.13.2;
- Material 3 with a custom minimal dotted-notebook visual language;
- Riverpod for state/dependency wiring;
- go_router for application routing;
- Drift for typed relational persistence;
- sqlite3 with SQLite3MultipleCiphers for encrypted native storage;
- Argon2id and reviewed authenticated cryptography for the application key hierarchy;
- Flutter ARB / `gen_l10n` localization.

English is the canonical and fallback UI locale. An exact Brazilian Portuguese system locale selects Portuguese (Brazil); unsupported locales fall back to English.

Exact dependency versions are locked in `pubspec.lock` once the scaffold bootstrap completes and are changed only through reviewed updates.

## Initial scope

The first product milestone is expected to cover:

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

The first public release train progresses deliberately through:

```text
v1.0.0-alpha.N
v1.0.0-beta.N
v1.0.0-rc.N
v1.0.0
```

Release candidates are not promoted automatically. Stable `1.0.0` happens only after deliberate testing and approval.

## Documentation map

- [`PROJECT.md`](PROJECT.md): live checklist, current state, blockers, next steps, and handoff log
- [`AGENTS.md`](AGENTS.md): mandatory operating contract for AI-assisted development
- [`docs/PRODUCT.md`](docs/PRODUCT.md): product boundaries and principles
- [`docs/DOMAIN.md`](docs/DOMAIN.md): Bullet Journal semantics
- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md): technical architecture and technology baseline
- [`SECURITY.md`](SECURITY.md): threat model and security constraints
- [`docs/WORKFLOW.md`](docs/WORKFLOW.md): branches, PRs, versioning, and releases
- [`CONTRIBUTING.md`](CONTRIBUTING.md): contribution expectations
- [`CHANGELOG.md`](CHANGELOG.md): release-facing history

## License

Daymark is distributed under the GNU General Public License v3.0 or later (`GPL-3.0-or-later`).
