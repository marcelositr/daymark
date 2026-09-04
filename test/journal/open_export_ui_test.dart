import 'package:daymark/features/journal/presentation/open_export_dialog.dart';
import 'package:daymark/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'open export requires reauthentication and exposes safe outputs',
    (tester) async {
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
          'Re-enter your master password to authorize exporting the complete '
          'journal as structured JSON or readable Markdown.',
        ),
        findsOneWidget,
      );

      final TextField passwordField = tester.widget<TextField>(
        find.byType(TextField),
      );
      expect(passwordField.obscureText, isTrue);
      expect(find.text('Master password'), findsOneWidget);

      expect(find.text('Markdown'), findsOneWidget);
      expect(find.text('JSON'), findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, 'Copy'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Save'), findsOneWidget);

      expect(
        find.text(
          'Saved files and copied content are plaintext and are no longer '
          'protected by Daymark encryption. Clipboard contents may be readable '
          'by other applications or retained by a clipboard manager.',
        ),
        findsOneWidget,
      );
    },
  );
}
