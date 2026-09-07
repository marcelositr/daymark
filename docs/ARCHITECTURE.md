# Architecture

## Overview

Daymark is a Flutter application with one primary product domain: the journal.

```text
main.dart
  -> DaymarkApp
  -> GoRouter
  -> JournalGate
  -> AppShell
  -> Today / Monthly / Future / Collections / Search / Index
  -> JournalSession
  -> application services and repositories
  -> Drift
  -> encrypted SQLite
```

Riverpod provides dependency and state wiring. `go_router` owns application routing. Drift owns relational persistence and schema migration.

## Source layout

```text
lib/
├── app/            application composition, theme, routing, app metadata
├── core/           encryption, database, session, backup, export, settings
├── features/
│   └── journal/    domain, application services, repositories, journal UI
├── l10n/           ARB localization sources
├── presentation/   shared application presentation components
└── main.dart       process entry point
```

### `lib/app`

Contains application-level composition:

- `daymark_app.dart`
- `router.dart`
- theme and design tokens
- appearance controller
- app metadata

### `lib/core`

Contains infrastructure that is not journal-screen specific:

- `crypto/` — journal key material and password-protected key envelope
- `database/` — Drift schema and encrypted SQLite opening/validation
- `session/` — unlocked-journal lifetime and serialized operations
- `backup/` — encrypted backup creation and restore
- `export/` — plaintext Open Export
- `settings/` — device-local non-journal preferences

### `lib/features/journal`

Contains the journal domain:

- `domain/` — persistent vocabulary and invariants
- `application/` — semantic operations such as capture and migration
- `data/` — repositories and read models
- `presentation/` — screens, dialogs, and journal-specific UI adapters

## Navigation

Primary routes:

```text
/                           Today
/daily/:date                historical Daily Log
/monthly                    current Monthly Log
/monthly/:period            Monthly history
/future                     Future Log
/future/:period             arrived/history Future Log
/collections
/collections/:collectionId
/search
/index
```

Expanded layouts expose all six major destinations. Compact layouts expose Today, Monthly, Future, Collections, and a More menu containing Search, Index, Backup, Export, Appearance, and About.

## Runtime ownership

`JournalSession` owns every object valid only while a journal is unlocked, including the database, key material, services, and repositories.

Journal operations enter through the session and are serialized. Once closing begins, no new operation may enter. Closing waits for queued work, closes encrypted persistence, and destroys journal key material.

`JournalSessionManager` owns creation, unlock, reauthentication, backup, restore, lock, and storage-state inspection.

## Persistence boundary

The database is relational and encrypted at rest. `JournalRepository` and focused repositories own persistence invariants. Presentation code should not coordinate multi-table writes directly.

Migrations between journal locations create a new Entry and a lineage record rather than moving the historical Entry in place.

## Locking

An unlocked journal may lock through:

- explicit user action
- five minutes of inactivity
- host OS lock signal

Android reports screen-off through a platform channel. Linux reports a real session lock through `systemd-logind` D-Bus integration. Both converge on the same journal lock path.

## Localization

Product locales are:

- English
- Spanish
- Portuguese (Brazil)

English is the fallback locale.

## Generated sources

Generated Drift and localization artifacts are part of the build process. CI rejects stale Drift generated output and validates localization generation.

## Architectural rule

Prefer a small number of explicit boundaries over introducing framework layers merely for symmetry. New abstractions should protect a real invariant, reduce duplication, or make testing materially clearer.
