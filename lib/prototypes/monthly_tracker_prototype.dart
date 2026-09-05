import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Disposable UI experiment for the proposed Monthly Tracker.
///
/// This revision tests two questions only:
/// 1. Does the graph read better as a horizontal canvas on every screen shape?
/// 2. Is 3, 4, or 5 simultaneous trackers the practical limit?
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
  int _visibleCount = 3;
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
        marks: _marks(<int>[1, 2, 4, 5, 6, 8, 10, 12, 13, 15, 16, 19, 20, 22, 24, 27, 28, 30], <int>[9, 18, 25]),
      ),
      _TrackerDemo(
        name: 'Não fumar',
        color: _slotColors[1],
        startDay: 1,
        endDay: 30,
        marks: _marks(<int>[1, 2, 3, 4, 5, 7, 8, 9, 10, 11, 12, 14, 15, 16, 17, 18, 20, 22, 23, 24, 25, 26, 27, 30], <int>[6, 13, 21, 29]),
      ),
      _TrackerDemo(
        name: 'Passear com o cachorro',
        color: _slotColors[2],
        startDay: 1,
        endDay: 30,
        marks: _marks(<int>[2, 3, 4, 6, 8, 9, 10, 11, 13, 15, 16, 18, 20, 21, 22, 24, 25, 27, 28, 30], <int>[1, 7, 14, 19, 26]),
      ),
      _TrackerDemo(
        name: 'Ler 3 páginas',
        color: _slotColors[3],
        startDay: 4,
        endDay: 22,
        marks: _marks(<int>[4, 5, 6, 8, 10, 11, 13, 14, 15, 17, 19, 21, 22], <int>[7, 12, 18]),
      ),
      _TrackerDemo(
        name: 'Novena',
        color: _slotColors[4],
        startDay: 7,
        endDay: 15,
        marks: _marks(<int>[7, 8, 9, 11, 12, 14, 15], <int>[10]),
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
            final double horizontalPadding = viewport.maxWidth < 520 ? 12 : 20;

            return ListView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                18,
                horizontalPadding,
                28,
              ),
              children: <Widget>[
                Text(
                  'Monthly Tracker — teste de densidade',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 6),
                Text(
                  portrait
                      ? 'Tela vertical: o gráfico continua sendo uma peça horizontal, usando toda a largura.'
                      : 'Tela horizontal: o gráfico usa toda a largura disponível, sem dividir espaço com o registro diário.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 18),
                _SectionCard(
                  title: 'Quantas linhas continuam legíveis?',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SegmentedButton<int>(
                        showSelectedIcon: false,
                        segments: const <ButtonSegment<int>>[
                          ButtonSegment<int>(value: 3, label: Text('3')),
                          ButtonSegment<int>(value: 4, label: Text('4')),
                          ButtonSegment<int>(value: 5, label: Text('5')),
                        ],
                        selected: <int>{_visibleCount},
                        onSelectionChanged: (Set<int> value) {
                          setState(() {
                            _visibleCount = value.single;
                            if (_focusedTracker != null &&
                                _focusedTracker! >= _visibleCount) {
                              _focusedTracker = null;
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Troque entre 3, 4 e 5 sem mudar os dados. A ideia é descobrir o limite visual, não defender o número 5.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _buildGraphCard(theme, viewport, portrait),
                const SizedBox(height: 14),
                _buildDailyCard(theme),
                const SizedBox(height: 14),
                _SectionCard(
                  title: 'O que observar',
                  child: Text(
                    '1) compare 3, 4 e 5 linhas; 2) redimensione para vertical, quadrado e horizontal; '
                    '3) toque numa legenda quando houver cruzamentos; 4) veja se o mês inteiro ainda pode ser lido de uma vez. '
                    'Nada aqui decide banco, schema ou produto final.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildGraphCard(
    ThemeData theme,
    BoxConstraints viewport,
    bool portrait,
  ) {
    final List<_TrackerDemo> visible = _trackers.take(_visibleCount).toList();

    return _SectionCard(
      title: 'Gráfico conjunto — $_visibleCount Trackers',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              for (int index = 0; index < visible.length; index++)
                _LegendChip(
                  tracker: visible[index],
                  selected: _focusedTracker == index,
                  dimmed: _focusedTracker != null && _focusedTracker != index,
                  onTap: () {
                    setState(() {
                      _focusedTracker = _focusedTracker == index ? null : index;
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints box) {
              final double width = box.maxWidth;
              final double desiredHeight = portrait
                  ? math.min(260, math.max(190, width / 1.65))
                  : math.min(340, math.max(220, viewport.maxHeight * 0.48));
              return SizedBox(
                width: width,
                height: desiredHeight,
                child: CustomPaint(
                  painter: _TrackerGraphPainter(
                    trackers: visible,
                    throughDay: _simulatedToday,
                    focusedTracker: _focusedTracker,
                    daysInMonth: _daysInMonth,
                    textColor: theme.colorScheme.onSurface,
                    gridColor: theme.colorScheme.outlineVariant,
                    compact: width < 520,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDailyCard(ThemeData theme) {
    final List<_TrackerDemo> visible = _trackers.take(_visibleCount).toList();
    final List<int> activeIndexes = <int>[
      for (int index = 0; index < visible.length; index++)
        if (visible[index].isActiveOn(_simulatedToday)) index,
    ];

    return _SectionCard(
      title: 'Registro do dia — $_simulatedToday/09',
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
              onPositive: () => _toggleMark(index, 1),
              onNegative: () => _toggleMark(index, -1),
            ),
          const SizedBox(height: 6),
          Text(
            'Check positivo = +1. Check negativo = -1. Sem check = 0.',
            style: theme.textTheme.bodySmall,
          ),
        ],
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: <Widget>[
          Container(width: 4, height: 30, color: tracker.color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              tracker.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
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
        color: tracker.color.withValues(alpha: dimmed ? 0.25 : 1),
      ),
      label: Text(
        tracker.name,
        style: TextStyle(
          color: dimmed
              ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38)
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
    required this.compact,
  });

  final List<_TrackerDemo> trackers;
  final int throughDay;
  final int? focusedTracker;
  final int daysInMonth;
  final Color textColor;
  final Color gridColor;
  final bool compact;

  static const double _left = 42;
  static const double _right = 12;
  static const double _top = 20;
  static const double _bottom = 34;

  @override
  void paint(Canvas canvas, Size size) {
    final double graphWidth = math.max(1, size.width - _left - _right);
    final double graphHeight = math.max(1, size.height - _top - _bottom);
    final double yPositive = _top;
    final double yZero = _top + graphHeight / 2;
    final double yNegative = _top + graphHeight;

    final Paint gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    for (final double y in <double>[yPositive, yZero, yNegative]) {
      canvas.drawLine(Offset(_left, y), Offset(size.width - _right, y), gridPaint);
    }

    _drawText(canvas, '+1', Offset(7, yPositive - 7), textColor, 12);
    _drawText(canvas, '0', Offset(18, yZero - 7), textColor, 12);
    _drawText(canvas, '-1', Offset(7, yNegative - 7), textColor, 12);

    for (int day = 1; day <= daysInMonth; day++) {
      final bool showLabel = compact
          ? day == 1 || day == daysInMonth || day % 5 == 0
          : day == 1 || day == daysInMonth || day % 2 == 0;
      if (!showLabel) continue;
      final double x = _xForDay(day, graphWidth);
      _drawText(
        canvas,
        '$day',
        Offset(x - 6, size.height - 22),
        textColor.withValues(alpha: 0.7),
        compact ? 9 : 10,
      );
    }

    for (int index = 0; index < trackers.length; index++) {
      final _TrackerDemo tracker = trackers[index];
      final int lastDay = math.min(tracker.endDay, throughDay);
      if (lastDay < tracker.startDay) continue;

      final bool dimmed = focusedTracker != null && focusedTracker != index;
      final Paint linePaint = Paint()
        ..color = tracker.color.withValues(alpha: dimmed ? 0.12 : 0.9)
        ..strokeWidth = focusedTracker == index ? 3.4 : 2.2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      final Paint pointPaint = Paint()
        ..color = tracker.color.withValues(alpha: dimmed ? 0.12 : 1)
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
          canvas.drawCircle(Offset(x, y), compact ? 2.4 : 3.0, pointPaint);
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
  bool shouldRepaint(covariant _TrackerGraphPainter oldDelegate) => true;
}
