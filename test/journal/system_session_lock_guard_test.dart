import 'dart:async';

import 'package:daymark/features/journal/presentation/system_session_lock_guard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('a platform lock signal requests journal lock', (tester) async {
    VoidCallback? signal;
    int lockCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: SystemSessionLockGuard(
          registrar: (onLock) {
            signal = onLock;
            return () => signal = null;
          },
          onSystemLock: () async {
            lockCount += 1;
          },
          child: const Scaffold(body: Text('Unlocked journal')),
        ),
      ),
    );

    signal!();
    await tester.pump();

    expect(lockCount, 1);
  });

  testWidgets('duplicate signals do not overlap an in-flight lock', (
    tester,
  ) async {
    VoidCallback? signal;
    final Completer<void> allowLockToFinish = Completer<void>();
    int lockCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: SystemSessionLockGuard(
          registrar: (onLock) {
            signal = onLock;
            return () => signal = null;
          },
          onSystemLock: () async {
            lockCount += 1;
            await allowLockToFinish.future;
          },
          child: const Scaffold(body: Text('Unlocked journal')),
        ),
      ),
    );

    signal!();
    signal!();
    await tester.pump();

    expect(lockCount, 1);

    allowLockToFinish.complete();
    await tester.pump();
  });

  testWidgets('disposing the guard unregisters the platform signal', (
    tester,
  ) async {
    VoidCallback? signal;

    await tester.pumpWidget(
      MaterialApp(
        home: SystemSessionLockGuard(
          registrar: (onLock) {
            signal = onLock;
            return () => signal = null;
          },
          onSystemLock: () async {},
          child: const Scaffold(body: Text('Unlocked journal')),
        ),
      ),
    );

    expect(signal, isNotNull);

    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));

    expect(signal, isNull);
  });
}
