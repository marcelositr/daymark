import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

typedef SystemSessionLockCallback = Future<void> Function();
typedef SystemLockRegistrar = VoidCallback Function(VoidCallback onLock);

const MethodChannel _systemLockChannel = MethodChannel(
  'io.github.marcelositr.daymark/system_lock',
);

VoidCallback _registerPlatformSystemLock(VoidCallback onLock) {
  Future<Object?> handleMethodCall(MethodCall call) async {
    if (call.method == 'locked') {
      onLock();
    }
    return null;
  }

  _systemLockChannel.setMethodCallHandler(handleMethodCall);
  return () => _systemLockChannel.setMethodCallHandler(null);
}

/// Locks an unlocked journal when the host OS reports a real session/device lock.
///
/// Normal app backgrounding remains governed by the inactivity timeout. This
/// guard is intentionally narrower: native runners only emit `locked` for an
/// OS-level protected-state signal.
final class SystemSessionLockGuard extends StatefulWidget {
  const SystemSessionLockGuard({
    required this.child,
    required this.onSystemLock,
    this.registrar,
    super.key,
  });

  final Widget child;
  final SystemSessionLockCallback onSystemLock;

  /// Injectable only so the lock policy can be tested without a native runner.
  final SystemLockRegistrar? registrar;

  @override
  State<SystemSessionLockGuard> createState() => _SystemSessionLockGuardState();
}

final class _SystemSessionLockGuardState extends State<SystemSessionLockGuard> {
  late VoidCallback _unregister;
  bool _lockRunning = false;

  @override
  void initState() {
    super.initState();
    _register();
  }

  @override
  void didUpdateWidget(SystemSessionLockGuard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.registrar != widget.registrar) {
      _unregister();
      _register();
    }
  }

  @override
  void dispose() {
    _unregister();
    super.dispose();
  }

  void _register() {
    final SystemLockRegistrar register =
        widget.registrar ?? _registerPlatformSystemLock;
    _unregister = register(() {
      unawaited(_requestLock());
    });
  }

  Future<void> _requestLock() async {
    if (_lockRunning) {
      return;
    }

    _lockRunning = true;
    try {
      await widget.onSystemLock();
    } catch (error, stackTrace) {
      debugPrint(
        'Unexpected system-session journal lock failure '
        '(${error.runtimeType}).',
      );
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      if (mounted) {
        _lockRunning = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
