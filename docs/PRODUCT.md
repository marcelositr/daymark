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

### Monthly Log

The first Monthly implementation represents the **current month** only.

It preserves the method's two different areas:

- **Calendar**: one row per date, with dated Event entries;
- **Tasks**: an open monthly Task list.

Historical month browsing may be added later, but it must not change the meaning of the current-month Monthly Log or turn it into a generic agenda.

### Future Log

The initial Future Log is a rolling overview of **six future months**, beginning with the month immediately after the current month.

Each month is a month-addressed bucket. Future does not assign entries to a day inside that month and must not become a second day-level calendar.

Rapid Logging may place Task, Event, and Note entries into the selected future month. Scheduling an existing open Task into Future is a separate deliberate movement action, not the same as capturing a new Future entry.

When the current month advances, the visible Future horizon rolls forward. Existing historical data remains persisted in its original month bucket even when that bucket falls outside the six-month overview.

### Collections

Collections are deliberate topic/project-oriented journal containers, not generic configurable workspaces.

The first Collection surface supports:

- listing and creating Collections;
- opening one Collection;
- Rapid Logging Task, Event, and Note entries owned by that Collection;
- completing or discarding open Tasks inside that Collection.

Collections deliberately do not gain Kanban fields, arbitrary properties, dashboards, or planner abstractions. Collection references and migration remain distinct domain operations. The first Collection UI does not yet expose references from chronological logs or deliberate forward migration (`>`).

### Migration and scheduling

Migration and scheduling must use real method-native destinations.

Do not invent temporary planner buckets, fake destinations, or automatic rollover rules merely to make a migration UI easier to implement.

The current product exposes **scheduling (`<`) for open Tasks in Today and Monthly**. The user deliberately chooses one of the six visible Future months. The historical source stays in place with scheduled state, and the selected Future month receives a fresh open Task with lineage back to the source.

Scheduling must be immediately visible when the user navigates to Future. Retained navigation state is not permission to show stale journal snapshots after a cross-surface write.

A Future destination always uses scheduling semantics. A normal forward migration (`>`) must use another valid non-Future destination according to the method.

Daymark does **not** treat the current Monthly Log as a shortcut destination for a Today Task merely because that container already exists. Forward-migration UI remains deferred until a method-faithful destination is intentionally exposed for migration. Collections now provide a real owning structure, but simply existing is not enough to expose `>` without a deliberate destination-selection flow and corresponding lifecycle tests.

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

The primary product destinations are:

- Today;
- Monthly;
- Future;
- Collections;
- Search.

The exact control used to reach them may differ by screen size. Desktop can keep these destinations visible in a compact sidebar or equivalent navigation. Android may move Search to a global action when five persistent destinations would create unnecessary clutter.

The Index remains a deliberate Bullet Journal structure and is not replaced by Search. It should remain directly accessible from the journal navigation model and may appear as an additional sidebar destination on wider layouts.

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
