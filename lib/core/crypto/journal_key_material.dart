import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

final class JournalKeyMaterial {
  JournalKeyMaterial._(this._journalKey, Uint8List cipherSalt)
    : _cipherSalt = Uint8List.fromList(cipherSalt) {
    if (_journalKey.bytes.length != journalKeyLength) {
      throw ArgumentError.value(
        _journalKey.bytes.length,
        'journalKey',
        'Journal keys must be $journalKeyLength bytes.',
      );
    }
    if (_cipherSalt.length != cipherSaltLength) {
      throw ArgumentError.value(
        _cipherSalt.length,
        'cipherSalt',
        'Cipher salts must be $cipherSaltLength bytes.',
      );
    }
  }

  factory JournalKeyMaterial.generate() {
    final Uint8List keyBuffer = Uint8List(journalKeyLength);
    final SecretKeyData journalKey = SecretKeyData.randomWithBuffer(
      keyBuffer,
      overwriteWhenDestroyed: true,
      debugLabel: 'Daymark journal data-encryption key',
    );

    return JournalKeyMaterial._(
      journalKey,
      _secureRandomBytes(cipherSaltLength),
    );
  }

  factory JournalKeyMaterial.fromSerialized(List<int> bytes) {
    if (bytes.length != serializedLength) {
      throw ArgumentError.value(
        bytes.length,
        'bytes',
        'Serialized journal key material must be $serializedLength bytes.',
      );
    }

    final Uint8List keyBytes = Uint8List(journalKeyLength);
    keyBytes.setRange(0, journalKeyLength, bytes);

    final Uint8List salt = Uint8List(cipherSaltLength);
    salt.setRange(0, cipherSaltLength, bytes, journalKeyLength);

    return JournalKeyMaterial._(
      SecretKeyData(
        keyBytes,
        overwriteWhenDestroyed: true,
        debugLabel: 'Daymark recovered journal data-encryption key',
      ),
      salt,
    );
  }

  static const int journalKeyLength = 32;
  static const int cipherSaltLength = 16;
  static const int serializedLength = journalKeyLength + cipherSaltLength;

  final SecretKeyData _journalKey;
  final Uint8List _cipherSalt;

  SecretKey get journalKey => _journalKey;

  bool get isDestroyed => _journalKey.isDestroyed;

  Uint8List serialize() {
    if (isDestroyed) {
      throw StateError('Journal key material has been destroyed.');
    }

    final Uint8List result = Uint8List(serializedLength);
    result.setRange(0, journalKeyLength, _journalKey.bytes);
    result.setRange(journalKeyLength, serializedLength, _cipherSalt);
    return result;
  }

  void destroy() {
    if (!isDestroyed) {
      _journalKey.destroy();
      _cipherSalt.fillRange(0, _cipherSalt.length, 0);
    }
  }
}

Uint8List _secureRandomBytes(int length) {
  final Random random = Random.secure();
  return Uint8List.fromList(
    List<int>.generate(length, (_) => random.nextInt(256), growable: false),
  );
}
