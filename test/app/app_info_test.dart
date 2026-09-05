import 'dart:io';

import 'package:daymark/app/app_info.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('About version stays aligned with pubspec', () {
    final String pubspec = File('pubspec.yaml').readAsStringSync();
    final RegExpMatch? match = RegExp(
      r'^version:\s*(\S+)\s*$',
      multiLine: true,
    ).firstMatch(pubspec);

    expect(match?.group(1), DaymarkAppInfo.version);
  });

  test('About project URLs are explicit HTTPS locations', () {
    for (final String value in [
      DaymarkAppInfo.website,
      DaymarkAppInfo.sourceCode,
      DaymarkAppInfo.issues,
      DaymarkAppInfo.authorWebsite,
    ]) {
      expect(Uri.parse(value).scheme, 'https');
    }
  });
}
