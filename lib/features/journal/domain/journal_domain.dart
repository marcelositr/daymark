enum JournalLogKind { daily, monthly, future }

enum JournalEntryType { task, event, note }

enum JournalTaskState { open, completed, migrated, scheduled, discarded }

enum JournalMonthlySection { calendar, tasks }

enum JournalMigrationKind { migrated, scheduled }

extension JournalLogKindCode on JournalLogKind {
  String get code => switch (this) {
    JournalLogKind.daily => 'daily',
    JournalLogKind.monthly => 'monthly',
    JournalLogKind.future => 'future',
  };
}

extension JournalEntryTypeCode on JournalEntryType {
  String get code => switch (this) {
    JournalEntryType.task => 'task',
    JournalEntryType.event => 'event',
    JournalEntryType.note => 'note',
  };
}

extension JournalTaskStateCode on JournalTaskState {
  String get code => switch (this) {
    JournalTaskState.open => 'open',
    JournalTaskState.completed => 'completed',
    JournalTaskState.migrated => 'migrated',
    JournalTaskState.scheduled => 'scheduled',
    JournalTaskState.discarded => 'discarded',
  };
}

extension JournalMonthlySectionCode on JournalMonthlySection {
  String get code => switch (this) {
    JournalMonthlySection.calendar => 'calendar',
    JournalMonthlySection.tasks => 'tasks',
  };
}

extension JournalMigrationKindCode on JournalMigrationKind {
  String get code => switch (this) {
    JournalMigrationKind.migrated => 'migrated',
    JournalMigrationKind.scheduled => 'scheduled',
  };

  JournalTaskState get sourceTaskState => switch (this) {
    JournalMigrationKind.migrated => JournalTaskState.migrated,
    JournalMigrationKind.scheduled => JournalTaskState.scheduled,
  };
}

sealed class JournalEntryOwner {
  const JournalEntryOwner();
}

final class JournalLogOwner extends JournalEntryOwner {
  const JournalLogOwner({
    required this.logId,
    this.monthlySection,
    this.monthlyCalendarDate,
  });

  final String logId;
  final JournalMonthlySection? monthlySection;
  final String? monthlyCalendarDate;
}

final class JournalCollectionOwner extends JournalEntryOwner {
  const JournalCollectionOwner(this.collectionId);

  final String collectionId;
}

final class JournalInvariantException implements Exception {
  const JournalInvariantException(this.message);

  final String message;

  @override
  String toString() => 'JournalInvariantException: $message';
}

final class JournalNotFoundException implements Exception {
  const JournalNotFoundException(this.entity, this.id);

  final String entity;
  final String id;

  @override
  String toString() => 'JournalNotFoundException: $entity $id was not found.';
}
