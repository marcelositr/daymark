# Domain

## Purpose

This document defines Daymark's journal semantics. It describes the current behavior that implementation changes should preserve.

## Core journal structures

Daymark has three Log kinds:

- **Daily Log** — one method date
- **Monthly Log** — one calendar month
- **Future Log** — one future month bucket

It also has **Collections**, which are deliberate topic/project containers.

## Entries

Every journal Entry has one type:

- **Task**
- **Event**
- **Note**

Tasks additionally have one state:

- `open`
- `completed`
- `migrated`
- `scheduled`
- `discarded`

Events and Notes do not carry Task state.

## Ownership

Every Entry has exactly one owning placement:

- a Log, or
- a Collection

A Collection reference is not ownership. It exposes an existing Entry inside a Collection while leaving the Entry in its original owner.

## Daily Log

Today is the writable Daily Log for the current method date.

The Daily Log supports Rapid Logging for Tasks, Events, and Notes.

Earlier Daily Logs are historical and read-only.

### Daily Reflection

Reflection isolates unresolved Tasks so the user deliberately decides what happens next. An open Task may be:

- completed
- migrated forward
- scheduled to a Future month
- migrated to a Collection
- discarded

Reflection is intentionally deliberate. Daymark must not silently decide Task outcomes.

## Monthly Log

The current Monthly Log has three views:

- **Calendar**
- **Tasks**
- **Tracker**

Historical Monthly Logs are read-only.

### Calendar

Calendar entries are dated and may be:

- Event
- Task

A dated Calendar Task remains a Task and therefore participates in normal Task state transitions.

### Monthly Tasks

The Tasks view contains the month's undated Task list and supports deliberate reflection over unresolved Tasks.

## Future Log

The primary Future Log is a rolling six-month horizon beginning with the month after the current month.

Future entries may be Tasks, Events, or Notes.

When a Future month becomes the current month, Daymark exposes an arrival review:

- an open Future Task may migrate to the matching Monthly Tasks list
- a Future Event may migrate to a selected date in the matching Monthly Calendar
- an open Future Task may also be completed or discarded

Future arrival is not an automatic transfer.

## Migration and scheduling

Daymark preserves history by creating a new destination Entry and recording lineage instead of moving the source Entry in place.

For a Task:

- forward migration marks the source `migrated`
- scheduling to a Future Log marks the source `scheduled`
- the destination Task starts `open`

Signifiers are copied to the destination Entry.

An Entry may have only one direct outgoing migration.

## Collections

A Collection may contain:

- Entries it owns
- references to Entries owned elsewhere

Moving an open Task to a Collection is a real migration and therefore creates a new destination Entry with lineage.

Adding a reference does not copy or move the source Entry.

## Index

The Index is deliberate persisted structure. It references existing Logs or Collections.

The Index:

- does not duplicate Entry content
- is not generated automatically
- may be reordered
- may remove references without deleting the target structure

## Search

Search is local and read-only.

Search may filter by:

- text
- built-in Signifiers
- text plus Signifiers

Search never creates Index items, changes ownership, or mutates Entry state. Results retain the Entry's real owner so navigation returns to the source context.

## Signifiers

Built-in Signifiers are:

- priority
- inspiration
- explore

They are metadata attached to an Entry and follow that Entry when Daymark creates a migrated destination copy.

## Trackers

Trackers are a **Daymark adaptation**, not a claim about canonical Bullet Journal rules.

A Tracker has:

- start date
- planned end date
- optional early end date
- one of five color slots
- explicit daily marks

Marks are:

- `+1` fulfilled
- `-1` not fulfilled
- no stored mark = neutral/unmarked

At most five Trackers may overlap the same period.

Ending a Tracker early removes marks after the chosen end date.

## Method-fidelity rule

When a digital convenience conflicts with deliberate reflection, migration, or user ownership of journal decisions, preserve the deliberate method behavior unless the maintainer explicitly changes product direction.
