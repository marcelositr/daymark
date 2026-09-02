# Changelog

All notable release-facing changes to Daymark will be documented in this file.

This file is for user-visible behavior, data compatibility, security, packaging, and contributor-facing release changes. Development continuity and session handoff belong in `PROJECT.md`.

## Unreleased

### Added

- Initial project foundation and pre-development documentation.
- Initial Flutter application scaffold for Linux and Android, including localization, adaptive navigation, light/dark/system theme foundations, static analysis, tests, and native build validation.
- Relational Drift schema v1 with migration/invariant validation for the core Bullet Journal data model.
- Pre-alpha master-password key-envelope and encrypted-journal persistence foundation.
- Portable authenticated encrypted backup/restore foundation with rollback-safe recovery behavior.
- Semantic journal application services for capture, migration, scheduling, and collection references.
- Encrypted journal creation, unlock, and explicit manual lock flow.
- Functional Today/Daily Log with Rapid Logging for Task, Event, and Note entries.
- Automatic Today date rollover at midnight and refresh when the application resumes.

### Changed

- English is the canonical and fallback UI locale; an exact Brazilian Portuguese system locale selects Portuguese (Brazil).
- Device-assisted secure-storage integration is deferred until the portable master-password/recovery security baseline is complete.
- Android OS-managed app-data backup and device-transfer paths are explicitly excluded; portable migration is reserved for Daymark's encrypted backup/restore design.
- Journal access now remains behind one stable router/application root instead of replacing the root application when lock state changes.
- Journal operations and session closing are serialized so manual lock does not close encrypted persistence underneath an in-flight journal operation.
- Master-password creation and unlock reject an empty password before cryptographic work begins.
- Portuguese parent localization resources include the journal-access and Daily Log strings used by the Brazilian Portuguese locale.
- Human and AI contributors now follow a staged validation workflow: baseline/audit, Draft CI, layer-correct tests, progressive local/manual validation, documentation alignment, full merge CI, and explicit user merge approval.

### Fixed

- Replaced the first Today regression-test approach, which mixed real filesystem/cryptographic I/O into a Flutter widget test, with an isolated in-memory presentation boundary.
- Unexpected journal-access and capture failures retain diagnostic stack information without logging passwords, journal contents, or raw exception messages.

### Security

- Journal persistence uses SQLite3MultipleCiphers ChaCha20-Poly1305 with random per-journal key material instead of plaintext SQLite.
- Master passwords protect the random journal key through Argon2id and XChaCha20-Poly1305 rather than being used directly as database passwords.
- Key-envelope and encrypted-database tests cover wrong credentials, corrupted authenticated data, incorrect database keys, unkeyed SQLite access, and representative plaintext leakage.
- Representative Linux and physical Android profile-mode benchmarks were recorded for Argon2id parameter selection.
- The initial Argon2id production baseline is frozen at 19 MiB memory, 2 iterations, parallelism 1, and 32-byte output; parameters remain explicit in each key envelope for future strengthening and compatibility handling.
- Unlocked journal sessions own the encrypted database and mutable journal-key material; closing the session closes persistence before key destruction.
