import 'package:daymark/app/daymark_app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('starts on Today', (tester) async {
    await tester.pumpWidget(const DaymarkApp());
    await tester.pumpAndSettle();

    expect(find.text('Today'), findsWidgets);
    expect(find.text('Daymark foundation is ready.'), findsOneWidget);
  });
}
