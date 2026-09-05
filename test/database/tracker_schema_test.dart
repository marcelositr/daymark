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

  test('schema v2 contains Tracker tables', () async {
    expect(DaymarkDatabase.currentSchemaVersion, 2);
    final rows = await database.customSelect('''
      SELECT name
      FROM sqlite_schema
      WHERE type = 'table'
        AND name IN ('trackers', 'tracker_marks')
      ORDER BY name
    ''').get();

    expect(
      rows.map((QueryRow row) => row.read<String>('name')).toList(),
      <String>['tracker_marks', 'trackers'],
    );
  });

  test('Tracker period and fixed color slot are constrained', () async {
    await database.customStatement('''
      INSERT INTO trackers (
        id, title, start_date, planned_end_date, ended_date,
        color_slot, created_at, updated_at
      ) VALUES (
        'tracker-valid', 'Valid', '2026-09-01', '2026-09-30', NULL,
        4, 1, 1
      )
    ''');

    expect(
      () => database.customStatement('''
        INSERT INTO trackers (
          id, title, start_date, planned_end_date, ended_date,
          color_slot, created_at, updated_at
        ) VALUES (
          'tracker-color', 'Bad color', '2026-09-01', '2026-09-30', NULL,
          5, 1, 1
        )
      '''),
      throwsA(isA<SqliteException>()),
    );

    expect(
      () => database.customStatement('''
        INSERT INTO trackers (
          id, title, start_date, planned_end_date, ended_date,
          color_slot, created_at, updated_at
        ) VALUES (
          'tracker-period', 'Bad period', '2026-09-30', '2026-09-01', NULL,
          0, 1, 1
        )
      '''),
      throwsA(isA<SqliteException>()),
    );
  });

  test('Tracker marks persist only explicit +1 and -1 values', () async {
    await database.customStatement('''
      INSERT INTO trackers (
        id, title, start_date, planned_end_date, ended_date,
        color_slot, created_at, updated_at
      ) VALUES (
        'tracker-1', 'Test', '2026-09-01', '2026-09-30', NULL,
        0, 1, 1
      )
    ''');

    await database.customStatement('''
      INSERT INTO tracker_marks (
        tracker_id, method_date, value, created_at, updated_at
      ) VALUES ('tracker-1', '2026-09-04', 1, 2, 2)
    ''');

    expect(
      () => database.customStatement('''
        INSERT INTO tracker_marks (
          tracker_id, method_date, value, created_at, updated_at
        ) VALUES ('tracker-1', '2026-09-05', 0, 2, 2)
      '''),
      throwsA(isA<SqliteException>()),
    );
  });

  test('deleting a Tracker cascades its explicit marks', () async {
    await database.customStatement('''
      INSERT INTO trackers (
        id, title, start_date, planned_end_date, ended_date,
        color_slot, created_at, updated_at
      ) VALUES (
        'tracker-1', 'Test', '2026-09-01', '2026-09-30', NULL,
        0, 1, 1
      )
    ''');
    await database.customStatement('''
      INSERT INTO tracker_marks (
        tracker_id, method_date, value, created_at, updated_at
      ) VALUES ('tracker-1', '2026-09-04', -1, 2, 2)
    ''');

    await database.customStatement("DELETE FROM trackers WHERE id = 'tracker-1'");
    final row = await database.customSelect(
      'SELECT COUNT(*) AS count FROM tracker_marks',
    ).getSingle();
    expect(row.read<int>('count'), 0);
  });
}
