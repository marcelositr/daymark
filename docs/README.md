# Daymark developer documentation

This directory is the canonical technical documentation for Daymark.

The documentation is intentionally compact. Git history and pull requests preserve implementation history; these files describe the current product and the contracts that future work must preserve.

## Start here

- [`PROJECT.md`](PROJECT.md) — current scope, supported platforms, release state, and project boundaries
- [`ARCHITECTURE.md`](ARCHITECTURE.md) — application structure and runtime responsibilities
- [`DOMAIN.md`](DOMAIN.md) — Bullet Journal semantics and Daymark-specific behavior
- [`DATA_MODEL.md`](DATA_MODEL.md) — persistent schema and data invariants
- [`SECURITY.md`](SECURITY.md) — threat model, encryption, session locking, and fail-closed behavior
- [`DEVELOPMENT.md`](DEVELOPMENT.md) — local development, tests, generated files, CI, and repository workflow
- [`RELEASE.md`](RELEASE.md) — Linux and Android release process and signing constraints
- [`BACKUP_FORMAT.md`](BACKUP_FORMAT.md) — encrypted backup container contract
- [`OPEN_EXPORT_FORMAT.md`](OPEN_EXPORT_FORMAT.md) — plaintext portability format contract
- [`CONTRIBUTING.md`](CONTRIBUTING.md) — contribution expectations
- [`CHANGELOG.md`](CHANGELOG.md) — release-facing history
- [`AI.md`](AI.md) — concise operating instructions for AI-assisted development

## Source-of-truth rule

When documentation and implementation disagree, inspect the implementation and tests before changing behavior.

Primary implementation sources:

| Concern | Source |
| --- | --- |
| Product behavior | `lib/features/journal/` and tests |
| Domain vocabulary | `lib/features/journal/domain/journal_domain.dart` |
| Persistence schema | `lib/core/database/daymark.drift` |
| Schema migrations | `lib/core/database/daymark_database.dart`, `drift_schemas/` |
| Encryption | `lib/core/crypto/`, `lib/core/database/encrypted_daymark_database.dart` |
| Session and lock policy | `lib/core/session/`, journal guards, native runners |
| Backup / Restore | `lib/core/backup/encrypted_backup_service.dart` |
| Open Export | `lib/core/export/open_export_service.dart` |
| Navigation | `lib/app/router.dart`, `lib/presentation/app_shell.dart` |
| Linux packaging | `tool/package_linux.sh`, `linux/packaging/` |
| Android packaging/signing | `android/` |
| CI | `.github/workflows/ci.yml` |
| User documentation | `wiki/` |
| Application version | `pubspec.yaml` |

Do not duplicate these contracts across multiple documents unless a short cross-reference improves navigation.
