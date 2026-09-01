# Architecture

## Status

This document defines architectural constraints before the application scaffold exists. Concrete package names and implementation details may evolve, but the boundaries below are intentional.

## Technology baseline

- Flutter
- Dart
- Drift
- SQLite

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
SQLite
```

Platform integrations belong outside the domain:

```text
platform/
├── linux/
└── android/
```

The domain must not depend on Android APIs, Linux desktop APIs, filesystem paths, windowing systems, notification services, or Flutter widgets.

## Domain concepts

The initial model is expected to revolve around:

- Journal
- Entry
- EntryType
- EntryState
- DailyLog
- MonthlyLog
- FutureLog
- Collection
- Migration
- Reflection

The exact schema must follow domain behavior rather than mirror screens.

## Persistence

SQLite is the source of truth for structured application data.

Drift provides typed persistence and migrations.

Database migrations must be explicit, versioned, tested, and forward-only in normal operation. Destructive schema changes require an explicit data migration strategy.

Attachments, if introduced, should normally remain files rather than opaque database blobs. SQLite should store metadata and references.

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

The application should eventually provide:

- a complete machine-readable export;
- a human-readable export, expected to include Markdown;
- documented schema/version metadata.

## UI architecture

Linux and Android share product behavior but do not need identical layouts.

Desktop may use wider navigation and keyboard-oriented interactions. Android should optimize for fast capture and minimal taps.

Responsive design must not become a desktop interface merely squeezed onto a phone.

## Non-goals for the initial architecture

The first implementation does not require:

- a backend server;
- user accounts;
- cloud synchronization;
- collaboration;
- distributed conflict resolution;
- plugin infrastructure;
- AI services.

These must not leak into the core model as speculative abstractions.
