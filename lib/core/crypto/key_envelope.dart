import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import 'journal_key_material.dart';
import 'security_exception.dart';

final class Argon2Parameters {
  const Argon2Parameters({
    required this.memoryKiB,
    required this.iterations,
    required this.parallelism,
    this.hashLength = 32,
  });

  /// Starting candidate based on the current OWASP minimum recommendation.
  ///
  /// This is intentionally not called "final". PR #7 must benchmark the
  /// parameters on representative Linux and Android hardware before release.
  static const Argon2Parameters productionCandidate = Argon2Parameters(
    memoryKiB: 19 * 1024,
    iterations: 2,
    parallelism: 1,
  );

  /// Small parameters for deterministic unit tests only.
  static const Argon2Parameters test = Argon2Parameters(
    memoryKiB: 64,
    iterations: 1,
    parallelism: 1,
  );

  static const int requiredHashLength = 32;
  static const int maxMemoryKiB = 256 * 1024;
  static const int maxIterations = 10;
  static const int maxParallelism = 8;

  final int memoryKiB;
  final int iterations;
  final int parallelism;
  final int hashLength;

  void validate() {
    if (hashLength != requiredHashLength ||
        parallelism < 1 ||
        parallelism > maxParallelism ||
        iterations < 1 ||
        iterations > maxIterations ||
        memoryKiB < 8 * parallelism ||
        memoryKiB > maxMemoryKiB) {
      throw const KeyEnvelopeFormatException(
        'Unsupported Argon2id parameters in key envelope.',
      );
    }
  }
}

final class KeyEnvelopeService {
  KeyEnvelopeService({
    this.parameters = Argon2Parameters.productionCandidate,
    Xchacha20? cipher,
  }) : _cipher = cipher ?? Xchacha20.poly1305Aead() {
    parameters.validate();
  }

  static const String format = 'daymark-key-envelope';
  static const int version = 1;
  static const String kdfName = 'argon2id';
  static const String wrapAlgorithm = 'xchacha20-poly1305';
  static const int kdfSaltLength = 16;
  static const int expectedMacLength = 16;

  final Argon2Parameters parameters;
  final Xchacha20 _cipher;

  Future<String> wrap({
    required String masterPassword,
    required JournalKeyMaterial keyMaterial,
  }) async {
    if (masterPassword.isEmpty) {
      throw ArgumentError.value(
        masterPassword,
        'masterPassword',
        'Master password must not be empty.',
      );
    }
    if (keyMaterial.isDestroyed) {
      throw StateError('Journal key material has been destroyed.');
    }

    final Uint8List kdfSalt = _secureRandomBytes(kdfSaltLength);
    final String encodedSalt = base64Url.encode(kdfSalt);
    final List<int> aad = _authenticatedMetadata(
      parameters: parameters,
      encodedSalt: encodedSalt,
    );
    final SecretKey keyEncryptionKey = await _deriveKey(
      password: masterPassword,
      salt: kdfSalt,
      parameters: parameters,
    );
    final Uint8List payload = keyMaterial.serialize();

    try {
      final SecretBox secretBox = await _cipher.encrypt(
        payload,
        secretKey: keyEncryptionKey,
        aad: aad,
      );

      return jsonEncode(<String, Object>{
        'format': format,
        'version': version,
        'kdf': <String, Object>{
          'name': kdfName,
          'memoryKiB': parameters.memoryKiB,
          'iterations': parameters.iterations,
          'parallelism': parameters.parallelism,
          'hashLength': parameters.hashLength,
          'salt': encodedSalt,
        },
        'wrap': <String, Object>{
          'name': wrapAlgorithm,
          'nonce': base64Url.encode(secretBox.nonce),
          'ciphertext': base64Url.encode(secretBox.cipherText),
          'mac': base64Url.encode(secretBox.mac.bytes),
        },
      });
    } finally {
      payload.fillRange(0, payload.length, 0);
      keyEncryptionKey.destroy();
    }
  }

  Future<JournalKeyMaterial> unwrap({
    required String masterPassword,
    required String encodedEnvelope,
  }) async {
    if (masterPassword.isEmpty) {
      throw const JournalUnlockException();
    }

    final _ParsedEnvelope envelope = _parse(encodedEnvelope);
    final List<int> aad = _authenticatedMetadata(
      parameters: envelope.parameters,
      encodedSalt: envelope.encodedSalt,
    );
    final SecretKey keyEncryptionKey = await _deriveKey(
      password: masterPassword,
      salt: envelope.salt,
      parameters: envelope.parameters,
    );

    try {
      final List<int> clearText = await _cipher.decrypt(
        SecretBox(
          envelope.cipherText,
          nonce: envelope.nonce,
          mac: Mac(envelope.mac),
        ),
        secretKey: keyEncryptionKey,
        aad: aad,
      );

      try {
        return JournalKeyMaterial.fromSerialized(clearText);
      } on ArgumentError {
        throw const KeyEnvelopeFormatException(
          'Invalid wrapped journal-key payload.',
        );
      } finally {
        clearText.fillRange(0, clearText.length, 0);
      }
    } on SecretBoxAuthenticationError {
      throw const JournalUnlockException();
    } on ArgumentError {
      throw const JournalUnlockException();
    } finally {
      keyEncryptionKey.destroy();
    }
  }

  Future<SecretKey> _deriveKey({
    required String password,
    required List<int> salt,
    required Argon2Parameters parameters,
  }) {
    final Argon2id algorithm = Argon2id(
      memory: parameters.memoryKiB,
      iterations: parameters.iterations,
      parallelism: parameters.parallelism,
      hashLength: parameters.hashLength,
    );

    return algorithm.deriveKeyFromPassword(password: password, nonce: salt);
  }

  _ParsedEnvelope _parse(String encodedEnvelope) {
    final Object? decoded;
    try {
      decoded = jsonDecode(encodedEnvelope);
    } on FormatException {
      throw const KeyEnvelopeFormatException();
    }

    if (decoded is! Map<String, Object?> ||
        !_hasExactKeys(decoded, const <String>{
          'format',
          'version',
          'kdf',
          'wrap',
        }) ||
        decoded['format'] != format ||
        decoded['version'] != version) {
      throw const KeyEnvelopeFormatException();
    }

    final Object? rawKdf = decoded['kdf'];
    final Object? rawWrap = decoded['wrap'];
    if (rawKdf is! Map<String, Object?> ||
        rawWrap is! Map<String, Object?> ||
        !_hasExactKeys(rawKdf, const <String>{
          'name',
          'memoryKiB',
          'iterations',
          'parallelism',
          'hashLength',
          'salt',
        }) ||
        !_hasExactKeys(rawWrap, const <String>{
          'name',
          'nonce',
          'ciphertext',
          'mac',
        }) ||
        rawKdf['name'] != kdfName ||
        rawWrap['name'] != wrapAlgorithm) {
      throw const KeyEnvelopeFormatException();
    }

    final Object? memoryKiB = rawKdf['memoryKiB'];
    final Object? iterations = rawKdf['iterations'];
    final Object? parallelism = rawKdf['parallelism'];
    final Object? hashLength = rawKdf['hashLength'];
    final Object? encodedSalt = rawKdf['salt'];
    final Object? encodedNonce = rawWrap['nonce'];
    final Object? encodedCipherText = rawWrap['ciphertext'];
    final Object? encodedMac = rawWrap['mac'];

    if (memoryKiB is! int ||
        iterations is! int ||
        parallelism is! int ||
        hashLength is! int ||
        encodedSalt is! String ||
        encodedNonce is! String ||
        encodedCipherText is! String ||
        encodedMac is! String) {
      throw const KeyEnvelopeFormatException();
    }

    final Argon2Parameters parsedParameters = Argon2Parameters(
      memoryKiB: memoryKiB,
      iterations: iterations,
      parallelism: parallelism,
      hashLength: hashLength,
    );
    parsedParameters.validate();

    final Uint8List salt = _decodeBytes(encodedSalt);
    final Uint8List nonce = _decodeBytes(encodedNonce);
    final Uint8List cipherText = _decodeBytes(encodedCipherText);
    final Uint8List mac = _decodeBytes(encodedMac);

    if (salt.length != kdfSaltLength ||
        nonce.length != _cipher.nonceLength ||
        cipherText.length != JournalKeyMaterial.serializedLength ||
        mac.length != expectedMacLength) {
      throw const KeyEnvelopeFormatException();
    }

    return _ParsedEnvelope(
      parameters: parsedParameters,
      encodedSalt: encodedSalt,
      salt: salt,
      nonce: nonce,
      cipherText: cipherText,
      mac: mac,
    );
  }

  static List<int> _authenticatedMetadata({
    required Argon2Parameters parameters,
    required String encodedSalt,
  }) {
    return utf8.encode(
      <String>[
        format,
        'version=$version',
        'kdf=$kdfName',
        'memoryKiB=${parameters.memoryKiB}',
        'iterations=${parameters.iterations}',
        'parallelism=${parameters.parallelism}',
        'hashLength=${parameters.hashLength}',
        'salt=$encodedSalt',
        'wrap=$wrapAlgorithm',
      ].join('\n'),
    );
  }
}

final class _ParsedEnvelope {
  const _ParsedEnvelope({
    required this.parameters,
    required this.encodedSalt,
    required this.salt,
    required this.nonce,
    required this.cipherText,
    required this.mac,
  });

  final Argon2Parameters parameters;
  final String encodedSalt;
  final Uint8List salt;
  final Uint8List nonce;
  final Uint8List cipherText;
  final Uint8List mac;
}

bool _hasExactKeys(Map<String, Object?> map, Set<String> expected) {
  return map.length == expected.length &&
      map.keys.toSet().containsAll(expected);
}

Uint8List _decodeBytes(String encoded) {
  try {
    return Uint8List.fromList(base64Url.decode(encoded));
  } on FormatException {
    throw const KeyEnvelopeFormatException();
  }
}

Uint8List _secureRandomBytes(int length) {
  final Random random = Random.secure();
  return Uint8List.fromList(
    List<int>.generate(length, (_) => random.nextInt(256), growable: false),
  );
}
