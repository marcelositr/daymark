import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Disposable UI experiment for the proposed Monthly Tracker.
///
/// Run with:
///   flutter run -d linux -t lib/prototypes/monthly_tracker_prototype.dart
///
/// This prototype is intentionally isolated from Daymark routing, persistence,
/// domain services, and localization. It exists only to validate whether the
/// daily interaction and the five-line graph remain readable across compact,
/// square-ish, landscape, and desktop layouts.
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
          16: 1,
          18: -1,
          19: 1,
          20: 1,
          22: 1,
          24: 1,
          25: -1,
          27: 1,
          28: 1,
          30: 1,
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
          16: 1,
          17: 1,
          18: 1,
          20: 1,
          21: -1,
          22: 1,
          23: 1,
          24: 1,
          25: 1,
          26: 1,
          27: 1,
          29: -1,
          30: 1,
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
          16: 1,
          18: 1,
          19: -1,
          20: 1,
          21: 1,
          22: 1,
          24: 1,
          25: 1,
          26: -1,
          27: 1,
          28: 1,
          30: 1,
        },
      ),
      _TrackerDemo(
        name: 'Ler 3 páginas',
        color: _slotColors[3],
        startDay: 4,
        endDay: 22,
        endReason: 'encerrado antes do fim',
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
          17: 1,
          18: -1,
          19: 1,
          21: 1,
          22: 1,
        },
      ),
      _TrackerDemo(
        name: 'Novena',
        color: _slotColors[4],
        startDay: 7,
        endDay: 15,
        endReason: 'concluído no período previsto',
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

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewport) {
            final double width = viewport.maxWidth;
            final bool wide = width >= 900;
            final String layoutName = switch (width) {
              < 520 => 'compacto / celular vertical',
              < 760 => 'intermediário / quase quadrado',
              < 900 => 'horizontal compacto',
              _ => 'desktop largo',
            };

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1180),
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    width < 520 ? 12 : 20,
                    20,
                    width < 520 ? 12 : 20,
                    32,
                  ),
                  children: <Widget>[
                    Text(
                      'Monthly Tracker — protótipo descartável',
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Layout detectado: $layoutName (${width.round()} px). '
                      'Redimensione a janela para testar vertical, quadrado, '
                      'horizontal e desktop sem mudar o conceito do gráfico.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 20),
                    if (wide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            flex: 4,
                            child: _buildDailyCard(theme),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 6,
                            child: _buildGraphCard(theme, width),
                          ),
                        ],
                      )
                    else ...<Widget>[
                      _buildDailyCard(theme),
                      const SizedBox(height: 16),
                      _buildGraphCard(theme, width),
                    ],
                    const SizedBox(height: 16),
                    _buildPeriodsCard(theme),
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: 'O que este teste NÃO decide',
                      child: Text(
                        'Não há banco, schema, integração com Today/Monthly, '
                        'notificações, criação real de Tracker ou escolha de '
                        'cores. A única pergunta agora é: o registro +/− e o '
                        'gráfico conjunto continuam claros em telas diferentes?',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDailyCard(ThemeData theme) {
    final List<int> activeIndexes = <int>[
      for (int index = 0; index < _trackers.length; index++)
        if (_trackers[index].isActiveOn(_simulatedToday)) index,
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
          const SizedBox(height: 4),
          for (final int index in activeIndexes)
            _DailyTrackerRow(
              tracker: _trackers[index],
              value: _trackers[index].valueOn(_simulatedToday),
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
            'Check positivo = +1. Check negativo = -1. Sem check = 0. '
            'O zero nunca precisa ser marcado.',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildGraphCard(ThemeData theme, double viewportWidth) {
    return _SectionCard(
      title: 'Gráfico conjunto — mês inteiro na largura disponível',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              for (int index = 0; index < _trackers.length; index++)
                _LegendChip(
                  tracker: _trackers[index],
                  selected: _focusedTracker == index,
                  dimmed:
                      _focusedTracker != null && _focusedTracker != index,
                  onTap: () {
                    setState(() {
                      _focusedTracker = _focusedTracker == index ? null : index;
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Toque numa legenda para destacar uma linha. Não há rolagem '
            'horizontal: os 30 dias sempre cabem na largura disponível.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints box) {
              final double graphHeight = switch (viewportWidth) {
                < 520 => 230,
                < 760 => 260,
                < 900 => 280,
                _ => 320,
              };
              return SizedBox(
                width: box.maxWidth,
                height: graphHeight,
                child: CustomPaint(
                  painter: _TrackerGraphPainter(
                    trackers: _trackers,
                    throughDay: _simulatedToday,
                    focusedTracker: _focusedTracker,
                    daysInMonth: _daysInMonth,
                    textColor: theme.colorScheme.onSurface,
                    gridColor: theme.colorScheme.outlineVariant,
                    compact: box.maxWidth < 520,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodsCard(ThemeData theme) {
    return _SectionCard(
      title: 'Períodos usados para forçar casos difíceis',
      child: Column(
        children: <Widget>[
          for (final _TrackerDemo tracker in _trackers)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: <Widget>[
                  Container(width: 18, height: 3, color: tracker.color),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      tracker.endReason == null
                          ? tracker.name
                          : '${tracker.name} · ${tracker.endReason}',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${tracker.startDay}–${tracker.endDay}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
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
    this.endReason,
  }) : marks = Map<int, int>.from(marks);

  final String name;
  final Color color;
  final int startDay;
  final int endDay;
  final String? endReason;
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
  static const double _top = 24;
  static const double _bottom = 36;

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
      canvas.drawLine(
        Offset(_left, y),
        Offset(size.width - _right, y),
        gridPaint,
      );
    }

    _drawText(canvas, '+1', Offset(6, yPositive - 8), textColor, 12);
    _drawText(canvas, '0', Offset(16, yZero - 8), textColor, 12);
    _drawText(canvas, '-1', Offset(6, yNegative - 8), textColor, 12);

    for (int day = 1; day <= daysInMonth; day++) {
      if (!_showDayLabel(day)) continue;
      final double x = _xForDay(day, graphWidth);
      _drawCenteredText(
        canvas,
        '$day',
        Offset(x, size.height - 22),
        textColor.withValues(alpha: 0.72),
        compact ? 9 : 10,
      );
    }

    if (throughDay >= 1 && throughDay <= daysInMonth) {
      final double todayX = _xForDay(throughDay, graphWidth);
      final Paint todayPaint = Paint()
        ..color = textColor.withValues(alpha: 0.18)
        ..strokeWidth = 1;
      canvas.drawLine(
        Offset(todayX, _top - 6),
        Offset(todayX, yNegative + 6),
        todayPaint,
      );
    }

    for (int index = 0; index < trackers.length; index++) {
      final _TrackerDemo tracker = trackers[index];
      final int lastDay = math.min(tracker.endDay, throughDay);
      if (lastDay < tracker.startDay) continue;

      final bool dimmed = focusedTracker != null && focusedTracker != index;
      final Paint linePaint = Paint()
        ..color = tracker.color.withValues(alpha: dimmed ? 0.14 : 0.92)
        ..strokeWidth = focusedTracker == index ? 3.4 : (compact ? 2.0 : 2.3)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      final Paint pointPaint = Paint()
        ..color = tracker.color.withValues(alpha: dimmed ? 0.14 : 1)
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
          canvas.drawCircle(Offset(x, y), compact ? 2.3 : 3.0, pointPaint);
        }
      }
    }
  }

  bool _showDayLabel(int day) {
    if (day == 1 || day == daysInMonth) return true;
    if (compact) return day % 5 == 0;
    return day % 2 == 0;
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

  void _drawCenteredText(
    Canvas canvas,
    String text,
    Offset center,
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
    painter.paint(canvas, Offset(center.dx - painter.width / 2, center.dy));
  }

  @override
  bool shouldRepaint(covariant _TrackerGraphPainter oldDelegate) => true;
}
