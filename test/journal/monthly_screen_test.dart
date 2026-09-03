import 'package:daymark/features/journal/data/monthly_log_repository.dart';
import 'package:daymark/features/journal/domain/journal_domain.dart';
import 'package:daymark/features/journal/presentation/monthly_screen.dart';
import 'package:daymark/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Monthly Calendar captures an Event on the selected day', (
    tester,
  ) async {
    final _MemoryMonthlyJournal dataSource = _MemoryMonthlyJournal();

    await _pumpMonthly(tester, dataSource);

    await tester.enterText(find.byType(TextField), 'Dentist');
    await tester.tap(find.byIcon(Icons.arrow_upward));
    await tester.pump();
    await tester.pump();

    expect(dataSource.calendarEntries, hasLength(1));
    expect(dataSource.calendarEntries.single.type, JournalEntryType.event);
    expect(dataSource.calendarEntries.single.calendarDate, '2026-09-15');
    expect(find.text('○ Dentist'), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Monthly Tasks captures and completes an open Task', (
    tester,
  ) async {
    final _MemoryMonthlyJournal dataSource = _MemoryMonthlyJournal();

    await _pumpMonthly(tester, dataSource);
    await tester.tap(find.text('Tasks'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Renew documents');
    await tester.tap(find.byIcon(Icons.arrow_upward));
    await tester.pump();
    await tester.pump();

    expect(dataSource.taskEntries, hasLength(1));
    expect(dataSource.taskEntries.single.taskState, JournalTaskState.open);
    expect(find.text('•'), findsOneWidget);

    await tester.tap(find.text('•'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Complete'));
    await tester.pump();
    await tester.pump();

    expect(dataSource.taskEntries.single.taskState, JournalTaskState.completed);
    expect(find.text('×'), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Monthly discarded Task remains visible and struck through', (
    tester,
  ) async {
    final _MemoryMonthlyJournal dataSource = _MemoryMonthlyJournal(
      taskEntries: [
        const MonthlyLogEntry(
          id: 'task-1',
          type: JournalEntryType.task,
          taskState: JournalTaskState.open,
          content: 'Old monthly task',
          ordinal: 0,
          section: JournalMonthlySection.tasks,
          calendarDate: null,
        ),
      ],
    );

    await _pumpMonthly(tester, dataSource);
    await tester.tap(find.text('Tasks'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('•'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Discard'));
    await tester.pump();
    await tester.pump();

    expect(dataSource.taskEntries.single.taskState, JournalTaskState.discarded);
    final Text marker = tester.widget<Text>(find.text('•'));
    final Text content = tester.widget<Text>(find.text('Old monthly task'));
    expect(marker.style?.decoration, TextDecoration.lineThrough);
    expect(content.style?.decoration, TextDecoration.lineThrough);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}

Future<void> _pumpMonthly(
  WidgetTester tester,
  _MemoryMonthlyJournal dataSource,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        monthlyJournalDataSourceProvider.overrideWithValue(dataSource),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: MonthlyScreen(initialMonth: DateTime(2026, 9, 15)),
        ),
      ),
    ),
  );
  await tester.pump();
}

final class _MemoryMonthlyJournal implements MonthlyJournalDataSource {
  _MemoryMonthlyJournal({
    List<MonthlyLogEntry>? calendarEntries,
    List<MonthlyLogEntry>? taskEntries,
  }) : calendarEntries = calendarEntries ?? <MonthlyLogEntry>[],
       taskEntries = taskEntries ?? <MonthlyLogEntry>[];

  final List<MonthlyLogEntry> calendarEntries;
  final List<MonthlyLogEntry> taskEntries;

  @override
  Future<MonthlyLogSnapshot> load(String periodStart) async {
    return MonthlyLogSnapshot(
      logId: 'monthly-$periodStart',
      periodStart: periodStart,
      calendarEntries: calendarEntries,
      taskEntries: taskEntries,
    );
  }

  @override
  Future<void> captureCalendarEvent({
    required String logId,
    required String calendarDate,
    required String content,
  }) async {
    calendarEntries.add(
      MonthlyLogEntry(
        id: 'event-${calendarEntries.length}',
        type: JournalEntryType.event,
        taskState: null,
        content: content,
        ordinal: calendarEntries.length,
        section: JournalMonthlySection.calendar,
        calendarDate: calendarDate,
      ),
    );
  }

  @override
  Future<void> captureTask({
    required String logId,
    required String content,
  }) async {
    taskEntries.add(
      MonthlyLogEntry(
        id: 'task-${taskEntries.length}',
        type: JournalEntryType.task,
        taskState: JournalTaskState.open,
        content: content,
        ordinal: taskEntries.length,
        section: JournalMonthlySection.tasks,
        calendarDate: null,
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
    final int index = taskEntries.indexWhere((entry) => entry.id == entryId);
    if (index < 0) {
      throw StateError('Missing entry.');
    }

    final MonthlyLogEntry source = taskEntries[index];
    if (source.type != JournalEntryType.task ||
        source.taskState != JournalTaskState.open) {
      throw StateError('Only open Tasks can transition.');
    }

    taskEntries[index] = MonthlyLogEntry(
      id: source.id,
      type: source.type,
      taskState: destinationState,
      content: source.content,
      ordinal: source.ordinal,
      section: source.section,
      calendarDate: source.calendarDate,
    );
  }
}
