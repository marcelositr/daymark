import 'package:daymark/core/crypto/journal_key_material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('serialized journal key material round-trips exactly', () {
    final JournalKeyMaterial original = JournalKeyMaterial.generate();
    final List<int> serialized = original.serialize();
    final JournalKeyMaterial recovered = JournalKeyMaterial.fromSerialized(
      serialized,
    );

    try {
      expect(recovered.serialize(), orderedEquals(serialized));
    } finally {
      recovered.destroy();
      serialized.fillRange(0, serialized.length, 0);
      original.destroy();
    }
  });

  test('generated journal key material is not reused', () {
    final JournalKeyMaterial first = JournalKeyMaterial.generate();
    final JournalKeyMaterial second = JournalKeyMaterial.generate();
    final List<int> firstSerialized = first.serialize();
    final List<int> secondSerialized = second.serialize();

    try {
      expect(firstSerialized, isNot(orderedEquals(secondSerialized)));
    } finally {
      firstSerialized.fillRange(0, firstSerialized.length, 0);
      secondSerialized.fillRange(0, secondSerialized.length, 0);
      first.destroy();
      second.destroy();
    }
  });

  test('destroyed journal key material cannot be serialized', () {
    final JournalKeyMaterial material = JournalKeyMaterial.generate();
    material.destroy();

    expect(material.isDestroyed, isTrue);
    expect(material.serialize, throwsStateError);
  });

  test('serialized journal key material requires the exact length', () {
    expect(
      () => JournalKeyMaterial.fromSerialized(
        List<int>.filled(JournalKeyMaterial.serializedLength - 1, 0),
      ),
      throwsArgumentError,
    );
  });
}
