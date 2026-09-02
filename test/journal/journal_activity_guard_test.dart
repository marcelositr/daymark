import 'package:daymark/features/journal/presentation/journal_activity_guard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('locks after the inactivity deadline', (tester) async {
    int lockCount = 0;

    await tester.pumpWidget(
      _testApp(
        timeout: const Duration(seconds: 5),
        onTimeout: () async {
          lockCount += 1;
        },
      ),
    );

    await tester.pump(const Duration(seconds: 4));
    expect(lockCount, 0);

    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    expect(lockCount, 1);
  });

  testWidgets('pointer interaction restarts the inactivity deadline', (
    tester,
  ) async {
    int lockCount = 0;

    await tester.pumpWidget(
      _testApp(
        timeout: const Duration(seconds: 5),
        onTimeout: () async {
          lockCount += 1;
        },
      ),
    );

    await tester.pump(const Duration(seconds: 4));
    await tester.tap(find.text('Interact'));
    await tester.pump();

    await tester.pump(const Duration(seconds: 4));
    expect(lockCount, 0);

    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    expect(lockCount, 1);
  });

  testWidgets('keyboard interaction restarts the inactivity deadline', (
    tester,
  ) async {
    int lockCount = 0;

    await tester.pumpWidget(
      _testApp(
        timeout: const Duration(seconds: 5),
        onTimeout: () async {
          lockCount += 1;
        },
        child: const Scaffold(
          body: Focus(
            autofocus: true,
            child: Center(child: Text('Keyboard target')),
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.pump(const Duration(seconds: 4));
    await tester.sendKeyDownEvent(LogicalKeyboardKey.keyA);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.keyA);

    await tester.pump(const Duration(seconds: 4));
    expect(lockCount, 0);

    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    expect(lockCount, 1);
  });

  testWidgets('explicit text editing restarts the inactivity deadline', (
    tester,
  ) async {
    int lockCount = 0;

    await tester.pumpWidget(
      _testApp(
        timeout: const Duration(seconds: 5),
        onTimeout: () async {
          lockCount += 1;
        },
        child: Scaffold(
          body: Builder(
            builder: (context) {
              return TextField(
                onChanged: (_) => JournalActivityGuard.recordActivity(context),
              );
            },
          ),
        ),
      ),
    );

    await tester.pump(const Duration(seconds: 4));
    await tester.enterText(find.byType(TextField), 'mobile input');
    await tester.pump();

    await tester.pump(const Duration(seconds: 4));
    expect(lockCount, 0);

    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    expect(lockCount, 1);
  });

  testWidgets('resume locks immediately after a long background gap', (
    tester,
  ) async {
    int lockCount = 0;
    DateTime now = DateTime.utc(2026, 9, 2, 12);

    await tester.pumpWidget(
      _testApp(
        timeout: const Duration(minutes: 5),
        now: () => now,
        onTimeout: () async {
          lockCount += 1;
        },
      ),
    );

    now = now.add(const Duration(minutes: 6));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    expect(lockCount, 1);
  });

  testWidgets('resume preserves only the remaining inactivity time', (
    tester,
  ) async {
    int lockCount = 0;
    DateTime now = DateTime.utc(2026, 9, 2, 12);

    await tester.pumpWidget(
      _testApp(
        timeout: const Duration(minutes: 5),
        now: () => now,
        onTimeout: () async {
          lockCount += 1;
        },
      ),
    );

    now = now.add(const Duration(minutes: 2));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);

    await tester.pump(const Duration(minutes: 2, seconds: 59));
    expect(lockCount, 0);

    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    expect(lockCount, 1);
  });

  testWidgets('a backward wall-clock jump fails closed on resume', (
    tester,
  ) async {
    int lockCount = 0;
    DateTime now = DateTime.utc(2026, 9, 2, 12);

    await tester.pumpWidget(
      _testApp(
        timeout: const Duration(minutes: 5),
        now: () => now,
        onTimeout: () async {
          lockCount += 1;
        },
      ),
    );

    now = now.subtract(const Duration(minutes: 1));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    expect(lockCount, 1);
  });
}

Widget _testApp({
  required Duration timeout,
  required JournalLockCallback onTimeout,
  DateTime Function()? now,
  Widget? child,
}) {
  return MaterialApp(
    home: JournalActivityGuard(
      timeout: timeout,
      now: now,
      onTimeout: onTimeout,
      child:
          child ??
          Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () {},
                child: const Text('Interact'),
              ),
            ),
          ),
    ),
  );
}
