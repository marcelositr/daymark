import 'dart:io';

import 'package:daymark/core/backup/encrypted_backup_service.dart';
import 'package:daymark/core/crypto/key_envelope.dart';
import 'package:daymark/core/session/journal_files.dart';
import 'package:daymark/core/session/journal_session.dart';
import 'package:daymark/features/journal/domain/journal_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory directory;
  late JournalSessionManager manager;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp(
      'daymark-journal-metadata-test-',
    );
    final KeyEnvelopeService keyEnvelopeService = KeyEnvelopeService(
      parameters: Argon2Parameters.test,
    );
    manager = JournalSessionManager(
      files: JournalFiles(directory),
      keyEnvelopeService: keyEnvelopeService,
      backupService: EncryptedBackupService(
        keyEnvelopeService: keyEnvelopeService,
      ),
    );
  });

  tearDown(() async {
    await manager.dispose();
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  });

  test('new journals initialize one stable metadata row', () async {
    final JournalSession created = await manager.create(
      masterPassword: 'metadata creation password',
    );

    final rows = await created.database
        .customSelect(
          'SELECT id, singleton, created_at, updated_at FROM journal_metadata',
        )
        .get();

    expect(rows, hasLength(1));
    final row = rows.single.data;
    final String id = row['id']! as String;
    final int createdAt = row['created_at']! as int;
    final int updatedAt = row['updated_at']! as int;

    expect(
      id,
      matches(
        RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-'
          r'[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        ),
      ),
    );
    expect(row['singleton'], 1);
    expect(createdAt, greaterThanOrEqualTo(0));
    expect(updatedAt, greaterThanOrEqualTo(createdAt));

    await manager.lock();
    final JournalSession reopened = await manager.unlock(
      masterPassword: 'metadata creation password',
    );
    final reopenedRows = await reopened.database
        .customSelect('SELECT id FROM journal_metadata')
        .get();

    expect(reopenedRows, hasLength(1));
    expect(reopenedRows.single.data['id'], id);
  });

  test('unlock repairs legacy journals with missing metadata', () async {
    final JournalSession created = await manager.create(
      masterPassword: 'legacy metadata password',
    );
    final daily = await created.loadDailyLog('2026-09-04');
    await created.captureDailyLogEntry(
      logId: daily.logId,
      type: JournalEntryType.note,
      content: 'Legacy journal content',
    );

    await created.database.customStatement('DELETE FROM journal_metadata');
    final beforeLock = await created.database
        .customSelect('SELECT id FROM journal_metadata')
        .get();
    expect(beforeLock, isEmpty);

    await manager.lock();
    final JournalSession reopened = await manager.unlock(
      masterPassword: 'legacy metadata password',
    );

    final metadataRows = await reopened.database
        .customSelect('SELECT id FROM journal_metadata')
        .get();
    expect(metadataRows, hasLength(1));

    final loaded = await reopened.loadDailyLog('2026-09-04');
    expect(loaded.entries, hasLength(1));
    expect(loaded.entries.single.content, 'Legacy journal content');
  });
}
