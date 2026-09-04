import 'package:daymark/presentation/daymark_notice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Undo notice is in-layout and expires after five seconds', (
    tester,
  ) async {
    await tester.pumpWidget(_noticeHarness());

    final BuildContext context = tester.element(
      find.byType(DaymarkNoticeRegion),
    );
    daymarkNoticeControllerOf(
      context,
    ).showUndo(message: 'Entry created.', actionLabel: 'Undo', onUndo: () {});
    await tester.pump();

    expect(
      find.byKey(const ValueKey<String>('daymark-notice')),
      findsOneWidget,
    );
    expect(find.text('Entry created.'), findsOneWidget);
    expect(find.text('Undo'), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);

    await tester.pump(const Duration(seconds: 5));
    await tester.pump();

    expect(find.text('Entry created.'), findsNothing);
    expect(find.text('Undo'), findsNothing);
  });

  testWidgets('a newer notice replaces the previous transient notice', (
    tester,
  ) async {
    await tester.pumpWidget(_noticeHarness());

    final BuildContext context = tester.element(
      find.byType(DaymarkNoticeRegion),
    );
    final DaymarkNoticeController notices = daymarkNoticeControllerOf(context);

    notices.showUndo(
      message: 'Entry created.',
      actionLabel: 'Undo',
      onUndo: () {},
    );
    await tester.pump();

    notices.showInfo('Backup saved.');
    await tester.pump();

    expect(find.text('Entry created.'), findsNothing);
    expect(find.text('Undo'), findsNothing);
    expect(find.text('Backup saved.'), findsOneWidget);
  });

  testWidgets(
    'activating Undo dismisses the notice before running the action',
    (tester) async {
      bool undone = false;
      await tester.pumpWidget(_noticeHarness());

      final BuildContext context = tester.element(
        find.byType(DaymarkNoticeRegion),
      );
      daymarkNoticeControllerOf(context).showUndo(
        message: 'Entry created.',
        actionLabel: 'Undo',
        onUndo: () {
          undone = true;
        },
      );
      await tester.pump();

      await tester.tap(find.text('Undo'));
      await tester.pump();

      expect(undone, isTrue);
      expect(find.text('Entry created.'), findsNothing);
      expect(find.text('Undo'), findsNothing);
    },
  );
}

Widget _noticeHarness() {
  return const ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            Expanded(child: SizedBox()),
            DaymarkNoticeRegion(),
          ],
        ),
      ),
    ),
  );
}
