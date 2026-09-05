import 'package:daymark/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

final class TrackerDraft {
  const TrackerDraft({
    required this.title,
    required this.startDate,
    required this.plannedEndDate,
  });

  final String title;
  final DateTime startDate;
  final DateTime plannedEndDate;
}

Future<TrackerDraft?> showTrackerCreateDialog({
  required BuildContext context,
  required DateTime today,
}) async {
  final TextEditingController titleController = TextEditingController();
  DateTime startDate = DateTime(today.year, today.month, today.day);
  DateTime plannedEndDate = startDate.add(const Duration(days: 29));
  final DateTime lastStartDate = DateTime(today.year, today.month + 1, 0);

  try {
    return await showDialog<TrackerDraft>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            final AppLocalizations l10n = AppLocalizations.of(context);
            return AlertDialog(
              title: Text(l10n.trackerCreateTitle),
              content: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    TextField(
                      controller: titleController,
                      autofocus: true,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(labelText: l10n.trackerTitle),
                    ),
                    const SizedBox(height: 16),
                    _DateButton(
                      label: l10n.trackerStartDate,
                      value: startDate,
                      onPressed: () async {
                        final DateTime? selected = await showDatePicker(
                          context: context,
                          initialDate: startDate,
                          firstDate: DateTime(today.year, today.month, 1),
                          lastDate: lastStartDate,
                        );
                        if (selected == null) return;
                        setState(() {
                          startDate = _dateOnly(selected);
                          if (plannedEndDate.isBefore(startDate)) {
                            plannedEndDate = startDate;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    _DateButton(
                      label: l10n.trackerPlannedEndDate,
                      value: plannedEndDate,
                      onPressed: () async {
                        final DateTime? selected = await showDatePicker(
                          context: context,
                          initialDate: plannedEndDate,
                          firstDate: startDate,
                          lastDate: DateTime(
                            startDate.year + 2,
                            startDate.month,
                            startDate.day,
                          ),
                        );
                        if (selected == null) return;
                        setState(() => plannedEndDate = _dateOnly(selected));
                      },
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.trackerCreateExplanation,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(
                    MaterialLocalizations.of(context).cancelButtonLabel,
                  ),
                ),
                FilledButton(
                  onPressed: () {
                    final String title = titleController.text.trim();
                    if (title.isEmpty) return;
                    Navigator.of(dialogContext).pop(
                      TrackerDraft(
                        title: title,
                        startDate: startDate,
                        plannedEndDate: plannedEndDate,
                      ),
                    );
                  },
                  child: Text(l10n.trackerCreate),
                ),
              ],
            );
          },
        );
      },
    );
  } finally {
    titleController.dispose();
  }
}

class _DateButton extends StatelessWidget {
  const _DateButton({
    required this.label,
    required this.value,
    required this.onPressed,
  });

  final String label;
  final DateTime value;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      child: Row(
        children: <Widget>[
          Expanded(child: Text(label)),
          Text(MaterialLocalizations.of(context).formatMediumDate(value)),
        ],
      ),
    );
  }
}

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);
