import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

enum AppearancePreference { system, light, dark }

final class AppearancePreferenceStore {
  const AppearancePreferenceStore(this.file);

  static const String _format = 'daymark-device-preferences';
  static const int _version = 1;

  final File file;

  static Future<AppearancePreferenceStore> forApplication() async {
    final Directory directory = await getApplicationSupportDirectory();
    return AppearancePreferenceStore(
      File(
        '${directory.path}${Platform.pathSeparator}'
        'device-preferences.json',
      ),
    );
  }

  Future<AppearancePreference> load() async {
    if (!await file.exists()) {
      return AppearancePreference.system;
    }

    try {
      final Object? decoded = jsonDecode(await file.readAsString());
      if (decoded is! Map<String, Object?> ||
          decoded['format'] != _format ||
          decoded['version'] != _version) {
        return AppearancePreference.system;
      }

      return switch (decoded['appearance']) {
        'light' => AppearancePreference.light,
        'dark' => AppearancePreference.dark,
        _ => AppearancePreference.system,
      };
    } on FormatException {
      return AppearancePreference.system;
    }
  }

  Future<void> save(AppearancePreference preference) async {
    await file.parent.create(recursive: true);

    final File temporary = File('${file.path}.creating');
    final String contents =
        '${jsonEncode(<String, Object?>{'format': _format, 'version': _version, 'appearance': preference.name})}\n';

    try {
      await temporary.writeAsString(contents, flush: true);
      await temporary.rename(file.path);
    } finally {
      if (await temporary.exists()) {
        await temporary.delete();
      }
    }
  }
}
