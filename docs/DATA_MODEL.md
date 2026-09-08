# Data model

Daymark uses a relational Drift schema stored in an encrypted SQLite database.

The canonical schema is `lib/core/database/daymark.drift`. This document explains the model; it does not replace the schema.

## Schema version

Current database schema version: **2**.

The v1 → v2 migration adds Trackers and Tracker marks. Schema changes require a Drift migration and migration tests.

## Tables

| Table | Purpose |
| --- | --- |
| `journal_metadata` | singleton journal metadata |
| `logs` | Daily, Monthly, and Future Logs |
| `collections` | Collection identities and titles |
| `entries` | Task, Event, and Note content/state |
| `entry_placements` | exactly one owning location per Entry |
| `migrations` | source → destination lineage |
| `collection_references` | non-owning Collection references |
| `signifiers` | built-in/custom signifier definitions |
| `entry_signifiers` | Entry ↔ Signifier relation |
| `index_items` | deliberate Index references |
| `trackers` | Tracker definitions and lifecycle |
| `tracker_marks` | explicit daily Tracker values |

## Important invariants

### Logs

A Log is unique by `(kind, period_start)`.

Kinds are:

- `daily`
- `monthly`
- `future`

Dates use ISO `YYYY-MM-DD` strings. Monthly/Future periods use the first day of the month.

### Entries

Entry types are:

- `task`
- `event`
- `note`

Only Tasks have `task_state`. Events and Notes must have `NULL` Task state.

Task states are:

- `open`
- `completed`
- `migrated`
- `scheduled`
- `discarded`

### Placement

Each Entry has exactly one `entry_placements` row and exactly one owner:

- `log_id`, or
- `collection_id`

Never both.

Monthly placements additionally identify `calendar` or `tasks`. Calendar placements require a date in that month; Monthly Tasks do not carry a calendar date.

Placement ordinals are unique within an owner.

### Migration lineage

A migration row links one source Entry to one destination Entry.

Both source and destination are unique in the migration table and cannot be the same Entry.

Migration kinds are:

- `migrated`
- `scheduled`

Migration is implemented transactionally by creating a destination Entry, copying relevant metadata, updating the source Task state when applicable, and recording lineage.

### Collection references

A reference exposes an Entry inside a Collection without changing ownership.

The pair `(collection_id, entry_id)` is unique. References have an explicit order within a Collection.

### Signifiers

Built-in Signifiers are seeded on database creation:

- `priority`
- `inspiration`
- `explore`

The schema also reserves representation for custom Signifiers, but product behavior is currently centered on the built-ins.

### Index

An Index item references exactly one Log or Collection. A target may appear in the Index at most once. Index order is explicit.

### Trackers

A Tracker has a start date, planned end date, optional early end date, and color slot `0..4`.

A mark is keyed by `(tracker_id, method_date)` and stores only `-1` or `1`. Absence means unmarked.

## Identifiers and timestamps

Application-created records use UUIDv7 identifiers where the repository owns ID creation.

Timestamps are UTC microseconds since Unix epoch and must be non-negative.

## Transactions

Cross-table mutations that enforce journal semantics must be atomic. Repository methods own these transactions; UI code must not reproduce multi-table persistence logic.

## Migration policy

For every schema change:

1. update the Drift schema
2. increment `DaymarkDatabase.currentSchemaVersion`
3. add a migration step
4. regenerate migration snapshots
5. test upgrading all supported prior schema versions
6. keep CI-generated artifacts clean

Never silently recreate a user database to avoid writing a migration.
