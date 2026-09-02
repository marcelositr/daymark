import 'dart:async';

import 'package:daymark/core/session/journal_session.dart';
import 'package:daymark/core/session/journal_session_controller.dart';
import 'package:daymark/features/journal/data/monthly_log_repository.dart';
import 'package:daymark/features/journal/domain/journal_domain.dart';
import 'package:daymark/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'journal_activity_guard.dart';

abstract interface class MonthlyJournalDataSource {
  Future<MonthlyLogSnapshot> load(String periodStart);

  Future<void> captureCalendarEvent({
    required String logId,
    required String calendarDate,
    required String content,
  });

  Future<void> captureTask({
    required String logId,
    required String content,
  });

  Future<void> completeTask({required String entryId});

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

final class _SessionMonthlyJournalDataSource implements MonthlyJournalDataSource {
  const _SessionMonthlyJournalDataSource(this._session);

  final JournalSession _session;

  @override
  Future<MonthlyLogSnapshot> load(String periodStart) {
    return _session.loadMonthlyLog(periodStart);
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
  Future<void> captureTask({
    required String logId,
    required String content,
  }) {
    return _session.captureMonthlyTask(logId: logId, content: content);
  }

  @override
  Future<void> completeTask({required String entryId}) {
    return _session.completeTask(entryId: entryId);
  }

  @override
  Future<void> discardTask({required String entryId}) {
    return _session.discardTask(entryId: entryId);
  }
}

class MonthlyScreen extends ConsumerStatefulWidget {
  const MonthlyScreen({this.initialMonth, super.key});

  final DateTime? initialMonth;

  @override
  ConsumerState<MonthlyScreen> createState() => _MonthlyScreenState();
}

class _MonthlyScreenState extends ConsumerState<MonthlyScreen>
    with WidgetsBindingObserver {
  final TextEditingController _entryController = TextEditingController();

  late DateTime _month;
  late Future<MonthlyLogSnapshot> _snapshotFuture;
  late int _selectedDay;
  JournalMonthlySection _section = JournalMonthlySection.calendar;
  bool _saving = false;
  String? _taskActionEntryId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final DateTime seed = widget.initialMonth ?? DateTime.now();
    _month = DateTime(seed.year, seed.month);
    _selectedDay = seed.day.clamp(1, _daysInMonth(_month));
    _snapshotFuture = _loadSnapshot();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && widget.initialMonth == null) {
      _refreshMonthIfNeeded();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    MaterialLocalizations.of(context).formatMonthYear(_month),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                IconButton(
                  onPressed: _lock,
                  tooltip: l10n.lockJournal,
                  icon: const Icon(Icons.lock_outline),
                ),
              ],
            ),
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
                onSelectionChanged: (selection) {
                  setState(() => _section = selection.single);
                },
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<MonthlyLogSnapshot>(
                future: _snapshotFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    return Center(child: Text(l10n.monthlyLogLoadFailed));
                  }
                  return switch (_section) {
                    JournalMonthlySection.calendar => _buildCalendar(
                      context,
                      snapshot.requireData,
                    ),
                    JournalMonthlySection.tasks => _buildTasks(
                      context,
                      l10n,
                      snapshot.requireData,
                    ),
                  };
                },
              ),
            ),
            const SizedBox(height: 12),
            _buildComposer(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar(BuildContext context, MonthlyLogSnapshot snapshot) {
    final MaterialLocalizations material = MaterialLocalizations.of(context);
    final int dayCount = _daysInMonth(_month);

    return ListView.builder(
      itemCount: dayCount,
      itemBuilder: (context, index) {
        final int dayNumber = index + 1;
        final DateTime date = DateTime(_month.year, _month.month, dayNumber);
        final String methodDate = _formatMethodDate(date);
        final List<MonthlyLogEntry> entries = <MonthlyLogEntry>[
          for (final MonthlyLogEntry entry in snapshot.calendarEntries)
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
                        child: Text(
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
    MonthlyLogSnapshot snapshot,
  ) {
    if (snapshot.taskEntries.isEmpty) {
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
      itemCount: snapshot.taskEntries.length,
      separatorBuilder: (context, index) => const SizedBox(height: 6),
      itemBuilder: (context, index) {
        final MonthlyLogEntry entry = snapshot.taskEntries[index];
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
    if (_taskActionEntryId == entry.id) {
      return const Center(
        child: SizedBox.square(
          dimension: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    final TextStyle? markerStyle = Theme.of(context).textTheme.titleMedium;
    final Text marker = Text(
      _taskSymbol(entry.taskState),
      textAlign: TextAlign.center,
      style: entry.taskState == JournalTaskState.discarded
          ? markerStyle?.copyWith(decoration: TextDecoration.lineThrough)
          : markerStyle,
    );

    if (entry.type != JournalEntryType.task ||
        entry.taskState != JournalTaskState.open) {
      return marker;
    }

    return PopupMenuButton<_MonthlyTaskAction>(
      enabled: _taskActionEntryId == null,
      tooltip: l10n.taskActions,
      padding: EdgeInsets.zero,
      onSelected: (action) {
        unawaited(_applyTaskAction(entry, action));
      },
      itemBuilder: (context) => [
        PopupMenuItem<_MonthlyTaskAction>(
          value: _MonthlyTaskAction.complete,
          child: Text(l10n.completeTask),
        ),
        PopupMenuItem<_MonthlyTaskAction>(
          value: _MonthlyTaskAction.discard,
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

  Future<MonthlyLogSnapshot> _loadSnapshot() {
    return _dataSource().load(formatJournalMonthStart(_month));
  }

  Future<void> _capture() async {
    final String content = _entryController.text.trim();
    if (content.isEmpty || _saving) {
      return;
    }

    final AppLocalizations l10n = AppLocalizations.of(context);
    setState(() => _saving = true);

    try {
      final MonthlyJournalDataSource dataSource = _dataSource();
      final MonthlyLogSnapshot snapshot = await _snapshotFuture;
      if (_section == JournalMonthlySection.calendar) {
        await dataSource.captureCalendarEvent(
          logId: snapshot.logId,
          calendarDate: _formatMethodDate(
            DateTime(_month.year, _month.month, _selectedDay),
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

  Future<void> _applyTaskAction(
    MonthlyLogEntry entry,
    _MonthlyTaskAction action,
  ) async {
    if (_taskActionEntryId != null ||
        entry.type != JournalEntryType.task ||
        entry.taskState != JournalTaskState.open) {
      return;
    }

    final AppLocalizations l10n = AppLocalizations.of(context);
    setState(() => _taskActionEntryId = entry.id);

    try {
      final MonthlyJournalDataSource dataSource = _dataSource();
      switch (action) {
        case _MonthlyTaskAction.complete:
          await dataSource.completeTask(entryId: entry.id);
          break;
        case _MonthlyTaskAction.discard:
          await dataSource.discardTask(entryId: entry.id);
          break;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _snapshotFuture = dataSource.load(formatJournalMonthStart(_month));
        _taskActionEntryId = null;
      });
    } catch (error, stackTrace) {
      _reportUnexpectedMonthlyError('task action', error, stackTrace);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.taskActionFailed)));
      setState(() => _taskActionEntryId = null);
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
    final DateTime now = DateTime.now();
    final DateTime currentMonth = DateTime(now.year, now.month);
    if (currentMonth == _month) {
      return;
    }

    setState(() {
      _month = currentMonth;
      _selectedDay = now.day.clamp(1, _daysInMonth(_month));
      _snapshotFuture = _loadSnapshot();
    });
  }
}

enum _MonthlyTaskAction { complete, discard }

int _daysInMonth(DateTime month) {
  return DateTime(month.year, month.month + 1, 0).day;
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
