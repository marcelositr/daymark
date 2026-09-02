import 'dart:io';

import 'package:daymark/app/daymark_app.dart';
import 'package:daymark/core/crypto/key_envelope.dart';
import 'package:daymark/core/session/journal_files.dart';
import 'package:daymark/core/session/journal_session.dart';
import 'package:daymark/core/session/journal_session_controller.dart';
import 'package:daymark/features/journal/data/daily_log_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Today captures a task without a false save failure', (
    tester,
  ) async {
    final Directory tempDirectory = await Directory.systemTemp.createTemp(
      'daymark-today-widget-test-',
    );
    final JournalSessionManager manager = JournalSessionManager(
      files: JournalFiles(tempDirectory),
      keyEnvelopeService: KeyEnvelopeService(parameters: Argon2Parameters.test),
    );
    final JournalSession session = await manager.create(
      masterPassword: 'today widget test password',
    );

    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await manager.dispose();
      if (await tempDirectory.exists()) {
        await tempDirectory.delete(recursive: true);
      }
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          journalSessionControllerProvider.overrideWithBuild(
            (ref, controller) => JournalUnlocked(session),
          ),
        ],
        child: const DaymarkApp(),
      ),
    );

    await _pumpUntil(tester, find.byType(TextField));
    expect(find.byType(TextField), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Widget task');
    await tester.tap(find.byIcon(Icons.arrow_upward));
    await _pumpUntil(tester, find.text('Widget task'));

    expect(find.text('Widget task'), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);

    final DateTime now = DateTime.now();
    final DailyLogSnapshot snapshot = await session.dailyLog.loadOrCreate(
      formatJournalMethodDate(DateTime(now.year, now.month, now.day)),
    );
    expect(
      snapshot.entries.map((entry) => entry.content),
      contains('Widget task'),
    );
  });
}

Future<void> _pumpUntil(WidgetTester tester, Finder finder) async {
  for (int attempt = 0; attempt < 50; attempt += 1) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }

  fail('Expected widget was not rendered within the test deadline.');
}
