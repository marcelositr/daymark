import 'package:daymark/core/session/journal_session.dart';
import 'package:daymark/core/session/journal_session_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'journal_access_screen.dart';

/// Keeps the application root and router stable while journal access changes.
///
/// Protected route content is only inserted into the tree after an unlocked
/// session exists. All loading, locked, creation, storage-problem, and error
/// states remain inside the same MaterialApp/router lifetime.
final class JournalGate extends ConsumerWidget {
  const JournalGate({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<JournalAccessState> access = ref.watch(
      journalSessionControllerProvider,
    );

    return switch (access) {
      AsyncData(value: JournalUnlocked()) => child,
      _ => const JournalAccessScreen(),
    };
  }
}
