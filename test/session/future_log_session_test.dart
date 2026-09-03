import 'dart:io';

import 'package:daymark/core/crypto/key_envelope.dart';
import 'package:daymark/core/session/journal_files.dart';
import 'package:daymark/core/session/journal_session.dart';
import 'package:daymark/features/journal/data/future_log_repository.dart';
import 'package:daymark/features/journal/domain/journal_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory directory;
  late JournalFiles files;
  late JournalSessionManager manager;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp(
      'daymark-future-session-test-',
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

  test('Future Log entries and Task state persist across lock and unlock', () async {
    final JournalSession created = await manager.create(
      masterPassword: 'persistent future journal',
    );
    final FutureLogSnapshot initial = await created.loadFutureLog('2026-10-01');

    await created.captureFutureLogEntry(
      logId: initial.logId,
      type: JournalEntryType.task,
      content: 'Renew passport',
    );
    await created.captureFutureLogEntry(
      logId: initial.logId,
      type: JournalEntryType.event,
      content: 'Conference',
    );

    final FutureLogSnapshot captured = await created.loadFutureLog('2026-10-01');
    await created.completeTask(entryId: captured.entries.first.id);

    await manager.lock();
    final JournalSession reopened = await manager.unlock(
      masterPassword: 'persistent future journal',
    );
    final FutureLogSnapshot loaded = await reopened.loadFutureLog('2026-10-01');

    expect(loaded.entries.map((entry) => entry.content), <String>[
      'Renew passport',
      'Conference',
    ]);
    expect(loaded.entries.first.type, JournalEntryType.task);
    expect(loaded.entries.first.taskState, JournalTaskState.completed);
    expect(loaded.entries.last.type, JournalEntryType.event);
    expect(loaded.entries.last.taskState, isNull);
  });
}
