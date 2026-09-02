import 'dart:io';

import 'package:daymark/core/crypto/journal_key_material.dart';
import 'package:daymark/core/crypto/key_envelope.dart';
import 'package:daymark/core/database/daymark_database.dart';
import 'package:daymark/core/database/encrypted_daymark_database.dart';
import 'package:daymark/features/journal/application/journal_service.dart';
import 'package:daymark/features/journal/data/daily_log_repository.dart';
import 'package:daymark/features/journal/data/journal_repository.dart';

import 'journal_files.dart';

sealed class JournalAccessState {
  const JournalAccessState();
}

final class JournalNeedsCreation extends JournalAccessState {
  const JournalNeedsCreation();
}

final class JournalLocked extends JournalAccessState {
  const JournalLocked();
}

final class JournalStorageProblem extends JournalAccessState {
  const JournalStorageProblem();
}

final class JournalUnlocked extends JournalAccessState {
  const JournalUnlocked(this.session);

  final JournalSession session;
}

/// Owns every object that is valid only while a journal is unlocked.
///
/// Closing a session closes encrypted persistence first and then destroys the
/// application's mutable journal-key owner. The operation is idempotent so
/// manual lock, lifecycle lock, and teardown may safely converge here later.
final class JournalSession {
  JournalSession._({
    required this.database,
    required JournalKeyMaterial keyMaterial,
  }) : _keyMaterial = keyMaterial,
       repository = JournalRepository(database) {
    service = JournalService(repository);
    dailyLog = DailyLogRepository(database, service);
  }

  final DaymarkDatabase database;
  final JournalKeyMaterial _keyMaterial;
  final JournalRepository repository;
  late final JournalService service;
  late final DailyLogRepository dailyLog;

  bool _closed = false;

  bool get isClosed => _closed;

  Future<void> close() async {
    if (_closed) {
      return;
    }
    _closed = true;

    try {
      await database.close();
    } finally {
      _keyMaterial.destroy();
    }
  }
}

/// Creates, unlocks, and locks the single local journal used by the initial
/// Daymark product flow.
///
/// An encrypted database without its key envelope, an envelope without its
/// database, or a leftover creation marker is never repaired or overwritten
/// automatically. Those states fail closed as [JournalStorageProblem].
final class JournalSessionManager {
  JournalSessionManager({
    required this.files,
    KeyEnvelopeService? keyEnvelopeService,
  }) : _keyEnvelopeService = keyEnvelopeService ?? KeyEnvelopeService();

  final JournalFiles files;
  final KeyEnvelopeService _keyEnvelopeService;

  JournalSession? _session;

  Future<JournalAccessState> inspect() async {
    final JournalSession? session = _session;
    if (session != null && !session.isClosed) {
      return JournalUnlocked(session);
    }

    final bool databaseExists = await files.databaseFile.exists();
    final bool envelopeExists = await files.keyEnvelopeFile.exists();
    final bool creatingEnvelopeExists = await files.creatingKeyEnvelopeFile
        .exists();

    if (!databaseExists && !envelopeExists && !creatingEnvelopeExists) {
      return const JournalNeedsCreation();
    }

    if (databaseExists && envelopeExists && !creatingEnvelopeExists) {
      final int databaseLength = await files.databaseFile.length();
      final int envelopeLength = await files.keyEnvelopeFile.length();
      if (databaseLength > 0 && envelopeLength > 0) {
        return const JournalLocked();
      }
    }

    return const JournalStorageProblem();
  }

  Future<JournalSession> create({required String masterPassword}) async {
    final JournalAccessState accessState = await inspect();
    if (accessState is! JournalNeedsCreation) {
      throw StateError('A new journal can only be created in empty storage.');
    }

    await files.ensureDirectory();

    final JournalKeyMaterial keyMaterial = JournalKeyMaterial.generate();
    DaymarkDatabase? database;

    try {
      final String encodedEnvelope = await _keyEnvelopeService.wrap(
        masterPassword: masterPassword,
        keyMaterial: keyMaterial,
      );

      await files.creatingKeyEnvelopeFile.writeAsString(
        encodedEnvelope,
        flush: true,
      );

      database = await EncryptedDaymarkDatabase.createNew(
        file: files.databaseFile,
        keyMaterial: keyMaterial,
      );

      await files.creatingKeyEnvelopeFile.rename(files.keyEnvelopeFile.path);

      final JournalSession session = JournalSession._(
        database: database,
        keyMaterial: keyMaterial,
      );
      _session = session;
      return session;
    } catch (error, stackTrace) {
      try {
        await database?.close();
      } finally {
        keyMaterial.destroy();
        await _cleanupFailedCreation();
      }
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  Future<JournalSession> unlock({required String masterPassword}) async {
    final JournalAccessState accessState = await inspect();
    if (accessState is! JournalLocked) {
      throw StateError('Only a complete locked journal can be unlocked.');
    }

    JournalKeyMaterial? keyMaterial;
    DaymarkDatabase? database;

    try {
      keyMaterial = await _keyEnvelopeService.unwrap(
        masterPassword: masterPassword,
        encodedEnvelope: await files.keyEnvelopeFile.readAsString(),
      );
      database = await EncryptedDaymarkDatabase.openExisting(
        file: files.databaseFile,
        keyMaterial: keyMaterial,
      );

      final JournalSession session = JournalSession._(
        database: database,
        keyMaterial: keyMaterial,
      );
      _session = session;
      return session;
    } catch (error, stackTrace) {
      try {
        await database?.close();
      } finally {
        keyMaterial?.destroy();
      }
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  Future<void> lock() async {
    final JournalSession? session = _session;
    _session = null;
    await session?.close();
  }

  Future<void> dispose() => lock();

  Future<void> _cleanupFailedCreation() async {
    await _deleteIfExists(files.creatingKeyEnvelopeFile);
    await _deleteIfExists(files.keyEnvelopeFile);
    await _deleteIfExists(files.databaseFile);
  }
}

Future<void> _deleteIfExists(File file) async {
  try {
    if (await file.exists()) {
      await file.delete();
    }
  } on FileSystemException {
    // Preserve the original creation failure. A file that could not be
    // removed is detected as JournalStorageProblem on the next inspection.
  }
}
