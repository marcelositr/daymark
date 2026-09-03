import 'dart:io';

import 'package:daymark/core/crypto/key_envelope.dart';
import 'package:daymark/core/session/journal_files.dart';
import 'package:daymark/core/session/journal_monthly_history_session.dart';
import 'package:daymark/core/session/journal_session.dart';
import 'package:daymark/features/journal/data/monthly_log_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory directory;
  late JournalSessionManager manager;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp(
      'daymark-monthly-history-session-test-',
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

  test(
    'historical Monthly lookup is non-creating and survives unlock',
    () async {
      final JournalSession created = await manager.create(
        masterPassword: 'monthly history',
      );

      expect(await created.findMonthlyLog('2026-08-01'), isNull);

      final MonthlyLogSnapshot august = await created.loadMonthlyLog(
        '2026-08-01',
      );
      await created.captureMonthlyCalendarEvent(
        logId: august.logId,
        calendarDate: '2026-08-12',
        content: 'Historic appointment',
      );

      await manager.lock();
      final JournalSession reopened = await manager.unlock(
        masterPassword: 'monthly history',
      );

      final MonthlyLogSnapshot? persisted = await reopened.findMonthlyLog(
        '2026-08-01',
      );
      expect(persisted, isNotNull);
      expect(persisted!.calendarEntries.single.content, 'Historic appointment');
      expect(await reopened.findMonthlyLog('2026-07-01'), isNull);
    },
  );
}
