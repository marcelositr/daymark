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
- User-facing encrypted backup creation and restore, with native file selection, password verification, locked/empty-state restore, and post-restore reopening only from committed validated files.
- Explicit Open Export to deterministic versioned JSON and human-readable Markdown, preserving stable IDs, ownership, states, relationships, and Unicode.
- Device-local Appearance selection with System, Light, and Dark modes, applied immediately and persisted independently of the encrypted journal.
- Semantic journal application services for capture, migration, scheduling, and collection references.
- Encrypted journal creation, unlock, and explicit manual lock flow.
- Functional Today/Daily Log with Rapid Logging for Task, Event, and Note entries.
- Read-only historical Daily browsing through a genuine date-addressed route, with no creation of missing historical Logs and no historical capture or Task actions.
- Automatic Today date rollover at midnight and refresh when the application resumes.
- Automatic journal lock after five minutes without journal interaction, with pointer/touch, hardware-keyboard, and text-edit activity resetting the deadline and background time continuing to count.
- Deliberate completion and discard actions for open Tasks in the Today/Daily Log flow.
- Current-month Monthly Log with Calendar and Tasks sections, dated Event capture, Monthly Task capture, and deliberate complete/discard actions.
- Read-only historical Monthly browsing, with month-by-month backward navigation, no future-Monthly navigation, and no creation of empty historical Logs merely by viewing a month.
- Rolling six-month Future Log, beginning with the month after the current month, with Task/Event/Note Rapid Logging and deliberate Future Task complete/discard actions.
- Deliberate scheduling (`<`) for open Tasks in Today and Monthly into one of the six real Future Log month buckets, preserving source history and creating a fresh open destination Task with movement lineage.
- Basic Collections surface for creating and opening method-native Collections, Rapid Logging Task/Event/Note entries, and completing or discarding Collection Tasks.
- Deliberate forward migration (`>`) for open Tasks in Today and Monthly Tasks into an existing Collection, preserving the historical source and creating a fresh open destination Task with lineage.
- Deliberate Collection references from Today, Monthly, and Future entries into an existing Collection without changing source ownership, entry identity, or Task state; references appear separately and read-only in the Collection.
- Basic deliberate Index of existing Daily, Monthly, and Future Logs and Collections, preserving user-chosen Index order without duplicating journal content or deriving persistent items from Search.
- Basic local Search over existing Entry content, showing read-only Daily, Monthly, Future, or Collection ownership context without creating Search history, duplicate content, references, or Index items.

### Changed

- English is the canonical and fallback UI locale; an exact Brazilian Portuguese system locale selects Portuguese (Brazil).
- Device-assisted secure-storage integration is deferred until the portable master-password/recovery security baseline is complete.
- Android OS-managed app-data backup and device-transfer paths are explicitly excluded; portable migration is reserved for Daymark's encrypted backup/restore design.
- Encrypted restore is available only while the journal is locked or absent, preventing replacement of files beneath a live encrypted database session.
- The native file-selection dependency is pinned to `file_picker 12.1.3` for Linux/Android compatibility with Daymark's current Flutter and AGP 9 toolchain.
- Journal access now remains behind one stable router/application root instead of replacing the root application when lock state changes.
- Journal operations and session closing are serialized so manual or automatic lock does not close encrypted persistence underneath an in-flight journal operation.
- Master-password creation and unlock reject an empty password before cryptographic work begins.
- Portuguese parent localization resources include the journal-access, Daily Log, Monthly Log, Future Log, Collection, migration, reference, Index, and Search strings used by the Brazilian Portuguese locale.
- Compact navigation keeps four core journal destinations directly visible and groups Search and Index under a minimal More sheet, while expanded desktop navigation exposes both directly.
- Human and AI contributors follow a staged validation workflow that prefers the fastest trustworthy feedback path: pinned local-first generation/formatting/analysis/tests/builds when explicitly agreed, Draft CI when remote evidence is useful, then full exact-head non-Draft CI / `merge-gate` and explicit user merge approval.
- AI handoff guidance now records concrete failure-prevention rules for localization generation, pinned formatting, widget-test diagnosis, safe interactive-shell command blocks, temporary CI probes, SHA-specific validation evidence, retained-navigation refresh behavior, and local-first execution without transferring debugging responsibility to the user.
- Returning from application background re-evaluates the inactivity deadline immediately instead of trusting a platform timer to have continued firing while suspended.
- Task terminal actions preserve the original journal entry and change only its Task state, keeping journal history visible.
- Future Log is explicitly month-addressed rather than a second day-level calendar, preserving the method-native distinction between Monthly and Future surfaces.
- Forward migration (`>`) uses an explicitly selected existing Collection as its first exposed non-Future destination; the current Monthly Log remains intentionally unavailable as a shortcut destination, while Collection references use the same source Entry rather than movement lineage.
- Historical Daily and Monthly Logs are retrieval-only: capture and Task actions remain available only in the current Daily Log/current month.

### Fixed

- Replaced the first Today regression-test approach, which mixed real filesystem/cryptographic I/O into a Flutter widget test, with an isolated in-memory presentation boundary.
- Unexpected journal-access and capture failures retain diagnostic stack information without logging passwords, journal contents, or raw exception messages.
- Mobile text editing explicitly counts as journal activity even when an input method does not emit Flutter hardware-key events.
- Focused Future Log persistence rejects non-Future owners before capture, preventing an incorrect caller from silently writing through the wrong product boundary.
- Retained Future navigation now reloads its month snapshots when the Future section becomes active, so Tasks scheduled from Today or Monthly appear immediately without requiring lock, restart, or screen remount.
- Retained Collections navigation now reloads its list, owned entries, and references when the section becomes active, so migrations or references created from another retained section appear without requiring lock, restart, or screen remount.
- Retained Search reruns the last submitted query when its section becomes active, so result Task state reflects changes made elsewhere without polling or persisting Search history.
- Search case-insensitive matching now handles Unicode case changes such as `RÁDIO` and `rádio` while keeping accents literal.
- A completed retained Search refresh can no longer overwrite the result of a newer explicitly submitted query.

### Security

- Journal persistence uses SQLite3MultipleCiphers ChaCha20-Poly1305 with random per-journal key material instead of plaintext SQLite.
- Master passwords protect the random journal key through Argon2id and XChaCha20-Poly1305 rather than being used directly as database passwords.
- Key-envelope and encrypted-database tests cover wrong credentials, corrupted authenticated data, incorrect database keys, unkeyed SQLite access, and representative plaintext leakage.
- Representative Linux and physical Android profile-mode benchmarks were recorded for Argon2id parameter selection.
- The initial Argon2id production baseline is frozen at 19 MiB memory, 2 iterations, parallelism 1, and 32-byte output; parameters remain explicit in each key envelope for future strengthening and compatibility handling.
- Unlocked journal sessions own the encrypted database and mutable journal-key material; closing the session closes persistence before key destruction.
- Open Export is an explicit plaintext security boundary: exported JSON and Markdown are not encrypted and are deliberately distinct from Daymark encrypted backup.
- The inactivity guard fails closed if the wall clock moves backwards relative to the last recorded journal interaction.
