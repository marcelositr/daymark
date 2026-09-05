import 'package:daymark/presentation/daymark_page_frame.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('page frame uses compact mobile margins', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: DaymarkPageFrame(
            child: SizedBox.expand(key: ValueKey('page-content')),
          ),
        ),
      ),
    );

    final Rect rect = tester.getRect(
      find.byKey(const ValueKey('page-content')),
    );
    expect(rect.left, 16);
    expect(rect.right, 384);
    expect(rect.top, 16);
  });

  testWidgets('page frame centers readable desktop content', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: DaymarkPageFrame(
            child: SizedBox.expand(key: ValueKey('page-content')),
          ),
        ),
      ),
    );

    final Rect rect = tester.getRect(
      find.byKey(const ValueKey('page-content')),
    );
    expect(rect.left, 252);
    expect(rect.right, 1148);
    expect(rect.width, 896);
    expect(rect.top, 32);
  });
}
