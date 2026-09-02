import 'package:daymark/core/database/daymark_database.dart';
import 'package:daymark/features/journal/application/journal_service.dart';
import 'package:daymark/features/journal/application/task_action_service.dart';
import 'package:daymark/features/journal/data/journal_repository.dart';
import 'package:daymark/features/journal/data/task_action_repository.dart';
import 'package:daymark/features/journal/domain/journal_domain.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late DaymarkDatabase database;
  late JournalService journalService;
  late TaskActionService taskActions;
  late _IdSequence ids;

  setUp(() {
    database = DaymarkDatabase(
      DatabaseConnection(
        NativeDatabase.memory(),
        closeStreamsSynchronously: true,
      ),
    );
    ids = _IdSequence();
    journalService = JournalService(
      JournalRepository(
        database,
        idGenerator: ids.next,
        nowUtcMicros: () => 1_000_000,
      ),
    );
    taskActions = TaskActionService(
      TaskActionRepository(database, nowUtcMicros: () => 2_000_000),
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('complete transitions only an open Task and preserves placement', () async {
    final String dailyLog = await journalService.createLog(
      kind: JournalLogKind.daily,
      periodStart: '2026-09-02',
    );
    final String task = await journalService.capture(
      type: JournalEntryType.task,
      content: 'Archive receipts',
      owner: JournalLogOwner(logId: dailyLog),
    );

    await taskActions.complete(entryId: task);

    final row = await database
        .customSelect(
          '''
          SELECT e.task_state, e.content, e.updated_at, p.log_id, p.ordinal
          FROM entries e
          JOIN entry_placements p ON p.entry_id = e.id
          WHERE e.id = ?
          ''',
          variables: <Variable<Object>>[Variable.withString(task)],
        )
        .getSingle();

    expect(row.read<String>('task_state'), 'completed');
    expect(row.read<String>('content'), 'Archive receipts');
    expect(row.read<int>('updated_at'), 2_000_000);
    expect(row.read<String>('log_id'), dailyLog);
    expect(row.read<int>('ordinal'), 0);
  });

  test('discard transitions an open Task to discarded', () async {
    final String dailyLog = await journalService.createLog(
      kind: JournalLogKind.daily,
      periodStart: '2026-09-02',
    );
    final String task = await journalService.capture(
      type: JournalEntryType.task,
      content: 'Obsolete reminder',
      owner: JournalLogOwner(logId: dailyLog),
    );

    await taskActions.discard(entryId: task);

    final row = await database
        .customSelect(
          'SELECT task_state FROM entries WHERE id = ?',
          variables: <Variable<Object>>[Variable.withString(task)],
        )
        .getSingle();
    expect(row.read<String>('task_state'), 'discarded');
  });

  test('Task actions reject Event and Note entries', () async {
    final String dailyLog = await journalService.createLog(
      kind: JournalLogKind.daily,
      periodStart: '2026-09-02',
    );
    final String event = await journalService.capture(
      type: JournalEntryType.event,
      content: 'Workshop',
      owner: JournalLogOwner(logId: dailyLog),
    );
    final String note = await journalService.capture(
      type: JournalEntryType.note,
      content: 'Bring adapter',
      owner: JournalLogOwner(logId: dailyLog),
    );

    expect(
      () => taskActions.complete(entryId: event),
      throwsA(isA<JournalInvariantException>()),
    );
    expect(
      () => taskActions.discard(entryId: note),
      throwsA(isA<JournalInvariantException>()),
    );
  });

  test('a terminal Task cannot be transitioned again', () async {
    final String dailyLog = await journalService.createLog(
      kind: JournalLogKind.daily,
      periodStart: '2026-09-02',
    );
    final String task = await journalService.capture(
      type: JournalEntryType.task,
      content: 'Submit form',
      owner: JournalLogOwner(logId: dailyLog),
    );

    await taskActions.complete(entryId: task);

    expect(
      () => taskActions.discard(entryId: task),
      throwsA(isA<JournalInvariantException>()),
    );

    final row = await database
        .customSelect(
          'SELECT task_state FROM entries WHERE id = ?',
          variables: <Variable<Object>>[Variable.withString(task)],
        )
        .getSingle();
    expect(row.read<String>('task_state'), 'completed');
  });

  test('missing Task fails without creating state', () async {
    expect(
      () => taskActions.complete(entryId: 'missing-entry'),
      throwsA(isA<JournalNotFoundException>()),
    );
  });
}

final class _IdSequence {
  int _value = 1;

  String next() {
    final String suffix = _value.toString().padLeft(12, '0');
    _value++;
    return '00000000-0000-7000-8000-$suffix';
  }
}
