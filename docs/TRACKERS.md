# Trackers

## Status

Trackers are an **optional Daymark adaptation** for deliberate daily observation and reflection and are part of Daymark's frozen product scope.

They are not presented as a mandatory or canonical part of Ryder Carroll's core Bullet Journal method. Daymark keeps the method-native structures authoritative: Daily Log, Monthly Log, Future Log, Collections, Index, Rapid Logging, Migration, and Reflection.

Bullet Journal community and official-site examples have used habit/behavior trackers as optional spreads or Collections. Daymark uses that broader compatible practice as context, but the exact model here is Daymark-specific.

The Daymark Tracker also has an explicit maintainer origin: it is based on Marcelo Trindade's personal paper practice of recording daily commitments and manually drawing their trajectories in a notebook. The digital adaptation removes the repetitive mechanical work of redrawing that graph while preserving the deliberate daily mark and later reflection.

Nothing in the UI or documentation should imply that the graph, `+1 / 0 / -1` encoding, five-color limit, or responsive layout is an official Bullet Journal rule.

Useful background from the Bullet Journal site:

- <https://bulletjournal.com/blogs/bulletjournalist/puppies-chains-and-jerry-seinfeld>
- <https://bulletjournal.com/blogs/bulletjournalist/intentional-habit-tracking>

## Frozen scope

Tracker behavior is feature-complete. Maintenance may fix bugs, accessibility regressions, compatibility/data issues, or supported-platform rendering problems, but must not expand the Tracker product.

In particular, Daymark does not plan:

- reflection-note fields attached to Trackers;
- "create new from this" / clone/renew convenience actions;
- starting a Tracker from a Daily Entry;
- configurable colors, styles, axes, graph types, or analytics;
- extra simultaneous slots beyond the existing five-color model;
- reminders, notifications, streaks, scores, rankings, goals, predictions, or gamification;
- automatic renewal or continuation;
- new Tracker ownership/Entry semantics.

Historical references to such ideas in older commits are not roadmap commitments.

## Product purpose

A Tracker represents one finite commitment, practice, or observation period, for example:

- devotional practice;
- a novena;
- Lent;
- reading a small amount each day;
- walking the dog;
- not smoking for a deliberately chosen period;
- another user-defined commitment that benefits from daily observation.

The loop is intentionally small:

```text
commitment -> daily mark or absence -> trajectory -> reflection
```

The graph is a reflection surface. It is not a score, prediction, diagnosis, productivity dashboard, or substitute for the user's own interpretation.

## Daily semantics

For every day inside a Tracker's active period:

- `+1` means the user explicitly marked the commitment as fulfilled for that day;
- `-1` means the user explicitly marked the commitment as not fulfilled for that day;
- `0` means the user made no explicit mark for that day.

The user never selects `0` directly. Removing an existing positive or negative mark returns that day to absence and therefore to `0` in the graph.

`0` is not failure. It means **no recorded mark**.

Outside the active period there is no datum. The graph must not draw zero-valued history before start or after effective end merely to fill visual space.

## Lifecycle

A Tracker has:

- a title;
- a deliberate start method date;
- a deliberate planned end method date;
- one of five fixed visual slots/colors;
- zero or more explicit daily marks (`+1` or `-1`);
- an optional early-end method date.

A Tracker is interpreted as:

- **planned** before its start date;
- **active** from its start through its effective end while the period is current;
- **completed** after reaching its planned end without being ended early;
- **ended** when the user deliberately stops it before the planned end.

The persisted state does not need a mutable status flag when status can be derived unambiguously from dates. An early end is deliberate and preserves history through the chosen end date.

Completion or early ending does not create a reflection-note record. Reflection remains the user's interpretation of the trajectory rather than a required Tracker field.

A finished Tracker remains finished. Daymark does not automatically renew, extend, clone, or restart it. A new commitment is created as a separate new Tracker through the existing creation flow.

## Simultaneous limit and colors

At most **five Trackers may overlap on the same method date**.

The limit exists for readability and focus, not as a subscription/configuration limit. One combined graph is the intended reflection view; too many simultaneous trajectories undermine that purpose.

The five visual identities are fixed slots. Daymark does not expose a color picker. A slot may be reused by another Tracker only when their active periods do not overlap.

To keep one Tracker's color stable across its whole history, creation requires one slot to be free for the Tracker's entire proposed period. In fragmented schedules this can be stricter than merely counting five Trackers on each individual day. Stable visual identity is preferred over silently recoloring history.

Color is the main visual identity, but the existing accessibility semantics must keep the data understandable without relying solely on color. Accessibility fixes may strengthen non-color semantics when required, but must not turn Tracker into a configurable chart designer.

## Graph semantics

The graph contains all Trackers that intersect the displayed month, subject to the simultaneous five-Tracker invariant.

For the normal month view:

- one axis is method day within the displayed month;
- the value axis contains exactly `+1`, `0`, and `-1`;
- explicit marks land exactly on `+1` or `-1`;
- absence inside active period lands exactly on `0`;
- no line exists outside active periods.

Lines may use restrained smooth Bezier transitions between adjacent daily points. Smoothing is presentation only: control points must not overshoot the semantic `+1 / 0 / -1` range, and actual daily points remain visible so the curve cannot be mistaken for measured intermediate values.

The graph may visually show recovery after a difficult day, but Daymark does not congratulate, shame, score, rank, or interpret the trajectory for the user.

## Responsive hierarchy

The approved responsive principle is **data first, graph second**, approximately a `2/3 : 1/3` hierarchy.

### Portrait / tall compact screen

Daily data/controls occupy roughly two thirds of the width. The graph occupies roughly one third as a vertical strip.

To avoid compressing a month into a narrow horizontal strip, method days run along the long vertical dimension while `-1 / 0 / +1` span the narrow horizontal dimension.

### Landscape / wide screen

Daily data/controls occupy roughly two thirds of the height. The graph occupies roughly the lower third and uses available width, with method days running horizontally.

The ratio is a hierarchy rather than a pixel contract. Maintenance adaptations for text scale, safe areas, supported device sizes, or desktop window constraints are allowed when they preserve data-first hierarchy and the existing semantics.

## Placement in Daymark

Tracker is not a top-level navigation destination.

Monthly is the administration/reflection home, with:

- Calendar;
- Tasks;
- Tracker.

Today may show active Trackers as a compact daily marking surface. Today does not create a Task every day and does not turn a Tracker into an Entry.

Daymark does not convert a Daily Entry into a Tracker and does not expose an Entry-to-Tracker creation action under the frozen scope.

Historical Monthly views remain read-only. They may display Tracker trajectories intersecting that month, but do not allow creation, marking, ending, or other mutation.

## Deliberate exclusions

Tracker does not gain:

- streak counters;
- badges, trophies, XP, confetti, or gamification;
- productivity scores or success percentages used as judgment;
- rankings between Trackers;
- automatic goal suggestions;
- automatic renewal;
- aggressive reminders;
- moralized labels for `0` or `-1`;
- predictive trend claims;
- configurable analytics dashboards;
- clone/restart convenience workflows;
- attached reflection-note records;
- additional chart customization systems.

These are frozen exclusions, not a feature backlog.

## Fidelity rule

The implementation should be described accurately:

> Daymark Tracker is an optional digital adaptation inspired by tracking practices used in Bullet Journals and by the maintainer's personal practice of manually graphing daily commitments.

That attribution is intentional. Daymark can adapt the medium without pretending its own inventions are canonical Bullet Journal rules.
