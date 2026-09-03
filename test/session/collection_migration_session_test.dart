import 'dart:io';

import 'package:daymark/core/crypto/key_envelope.dart';
import 'package:daymark/core/session/journal_files.dart';
import 'package:daymark/core/session/journal_session.dart';
import 'package:daymark/features/journal/data/collection_repository.dart';
import 'package:daymark/features/journal/data/daily_log_repository.dart';
import 'package:daymark/features/journal/domain/journal_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory directory;
  late JournalFiles files;
  late JournalSessionManager manager;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp(
      'daymark-collection-migration-session-test-',
    );
    files = JournalFiles(directory);
    manager = JournalSessionManager(
      files: files,
      keyEnvelopeService: KeyEnvelopeService(parameters: Argon2Parameters.test),
    );
  });

  tearDown(() async {
    await manager.dispose();
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  });

  test(
    'Task migration to Collection preserves source and persists lineage',
    () async {
      final JournalSession created = await manager.create(
        masterPassword: 'collection migration journal',
      );
      final DailyLogSnapshot daily = await created.loadDailyLog('2026-09-03');
      await created.captureDailyLogEntry(
        logId: daily.logId,
        type: JournalEntryType.task,
        content: 'Move into project',
      );
      final DailyLogSnapshot captured = await created.loadDailyLog(
        '2026-09-03',
      );
      final String collectionId = await created.createCollection(
        title: 'Project',
      );

      await created.migrateTaskToCollection(
        entryId: captured.entries.single.id,
        collectionId: collectionId,
      );

      final DailyLogSnapshot sourceAfter = await created.loadDailyLog(
        '2026-09-03',
      );
      final CollectionSnapshot destinationAfter = await created.loadCollection(
        collectionId,
      );
      expect(sourceAfter.entries.single.taskState, JournalTaskState.migrated);
      expect(destinationAfter.entries, hasLength(1));
      expect(destinationAfter.entries.single.content, 'Move into project');
      expect(destinationAfter.entries.single.type, JournalEntryType.task);
      expect(destinationAfter.entries.single.taskState, JournalTaskState.open);

      await manager.lock();
      final JournalSession reopened = await manager.unlock(
        masterPassword: 'collection migration journal',
      );
      final DailyLogSnapshot persistedSource = await reopened.loadDailyLog(
        '2026-09-03',
      );
      final CollectionSnapshot persistedDestination = await reopened
          .loadCollection(collectionId);
      expect(
        persistedSource.entries.single.taskState,
        JournalTaskState.migrated,
      );
      expect(
        persistedDestination.entries.single.taskState,
        JournalTaskState.open,
      );
    },
  );
}
