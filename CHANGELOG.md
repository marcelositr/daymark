# Changelog

All notable release-facing changes to Daymark are documented in this file.

This file is for user-visible behavior, data compatibility, security, packaging, and contributor-facing release changes. Development continuity and session handoff belong in `PROJECT.md`.

## Unreleased

### Fixed

- Linux Debian and AppImage packages install the canonical Daymark application icon through standard desktop icon locations, including scalable SVG and conventional fallbacks.
- AppImage carries the canonical root application icon and `.DirIcon`.
- Android CI regenerates launcher resources from the canonical Daymark branding asset and rejects stale committed launcher icons.

### Compatibility

- Application version advances to `1.0.0-beta.2+5`.
- Database schema remains v2 with no beta.2 migration.
- Android preserves the signing lineage established by alpha.3 and retained by beta.1.
- Beta.2 remains an icon-integration maintenance release with no product capability changes.

## [1.0.0-beta.1] - 2026-09-06

### Changed

- Prerelease packaging candidate advances to `1.0.0-beta.1+4`.
- Beta.1 is a stability promotion of the feature-complete alpha.3 product line; functional scope remains frozen and no feature expansion is included.
- Linux distribution replaces the raw `.tar.gz` bundle with installable Debian (`.deb`) and portable AppImage packages, both built from the same Flutter release bundle.
- A version-controlled user Wiki documents the complete frozen product in Portuguese (Brazil); pull requests validate it and merges to `main` publish it automatically to GitHub Wiki.
- Spanish (`es`) joins English and Portuguese (Brazil) as the only supported product languages, following Spanish regional system locales without adding a manual language selector.

### Compatibility

- Schema remains v2 with no beta.1 database schema change.
- Android beta.1 is required to preserve the alpha.3 signing lineage and support direct install-over from published alpha.3 while retaining the existing journal and master-password unlock.
- Published alpha.2 -> alpha.3 portable encrypted Backup / clean-install / Restore compatibility remains documented and unchanged.

## [1.0.0-alpha.3] - 2026-09-06

Feature-complete Daymark prerelease consolidating the post-alpha.2 product line for Linux and Android.

### Added

- Search results and Index items navigate directly to their real Daily, Monthly, Future, or Collection source while preserving historical read-only behavior.
- Index items can be deliberately reordered or removed without changing underlying journal structures.
- Collection references can be removed without deleting or mutating the source Entry.
- Today includes contextual Daily Reflection for open Tasks with deliberate Complete, Migrate, Schedule, and Discard decisions.
- Fresh captures expose a narrow immediate Undo action without introducing general Edit/Delete behavior.
- Open Export can copy selected Markdown or JSON directly to the system clipboard.
- Optional finite Monthly Trackers add deliberate daily `+ / -` marking, a combined five-color `+1 / 0 / -1` reflection graph, early ending, historical read-only viewing, and compact active-Tracker controls in Today.
- Database schema v2 adds persisted Tracker periods and explicit `+1 / -1` marks with a tested additive migration from the published alpha.2 schema v1.
- Daymark ships dedicated application branding assets and launcher/application icons for Android and Linux.
- Journal entry type/state and Tracker selection expose explicit accessibility semantics instead of relying only on visual Bullet Journal marks or color.
- Daymark includes a localized About surface with application version, project identity, `devnux.com.br/daymark`, source repository, bug-reporting location, GPL-3.0-or-later license, author identity, existing branding, and Flutter open-source license disclosure.
- GitHub public support intake includes a structured Bug Report form, disables blank issues, warns users not to publish sensitive journal/security data, and routes vulnerability reports to the repository security policy.

### Changed

- Prerelease packaging advances to `1.0.0-alpha.3+3`.
- Linux keyboard focus and keyboard submission behavior are consistent across Today, Monthly, Future, Collections, and Search.
- Journal entry rows are the primary action target instead of requiring precise clicks on the Bullet Journal marker.
- Transient application feedback uses one in-layout Daymark notice channel that does not cover Rapid Logging controls.
- Open Export uses one format selector with Copy and Save actions rather than separate format-specific save buttons.
- Open Export advances to format version 2 and includes Tracker periods plus explicit Tracker marks while preserving published version-1 field meaning.
- Material 3 remains the technical base while Daymark applies a shared restrained visual control system for fields, buttons, menus, dialogs, navigation, and Tracker controls.
- Principal journal screens use one responsive bounded page frame: compact Android layouts use tighter margins while wide Linux windows center journal content instead of stretching reading lines across the full window.
- Typography hierarchy and selected navigation states are consistent across primary journal surfaces.
- Empty journal/search/history states use one quiet presentation treatment instead of scattered one-off text placement.
- Relevant selectors and post-action flows restore composer/search focus on Linux, reducing pointer round-trips without changing Android touch behavior.
- Daymark's functional scope is now explicitly **feature-complete and frozen**. Normal development after this release is limited to bugs, security, compatibility/migration, supported-platform/toolchain, packaging/release, accessibility/localization, and documentation maintenance.
- Feature Request intake is removed. Public Issues are for bugs; security vulnerabilities use the private/security-policy path.
- Linux and Android remain the supported product platforms, and English plus Portuguese (Brazil) remain the supported product languages. Additional platforms/languages are not roadmap items under the freeze.
- Device-assisted/biometric unlock, recovery-secret UX, cloud/accounts/network features, AI features, collaboration, richer planner/search/collection systems, automatic backup scheduling, attachments, dashboards, gamification, and freeform editing are explicitly not planned under the frozen scope.
- Android alpha.2 -> alpha.3 migration is performed through encrypted Backup / uninstall alpha.2 / clean-install alpha.3 / Restore because the alpha.2 private signing key was not recoverable during alpha.3 release preparation. Direct install-over between those two published lineages is not supported.
- Alpha.3 establishes a new dedicated Android signing lineage that must be preserved by later Android releases intended to install over alpha.3.

### Security

- Open Export requires master-password reauthentication before Daymark creates any plaintext representation.
- Reauthentication validates the existing authenticated key envelope with temporary key material that is destroyed immediately without replacing or reopening the live journal session.
- The Open Export warning explicitly covers both saved plaintext files and the system clipboard, including clipboard-manager retention risk.
- Android device non-interactive events and Linux systemd-logind session-lock signals request immediate Daymark lock through the same serialized journal-session path as manual and inactivity locking.
- The portable master-password model remains Daymark's unlock security model; device-assisted/biometric unlock is intentionally not planned rather than being left as unfinished release work.
- Android release signing continues to fail closed when local release-signing configuration is absent. The alpha.3 candidate uses one RSA-4096 signer with certificate SHA-256 `77bca227f0cd95eb9e3c5a2c24902ba9d20e296dbdba9fde87d024cd0febb311`; signing secrets remain local-only and outside Git.

### Compatibility

- Schema v1 from public `v1.0.0-alpha.2` migrates additively to schema v2 for Trackers.
- The supported alpha.2 -> alpha.3 Android transition is encrypted Backup / uninstall / clean install / Restore, not direct install-over, because the alpha.2 private signing key is unavailable.
- A retained alpha.2 encrypted backup restored successfully into a clean alpha.3 physical-Android installation and remained readable after force-stop/relaunch, validating the portable migration boundary and schema-v1-to-v2 path.
- Published key-envelope interpretation, 48-byte journal-key serialization, encrypted backup boundary, and Open Export versioning remain compatibility-sensitive.
- From alpha.3 onward, Android signing identity is also compatibility-sensitive for install-over upgrades and must preserve the alpha.3 certificate unless an explicit platform-supported signing migration is required and validated.

### Release validation

Validated alpha.3 candidate binaries were built from exact source head `e19ab982d2898cae223e396a1c2e4e26fc0446b0` before later documentation-only evidence commits.

- Linux x64 archive SHA-256: `bf11b1a9df952fdc3d4ce333490872a1b885dab2a56a56b6ff1062bd6b9d0189`.
- Signed Android APK SHA-256: `007f23c006282cb3eb9a7a2c62a97018631e36641d1539278436ba8d4ee41199`.
- Android release certificate SHA-256: `77bca227f0cd95eb9e3c5a2c24902ba9d20e296dbdba9fde87d024cd0febb311`.
- Retained alpha.2 encrypted backup used for physical migration validation SHA-256: `d6d6b7f94b869d95a61369ff675ba96dcc51633917995734e68dfac46628a23f`.
- Generated sources, formatter, analyzer, and full Flutter test suite passed on the binary build-source head.
- Linux release behavior was manually rechecked across the maintainer's full release checklist.
- The alpha.3 APK was verified with `apksigner` and installed successfully on physical Android hardware.
- The retained alpha.2 encrypted backup restored successfully into the clean alpha.3 installation; the restored journal remained usable after force-stop and relaunch.

## [1.0.0-alpha.2] - 2026-09-04

First controlled distributable Daymark prerelease for Linux and Android.

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

- Prerelease packaging advances to `1.0.0-alpha.2+2`; Linux and Android present the application name as `Daymark`.
- Android release builds require explicit local release signing and fail closed instead of silently using the debug key.
- Android release packaging refreshes generated plugin configuration before the `--no-pub` release build to avoid a stale development-only `integration_test` registrant.
- English is the canonical and fallback UI locale; an exact Brazilian Portuguese system locale selects Portuguese (Brazil).
- Device-assisted secure-storage integration was deferred at the alpha.2 historical checkpoint while the portable master-password/recovery security baseline was being established.
- Android OS-managed app-data backup and device-transfer paths are explicitly excluded; portable migration is reserved for Daymark's encrypted backup/restore design.
- Encrypted restore is available only while the journal is locked or absent, preventing replacement of files beneath a live encrypted database session.
- The native file-selection dependency is pinned to `file_picker 12.1.3` for Linux/Android compatibility with Daymark's current Flutter and AGP 9 toolchain.
- Journal access remains behind one stable router/application root instead of replacing the root application when lock state changes.
- Journal operations and session closing are serialized so manual or automatic lock does not close encrypted persistence underneath an in-flight journal operation.
- Master-password creation and unlock reject an empty password before cryptographic work begins.
- Portuguese parent localization resources include journal-access, Daily Log, Monthly Log, Future Log, Collection, migration, reference, Index, and Search strings used by the Brazilian Portuguese locale.
- Compact navigation keeps four core journal destinations directly visible and groups Search and Index under a minimal More sheet, while expanded desktop navigation exposes both directly.
- Human and AI contributors follow a staged validation workflow that prefers the fastest trustworthy feedback path: pinned local-first generation/formatting/analysis/tests/builds when explicitly agreed, Draft CI when remote evidence is useful, then full exact-head non-Draft CI / `merge-gate` and explicit maintainer merge approval.
- AI handoff guidance records failure-prevention rules for localization generation, pinned formatting, widget-test diagnosis, safe interactive-shell command blocks, temporary CI probes, SHA-specific evidence, retained-navigation refresh behavior, and local-first execution.
- Returning from application background re-evaluates the inactivity deadline immediately instead of trusting a platform timer to have continued firing while suspended.
- Task terminal actions preserve the original journal entry and change only its Task state, keeping journal history visible.
- Future Log is explicitly month-addressed rather than a second day-level calendar, preserving the method-native distinction between Monthly and Future surfaces.
- Forward migration (`>`) uses an explicitly selected existing Collection as its first exposed non-Future destination; the current Monthly Log remains intentionally unavailable as a shortcut destination, while Collection references use the same source Entry rather than movement lineage.
- Historical Daily and Monthly Logs are retrieval-only: capture and Task actions remain available only in the current Daily Log/current month.

### Fixed

- Journal creation initializes the required singleton `journal_metadata` record, and unlocking an older pre-alpha journal with that row missing repairs it idempotently without replacing existing encrypted journal content; multiple metadata rows still fail closed as corruption.
- Replaced the first Today regression-test approach, which mixed real filesystem/cryptographic I/O into a Flutter widget test, with an isolated in-memory presentation boundary.
- Unexpected journal-access and capture failures retain diagnostic stack information without logging passwords, journal contents, or raw exception messages.
- Mobile text editing explicitly counts as journal activity even when an input method does not emit Flutter hardware-key events.
- Focused Future Log persistence rejects non-Future owners before capture, preventing an incorrect caller from silently writing through the wrong product boundary.
- Retained Future navigation reloads its month snapshots when the Future section becomes active, so Tasks scheduled from Today or Monthly appear immediately without requiring lock, restart, or screen remount.
- Retained Collections navigation reloads its list, owned entries, and references when the section becomes active, so migrations or references created from another retained section appear without requiring lock, restart, or screen remount.
- Retained Search reruns the last submitted query when its section becomes active, so result Task state reflects changes made elsewhere without polling or persisting Search history.
- Search case-insensitive matching handles Unicode case changes such as `RÁDIO` and `rádio` while keeping accents literal.
- A completed retained Search refresh can no longer overwrite the result of a newer explicitly submitted query.

### Security

- The `1.0.0-alpha.2` Android release uses a dedicated non-debug release signing key kept outside Git; physical-device migration validation preserved encrypted journal data while moving from the earlier debug-signed alpha.1 development lineage into the release-signed alpha.2 installation through the portable encrypted backup boundary.
- Journal persistence uses SQLite3MultipleCiphers ChaCha20-Poly1305 with random per-journal key material instead of plaintext SQLite.
- Master passwords protect the random journal key through Argon2id and XChaCha20-Poly1305 rather than being used directly as database passwords.
- Key-envelope and encrypted-database tests cover wrong credentials, corrupted authenticated data, incorrect database keys, unkeyed SQLite access, and representative plaintext leakage.
- Representative Linux and physical Android profile-mode benchmarks were recorded for Argon2id parameter selection.
- The initial Argon2id production baseline is frozen at 19 MiB memory, 2 iterations, parallelism 1, and 32-byte output; parameters remain explicit in each key envelope for compatible security maintenance.
- Unlocked journal sessions own the encrypted database and mutable journal-key material; closing the session closes persistence before key destruction.
- Open Export is an explicit plaintext security boundary: exported JSON and Markdown are not encrypted and are deliberately distinct from Daymark encrypted backup.
- The inactivity guard fails closed if the wall clock moves backwards relative to the last recorded journal interaction.

### Release validation

- Final distributed Linux x64 archive SHA-256: `490ce7c62126e8b9d5e9e78a3727f68c131e60ef197d0673d174ea0d44def9c4`.
- Final distributed signed Android APK SHA-256: `96f69264a4fc0fead8d31893f96aac428db341303abdfab929daaee5760f20f0`.
- Android release certificate SHA-256: `44342dcd1343643bc56da2545ec10e5624fc2e49d1bcc3b418f4f9ab160e1b88`.
- Linux release smoke testing, physical Android migration/restore/reinstall testing, JSON/Markdown Open Export validation, exact-head Ready CI, and post-merge `main` CI passed before publication.
