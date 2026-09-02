import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:cryptography/helpers.dart';

import '../crypto/journal_key_material.dart';
import '../crypto/key_envelope.dart';
import '../crypto/security_exception.dart';
import '../database/daymark_database.dart';
import '../database/encrypted_daymark_database.dart';

typedef RestoreCommitHook = FutureOr<void> Function(RestoreCommitPhase phase);

enum RestoreCommitPhase {
  afterExistingFilesMoved,
  afterDatabaseInstalled,
  afterEnvelopeInstalled,
}

/// Creates and restores Daymark's portable encrypted backup container.
///
/// Version 1 stores an encrypted SQLite snapshot plus the journal key envelope.
/// The entire container except its trailing MAC is authenticated with
/// HMAC-SHA256. The MAC key is separated from the journal database key through
/// HKDF-SHA256 with a random per-backup salt.
final class EncryptedBackupService {
  EncryptedBackupService({
    KeyEnvelopeService? keyEnvelopeService,
    RestoreCommitHook? restoreCommitHook,
  }) : _keyEnvelopeService = keyEnvelopeService ?? KeyEnvelopeService(),
       _restoreCommitHook = restoreCommitHook;

  static const String format = 'daymark-backup';
  static const int version = 1;
  static const int integritySaltLength = 16;
  static const int macLength = 32;
  static const int maxManifestLength = 64 * 1024;
  static const int maxEnvelopeLength = 64 * 1024;
  static const int _headerLength = 36;
  static const int _ioChunkLength = 64 * 1024;
  static const String _databaseCipher = 'sqlite3mc-chacha20';
  static const String _integrityKdfName = 'hkdf-sha256';
  static const String _integrityMacName = 'hmac-sha256';
  static const String _integrityInfo = 'daymark-backup-v1-integrity';
  static const String _restoreTransactionFormat = 'daymark-restore-transaction';
  static const int _restoreTransactionVersion = 1;
  static const List<int> _magic = <int>[
    0x44,
    0x41,
    0x59,
    0x4d,
    0x41,
    0x52,
    0x4b,
    0x2d,
    0x42,
    0x41,
    0x43,
    0x4b,
    0x55,
    0x50,
    0x00,
    0x00,
  ];

  final KeyEnvelopeService _keyEnvelopeService;
  final RestoreCommitHook? _restoreCommitHook;
  final Hkdf _integrityKdf = Hkdf(hmac: Hmac.sha256(), outputLength: macLength);
  final Hmac _integrityMac = Hmac.sha256();

  Future<void> createBackup({
    required File journalFile,
    required File backupFile,
    required JournalKeyMaterial keyMaterial,
    required String encodedKeyEnvelope,
    required String masterPassword,
  }) async {
    if (!journalFile.existsSync() || journalFile.lengthSync() == 0) {
      throw const BackupWriteException(
        'The journal database does not exist or is empty.',
      );
    }
    if (backupFile.existsSync()) {
      throw const BackupWriteException(
        'Refusing to overwrite an existing backup file.',
      );
    }
    if (!backupFile.parent.existsSync()) {
      throw const BackupWriteException(
        'The backup destination directory does not exist.',
      );
    }
    if (keyMaterial.isDestroyed) {
      throw StateError('Journal key material has been destroyed.');
    }

    await _verifyEnvelopeMatchesKeyMaterial(
      encodedKeyEnvelope: encodedKeyEnvelope,
      masterPassword: masterPassword,
      keyMaterial: keyMaterial,
    );

    final String token = _randomToken();
    final File snapshotFile = File('${backupFile.path}.snapshot-$token.tmp');
    final File temporaryBackup = File('${backupFile.path}.build-$token.tmp');

    try {
      await EncryptedDaymarkDatabase.createSnapshot(
        sourceFile: journalFile,
        destinationFile: snapshotFile,
        keyMaterial: keyMaterial,
      );

      final Uint8List integritySalt = _secureRandomBytes(integritySaltLength);
      final _BackupManifest manifest = _BackupManifest(
        createdAtUtcMicros: DateTime.now().toUtc().microsecondsSinceEpoch,
        databaseSchemaVersion: DaymarkDatabase.currentSchemaVersion,
        integritySalt: integritySalt,
      );
      final Uint8List manifestBytes = Uint8List.fromList(
        utf8.encode(jsonEncode(manifest.toJson())),
      );
      final Uint8List envelopeBytes = Uint8List.fromList(
        utf8.encode(encodedKeyEnvelope),
      );

      if (manifestBytes.length > maxManifestLength ||
          envelopeBytes.isEmpty ||
          envelopeBytes.length > maxEnvelopeLength) {
        throw const BackupWriteException(
          'Backup metadata exceeds the supported size limits.',
        );
      }

      final int databaseLength = snapshotFile.lengthSync();
      if (databaseLength <= 0) {
        throw const BackupWriteException(
          'Encrypted database snapshot is empty.',
        );
      }

      final Uint8List header = _encodeHeader(
        manifestLength: manifestBytes.length,
        envelopeLength: envelopeBytes.length,
        databaseLength: databaseLength,
      );
      final SecretKeyData integrityKey = await _deriveIntegrityKey(
        keyMaterial: keyMaterial,
        salt: integritySalt,
      );
      final MacSink macSink = await _integrityMac.newMacSink(
        secretKey: integrityKey,
      );
      final IOSink output = temporaryBackup.openWrite();
      bool outputClosed = false;

      try {
        _writeAuthenticated(output, macSink, header);
        _writeAuthenticated(output, macSink, manifestBytes);
        _writeAuthenticated(output, macSink, envelopeBytes);

        await for (final List<int> chunk in snapshotFile.openRead()) {
          _writeAuthenticated(output, macSink, chunk);
        }

        macSink.close();
        final Mac mac = await macSink.mac();
        output.add(mac.bytes);
        await output.flush();
        await output.close();
        outputClosed = true;

        if (backupFile.existsSync()) {
          throw const BackupWriteException(
            'Refusing to overwrite an existing backup file.',
          );
        }
        await temporaryBackup.rename(backupFile.path);
      } finally {
        integrityKey.destroy();
        integritySalt.fillRange(0, integritySalt.length, 0);
        if (!outputClosed) {
          try {
            await output.close();
          } on FileSystemException {
            // Preserve the primary backup error. The temporary container is
            // deleted below on a best-effort basis.
          }
        }
      }
    } on DaymarkSecurityException {
      rethrow;
    } on FileSystemException {
      throw const BackupWriteException('Could not create the backup file.');
    } finally {
      _deleteBestEffort(snapshotFile);
      _deleteBestEffort(temporaryBackup);
    }
  }

  /// Restores a validated backup into the destination journal/key-envelope
  /// pair. The caller must close any active session for the destination first.
  ///
  /// All authentication, compatibility, encrypted-database integrity, and
  /// foreign-key checks complete on staged files before the existing journal is
  /// moved. A transaction marker makes an interrupted commit recoverable.
  Future<void> restoreBackup({
    required File backupFile,
    required File destinationJournalFile,
    required File destinationKeyEnvelopeFile,
    required String masterPassword,
  }) async {
    if (!backupFile.existsSync() || backupFile.lengthSync() == 0) {
      throw const BackupFormatException();
    }
    if (!destinationJournalFile.parent.existsSync() ||
        !destinationKeyEnvelopeFile.parent.existsSync()) {
      throw const BackupRestoreException(
        'The restore destination directory does not exist.',
      );
    }

    await recoverInterruptedRestore(
      destinationJournalFile: destinationJournalFile,
      destinationKeyEnvelopeFile: destinationKeyEnvelopeFile,
    );

    final _BackupMetadata metadata = await _readMetadata(backupFile);
    JournalKeyMaterial? keyMaterial;

    try {
      try {
        keyMaterial = await _keyEnvelopeService.unwrap(
          masterPassword: masterPassword,
          encodedEnvelope: metadata.encodedKeyEnvelope,
        );
      } on JournalUnlockException {
        throw const BackupAuthenticationException();
      } on KeyEnvelopeFormatException {
        throw const BackupFormatException(
          'The backup contains an invalid key envelope.',
        );
      }

      await _verifyBackupAuthentication(
        backupFile: backupFile,
        metadata: metadata,
        keyMaterial: keyMaterial,
      );
      _validateCompatibility(metadata.manifest);

      final _RestorePaths restorePaths = _RestorePaths(
        destinationJournalFile: destinationJournalFile,
        destinationKeyEnvelopeFile: destinationKeyEnvelopeFile,
      );
      try {
        await _deleteRequired(restorePaths.stagedDatabase);
        await _deleteRequired(restorePaths.stagedEnvelope);
      } on FileSystemException {
        throw const BackupRestoreException(
          'Could not prepare restore staging files.',
        );
      }

      try {
        await _extractDatabase(
          backupFile: backupFile,
          metadata: metadata,
          destinationFile: restorePaths.stagedDatabase,
        );
        await restorePaths.stagedEnvelope.writeAsString(
          metadata.encodedKeyEnvelope,
          flush: true,
        );

        try {
          EncryptedDaymarkDatabase.validateExisting(
            file: restorePaths.stagedDatabase,
            keyMaterial: keyMaterial,
            expectedSchemaVersion: metadata.manifest.databaseSchemaVersion,
          );
        } on JournalUnlockException {
          throw const BackupAuthenticationException();
        } on JournalDatabaseOpenException {
          throw const BackupFormatException(
            'The backup contains an invalid encrypted journal database.',
          );
        }

        await _commitRestore(restorePaths);
      } finally {
        if (!restorePaths.transactionMarker.existsSync()) {
          _deleteBestEffort(restorePaths.stagedDatabase);
          _deleteBestEffort(restorePaths.stagedEnvelope);
        }
      }
    } on FileSystemException {
      throw const BackupRestoreException(
        'The backup could not be restored to the requested destination.',
      );
    } finally {
      keyMaterial?.destroy();
    }
  }

  /// Recovers a restore that was interrupted after its durable transaction
  /// marker was written but before commit completed.
  ///
  /// If a previous journal existed, recovery always returns to that journal.
  /// If the destination was new, recovery removes any partially installed pair.
  Future<void> recoverInterruptedRestore({
    required File destinationJournalFile,
    required File destinationKeyEnvelopeFile,
  }) async {
    final _RestorePaths paths = _RestorePaths(
      destinationJournalFile: destinationJournalFile,
      destinationKeyEnvelopeFile: destinationKeyEnvelopeFile,
    );

    if (!paths.transactionMarker.existsSync()) {
      try {
        await _deleteRequired(paths.stagedDatabase);
        await _deleteRequired(paths.stagedEnvelope);

        final bool databaseExists = destinationJournalFile.existsSync();
        final bool envelopeExists = destinationKeyEnvelopeFile.existsSync();
        if (databaseExists != envelopeExists) {
          throw const BackupRestoreException(
            'An incomplete destination journal pair exists without a restore '
            'transaction marker.',
          );
        }

        final bool rollbackExists =
            paths.rollbackDatabase.existsSync() ||
            paths.rollbackEnvelope.existsSync();
        if (databaseExists && envelopeExists) {
          await _deleteRequired(paths.rollbackDatabase);
          await _deleteRequired(paths.rollbackEnvelope);
        } else if (rollbackExists) {
          throw const BackupRestoreException(
            'Rollback material exists without a committed journal pair.',
          );
        }
      } on BackupRestoreException {
        rethrow;
      } on FileSystemException {
        throw const BackupRestoreException(
          'Stale restore state could not be removed safely.',
        );
      }
      return;
    }

    final _RestoreTransaction transaction = await _readRestoreTransaction(
      paths.transactionMarker,
    );

    try {
      if (transaction.hadExistingJournal) {
        await _restoreOriginalFile(
          rollbackFile: paths.rollbackDatabase,
          destinationFile: destinationJournalFile,
        );
        await _restoreOriginalFile(
          rollbackFile: paths.rollbackEnvelope,
          destinationFile: destinationKeyEnvelopeFile,
        );

        if (!destinationJournalFile.existsSync() ||
            !destinationKeyEnvelopeFile.existsSync()) {
          throw const BackupRestoreException(
            'Interrupted restore could not recover the original journal pair.',
          );
        }
      } else {
        await _deleteRequired(destinationJournalFile);
        await _deleteRequired(destinationKeyEnvelopeFile);
      }

      await _deleteRequired(paths.stagedDatabase);
      await _deleteRequired(paths.stagedEnvelope);
      await _deleteRequired(paths.rollbackDatabase);
      await _deleteRequired(paths.rollbackEnvelope);
      await paths.transactionMarker.delete();
    } on BackupRestoreException {
      rethrow;
    } on FileSystemException {
      throw const BackupRestoreException(
        'Interrupted restore recovery could not be completed safely.',
      );
    }
  }

  Future<void> _verifyEnvelopeMatchesKeyMaterial({
    required String encodedKeyEnvelope,
    required String masterPassword,
    required JournalKeyMaterial keyMaterial,
  }) async {
    JournalKeyMaterial? recovered;

    try {
      try {
        recovered = await _keyEnvelopeService.unwrap(
          masterPassword: masterPassword,
          encodedEnvelope: encodedKeyEnvelope,
        );
      } on JournalUnlockException {
        throw const BackupAuthenticationException();
      } on KeyEnvelopeFormatException {
        throw const BackupFormatException(
          'The journal key envelope is invalid.',
        );
      }

      final Uint8List expected = keyMaterial.serialize();
      final Uint8List actual = recovered.serialize();
      try {
        if (!constantTimeBytesEquality.equals(expected, actual)) {
          throw const BackupAuthenticationException();
        }
      } finally {
        expected.fillRange(0, expected.length, 0);
        actual.fillRange(0, actual.length, 0);
      }
    } finally {
      recovered?.destroy();
    }
  }

  Future<SecretKeyData> _deriveIntegrityKey({
    required JournalKeyMaterial keyMaterial,
    required List<int> salt,
  }) async {
    final Uint8List serialized = keyMaterial.serialize();
    final SecretKeyData sourceKey = SecretKeyData(
      serialized,
      overwriteWhenDestroyed: true,
      debugLabel: 'Daymark backup integrity root key',
    );

    try {
      return await _integrityKdf.deriveKey(
        secretKey: sourceKey,
        nonce: salt,
        info: utf8.encode(_integrityInfo),
      );
    } finally {
      sourceKey.destroy();
      serialized.fillRange(0, serialized.length, 0);
    }
  }

  Future<_BackupMetadata> _readMetadata(File backupFile) async {
    RandomAccessFile? input;

    try {
      input = await backupFile.open();
      final int fileLength = await input.length();
      if (fileLength < _headerLength + macLength) {
        throw const BackupFormatException();
      }

      final Uint8List headerBytes = Uint8List.fromList(
        await input.read(_headerLength),
      );
      if (headerBytes.length != _headerLength) {
        throw const BackupFormatException();
      }
      final _BackupHeader header = _parseHeader(headerBytes);

      if (header.manifestLength <= 0 ||
          header.manifestLength > maxManifestLength ||
          header.envelopeLength <= 0 ||
          header.envelopeLength > maxEnvelopeLength ||
          header.databaseLength <= 0) {
        throw const BackupFormatException();
      }

      final int databaseOffset =
          _headerLength + header.manifestLength + header.envelopeLength;
      final int authenticatedLength = databaseOffset + header.databaseLength;
      if (authenticatedLength + macLength != fileLength) {
        throw const BackupFormatException();
      }

      final Uint8List manifestBytes = Uint8List.fromList(
        await input.read(header.manifestLength),
      );
      final Uint8List envelopeBytes = Uint8List.fromList(
        await input.read(header.envelopeLength),
      );
      if (manifestBytes.length != header.manifestLength ||
          envelopeBytes.length != header.envelopeLength) {
        throw const BackupFormatException();
      }

      final String manifestText;
      final String encodedEnvelope;
      try {
        manifestText = utf8.decode(manifestBytes, allowMalformed: false);
        encodedEnvelope = utf8.decode(envelopeBytes, allowMalformed: false);
      } on FormatException {
        throw const BackupFormatException();
      }

      return _BackupMetadata(
        manifest: _BackupManifest.parse(manifestText),
        encodedKeyEnvelope: encodedEnvelope,
        databaseOffset: databaseOffset,
        databaseLength: header.databaseLength,
        authenticatedLength: authenticatedLength,
      );
    } on DaymarkSecurityException {
      rethrow;
    } on FileSystemException {
      throw const BackupFormatException('The backup file could not be read.');
    } finally {
      await input?.close();
    }
  }

  Future<void> _verifyBackupAuthentication({
    required File backupFile,
    required _BackupMetadata metadata,
    required JournalKeyMaterial keyMaterial,
  }) async {
    final SecretKeyData integrityKey = await _deriveIntegrityKey(
      keyMaterial: keyMaterial,
      salt: metadata.manifest.integritySalt,
    );
    final MacSink macSink = await _integrityMac.newMacSink(
      secretKey: integrityKey,
    );
    RandomAccessFile? input;

    try {
      input = await backupFile.open();
      int remaining = metadata.authenticatedLength;
      while (remaining > 0) {
        final int count = min(_ioChunkLength, remaining);
        final List<int> chunk = await input.read(count);
        if (chunk.isEmpty) {
          throw const BackupFormatException();
        }
        macSink.add(chunk);
        remaining -= chunk.length;
      }

      macSink.close();
      final Mac calculated = await macSink.mac();
      final List<int> expected = await input.read(macLength);
      if (expected.length != macLength ||
          !constantTimeBytesEquality.equals(calculated.bytes, expected)) {
        throw const BackupAuthenticationException();
      }
    } on DaymarkSecurityException {
      rethrow;
    } on FileSystemException {
      throw const BackupFormatException('The backup file could not be read.');
    } finally {
      integrityKey.destroy();
      await input?.close();
    }
  }

  void _validateCompatibility(_BackupManifest manifest) {
    if (manifest.databaseSchemaVersion !=
        DaymarkDatabase.currentSchemaVersion) {
      throw BackupCompatibilityException(
        'Backup database schema ${manifest.databaseSchemaVersion} is not '
        'supported by schema ${DaymarkDatabase.currentSchemaVersion}.',
      );
    }
  }

  Future<void> _extractDatabase({
    required File backupFile,
    required _BackupMetadata metadata,
    required File destinationFile,
  }) async {
    RandomAccessFile? input;
    IOSink? output;

    try {
      input = await backupFile.open();
      await input.setPosition(metadata.databaseOffset);
      output = destinationFile.openWrite();

      int remaining = metadata.databaseLength;
      while (remaining > 0) {
        final int count = min(_ioChunkLength, remaining);
        final List<int> chunk = await input.read(count);
        if (chunk.isEmpty) {
          throw const BackupFormatException();
        }
        output.add(chunk);
        remaining -= chunk.length;
      }

      await output.flush();
      await output.close();
      output = null;
    } on DaymarkSecurityException {
      rethrow;
    } on FileSystemException {
      throw const BackupRestoreException(
        'The encrypted database could not be staged for restore.',
      );
    } finally {
      await output?.close();
      await input?.close();
    }
  }

  Future<void> _commitRestore(_RestorePaths paths) async {
    final bool databaseExists = paths.destinationJournalFile.existsSync();
    final bool envelopeExists = paths.destinationKeyEnvelopeFile.existsSync();
    if (databaseExists != envelopeExists) {
      throw const BackupRestoreException(
        'Refusing to replace an incomplete destination journal pair.',
      );
    }
    if (paths.rollbackDatabase.existsSync() ||
        paths.rollbackEnvelope.existsSync()) {
      throw const BackupRestoreException(
        'Refusing to start restore with stale rollback material.',
      );
    }

    final bool hadExistingJournal = databaseExists && envelopeExists;
    await _writeRestoreTransaction(
      paths.transactionMarker,
      hadExistingJournal: hadExistingJournal,
    );

    try {
      if (hadExistingJournal) {
        await paths.destinationJournalFile.rename(paths.rollbackDatabase.path);
        await paths.destinationKeyEnvelopeFile.rename(
          paths.rollbackEnvelope.path,
        );
      }
      await _invokeRestoreCommitHook(
        RestoreCommitPhase.afterExistingFilesMoved,
      );

      await paths.stagedDatabase.rename(paths.destinationJournalFile.path);
      await _invokeRestoreCommitHook(RestoreCommitPhase.afterDatabaseInstalled);

      await paths.stagedEnvelope.rename(paths.destinationKeyEnvelopeFile.path);
      await _invokeRestoreCommitHook(RestoreCommitPhase.afterEnvelopeInstalled);

      // Deleting the marker is the commit point. If the process terminates
      // before this operation, recovery returns to the pre-restore journal.
      await paths.transactionMarker.delete();

      // Old data is still encrypted. Cleanup is best-effort after commit so a
      // cleanup failure cannot turn a completed restore back into data loss.
      _deleteBestEffort(paths.rollbackDatabase);
      _deleteBestEffort(paths.rollbackEnvelope);
    } on Object {
      try {
        await recoverInterruptedRestore(
          destinationJournalFile: paths.destinationJournalFile,
          destinationKeyEnvelopeFile: paths.destinationKeyEnvelopeFile,
        );
      } on DaymarkSecurityException {
        throw const BackupRestoreException(
          'Backup restore failed and automatic rollback was incomplete.',
        );
      }
      throw const BackupRestoreException(
        'Backup restore failed and the previous journal was restored.',
      );
    }
  }

  Future<void> _invokeRestoreCommitHook(RestoreCommitPhase phase) async {
    final RestoreCommitHook? hook = _restoreCommitHook;
    if (hook != null) {
      await hook(phase);
    }
  }

  Future<void> _writeRestoreTransaction(
    File marker, {
    required bool hadExistingJournal,
  }) async {
    if (marker.existsSync()) {
      throw const BackupRestoreException(
        'A restore transaction is already in progress.',
      );
    }

    await marker.writeAsString(
      jsonEncode(<String, Object>{
        'format': _restoreTransactionFormat,
        'version': _restoreTransactionVersion,
        'hadExistingJournal': hadExistingJournal,
      }),
      flush: true,
    );
  }

  Future<_RestoreTransaction> _readRestoreTransaction(File marker) async {
    final Object? decoded;
    try {
      decoded = jsonDecode(await marker.readAsString());
    } on FormatException {
      throw const BackupRestoreException(
        'The restore transaction marker is invalid.',
      );
    } on FileSystemException {
      throw const BackupRestoreException(
        'The restore transaction marker could not be read.',
      );
    }

    if (decoded is! Map<String, Object?> ||
        !_hasExactKeys(decoded, const <String>{
          'format',
          'version',
          'hadExistingJournal',
        }) ||
        decoded['format'] != _restoreTransactionFormat ||
        decoded['version'] != _restoreTransactionVersion ||
        decoded['hadExistingJournal'] is! bool) {
      throw const BackupRestoreException(
        'The restore transaction marker is invalid.',
      );
    }

    return _RestoreTransaction(
      hadExistingJournal: decoded['hadExistingJournal']! as bool,
    );
  }

  Future<void> _restoreOriginalFile({
    required File rollbackFile,
    required File destinationFile,
  }) async {
    if (!rollbackFile.existsSync()) {
      return;
    }
    await _deleteRequired(destinationFile);
    await rollbackFile.rename(destinationFile.path);
  }

  static void _writeAuthenticated(
    IOSink output,
    MacSink macSink,
    List<int> bytes,
  ) {
    output.add(bytes);
    macSink.add(bytes);
  }

  static Uint8List _encodeHeader({
    required int manifestLength,
    required int envelopeLength,
    required int databaseLength,
  }) {
    final ByteData data = ByteData(_headerLength);
    for (int index = 0; index < _magic.length; index++) {
      data.setUint8(index, _magic[index]);
    }
    data.setUint32(16, version, Endian.big);
    data.setUint32(20, manifestLength, Endian.big);
    data.setUint32(24, envelopeLength, Endian.big);
    data.setUint64(28, databaseLength, Endian.big);
    return data.buffer.asUint8List();
  }

  static _BackupHeader _parseHeader(Uint8List bytes) {
    if (bytes.length != _headerLength) {
      throw const BackupFormatException();
    }
    for (int index = 0; index < _magic.length; index++) {
      if (bytes[index] != _magic[index]) {
        throw const BackupFormatException();
      }
    }

    final ByteData data = ByteData.view(
      bytes.buffer,
      bytes.offsetInBytes,
      bytes.lengthInBytes,
    );
    final int parsedVersion = data.getUint32(16, Endian.big);
    if (parsedVersion != version) {
      throw BackupCompatibilityException(
        'Backup format version $parsedVersion is not supported.',
      );
    }

    return _BackupHeader(
      manifestLength: data.getUint32(20, Endian.big),
      envelopeLength: data.getUint32(24, Endian.big),
      databaseLength: data.getUint64(28, Endian.big),
    );
  }
}

final class _BackupHeader {
  const _BackupHeader({
    required this.manifestLength,
    required this.envelopeLength,
    required this.databaseLength,
  });

  final int manifestLength;
  final int envelopeLength;
  final int databaseLength;
}

final class _BackupMetadata {
  const _BackupMetadata({
    required this.manifest,
    required this.encodedKeyEnvelope,
    required this.databaseOffset,
    required this.databaseLength,
    required this.authenticatedLength,
  });

  final _BackupManifest manifest;
  final String encodedKeyEnvelope;
  final int databaseOffset;
  final int databaseLength;
  final int authenticatedLength;
}

final class _BackupManifest {
  const _BackupManifest({
    required this.createdAtUtcMicros,
    required this.databaseSchemaVersion,
    required this.integritySalt,
  });

  factory _BackupManifest.parse(String encoded) {
    final Object? decoded;
    try {
      decoded = jsonDecode(encoded);
    } on FormatException {
      throw const BackupFormatException();
    }

    if (decoded is! Map<String, Object?> ||
        !_hasExactKeys(decoded, const <String>{
          'format',
          'version',
          'createdAtUtcMicros',
          'databaseSchemaVersion',
          'databaseCipher',
          'keyEnvelopeFormat',
          'keyEnvelopeVersion',
          'integrity',
        }) ||
        decoded['format'] != EncryptedBackupService.format ||
        decoded['version'] != EncryptedBackupService.version ||
        decoded['databaseCipher'] != EncryptedBackupService._databaseCipher ||
        decoded['keyEnvelopeFormat'] != KeyEnvelopeService.format ||
        decoded['keyEnvelopeVersion'] != KeyEnvelopeService.version) {
      throw const BackupFormatException();
    }

    final Object? createdAtUtcMicros = decoded['createdAtUtcMicros'];
    final Object? databaseSchemaVersion = decoded['databaseSchemaVersion'];
    final Object? rawIntegrity = decoded['integrity'];
    if (createdAtUtcMicros is! int ||
        createdAtUtcMicros < 0 ||
        databaseSchemaVersion is! int ||
        databaseSchemaVersion < 1 ||
        rawIntegrity is! Map<String, Object?> ||
        !_hasExactKeys(rawIntegrity, const <String>{'kdf', 'mac', 'salt'}) ||
        rawIntegrity['kdf'] != EncryptedBackupService._integrityKdfName ||
        rawIntegrity['mac'] != EncryptedBackupService._integrityMacName ||
        rawIntegrity['salt'] is! String) {
      throw const BackupFormatException();
    }

    final Uint8List integritySalt;
    try {
      integritySalt = Uint8List.fromList(
        base64Url.decode(rawIntegrity['salt']! as String),
      );
    } on FormatException {
      throw const BackupFormatException();
    }
    if (integritySalt.length != EncryptedBackupService.integritySaltLength) {
      throw const BackupFormatException();
    }

    return _BackupManifest(
      createdAtUtcMicros: createdAtUtcMicros,
      databaseSchemaVersion: databaseSchemaVersion,
      integritySalt: integritySalt,
    );
  }

  final int createdAtUtcMicros;
  final int databaseSchemaVersion;
  final Uint8List integritySalt;

  Map<String, Object> toJson() {
    return <String, Object>{
      'format': EncryptedBackupService.format,
      'version': EncryptedBackupService.version,
      'createdAtUtcMicros': createdAtUtcMicros,
      'databaseSchemaVersion': databaseSchemaVersion,
      'databaseCipher': EncryptedBackupService._databaseCipher,
      'keyEnvelopeFormat': KeyEnvelopeService.format,
      'keyEnvelopeVersion': KeyEnvelopeService.version,
      'integrity': <String, Object>{
        'kdf': EncryptedBackupService._integrityKdfName,
        'mac': EncryptedBackupService._integrityMacName,
        'salt': base64Url.encode(integritySalt),
      },
    };
  }
}

final class _RestoreTransaction {
  const _RestoreTransaction({required this.hadExistingJournal});

  final bool hadExistingJournal;
}

final class _RestorePaths {
  _RestorePaths({
    required this.destinationJournalFile,
    required this.destinationKeyEnvelopeFile,
  }) : stagedDatabase = File('${destinationJournalFile.path}.restore-staged'),
       stagedEnvelope = File(
         '${destinationKeyEnvelopeFile.path}.restore-staged',
       ),
       rollbackDatabase = File(
         '${destinationJournalFile.path}.restore-rollback',
       ),
       rollbackEnvelope = File(
         '${destinationKeyEnvelopeFile.path}.restore-rollback',
       ),
       transactionMarker = File(
         '${destinationJournalFile.path}.restore-transaction',
       );

  final File destinationJournalFile;
  final File destinationKeyEnvelopeFile;
  final File stagedDatabase;
  final File stagedEnvelope;
  final File rollbackDatabase;
  final File rollbackEnvelope;
  final File transactionMarker;
}

bool _hasExactKeys(Map<String, Object?> map, Set<String> expected) {
  return map.length == expected.length &&
      map.keys.toSet().containsAll(expected);
}

Future<void> _deleteRequired(File file) async {
  if (file.existsSync()) {
    await file.delete();
  }
}

void _deleteBestEffort(File file) {
  try {
    if (file.existsSync()) {
      file.deleteSync();
    }
  } on FileSystemException {
    // Temporary/rollback files contain only encrypted material. Cleanup after a
    // committed operation is best-effort and must not destroy a valid journal.
  }
}

Uint8List _secureRandomBytes(int length) {
  final Random random = Random.secure();
  return Uint8List.fromList(
    List<int>.generate(length, (_) => random.nextInt(256), growable: false),
  );
}

String _randomToken() {
  final Uint8List bytes = _secureRandomBytes(12);
  final String token = base64Url.encode(bytes).replaceAll('=', '');
  bytes.fillRange(0, bytes.length, 0);
  return token;
}
