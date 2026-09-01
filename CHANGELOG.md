# Changelog

All notable release-facing changes to Daymark will be documented in this file.

This file is for user-visible behavior, data compatibility, security, packaging, and contributor-facing release changes. Development continuity and session handoff belong in `PROJECT.md`.

## Unreleased

### Added

- Initial project foundation and pre-development documentation.
- Initial Flutter application scaffold for Linux and Android, including localization, adaptive navigation, light/dark/system theme foundations, static analysis, tests, and native build validation.

### Changed

- English is the canonical and fallback UI locale; an exact Brazilian Portuguese system locale selects Portuguese (Brazil).
- Device-assisted secure-storage integration is deferred to the focused security implementation instead of being forced into the general scaffold.

### Fixed

- Nothing released yet.

### Security

- Encryption at rest, master-password key hierarchy, lock behavior, and encrypted portable backup are defined as baseline requirements before journal persistence is implemented.
