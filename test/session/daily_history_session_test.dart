import 'dart:io';

import 'package:daymark/core/crypto/key_envelope.dart';
import 'package:daymark/core/session/journal_daily_history_session.dart';
import 'package:daymark/core/session/journal_files.dart';
import 'package:daymark/core/session/journal_index_session.dart';
import 'package:daymark/core/session/journal_session.dart';
import 'package:daymark/features/journal/data/daily_log_repository.dart';
import 'package:daymark/features/journal/data/index_repository.dart';
import 'package:daymark/features/journal/domain/journal_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory directory;
  late JournalSessionManager manager;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp(
      'daymark-daily-history-session-test-',
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

  test('historical Daily lookup is non-creating and survives unlock', () async {
    final JournalSession created = await manager.create(
      masterPassword: 'daily history',
    );

    expect(await created.findDailyLog('2026-09-01'), isNull);
    final List<IndexCandidate> candidatesAfterLookup = await created
        .listIndexCandidates();
    expect(
      candidatesAfterLookup.any(
        (candidate) => candidate.periodStart == '2026-09-01',
      ),
      isFalse,
    );

    final DailyLogSnapshot historical = await created.loadDailyLog(
      '2026-09-01',
    );
    await created.captureDailyLogEntry(
      logId: historical.logId,
      type: JournalEntryType.note,
      content: 'Historic Daily note',
    );

    await manager.lock();
    final JournalSession reopened = await manager.unlock(
      masterPassword: 'daily history',
    );

    final DailyLogSnapshot? persisted = await reopened.findDailyLog(
      '2026-09-01',
    );
    expect(persisted, isNotNull);
    expect(persisted!.entries.single.content, 'Historic Daily note');
    expect(await reopened.findDailyLog('2026-08-31'), isNull);
  });
}
