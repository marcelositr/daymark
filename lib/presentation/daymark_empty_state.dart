import 'package:flutter/material.dart';

class DaymarkEmptyState extends StatelessWidget {
  const DaymarkEmptyState({
    required this.message,
    this.topPadding = 0,
    super.key,
  });

  final String message;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Align(
      alignment: AlignmentDirectional.topStart,
      child: Padding(
        padding: EdgeInsets.only(top: topPadding),
        child: Text(
          message,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
