import 'package:daymark/features/journal/data/future_log_repository.dart';
import 'package:daymark/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

const int taskScheduleMonthCount = 6;

List<DateTime> futureMonthHorizon(
  DateTime anchor, {
  int monthCount = taskScheduleMonthCount,
}) {
  if (monthCount < 1) {
    throw ArgumentError.value(monthCount, 'monthCount', 'Must be positive.');
  }

  final DateTime anchorMonth = DateTime(anchor.year, anchor.month);
  return List<DateTime>.unmodifiable([
    for (int offset = 1; offset <= monthCount; offset++)
      DateTime(anchorMonth.year, anchorMonth.month + offset),
  ]);
}

Future<String?> showTaskScheduleDialog({
  required BuildContext context,
  required DateTime anchor,
}) {
  final AppLocalizations l10n = AppLocalizations.of(context);
  final MaterialLocalizations material = MaterialLocalizations.of(context);
  final List<DateTime> months = futureMonthHorizon(anchor);

  return showDialog<String>(
    context: context,
    builder: (dialogContext) => SimpleDialog(
      title: Text(l10n.scheduleTaskTitle),
      children: [
        for (final DateTime month in months)
          SimpleDialogOption(
            key: ValueKey<String>('schedule-${formatFuturePeriodStart(month)}'),
            onPressed: () {
              Navigator.of(dialogContext).pop(formatFuturePeriodStart(month));
            },
            child: Text(material.formatMonthYear(month)),
          ),
      ],
    ),
  );
}
