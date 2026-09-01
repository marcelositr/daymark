# Architecture

## Status

This document defines architectural constraints before the application scaffold exists. Concrete package names and implementation details may evolve, but the boundaries below are intentional.

## Technology baseline

- Flutter
- Dart
- Drift
- SQLite-compatible encrypted persistence

SQLCipher is the expected implementation direction for encrypted database storage unless technical validation before persistence implementation identifies a better maintained equivalent.

Initial supported platforms:

- Linux
- Android

Future targets may include Windows, macOS, and iOS.

## Layering

Daymark should keep platform and framework concerns at the edges.

```text
presentation
    ↓
application
    ↓
domain
    ↓
data / repositories
    ↓
encrypted SQLite-compatible storage
```

Platform integrations belong outside the domain:

```text
platform/
├── linux/
└── android/
```

The domain must not depend on Android APIs, Linux desktop APIs, filesystem paths, windowing systems, notification services, or Flutter widgets.

## Domain concepts

The authoritative semantic rules are defined in `docs/DOMAIN.md`.

The initial model revolves around:

- Journal
- Entry
- EntryType
- TaskState
- Signifier
- DailyLog
- MonthlyLog
- FutureLog
- Collection
- Migration
- Reflection

Entry type, task state, signifiers, storage location, and migration lineage are separate concerns. The exact schema must follow domain behavior rather than mirror screens or rendered Bullet symbols.

## Persistence

Encrypted SQLite-compatible storage is the source of truth for structured application data.

Drift provides typed persistence and migrations.

Database migrations must be explicit, versioned, tested, and forward-only in normal operation. Destructive schema changes require an explicit data migration strategy.

Encryption at rest is part of the persistence architecture from the beginning. It must not be retrofitted after plaintext journal databases have become part of the normal product lifecycle.

Stable IDs must be used for persisted entries and relationships. Migration lineage must refer to identities rather than copied display text.

Attachments, if introduced, should normally remain files rather than opaque database blobs. Their storage must follow the same security requirement and must not create a plaintext side channel around the encrypted journal.

## Key architecture

The journal data-encryption key is generated from cryptographically secure random material and is distinct from the user's master password.

The master password protects access to the journal key through a versioned password-based key-derivation and key-wrapping layer. Argon2id is the preferred KDF direction, subject to platform benchmarking and implementation validation before the security layer is frozen.

Device-specific mechanisms such as Android Keystore or a Linux secret service may protect an additional device-local wrapped key for convenient unlock. The portable security and recovery model must not depend on those device-specific mechanisms.

## Backup architecture

Manual full encrypted backup and restore are initial product requirements rather than optional post-release tooling.

Backups must be:

- encrypted by default;
- portable between supported platforms;
- independent of device-bound key stores;
- versioned;
- integrity-checked before restore;
- capable of evolving to include attachments without changing the security boundary.

Automatic backup scheduling, retention rotation, remote synchronization, and cloud-specific integrations are later concerns.

Human-readable Markdown or JSON export is a separate portability feature and may intentionally produce plaintext.

## Localization

Internationalization is part of the initial architecture.

Daymark should use Flutter's localization tooling with ARB resources and generated localization accessors. English is the canonical source locale and Portuguese (Brazil) is the first additional locale.

Expected localization resources:

```text
lib/l10n/
├── app_en.arb
└── app_pt_BR.arb
```

User-facing strings must not be hardcoded throughout presentation code when they belong in localization resources.

Domain values, enum-like states, database records, migration logic, export schema identifiers, and application decisions must use stable language-neutral identifiers. Translated strings are presentation only and must never become persistence keys or business logic inputs.

The application should select the system locale by default and support an explicit user override.

Layouts should use directional concepts such as start/end instead of assuming left/right wherever practical, keeping future RTL support possible without requiring a UI rewrite. RTL languages are not an initial release target.

## Portability

User data must never depend on undocumented internal serialization as the only recovery path.

The application should provide:

- a full encrypted Daymark backup for safe recovery;
- a complete machine-readable export;
- a human-readable export, expected to include Markdown;
- documented schema/version metadata.

Exports must be treated as a deliberate security boundary because portable human-readable formats may be plaintext outside the encrypted journal store.

## UI architecture

Linux and Android share product behavior but do not need identical layouts.

Desktop may use wider navigation and keyboard-oriented interactions. Android should optimize for fast capture and minimal taps.

Responsive design must not become a desktop interface merely squeezed onto a phone.

The visual identity may use the metaphor of a minimal dotted notebook page, but the application is not a freeform canvas or page-layout editor. Notebook aesthetics belong to presentation; semantic journal structure remains in the domain model.

## Foundation-first development order

Daymark should establish correctness and safety before visual or convenience features.

The initial implementation order is:

1. Bullet Journal domain model and behavior;
2. data model, identifiers, migrations, and migration history;
3. encryption, key handling, locking, backup/restore, and storage security boundaries;
4. localization foundation;
5. architectural wiring between domain, application, data, presentation, and platform layers;
6. minimal end-to-end workflow for capture, completion, deliberate migration, Monthly Log, Future Log, Collections, and retrieval.

Visual refinement, advanced attachments, automatic backup scheduling, importers, additional themes, and other non-core enhancements come after the core workflow is correct, testable, and secure.

## Non-goals for the initial architecture

The first implementation does not require:

- a backend server;
- user accounts;
- cloud synchronization;
- collaboration;
- distributed conflict resolution;
- plugin infrastructure;
- AI services;
- freeform canvas/page-layout editing.

These must not leak into the core model as speculative abstractions.
