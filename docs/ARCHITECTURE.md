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
