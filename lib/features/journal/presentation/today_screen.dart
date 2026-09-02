import 'dart:async';

import 'package:daymark/core/session/journal_session.dart';
import 'package:daymark/core/session/journal_session_controller.dart';
import 'package:daymark/features/journal/data/daily_log_repository.dart';
import 'package:daymark/features/journal/domain/journal_domain.dart';
import 'package:daymark/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'journal_activity_guard.dart';

abstract interface class TodayJournalDataSource {
  Future<DailyLogSnapshot> load(String methodDate);

  Future<void> capture({
    required String logId,
    required JournalEntryType type,
    required String content,
  });

  Future<void> completeTask({required String entryId});

  Future<void> discardTask({required String entryId});
}

final Provider<TodayJournalDataSource> todayJournalDataSourceProvider =
    Provider<TodayJournalDataSource>((ref) {
      final JournalAccessState access = ref
          .watch(journalSessionControllerProvider)
          .requireValue;
      if (access case JournalUnlocked(:final session)) {
        return _SessionTodayJournalDataSource(session);
      }
      throw StateError('Today requires an unlocked journal session.');
    });

final class _SessionTodayJournalDataSource implements TodayJournalDataSource {
  const _SessionTodayJournalDataSource(this._session);

  final JournalSession _session;

  @override
  Future<DailyLogSnapshot> load(String methodDate) {
    return _session.loadDailyLog(methodDate);
  }

  @override
  Future<void> capture({
    required String logId,
    required JournalEntryType type,
    required String content,
  }) {
    return _session.captureDailyLogEntry(
      logId: logId,
      type: type,
      content: content,
    );
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

class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen>
    with WidgetsBindingObserver {
  final TextEditingController _entryController = TextEditingController();

  late DateTime _today;
  late Future<DailyLogSnapshot> _snapshotFuture;
  Timer? _dayRolloverTimer;
  JournalEntryType _entryType = JournalEntryType.task;
  bool _saving = false;
  String? _taskActionEntryId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _today = _dateOnly(DateTime.now());
    _snapshotFuture = _loadSnapshot();
    _scheduleDayRollover();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshDateIfNeeded();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _dayRolloverTimer?.cancel();
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
                    MaterialLocalizations.of(context).formatFullDate(_today),
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
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<DailyLogSnapshot>(
                future: _snapshotFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    return Center(child: Text(l10n.dailyLogLoadFailed));
                  }
                  return _buildEntries(context, l10n, snapshot.requireData);
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

  Widget _buildEntries(
    BuildContext context,
    AppLocalizations l10n,
    DailyLogSnapshot snapshot,
  ) {
    if (snapshot.entries.isEmpty) {
      return Align(
        alignment: AlignmentDirectional.topStart,
        child: Padding(
          padding: const EdgeInsets.only(top: 24),
          child: Text(
            l10n.emptyDailyLog,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: snapshot.entries.length,
      separatorBuilder: (context, index) => const SizedBox(height: 6),
      itemBuilder: (context, index) {
        final DailyLogEntry entry = snapshot.entries[index];
        final TextStyle? entryStyle = Theme.of(context).textTheme.bodyLarge;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 28,
                child: _buildEntryMarker(context, l10n, entry),
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

  Widget _buildEntryMarker(
    BuildContext context,
    AppLocalizations l10n,
    DailyLogEntry entry,
  ) {
    if (_taskActionEntryId == entry.id) {
      return const Center(
        child: SizedBox.square(
          dimension: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    final Text marker = Text(
      _entrySymbol(entry),
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.titleMedium,
    );

    if (entry.type != JournalEntryType.task ||
        entry.taskState != JournalTaskState.open) {
      return marker;
    }

    return PopupMenuButton<_TaskAction>(
      enabled: _taskActionEntryId == null,
      tooltip: l10n.taskActions,
      padding: EdgeInsets.zero,
      onSelected: (action) {
        unawaited(_applyTaskAction(entry, action));
      },
      itemBuilder: (context) => [
        PopupMenuItem<_TaskAction>(
          value: _TaskAction.complete,
          child: Text(l10n.completeTask),
        ),
        PopupMenuItem<_TaskAction>(
          value: _TaskAction.discard,
          child: Text(l10n.discardTask),
        ),
      ],
      child: marker,
    );
  }

  Widget _buildComposer(AppLocalizations l10n) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        DropdownButtonHideUnderline(
          child: DropdownButton<JournalEntryType>(
            value: _entryType,
            onChanged: _saving
                ? null
                : (value) {
                    if (value != null) {
                      setState(() => _entryType = value);
                    }
                  },
            items: [
              DropdownMenuItem(
                value: JournalEntryType.task,
                child: Text(l10n.entryTask),
              ),
              DropdownMenuItem(
                value: JournalEntryType.event,
                child: Text(l10n.entryEvent),
              ),
              DropdownMenuItem(
                value: JournalEntryType.note,
                child: Text(l10n.entryNote),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: _entryController,
            enabled: !_saving,
            minLines: 1,
            maxLines: 4,
            onChanged: (_) => JournalActivityGuard.recordActivity(context),
            decoration: InputDecoration(
              hintText: l10n.rapidLogHint,
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

  TodayJournalDataSource _dataSource() {
    return ref.read(todayJournalDataSourceProvider);
  }

  Future<DailyLogSnapshot> _loadSnapshot() {
    return _dataSource().load(formatJournalMethodDate(_today));
  }

  Future<void> _capture() async {
    final String content = _entryController.text.trim();
    if (content.isEmpty || _saving) {
      return;
    }

    final AppLocalizations l10n = AppLocalizations.of(context);
    setState(() => _saving = true);

    try {
      final TodayJournalDataSource dataSource = _dataSource();
      final DailyLogSnapshot snapshot = await _snapshotFuture;
      await dataSource.capture(
        logId: snapshot.logId,
        type: _entryType,
        content: content,
      );

      if (!mounted) {
        return;
      }

      _entryController.clear();
      setState(() {
        _snapshotFuture = dataSource.load(formatJournalMethodDate(_today));
        _saving = false;
      });
    } catch (error, stackTrace) {
      _reportUnexpectedJournalError('capture', error, stackTrace);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.saveEntryFailed)));
      setState(() => _saving = false);
    }
  }

  Future<void> _applyTaskAction(
    DailyLogEntry entry,
    _TaskAction action,
  ) async {
    if (_taskActionEntryId != null ||
        entry.type != JournalEntryType.task ||
        entry.taskState != JournalTaskState.open) {
      return;
    }

    final AppLocalizations l10n = AppLocalizations.of(context);
    setState(() => _taskActionEntryId = entry.id);

    try {
      final TodayJournalDataSource dataSource = _dataSource();
      switch (action) {
        case _TaskAction.complete:
          await dataSource.completeTask(entryId: entry.id);
        case _TaskAction.discard:
          await dataSource.discardTask(entryId: entry.id);
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _snapshotFuture = dataSource.load(formatJournalMethodDate(_today));
        _taskActionEntryId = null;
      });
    } catch (error, stackTrace) {
      _reportUnexpectedJournalError('task action', error, stackTrace);
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
      _reportUnexpectedJournalError('lock', error, stackTrace);
    }
  }

  void _refreshDateIfNeeded() {
    final DateTime currentDate = _dateOnly(DateTime.now());
    if (currentDate == _today) {
      _scheduleDayRollover();
      return;
    }

    if (mounted) {
      setState(() {
        _today = currentDate;
        _snapshotFuture = _loadSnapshot();
      });
    }
    _scheduleDayRollover();
  }

  void _scheduleDayRollover() {
    _dayRolloverTimer?.cancel();
    final DateTime now = DateTime.now();
    final DateTime tomorrow = DateTime(now.year, now.month, now.day + 1);
    _dayRolloverTimer = Timer(
      tomorrow.difference(now) + const Duration(seconds: 1),
      _refreshDateIfNeeded,
    );
  }
}

enum _TaskAction { complete, discard }

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

String _entrySymbol(DailyLogEntry entry) => switch (entry.type) {
  JournalEntryType.task => switch (entry.taskState) {
    JournalTaskState.completed => '×',
    JournalTaskState.migrated => '>',
    JournalTaskState.scheduled => '<',
    JournalTaskState.discarded => '—',
    JournalTaskState.open || null => '•',
  },
  JournalEntryType.event => '○',
  JournalEntryType.note => '–',
};

void _reportUnexpectedJournalError(
  String operation,
  Object error,
  StackTrace stackTrace,
) {
  FlutterError.reportError(
    FlutterErrorDetails(
      exception: FlutterError(
        'Journal $operation failed (${error.runtimeType}).',
      ),
      stack: stackTrace,
      library: 'daymark',
    ),
  );
}
