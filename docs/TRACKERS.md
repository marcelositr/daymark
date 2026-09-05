# Trackers

## Status

Trackers are an **optional Daymark adaptation** for deliberate daily observation and reflection.

They are not presented as a mandatory or canonical part of Ryder Carroll's core Bullet Journal method. Daymark keeps the core method-native structures authoritative: Daily Log, Monthly Log, Future Log, Collections, Index, Rapid Logging, Migration, and Reflection.

Bullet Journal community and official-site examples have long used habit/behavior trackers as optional spreads or Collections. Daymark uses that broader compatible practice as context, but the exact model in this document is Daymark-specific.

The Daymark Tracker also has an explicit maintainer origin: it is based on Marcelo Trindade's personal paper practice of recording daily commitments and manually drawing their trajectories in a notebook. The digital feature exists mainly to remove the repetitive mechanical work of redrawing that graph while preserving the deliberate daily mark and later reflection.

Nothing in the UI or documentation should imply that the graph, the `+1 / 0 / -1` encoding, the five-color limit, or the responsive layout described here is an official Bullet Journal rule.

Useful background from the Bullet Journal site:

- <https://bulletjournal.com/blogs/bulletjournalist/puppies-chains-and-jerry-seinfeld>
- <https://bulletjournal.com/blogs/bulletjournalist/intentional-habit-tracking>

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

The user never selects `0` directly. Removing an existing positive or negative mark returns that day to the absence state and therefore to `0` in the graph.

`0` is not failure. It means **no recorded mark**.

Outside the Tracker's active period there is no datum. The graph must not draw zero-valued history before the start or after the effective end merely to fill visual space.

## Lifecycle

A Tracker has:

- a title;
- a deliberate start method date;
- a deliberate planned end method date;
- one of five fixed visual slots/colors;
- zero or more explicit daily marks (`+1` or `-1`);
- an optional early-end method date.

A Tracker may therefore be interpreted as:

- **planned** before its start date;
- **active** from its start through its effective end while the period is current;
- **completed** after reaching its planned end without being ended early;
- **ended** when the user deliberately stops it before the planned end.

The persisted state does not need a mutable status flag when the status can be derived without ambiguity from the dates. An early end is deliberate and preserves all history through the chosen end date.

A normal completion or early end may later support a reflection note, but no reflection text is required merely to make the Tracker valid.

Continuing a finished Tracker must be another deliberate action. A future "create new from this" convenience may copy its structure, but Daymark must not renew or extend Trackers automatically.

## Simultaneous limit and colors

At most **five Trackers may overlap on the same method date**.

The limit exists for readability and focus, not as an arbitrary subscription or configuration limit. One combined graph is the intended reflection view; too many simultaneous trajectories undermine that purpose.

The five visual identities are fixed slots. Version 1 does not expose a color picker. A slot may be reused by another Tracker only when their active periods do not overlap. To keep one Tracker's color stable across its whole history, creation requires one slot to be free for the Tracker's entire proposed period; in unusual fragmented schedules this can be stricter than merely counting five Trackers on each individual day. Version 1 deliberately prefers stable visual identity over silently recoloring existing Tracker history.

Color is the primary visual identity, but the graph should remain understandable when a line is focused individually. Future accessibility work may add a secondary distinction if color alone proves insufficient; that must not turn the feature into a configurable chart designer.

## Graph semantics

The graph contains all Trackers that intersect the month being viewed, up to the simultaneous five-Tracker invariant.

For the normal month view:

- one axis is the method day within the displayed month;
- the value axis contains exactly `+1`, `0`, and `-1`;
- explicit marks land exactly on `+1` or `-1`;
- absence inside the active period lands exactly on `0`;
- no line exists outside the Trackers' active periods.

Lines may use restrained smooth Bezier transitions between adjacent daily points. Smoothing is presentation only: control points must not overshoot the semantic `+1 / 0 / -1` range, and the actual daily points remain visible so the curve cannot be mistaken for measured intermediate values.

The graph may visually show recovery after a difficult day, but Daymark itself does not congratulate, shame, score, or interpret the trajectory for the user.

## Responsive hierarchy

The approved responsive principle is **data first, graph second**, approximately a `2/3 : 1/3` hierarchy.

### Portrait / tall compact screen

The daily data/controls occupy roughly two thirds of the width. The graph occupies roughly one third as a vertical strip.

To avoid compressing an entire month into a narrow horizontal strip, the graph transposes its axes in this layout: method days run along the long vertical dimension while `-1 / 0 / +1` span the narrow horizontal dimension.

### Landscape / wide screen

The daily data/controls occupy roughly two thirds of the height. The graph occupies roughly the lower third and uses the full available width, with method days running horizontally.

The ratio is a hierarchy rather than a pixel contract. Small adaptations for usable controls, text scale, safe areas, or desktop window constraints are allowed as long as the graph remains secondary and the full monthly trajectory remains legible.

## Placement in Daymark

Tracker is not a new top-level navigation destination.

Monthly is the administration and reflection home. The Monthly surface gains a third internal section alongside Calendar and Tasks:

- Calendar;
- Tasks;
- Tracker.

Today may show active Trackers as a compact daily marking surface. Today does not create a new Task every day and does not turn a Tracker into an Entry.

A future action that starts a Tracker from a Daily entry must preserve the original Entry as historical journal content and create a separate Tracker entity. Daymark must never silently convert or repurpose the source Entry.

Historical Monthly views remain read-only. They may display the Tracker trajectories that intersect that month, but they must not allow creation, marking, ending, or other mutation.

## Deliberate exclusions

Tracker must not gain:

- streak counters;
- badges, trophies, XP, confetti, or gamification;
- productivity scores or success percentages used as judgment;
- rankings between Trackers;
- automatic goal suggestions;
- automatic renewal;
- aggressive reminders;
- moralized labels for `0` or `-1`;
- predictive trend claims;
- a large configurable analytics dashboard.

If a future proposal needs those concepts, it is a separate product decision and must pass the normal Daymark feature test rather than being smuggled in as a Tracker enhancement.

## Fidelity rule

The implementation should be described accurately:

> Daymark Tracker is an optional digital adaptation inspired by tracking practices used in Bullet Journals and by the maintainer's personal practice of manually graphing daily commitments.

That attribution is intentional. Daymark can adapt the medium without pretending its own inventions are canonical Bullet Journal rules.
