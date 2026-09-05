import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Disposable UI experiment for the proposed Monthly Tracker.
///
/// This revision follows the hand-drawn responsive hierarchy:
/// - portrait: data takes about 2/3 of the width and the graph 1/3;
/// - landscape/desktop: data takes about 2/3 of the height and the graph 1/3;
/// - the graph transposes its axes in portrait so the full month uses the long
///   dimension of the screen instead of being squeezed into a narrow strip.
///
/// Nothing here changes Daymark routing, persistence, schema, or product domain.
void main() {
  runApp(const _TrackerPrototypeApp());
}

class _TrackerPrototypeApp extends StatelessWidget {
  const _TrackerPrototypeApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Daymark Tracker Prototype',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: const _TrackerPrototypeScreen(),
    );
  }
}

class _TrackerPrototypeScreen extends StatefulWidget {
  const _TrackerPrototypeScreen();

  @override
  State<_TrackerPrototypeScreen> createState() =>
      _TrackerPrototypeScreenState();
}

class _TrackerPrototypeScreenState extends State<_TrackerPrototypeScreen> {
  static const int _daysInMonth = 30;
  static const List<Color> _slotColors = <Color>[
    Color(0xFF1565C0),
    Color(0xFF2E7D32),
    Color(0xFFEF6C00),
    Color(0xFF6A1B9A),
    Color(0xFFC62828),
  ];

  late final List<_TrackerDemo> _trackers;
  int _visibleCount = 4;
  int _simulatedToday = 30;
  int? _focusedTracker;

  @override
  void initState() {
    super.initState();
    _trackers = <_TrackerDemo>[
      _TrackerDemo(
        name: 'Devocional',
        color: _slotColors[0],
        startDay: 1,
        endDay: 30,
        marks: _marks(
          <int>[1, 2, 4, 5, 6, 8, 10, 12, 13, 15, 16, 19, 20, 22, 24, 27, 28, 30],
          <int>[9, 18, 25],
        ),
      ),
      _TrackerDemo(
        name: 'Não fumar',
        color: _slotColors[1],
        startDay: 1,
        endDay: 30,
        marks: _marks(
          <int>[1, 2, 3, 4, 5, 7, 8, 9, 10, 11, 12, 14, 15, 16, 17, 18, 20, 22, 23, 24, 25, 26, 27, 30],
          <int>[6, 13, 21, 29],
        ),
      ),
      _TrackerDemo(
        name: 'Passear com o cachorro',
        color: _slotColors[2],
        startDay: 1,
        endDay: 30,
        marks: _marks(
          <int>[2, 3, 4, 6, 8, 9, 10, 11, 13, 15, 16, 18, 20, 21, 22, 24, 25, 27, 28, 30],
          <int>[1, 7, 14, 19, 26],
        ),
      ),
      _TrackerDemo(
        name: 'Ler 3 páginas',
        color: _slotColors[3],
        startDay: 4,
        endDay: 22,
        marks: _marks(
          <int>[4, 5, 6, 8, 10, 11, 13, 14, 15, 17, 19, 21, 22],
          <int>[7, 12, 18],
        ),
      ),
      _TrackerDemo(
        name: 'Novena',
        color: _slotColors[4],
        startDay: 7,
        endDay: 15,
        marks: _marks(
          <int>[7, 8, 9, 11, 12, 14, 15],
          <int>[10],
        ),
      ),
    ];
  }

  static Map<int, int> _marks(List<int> positive, List<int> negative) {
    return <int, int>{
      for (final int day in positive) day: 1,
      for (final int day in negative) day: -1,
    };
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewport) {
            final bool portrait = viewport.maxHeight > viewport.maxWidth;
            final double outerPadding = viewport.maxWidth < 520 ? 10 : 16;

            return Padding(
              padding: EdgeInsets.all(outerPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _Header(
                    portrait: portrait,
                    visibleCount: _visibleCount,
                    onVisibleCountChanged: _setVisibleCount,
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: portrait
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Expanded(
                                flex: 2,
                                child: _buildDataPanel(theme, compact: true),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildGraphPanel(
                                  theme,
                                  verticalTimeline: true,
                                ),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Expanded(
                                flex: 2,
                                child: _buildDataPanel(theme, compact: false),
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                child: _buildGraphPanel(
                                  theme,
                                  verticalTimeline: false,
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _setVisibleCount(int count) {
    setState(() {
      _visibleCount = count;
      if (_focusedTracker != null && _focusedTracker! >= _visibleCount) {
        _focusedTracker = null;
      }
    });
  }

  Widget _buildDataPanel(ThemeData theme, {required bool compact}) {
    final List<_TrackerDemo> visible = _trackers.take(_visibleCount).toList();
    final List<int> activeIndexes = <int>[
      for (int index = 0; index < visible.length; index++)
        if (visible[index].isActiveOn(_simulatedToday)) index,
    ];

    return _Panel(
      title: 'Dados · $_simulatedToday/09',
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Slider(
              min: 1,
              max: _daysInMonth.toDouble(),
              divisions: _daysInMonth - 1,
              value: _simulatedToday.toDouble(),
              label: '$_simulatedToday',
              onChanged: (double value) {
                setState(() => _simulatedToday = value.round());
              },
            ),
            for (final int index in activeIndexes)
              _DailyTrackerRow(
                tracker: visible[index],
                value: visible[index].valueOn(_simulatedToday),
                focused: _focusedTracker == index,
                compact: compact,
                onFocus: () {
                  setState(() {
                    _focusedTracker = _focusedTracker == index ? null : index;
                  });
                },
                onPositive: () => _toggleMark(index, 1),
                onNegative: () => _toggleMark(index, -1),
              ),
            if (activeIndexes.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Nenhum Tracker ativo neste dia.'),
              ),
            const SizedBox(height: 8),
            Text(
              '+ = cumpri · − = não cumpri · sem check = 0',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 10),
            Text(
              'Toque no nome ou na cor para destacar a linha correspondente.',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGraphPanel(
    ThemeData theme, {
    required bool verticalTimeline,
  }) {
    final List<_TrackerDemo> visible = _trackers.take(_visibleCount).toList();

    return _Panel(
      title: 'Gráfico',
      denseTitle: verticalTimeline,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints box) {
          return SizedBox.expand(
            child: CustomPaint(
              painter: _TrackerGraphPainter(
                trackers: visible,
                throughDay: _simulatedToday,
                focusedTracker: _focusedTracker,
                daysInMonth: _daysInMonth,
                textColor: theme.colorScheme.onSurface,
                gridColor: theme.colorScheme.outlineVariant,
                verticalTimeline: verticalTimeline,
              ),
            ),
          );
        },
      ),
    );
  }

  void _toggleMark(int trackerIndex, int value) {
    final _TrackerDemo tracker = _trackers[trackerIndex];
    setState(() {
      if (tracker.valueOn(_simulatedToday) == value &&
          tracker.hasExplicitMark(_simulatedToday)) {
        tracker.marks.remove(_simulatedToday);
      } else {
        tracker.marks[_simulatedToday] = value;
      }
    });
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.portrait,
    required this.visibleCount,
    required this.onVisibleCountChanged,
  });

  final bool portrait;
  final int visibleCount;
  final ValueChanged<int> onVisibleCountChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Monthly Tracker', style: theme.textTheme.titleLarge),
              Text(
                portrait
                    ? 'Retrato: dados 2/3 · gráfico 1/3'
                    : 'Horizontal: dados 2/3 · gráfico 1/3',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        SegmentedButton<int>(
          showSelectedIcon: false,
          segments: const <ButtonSegment<int>>[
            ButtonSegment<int>(value: 3, label: Text('3')),
            ButtonSegment<int>(value: 4, label: Text('4')),
            ButtonSegment<int>(value: 5, label: Text('5')),
          ],
          selected: <int>{visibleCount},
          onSelectionChanged: (Set<int> selection) {
            onVisibleCountChanged(selection.single);
          },
        ),
      ],
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.title,
    required this.child,
    this.denseTitle = false,
  });

  final String title;
  final Widget child;
  final bool denseTitle;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(denseTitle ? 8 : 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              title,
              style: denseTitle
                  ? Theme.of(context).textTheme.labelLarge
                  : Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: denseTitle ? 6 : 10),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class _DailyTrackerRow extends StatelessWidget {
  const _DailyTrackerRow({
    required this.tracker,
    required this.value,
    required this.focused,
    required this.compact,
    required this.onFocus,
    required this.onPositive,
    required this.onNegative,
  });

  final _TrackerDemo tracker;
  final int value;
  final bool focused;
  final bool compact;
  final VoidCallback onFocus;
  final VoidCallback onPositive;
  final VoidCallback onNegative;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: focused ? tracker.color.withValues(alpha: 0.08) : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: <Widget>[
            InkWell(
              onTap: onFocus,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                child: Container(width: 4, height: 28, color: tracker.color),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: onFocus,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                  child: Text(
                    tracker.name,
                    maxLines: compact ? 2 : 1,
                    overflow: TextOverflow.ellipsis,
                    style: compact
                        ? Theme.of(context).textTheme.bodyMedium
                        : Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
            ),
            IconButton(
              visualDensity: compact ? VisualDensity.compact : null,
              tooltip: 'Cumpri (+1)',
              onPressed: onPositive,
              style: IconButton.styleFrom(
                backgroundColor: value == 1
                    ? tracker.color.withValues(alpha: 0.16)
                    : null,
                foregroundColor: value == 1 ? tracker.color : null,
              ),
              icon: const Icon(Icons.check),
            ),
            IconButton(
              visualDensity: compact ? VisualDensity.compact : null,
              tooltip: 'Não cumpri (-1)',
              onPressed: onNegative,
              style: IconButton.styleFrom(
                backgroundColor: value == -1
                    ? tracker.color.withValues(alpha: 0.16)
                    : null,
                foregroundColor: value == -1 ? tracker.color : null,
              ),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrackerDemo {
  _TrackerDemo({
    required this.name,
    required this.color,
    required this.startDay,
    required this.endDay,
    required Map<int, int> marks,
  }) : marks = Map<int, int>.from(marks);

  final String name;
  final Color color;
  final int startDay;
  final int endDay;
  final Map<int, int> marks;

  bool isActiveOn(int day) => day >= startDay && day <= endDay;

  bool hasExplicitMark(int day) => marks.containsKey(day);

  int valueOn(int day) {
    if (!isActiveOn(day)) return 0;
    return marks[day] ?? 0;
  }
}

class _TrackerGraphPainter extends CustomPainter {
  const _TrackerGraphPainter({
    required this.trackers,
    required this.throughDay,
    required this.focusedTracker,
    required this.daysInMonth,
    required this.textColor,
    required this.gridColor,
    required this.verticalTimeline,
  });

  final List<_TrackerDemo> trackers;
  final int throughDay;
  final int? focusedTracker;
  final int daysInMonth;
  final Color textColor;
  final Color gridColor;
  final bool verticalTimeline;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 1 || size.height <= 1) return;

    if (verticalTimeline) {
      _paintVerticalTimeline(canvas, size);
    } else {
      _paintHorizontalTimeline(canvas, size);
    }
  }

  void _paintHorizontalTimeline(Canvas canvas, Size size) {
    const double left = 36;
    const double right = 8;
    const double top = 8;
    const double bottom = 24;
    final double graphWidth = math.max(1, size.width - left - right);
    final double graphHeight = math.max(1, size.height - top - bottom);
    final double yPositive = top;
    final double yZero = top + graphHeight / 2;
    final double yNegative = top + graphHeight;

    final Paint gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    for (final double y in <double>[yPositive, yZero, yNegative]) {
      canvas.drawLine(Offset(left, y), Offset(size.width - right, y), gridPaint);
    }

    _drawText(canvas, '+1', const Offset(4, 1), textColor, 10);
    _drawText(canvas, '0', Offset(14, yZero - 6), textColor, 10);
    _drawText(canvas, '-1', Offset(4, yNegative - 6), textColor, 10);

    for (final int day in <int>[1, 5, 10, 15, 20, 25, 30]) {
      if (day > daysInMonth) continue;
      final double x = left + ((day - 1) / (daysInMonth - 1)) * graphWidth;
      _drawText(
        canvas,
        '$day',
        Offset(x - 5, size.height - 17),
        textColor.withValues(alpha: 0.7),
        9,
      );
    }

    _paintTrackerLines(
      canvas,
      dayPoint: (int day, int value) {
        final double x = left + ((day - 1) / (daysInMonth - 1)) * graphWidth;
        final double y = switch (value) {
          1 => yPositive,
          -1 => yNegative,
          _ => yZero,
        };
        return Offset(x, y);
      },
      pointRadius: size.height < 180 ? 2 : 2.6,
    );
  }

  void _paintVerticalTimeline(Canvas canvas, Size size) {
    const double left = 26;
    const double right = 6;
    const double top = 24;
    const double bottom = 8;
    final double graphWidth = math.max(1, size.width - left - right);
    final double graphHeight = math.max(1, size.height - top - bottom);
    final double xNegative = left;
    final double xZero = left + graphWidth / 2;
    final double xPositive = left + graphWidth;

    final Paint gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    for (final double x in <double>[xNegative, xZero, xPositive]) {
      canvas.drawLine(Offset(x, top), Offset(x, size.height - bottom), gridPaint);
    }

    _drawText(canvas, '-1', Offset(xNegative - 7, 2), textColor, 9);
    _drawText(canvas, '0', Offset(xZero - 3, 2), textColor, 9);
    _drawText(canvas, '+1', Offset(xPositive - 8, 2), textColor, 9);

    for (final int day in <int>[1, 5, 10, 15, 20, 25, 30]) {
      if (day > daysInMonth) continue;
      final double y = top + ((day - 1) / (daysInMonth - 1)) * graphHeight;
      _drawText(
        canvas,
        '$day',
        Offset(1, y - 5),
        textColor.withValues(alpha: 0.7),
        8,
      );
    }

    _paintTrackerLines(
      canvas,
      dayPoint: (int day, int value) {
        final double y = top + ((day - 1) / (daysInMonth - 1)) * graphHeight;
        final double x = switch (value) {
          1 => xPositive,
          -1 => xNegative,
          _ => xZero,
        };
        return Offset(x, y);
      },
      pointRadius: size.width < 150 ? 1.8 : 2.3,
    );
  }

  void _paintTrackerLines(
    Canvas canvas, {
    required Offset Function(int day, int value) dayPoint,
    required double pointRadius,
  }) {
    for (int index = 0; index < trackers.length; index++) {
      final _TrackerDemo tracker = trackers[index];
      final int lastDay = math.min(tracker.endDay, throughDay);
      if (lastDay < tracker.startDay) continue;

      final bool dimmed = focusedTracker != null && focusedTracker != index;
      final Paint linePaint = Paint()
        ..color = tracker.color.withValues(alpha: dimmed ? 0.1 : 0.9)
        ..strokeWidth = focusedTracker == index ? 3.2 : 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      final Paint pointPaint = Paint()
        ..color = tracker.color.withValues(alpha: dimmed ? 0.1 : 1)
        ..style = PaintingStyle.fill;

      final Path path = Path();
      bool started = false;
      for (int day = tracker.startDay; day <= lastDay; day++) {
        final Offset point = dayPoint(day, tracker.valueOn(day));
        if (!started) {
          path.moveTo(point.dx, point.dy);
          started = true;
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      canvas.drawPath(path, linePaint);

      if (!dimmed) {
        for (int day = tracker.startDay; day <= lastDay; day++) {
          final Offset point = dayPoint(day, tracker.valueOn(day));
          canvas.drawCircle(point, pointRadius, pointPaint);
        }
      }
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
  bool shouldRepaint(covariant _TrackerGraphPainter oldDelegate) => true;
}
