import 'dart:convert';
import 'dart:io';

import 'package:daymark/l10n/app_localizations_es.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Spanish catalog matches every canonical English message key', () {
    final Map<String, Object?> english = _readCatalog('lib/l10n/app_en.arb');
    final Map<String, Object?> spanish = _readCatalog('lib/l10n/app_es.arb');

    expect(spanish.keys.toSet(), english.keys.toSet());
    expect(spanish['@@locale'], 'es');
    expect(
      spanish.entries
          .where((entry) => entry.key != '@@locale')
          .every((entry) => entry.value is String && entry.value != ''),
      isTrue,
    );
  });

  test('Spanish preserves critical password and plaintext warnings', () {
    final AppLocalizationsEs localizations = AppLocalizationsEs();

    expect(localizations.masterPassword, 'Contraseña maestra');
    expect(localizations.encryptedBackupTitle, contains('cifrada'));
    expect(localizations.openExportWarning, contains('texto sin formato'));
    expect(localizations.openExportWarning, contains('portapapeles'));
  });
}

Map<String, Object?> _readCatalog(String path) {
  return (jsonDecode(File(path).readAsStringSync()) as Map<String, Object?>);
}
