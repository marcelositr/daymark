import 'package:daymark/core/database/daymark_database.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late DaymarkDatabase database;

  setUp(() {
    database = DaymarkDatabase(
      DatabaseConnection(
        NativeDatabase.memory(),
        closeStreamsSynchronously: true,
      ),
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('enables foreign keys and creates schema v1', () async {
    final foreignKeys = await database
        .customSelect('PRAGMA foreign_keys')
        .getSingle();

    expect(foreignKeys.data.values.single, 1);

    final tables = await database.customSelect('''
      SELECT name
      FROM sqlite_schema
      WHERE type = 'table'
        AND name NOT LIKE 'sqlite_%'
      ORDER BY name
    ''').get();

    expect(
      tables.map((row) => row.read<String>('name')).toSet(),
      containsAll(<String>{
        'journal_metadata',
        'logs',
        'collections',
        'entries',
        'entry_placements',
        'migrations',
        'collection_references',
        'signifiers',
        'entry_signifiers',
        'index_items',
      }),
    );
  });

  test('journal metadata is a singleton', () async {
    await database.customStatement('''
      INSERT INTO journal_metadata (id, created_at, updated_at)
      VALUES ('00000000-0000-7000-8000-000000000001', 1, 1)
    ''');

    expect(
      () => database.customStatement('''
        INSERT INTO journal_metadata (id, created_at, updated_at)
        VALUES ('00000000-0000-7000-8000-000000000002', 2, 2)
      '''),
      throwsA(isA<SqliteException>()),
    );
  });

  test('entry type and task state cannot contradict each other', () async {
    await database.customStatement('''
      INSERT INTO entries (
        id, entry_type, task_state, content, created_at, updated_at
      ) VALUES (
        '00000000-0000-7000-8000-000000000010',
        'task', 'open', 'valid task', 1, 1
      )
    ''');

    expect(
      () => database.customStatement('''
        INSERT INTO entries (
          id, entry_type, task_state, content, created_at, updated_at
        ) VALUES (
          '00000000-0000-7000-8000-000000000011',
          'event', 'completed', 'invalid event', 1, 1
        )
      '''),
      throwsA(isA<SqliteException>()),
    );

    expect(
      () => database.customStatement('''
        INSERT INTO entries (
          id, entry_type, task_state, content, created_at, updated_at
        ) VALUES (
          '00000000-0000-7000-8000-000000000012',
          'task', NULL, 'invalid task', 1, 1
        )
      '''),
      throwsA(isA<SqliteException>()),
    );
  });

  test('an entry placement has exactly one owner', () async {
    await database.customStatement('''
      INSERT INTO logs (id, kind, period_start, created_at)
      VALUES (
        '00000000-0000-7000-8000-000000000020',
        'daily', '2026-09-01', 1
      )
    ''');

    await database.customStatement('''
      INSERT INTO collections (id, title, created_at, updated_at)
      VALUES (
        '00000000-0000-7000-8000-000000000021',
        'Collection', 1, 1
      )
    ''');

    await database.customStatement('''
      INSERT INTO entries (
        id, entry_type, task_state, content, created_at, updated_at
      ) VALUES (
        '00000000-0000-7000-8000-000000000022',
        'note', NULL, 'placed note', 1, 1
      )
    ''');

    expect(
      () => database.customStatement('''
        INSERT INTO entry_placements (
          entry_id, log_id, collection_id, ordinal, monthly_section
        ) VALUES (
          '00000000-0000-7000-8000-000000000022',
          '00000000-0000-7000-8000-000000000020',
          '00000000-0000-7000-8000-000000000021',
          0,
          NULL
        )
      '''),
      throwsA(isA<SqliteException>()),
    );
  });

  test(
    'Monthly calendar placements require an explicit calendar date',
    () async {
      await database.customStatement('''
      INSERT INTO logs (id, kind, period_start, created_at)
      VALUES (
        '00000000-0000-7000-8000-000000000023',
        'monthly', '2026-09-01', 1
      )
    ''');

      await database.customStatement('''
      INSERT INTO entries (
        id, entry_type, task_state, content, created_at, updated_at
      ) VALUES (
        '00000000-0000-7000-8000-000000000024',
        'event', NULL, 'Dentist', 1, 1
      )
    ''');

      expect(
        () => database.customStatement('''
        INSERT INTO entry_placements (
          entry_id,
          log_id,
          collection_id,
          ordinal,
          monthly_section,
          monthly_calendar_date
        ) VALUES (
          '00000000-0000-7000-8000-000000000024',
          '00000000-0000-7000-8000-000000000023',
          NULL,
          0,
          'calendar',
          NULL
        )
      '''),
        throwsA(isA<SqliteException>()),
      );

      await database.customStatement('''
      INSERT INTO entry_placements (
        entry_id,
        log_id,
        collection_id,
        ordinal,
        monthly_section,
        monthly_calendar_date
      ) VALUES (
        '00000000-0000-7000-8000-000000000024',
        '00000000-0000-7000-8000-000000000023',
        NULL,
        0,
        'calendar',
        '2026-09-15'
      )
    ''');
    },
  );

  test('migration lineage is a one-to-one chain edge', () async {
    for (final id in <String>[
      '00000000-0000-7000-8000-000000000030',
      '00000000-0000-7000-8000-000000000031',
      '00000000-0000-7000-8000-000000000032',
    ]) {
      await database.customStatement(
        '''
        INSERT INTO entries (
          id, entry_type, task_state, content, created_at, updated_at
        ) VALUES (?, 'task', 'open', 'task', 1, 1)
      ''',
        <Object>[id],
      );
    }

    await database.customStatement('''
      INSERT INTO migrations (
        id, source_entry_id, destination_entry_id, kind, created_at
      ) VALUES (
        '00000000-0000-7000-8000-000000000039',
        '00000000-0000-7000-8000-000000000030',
        '00000000-0000-7000-8000-000000000031',
        'migrated',
        2
      )
    ''');

    expect(
      () => database.customStatement('''
        INSERT INTO migrations (
          id, source_entry_id, destination_entry_id, kind, created_at
        ) VALUES (
          '00000000-0000-7000-8000-000000000038',
          '00000000-0000-7000-8000-000000000030',
          '00000000-0000-7000-8000-000000000032',
          'migrated',
          3
        )
      '''),
      throwsA(isA<SqliteException>()),
    );
  });

  test('built-in signifiers are seeded with stable identities', () async {
    final rows = await database.customSelect('''
      SELECT id, builtin_code
      FROM signifiers
      WHERE kind = 'builtin'
      ORDER BY id
    ''').get();

    expect(rows.map((row) => row.read<String>('id')).toList(), <String>[
      'builtin:explore',
      'builtin:inspiration',
      'builtin:priority',
    ]);
  });
}
