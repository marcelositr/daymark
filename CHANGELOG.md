# Changelog

All notable release-facing changes to Daymark will be documented in this file.

This file is for user-visible behavior, data compatibility, security, packaging, and contributor-facing release changes. Development continuity and session handoff belong in `PROJECT.md`.

## Unreleased

### Added

- Initial project foundation and pre-development documentation.
- Initial Flutter application scaffold for Linux and Android, including localization, adaptive navigation, light/dark/system theme foundations, static analysis, tests, and native build validation.
- Relational Drift schema v1 with migration/invariant validation for the core Bullet Journal data model.
- Pre-alpha master-password key-envelope and encrypted-journal persistence foundation.

### Changed

- English is the canonical and fallback UI locale; an exact Brazilian Portuguese system locale selects Portuguese (Brazil).
- Device-assisted secure-storage integration is deferred until the portable master-password/recovery security baseline is complete.

### Fixed

- Nothing released yet.

### Security

- Journal persistence uses SQLite3MultipleCiphers ChaCha20-Poly1305 with random per-journal key material instead of plaintext SQLite.
- Master passwords protect the random journal key through Argon2id and XChaCha20-Poly1305 rather than being used directly as database passwords.
- Key-envelope and encrypted-database tests cover wrong credentials, corrupted authenticated data, incorrect database keys, unkeyed SQLite access, and representative plaintext leakage.
- Argon2id production parameters remain intentionally unfrozen until representative Linux and physical Android profile-mode benchmarks are reviewed.
