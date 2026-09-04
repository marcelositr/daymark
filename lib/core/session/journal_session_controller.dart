import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'journal_files.dart';
import 'journal_session.dart';

final FutureProvider<JournalFiles> journalFilesProvider =
    FutureProvider<JournalFiles>((ref) => JournalFiles.forApplication());

final AsyncNotifierProvider<JournalSessionController, JournalAccessState>
journalSessionControllerProvider =
    AsyncNotifierProvider<JournalSessionController, JournalAccessState>(
      JournalSessionController.new,
    );

final class JournalSessionController extends AsyncNotifier<JournalAccessState> {
  JournalSessionManager? _manager;

  @override
  Future<JournalAccessState> build() async {
    final JournalFiles files = await ref.watch(journalFilesProvider.future);
    final JournalSessionManager manager = JournalSessionManager(files: files);
    _manager = manager;
    ref.onDispose(() {
      if (identical(_manager, manager)) {
        _manager = null;
      }
      unawaited(manager.dispose());
    });
    return manager.inspect();
  }

  Future<void> create({required String masterPassword}) async {
    final JournalSessionManager manager = _requireManager();
    state = const AsyncLoading<JournalAccessState>();

    try {
      final JournalSession session = await manager.create(
        masterPassword: masterPassword,
      );
      state = AsyncData<JournalAccessState>(JournalUnlocked(session));
    } catch (error, stackTrace) {
      await _restoreStateAfterFailure(manager, error, stackTrace);
    }
  }

  Future<void> unlock({required String masterPassword}) async {
    final JournalSessionManager manager = _requireManager();
    state = const AsyncLoading<JournalAccessState>();

    try {
      final JournalSession session = await manager.unlock(
        masterPassword: masterPassword,
      );
      state = AsyncData<JournalAccessState>(JournalUnlocked(session));
    } catch (error, stackTrace) {
      await _restoreStateAfterFailure(manager, error, stackTrace);
    }
  }

  Future<void> createBackup({
    required File backupFile,
    required String masterPassword,
  }) {
    return _requireManager().createBackup(
      backupFile: backupFile,
      masterPassword: masterPassword,
    );
  }

  Future<void> restoreBackup({
    required File backupFile,
    required String masterPassword,
  }) async {
    final JournalSessionManager manager = _requireManager();
    state = const AsyncLoading<JournalAccessState>();

    try {
      final JournalSession session = await manager.restoreBackup(
        backupFile: backupFile,
        masterPassword: masterPassword,
      );
      state = AsyncData<JournalAccessState>(JournalUnlocked(session));
    } catch (error, stackTrace) {
      await _restoreStateAfterFailure(manager, error, stackTrace);
    }
  }

  Future<void> lock() async {
    final JournalSessionManager manager = _requireManager();
    state = const AsyncLoading<JournalAccessState>();

    try {
      await manager.lock();
      state = AsyncData<JournalAccessState>(await manager.inspect());
    } catch (error, stackTrace) {
      await _restoreStateAfterFailure(manager, error, stackTrace);
    }
  }

  JournalSessionManager _requireManager() {
    final JournalSessionManager? manager = _manager;
    if (manager == null) {
      throw StateError('Journal session controller is not initialized yet.');
    }
    return manager;
  }

  Future<Never> _restoreStateAfterFailure(
    JournalSessionManager manager,
    Object error,
    StackTrace stackTrace,
  ) async {
    try {
      state = AsyncData<JournalAccessState>(await manager.inspect());
    } catch (inspectionError, inspectionStackTrace) {
      state = AsyncError<JournalAccessState>(
        inspectionError,
        inspectionStackTrace,
      );
    }
    Error.throwWithStackTrace(error, stackTrace);
  }
}
