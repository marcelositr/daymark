import 'dart:convert';
import 'dart:io';

import 'package:daymark/core/settings/appearance_preferences.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory root;
  late File preferenceFile;
  late AppearancePreferenceStore store;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('daymark-appearance-test-');
    preferenceFile = File(
      '${root.path}${Platform.pathSeparator}preferences.json',
    );
    store = AppearancePreferenceStore(preferenceFile);
  });

  tearDown(() async {
    if (await root.exists()) {
      await root.delete(recursive: true);
    }
  });

  test('missing preference defaults to system', () async {
    expect(await store.load(), AppearancePreference.system);
  });

  test('saved preference survives a new store instance', () async {
    await store.save(AppearancePreference.dark);

    final AppearancePreferenceStore reopened = AppearancePreferenceStore(
      preferenceFile,
    );
    expect(await reopened.load(), AppearancePreference.dark);

    final Map<String, Object?> payload =
        jsonDecode(await preferenceFile.readAsString()) as Map<String, Object?>;
    expect(payload['format'], 'daymark-device-preferences');
    expect(payload['version'], 1);
    expect(payload['appearance'], 'dark');
  });

  test('unknown appearance value falls back to system', () async {
    await preferenceFile.writeAsString(
      '{"format":"daymark-device-preferences",'
      '"version":1,"appearance":"sepia"}\n',
    );

    expect(await store.load(), AppearancePreference.system);
  });

  test('malformed preference file falls back to system', () async {
    await preferenceFile.writeAsString('{not-json');

    expect(await store.load(), AppearancePreference.system);
  });
}
