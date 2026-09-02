import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

typedef JournalLockCallback = Future<void> Function();

/// Enforces the documented inactivity lock policy around unlocked journal UI.
///
/// Pointer and keyboard interaction restart the deadline. Background time does
/// not reset it, and returning to the foreground re-evaluates elapsed wall
/// time so a suspended platform timer cannot keep an inactive journal open.
final class JournalActivityGuard extends StatefulWidget {
  JournalActivityGuard({
    required this.child,
    required this.onTimeout,
    this.timeout = const Duration(minutes: 5),
    DateTime Function()? now,
    super.key,
  }) : assert(timeout > Duration.zero),
       _now = now ?? DateTime.now;

  final Widget child;
  final JournalLockCallback onTimeout;
  final Duration timeout;
  final DateTime Function() _now;

  @override
  State<JournalActivityGuard> createState() => _JournalActivityGuardState();
}

final class _JournalActivityGuardState extends State<JournalActivityGuard>
    with WidgetsBindingObserver {
  Timer? _timer;
  late DateTime _lastActivityAt;
  int _generation = 0;
  bool _timeoutRunning = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _lastActivityAt = widget._now();
    _armTimer(widget.timeout);
  }

  @override
  void didUpdateWidget(covariant JournalActivityGuard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.timeout != widget.timeout || oldWidget._now != widget._now) {
      _recordActivity();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _evaluateDeadline();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _recordActivity() {
    if (_timeoutRunning) {
      return;
    }

    _lastActivityAt = widget._now();
    _generation += 1;
    _armTimer(widget.timeout);
  }

  void _evaluateDeadline() {
    if (_timeoutRunning) {
      return;
    }

    final DateTime now = widget._now();
    final Duration elapsed = now.isBefore(_lastActivityAt)
        ? widget.timeout
        : now.difference(_lastActivityAt);

    if (elapsed >= widget.timeout) {
      unawaited(_requestTimeout(_generation));
      return;
    }

    _armTimer(widget.timeout - elapsed);
  }

  void _armTimer(Duration delay) {
    _timer?.cancel();
    final int generation = _generation;
    _timer = Timer(delay, () {
      unawaited(_requestTimeout(generation));
    });
  }

  Future<void> _requestTimeout(int generation) async {
    if (!mounted || _timeoutRunning || generation != _generation) {
      return;
    }

    _timeoutRunning = true;
    _timer?.cancel();

    try {
      await widget.onTimeout();
    } catch (error, stackTrace) {
      debugPrint(
        'Unexpected automatic journal lock failure (${error.runtimeType}).',
      );
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) {
        return;
      }

      _timeoutRunning = false;
      _lastActivityAt = widget._now();
      _generation += 1;
      _armTimer(widget.timeout);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _recordActivity(),
      onPointerSignal: (_) => _recordActivity(),
      child: Focus(
        canRequestFocus: false,
        skipTraversal: true,
        onKeyEvent: (_, _) {
          _recordActivity();
          return KeyEventResult.ignored;
        },
        child: widget.child,
      ),
    );
  }
}
