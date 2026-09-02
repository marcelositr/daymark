import 'dart:io';

import 'package:daymark/core/crypto/key_envelope.dart';
import 'package:daymark/core/crypto/security_exception.dart';
import 'package:daymark/core/session/journal_files.dart';
import 'package:daymark/core/session/journal_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory directory;
  late JournalFiles files;
  late JournalSessionManager manager;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('daymark-session-test-');
    files = JournalFiles(directory);
    manager = JournalSessionManager(
      files: files,
      keyEnvelopeService: KeyEnvelopeService(
        parameters: Argon2Parameters.test,
      ),
    );
  });

  tearDown(() async {
    await manager.dispose();
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  });

  test('create, lock, and unlock own the encrypted session lifecycle', () async {
    expect(await manager.inspect(), isA<JournalNeedsCreation>());

    final JournalSession created = await manager.create(
      masterPassword: 'correct horse battery staple',
    );

    expect(created.isClosed, isFalse);
    expect(await files.databaseFile.exists(), isTrue);
    expect(await files.keyEnvelopeFile.exists(), isTrue);
    expect(await files.creatingKeyEnvelopeFile.exists(), isFalse);
    expect(await manager.inspect(), isA<JournalUnlocked>());

    await manager.lock();
    expect(created.isClosed, isTrue);
    expect(await manager.inspect(), isA<JournalLocked>());

    final JournalSession reopened = await manager.unlock(
      masterPassword: 'correct horse battery staple',
    );
    expect(reopened.isClosed, isFalse);
    expect(await manager.inspect(), isA<JournalUnlocked>());
  });

  test('wrong password fails closed and leaves the journal locked', () async {
    await manager.create(masterPassword: 'right password');
    await manager.lock();

    expect(
      manager.unlock(masterPassword: 'wrong password'),
      throwsA(isA<JournalUnlockException>()),
    );

    expect(await manager.inspect(), isA<JournalLocked>());

    final JournalSession reopened = await manager.unlock(
      masterPassword: 'right password',
    );
    expect(reopened.isClosed, isFalse);
  });

  test('incomplete journal file sets are never treated as creatable', () async {
    await files.ensureDirectory();
    await files.databaseFile.writeAsBytes(const <int>[1, 2, 3], flush: true);

    expect(await manager.inspect(), isA<JournalStorageProblem>());
    expect(
      manager.create(masterPassword: 'do not overwrite'),
      throwsA(isA<StateError>()),
    );
    expect(await files.databaseFile.readAsBytes(), const <int>[1, 2, 3]);
  });
}
