import 'package:daymark/features/journal/domain/journal_domain.dart';
import 'package:daymark/l10n/app_localizations.dart';

String journalEntrySemanticLabel(
  AppLocalizations l10n, {
  required JournalEntryType type,
  required JournalTaskState? taskState,
  required String content,
}) {
  final String typeLabel = switch (type) {
    JournalEntryType.task => l10n.entryTask,
    JournalEntryType.event => l10n.entryEvent,
    JournalEntryType.note => l10n.entryNote,
  };

  if (type != JournalEntryType.task) {
    return '$typeLabel, $content';
  }

  final String stateLabel = switch (taskState) {
    JournalTaskState.completed => l10n.taskStateCompleted,
    JournalTaskState.migrated => l10n.taskStateMigrated,
    JournalTaskState.scheduled => l10n.taskStateScheduled,
    JournalTaskState.discarded => l10n.taskStateDiscarded,
    JournalTaskState.open || null => l10n.taskStateOpen,
  };

  return '$typeLabel, $stateLabel, $content';
}
