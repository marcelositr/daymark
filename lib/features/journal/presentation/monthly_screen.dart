import 'dart:async';

import 'package:daymark/core/session/journal_monthly_history_session.dart';
import 'package:daymark/core/session/journal_session.dart';
import 'package:daymark/core/session/journal_session_controller.dart';
import 'package:daymark/features/journal/data/monthly_log_repository.dart';
import 'package:daymark/features/journal/domain/journal_domain.dart';
import 'package:daymark/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'entry_collection_reference_dialog.dart';
import 'journal_activity_guard.dart';
import 'task_collection_migration_dialog.dart';
import 'task_schedule_dialog.dart';

abstract interface class MonthlyJournalDataSource {
  Future<MonthlyLogSnapshot> load(String periodStart);

  Future<MonthlyLogSnapshot?> find(String periodStart);

  Future<void> captureCalendarEvent({
    required String logId,
    required String calendarDate,
    required String content,
  });

  Future<void> captureTask({required String logId, required String content});

  Future<void> completeTask({required String entryId});

  Future<void> scheduleTaskToFuture({
    required String entryId,
    required String periodStart,
  });

  Future<void> discardTask({required String entryId});
}

final Provider<MonthlyJournalDataSource> monthlyJournalDataSourceProvider =
    Provider<MonthlyJournalDataSource>((ref) {
      final JournalAccessState access = ref
          .watch(journalSessionControllerProvider)
          .requireValue;
      if (access case JournalUnlocked(:final session)) {
        return _SessionMonthlyJournalDataSource(session);
      }
      throw StateError('Monthly requires an unlocked journal session.');
    });

final class _SessionMonthlyJournalDataSource
    implements MonthlyJournalDataSource {
  const _SessionMonthlyJournalDataSource(this._session);

  final JournalSession _session;

  @override
  Future<MonthlyLogSnapshot> load(String periodStart) {
    return _session.loadMonthlyLog(periodStart);
  }

  @override
  Future<MonthlyLogSnapshot?> find(String periodStart) {
    return _session.findMonthlyLog(periodStart);
  }

  @override
  Future<void> captureCalendarEvent({
    required String logId,
    required String calendarDate,
    required String content,
  }) {
    return _session.captureMonthlyCalendarEvent(
      logId: logId,
      calendarDate: calendarDate,
      content: content,
    );
  }

  @override
  Future<void> captureTask({required String logId, required String content}) {
    return _session.captureMonthlyTask(logId: logId, content: content);
  }

  @override
  Future<void> completeTask({required String entryId}) {
    return _session.completeTask(entryId: entryId);
  }

  @override
  Future<void> scheduleTaskToFuture({
    required String entryId,
    required String periodStart,
  }) {
    return _session.scheduleTaskToFuture(
      entryId: entryId,
      periodStart: periodStart,
    );
  }

  @override
  Future<void> discardTask({required String entryId}) {
    return _session.discardTask(entryId: entryId);
  }
}

class MonthlyScreen extends ConsumerStatefulWidget {
  const MonthlyScreen({this.initialMonth, this.now, super.key});

  final DateTime? initialMonth;
  final DateTime Function()? now;

  @override
  ConsumerState<MonthlyScreen> createState() => _MonthlyScreenState();
}

class _MonthlyScreenState extends ConsumerState<MonthlyScreen>
    with WidgetsBindingObserver {
  final TextEditingController _entryController = TextEditingController();

  late DateTime _month;
  late Future<MonthlyLogSnapshot?> _snapshotFuture;
  late int _selectedDay;
  late bool _followingCurrentMonth;
  Timer? _monthRolloverTimer;
  JournalMonthlySection _section = JournalMonthlySection.calendar;
  bool _saving = false;
  String? _entryActionId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final DateTime now = _now();
    final DateTime currentMonth = DateTime(now.year, now.month);
    final DateTime seed = widget.initialMonth ?? now;
    final DateTime requestedMonth = DateTime(seed.year, seed.month);
    _month = _isAfterMonth(requestedMonth, currentMonth)
        ? currentMonth
        : requestedMonth;
    _followingCurrentMonth = _sameMonth(_month, currentMonth);
    _selectedDay = _followingCurrentMonth ? _clampDay(now.day, _month) : 1;
    _snapshotFuture = _loadSnapshotFor(
      _month,
      writable: _followingCurrentMonth,
    );
    _scheduleMonthRollover();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        widget.initialMonth == null &&
        _followingCurrentMonth) {
      _refreshMonthIfNeeded();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _monthRolloverTimer?.cancel();
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool busy = _saving || _entryActionId != null;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: busy ? null : () => _selectMonth(-1),
                  tooltip: l10n.previousMonth,
                  icon: const Icon(Icons.chevron_left),
                ),
                Expanded(
                  child: Text(
                    MaterialLocalizations.of(context).formatMonthYear(_month),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                IconButton(
                  onPressed: busy || _followingCurrentMonth
                      ? null
                      : () => _selectMonth(1),
                  tooltip: l10n.nextMonth,
                  icon: const Icon(Icons.chevron_right),
                ),
                IconButton(
                  onPressed: _lock,
                  tooltip: l10n.lockJournal,
                  icon: const Icon(Icons.lock_outline),
                ),
              ],
            ),
            if (!_followingCurrentMonth) ...[
              const SizedBox(height: 4),
              Text(
                l10n.monthlyHistoryReadOnly,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 12),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: SegmentedButton<JournalMonthlySection>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment<JournalMonthlySection>(
                    value: JournalMonthlySection.calendar,
                    label: Text(l10n.monthlyCalendar),
                  ),
                  ButtonSegment<JournalMonthlySection>(
                    value: JournalMonthlySection.tasks,
                    label: Text(l10n.monthlyTasks),
                  ),
                ],
                selected: <JournalMonthlySection>{_section},
                onSelectionChanged: _saving
                    ? null
                    : (selection) {
                        _entryController.clear();
                        setState(() => _section = selection.single);
                      },
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<MonthlyLogSnapshot?>(
                future: _snapshotFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text(l10n.monthlyLogLoadFailed));
                  }
                  return switch (_section) {
                    JournalMonthlySection.calendar => _buildCalendar(
                      context,
                      l10n,
                      snapshot.data,
                    ),
                    JournalMonthlySection.tasks => _buildTasks(
                      context,
                      l10n,
                      snapshot.data,
                    ),
                  };
                },
              ),
            ),
            if (_followingCurrentMonth) ...[
              const SizedBox(height: 12),
              _buildComposer(l10n),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar(
    BuildContext context,
    AppLocalizations l10n,
    MonthlyLogSnapshot? snapshot,
  ) {
    final MaterialLocalizations material = MaterialLocalizations.of(context);
    final int dayCount = _daysInMonth(_month);
    final List<MonthlyLogEntry> calendarEntries =
        snapshot?.calendarEntries ?? const <MonthlyLogEntry>[];

    return ListView.builder(
      itemCount: dayCount,
      itemBuilder: (context, index) {
        final int dayNumber = index + 1;
        final DateTime date = DateTime(_month.year, _month.month, dayNumber);
        final String methodDate = _formatMethodDate(date);
        final List<MonthlyLogEntry> entries = <MonthlyLogEntry>[
          for (final MonthlyLogEntry entry in calendarEntries)
            if (entry.calendarDate == methodDate) entry,
        ];
        final String weekday = material.narrowWeekdays[date.weekday % 7];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 52,
                child: Text(
                  '$dayNumber $weekday',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final MonthlyLogEntry entry in entries)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: _followingCurrentMonth
                            ? PopupMenuButton<_MonthlyEntryAction>(
                                enabled: _entryActionId == null,
                                tooltip: l10n.entryActions,
                                padding: EdgeInsets.zero,
                                onSelected: (action) {
                                  unawaited(_applyEntryAction(entry, action));
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem<_MonthlyEntryAction>(
                                    value: _MonthlyEntryAction.reference,
                                    child: Text(l10n.referenceEntry),
                                  ),
                                ],
                                child: Text(
                                  '○ ${entry.content}',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              )
                            : Text(
                                '○ ${entry.content}',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTasks(
    BuildContext context,
    AppLocalizations l10n,
    MonthlyLogSnapshot? snapshot,
  ) {
    final List<MonthlyLogEntry> taskEntries =
        snapshot?.taskEntries ?? const <MonthlyLogEntry>[];
    if (taskEntries.isEmpty) {
      return Align(
        alignment: AlignmentDirectional.topStart,
        child: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Text(
            l10n.emptyMonthlyTasks,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: taskEntries.length,
      separatorBuilder: (context, index) => const SizedBox(height: 6),
      itemBuilder: (context, index) {
        final MonthlyLogEntry entry = taskEntries[index];
        final TextStyle? entryStyle = Theme.of(context).textTheme.bodyLarge;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 28,
                child: _buildTaskMarker(context, l10n, entry),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  entry.content,
                  style: entry.taskState == JournalTaskState.discarded
                      ? entryStyle?.copyWith(
                          decoration: TextDecoration.lineThrough,
                        )
                      : entryStyle,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTaskMarker(
    BuildContext context,
    AppLocalizations l10n,
    MonthlyLogEntry entry,
  ) {
    final TextStyle? markerStyle = Theme.of(context).textTheme.titleMedium;
    final Text marker = Text(
      _taskSymbol(entry.taskState),
      textAlign: TextAlign.center,
      style: entry.taskState == JournalTaskState.discarded
          ? markerStyle?.copyWith(decoration: TextDecoration.lineThrough)
          : markerStyle,
    );

    if (!_followingCurrentMonth) {
      return marker;
    }
    if (_entryActionId == entry.id) {
      return const Center(
        child: SizedBox.square(
          dimension: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    final bool openTask =
        entry.type == JournalEntryType.task &&
        entry.taskState == JournalTaskState.open;

    return PopupMenuButton<_MonthlyEntryAction>(
      enabled: _entryActionId == null,
      tooltip: l10n.entryActions,
      padding: EdgeInsets.zero,
      onSelected: (action) {
        unawaited(_applyEntryAction(entry, action));
      },
      itemBuilder: (context) => [
        if (openTask)
          PopupMenuItem<_MonthlyEntryAction>(
            value: _MonthlyEntryAction.complete,
            child: Text(l10n.completeTask),
          ),
        if (openTask)
          PopupMenuItem<_MonthlyEntryAction>(
            value: _MonthlyEntryAction.migrate,
            child: Text(l10n.migrateTask),
          ),
        if (openTask)
          PopupMenuItem<_MonthlyEntryAction>(
            value: _MonthlyEntryAction.schedule,
            child: Text(l10n.scheduleTask),
          ),
        PopupMenuItem<_MonthlyEntryAction>(
          value: _MonthlyEntryAction.reference,
          child: Text(l10n.referenceEntry),
        ),
        if (openTask)
          PopupMenuItem<_MonthlyEntryAction>(
            value: _MonthlyEntryAction.discard,
            child: Text(l10n.discardTask),
          ),
      ],
      child: marker,
    );
  }

  Widget _buildComposer(AppLocalizations l10n) {
    final bool calendar = _section == JournalMonthlySection.calendar;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (calendar) ...[
          DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _selectedDay,
              onChanged: _saving
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() => _selectedDay = value);
                      }
                    },
              items: [
                for (int day = 1; day <= _daysInMonth(_month); day++)
                  DropdownMenuItem<int>(value: day, child: Text('$day')),
              ],
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: TextField(
            controller: _entryController,
            enabled: !_saving,
            minLines: 1,
            maxLines: 4,
            onChanged: (_) => JournalActivityGuard.recordActivity(context),
            decoration: InputDecoration(
              hintText: calendar ? l10n.monthlyEventHint : l10n.monthlyTaskHint,
              isDense: true,
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: _saving ? null : _capture,
          tooltip: l10n.addEntry,
          icon: _saving
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.arrow_upward),
        ),
      ],
    );
  }

  MonthlyJournalDataSource _dataSource() {
    return ref.read(monthlyJournalDataSourceProvider);
  }

  Future<MonthlyLogSnapshot?> _loadSnapshotFor(
    DateTime month, {
    required bool writable,
  }) {
    final String periodStart = formatJournalMonthStart(month);
    final MonthlyJournalDataSource dataSource = _dataSource();
    return writable
        ? dataSource.load(periodStart)
        : dataSource.find(periodStart);
  }

  Future<void> _selectMonth(int offset) async {
    if (_saving || _entryActionId != null) {
      return;
    }
    final DateTime target = DateTime(_month.year, _month.month + offset);
    final DateTime currentMonth = _currentMonth();
    if (_isAfterMonth(target, currentMonth)) {
      return;
    }
    final bool followingCurrentMonth = _sameMonth(target, currentMonth);
    final DateTime now = _now();

    _monthRolloverTimer?.cancel();
    _entryController.clear();
    setState(() {
      _month = target;
      _followingCurrentMonth = followingCurrentMonth;
      _selectedDay = followingCurrentMonth ? _clampDay(now.day, target) : 1;
      _snapshotFuture = _loadSnapshotFor(
        target,
        writable: followingCurrentMonth,
      );
    });
    _scheduleMonthRollover();
  }

  Future<void> _capture() async {
    final String content = _entryController.text.trim();
    if (content.isEmpty || _saving || !_followingCurrentMonth) {
      return;
    }

    final JournalMonthlySection section = _section;
    final DateTime month = _month;
    final int selectedDay = _selectedDay;
    final AppLocalizations l10n = AppLocalizations.of(context);
    setState(() => _saving = true);

    try {
      final MonthlyJournalDataSource dataSource = _dataSource();
      final MonthlyLogSnapshot? snapshot = await _snapshotFuture;
      if (snapshot == null) {
        throw StateError('Current Monthly Log is missing.');
      }
      if (section == JournalMonthlySection.calendar) {
        await dataSource.captureCalendarEvent(
          logId: snapshot.logId,
          calendarDate: _formatMethodDate(
            DateTime(month.year, month.month, selectedDay),
          ),
          content: content,
        );
      } else {
        await dataSource.captureTask(logId: snapshot.logId, content: content);
      }

      if (!mounted) {
        return;
      }

      _entryController.clear();
      setState(() {
        _snapshotFuture = dataSource.load(formatJournalMonthStart(_month));
        _saving = false;
      });
    } catch (error, stackTrace) {
      _reportUnexpectedMonthlyError('capture', error, stackTrace);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.saveEntryFailed)));
      setState(() => _saving = false);
    }
  }

  Future<void> _applyEntryAction(
    MonthlyLogEntry entry,
    _MonthlyEntryAction action,
  ) async {
    if (_entryActionId != null || !_followingCurrentMonth) {
      return;
    }
    final bool openTask =
        entry.type == JournalEntryType.task &&
        entry.taskState == JournalTaskState.open;
    if (action != _MonthlyEntryAction.reference && !openTask) {
      return;
    }

    final DateTime actionMonth = _month;
    String? migrationCollectionId;
    if (action == _MonthlyEntryAction.migrate) {
      migrationCollectionId = await showTaskCollectionMigrationDialog(
        context: context,
        dataSource: ref.read(taskCollectionMigrationDataSourceProvider),
      );
      if (!mounted || migrationCollectionId == null) {
        return;
      }
    }

    String? referenceCollectionId;
    if (action == _MonthlyEntryAction.reference) {
      referenceCollectionId = await showEntryCollectionReferenceDialog(
        context: context,
        dataSource: ref.read(entryCollectionReferenceDataSourceProvider),
      );
      if (!mounted || referenceCollectionId == null) {
        return;
      }
    }

    String? schedulePeriodStart;
    if (action == _MonthlyEntryAction.schedule) {
      schedulePeriodStart = await showTaskScheduleDialog(
        context: context,
        anchor: actionMonth,
      );
      if (!mounted || schedulePeriodStart == null) {
        return;
      }
    }

    final AppLocalizations l10n = AppLocalizations.of(context);
    setState(() => _entryActionId = entry.id);

    try {
      final MonthlyJournalDataSource dataSource = _dataSource();
      switch (action) {
        case _MonthlyEntryAction.complete:
          await dataSource.completeTask(entryId: entry.id);
          break;
        case _MonthlyEntryAction.migrate:
          await ref
              .read(taskCollectionMigrationDataSourceProvider)
              .migrateTask(
                entryId: entry.id,
                collectionId: migrationCollectionId!,
              );
          break;
        case _MonthlyEntryAction.schedule:
          await dataSource.scheduleTaskToFuture(
            entryId: entry.id,
            periodStart: schedulePeriodStart!,
          );
          break;
        case _MonthlyEntryAction.reference:
          await ref
              .read(entryCollectionReferenceDataSourceProvider)
              .referenceEntry(
                entryId: entry.id,
                collectionId: referenceCollectionId!,
              );
          break;
        case _MonthlyEntryAction.discard:
          await dataSource.discardTask(entryId: entry.id);
          break;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _snapshotFuture = dataSource.load(formatJournalMonthStart(_month));
        _entryActionId = null;
      });
    } catch (error, stackTrace) {
      _reportUnexpectedMonthlyError(
        action == _MonthlyEntryAction.reference
            ? 'collection reference'
            : 'task action',
        error,
        stackTrace,
      );
      if (!mounted) {
        return;
      }
      final String message = action == _MonthlyEntryAction.reference
          ? l10n.referenceEntryFailed
          : l10n.taskActionFailed;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
      setState(() => _entryActionId = null);
    }
  }

  Future<void> _lock() async {
    try {
      await ref.read(journalSessionControllerProvider.notifier).lock();
    } catch (error, stackTrace) {
      _reportUnexpectedMonthlyError('lock', error, stackTrace);
    }
  }

  void _refreshMonthIfNeeded() {
    if (!_followingCurrentMonth) {
      return;
    }
    final DateTime now = _now();
    final DateTime currentMonth = DateTime(now.year, now.month);
    if (_sameMonth(currentMonth, _month)) {
      _scheduleMonthRollover();
      return;
    }

    setState(() {
      _month = currentMonth;
      _selectedDay = _clampDay(now.day, _month);
      _snapshotFuture = _loadSnapshotFor(_month, writable: true);
    });
    _scheduleMonthRollover();
  }

  void _scheduleMonthRollover() {
    _monthRolloverTimer?.cancel();
    if (widget.initialMonth != null || !_followingCurrentMonth) {
      return;
    }

    final DateTime now = _now();
    final DateTime nextMonth = DateTime(now.year, now.month + 1);
    _monthRolloverTimer = Timer(
      nextMonth.difference(now) + const Duration(seconds: 1),
      _refreshMonthIfNeeded,
    );
  }

  DateTime _now() => widget.now?.call() ?? DateTime.now();

  DateTime _currentMonth() {
    final DateTime now = _now();
    return DateTime(now.year, now.month);
  }
}

enum _MonthlyEntryAction { complete, migrate, schedule, reference, discard }

int _daysInMonth(DateTime month) {
  return DateTime(month.year, month.month + 1, 0).day;
}

int _clampDay(int day, DateTime month) {
  final int lastDay = _daysInMonth(month);
  if (day < 1) {
    return 1;
  }
  if (day > lastDay) {
    return lastDay;
  }
  return day;
}

bool _sameMonth(DateTime left, DateTime right) {
  return left.year == right.year && left.month == right.month;
}

bool _isAfterMonth(DateTime left, DateTime right) {
  return left.year > right.year ||
      (left.year == right.year && left.month > right.month);
}

String _formatMethodDate(DateTime date) {
  return '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

String _taskSymbol(JournalTaskState? state) => switch (state) {
  JournalTaskState.completed => '×',
  JournalTaskState.migrated => '>',
  JournalTaskState.scheduled => '<',
  JournalTaskState.discarded => '•',
  JournalTaskState.open => '•',
  null => '•',
};

void _reportUnexpectedMonthlyError(
  String operation,
  Object error,
  StackTrace stackTrace,
) {
  FlutterError.reportError(
    FlutterErrorDetails(
      exception: FlutterError(
        'Monthly journal $operation failed (${error.runtimeType}).',
      ),
      stack: stackTrace,
      library: 'daymark',
    ),
  );
}
