import 'package:daymark/core/database/daymark_database.dart';
import 'package:daymark/features/journal/application/journal_service.dart';
import 'package:daymark/features/journal/data/daily_log_repository.dart';
import 'package:daymark/features/journal/data/journal_repository.dart';
import 'package:daymark/features/journal/domain/journal_domain.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late DaymarkDatabase database;
  late DailyLogRepository dailyLog;

  setUp(() {
    database = DaymarkDatabase(
      DatabaseConnection(
        NativeDatabase.memory(),
        closeStreamsSynchronously: true,
      ),
    );
    final JournalRepository repository = JournalRepository(database);
    dailyLog = DailyLogRepository(database, JournalService(repository));
  });

  tearDown(() async {
    await database.close();
  });

  test('loadOrCreate reuses the one Daily Log for a method date', () async {
    final DailyLogSnapshot first = await dailyLog.loadOrCreate('2026-09-02');
    final DailyLogSnapshot second = await dailyLog.loadOrCreate('2026-09-02');

    expect(second.logId, first.logId);

    final row = await database
        .customSelect(
          "SELECT COUNT(*) AS count FROM logs WHERE kind = 'daily'",
        )
        .getSingle();
    expect(row.read<int>('count'), 1);
  });

  test('Rapid Logging preserves type, task state, and entry order', () async {
    final DailyLogSnapshot initial = await dailyLog.loadOrCreate('2026-09-02');

    await dailyLog.capture(
      logId: initial.logId,
      type: JournalEntryType.task,
      content: 'Call the supplier',
    );
    await dailyLog.capture(
      logId: initial.logId,
      type: JournalEntryType.event,
      content: 'Meter inspection at 14:00',
    );
    await dailyLog.capture(
      logId: initial.logId,
      type: JournalEntryType.note,
      content: 'Bring the old field notebook',
    );

    final DailyLogSnapshot loaded = await dailyLog.loadOrCreate('2026-09-02');

    expect(loaded.entries, hasLength(3));
    expect(loaded.entries.map((entry) => entry.ordinal), <int>[0, 1, 2]);
    expect(
      loaded.entries.map((entry) => entry.type),
      <JournalEntryType>[
        JournalEntryType.task,
        JournalEntryType.event,
        JournalEntryType.note,
      ],
    );
    expect(loaded.entries[0].taskState, JournalTaskState.open);
    expect(loaded.entries[1].taskState, isNull);
    expect(loaded.entries[2].taskState, isNull);
  });
}
