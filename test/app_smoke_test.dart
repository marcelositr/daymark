import 'dart:io';

import 'package:daymark/app/daymark_app.dart';
import 'package:daymark/core/session/journal_files.dart';
import 'package:daymark/core/session/journal_session_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('starts on encrypted journal creation when storage is empty', (
    tester,
  ) async {
    final Directory directory = await Directory.systemTemp.createTemp(
      'daymark-app-smoke-',
    );
    addTearDown(() async {
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          journalFilesProvider.overrideWith(
            (ref) async => JournalFiles(directory),
          ),
        ],
        child: const DaymarkApp(),
      ),
    );
    await _pumpUntilFound(tester, find.text('Create your journal'));

    expect(find.text('Create your journal'), findsOneWidget);
    expect(find.text('Master password'), findsOneWidget);
    expect(find.text('Confirm master password'), findsOneWidget);
  });

  group('locale resolution', () {
    test('uses English when the system locale is unsupported', () {
      expect(
        resolveDaymarkLocale(const <Locale>[Locale('es', 'BR')]),
        const Locale('en'),
      );
    });

    test('uses Brazilian Portuguese for an exact pt_BR system locale', () {
      expect(
        resolveDaymarkLocale(const <Locale>[Locale('pt', 'BR')]),
        const Locale('pt', 'BR'),
      );
    });

    test('does not treat other Portuguese locales as pt_BR', () {
      expect(
        resolveDaymarkLocale(const <Locale>[Locale('pt', 'PT')]),
        const Locale('en'),
      );
    });
  });
}

Future<void> _pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 5),
  Duration interval = const Duration(milliseconds: 50),
}) async {
  final int attempts = timeout.inMilliseconds ~/ interval.inMilliseconds;
  for (int attempt = 0; attempt < attempts; attempt++) {
    await tester.pump(interval);
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }

  fail('Timed out waiting for the expected widget.');
}
