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
  });
}

final class _MemoryTodayJournal implements TodayJournalDataSource {
  final List<DailyLogEntry> entries = <DailyLogEntry>[];

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
}
