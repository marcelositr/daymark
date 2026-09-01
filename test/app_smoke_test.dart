import 'package:daymark/app/daymark_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('starts on Today', (tester) async {
    await tester.pumpWidget(const DaymarkApp());
    await tester.pumpAndSettle();

    expect(find.text('Today'), findsWidgets);
    expect(find.text('Daymark foundation is ready.'), findsOneWidget);
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
