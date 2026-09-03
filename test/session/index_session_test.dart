import 'dart:io';

import 'package:daymark/core/crypto/key_envelope.dart';
import 'package:daymark/core/session/journal_files.dart';
import 'package:daymark/core/session/journal_index_session.dart';
import 'package:daymark/core/session/journal_session.dart';
import 'package:daymark/features/journal/data/daily_log_repository.dart';
import 'package:daymark/features/journal/data/index_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory directory;
  late JournalFiles files;
  late JournalSessionManager manager;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp(
      'daymark-index-session-test-',
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

  test('Index survives lock and unlock with deliberate order intact', () async {
    final JournalSession created = await manager.create(
      masterPassword: 'index journal',
    );
    final DailyLogSnapshot daily = await created.loadDailyLog('2026-09-03');
    final String collectionId = await created.createCollection(title: 'Radio');

    await created.addCollectionToIndex(collectionId);
    await created.addLogToIndex(daily.logId);

    final List<IndexItem> beforeLock = await created.listIndexItems();
    expect(beforeLock, hasLength(2));
    expect(beforeLock[0].targetKind, IndexTargetKind.collection);
    expect(beforeLock[0].collectionTitle, 'Radio');
    expect(beforeLock[1].targetKind, IndexTargetKind.log);
    expect(beforeLock[1].targetId, daily.logId);

    await manager.lock();
    final JournalSession reopened = await manager.unlock(
      masterPassword: 'index journal',
    );

    final List<IndexItem> persisted = await reopened.listIndexItems();
    expect(persisted, hasLength(2));
    expect(persisted.map((item) => item.ordinal), <int>[0, 1]);
    expect(persisted[0].targetId, collectionId);
    expect(persisted[1].targetId, daily.logId);

    final List<IndexCandidate> candidates = await reopened
        .listIndexCandidates();
    expect(
      candidates.any((candidate) => candidate.targetId == collectionId),
      isFalse,
    );
    expect(
      candidates.any((candidate) => candidate.targetId == daily.logId),
      isFalse,
    );
  });
}
