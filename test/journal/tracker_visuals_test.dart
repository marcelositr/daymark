import 'package:daymark/features/journal/presentation/tracker_visuals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('tracker mark button exposes selected state to semantics', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DaymarkTrackerMarkButton(
            tooltip: 'Fulfilled',
            selected: true,
            color: Colors.blue,
            icon: Icons.check,
            onPressed: () {},
          ),
        ),
      ),
    );

    expect(
      find.byWidgetPredicate(
        (widget) => widget is Semantics && widget.properties.selected == true,
      ),
      findsOneWidget,
    );
  });
}
