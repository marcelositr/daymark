# Data model

## Purpose

This document defines Daymark's current relational persistence contract. Drift implementation, schema snapshots, migration tests, export contracts, and compatibility code must remain consistent with these rules rather than allowing database structure to redefine Bullet Journal semantics implicitly.

The model follows `docs/DOMAIN.md`. Database structure preserves the frozen Bullet Journal semantics, migration lineage, deliberate Index structure, Tracker adaptation, and encrypted local ownership without turning the product into a generic task database.

Schema version 1 is published in `v1.0.0-alpha.2` and is a real compatibility boundary. Schema version 2 is the current additive Tracker migration.

Daymark's functional product scope is frozen. Schema changes are maintenance-only and require a concrete bug, security, compatibility, or supported-platform/toolchain reason. They are not a mechanism for adding new product capabilities.

## Database boundary

One encrypted Daymark database file represents exactly one journal.

Daymark does not model multiple journals as tenants inside one SQLite database with a `journal_id` repeated across every table. Multi-journal product support is not planned under the freeze.

The single-journal-file boundary keeps:

- journal keys isolated;
- Backup / Restore naturally journal-scoped;
- journal transfer/deletion structurally bounded;
- accidental cross-journal queries impossible.

The database contains exactly one `journal_metadata` record with the journal's stable identity. Application code treats more than one metadata row as corruption.

`v1.0.0-alpha.2` also repairs an older development journal with zero metadata rows: successful unlock transactionally creates one UUID-v7 singleton row and preserves it thereafter. This compatibility repair does not change schema version 1.

## Storage conventions

### Identifiers

Persisted domain entities use UUID v7 stored as canonical lowercase text.

Database row numbers are implementation details and must not become domain identifiers, export identifiers, migration references, or cross-record identity.

Built-in semantic codes such as `task`, `event`, `open`, or `priority` are stable language-neutral text values rather than localized labels.

### Time

Instants such as creation, modification, references, and migrations are stored as UTC integer microseconds since Unix epoch.

Method dates are different from instants. Daily, Monthly, Future, and Tracker method periods represent calendar dates in the user's journal context and must not shift because of timezone conversion. They are stored as ISO-8601 date text (`YYYY-MM-DD`). Monthly/Future periods use the first day of the represented month.

### Foreign keys

SQLite foreign-key enforcement is mandatory whenever a Daymark database connection is open.

Foreign-key violations are data-integrity failures. The application must not silently repair them by dropping relationships.

### Text enums

Small semantic enums use stable text values instead of ordinal integers. Internal enum reorderings must not reinterpret old data.

## Schema version 1

### `journal_metadata`

One record identifies the encrypted journal represented by the database file.

Fields:

- `id` — UUID v7 primary key;
- `created_at` — UTC microseconds;
- `updated_at` — UTC microseconds.

This table does not contain password-derived keys, KDF salts, wrapped database keys, or device-unlock material. Pre-unlock cryptographic metadata belongs to the key-envelope boundary defined by `SECURITY.md`.

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

Future Log is month-addressable rather than a second general calendar system.

### `collections`

Represents deliberate Bullet Journal Collections.

Fields:

- `id` — UUID v7 primary key;
- `title` — user content;
- `created_at` — UTC microseconds;
- `updated_at` — UTC microseconds.

Collections are simple content containers. Configurable database fields, Kanban metadata, arbitrary property schemas, and workspace/Notion-style structures are outside the frozen product scope.

### `entries`

Stores semantic content independently from placement.

Fields:

- `id` — UUID v7 primary key;
- `entry_type` — `task`, `event`, or `note`;
- `task_state` — nullable Task lifecycle value;
- `content` — user content;
- `created_at` — UTC microseconds;
- `updated_at` — UTC microseconds.

Task-state invariant:

- a `task` has exactly one of `open`, `completed`, `migrated`, `scheduled`, or `discarded`;
- an `event` has `task_state = NULL`;
- a `note` has `task_state = NULL`.

Rendered Bullet symbols are not persisted as semantic state.

### `entry_placements`

Every Entry has exactly one owning location.

Fields:

- `entry_id` — primary key and foreign key to `entries`;
- `log_id` — nullable foreign key to `logs`;
- `collection_id` — nullable foreign key to `collections`;
- `ordinal` — integer order within the owner;
- `monthly_section` — nullable `calendar` or `tasks` when owner is Monthly;
- `monthly_calendar_date` — nullable ISO date, required exactly for `monthly_section = calendar`.

Ownership invariant:

Exactly one of `log_id` and `collection_id` is non-null.

`ordinal` preserves deliberate/capture ordering independently of timestamps.

`monthly_section` preserves the Monthly Calendar/Tasks distinction. It is null for Daily, Future, and Collection ownership.

A Monthly calendar placement stores calendar date explicitly. Repository/application validation ensures that date belongs to the owning Monthly month.

An Entry is never moved between owners in place to implement Bullet Journal movement. Scheduling/migration creates destination Entry plus lineage while retaining source history.

### `migrations`

Records deliberate movement lineage.

Fields:

- `id` — UUID v7 primary key;
- `source_entry_id` — foreign key to `entries`;
- `destination_entry_id` — foreign key to `entries`;
- `kind` — `migrated` or `scheduled`;
- `created_at` — UTC microseconds.

Invariants:

- source and destination differ;
- one source has at most one direct outgoing migration;
- one destination has at most one direct predecessor.

Lineage forms chains such as:

```text
A -> B -> C
```

For Tasks:

- `migrated` lineage corresponds to source state `migrated`;
- `scheduled` lineage corresponds to source state `scheduled` and destination ownership in Future.

The frozen product movement flows are Task-only from Today/Daily or Monthly Tasks to Future (scheduled) or an existing Collection (migrated). Event/Note movement product flows are not planned.

### `collection_references`

Represents a Collection reference without changing Entry ownership or Task state.

Fields:

- `collection_id` — foreign key to `collections`;
- `entry_id` — foreign key to `entries`;
- `ordinal` — order in the Collection reference list;
- `created_at` — UTC microseconds.

Primary key:

- `(collection_id, entry_id)`.

A referenced Daily/Monthly/Future Entry remains owned by its chronological Log and appears read-only through the Collection reference surface.

### `signifiers`

Defines signifier identities without turning them into Entry types.

Fields:

- `id` — stable text primary key;
- `kind` — `builtin` or `custom`;
- `builtin_code` — nullable stable code for built-ins;
- `custom_label` — nullable user-facing label;
- `custom_symbol` — nullable user-facing symbol;
- `created_at` — UTC microseconds.

Built-in stable IDs include concepts such as:

- `builtin:priority`;
- `builtin:inspiration`;
- `builtin:explore`.

Built-in translated labels are not stored.

The `custom` representation remains part of the published schema shape but user-defined signifier product UI is not planned under the current freeze. Do not expand that schema capability into a new product feature without an explicit freeze reversal.

### `entry_signifiers`

Many-to-many relationship between Entries and signifiers.

Fields / primary key:

- `entry_id` — foreign key to `entries`;
- `signifier_id` — foreign key to `signifiers`;
- primary key `(entry_id, signifier_id)`.

### `index_items`

Persists the deliberate Index independently from Search.

Fields:

- `id` — UUID v7 primary key;
- `ordinal` — deliberate Index order;
- `log_id` — nullable foreign key to `logs`;
- `collection_id` — nullable foreign key to `collections`;
- `created_at` — UTC microseconds.

Exactly one target is non-null.

The Index stores references to journal structures, not duplicated Entry content.

## Schema version 2

Schema v2 is the first post-alpha.2 migration and extends published schema v1 additively for the optional Daymark Tracker adaptation. Existing v1 tables/semantic values are not reinterpreted.

### `trackers`

Stores one finite Tracker independently from Entries/placements.

Fields:

- `id` — UUID v7 primary key;
- `title` — non-empty user content;
- `start_date` — inclusive ISO method date;
- `planned_end_date` — inclusive ISO method date, not earlier than start;
- `ended_date` — nullable inclusive early-end date between start/planned end;
- `color_slot` — stable visual slot `0..4`;
- `created_at` — UTC microseconds;
- `updated_at` — UTC microseconds.

Effective end is `ended_date` when present, otherwise `planned_end_date`. One persisted slot keeps visual identity across the full intersecting period. The frozen Tracker behavior requires a slot to be available across the proposed period rather than recoloring history.

### `tracker_marks`

Stores only explicit daily Tracker outcomes.

Fields / primary key:

- `tracker_id` — foreign key to `trackers`, cascading when that Tracker is explicitly destroyed;
- `method_date` — ISO method date;
- `value` — exactly `-1` or `1`;
- `created_at` — UTC microseconds;
- `updated_at` — UTC microseconds;
- primary key `(tracker_id, method_date)`.

There is no persisted zero row. Inside effective interval, absence means `0` / no explicit mark. Outside interval there is no datum. Repository validation rejects marks outside interval.

### Migration from v1

The v1-to-v2 migration uses Drift generated versioned-schema helpers and creates `trackers`, `tracker_marks`, and declared indexes without rewriting v1 journal rows.

CI retains v1/v2 schema snapshots and migration verification. A representative v1 journal is migrated in tests to prove existing data survives while Tracker tables begin empty.

## Deliberately absent product/storage systems

### External/full-text Search index

Frozen Search queries the encrypted database directly. No plaintext external Search index is allowed, and richer full-text/ranking product functionality is not planned.

A maintenance optimization, if ever concretely required, must remain inside the encrypted boundary and preserve existing Search semantics.

### Journal-scoped application preferences

Theme/Appearance, window state, and similar application preferences are not journal domain records.

Appearance remains non-secret device/application state outside the encrypted journal database.

Explicit language override and additional lock-configuration product settings are not planned under the freeze.

### Key-envelope metadata

Master-password KDF parameters, salts, and wrapped journal-key material remain outside Drift because they are required before opening the database.

Device-assisted unlock and recovery-secret product systems are not planned. Do not add schema or envelope fields for them speculatively.

### Attachments

Attachments are not part of the frozen product and no attachment schema is planned.

### Reflection records

Reflection is current method behavior, not a persisted standalone entity. No reflection table is planned under the frozen scope.

### Trash / soft delete

Daymark does not add a generic trash subsystem. `discarded` is a Bullet Journal Task state and remains distinct from destructive deletion.

## Deletion and referential behavior

Deletion is an explicit destructive operation, not a Task state.

Referential rules prevent accidental orphaning. When a user explicitly destroys an Entry, dependent relationship rows such as signifier links/references may cascade according to the implemented schema. Migration lineage must never silently become a false historical edge.

Deleting a Collection or Log that owns Entries must not silently destroy those Entries. Existing product/UI rules remain authoritative.

### Immediate capture Undo

The UI may briefly offer Undo immediately after capture. Persistence operation is intentionally narrower than generic deletion: it transactionally removes Entry plus owning placement only while the Entry remains untouched and has no migration, reference, signifier, or other journal relationship.

This requires no schema change and does not introduce Trash/soft delete.

## Ordering

Do not use timestamps alone as UI order.

`ordinal` is scoped to the owning structure/reference list and preserves the existing deliberate order behavior. Index reorder/remove is implemented at its supported boundary.

Do not add new manual-ordering systems, fractional-position packages, or collaborative ordering algorithms under the frozen product scope.

## Published schema and migration policy

Daymark uses Drift versioned migration tooling rather than ad-hoc schema strings as the normal path.

The implementation must:

1. retain exported schema snapshots under `drift_schemas/`;
2. use Drift migration tooling/generated helpers for later maintenance schema versions;
3. keep migration verification code under tests;
4. test target schema shape and representative data preservation across every supported predecessor upgrade;
5. enable foreign keys before normal use and verify integrity around migrations;
6. keep schema/migration checks in CI.

Schema v1 is published in alpha.2. Schema v2 is the current additive Tracker migration with v1 as supported predecessor.

A later maintenance build that claims alpha.2 compatibility must preserve an explicit tested path from schema v1. Any schema v3+ change must have a concrete maintenance/security/compatibility reason, migrate forward explicitly, and must not silently reinterpret semantic values, delete content, or recreate the database to avoid migration.

Compatibility repairs for already-published semantic invariants, such as the alpha.2 `journal_metadata` singleton repair for older development journals, must be transactional, idempotent, tested, and must not conceal genuine corruption.

## Review rule

A schema change is a data-compatibility/security maintenance change, not a private implementation detail.

Any post-freeze change to tables, semantic values, constraints, or migration behavior must:

- have a concrete maintenance/security/compatibility justification;
- preserve the frozen product semantics;
- update schema snapshots/migration tests;
- update relevant documentation;
- update `CHANGELOG.md` when release-facing;
- update `PROJECT.md` in the same PR.
