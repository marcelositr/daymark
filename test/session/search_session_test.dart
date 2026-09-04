import 'dart:io';

import 'package:daymark/core/crypto/key_envelope.dart';
import 'package:daymark/core/session/journal_files.dart';
import 'package:daymark/core/session/journal_search_session.dart';
import 'package:daymark/core/session/journal_session.dart';
import 'package:daymark/features/journal/data/search_repository.dart';
import 'package:daymark/features/journal/domain/journal_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory directory;
  late JournalSessionManager manager;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp(
      'daymark-search-session-test-',
    );
    manager = JournalSessionManager(
      files: JournalFiles(directory),
      keyEnvelopeService: KeyEnvelopeService(parameters: Argon2Parameters.test),
    );
  });

  tearDown(() async {
    await manager.dispose();
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  });

  test('Search stays read-only and works after lock/unlock', () async {
    final JournalSession created = await manager.create(
      masterPassword: 'search session',
    );
    final String collectionId = await created.createCollection(title: 'Radio');
    await created.captureCollectionEntry(
      collectionId: collectionId,
      type: JournalEntryType.note,
      content: 'Repeater frequency 145.450',
    );

    final List<JournalSearchResult> beforeLock = await created.searchJournal(
      '145.450',
    );
    expect(beforeLock, hasLength(1));
    expect(beforeLock.single.collectionTitle, 'Radio');

    await manager.lock();
    final JournalSession reopened = await manager.unlock(
      masterPassword: 'search session',
    );

    final List<JournalSearchResult> afterUnlock = await reopened.searchJournal(
      'repeater',
    );
    expect(afterUnlock, hasLength(1));
    expect(afterUnlock.single.content, 'Repeater frequency 145.450');
    expect(afterUnlock.single.ownerKind, SearchOwnerKind.collection);

    final collection = await reopened.loadCollection(collectionId);
    expect(collection.entries, hasLength(1));
    expect(collection.entries.single.content, 'Repeater frequency 145.450');
  });
}
