import 'dart:math' as math;

import 'package:daymark/features/journal/data/tracker_repository.dart';
import 'package:daymark/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

const List<Color> trackerSlotColors = <Color>[
  Color(0xFF1565C0),
  Color(0xFF2E7D32),
  Color(0xFFEF6C00),
  Color(0xFF6A1B9A),
  Color(0xFFC62828),
];

class TrackerMonthView extends StatefulWidget {
  const TrackerMonthView({
    required this.snapshot,
    required this.selectedDay,
    required this.maxSelectableDay,
    required this.writable,
    required this.onSelectedDayChanged,
    required this.onSetMark,
    required this.onEndEarly,
    super.key,
  });

  final TrackerMonthSnapshot snapshot;
  final int selectedDay;
  final int maxSelectableDay;
  final bool writable;
  final ValueChanged<int> onSelectedDayChanged;
  final Future<void> Function(TrackerRecord tracker, int? value) onSetMark;
  final Future<void> Function(TrackerRecord tracker) onEndEarly;

  @override
  State<TrackerMonthView> createState() => _TrackerMonthViewState();
}

class _TrackerMonthViewState extends State<TrackerMonthView> {
  String? _focusedTrackerId;
  String? _busyTrackerId;

  @override
  Widget build(BuildContext context) {
    final bool portrait =
        MediaQuery.sizeOf(context).height > MediaQuery.sizeOf(context).width;
    final String selectedDate = _methodDate(
      widget.snapshot.periodStart,
      widget.selectedDay,
    );

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (widget.snapshot.trackers.isEmpty) {
          return Align(
            alignment: AlignmentDirectional.topStart,
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                AppLocalizations.of(context).trackerEmptyMonth,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          );
        }

        final Widget data = _TrackerDataPanel(
          snapshot: widget.snapshot,
          selectedDate: selectedDate,
          selectedDay: widget.selectedDay,
          maxSelectableDay: widget.maxSelectableDay,
          writable: widget.writable,
          focusedTrackerId: _focusedTrackerId,
          busyTrackerId: _busyTrackerId,
          onSelectedDayChanged: widget.onSelectedDayChanged,
          onFocus: (String trackerId) {
            setState(() {
              _focusedTrackerId = _focusedTrackerId == trackerId
                  ? null
                  : trackerId;
            });
          },
          onSetMark: _setMark,
          onEndEarly: _endEarly,
        );
        final Widget graph = _TrackerGraphPanel(
          snapshot: widget.snapshot,
          throughDay: widget.maxSelectableDay,
          focusedTrackerId: _focusedTrackerId,
          verticalTimeline: portrait,
        );

        if (portrait) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(flex: 2, child: data),
              const SizedBox(width: 8),
              Expanded(child: graph),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(flex: 2, child: data),
            const SizedBox(height: 8),
            Expanded(child: graph),
          ],
        );
      },
    );
  }

  Future<void> _setMark(TrackerRecord tracker, int? value) async {
    if (_busyTrackerId != null) return;
    setState(() => _busyTrackerId = tracker.id);
    try {
      await widget.onSetMark(tracker, value);
    } finally {
      if (mounted) {
        setState(() => _busyTrackerId = null);
      }
    }
  }

  Future<void> _endEarly(TrackerRecord tracker) async {
    if (_busyTrackerId != null) return;
    setState(() => _busyTrackerId = tracker.id);
    try {
      await widget.onEndEarly(tracker);
    } finally {
      if (mounted) {
        setState(() => _busyTrackerId = null);
      }
    }
  }
}

class _TrackerDataPanel extends StatelessWidget {
  const _TrackerDataPanel({
    required this.snapshot,
    required this.selectedDate,
    required this.selectedDay,
    required this.maxSelectableDay,
    required this.writable,
    required this.focusedTrackerId,
    required this.busyTrackerId,
    required this.onSelectedDayChanged,
    required this.onFocus,
    required this.onSetMark,
    required this.onEndEarly,
  });

  final TrackerMonthSnapshot snapshot;
  final String selectedDate;
  final int selectedDay;
  final int maxSelectableDay;
  final bool writable;
  final String? focusedTrackerId;
  final String? busyTrackerId;
  final ValueChanged<int> onSelectedDayChanged;
  final ValueChanged<String> onFocus;
  final Future<void> Function(TrackerRecord tracker, int? value) onSetMark;
  final Future<void> Function(TrackerRecord tracker) onEndEarly;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return _TrackerPanel(
      title: '${l10n.trackerData} · $selectedDay',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              IconButton(
                tooltip: l10n.previousDay,
                onPressed: selectedDay > 1
                    ? () => onSelectedDayChanged(selectedDay - 1)
                    : null,
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: Text(
                  selectedDate,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              IconButton(
                tooltip: l10n.nextDay,
                onPressed: selectedDay < maxSelectableDay
                    ? () => onSelectedDayChanged(selectedDay + 1)
                    : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Expanded(
            child: ListView.separated(
              itemCount: snapshot.trackers.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(height: 4),
              itemBuilder: (BuildContext context, int index) {
                final TrackerRecord tracker = snapshot.trackers[index];
                final bool active = tracker.isActiveOn(selectedDate);
                final bool focused = tracker.id == focusedTrackerId;
                final bool busy = tracker.id == busyTrackerId;
                final int? value = active
                    ? tracker.valueOn(selectedDate)
                    : null;
                final bool canEnd =
                    writable &&
                    active &&
                    selectedDay == maxSelectableDay &&
                    selectedDate.compareTo(tracker.plannedEndDate) < 0 &&
                    tracker.endedDate == null;

                return DecoratedBox(
                  decoration: BoxDecoration(
                    color: focused
                        ? trackerSlotColors[tracker.colorSlot].withValues(
                            alpha: 0.08,
                          )
                        : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    child: Row(
                      children: <Widget>[
                        InkWell(
                          onTap: () => onFocus(tracker.id),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 8,
                            ),
                            child: Container(
                              width: 4,
                              height: 28,
                              decoration: BoxDecoration(
                                color: trackerSlotColors[tracker.colorSlot],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: InkWell(
                            onTap: () => onFocus(tracker.id),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    tracker.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${tracker.startDate} – ${tracker.effectiveEndDate}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (busy)
                          const Padding(
                            padding: EdgeInsets.all(10),
                            child: SizedBox.square(
                              dimension: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        else if (active && writable) ...<Widget>[
                          IconButton(
                            tooltip: l10n.trackerFulfilled,
                            visualDensity: VisualDensity.compact,
                            onPressed: () => onSetMark(
                              tracker,
                              value == 1 &&
                                      tracker.hasExplicitMark(selectedDate)
                                  ? null
                                  : 1,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: value == 1
                                  ? trackerSlotColors[tracker.colorSlot]
                                        .withValues(alpha: 0.14)
                                  : null,
                              foregroundColor: value == 1
                                  ? trackerSlotColors[tracker.colorSlot]
                                  : null,
                            ),
                            icon: const Icon(Icons.check),
                          ),
                          IconButton(
                            tooltip: l10n.trackerNotFulfilled,
                            visualDensity: VisualDensity.compact,
                            onPressed: () => onSetMark(
                              tracker,
                              value == -1 &&
                                      tracker.hasExplicitMark(selectedDate)
                                  ? null
                                  : -1,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: value == -1
                                  ? trackerSlotColors[tracker.colorSlot]
                                        .withValues(alpha: 0.14)
                                  : null,
                              foregroundColor: value == -1
                                  ? trackerSlotColors[tracker.colorSlot]
                                  : null,
                            ),
                            icon: const Icon(Icons.close),
                          ),
                          if (canEnd)
                            IconButton(
                              tooltip: l10n.trackerEndEarly,
                              visualDensity: VisualDensity.compact,
                              onPressed: () => onEndEarly(tracker),
                              icon: const Icon(Icons.stop_circle_outlined),
                            ),
                        ] else if (active)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(switch (value) {
                              1 => '+1',
                              -1 => '-1',
                              _ => '0',
                            }, style: Theme.of(context).textTheme.labelLarge),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.trackerZeroMeaning,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _TrackerGraphPanel extends StatelessWidget {
  const _TrackerGraphPanel({
    required this.snapshot,
    required this.throughDay,
    required this.focusedTrackerId,
    required this.verticalTimeline,
  });

  final TrackerMonthSnapshot snapshot;
  final int throughDay;
  final String? focusedTrackerId;
  final bool verticalTimeline;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return _TrackerPanel(
      title: AppLocalizations.of(context).trackerGraph,
      dense: verticalTimeline,
      child: CustomPaint(
        painter: _TrackerGraphPainter(
          snapshot: snapshot,
          throughDay: throughDay,
          focusedTrackerId: focusedTrackerId,
          verticalTimeline: verticalTimeline,
          textColor: theme.colorScheme.onSurface,
          gridColor: theme.colorScheme.outlineVariant,
          surfaceColor: theme.colorScheme.surface,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _TrackerPanel extends StatelessWidget {
  const _TrackerPanel({
    required this.title,
    required this.child,
    this.dense = false,
  });

  final String title;
  final Widget child;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(dense ? 8 : 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              title,
              style: dense
                  ? Theme.of(context).textTheme.labelLarge
                  : Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: dense ? 6 : 10),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class _TrackerGraphPainter extends CustomPainter {
  const _TrackerGraphPainter({
    required this.snapshot,
    required this.throughDay,
    required this.focusedTrackerId,
    required this.verticalTimeline,
    required this.textColor,
    required this.gridColor,
    required this.surfaceColor,
  });

  final TrackerMonthSnapshot snapshot;
  final int throughDay;
  final String? focusedTrackerId;
  final bool verticalTimeline;
  final Color textColor;
  final Color gridColor;
  final Color surfaceColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 1 || size.height <= 1) return;
    if (verticalTimeline) {
      _paintVertical(canvas, size);
    } else {
      _paintHorizontal(canvas, size);
    }
  }

  void _paintHorizontal(Canvas canvas, Size size) {
    const double left = 36;
    const double right = 8;
    const double top = 8;
    const double bottom = 24;
    final double graphWidth = math.max(1, size.width - left - right);
    final double graphHeight = math.max(1, size.height - top - bottom);
    final double yPositive = top;
    final double yZero = top + graphHeight / 2;
    final double yNegative = top + graphHeight;

    _drawHorizontalGrid(
      canvas,
      size,
      left: left,
      right: right,
      yPositive: yPositive,
      yZero: yZero,
      yNegative: yNegative,
      graphWidth: graphWidth,
    );

    _drawTrackerLines(
      canvas,
      dayPoint: (int day, int value) {
        final double x =
            left + ((day - 1) / (snapshot.daysInMonth - 1)) * graphWidth;
        final double y = switch (value) {
          1 => yPositive,
          -1 => yNegative,
          _ => yZero,
        };
        return Offset(x, y);
      },
      smoothAlongX: true,
      pointRadius: size.height < 180 ? 1.5 : 1.9,
    );
  }

  void _paintVertical(Canvas canvas, Size size) {
    const double left = 26;
    const double right = 6;
    const double top = 24;
    const double bottom = 8;
    final double graphWidth = math.max(1, size.width - left - right);
    final double graphHeight = math.max(1, size.height - top - bottom);
    final double xNegative = left;
    final double xZero = left + graphWidth / 2;
    final double xPositive = left + graphWidth;

    _drawVerticalGrid(
      canvas,
      size,
      top: top,
      bottom: bottom,
      xNegative: xNegative,
      xZero: xZero,
      xPositive: xPositive,
      graphHeight: graphHeight,
    );

    _drawTrackerLines(
      canvas,
      dayPoint: (int day, int value) {
        final double y =
            top + ((day - 1) / (snapshot.daysInMonth - 1)) * graphHeight;
        final double x = switch (value) {
          1 => xPositive,
          -1 => xNegative,
          _ => xZero,
        };
        return Offset(x, y);
      },
      smoothAlongX: false,
      pointRadius: size.width < 150 ? 1.35 : 1.75,
    );
  }

  void _drawHorizontalGrid(
    Canvas canvas,
    Size size, {
    required double left,
    required double right,
    required double yPositive,
    required double yZero,
    required double yNegative,
    required double graphWidth,
  }) {
    final Paint gridPaint = Paint()
      ..color = gridColor.withValues(alpha: 0.7)
      ..strokeWidth = 1
      ..isAntiAlias = true;
    for (final double y in <double>[yPositive, yZero, yNegative]) {
      canvas.drawLine(
        Offset(left, y),
        Offset(size.width - right, y),
        gridPaint,
      );
    }
    _drawText(canvas, '+1', const Offset(4, 1), textColor, 10);
    _drawText(canvas, '0', Offset(14, yZero - 6), textColor, 10);
    _drawText(canvas, '-1', Offset(4, yNegative - 6), textColor, 10);
    for (final int day in _dayLabels(snapshot.daysInMonth)) {
      final double x =
          left + ((day - 1) / (snapshot.daysInMonth - 1)) * graphWidth;
      _drawText(
        canvas,
        '$day',
        Offset(x - 5, size.height - 17),
        textColor.withValues(alpha: 0.65),
        9,
      );
    }
  }

  void _drawVerticalGrid(
    Canvas canvas,
    Size size, {
    required double top,
    required double bottom,
    required double xNegative,
    required double xZero,
    required double xPositive,
    required double graphHeight,
  }) {
    final Paint gridPaint = Paint()
      ..color = gridColor.withValues(alpha: 0.7)
      ..strokeWidth = 1
      ..isAntiAlias = true;
    for (final double x in <double>[xNegative, xZero, xPositive]) {
      canvas.drawLine(
        Offset(x, top),
        Offset(x, size.height - bottom),
        gridPaint,
      );
    }
    _drawText(canvas, '-1', Offset(xNegative - 7, 2), textColor, 9);
    _drawText(canvas, '0', Offset(xZero - 3, 2), textColor, 9);
    _drawText(canvas, '+1', Offset(xPositive - 8, 2), textColor, 9);
    for (final int day in _dayLabels(snapshot.daysInMonth)) {
      final double y =
          top + ((day - 1) / (snapshot.daysInMonth - 1)) * graphHeight;
      _drawText(
        canvas,
        '$day',
        Offset(1, y - 5),
        textColor.withValues(alpha: 0.65),
        8,
      );
    }
  }

  void _drawTrackerLines(
    Canvas canvas, {
    required Offset Function(int day, int value) dayPoint,
    required bool smoothAlongX,
    required double pointRadius,
  }) {
    final DateTime month = DateTime.parse(snapshot.periodStart);
    final int visibleThrough = throughDay.clamp(1, snapshot.daysInMonth);

    for (final TrackerRecord tracker in snapshot.trackers) {
      final DateTime start = DateTime.parse(tracker.startDate);
      final DateTime end = DateTime.parse(tracker.effectiveEndDate);
      final int firstDay =
          start.year == month.year && start.month == month.month
          ? start.day
          : 1;
      final int naturalLastDay =
          end.year == month.year && end.month == month.month
          ? end.day
          : snapshot.daysInMonth;
      final int lastDay = math.min(naturalLastDay, visibleThrough);
      if (lastDay < firstDay) continue;

      final bool dimmed =
          focusedTrackerId != null && focusedTrackerId != tracker.id;
      final Color color = trackerSlotColors[tracker.colorSlot];
      final double lineWidth = focusedTrackerId == tracker.id ? 2.8 : 1.8;
      final Paint haloPaint = Paint()
        ..color = surfaceColor.withValues(alpha: dimmed ? 0 : 0.74)
        ..strokeWidth = lineWidth + 2.4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..isAntiAlias = true;
      final Paint linePaint = Paint()
        ..color = color.withValues(alpha: dimmed ? 0.12 : 0.92)
        ..strokeWidth = lineWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..isAntiAlias = true;

      final List<Offset> points = <Offset>[];
      final List<bool> explicit = <bool>[];
      for (int day = firstDay; day <= lastDay; day++) {
        final String methodDate = _methodDate(snapshot.periodStart, day);
        final int value = tracker.marks[methodDate] ?? 0;
        points.add(dayPoint(day, value));
        explicit.add(tracker.marks.containsKey(methodDate));
      }
      if (points.isEmpty) continue;

      final Path path = _smoothPath(points, alongX: smoothAlongX);
      if (!dimmed) canvas.drawPath(path, haloPaint);
      canvas.drawPath(path, linePaint);

      if (dimmed) continue;
      for (int index = 0; index < points.length; index++) {
        final double radius = explicit[index]
            ? pointRadius + 0.55
            : pointRadius;
        final Paint outer = Paint()
          ..color = surfaceColor
          ..style = PaintingStyle.fill
          ..isAntiAlias = true;
        final Paint inner = Paint()
          ..color = color
          ..style = PaintingStyle.fill
          ..isAntiAlias = true;
        canvas.drawCircle(points[index], radius + 1.0, outer);
        canvas.drawCircle(points[index], radius, inner);
      }
    }
  }

  Path _smoothPath(List<Offset> points, {required bool alongX}) {
    final Path path = Path()..moveTo(points.first.dx, points.first.dy);
    for (int index = 1; index < points.length; index++) {
      final Offset previous = points[index - 1];
      final Offset current = points[index];
      if (alongX) {
        final double control = (current.dx - previous.dx) * 0.42;
        path.cubicTo(
          previous.dx + control,
          previous.dy,
          current.dx - control,
          current.dy,
          current.dx,
          current.dy,
        );
      } else {
        final double control = (current.dy - previous.dy) * 0.42;
        path.cubicTo(
          previous.dx,
          previous.dy + control,
          current.dx,
          current.dy - control,
          current.dx,
          current.dy,
        );
      }
    }
    return path;
  }

  Iterable<int> _dayLabels(int daysInMonth) sync* {
    for (final int day in <int>[1, 5, 10, 15, 20, 25, 30, 31]) {
      if (day <= daysInMonth) yield day;
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset offset,
    Color color,
    double fontSize,
  ) {
    final TextPainter painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: fontSize),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _TrackerGraphPainter oldDelegate) {
    return oldDelegate.snapshot != snapshot ||
        oldDelegate.throughDay != throughDay ||
        oldDelegate.focusedTrackerId != focusedTrackerId ||
        oldDelegate.verticalTimeline != verticalTimeline ||
        oldDelegate.textColor != textColor ||
        oldDelegate.gridColor != gridColor ||
        oldDelegate.surfaceColor != surfaceColor;
  }
}

String _methodDate(String periodStart, int day) {
  final DateTime month = DateTime.parse(periodStart);
  return '${month.year.toString().padLeft(4, '0')}-'
      '${month.month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}';
}
