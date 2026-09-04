import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum DaymarkNoticeKind { info, undo, error }

@immutable
final class DaymarkNotice {
  const DaymarkNotice({
    required this.id,
    required this.kind,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final int id;
  final DaymarkNoticeKind kind;
  final String message;
  final String? actionLabel;
  final FutureOr<void> Function()? onAction;
}

final NotifierProvider<DaymarkNoticeController, DaymarkNotice?>
daymarkNoticeProvider =
    NotifierProvider<DaymarkNoticeController, DaymarkNotice?>(
      DaymarkNoticeController.new,
    );

final class DaymarkNoticeController extends Notifier<DaymarkNotice?> {
  static const Duration infoDuration = Duration(seconds: 3);
  static const Duration undoDuration = Duration(seconds: 5);
  static const Duration errorDuration = Duration(seconds: 6);

  Timer? _timer;
  int _nextId = 0;

  @override
  DaymarkNotice? build() {
    ref.onDispose(() => _timer?.cancel());
    return null;
  }

  void showInfo(String message, {Duration duration = infoDuration}) {
    _show(kind: DaymarkNoticeKind.info, message: message, duration: duration);
  }

  void showError(String message, {Duration duration = errorDuration}) {
    _show(kind: DaymarkNoticeKind.error, message: message, duration: duration);
  }

  void showUndo({
    required String message,
    required String actionLabel,
    required FutureOr<void> Function() onUndo,
    Duration duration = undoDuration,
  }) {
    _show(
      kind: DaymarkNoticeKind.undo,
      message: message,
      actionLabel: actionLabel,
      onAction: onUndo,
      duration: duration,
    );
  }

  void dismiss() {
    _timer?.cancel();
    _timer = null;
    state = null;
  }

  Future<void> activateAction(int noticeId) async {
    final DaymarkNotice? current = state;
    if (current == null || current.id != noticeId || current.onAction == null) {
      return;
    }

    final FutureOr<void> Function() action = current.onAction!;
    dismiss();
    await Future<void>.sync(action);
  }

  void _show({
    required DaymarkNoticeKind kind,
    required String message,
    required Duration duration,
    String? actionLabel,
    FutureOr<void> Function()? onAction,
  }) {
    _timer?.cancel();

    final int id = ++_nextId;
    state = DaymarkNotice(
      id: id,
      kind: kind,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
    );

    _timer = Timer(duration, () {
      if (state?.id == id) {
        state = null;
      }
      _timer = null;
    });
  }
}

DaymarkNoticeController daymarkNoticeControllerOf(BuildContext context) {
  return ProviderScope.containerOf(
    context,
    listen: false,
  ).read(daymarkNoticeProvider.notifier);
}

final class DaymarkNoticeRegion extends ConsumerWidget {
  const DaymarkNoticeRegion({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DaymarkNotice? notice = ref.watch(daymarkNoticeProvider);

    if (notice == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Semantics(
        liveRegion: true,
        container: true,
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: SizedBox(
              width: double.infinity,
              child: _NoticeSurface(notice: notice),
            ),
          ),
        ),
      ),
    );
  }
}

final class _NoticeSurface extends ConsumerWidget {
  const _NoticeSurface({required this.notice});

  final DaymarkNotice notice;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool error = notice.kind == DaymarkNoticeKind.error;
    final Color background = error
        ? scheme.errorContainer
        : scheme.surfaceContainerHighest;
    final Color foreground = error
        ? scheme.onErrorContainer
        : scheme.onSurfaceVariant;

    return Material(
      key: const ValueKey<String>('daymark-notice'),
      color: background,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(12, 8, 8, 8),
        child: Row(
          children: [
            if (error) ...[
              Icon(Icons.error_outline, size: 18, color: foreground),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                notice.message,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: foreground),
              ),
            ),
            if (notice.actionLabel != null && notice.onAction != null) ...[
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => unawaited(
                  ref
                      .read(daymarkNoticeProvider.notifier)
                      .activateAction(notice.id),
                ),
                style: TextButton.styleFrom(foregroundColor: foreground),
                child: Text(notice.actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
