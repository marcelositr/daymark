# Domain semantics

## Purpose

This document defines Daymark's core Bullet Journal semantics independently of Flutter widgets, database tables, translated strings, or platform behavior.

The model should remain small enough to preserve the method while being explicit enough to evolve without reinterpreting old journal data.

## Entry types

Daymark has exactly three core entry types:

- `task` — an actionable item, rendered with `•` while open;
- `event` — a date-related occurrence, rendered with `○`;
- `note` — information, thought, observation, or fact, rendered with `–`.

Additional meaning must not be introduced by creating extra entry types such as `important`, `meeting`, `email`, `idea`, or `delegated`. Those concerns belong to content, signifiers, relationships, or future optional features.

Rendered symbols are presentation. Persistence and business logic use stable language-neutral semantic identifiers.

## Task lifecycle

Tasks have the following semantic states:

- `open` — not yet resolved;
- `completed` — intentionally completed, normally rendered as `×`;
- `migrated` — intentionally moved forward, normally rendered as `>`;
- `scheduled` — intentionally moved to the Future Log, normally rendered as `<`;
- `discarded` — intentionally judged no longer worth doing.

Discarding a task is not the same operation as deleting data. A discarded task remains part of the journal record. Permanent deletion is a separate destructive data operation and must never be represented as a Bullet Journal task state.

Events and notes do not inherit task states merely for implementation convenience.

## Signifiers

Signifiers add context to an entry without changing its entry type.

The domain must support zero or more signifiers per entry. The initial built-in vocabulary may include the conventional concepts:

- `priority` (`*`);
- `inspiration` (`!`);
- `explore`.

Signifier identity must be separate from its displayed symbol or localized label so that future user-defined signifiers can be added without changing the entry schema or inventing new entry types.

## Locations and chronological logs

Entries may belong to method-native locations such as:

- Daily Log;
- Monthly Log;
- Future Log;
- Collection.

The Index and Search are retrieval/navigation structures rather than owners of duplicated entry content. A Search result is a transient view of an existing Entry and never changes that Entry's identity, owner, content, or Task state.

Reflection is a method behavior and may have its own records or workflow, but it is not an `EntryType`.

### Daily Log

A Daily Log belongs to one method date.

Rapid Logging may capture Task, Event, or Note entries there. Advancing to a new day does not silently migrate unresolved entries.

Historical retrieval of a Daily Log is non-creating: asking to view a method date that has no persisted Daily Log must return absence rather than inventing an empty Log. A past Daily Log remains historical evidence and is read-only in the current product; retrieval does not grant capture, Task actions, migration, scheduling, references, completion, or discard through the historical surface.

Today remains the interactive current Daily Log. Navigating historical dates is retrieval over existing chronology, not a change of Entry ownership or an alternative calendar model.

### Monthly Log

A Monthly Log belongs to one month.

Its two semantic sections are distinct:

- `calendar` — date-addressed Event placements within that month;
- `tasks` — monthly Task placements without a calendar date.

A Monthly Calendar date must belong to its owning month. A Monthly Task does not acquire a hidden day merely because a UI could display one.

### Future Log

A Future Log bucket belongs to one month and is **month-addressed rather than day-addressed**.

Task, Event, and Note entries may be captured into that future month. A Future Log entry does not acquire a `monthly_section` or a `monthly_calendar_date`.

The product may show a rolling subset of future months, but visibility does not change ownership or delete older Future data.

Capturing a new entry directly in Future is different from scheduling an existing entry into Future. Scheduling must create deliberate migration lineage.

## Index

The Index is a deliberate ordered set of references to journal structures such as Logs and Collections.

An Index item targets a Log or Collection as a structure. It does not target an individual Entry directly in the current model.

Adding a structure to the Index:

- does not create or duplicate an Entry;
- does not change ownership of any Entry;
- does not change Task state;
- does not create a new Log or Collection;
- does not happen automatically merely because a structure exists.

A given Log or Collection appears at most once in the Index. Index order records the user's deliberate catalog order rather than being inferred from timestamps, Search relevance, or chronological ownership.

Search is not the Index. Search may derive transient results from journal content, while the Index persists structures that the user intentionally chose to catalog.

## Search

Search is a transient read model over existing journal Entries. Matching an Entry does not create a new Entry, placement, Collection reference, migration edge, or Index item.

A Search result preserves and reports the source Entry's stable identity, entry type, Task state when applicable, and actual owning context. Daily, Monthly, Future, and Collection ownership remain authoritative; Search never becomes an owner itself.

The current product matches submitted text against Entry content only. Query interpretation, result ranking, filtering, Collection-title search, and navigation to the source are presentation/retrieval concerns that may evolve without changing ownership or history semantics.

## Migration

Migration is always deliberate.

Daymark must never silently migrate unresolved items because a date changed or because software can automate the action.

A migration records lineage rather than overwriting history. The model must preserve, at minimum:

- source entry identity;
- destination entry identity when a new destination entry is created;
- source location;
- destination location;
- migration kind;
- timestamp.

For a task:

- `>` means a deliberate forward migration into an appropriate non-Future destination;
- `<` means a deliberate scheduling action into the Future Log.

Only an open Task can change to migrated/scheduled Task state. A completed, discarded, migrated, or scheduled Task must not be moved again as though it were still open.

The current product exposes Task scheduling from Daily/Today and Monthly Tasks into Future, and forward Task migration from Daily/Today and Monthly Tasks into an existing Collection. Those UI flows are intentionally Task-only even though the underlying movement model can preserve lineage for Events or Notes when a future product flow legitimately requires it.

Scheduling an open Task preserves the historical source in its original owner with `scheduled` state and creates a new open Task in the chosen Future bucket. The destination is not an in-place ownership mutation of the source.

Migrating an open Task to a Collection preserves the historical source in its original chronological owner with `migrated` state and creates a new open Task owned by the deliberately selected Collection. The Collection must already exist; migration does not silently create or choose a destination.

When an item from the Future Log becomes current and is brought into a Monthly Log, that movement must remain traceable even when the entry is an Event and therefore has no Task state.

Migration should normally create a destination entry while retaining the source as historical evidence of the decision. This preserves chronology and makes migration lineage inspectable.

A migrated or scheduled destination Task begins as a new open Task in its destination. The source Task retains the terminal state that records the decision. Events and Notes may move with lineage without acquiring Task state.

A Future destination uses scheduling semantics. A normal `migrated` operation must not target Future merely because both operations happen to create destination entries.

Forward migration (`>`) must use a method-faithful non-Future destination such as the next Monthly Log or an appropriate Collection. The current Monthly Log is not a shortcut destination for a Today Task merely because it is already available in the UI.

One source entry may have at most one direct outgoing migration. Product UI must not offer contradictory second movement after the source already has outgoing lineage.

## Collection references versus migration

Daymark distinguishes two different actions:

1. **Reference/link** — an entry remains in its original chronological location and is also discoverable from a Collection. This does not change task state.
2. **Migration to a Collection** — the user deliberately moves the item according to the Bullet Journal migration process. A migration relationship is recorded and an applicable source task becomes `migrated`.

This distinction prevents Collections from becoming a hidden second task manager while still allowing useful digital cross-reference.

The current product exposes deliberate references from Today, Monthly, and Future entries into an existing Collection. A reference keeps the same Entry identity, owner, content, and Task state; the Collection presents it separately as read-only content rather than granting ownership-level Task actions.

## Immediate capture undo

Immediate capture Undo is a narrow correction operation for an accidental fresh
capture. It is not `discarded`, is not an Entry type or Task state, and must not
become a generic historical delete path.

The operation may destroy only an Entry that is still pristine after capture.
If the Entry has been semantically changed or participates in migration,
scheduling, Collection references, signifiers, or other journal relationships,
Undo must fail rather than rewrite history.

## Identity and history

Every persisted entry must have a stable identifier independent of its text, date, symbol, language, or screen position.

Editing content must not silently change semantic identity. Migration history and relationships must refer to stable IDs rather than copied display text.

An entry is not moved between owners in place to simulate migration. The historical source placement remains part of the journal record and the destination receives its own identity.

The exact database schema may evolve, but these semantics must remain explicit in migrations and compatibility code.
