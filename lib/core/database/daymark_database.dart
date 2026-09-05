import 'package:drift/drift.dart';

import 'daymark_database.steps.dart';

part 'daymark_database.g.dart';

@DriftDatabase(include: {'daymark.drift'})
class DaymarkDatabase extends _$DaymarkDatabase {
  DaymarkDatabase(super.executor);

  static const int currentSchemaVersion = 2;

  @override
  int get schemaVersion => currentSchemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator migrator) async {
      await migrator.createAll();
      await _seedBuiltInSignifiers();
    },
    onUpgrade: stepByStep(
      from1To2: (Migrator migrator, Schema2 schema) async {
        await migrator.createTable(schema.trackers);
        await migrator.createIndex(schema.trackersPeriod);
        await migrator.createTable(schema.trackerMarks);
        await migrator.createIndex(schema.trackerMarksMethodDate);
      },
    ),
    beforeOpen: (OpeningDetails details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  Future<void> _seedBuiltInSignifiers() async {
    const int createdAt = 0;

    for (final (String id, String code) in <(String, String)>[
      ('builtin:priority', 'priority'),
      ('builtin:inspiration', 'inspiration'),
      ('builtin:explore', 'explore'),
    ]) {
      await customStatement(
        '''
        INSERT INTO signifiers (
          id,
          kind,
          builtin_code,
          custom_label,
          custom_symbol,
          created_at
        ) VALUES (?, 'builtin', ?, NULL, NULL, ?)
        ''',
        <Object>[id, code, createdAt],
      );
    }
  }
}
