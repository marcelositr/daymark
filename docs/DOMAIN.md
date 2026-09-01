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

## Locations and modules

Entries may belong to method-native locations such as:

- Daily Log;
- Monthly Log;
- Future Log;
- Collection.

The Index and Search are retrieval/navigation structures rather than owners of duplicated entry content.

Reflection is a method behavior and may have its own records or workflow, but it is not an `EntryType`.

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

- `>` means a deliberate forward migration, such as into the next Monthly Log or an appropriate Collection;
- `<` means a deliberate scheduling action into the Future Log.

When an item from the Future Log becomes current and is brought into a Monthly Log, that movement must remain traceable even when the entry is an Event and therefore has no Task state.

Migration should normally create a destination entry while retaining the source as historical evidence of the decision. This preserves chronology and makes migration lineage inspectable.

## Collection references versus migration

Daymark distinguishes two different actions:

1. **Reference/link** — an entry remains in its original chronological location and is also discoverable from a Collection. This does not change task state.
2. **Migration to a Collection** — the user deliberately moves the item according to the Bullet Journal migration process. A migration relationship is recorded and an applicable source task becomes `migrated`.

This distinction prevents Collections from becoming a hidden second task manager while still allowing useful digital cross-reference.

## Identity and history

Every persisted entry must have a stable identifier independent of its text, date, symbol, language, or screen position.

Editing content must not silently change semantic identity. Migration history and relationships must refer to stable IDs rather than copied display text.

The exact database schema may evolve, but these semantics must remain explicit in migrations and compatibility code.