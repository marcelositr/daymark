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
      'daymark-collection-reference-session-test-',
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
    'Collection reference preserves source and survives lock/unlock',
    () async {
      final JournalSession created = await manager.create(
        masterPassword: 'collection reference journal',
      );
      final DailyLogSnapshot daily = await created.loadDailyLog('2026-09-03');
      await created.captureDailyLogEntry(
        logId: daily.logId,
        type: JournalEntryType.task,
        content: 'Keep original task',
      );
      final DailyLogSnapshot captured = await created.loadDailyLog(
        '2026-09-03',
      );
      final String entryId = captured.entries.single.id;
      final String collectionId = await created.createCollection(
        title: 'Project',
      );

      await created.referenceEntryInCollection(
        entryId: entryId,
        collectionId: collectionId,
      );

      final DailyLogSnapshot sourceAfter = await created.loadDailyLog(
        '2026-09-03',
      );
      final CollectionSnapshot collectionAfter = await created.loadCollection(
        collectionId,
      );
      expect(sourceAfter.entries.single.id, entryId);
      expect(sourceAfter.entries.single.taskState, JournalTaskState.open);
      expect(collectionAfter.entries, isEmpty);
      expect(collectionAfter.references.single.id, entryId);
      expect(
        collectionAfter.references.single.taskState,
        JournalTaskState.open,
      );

      await manager.lock();
      final JournalSession reopened = await manager.unlock(
        masterPassword: 'collection reference journal',
      );
      final DailyLogSnapshot persistedSource = await reopened.loadDailyLog(
        '2026-09-03',
      );
      final CollectionSnapshot persistedCollection = await reopened
          .loadCollection(collectionId);
      expect(persistedSource.entries.single.id, entryId);
      expect(persistedSource.entries.single.taskState, JournalTaskState.open);
      expect(persistedCollection.entries, isEmpty);
      expect(persistedCollection.references.single.id, entryId);
    },
  );
}
