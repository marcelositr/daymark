# Data model

## Purpose

This document defines the relational persistence contract for Daymark before the Drift implementation is allowed to make those decisions implicitly.

The model follows `docs/DOMAIN.md`. Database structure must preserve Bullet Journal semantics, migration lineage, deliberate Index structure, and encrypted local ownership without turning the product into a generic task database.

## Database boundary

One encrypted Daymark database file represents exactly one journal.

Daymark must not model multiple journals as tenants inside one SQLite database with a `journal_id` repeated across every table. If multiple journals are supported later, each journal should normally have its own encrypted database file and its own independent journal key.

Reasons:

- journal keys stay isolated;
- backup and restore remain naturally journal-scoped;
- deleting or transferring one journal does not require filtering a shared database;
- accidental cross-journal queries become structurally impossible;
- future multi-journal support does not require changing entry identity or relationships.

The database contains a single `journal_metadata` record with the journal's stable identity. Application code must treat more than one metadata row as corruption.

## Storage conventions

### Identifiers

Persisted domain entities use UUID v7 stored as canonical lowercase text.

Database row numbers are implementation details and must not become domain identifiers, export identifiers, migration references, or cross-record identity.

Built-in semantic codes such as `task`, `event`, `open`, or `priority` are stable language-neutral text values rather than localized labels.

### Time

Instants such as creation, modification, references, and migrations are stored as UTC integer microseconds since Unix epoch.

Method dates are different from instants. Daily, Monthly, and Future Log periods represent calendar dates in the user's journal context and must not shift because of timezone conversion. They are stored as ISO-8601 date text (`YYYY-MM-DD`). Monthly and Future periods use the first day of the represented month.

### Foreign keys

SQLite foreign-key enforcement is mandatory whenever a Daymark database connection is open.

Foreign-key violations are data-integrity failures. The application must not silently repair them by dropping relationships.

### Text enums

Small semantic enums use stable text values instead of ordinal integers. Adding or reordering an application enum must therefore not reinterpret old data.

## Initial schema

The first schema version is `1`.

### `journal_metadata`

One record identifies the encrypted journal represented by the database file.

Fields:

- `id` — UUID v7 primary key;
- `created_at` — UTC microseconds;
- `updated_at` — UTC microseconds.

This table deliberately does not contain password-derived keys, KDF salts, wrapped database keys, recovery material, or device-keystore handles. Those values are needed before the encrypted database can be opened and therefore belong to the versioned key-envelope design defined by the security spike.

### `logs`

Represents method-native chronological log containers.

Fields:

- `id` — UUID v7 primary key;
- `kind` — `daily`, `monthly`, or `future`;
- `period_start` — ISO date;
- `created_at` — UTC microseconds.

Invariant:

- `(kind, period_start)` is unique.

Examples:

- Daily Log for 2026-09-01: `daily`, `2026-09-01`;
- Monthly Log for September 2026: `monthly`, `2026-09-01`;
- Future Log bucket for January 2027: `future`, `2027-01-01`.

A digital Future Log is modeled as month-addressable buckets rather than a second general calendar system.

### `collections`

Represents deliberate Bullet Journal Collections.

Fields:

- `id` — UUID v7 primary key;
- `title` — user content;
- `created_at` — UTC microseconds;
- `updated_at` — UTC microseconds.

Collections are simple content containers. This table must not grow configurable database fields, Kanban metadata, arbitrary property schemas, or Notion-style structure without an explicit product decision.

### `entries`

Stores the semantic content of a Bullet Journal entry independently from where it is placed.

Fields:

- `id` — UUID v7 primary key;
- `entry_type` — `task`, `event`, or `note`;
- `task_state` — nullable task lifecycle value;
- `content` — user content;
- `created_at` — UTC microseconds;
- `updated_at` — UTC microseconds.

Task-state invariant:

- a `task` has exactly one of `open`, `completed`, `migrated`, `scheduled`, or `discarded`;
- an `event` has `task_state = NULL`;
- a `note` has `task_state = NULL`.

Rendered Bullet symbols are not persisted as the semantic state.

Editing content updates the existing entry identity. It does not create a new identity merely because text changed.

### `entry_placements`

Every entry has exactly one owning location.

Fields:

- `entry_id` — primary key and foreign key to `entries`;
- `log_id` — nullable foreign key to `logs`;
- `collection_id` — nullable foreign key to `collections`;
- `ordinal` — integer order within the owner;
- `monthly_section` — nullable `calendar` or `tasks` when the owner is a Monthly Log;
- `monthly_calendar_date` — nullable ISO date, required exactly when `monthly_section = calendar`.

Ownership invariant:

Exactly one of `log_id` and `collection_id` is non-null.

`ordinal` preserves deliberate/capture ordering independently of timestamps and leaves room for transactional reordering later without changing entry identity.

`monthly_section` preserves the original Monthly Log distinction between the calendar side and task-list side. It is null for Daily Log, Future Log, and Collection ownership.

A Monthly calendar placement stores its calendar date explicitly. Daymark must not infer a date by parsing entry text such as `15 dentist`. Repository/application validation must also ensure that a Monthly calendar date belongs to the month represented by its owning Monthly Log; that cross-table invariant cannot be expressed as a normal SQLite `CHECK` constraint.

An entry is never moved between owners in-place to implement Bullet Journal migration. Migration creates a destination entry and a lineage record, leaving the source in its historical location.

### `migrations`

Records deliberate Bullet Journal movement as a lineage chain.

Fields:

- `id` — UUID v7 primary key;
- `source_entry_id` — foreign key to `entries`;
- `destination_entry_id` — foreign key to `entries`;
- `kind` — `migrated` or `scheduled`;
- `created_at` — UTC microseconds.

Invariants:

- source and destination must be different entries;
- one source entry may have at most one direct outgoing migration;
- one destination entry may have at most one direct predecessor.

This deliberately forms chains rather than a many-parent graph. Repeated future movement creates another entry and another edge:

```text
A -> B -> C
```

rather than rewriting `A` or attaching several destinations to one historical decision.

For tasks, application/domain logic must keep source task state consistent with migration kind:

- `migrated` lineage normally corresponds to source state `migrated`;
- `scheduled` lineage corresponds to source state `scheduled` and destination ownership in a Future Log.

Events and Notes may participate in traceable movement without acquiring task states.

Source and destination locations are preserved through their immutable entry placements, so lineage does not need to duplicate display text or denormalized location labels.

### `collection_references`

Represents a Collection reference/link without changing entry ownership or task state.

Fields:

- `collection_id` — foreign key to `collections`;
- `entry_id` — foreign key to `entries`;
- `ordinal` — order of the reference within the Collection;
- `created_at` — UTC microseconds.

Primary key:

- `(collection_id, entry_id)`.

This is intentionally distinct from migrating an entry into a Collection. A referenced Daily entry remains owned by its Daily Log.

### `signifiers`

Defines signifier identities without turning them into entry types.

Fields:

- `id` — stable text primary key;
- `kind` — `builtin` or `custom`;
- `builtin_code` — nullable stable code for built-ins;
- `custom_label` — nullable user-facing label for a future custom signifier;
- `custom_symbol` — nullable user-facing symbol for a future custom signifier;
- `created_at` — UTC microseconds.

Initial built-in identities are expected to use stable IDs such as:

- `builtin:priority`;
- `builtin:inspiration`;
- `builtin:explore`.

Built-in translated labels are not stored in the database.

Custom signifiers are not required for the first product milestone, but this definition table prevents a future custom signifier feature from requiring new `EntryType` values or new columns on `entries`.

### `entry_signifiers`

Many-to-many relationship between entries and signifiers.

Fields / primary key:

- `entry_id` — foreign key to `entries`;
- `signifier_id` — foreign key to `signifiers`;
- primary key `(entry_id, signifier_id)`.

### `index_items`

Persists the Index as a deliberate Bullet Journal structure rather than deriving it from Search.

Fields:

- `id` — UUID v7 primary key;
- `ordinal` — deliberate Index order;
- `log_id` — nullable foreign key to `logs`;
- `collection_id` — nullable foreign key to `collections`;
- `created_at` — UTC microseconds.

Exactly one target is non-null.

The Index stores references to journal structures, not duplicated entry content.

## Deliberately absent from schema v1

### Search index

Search must initially query the encrypted journal database directly. If an FTS index is introduced later, it must live inside the same encrypted database boundary. No plaintext external search index is allowed.

### Application preferences

Theme, language override, window state, and similar application preferences are not journal domain records and do not belong in the encrypted journal relational model merely for convenience.

Security-sensitive preference behavior such as auto-lock is governed by the security architecture, but it still must not be mixed into entry/domain tables.

### Key-envelope metadata

Master-password KDF parameters, salts, wrapped journal key material, recovery metadata, and device-assisted unlock handles are intentionally outside this Drift schema because they are required to unlock the database itself.

The security spike must define a small versioned envelope with authenticated handling. Plain metadata in that envelope must not reveal journal content.

### Attachments

Attachments are not part of schema v1. If introduced, they will use encrypted files plus database metadata rather than creating a plaintext side channel.

### Reflection records

Reflection is a method behavior, not automatically a stored entity. No reflection table is added until a concrete user-visible requirement demonstrates what must persist.

### Trash / soft delete

Daymark does not add a generic trash subsystem preemptively. `discarded` is a Bullet Journal task state and remains distinct from destructive deletion.

## Deletion and referential behavior

Deletion is an explicit destructive operation, not a task state.

The implementation should prefer referential rules that prevent accidental orphaning. Where a user explicitly destroys an entry, dependent relationship rows such as signifier links and Collection references may cascade with it. Migration lineage involving an entry must be handled deliberately so deletion cannot silently leave a false historical edge.

Deleting a Collection or Log that owns entries must not silently destroy those entries. The application must require an explicit data decision first.

Exact `ON DELETE` actions are part of the Drift schema implementation and tests and must match these rules.

## Ordering

Do not use timestamps alone as UI order.

`ordinal` is scoped to the owning structure or reference list. Initial insertion may use monotonically increasing integers. If manual insertion/reordering is later needed, the application may renumber a container transactionally. No fractional-position package or collaborative ordering algorithm is justified for the initial local-only product.

## Schema migration policy

Daymark uses Drift's versioned migration tooling rather than ad-hoc `ALTER TABLE` strings as the normal path.

The implementation must:

1. start at `schemaVersion = 1`;
2. keep exported schema snapshots under `drift_schemas/`;
3. use Drift's `make-migrations` / generated step-by-step migration helpers for subsequent versions;
4. keep generated migration verification code under the test tree;
5. test schema shape and representative data preservation across supported upgrades;
6. enable foreign keys before normal use and verify foreign-key integrity around migrations;
7. run schema/migration tests in CI once schema v1 is implemented.

Before the first public `v1.0.0-alpha.1`, an unreleased schema may still be corrected aggressively when evidence warrants it. Once any prerelease containing user data is published, every later supported build must have an explicit tested upgrade path from the published schema versions it claims to support.

No release may solve a migration problem by silently deleting and recreating the user's journal.

## Review rule

A schema change is a product/data-compatibility change, not a private implementation detail.

Any future change to tables, semantic values, constraints, or migration behavior must update the schema snapshot, migration tests, relevant documentation, and `PROJECT.md` in the same pull request.