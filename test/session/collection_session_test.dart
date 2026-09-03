import 'dart:io';

import 'package:daymark/core/crypto/key_envelope.dart';
import 'package:daymark/core/session/journal_files.dart';
import 'package:daymark/core/session/journal_session.dart';
import 'package:daymark/features/journal/data/collection_repository.dart';
import 'package:daymark/features/journal/domain/journal_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory directory;
  late JournalFiles files;
  late JournalSessionManager manager;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp(
      'daymark-collection-session-test-',
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
    'Collection entries and Task state persist across lock and unlock',
    () async {
      final JournalSession created = await manager.create(
        masterPassword: 'persistent collection journal',
      );
      final String collectionId = await created.createCollection(
        title: 'Reading',
      );

      await created.captureCollectionEntry(
        collectionId: collectionId,
        type: JournalEntryType.task,
        content: 'Read chapter one',
      );
      await created.captureCollectionEntry(
        collectionId: collectionId,
        type: JournalEntryType.event,
        content: 'Book club',
      );
      await created.captureCollectionEntry(
        collectionId: collectionId,
        type: JournalEntryType.note,
        content: 'Check bibliography',
      );

      final CollectionSnapshot captured = await created.loadCollection(
        collectionId,
      );
      await created.completeTask(entryId: captured.entries.first.id);

      await manager.lock();
      final JournalSession reopened = await manager.unlock(
        masterPassword: 'persistent collection journal',
      );

      final List<CollectionSummary> collections = await reopened
          .listCollections();
      final CollectionSnapshot loaded = await reopened.loadCollection(
        collectionId,
      );

      expect(collections, hasLength(1));
      expect(collections.single.title, 'Reading');
      expect(loaded.title, 'Reading');
      expect(loaded.entries.map((entry) => entry.content), <String>[
        'Read chapter one',
        'Book club',
        'Check bibliography',
      ]);
      expect(loaded.entries.first.type, JournalEntryType.task);
      expect(loaded.entries.first.taskState, JournalTaskState.completed);
      expect(loaded.entries[1].type, JournalEntryType.event);
      expect(loaded.entries[1].taskState, isNull);
      expect(loaded.entries.last.type, JournalEntryType.note);
      expect(loaded.entries.last.taskState, isNull);
    },
  );
}
