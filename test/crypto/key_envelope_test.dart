import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:daymark/core/crypto/journal_key_material.dart';
import 'package:daymark/core/crypto/key_envelope.dart';
import 'package:daymark/core/crypto/security_exception.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final KeyEnvelopeService service = KeyEnvelopeService(
    parameters: Argon2Parameters.test,
  );

  test('Argon2id derives the same key from identical inputs', () async {
    const Argon2Parameters parameters = Argon2Parameters.test;
    final Argon2id algorithm = Argon2id(
      memory: parameters.memoryKiB,
      iterations: parameters.iterations,
      parallelism: parameters.parallelism,
      hashLength: parameters.hashLength,
    );
    const List<int> salt = <int>[
      0,
      1,
      2,
      3,
      4,
      5,
      6,
      7,
      8,
      9,
      10,
      11,
      12,
      13,
      14,
      15,
    ];

    final SecretKey first = await algorithm.deriveKeyFromPassword(
      password: 'same-password',
      nonce: salt,
    );
    final SecretKey second = await algorithm.deriveKeyFromPassword(
      password: 'same-password',
      nonce: salt,
    );

    try {
      final List<int> firstBytes = await first.extractBytes();
      final List<int> secondBytes = await second.extractBytes();
      expect(firstBytes, orderedEquals(secondBytes));
    } finally {
      first.destroy();
      second.destroy();
    }
  });

  test('Argon2id salt changes derived key material', () async {
    const Argon2Parameters parameters = Argon2Parameters.test;
    final Argon2id algorithm = Argon2id(
      memory: parameters.memoryKiB,
      iterations: parameters.iterations,
      parallelism: parameters.parallelism,
      hashLength: parameters.hashLength,
    );
    const List<int> firstSalt = <int>[
      0,
      1,
      2,
      3,
      4,
      5,
      6,
      7,
      8,
      9,
      10,
      11,
      12,
      13,
      14,
      15,
    ];
    const List<int> secondSalt = <int>[
      15,
      14,
      13,
      12,
      11,
      10,
      9,
      8,
      7,
      6,
      5,
      4,
      3,
      2,
      1,
      0,
    ];

    final SecretKey first = await algorithm.deriveKeyFromPassword(
      password: 'same-password',
      nonce: firstSalt,
    );
    final SecretKey second = await algorithm.deriveKeyFromPassword(
      password: 'same-password',
      nonce: secondSalt,
    );

    try {
      final List<int> firstBytes = await first.extractBytes();
      final List<int> secondBytes = await second.extractBytes();
      expect(firstBytes, isNot(orderedEquals(secondBytes)));
    } finally {
      first.destroy();
      second.destroy();
    }
  });

  test('wraps and unwraps journal key material', () async {
    final JournalKeyMaterial original = JournalKeyMaterial.generate();
    final List<int> expected = original.serialize();

    try {
      final String envelope = await service.wrap(
        masterPassword: 'correct horse battery staple',
        keyMaterial: original,
      );
      final JournalKeyMaterial recovered = await service.unwrap(
        masterPassword: 'correct horse battery staple',
        encodedEnvelope: envelope,
      );

      try {
        expect(recovered.serialize(), orderedEquals(expected));
      } finally {
        recovered.destroy();
      }
    } finally {
      expected.fillRange(0, expected.length, 0);
      original.destroy();
    }
  });

  test('wrong password fails with a generic unlock error', () async {
    final JournalKeyMaterial material = JournalKeyMaterial.generate();

    try {
      final String envelope = await service.wrap(
        masterPassword: 'right-password',
        keyMaterial: material,
      );

      await expectLater(
        service.unwrap(
          masterPassword: 'wrong-password',
          encodedEnvelope: envelope,
        ),
        throwsA(isA<JournalUnlockException>()),
      );
    } finally {
      material.destroy();
    }
  });

  test('modified ciphertext fails authentication', () async {
    final JournalKeyMaterial material = JournalKeyMaterial.generate();

    try {
      final String envelope = await service.wrap(
        masterPassword: 'password',
        keyMaterial: material,
      );
      final String tampered = _mutateEncodedField(
        envelope,
        section: 'wrap',
        field: 'ciphertext',
      );

      await expectLater(
        service.unwrap(masterPassword: 'password', encodedEnvelope: tampered),
        throwsA(isA<JournalUnlockException>()),
      );
    } finally {
      material.destroy();
    }
  });

  test('modified nonce fails authentication', () async {
    final JournalKeyMaterial material = JournalKeyMaterial.generate();

    try {
      final String envelope = await service.wrap(
        masterPassword: 'password',
        keyMaterial: material,
      );
      final String tampered = _mutateEncodedField(
        envelope,
        section: 'wrap',
        field: 'nonce',
      );

      await expectLater(
        service.unwrap(masterPassword: 'password', encodedEnvelope: tampered),
        throwsA(isA<JournalUnlockException>()),
      );
    } finally {
      material.destroy();
    }
  });

  test('modified authentication tag fails authentication', () async {
    final JournalKeyMaterial material = JournalKeyMaterial.generate();

    try {
      final String envelope = await service.wrap(
        masterPassword: 'password',
        keyMaterial: material,
      );
      final String tampered = _mutateEncodedField(
        envelope,
        section: 'wrap',
        field: 'mac',
      );

      await expectLater(
        service.unwrap(masterPassword: 'password', encodedEnvelope: tampered),
        throwsA(isA<JournalUnlockException>()),
      );
    } finally {
      material.destroy();
    }
  });

  test('modified authenticated KDF metadata fails closed', () async {
    final JournalKeyMaterial material = JournalKeyMaterial.generate();

    try {
      final String envelope = await service.wrap(
        masterPassword: 'password',
        keyMaterial: material,
      );
      final Map<String, Object?> root = _decodeEnvelope(envelope);
      final Map<String, Object?> kdf = _section(root, 'kdf');
      kdf['memoryKiB'] = Argon2Parameters.test.memoryKiB + 1;

      await expectLater(
        service.unwrap(
          masterPassword: 'password',
          encodedEnvelope: jsonEncode(root),
        ),
        throwsA(isA<JournalUnlockException>()),
      );
    } finally {
      material.destroy();
    }
  });

  test('truncated envelope payload fails closed', () async {
    final JournalKeyMaterial material = JournalKeyMaterial.generate();

    try {
      final String envelope = await service.wrap(
        masterPassword: 'password',
        keyMaterial: material,
      );
      final String tampered = _truncateEncodedField(
        envelope,
        section: 'wrap',
        field: 'ciphertext',
      );

      await expectLater(
        service.unwrap(masterPassword: 'password', encodedEnvelope: tampered),
        throwsA(isA<KeyEnvelopeFormatException>()),
      );
    } finally {
      material.destroy();
    }
  });

  test('unsupported envelope version is rejected before KDF work', () async {
    final JournalKeyMaterial material = JournalKeyMaterial.generate();

    try {
      final String envelope = await service.wrap(
        masterPassword: 'password',
        keyMaterial: material,
      );
      final Map<String, Object?> root = _decodeEnvelope(envelope);
      root['version'] = 2;

      await expectLater(
        service.unwrap(
          masterPassword: 'password',
          encodedEnvelope: jsonEncode(root),
        ),
        throwsA(isA<KeyEnvelopeFormatException>()),
      );
    } finally {
      material.destroy();
    }
  });

  test('unsupported KDF identifier is rejected before KDF work', () async {
    final JournalKeyMaterial material = JournalKeyMaterial.generate();

    try {
      final String envelope = await service.wrap(
        masterPassword: 'password',
        keyMaterial: material,
      );
      final Map<String, Object?> root = _decodeEnvelope(envelope);
      final Map<String, Object?> kdf = _section(root, 'kdf');
      kdf['name'] = 'unsupported-kdf';

      await expectLater(
        service.unwrap(
          masterPassword: 'password',
          encodedEnvelope: jsonEncode(root),
        ),
        throwsA(isA<KeyEnvelopeFormatException>()),
      );
    } finally {
      material.destroy();
    }
  });

  test(
    'unreasonable Argon2 parameters are rejected before allocation',
    () async {
      final JournalKeyMaterial material = JournalKeyMaterial.generate();

      try {
        final String envelope = await service.wrap(
          masterPassword: 'password',
          keyMaterial: material,
        );
        final Map<String, Object?> root = _decodeEnvelope(envelope);
        final Map<String, Object?> kdf = _section(root, 'kdf');
        kdf['memoryKiB'] = Argon2Parameters.maxMemoryKiB + 1;

        await expectLater(
          service.unwrap(
            masterPassword: 'password',
            encodedEnvelope: jsonEncode(root),
          ),
          throwsA(isA<KeyEnvelopeFormatException>()),
        );
      } finally {
        material.destroy();
      }
    },
  );
}

Map<String, Object?> _decodeEnvelope(String encoded) {
  final Object? decoded = jsonDecode(encoded);
  if (decoded is! Map<String, Object?>) {
    fail('Test fixture is not a JSON object.');
  }
  return decoded;
}

Map<String, Object?> _section(Map<String, Object?> root, String name) {
  final Object? value = root[name];
  if (value is! Map<String, Object?>) {
    fail('Test fixture has no $name object.');
  }
  return value;
}

String _mutateEncodedField(
  String encoded, {
  required String section,
  required String field,
}) {
  final Map<String, Object?> root = _decodeEnvelope(encoded);
  final Map<String, Object?> object = _section(root, section);
  final Object? rawValue = object[field];
  if (rawValue is! String || rawValue.isEmpty) {
    fail('Test fixture has no encoded $section.$field value.');
  }

  final String replacement = rawValue.startsWith('A') ? 'B' : 'A';
  object[field] = '$replacement${rawValue.substring(1)}';
  return jsonEncode(root);
}

String _truncateEncodedField(
  String encoded, {
  required String section,
  required String field,
}) {
  final Map<String, Object?> root = _decodeEnvelope(encoded);
  final Map<String, Object?> object = _section(root, section);
  final Object? rawValue = object[field];
  if (rawValue is! String || rawValue.length < 2) {
    fail('Test fixture has no truncatable $section.$field value.');
  }

  object[field] = rawValue.substring(0, rawValue.length - 2);
  return jsonEncode(root);
}
