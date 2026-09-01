import 'package:drift/drift.dart';

part 'daymark_database.g.dart';

@DriftDatabase(include: {'daymark.drift'})
class DaymarkDatabase extends _$DaymarkDatabase {
  DaymarkDatabase(QueryExecutor executor) : super(executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator migrator) async {
          await migrator.createAll();
          await _seedBuiltInSignifiers();
        },
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
