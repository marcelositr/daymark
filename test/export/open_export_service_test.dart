import 'dart:convert';

import 'package:daymark/core/database/daymark_database.dart';
import 'package:daymark/core/export/open_export_service.dart';
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

  test(
    'JSON export is deterministic and preserves journal relationships',
    () async {
      await _seedExportFixture(database);
      final OpenExportService service = OpenExportService(database);

      final OpenExportDocument first = await service.create(
        format: OpenExportFormat.json,
      );
      final OpenExportDocument second = await service.create(
        format: OpenExportFormat.json,
      );

      expect(first.contents, second.contents);
      expect(first.contents.endsWith('\n'), isTrue);

      final Map<String, Object?> payload =
          jsonDecode(first.contents) as Map<String, Object?>;
      expect(payload['format'], OpenExportService.formatName);
      expect(payload['formatVersion'], OpenExportService.formatVersion);
      expect(
        payload['databaseSchemaVersion'],
        DaymarkDatabase.currentSchemaVersion,
      );

      final List<Map<String, Object?>> entries = _maps(payload['entries']);
      final Map<String, Object?> source = entries.singleWhere(
        (entry) => entry['id'] == 'entry-source',
      );
      expect(source['entryType'], 'task');
      expect(source['taskState'], 'migrated');
      expect(source['content'], 'Olá 🌿\nlinha 2');

      final List<Map<String, Object?>> placements = _maps(
        payload['entryPlacements'],
      );
      expect(
        placements.singleWhere(
          (placement) => placement['entryId'] == 'entry-source',
        )['logId'],
        'log-daily',
      );
      expect(
        placements.singleWhere(
          (placement) => placement['entryId'] == 'entry-destination',
        )['collectionId'],
        'collection-1',
      );

      final Map<String, Object?> migration = _maps(payload['migrations'])
          .single;
      expect(migration['sourceEntryId'], 'entry-source');
      expect(migration['destinationEntryId'], 'entry-destination');
      expect(migration['kind'], 'migrated');

      final Map<String, Object?> reference = _maps(
        payload['collectionReferences'],
      ).single;
      expect(reference['collectionId'], 'collection-1');
      expect(reference['entryId'], 'entry-source');

      final Map<String, Object?> entrySignifier = _maps(
        payload['entrySignifiers'],
      ).single;
      expect(entrySignifier['entryId'], 'entry-destination');
      expect(entrySignifier['signifierId'], 'signifier-custom');

      final Map<String, Object?> indexItem = _maps(payload['indexItems'])
          .single;
      expect(indexItem['collectionId'], 'collection-1');
    },
  );

  test(
    'Markdown export is plaintext, readable, and preserves Unicode',
    () async {
      await _seedExportFixture(database);

      final OpenExportDocument document = await OpenExportService(database)
          .create(format: OpenExportFormat.markdown);

      expect(document.contents, startsWith('# Daymark Open Export\n'));
      expect(
        document.contents,
        contains('This is a plaintext export. It is not protected by Daymark'),
      );
      expect(document.contents, contains('Olá 🌿\nlinha 2'));
      expect(document.contents, contains('entry-source'));
      expect(document.contents, contains('entry-destination'));
      expect(document.contents, contains('collection-1'));
      expect(document.contents, contains('migrated'));
    },
  );
}

List<Map<String, Object?>> _maps(Object? value) {
  return (value! as List<Object?>).cast<Map<String, Object?>>();
}

Future<void> _seedExportFixture(DaymarkDatabase database) async {
  await database.customStatement('''
    INSERT INTO journal_metadata (id, created_at, updated_at)
    VALUES ('journal-1', 1, 1)
    ''');
  await database.customStatement('''
    INSERT INTO logs (id, kind, period_start, created_at)
    VALUES ('log-daily', 'daily', '2026-09-04', 10)
    ''');
  await database.customStatement('''
    INSERT INTO collections (id, title, created_at, updated_at)
    VALUES ('collection-1', 'Viagem', 20, 20)
    ''');
  await database.customStatement('''
    INSERT INTO entries (
      id, entry_type, task_state, content, created_at, updated_at
    ) VALUES (
      'entry-source', 'task', 'migrated', 'Olá 🌿\nlinha 2', 30, 40
    )
    ''');
  await database.customStatement('''
    INSERT INTO entries (
      id, entry_type, task_state, content, created_at, updated_at
    ) VALUES (
      'entry-destination', 'task', 'open', 'Olá 🌿\nlinha 2', 40, 40
    )
    ''');
  await database.customStatement('''
    INSERT INTO entry_placements (
      entry_id, log_id, collection_id, ordinal,
      monthly_section, monthly_calendar_date
    ) VALUES ('entry-source', 'log-daily', NULL, 0, NULL, NULL)
    ''');
  await database.customStatement('''
    INSERT INTO entry_placements (
      entry_id, log_id, collection_id, ordinal,
      monthly_section, monthly_calendar_date
    ) VALUES ('entry-destination', NULL, 'collection-1', 0, NULL, NULL)
    ''');
  await database.customStatement('''
    INSERT INTO migrations (
      id, source_entry_id, destination_entry_id, kind, created_at
    ) VALUES (
      'migration-1', 'entry-source', 'entry-destination', 'migrated', 40
    )
    ''');
  await database.customStatement('''
    INSERT INTO collection_references (
      collection_id, entry_id, ordinal, created_at
    ) VALUES ('collection-1', 'entry-source', 0, 50)
    ''');
  await database.customStatement('''
    INSERT INTO signifiers (
      id, kind, builtin_code, custom_label, custom_symbol, created_at
    ) VALUES (
      'signifier-custom', 'custom', NULL, 'Importante', '!', 60
    )
    ''');
  await database.customStatement('''
    INSERT INTO entry_signifiers (entry_id, signifier_id)
    VALUES ('entry-destination', 'signifier-custom')
    ''');
  await database.customStatement('''
    INSERT INTO index_items (
      id, ordinal, log_id, collection_id, created_at
    ) VALUES ('index-1', 0, NULL, 'collection-1', 70)
    ''');
}
