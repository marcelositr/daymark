# Changelog

All notable release-facing changes to Daymark will be documented in this file.

This file is for user-visible behavior, data compatibility, security, packaging, and contributor-facing release changes. Development continuity and session handoff belong in `PROJECT.md`.

## Unreleased

### Added

- Initial project foundation and pre-development documentation.
- Initial Flutter application scaffold for Linux and Android, including localization, adaptive navigation, light/dark/system theme foundations, static analysis, tests, and native build validation.
- Relational Drift schema v1 with migration/invariant validation for the core Bullet Journal data model.
- Pre-alpha master-password key-envelope and encrypted-journal persistence foundation.
- Authenticated portable encrypted backup and rollback-safe restore with crash-recovery validation.
- Journal repository/application services that enforce cross-table Bullet Journal semantics for ownership, Collections, migration, scheduling, and lineage.
- First usable journal flow: create or unlock the encrypted local journal, manually lock the active session, open Today's Daily Log, and Rapid Log Tasks, Events, and Notes.

### Changed

- English is the canonical and fallback UI locale; an exact Brazilian Portuguese system locale selects Portuguese (Brazil).
- Device-assisted secure-storage integration is deferred until the portable master-password/recovery security baseline is complete.
- Android OS-managed app-data backup and device-transfer paths are explicitly excluded; portable migration is reserved for Daymark's encrypted backup/restore design.
- Unlocked database, journal key, repository, and application-service lifetime is now owned by an explicit journal session instead of being left for presentation code to coordinate.

### Fixed

- Nothing released yet.

### Security

- Journal persistence uses SQLite3MultipleCiphers ChaCha20-Poly1305 with random per-journal key material instead of plaintext SQLite.
- Master passwords protect the random journal key through Argon2id and XChaCha20-Poly1305 rather than being used directly as database passwords.
- Key-envelope and encrypted-database tests cover wrong credentials, corrupted authenticated data, incorrect database keys, unkeyed SQLite access, and representative plaintext leakage.
- Representative Linux and physical Android profile-mode benchmarks were recorded for Argon2id parameter selection.
- The initial Argon2id production baseline is frozen at 19 MiB memory, 2 iterations, parallelism 1, and 32-byte output; parameters remain explicit in each key envelope for future strengthening and compatibility handling.
- Incomplete local database/key-envelope pairs fail closed and are not silently repaired or overwritten by the create/unlock flow.
- Manual lock closes encrypted persistence before destroying the application's mutable journal-key owner.
