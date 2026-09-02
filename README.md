# Daymark

Daymark is a minimal, local-first Bullet Journal application for Linux and Android, designed to stay faithful to the original method while removing digital clutter.

> The interface should disappear during use. The journal, reflection, and decisions come first.

## Project status

Daymark is in foundation / pre-alpha development. The product, domain, security, data, workflow, and toolchain constraints are established before journal features become the main development focus.

The Flutter scaffold and relational schema v1 are integrated on `main`. The current development cycle is PR #7, which is validating the master-password key hierarchy and encrypted journal persistence. The pinned toolchain is Flutter 3.47.2 with Dart 3.13.2, targeting Linux and Android.

PR #7 has an implemented and tested pre-alpha security baseline using Argon2id + XChaCha20-Poly1305 for portable journal-key protection and SQLite3MultipleCiphers ChaCha20-Poly1305 for encrypted journal storage. Representative Linux and physical Android profile-mode measurements are recorded, and the initial Argon2id production baseline is frozen at 19 MiB memory, 2 iterations, parallelism 1, and 32-byte output. Android OS-managed app-data backup/device transfer is explicitly excluded so portable migration remains an intentional Daymark encrypted-backup boundary.

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

The current reviewed baseline is documented in [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md), with the relational persistence contract in [`docs/DATA_MODEL.md`](docs/DATA_MODEL.md) and the active security validation contract in [`docs/SECURITY_FOUNDATION.md`](docs/SECURITY_FOUNDATION.md).

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
- [`docs/DATA_MODEL.md`](docs/DATA_MODEL.md): relational schema, persistence invariants, and migration policy
- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md): technical architecture and technology baseline
- [`SECURITY.md`](SECURITY.md): threat model and security constraints
- [`docs/SECURITY_FOUNDATION.md`](docs/SECURITY_FOUNDATION.md): current security implementation/validation contract
- [`docs/ARGON2_BENCHMARK.md`](docs/ARGON2_BENCHMARK.md): Linux/Android KDF benchmark procedure, evidence, and initial parameter decision
- [`docs/WORKFLOW.md`](docs/WORKFLOW.md): branches, PRs, versioning, and releases
- [`CONTRIBUTING.md`](CONTRIBUTING.md): contribution expectations
- [`CHANGELOG.md`](CHANGELOG.md): release-facing history

## License

Daymark is distributed under the GNU General Public License v3.0 or later (`GPL-3.0-or-later`).
