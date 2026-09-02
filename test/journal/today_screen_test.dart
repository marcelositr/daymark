import 'package:daymark/features/journal/data/daily_log_repository.dart';
import 'package:daymark/features/journal/domain/journal_domain.dart';
import 'package:daymark/features/journal/presentation/today_screen.dart';
import 'package:daymark/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Today captures a task without a false save failure', (
    tester,
  ) async {
    final _MemoryTodayJournal dataSource = _MemoryTodayJournal();

    await _pumpToday(tester, dataSource);

    expect(find.byType(TextField), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Widget task');
    await tester.tap(find.byIcon(Icons.arrow_upward));
    await tester.pump();
    await tester.pump();

    expect(find.text('Widget task'), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
    expect(dataSource.entries, hasLength(1));
    expect(dataSource.entries.single.type, JournalEntryType.task);
    expect(dataSource.entries.single.taskState, JournalTaskState.open);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Today completes an open Task through the task marker', (
    tester,
  ) async {
    final _MemoryTodayJournal dataSource = _MemoryTodayJournal(
      entries: [
        const DailyLogEntry(
          id: 'task-1',
          type: JournalEntryType.task,
          taskState: JournalTaskState.open,
          content: 'Finish report',
          ordinal: 0,
        ),
      ],
    );

    await _pumpToday(tester, dataSource);

    expect(find.text('•'), findsOneWidget);
    await tester.tap(find.text('•'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Complete'));
    await tester.pump();
    await tester.pump();

    expect(dataSource.entries.single.taskState, JournalTaskState.completed);
    expect(find.text('×'), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Today discards an open Task without removing its history', (
    tester,
  ) async {
    final _MemoryTodayJournal dataSource = _MemoryTodayJournal(
      entries: [
        const DailyLogEntry(
          id: 'task-1',
          type: JournalEntryType.task,
          taskState: JournalTaskState.open,
          content: 'Old reminder',
          ordinal: 0,
        ),
      ],
    );

    await _pumpToday(tester, dataSource);

    await tester.tap(find.text('•'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Discard'));
    await tester.pump();
    await tester.pump();

    expect(dataSource.entries, hasLength(1));
    expect(dataSource.entries.single.taskState, JournalTaskState.discarded);
    expect(find.text('—'), findsOneWidget);
    expect(find.text('Old reminder'), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}

Future<void> _pumpToday(
  WidgetTester tester,
  _MemoryTodayJournal dataSource,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        todayJournalDataSourceProvider.overrideWithValue(dataSource),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: TodayScreen()),
      ),
    ),
  );
  await tester.pump();
}

final class _MemoryTodayJournal implements TodayJournalDataSource {
  _MemoryTodayJournal({List<DailyLogEntry>? entries})
    : entries = entries ?? <DailyLogEntry>[];

  final List<DailyLogEntry> entries;

  @override
  Future<DailyLogSnapshot> load(String methodDate) async {
    return DailyLogSnapshot(
      logId: 'daily-$methodDate',
      methodDate: methodDate,
      entries: entries,
    );
  }

  @override
  Future<void> capture({
    required String logId,
    required JournalEntryType type,
    required String content,
  }) async {
    entries.add(
      DailyLogEntry(
        id: 'entry-${entries.length}',
        type: type,
        taskState: type == JournalEntryType.task ? JournalTaskState.open : null,
        content: content,
        ordinal: entries.length,
      ),
    );
  }

  @override
  Future<void> completeTask({required String entryId}) async {
    _transitionTask(entryId, JournalTaskState.completed);
  }

  @override
  Future<void> discardTask({required String entryId}) async {
    _transitionTask(entryId, JournalTaskState.discarded);
  }

  void _transitionTask(String entryId, JournalTaskState destinationState) {
    final int index = entries.indexWhere((entry) => entry.id == entryId);
    if (index < 0) {
      throw StateError('Missing entry.');
    }

    final DailyLogEntry source = entries[index];
    if (source.type != JournalEntryType.task ||
        source.taskState != JournalTaskState.open) {
      throw StateError('Only open Tasks can transition.');
    }

    entries[index] = DailyLogEntry(
      id: source.id,
      type: source.type,
      taskState: destinationState,
      content: source.content,
      ordinal: source.ordinal,
    );
  }
}
