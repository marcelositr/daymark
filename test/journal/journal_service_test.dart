import 'package:daymark/core/database/daymark_database.dart';
import 'package:daymark/features/journal/application/journal_service.dart';
import 'package:daymark/features/journal/data/journal_repository.dart';
import 'package:daymark/features/journal/domain/journal_domain.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late DaymarkDatabase database;
  late JournalService service;
  late _IdSequence ids;

  setUp(() {
    database = DaymarkDatabase(
      DatabaseConnection(
        NativeDatabase.memory(),
        closeStreamsSynchronously: true,
      ),
    );
    ids = _IdSequence();
    service = JournalService(
      JournalRepository(
        database,
        idGenerator: ids.next,
        nowUtcMicros: () => 1_000_000,
      ),
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('Monthly calendar placement must belong to the owning month', () async {
    final String monthlyLog = await service.createLog(
      kind: JournalLogKind.monthly,
      periodStart: '2026-09-01',
    );

    final String entry = await service.capture(
      type: JournalEntryType.event,
      content: 'Dentist',
      owner: JournalLogOwner(
        logId: monthlyLog,
        monthlySection: JournalMonthlySection.calendar,
        monthlyCalendarDate: '2026-09-15',
      ),
    );

    final placement = await database.customSelect(
      '''
      SELECT monthly_section, monthly_calendar_date
      FROM entry_placements
      WHERE entry_id = ?
      ''',
      variables: <Variable>[Variable.withString(entry)],
    ).getSingle();
    expect(placement.read<String>('monthly_section'), 'calendar');
    expect(placement.read<String>('monthly_calendar_date'), '2026-09-15');

    expect(
      () => service.capture(
        type: JournalEntryType.event,
        content: 'Wrong month',
        owner: JournalLogOwner(
          logId: monthlyLog,
          monthlySection: JournalMonthlySection.calendar,
          monthlyCalendarDate: '2026-10-01',
        ),
      ),
      throwsA(isA<JournalInvariantException>()),
    );

    final count = await database.customSelect(
      'SELECT COUNT(*) AS count FROM entries',
    ).getSingle();
    expect(count.read<int>('count'), 1);
  });

  test('non-Monthly owners reject Monthly placement fields', () async {
    final String dailyLog = await service.createLog(
      kind: JournalLogKind.daily,
      periodStart: '2026-09-02',
    );

    expect(
      () => service.capture(
        type: JournalEntryType.note,
        content: 'Invalid placement',
        owner: JournalLogOwner(
          logId: dailyLog,
          monthlySection: JournalMonthlySection.tasks,
        ),
      ),
      throwsA(isA<JournalInvariantException>()),
    );

    final count = await database.customSelect(
      'SELECT COUNT(*) AS count FROM entries',
    ).getSingle();
    expect(count.read<int>('count'), 0);
  });

  test('Collection reference preserves ownership and task state', () async {
    final String dailyLog = await service.createLog(
      kind: JournalLogKind.daily,
      periodStart: '2026-09-02',
    );
    final String collection = await service.createCollection(title: 'Work');
    final String entry = await service.capture(
      type: JournalEntryType.task,
      content: 'Call supplier',
      owner: JournalLogOwner(logId: dailyLog),
    );

    await service.referenceInCollection(
      collectionId: collection,
      entryId: entry,
    );

    final row = await database.customSelect(
      '''
      SELECT e.task_state, p.log_id, p.collection_id
      FROM entries e
      JOIN entry_placements p ON p.entry_id = e.id
      WHERE e.id = ?
      ''',
      variables: <Variable>[Variable.withString(entry)],
    ).getSingle();
    expect(row.read<String>('task_state'), 'open');
    expect(row.read<String>('log_id'), dailyLog);
    expect(row.readNullable<String>('collection_id'), isNull);

    final reference = await database.customSelect(
      '''
      SELECT ordinal
      FROM collection_references
      WHERE collection_id = ? AND entry_id = ?
      ''',
      variables: <Variable>[
        Variable.withString(collection),
        Variable.withString(entry),
      ],
    ).getSingle();
    expect(reference.read<int>('ordinal'), 0);

    expect(
      () => service.referenceInCollection(
        collectionId: collection,
        entryId: entry,
      ),
      throwsA(isA<JournalInvariantException>()),
    );
  });

  test('migration preserves source and creates one lineage destination', () async {
    final String dailyLog = await service.createLog(
      kind: JournalLogKind.daily,
      periodStart: '2026-09-02',
    );
    final String monthlyLog = await service.createLog(
      kind: JournalLogKind.monthly,
      periodStart: '2026-10-01',
    );
    final String source = await service.capture(
      type: JournalEntryType.task,
      content: 'Renew insurance',
      owner: JournalLogOwner(logId: dailyLog),
    );

    final String destination = await service.migrate(
      sourceEntryId: source,
      destinationOwner: JournalLogOwner(
        logId: monthlyLog,
        monthlySection: JournalMonthlySection.tasks,
      ),
    );

    final sourceRow = await database.customSelect(
      'SELECT task_state, content FROM entries WHERE id = ?',
      variables: <Variable>[Variable.withString(source)],
    ).getSingle();
    final destinationRow = await database.customSelect(
      'SELECT task_state, content FROM entries WHERE id = ?',
      variables: <Variable>[Variable.withString(destination)],
    ).getSingle();
    expect(sourceRow.read<String>('task_state'), 'migrated');
    expect(destinationRow.read<String>('task_state'), 'open');
    expect(destinationRow.read<String>('content'), 'Renew insurance');

    final sourcePlacement = await database.customSelect(
      'SELECT log_id FROM entry_placements WHERE entry_id = ?',
      variables: <Variable>[Variable.withString(source)],
    ).getSingle();
    final destinationPlacement = await database.customSelect(
      '''
      SELECT log_id, monthly_section
      FROM entry_placements
      WHERE entry_id = ?
      ''',
      variables: <Variable>[Variable.withString(destination)],
    ).getSingle();
    expect(sourcePlacement.read<String>('log_id'), dailyLog);
    expect(destinationPlacement.read<String>('log_id'), monthlyLog);
    expect(destinationPlacement.read<String>('monthly_section'), 'tasks');

    final lineage = await database.customSelect(
      '''
      SELECT source_entry_id, destination_entry_id, kind
      FROM migrations
      WHERE source_entry_id = ?
      ''',
      variables: <Variable>[Variable.withString(source)],
    ).getSingle();
    expect(lineage.read<String>('destination_entry_id'), destination);
    expect(lineage.read<String>('kind'), 'migrated');

    expect(
      () => service.migrate(
        sourceEntryId: source,
        destinationOwner: JournalLogOwner(
          logId: monthlyLog,
          monthlySection: JournalMonthlySection.tasks,
        ),
      ),
      throwsA(isA<JournalInvariantException>()),
    );
  });

  test('scheduled movement requires a Future Log', () async {
    final String dailyLog = await service.createLog(
      kind: JournalLogKind.daily,
      periodStart: '2026-09-02',
    );
    final String monthlyLog = await service.createLog(
      kind: JournalLogKind.monthly,
      periodStart: '2026-10-01',
    );
    final String source = await service.capture(
      type: JournalEntryType.task,
      content: 'Book annual inspection',
      owner: JournalLogOwner(logId: dailyLog),
    );

    expect(
      () => service.schedule(
        sourceEntryId: source,
        futureLogOwner: JournalLogOwner(
          logId: monthlyLog,
          monthlySection: JournalMonthlySection.tasks,
        ),
      ),
      throwsA(isA<JournalInvariantException>()),
    );

    final sourceRow = await database.customSelect(
      'SELECT task_state FROM entries WHERE id = ?',
      variables: <Variable>[Variable.withString(source)],
    ).getSingle();
    expect(sourceRow.read<String>('task_state'), 'open');

    final entryCount = await database.customSelect(
      'SELECT COUNT(*) AS count FROM entries',
    ).getSingle();
    expect(entryCount.read<int>('count'), 1);
  });

  test('scheduling an Event preserves null task state', () async {
    final String dailyLog = await service.createLog(
      kind: JournalLogKind.daily,
      periodStart: '2026-09-02',
    );
    final String futureLog = await service.createLog(
      kind: JournalLogKind.future,
      periodStart: '2027-01-01',
    );
    final String source = await service.capture(
      type: JournalEntryType.event,
      content: 'Conference',
      owner: JournalLogOwner(logId: dailyLog),
    );

    final String destination = await service.schedule(
      sourceEntryId: source,
      futureLogOwner: JournalLogOwner(logId: futureLog),
    );

    final rows = await database.customSelect(
      '''
      SELECT id, task_state
      FROM entries
      WHERE id IN (?, ?)
      ORDER BY id
      ''',
      variables: <Variable>[
        Variable.withString(source),
        Variable.withString(destination),
      ],
    ).get();
    expect(rows, hasLength(2));
    expect(rows.every((row) => row.readNullable<String>('task_state') == null), isTrue);

    final lineage = await database.customSelect(
      'SELECT kind FROM migrations WHERE source_entry_id = ?',
      variables: <Variable>[Variable.withString(source)],
    ).getSingle();
    expect(lineage.read<String>('kind'), 'scheduled');
  });

  test('migration to the same owner is rejected without changing source', () async {
    final String dailyLog = await service.createLog(
      kind: JournalLogKind.daily,
      periodStart: '2026-09-02',
    );
    final String source = await service.capture(
      type: JournalEntryType.task,
      content: 'Keep history honest',
      owner: JournalLogOwner(logId: dailyLog),
    );

    expect(
      () => service.migrate(
        sourceEntryId: source,
        destinationOwner: JournalLogOwner(logId: dailyLog),
      ),
      throwsA(isA<JournalInvariantException>()),
    );

    final sourceRow = await database.customSelect(
      'SELECT task_state FROM entries WHERE id = ?',
      variables: <Variable>[Variable.withString(source)],
    ).getSingle();
    expect(sourceRow.read<String>('task_state'), 'open');

    final migrationCount = await database.customSelect(
      'SELECT COUNT(*) AS count FROM migrations',
    ).getSingle();
    expect(migrationCount.read<int>('count'), 0);
  });

  test('Monthly and Future period buckets must start on day one', () async {
    expect(
      () => service.createLog(
        kind: JournalLogKind.monthly,
        periodStart: '2026-09-02',
      ),
      throwsA(isA<JournalInvariantException>()),
    );
    expect(
      () => service.createLog(
        kind: JournalLogKind.future,
        periodStart: '2027-01-12',
      ),
      throwsA(isA<JournalInvariantException>()),
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
