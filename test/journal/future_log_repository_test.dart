import 'package:daymark/core/database/daymark_database.dart';
import 'package:daymark/features/journal/application/journal_service.dart';
import 'package:daymark/features/journal/data/future_log_repository.dart';
import 'package:daymark/features/journal/data/journal_repository.dart';
import 'package:daymark/features/journal/domain/journal_domain.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late DaymarkDatabase database;
  late JournalService service;
  late FutureLogRepository futureLog;

  setUp(() {
    database = DaymarkDatabase(
      DatabaseConnection(
        NativeDatabase.memory(),
        closeStreamsSynchronously: true,
      ),
    );
    final JournalRepository repository = JournalRepository(database);
    service = JournalService(repository);
    futureLog = FutureLogRepository(database, service);
  });

  tearDown(() async {
    await database.close();
  });

  test('loadOrCreate reuses the one Future Log for a month', () async {
    final FutureLogSnapshot first = await futureLog.loadOrCreate('2026-10-01');
    final FutureLogSnapshot second = await futureLog.loadOrCreate('2026-10-01');

    expect(second.logId, first.logId);

    final row = await database
        .customSelect(
          "SELECT COUNT(*) AS count FROM logs WHERE kind = 'future'",
        )
        .getSingle();
    expect(row.read<int>('count'), 1);
  });

  test('Future entries preserve type, task state, and order', () async {
    final FutureLogSnapshot initial = await futureLog.loadOrCreate('2026-10-01');

    await futureLog.capture(
      logId: initial.logId,
      type: JournalEntryType.task,
      content: 'Renew passport',
    );
    await futureLog.capture(
      logId: initial.logId,
      type: JournalEntryType.event,
      content: 'Conference',
    );
    await futureLog.capture(
      logId: initial.logId,
      type: JournalEntryType.note,
      content: 'Check train schedule',
    );

    final FutureLogSnapshot loaded = await futureLog.loadOrCreate('2026-10-01');

    expect(loaded.entries.map((entry) => entry.content), <String>[
      'Renew passport',
      'Conference',
      'Check train schedule',
    ]);
    expect(loaded.entries[0].type, JournalEntryType.task);
    expect(loaded.entries[0].taskState, JournalTaskState.open);
    expect(loaded.entries[1].type, JournalEntryType.event);
    expect(loaded.entries[1].taskState, isNull);
    expect(loaded.entries[2].type, JournalEntryType.note);
    expect(loaded.entries[2].taskState, isNull);
  });

  test('different Future months remain separate buckets', () async {
    final FutureLogSnapshot october = await futureLog.loadOrCreate('2026-10-01');
    final FutureLogSnapshot november = await futureLog.loadOrCreate('2026-11-01');

    await futureLog.capture(
      logId: october.logId,
      type: JournalEntryType.event,
      content: 'October event',
    );
    await futureLog.capture(
      logId: november.logId,
      type: JournalEntryType.task,
      content: 'November task',
    );

    final FutureLogSnapshot loadedOctober = await futureLog.loadOrCreate(
      '2026-10-01',
    );
    final FutureLogSnapshot loadedNovember = await futureLog.loadOrCreate(
      '2026-11-01',
    );

    expect(loadedOctober.entries.single.content, 'October event');
    expect(loadedNovember.entries.single.content, 'November task');
  });

  test('capture rejects a non-Future Log owner', () async {
    final String dailyLogId = await service.createLog(
      kind: JournalLogKind.daily,
      periodStart: '2026-09-03',
    );

    expect(
      futureLog.capture(
        logId: dailyLogId,
        type: JournalEntryType.task,
        content: 'Wrong owner',
      ),
      throwsA(isA<JournalInvariantException>()),
    );

    final row = await database
        .customSelect('SELECT COUNT(*) AS count FROM entries')
        .getSingle();
    expect(row.read<int>('count'), 0);
  });

  test('Future periods must start on the first day of a month', () async {
    expect(
      futureLog.loadOrCreate('2026-10-12'),
      throwsA(isA<JournalInvariantException>()),
    );

    final row = await database
        .customSelect(
          "SELECT COUNT(*) AS count FROM logs WHERE kind = 'future'",
        )
        .getSingle();
    expect(row.read<int>('count'), 0);
  });
}
