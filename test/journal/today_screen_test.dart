import 'package:daymark/features/journal/data/daily_log_repository.dart';
import 'package:daymark/features/journal/domain/journal_domain.dart';
import 'package:daymark/features/journal/presentation/today_screen.dart';
import 'package:daymark/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  testWidgets('Today schedules an open Task into the Future Log horizon', (
    tester,
  ) async {
    final _MemoryTodayJournal dataSource = _MemoryTodayJournal(
      entries: [
        const DailyLogEntry(
          id: 'task-1',
          type: JournalEntryType.task,
          taskState: JournalTaskState.open,
          content: 'Plan for later',
          ordinal: 0,
        ),
      ],
    );

    await _pumpToday(tester, dataSource);
    final DateTime methodDate = DateTime.parse(dataSource.lastMethodDate!);

    await tester.tap(find.text('•'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Schedule'));
    await tester.pumpAndSettle();

    expect(find.byType(SimpleDialogOption), findsNWidgets(6));
    await tester.tap(find.byType(SimpleDialogOption).first);
    await tester.pumpAndSettle();

    final DateTime nextMonth = DateTime(methodDate.year, methodDate.month + 1);
    expect(dataSource.scheduledPeriodStart, _monthStart(nextMonth));
    expect(dataSource.entries.single.taskState, JournalTaskState.scheduled);
    expect(find.text('<'), findsOneWidget);
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

    final Text discardedMarker = tester.widget<Text>(find.text('•'));
    final Text discardedContent = tester.widget<Text>(
      find.text('Old reminder'),
    );
    expect(discardedMarker.style?.decoration, TextDecoration.lineThrough);
    expect(discardedContent.style?.decoration, TextDecoration.lineThrough);
    expect(find.byType(SnackBar), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Daily reflection isolates open Tasks and deliberate decisions', (
    tester,
  ) async {
    final _MemoryTodayJournal dataSource = _MemoryTodayJournal(
      entries: [
        const DailyLogEntry(
          id: 'task-open',
          type: JournalEntryType.task,
          taskState: JournalTaskState.open,
          content: 'Decide this task',
          ordinal: 0,
        ),
        const DailyLogEntry(
          id: 'note-1',
          type: JournalEntryType.note,
          taskState: null,
          content: 'Keep this note out of reflection',
          ordinal: 1,
        ),
        const DailyLogEntry(
          id: 'task-done',
          type: JournalEntryType.task,
          taskState: JournalTaskState.completed,
          content: 'Already completed',
          ordinal: 2,
        ),
      ],
    );

    await _pumpToday(tester, dataSource);

    await tester.tap(find.byTooltip('Start reflection'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Review each open Task and deliberately decide what happens to it.',
      ),
      findsOneWidget,
    );
    expect(find.text('Decide this task'), findsOneWidget);
    expect(find.text('Keep this note out of reflection'), findsNothing);
    expect(find.text('Already completed'), findsNothing);
    expect(find.byType(TextField), findsNothing);
    expect(find.text('Reference'), findsNothing);

    await tester.tap(find.text('•'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Complete'));
    await tester.pumpAndSettle();

    expect(dataSource.entries.first.taskState, JournalTaskState.completed);
    expect(find.text('No open Tasks to reflect on.'), findsOneWidget);

    await tester.tap(find.byTooltip('Finish reflection'));
    await tester.pumpAndSettle();

    expect(find.text('Keep this note out of reflection'), findsOneWidget);
    expect(find.text('Already completed'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('Linux composer autofocuses and Ctrl+Enter captures', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    final _MemoryTodayJournal dataSource = _MemoryTodayJournal();
    await _pumpToday(tester, dataSource);

    final Finder field = find.byType(TextField);
    expect(tester.widget<TextField>(field).autofocus, isTrue);

    await tester.enterText(field, 'Keyboard capture');
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();

    expect(dataSource.entries, hasLength(1));
    expect(dataSource.entries.single.content, 'Keyboard capture');
    expect(find.text('Keyboard capture'), findsOneWidget);
  });

  testWidgets('Today exposes entry type and Task state to semantics', (
    tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    addTearDown(semantics.dispose);

    final _MemoryTodayJournal dataSource = _MemoryTodayJournal(
      entries: [
        const DailyLogEntry(
          id: 'task-1',
          type: JournalEntryType.task,
          taskState: JournalTaskState.open,
          content: 'Accessible task',
          ordinal: 0,
        ),
      ],
    );

    await _pumpToday(tester, dataSource);

    expect(
      find.bySemanticsLabel('Task, Open, Accessible task'),
      findsOneWidget,
    );
  });

  testWidgets('failed Task action leaves the Task open and reports failure', (
    tester,
  ) async {
    final previousErrorHandler = FlutterError.onError;
    final List<FlutterErrorDetails> reportedErrors = <FlutterErrorDetails>[];
    FlutterError.onError = reportedErrors.add;
    addTearDown(() => FlutterError.onError = previousErrorHandler);

    final _MemoryTodayJournal dataSource = _MemoryTodayJournal(
      failTaskActions: true,
      entries: [
        const DailyLogEntry(
          id: 'task-1',
          type: JournalEntryType.task,
          taskState: JournalTaskState.open,
          content: 'Keep me open',
          ordinal: 0,
        ),
      ],
    );

    await _pumpToday(tester, dataSource);

    await tester.tap(find.text('•'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Complete'));
    await tester.pump();
    await tester.pump();

    expect(dataSource.entries.single.taskState, JournalTaskState.open);
    expect(find.text('•'), findsOneWidget);
    expect(find.text('Could not update this task.'), findsOneWidget);
    expect(reportedErrors, hasLength(1));
    expect(
      reportedErrors.single.exceptionAsString(),
      contains('Journal task action failed (StateError).'),
    );

    await tester.pumpWidget(const SizedBox.shrink());
  });
}

Future<void> _pumpToday(
  WidgetTester tester,
  _MemoryTodayJournal dataSource,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [todayJournalDataSourceProvider.overrideWithValue(dataSource)],
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
  _MemoryTodayJournal({
    List<DailyLogEntry>? entries,
    this.failTaskActions = false,
  }) : entries = entries ?? <DailyLogEntry>[];

  final List<DailyLogEntry> entries;
  final bool failTaskActions;
  String? lastMethodDate;
  String? scheduledPeriodStart;

  @override
  Future<DailyLogSnapshot> load(String methodDate) async {
    lastMethodDate = methodDate;
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
    _failIfRequested();
    _transitionTask(entryId, JournalTaskState.completed);
  }

  @override
  Future<void> scheduleTaskToFuture({
    required String entryId,
    required String periodStart,
  }) async {
    _failIfRequested();
    scheduledPeriodStart = periodStart;
    _transitionTask(entryId, JournalTaskState.scheduled);
  }

  @override
  Future<void> discardTask({required String entryId}) async {
    _failIfRequested();
    _transitionTask(entryId, JournalTaskState.discarded);
  }

  void _failIfRequested() {
    if (failTaskActions) {
      throw StateError('Injected Task action failure.');
    }
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

String _monthStart(DateTime month) {
  return '${month.year.toString().padLeft(4, '0')}-'
      '${month.month.toString().padLeft(2, '0')}-01';
}
