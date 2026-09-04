import 'package:daymark/core/session/journal_session.dart';
import 'package:daymark/core/session/journal_session_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class EntryCaptureUndoDataSource {
  Future<void> undoCapture({required String entryId});
}

final Provider<EntryCaptureUndoDataSource> entryCaptureUndoDataSourceProvider =
    Provider<EntryCaptureUndoDataSource>((ref) {
      final JournalAccessState access = ref
          .watch(journalSessionControllerProvider)
          .requireValue;
      if (access case JournalUnlocked(:final session)) {
        return _SessionEntryCaptureUndoDataSource(session);
      }
      throw StateError('Capture undo requires an unlocked journal session.');
    });

final class _SessionEntryCaptureUndoDataSource
    implements EntryCaptureUndoDataSource {
  const _SessionEntryCaptureUndoDataSource(this._session);

  final JournalSession _session;

  @override
  Future<void> undoCapture({required String entryId}) {
    return _session.undoCapture(entryId: entryId);
  }
}
