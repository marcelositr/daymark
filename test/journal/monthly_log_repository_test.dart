import 'package:daymark/core/database/daymark_database.dart';
import 'package:daymark/features/journal/application/journal_service.dart';
import 'package:daymark/features/journal/data/journal_repository.dart';
import 'package:daymark/features/journal/data/monthly_log_repository.dart';
import 'package:daymark/features/journal/domain/journal_domain.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late DaymarkDatabase database;
  late MonthlyLogRepository monthlyLog;

  setUp(() {
    database = DaymarkDatabase(
      DatabaseConnection(
        NativeDatabase.memory(),
        closeStreamsSynchronously: true,
      ),
    );
    final JournalRepository repository = JournalRepository(database);
    monthlyLog = MonthlyLogRepository(database, JournalService(repository));
  });

  tearDown(() async {
    await database.close();
  });

  test('loadOrCreate reuses the one Monthly Log for a month', () async {
    final MonthlyLogSnapshot first = await monthlyLog.loadOrCreate(
      '2026-09-01',
    );
    final MonthlyLogSnapshot second = await monthlyLog.loadOrCreate(
      '2026-09-01',
    );

    expect(second.logId, first.logId);

    final row = await database
        .customSelect(
          "SELECT COUNT(*) AS count FROM logs WHERE kind = 'monthly'",
        )
        .getSingle();
    expect(row.read<int>('count'), 1);
  });

  test('Calendar events preserve their date and stay out of Tasks', () async {
    final MonthlyLogSnapshot initial = await monthlyLog.loadOrCreate(
      '2026-09-01',
    );

    await monthlyLog.captureCalendarEvent(
      logId: initial.logId,
      calendarDate: '2026-09-15',
      content: 'Meter inspection',
    );

    final MonthlyLogSnapshot loaded = await monthlyLog.loadOrCreate(
      '2026-09-01',
    );

    expect(loaded.calendarEntries, hasLength(1));
    expect(loaded.taskEntries, isEmpty);
    expect(loaded.calendarEntries.single.type, JournalEntryType.event);
    expect(loaded.calendarEntries.single.taskState, isNull);
    expect(loaded.calendarEntries.single.calendarDate, '2026-09-15');
    expect(loaded.calendarEntries.single.content, 'Meter inspection');
  });

  test('Monthly Tasks are open Tasks in the Tasks section', () async {
    final MonthlyLogSnapshot initial = await monthlyLog.loadOrCreate(
      '2026-09-01',
    );

    await monthlyLog.captureTask(
      logId: initial.logId,
      content: 'Review water bill',
    );

    final MonthlyLogSnapshot loaded = await monthlyLog.loadOrCreate(
      '2026-09-01',
    );

    expect(loaded.calendarEntries, isEmpty);
    expect(loaded.taskEntries, hasLength(1));
    expect(loaded.taskEntries.single.type, JournalEntryType.task);
    expect(loaded.taskEntries.single.taskState, JournalTaskState.open);
    expect(loaded.taskEntries.single.calendarDate, isNull);
    expect(loaded.taskEntries.single.content, 'Review water bill');
  });

  test('Calendar capture rejects a date outside the Monthly Log', () async {
    final MonthlyLogSnapshot initial = await monthlyLog.loadOrCreate(
      '2026-09-01',
    );

    expect(
      monthlyLog.captureCalendarEvent(
        logId: initial.logId,
        calendarDate: '2026-10-01',
        content: 'Wrong month',
      ),
      throwsA(isA<JournalInvariantException>()),
    );

    final MonthlyLogSnapshot loaded = await monthlyLog.loadOrCreate(
      '2026-09-01',
    );
    expect(loaded.calendarEntries, isEmpty);
  });
}
