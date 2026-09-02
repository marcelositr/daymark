import 'dart:io';

import 'package:daymark/core/backup/encrypted_backup_service.dart';
import 'package:daymark/core/crypto/journal_key_material.dart';
import 'package:daymark/core/crypto/key_envelope.dart';
import 'package:daymark/core/crypto/security_exception.dart';
import 'package:daymark/core/database/daymark_database.dart';
import 'package:daymark/core/database/encrypted_daymark_database.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const String masterPassword = 'backup recovery fixture password';
  const String entryId = '00000000-0000-7000-8000-000000000901';
  const String content = 'LIVE-SNAPSHOT-CONTENT-901';

  late Directory tempDirectory;
  late KeyEnvelopeService keyEnvelopeService;
  late EncryptedBackupService backupService;

  setUp(() {
    tempDirectory = Directory.systemTemp.createTempSync(
      'daymark-backup-recovery-test-',
    );
    keyEnvelopeService = KeyEnvelopeService(parameters: Argon2Parameters.test);
    backupService = EncryptedBackupService(
      keyEnvelopeService: keyEnvelopeService,
    );
  });

  tearDown(() {
    if (tempDirectory.existsSync()) {
      tempDirectory.deleteSync(recursive: true);
    }
  });

  test(
    'backup snapshots committed data while the source journal stays open',
    () async {
      final File sourceFile = File('${tempDirectory.path}/source.daymark');
      final File backupFile = File(
        '${tempDirectory.path}/source.daymark-backup',
      );
      final File restoredFile = File('${tempDirectory.path}/restored.daymark');
      final File restoredEnvelopeFile = File(
        '${tempDirectory.path}/restored.key-envelope.json',
      );
      final JournalKeyMaterial sourceKey = JournalKeyMaterial.generate();
      final DaymarkDatabase sourceDatabase =
          await EncryptedDaymarkDatabase.createNew(
            file: sourceFile,
            keyMaterial: sourceKey,
          );

      try {
        await sourceDatabase.customStatement(
          '''
        INSERT INTO entries (
          id, entry_type, task_state, content, created_at, updated_at
        ) VALUES (?, 'note', NULL, ?, 1, 1)
        ''',
          <Object>[entryId, content],
        );
        final String encodedEnvelope = await keyEnvelopeService.wrap(
          masterPassword: masterPassword,
          keyMaterial: sourceKey,
        );

        await backupService.createBackup(
          journalFile: sourceFile,
          backupFile: backupFile,
          keyMaterial: sourceKey,
          encodedKeyEnvelope: encodedEnvelope,
          masterPassword: masterPassword,
        );

        // The original Drift connection is deliberately still alive here.
        expect(
          await sourceDatabase
              .customSelect('SELECT count(*) AS c FROM entries')
              .getSingle()
              .then((row) => row.read<int>('c')),
          1,
        );

        await backupService.restoreBackup(
          backupFile: backupFile,
          destinationJournalFile: restoredFile,
          destinationKeyEnvelopeFile: restoredEnvelopeFile,
          masterPassword: masterPassword,
        );

        final JournalKeyMaterial restoredKey = await keyEnvelopeService.unwrap(
          masterPassword: masterPassword,
          encodedEnvelope: await restoredEnvelopeFile.readAsString(),
        );
        try {
          final DaymarkDatabase restoredDatabase =
              await EncryptedDaymarkDatabase.openExisting(
                file: restoredFile,
                keyMaterial: restoredKey,
              );
          try {
            final row = await restoredDatabase
                .customSelect(
                  'SELECT content FROM entries WHERE id = ?',
                  variables: <Variable<Object>>[Variable<Object>(entryId)],
                )
                .getSingle();
            expect(row.read<String>('content'), content);
          } finally {
            await restoredDatabase.close();
          }
        } finally {
          restoredKey.destroy();
        }
      } finally {
        await sourceDatabase.close();
        sourceKey.destroy();
      }
    },
  );

  test(
    'stale rollback residue is removed before another restore starts',
    () async {
      final File databaseFile = File('${tempDirectory.path}/journal.daymark');
      final File envelopeFile = File(
        '${tempDirectory.path}/journal.key-envelope.json',
      );
      final File rollbackDatabase = File(
        '${databaseFile.path}.restore-rollback',
      );
      final File rollbackEnvelope = File(
        '${envelopeFile.path}.restore-rollback',
      );

      await databaseFile.writeAsBytes(<int>[1], flush: true);
      await envelopeFile.writeAsString('{}', flush: true);
      await rollbackDatabase.writeAsBytes(<int>[2], flush: true);
      await rollbackEnvelope.writeAsString('{"old":true}', flush: true);

      await backupService.recoverInterruptedRestore(
        destinationJournalFile: databaseFile,
        destinationKeyEnvelopeFile: envelopeFile,
      );

      expect(databaseFile.existsSync(), isTrue);
      expect(envelopeFile.existsSync(), isTrue);
      expect(rollbackDatabase.existsSync(), isFalse);
      expect(rollbackEnvelope.existsSync(), isFalse);
    },
  );

  test('incomplete destination pair without a marker fails closed', () async {
    final File databaseFile = File('${tempDirectory.path}/journal.daymark');
    final File envelopeFile = File(
      '${tempDirectory.path}/journal.key-envelope.json',
    );
    await databaseFile.writeAsBytes(<int>[1], flush: true);

    await expectLater(
      backupService.recoverInterruptedRestore(
        destinationJournalFile: databaseFile,
        destinationKeyEnvelopeFile: envelopeFile,
      ),
      throwsA(isA<BackupRestoreException>()),
    );
  });

  test('orphan rollback material without a marker fails closed', () async {
    final File databaseFile = File('${tempDirectory.path}/journal.daymark');
    final File envelopeFile = File(
      '${tempDirectory.path}/journal.key-envelope.json',
    );
    final File rollbackDatabase = File('${databaseFile.path}.restore-rollback');
    await rollbackDatabase.writeAsBytes(<int>[1], flush: true);

    await expectLater(
      backupService.recoverInterruptedRestore(
        destinationJournalFile: databaseFile,
        destinationKeyEnvelopeFile: envelopeFile,
      ),
      throwsA(isA<BackupRestoreException>()),
    );
  });
}
