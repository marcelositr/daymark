import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Disposable UI experiment for the proposed Monthly Tracker.
///
/// Run with:
///   flutter run -d linux -t lib/prototypes/monthly_tracker_prototype.dart
///
/// This prototype is intentionally isolated from Daymark routing, persistence,
/// domain services, and localization. It exists only to validate whether the
/// daily interaction and the five-line graph remain readable.
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
  int _simulatedToday = 15;
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
        marks: <int, int>{
          1: 1,
          2: 1,
          4: -1,
          5: 1,
          6: 1,
          8: 1,
          9: -1,
          10: 1,
          12: 1,
          13: 1,
          15: 1,
        },
      ),
      _TrackerDemo(
        name: 'Não fumar',
        color: _slotColors[1],
        startDay: 1,
        endDay: 30,
        marks: <int, int>{
          1: 1,
          2: 1,
          3: 1,
          4: 1,
          5: 1,
          6: -1,
          7: 1,
          8: 1,
          9: 1,
          10: 1,
          11: 1,
          12: 1,
          13: -1,
          14: 1,
          15: 1,
        },
      ),
      _TrackerDemo(
        name: 'Passear com o cachorro',
        color: _slotColors[2],
        startDay: 1,
        endDay: 30,
        marks: <int, int>{
          1: -1,
          2: 1,
          3: 1,
          4: 1,
          6: 1,
          7: -1,
          8: 1,
          9: 1,
          10: 1,
          11: 1,
          13: 1,
          14: -1,
          15: 1,
        },
      ),
      _TrackerDemo(
        name: 'Ler 3 páginas',
        color: _slotColors[3],
        startDay: 4,
        endDay: 30,
        marks: <int, int>{
          4: 1,
          5: 1,
          6: 1,
          7: -1,
          8: 1,
          10: 1,
          11: 1,
          12: -1,
          13: 1,
          14: 1,
          15: 1,
        },
      ),
      _TrackerDemo(
        name: 'Novena',
        color: _slotColors[4],
        startDay: 7,
        endDay: 15,
        marks: <int, int>{
          7: 1,
          8: 1,
          9: 1,
          10: -1,
          11: 1,
          12: 1,
          14: 1,
          15: 1,
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<int> activeIndexes = <int>[
      for (int index = 0; index < _trackers.length; index++)
        if (_trackers[index].isActiveOn(_simulatedToday)) index,
    ];

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              children: <Widget>[
                Text(
                  'Monthly Tracker — protótipo isolado',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 6),
                Text(
                  'Sem banco, sem rota e sem mudança no domínio. O objetivo é '
                  'testar somente o fluxo diário e a leitura de cinco linhas.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                _SectionCard(
                  title: 'Dia simulado: $_simulatedToday de setembro',
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
                      const SizedBox(height: 8),
                      for (final int index in activeIndexes)
                        _DailyTrackerRow(
                          tracker: _trackers[index],
                          value: _trackers[index].valueOn(_simulatedToday),
                          onPositive: () => _toggleMark(index, 1),
                          onNegative: () => _toggleMark(index, -1),
                        ),
                      if (activeIndexes.isEmpty)
                        const Text('Nenhum Tracker ativo neste dia.'),
                      const SizedBox(height: 8),
                      Text(
                        'Sem marcação = 0. Tocar novamente no mesmo check '
                        'remove a marcação e volta para 0.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Gráfico conjunto',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: <Widget>[
                          for (int index = 0;
                              index < _trackers.length;
                              index++)
                            _LegendChip(
                              tracker: _trackers[index],
                              selected: _focusedTracker == index,
                              dimmed: _focusedTracker != null &&
                                  _focusedTracker != index,
                              onTap: () {
                                setState(() {
                                  _focusedTracker = _focusedTracker == index
                                      ? null
                                      : index;
                                });
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'As linhas só existem dentro do período do Tracker e '
                        'até o dia simulado. Toque na legenda para isolar uma.',
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      LayoutBuilder(
                        builder: (BuildContext context, BoxConstraints box) {
                          final double graphWidth = math.max(
                            box.maxWidth,
                            980,
                          );
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: CustomPaint(
                              size: Size(graphWidth, 300),
                              painter: _TrackerGraphPainter(
                                trackers: _trackers,
                                throughDay: _simulatedToday,
                                focusedTracker: _focusedTracker,
                                daysInMonth: _daysInMonth,
                                textColor: theme.colorScheme.onSurface,
                                gridColor: theme.colorScheme.outlineVariant,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Períodos usados neste teste',
                  child: Column(
                    children: <Widget>[
                      for (final _TrackerDemo tracker in _trackers)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 18,
                                height: 3,
                                color: tracker.color,
                              ),
                              const SizedBox(width: 10),
                              Expanded(child: Text(tracker.name)),
                              Text(
                                '${tracker.startDay}–${tracker.endDay}',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
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

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            child,
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
    required this.onPositive,
    required this.onNegative,
  });

  final _TrackerDemo tracker;
  final int value;
  final VoidCallback onPositive;
  final VoidCallback onNegative;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: <Widget>[
          Container(width: 4, height: 30, color: tracker.color),
          const SizedBox(width: 10),
          Expanded(child: Text(tracker.name)),
          IconButton(
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
          const SizedBox(width: 4),
          IconButton(
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
    );
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({
    required this.tracker,
    required this.selected,
    required this.dimmed,
    required this.onTap,
  });

  final _TrackerDemo tracker;
  final bool selected;
  final bool dimmed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: onTap,
      side: BorderSide(
        color: selected ? tracker.color : tracker.color.withValues(alpha: 0.5),
      ),
      avatar: Container(
        width: 14,
        height: 3,
        color: tracker.color.withValues(alpha: dimmed ? 0.28 : 1),
      ),
      label: Text(
        tracker.name,
        style: TextStyle(
          color: dimmed
              ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.42)
              : null,
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
  });

  final List<_TrackerDemo> trackers;
  final int throughDay;
  final int? focusedTracker;
  final int daysInMonth;
  final Color textColor;
  final Color gridColor;

  static const double _left = 46;
  static const double _right = 18;
  static const double _top = 24;
  static const double _bottom = 42;

  @override
  void paint(Canvas canvas, Size size) {
    final double graphWidth = size.width - _left - _right;
    final double graphHeight = size.height - _top - _bottom;
    final double yPositive = _top;
    final double yZero = _top + graphHeight / 2;
    final double yNegative = _top + graphHeight;

    final Paint gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    for (final double y in <double>[yPositive, yZero, yNegative]) {
      canvas.drawLine(
        Offset(_left, y),
        Offset(size.width - _right, y),
        gridPaint,
      );
    }

    _drawText(canvas, '+1', Offset(10, yPositive - 8), textColor, 12);
    _drawText(canvas, '0', Offset(20, yZero - 8), textColor, 12);
    _drawText(canvas, '-1', Offset(10, yNegative - 8), textColor, 12);

    for (int day = 1; day <= daysInMonth; day++) {
      final double x = _xForDay(day, graphWidth);
      if (day == 1 || day == daysInMonth || day % 2 == 0) {
        _drawText(
          canvas,
          '$day',
          Offset(x - 7, size.height - 26),
          textColor.withValues(alpha: 0.72),
          10,
        );
      }
    }

    final double todayX = _xForDay(throughDay, graphWidth);
    final Paint todayPaint = Paint()
      ..color = textColor.withValues(alpha: 0.18)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(todayX, _top - 6),
      Offset(todayX, yNegative + 6),
      todayPaint,
    );

    for (int index = 0; index < trackers.length; index++) {
      final _TrackerDemo tracker = trackers[index];
      final int lastDay = math.min(tracker.endDay, throughDay);
      if (lastDay < tracker.startDay) continue;

      final bool dimmed = focusedTracker != null && focusedTracker != index;
      final Paint linePaint = Paint()
        ..color = tracker.color.withValues(alpha: dimmed ? 0.16 : 0.92)
        ..strokeWidth = focusedTracker == index ? 3.4 : 2.3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      final Paint pointPaint = Paint()
        ..color = tracker.color.withValues(alpha: dimmed ? 0.16 : 1)
        ..style = PaintingStyle.fill;

      final Path path = Path();
      bool started = false;
      for (int day = tracker.startDay; day <= lastDay; day++) {
        final double x = _xForDay(day, graphWidth);
        final double y = switch (tracker.valueOn(day)) {
          1 => yPositive,
          -1 => yNegative,
          _ => yZero,
        };
        if (!started) {
          path.moveTo(x, y);
          started = true;
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, linePaint);

      if (!dimmed) {
        for (int day = tracker.startDay; day <= lastDay; day++) {
          final double x = _xForDay(day, graphWidth);
          final double y = switch (tracker.valueOn(day)) {
            1 => yPositive,
            -1 => yNegative,
            _ => yZero,
          };
          canvas.drawCircle(Offset(x, y), 3.2, pointPaint);
        }
      }
    }
  }

  double _xForDay(int day, double graphWidth) {
    if (daysInMonth <= 1) return _left;
    return _left + ((day - 1) / (daysInMonth - 1)) * graphWidth;
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
    return oldDelegate.throughDay != throughDay ||
        oldDelegate.focusedTracker != focusedTracker ||
        oldDelegate.trackers != trackers ||
        oldDelegate.textColor != textColor ||
        oldDelegate.gridColor != gridColor;
  }
}
