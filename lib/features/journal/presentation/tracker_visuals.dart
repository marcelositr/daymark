import 'package:daymark/app/design_tokens.dart';
import 'package:flutter/material.dart';

const List<Color> trackerSlotColors = <Color>[
  Color(0xFF1565C0),
  Color(0xFF2E7D32),
  Color(0xFFEF6C00),
  Color(0xFF6A1B9A),
  Color(0xFFC62828),
];

class DaymarkTrackerStripe extends StatelessWidget {
  const DaymarkTrackerStripe({required this.color, super.key});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: DaymarkDesign.trackerStripeWidth,
      height: DaymarkDesign.trackerStripeHeight,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(DaymarkDesign.trackerStripeRadius),
      ),
    );
  }
}

class DaymarkTrackerMarkButton extends StatelessWidget {
  const DaymarkTrackerMarkButton({
    required this.tooltip,
    required this.selected,
    required this.color,
    required this.icon,
    required this.onPressed,
    super.key,
  });

  final String tooltip;
  final bool selected;
  final Color color;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      child: IconButton(
        tooltip: tooltip,
        visualDensity: VisualDensity.compact,
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: selected ? color.withValues(alpha: 0.14) : null,
          foregroundColor: selected ? color : null,
        ),
        icon: Icon(icon),
      ),
    );
  }
}
