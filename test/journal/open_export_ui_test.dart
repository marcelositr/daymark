import 'package:daymark/features/journal/presentation/open_export_dialog.dart';
import 'package:daymark/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('open export makes plaintext boundary explicit', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: <Locale>[Locale('en')],
          home: Scaffold(body: OpenExportDialog()),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Plaintext export'), findsOneWidget);
    expect(
      find.text(
        'The exported file is plaintext and is no longer protected by Daymark '
        'encryption. Anyone who can access the file can read its contents.',
      ),
      findsOneWidget,
    );
    expect(
      find.widgetWithText(OutlinedButton, 'Export Markdown'),
      findsOneWidget,
    );
    expect(find.widgetWithText(FilledButton, 'Export JSON'), findsOneWidget);
  });
}
