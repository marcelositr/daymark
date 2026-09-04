# Product principles

## Purpose

Daymark exists to provide a faithful digital implementation of the Bullet Journal method without turning personal organization into a productivity platform.

The application should help the user capture, reflect, migrate, discard, and retrieve information with as little interface friction and distraction as possible.

## Digital minimalism

Daymark deliberately avoids features whose primary purpose is to increase engagement with the application.

The product must not introduce:

- advertising;
- feeds;
- streaks, badges, XP, or gamification;
- productivity scores;
- attention-seeking notifications;
- unsolicited suggestions;
- dashboards for the sake of dashboards;
- social or collaborative features in the core product;
- AI-generated journal content;
- automatic decisions that replace intentional reflection.

Animations must be restrained and functional. Colors, typography, navigation, and persistent controls must remain minimal.

## Method fidelity

The core vocabulary is intentionally small:

- task;
- event;
- note;
- Daily Log;
- Monthly Log;
- Future Log;
- Collection;
- Index;
- Migration;
- Reflection.

Migration is a deliberate decision. Unresolved entries must never be silently rolled forward merely because software can automate it.

The detailed domain semantics are defined in `docs/DOMAIN.md`.

## Current chronological product shape

The initial digital implementation keeps the method-native chronological surfaces distinct instead of merging them into a general planner.

### Daily Log / Today

Today represents the current Daily Log and supports Rapid Logging of Task, Event, and Note entries.

The date changes automatically at the method-day boundary, but unresolved entries are not automatically migrated because the calendar advanced.

Earlier Daily Logs may be opened through a dedicated **read-only historical route**. Historical Daily browsing must not create a missing Daily Log merely because the user views that date and must not expose capture, Task actions, migration, scheduling, references, completion, or discard.

A historical day that has never existed therefore appears empty without becoming persisted state or an Index candidate. Historical navigation may move between earlier dates but must not advance into Today as though the current Daily Log were historical. Returning to Today restores the normal interactive Rapid Logging surface.

This history surface is retrieval, not a generic calendar workspace or reflection engine. Direct Index/Search navigation to a historical Daily route is intentionally deferred to a focused retrieval-navigation slice now that a real Daily historical destination exists.

### Monthly Log

Monthly preserves the method's two different areas:

- **Calendar**: one row per date, with dated Event entries;
- **Tasks**: a monthly Task list.

The **current month** remains the active Monthly Log and supports capture plus deliberate Task actions.

Earlier Monthly Logs may be browsed month by month in **read-only historical mode**. Historical browsing must not create a missing Monthly Log merely because the user navigates to that month, must not expose capture or Task actions, and must not allow navigation forward past the current month into a future Monthly Log.

A historical month that has never existed therefore appears empty without becoming persisted state or an Index candidate. Returning to the current month restores the normal interactive Monthly behavior.

This history surface is retrieval, not a reflection engine or generic agenda. Future editing of historical Monthly Logs, direct Index/Search navigation to an arbitrary historical month, and richer Monthly reflection remain separate product decisions.

### Future Log

The initial Future Log is a rolling overview of **six future months**, beginning with the month immediately after the current month.

Each month is a month-addressed bucket. Future does not assign entries to a day inside that month and must not become a second day-level calendar.

Rapid Logging may place Task, Event, and Note entries into the selected future month. Scheduling an existing open Task into Future is a separate deliberate movement action, not the same as capturing a new Future entry.

When the current month advances, the visible Future horizon rolls forward. Existing historical data remains persisted in its original month bucket even when that bucket falls outside the six-month overview.

### Collections

Collections are deliberate topic/project-oriented journal containers, not generic configurable workspaces.

The Collection surface supports:

- listing and creating Collections;
- opening one Collection;
- Rapid Logging Task, Event, and Note entries owned by that Collection;
- completing or discarding open Tasks inside that Collection;
- receiving deliberately migrated open Tasks from Today or Monthly Tasks;
- displaying deliberate references to Today, Monthly, and Future entries in a separate read-only section.

Collections deliberately do not gain Kanban fields, arbitrary properties, dashboards, or planner abstractions. Collection references and migration remain distinct domain operations.

A **Collection reference** does not move or copy the source entry. The source remains owned by its original Daily, Monthly, or Future Log with the same stable Entry identity and Task state. The Collection displays that entry as a reference only, and Task actions are not exposed through the reference. The user must deliberately choose an existing Collection; Daymark does not auto-select or create a Collection as a side effect.

Removing references, navigating from a reference back to its source, and referencing Collection-owned entries from inside Collections remain separate product decisions.

### Index

The Index is a deliberate Bullet Journal catalog of existing journal structures. It is persisted independently from Search and never duplicates Entry content.

The first Index surface supports:

- listing indexed Logs and Collections in deliberate Index order;
- adding an existing Daily, Monthly, or Future Log to the Index;
- adding an existing Collection to the Index;
- excluding a structure once it has already been indexed.

Adding something to the Index does not move it, copy it, change Entry ownership, alter Task state, or create a new Log or Collection. Daymark never auto-indexes every structure merely because the software can discover it.

The initial Index appends new items in the order the user chooses them. Reordering, removing Index items, and navigating an Index row directly to an arbitrary historical Log remain separate focused slices. Direct navigation must use real product routes rather than pretending the current Today/Monthly/Future screens can represent an arbitrary historical target.

Search remains a separate retrieval mechanism. A Search result does not become a persistent Index item unless the user makes an explicit future product action that says so.

### Search

Search is an explicit local retrieval surface over existing Entry content. It is not another owner, Collection, or persistent catalog.

The first Search surface:

- runs only after the user deliberately submits text;
- performs case-insensitive literal substring matching over existing Entry content;
- shows the result's real Entry type/Task state and owning Daily, Monthly, Future, or Collection context;
- remains read-only and exposes no Task, migration, scheduling, reference, or ownership actions;
- presents a quiet prompt before a query and a quiet empty state when nothing matches;
- refreshes the last submitted query when the retained Search section becomes active again so Task state does not remain stale after work elsewhere.

Search does not create Entries, Collection references, or Index items. It does not persist query history, maintain a Search cache, or introduce a relevance/ranking engine in this slice. Direct navigation from a result to its source, Collection-title search, richer filtering, and any future full-text indexing remain separate product decisions.

### Migration and scheduling

Migration and scheduling must use real method-native destinations.

Do not invent temporary planner buckets, fake destinations, or automatic rollover rules merely to make a migration UI easier to implement.

The current product exposes **scheduling (`<`) for open Tasks in Today and Monthly**. The user deliberately chooses one of the six visible Future months. The historical source stays in place with scheduled state, and the selected Future month receives a fresh open Task with lineage back to the source.

The current product also exposes **forward migration (`>`) for open Tasks in Today and Monthly Tasks into an existing Collection**. The user deliberately chooses the destination Collection. The historical source stays in place with migrated state, and the chosen Collection receives a fresh open Task with lineage back to the source. Daymark does not choose a Collection automatically and does not create one as a side effect of migration.

Cross-surface movement or referencing must be immediately visible when the user navigates to its destination. Retained navigation state is not permission to show stale Future or Collection snapshots after a write from another section.

A Future destination always uses scheduling semantics. A normal forward migration (`>`) uses a valid non-Future destination according to the method.

Daymark does **not** treat the current Monthly Log as a shortcut destination for a Today Task merely because that container already exists. Existing Collections are the first deliberately exposed forward-migration destination. Migration from Future or from Collection-owned entries, and migration to a future Monthly Log, remain separate product decisions rather than implicit extensions of this flow.

## Immediate capture correction

A successful capture in Today, Monthly, Future, or a Collection may expose a
short-lived **Undo** action as mechanical error correction.

Undo is deliberately not a general Edit/Delete feature and is not a new Bullet
Journal task state. It may reverse only the freshly captured Entry while that
Entry is still untouched and has no migration, Collection reference, signifier,
or other journal relationship. Once the Entry participates in journal history,
normal method actions such as completion, migration, scheduling, reference, and
discard remain authoritative.

The visible Undo window is presentation behavior rather than a persistence rule.

## Local-first

The journal belongs to the user.

Daymark must work without an account or network connection. Core functionality must never depend on a remote service.

User data must be exportable in documented, non-proprietary formats. A user must remain capable of recovering meaningful data even if Daymark itself is no longer available.

## Initial platforms

The supported targets for the first development phase are:

- Linux;
- Android.

The domain and application layers must not depend on platform-specific APIs. Windows, macOS, and iOS are future targets, not current scope.

## Languages and localization

Daymark is multilingual by design, not as a later retrofit.

The initial product languages are:

- English;
- Portuguese (Brazil).

English is the canonical source locale and the product fallback locale.

On first run, Daymark follows the operating-system locale only when it matches a supported product locale. An exact Brazilian Portuguese locale selects `pt_BR`; English locales select English; unsupported locales fall back to English. A future explicit user language override takes precedence over system detection.

The Flutter localization generator requires a parent `pt` resource when `pt_BR` exists. That parent resource is a technical generation fallback and does not expand the initial product-language promise beyond English and Portuguese (Brazil).

Product behavior, domain rules, persistence values, and identifiers must never depend on translated display strings.

The interface must avoid layout assumptions that make future right-to-left languages unnecessarily difficult to support. Hebrew, Arabic, and other RTL languages are future possibilities, not part of the initial release scope.

## Navigation

The journal navigation model contains:

- Today;
- Monthly;
- Future;
- Collections;
- Search;
- Index.

The exact control used to reach them differs by screen size. Wider desktop layouts expose all six directly in the navigation rail. Compact/mobile layouts keep Today, Monthly, Future, and Collections as direct bottom destinations and use a minimal **More** destination for Search and Index rather than crowding six items into the bottom bar.

Grouping Search and Index under the same compact navigation entry does not merge their product meaning. The Index remains a deliberate persisted Bullet Journal structure; Search remains query-driven retrieval.

Historical Daily navigation is contextual under Today rather than a seventh top-level destination. The current Daily Log stays the primary Today surface while `/daily/:date` represents explicit read-only retrieval of a past method date.

Reflection is contextual rather than a permanent top-level workspace. Reflection actions should appear where they belong, such as Daily or Monthly review flows.

Settings are secondary application controls and must not compete with journal navigation.

## Visual direction

Daymark supports light and dark appearance, with a system-following option where the platform provides one.

The shared visual metaphor is a minimal dotted notebook or sketchbook page:

- restrained dotted background;
- comfortable page-like spacing;
- strong emphasis on journal content;
- minimal chrome;
- light and dark palettes designed as equivalent reading surfaces rather than unrelated themes.

The notebook metaphor is visual, not structural. Daymark is not a freeform canvas, drawing application, ruler tool, page designer, or drag-and-drop layout system.

Linux and Android should feel like the same journal while using layouts appropriate to each form factor. The interface should preserve usable screen space on phones rather than drawing decorative notebook hardware, bindings, page shadows, or other literal simulations.

## Feature test

Before adding a feature, ask:

1. Does it support capture, reflection, migration, retrieval, or another core part of the method?
2. Does it reduce mechanical friction without removing a conscious decision?
3. Does it keep the user's attention on their journal rather than on Daymark itself?
4. Can it remain understandable without configuration overhead?
5. Does it use an existing method-native concept instead of inventing a parallel productivity abstraction?

If the answer is no, the feature probably does not belong in Daymark.
