import 'package:daymark/features/journal/data/task_action_repository.dart';

/// Application boundary for deliberate Task-only actions.
///
/// Migration and scheduling remain in `JournalService` because those operations
/// create destination entries and lineage. This service owns Task eligibility
/// validation plus the simpler terminal transitions that keep one Task in its
/// current placement.
final class TaskActionService {
  const TaskActionService(this._repository);

  final TaskActionRepository _repository;

  Future<void> requireOpen({required String entryId}) {
    return _repository.requireOpenTask(entryId);
  }

  Future<void> complete({required String entryId}) {
    return _repository.complete(entryId);
  }

  Future<void> discard({required String entryId}) {
    return _repository.discard(entryId);
  }
}
