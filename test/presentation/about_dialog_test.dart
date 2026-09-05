import 'package:daymark/app/app_info.dart';
import 'package:daymark/l10n/app_localizations.dart';
import 'package:daymark/presentation/about_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('About presents Daymark identity and project locations', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('pt', 'BR'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: DaymarkAboutDialog()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Daymark'), findsOneWidget);
    expect(find.text(DaymarkAppInfo.version), findsOneWidget);
    expect(
      find.text(
        'Um Bullet Journal minimalista e local-first para Linux e Android.',
      ),
      findsOneWidget,
    );
    expect(find.text(DaymarkAppInfo.website), findsOneWidget);
    expect(find.text(DaymarkAppInfo.sourceCode), findsOneWidget);
    expect(find.text(DaymarkAppInfo.issues), findsOneWidget);
    expect(find.text(DaymarkAppInfo.author), findsOneWidget);
    expect(
      find.text(
        'Daymark é um software independente inspirado no método Bullet Journal.',
      ),
      findsOneWidget,
    );
  });
}
