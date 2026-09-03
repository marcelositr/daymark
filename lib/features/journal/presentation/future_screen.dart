import 'dart:async';

import 'package:daymark/core/session/journal_session.dart';
import 'package:daymark/core/session/journal_session_controller.dart';
import 'package:daymark/features/journal/data/future_log_repository.dart';
import 'package:daymark/features/journal/domain/journal_domain.dart';
import 'package:daymark/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'journal_activity_guard.dart';

abstract interface class FutureJournalDataSource {
  Future<FutureLogSnapshot> load(String periodStart);

  Future<void> capture({
    required String logId,
    required JournalEntryType type,
    required String content,
  });

  Future<void> completeTask({required String entryId});

  Future<void> discardTask({required String entryId});
}

final Provider<FutureJournalDataSource> futureJournalDataSourceProvider =
    Provider<FutureJournalDataSource>((ref) {
      final JournalAccessState access = ref
          .watch(journalSessionControllerProvider)
          .requireValue;
      if (access case JournalUnlocked(:final session)) {
        return _SessionFutureJournalDataSource(session);
      }
      throw StateError('Future requires an unlocked journal session.');
    });

final class _SessionFutureJournalDataSource implements FutureJournalDataSource {
  const _SessionFutureJournalDataSource(this._session);

  final JournalSession _session;

  @override
  Future<FutureLogSnapshot> load(String periodStart) {
    return _session.loadFutureLog(periodStart);
  }

  @override
  Future<void> capture({
    required String logId,
    required JournalEntryType type,
    required String content,
  }) {
    return _session.captureFutureLogEntry(
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

class FutureScreen extends ConsumerStatefulWidget {
  const FutureScreen({this.initialDate, super.key});

  final DateTime? initialDate;

  @override
  ConsumerState<FutureScreen> createState() => _FutureScreenState();
}

class _FutureScreenState extends ConsumerState<FutureScreen>
    with WidgetsBindingObserver {
  static const int _visibleMonthCount = 6;

  final TextEditingController _entryController = TextEditingController();

  late DateTime _anchorMonth;
  late List<DateTime> _months;
  late DateTime _selectedMonth;
  late Future<List<FutureLogSnapshot>> _snapshotsFuture;
  Timer? _horizonRolloverTimer;
  JournalEntryType _entryType = JournalEntryType.task;
  bool _saving = false;
  String? _taskActionEntryId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final DateTime seed = widget.initialDate ?? DateTime.now();
    _anchorMonth = DateTime(seed.year, seed.month);
    _months = _futureMonths(_anchorMonth);
    _selectedMonth = _months.first;
    _snapshotsFuture = _loadSnapshots();
    _scheduleHorizonRollover();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && widget.initialDate == null) {
      _refreshHorizonIfNeeded();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _horizonRolloverTimer?.cancel();
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
                    l10n.future,
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
              child: FutureBuilder<List<FutureLogSnapshot>>(
                future: _snapshotsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    return Center(child: Text(l10n.futureLogLoadFailed));
                  }
                  return _buildOverview(context, l10n, snapshot.requireData);
                },
              ),
            ),
            const SizedBox(height: 12),
            _buildComposer(context, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildOverview(
    BuildContext context,
    AppLocalizations l10n,
    List<FutureLogSnapshot> snapshots,
  ) {
    return ListView.builder(
      itemCount: _months.length,
      itemBuilder: (context, index) {
        final DateTime month = _months[index];
        final String periodStart = formatFuturePeriodStart(month);
        final FutureLogSnapshot snapshot = snapshots.singleWhere(
          (item) => item.periodStart == periodStart,
        );

        return Padding(
          key: ValueKey<String>('future-$periodStart'),
          padding: EdgeInsets.only(
            bottom: index == _months.length - 1 ? 0 : 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                MaterialLocalizations.of(context).formatMonthYear(month),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              if (snapshot.entries.isEmpty)
                Text(
                  l10n.emptyFutureMonth,
                  style: Theme.of(context).textTheme.bodyMedium,
                )
              else
                for (final FutureLogEntry entry in snapshot.entries)
                  _buildEntry(context, l10n, entry),
              if (index != _months.length - 1) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildEntry(
    BuildContext context,
    AppLocalizations l10n,
    FutureLogEntry entry,
  ) {
    final TextStyle? entryStyle = Theme.of(context).textTheme.bodyLarge;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 28, child: _buildEntryMarker(context, l10n, entry)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              entry.content,
              style: entry.taskState == JournalTaskState.discarded
                  ? entryStyle?.copyWith(decoration: TextDecoration.lineThrough)
                  : entryStyle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryMarker(
    BuildContext context,
    AppLocalizations l10n,
    FutureLogEntry entry,
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
      _entrySymbol(entry),
      textAlign: TextAlign.center,
      style: entry.taskState == JournalTaskState.discarded
          ? markerStyle?.copyWith(decoration: TextDecoration.lineThrough)
          : markerStyle,
    );

    if (entry.type != JournalEntryType.task ||
        entry.taskState != JournalTaskState.open) {
      return marker;
    }

    return PopupMenuButton<_FutureTaskAction>(
      enabled: _taskActionEntryId == null,
      tooltip: l10n.taskActions,
      padding: EdgeInsets.zero,
      onSelected: (action) {
        unawaited(_applyTaskAction(entry, action));
      },
      itemBuilder: (context) => [
        PopupMenuItem<_FutureTaskAction>(
          value: _FutureTaskAction.complete,
          child: Text(l10n.completeTask),
        ),
        PopupMenuItem<_FutureTaskAction>(
          value: _FutureTaskAction.discard,
          child: Text(l10n.discardTask),
        ),
      ],
      child: marker,
    );
  }

  Widget _buildComposer(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<DateTime>(
                  key: const ValueKey<String>('future-month-target'),
                  value: _selectedMonth,
                  isExpanded: true,
                  onChanged: _saving
                      ? null
                      : (value) {
                          if (value != null) {
                            setState(() => _selectedMonth = value);
                          }
                        },
                  items: [
                    for (final DateTime month in _months)
                      DropdownMenuItem<DateTime>(
                        value: month,
                        child: Text(
                          MaterialLocalizations.of(context)
                              .formatMonthYear(month),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            DropdownButtonHideUnderline(
              child: DropdownButton<JournalEntryType>(
                key: const ValueKey<String>('future-entry-type'),
                value: _entryType,
                onChanged: _saving
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() => _entryType = value);
                        }
                      },
                items: [
                  DropdownMenuItem<JournalEntryType>(
                    value: JournalEntryType.task,
                    child: Text(l10n.entryTask),
                  ),
                  DropdownMenuItem<JournalEntryType>(
                    value: JournalEntryType.event,
                    child: Text(l10n.entryEvent),
                  ),
                  DropdownMenuItem<JournalEntryType>(
                    value: JournalEntryType.note,
                    child: Text(l10n.entryNote),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _entryController,
                enabled: !_saving,
                minLines: 1,
                maxLines: 4,
                onChanged: (_) => JournalActivityGuard.recordActivity(context),
                decoration: InputDecoration(
                  hintText: l10n.futureEntryHint,
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
        ),
      ],
    );
  }

  FutureJournalDataSource _dataSource() {
    return ref.read(futureJournalDataSourceProvider);
  }

  Future<List<FutureLogSnapshot>> _loadSnapshots() {
    final FutureJournalDataSource dataSource = _dataSource();
    return Future.wait([
      for (final DateTime month in _months)
        dataSource.load(formatFuturePeriodStart(month)),
    ]);
  }

  Future<void> _capture() async {
    final String content = _entryController.text.trim();
    if (content.isEmpty || _saving) {
      return;
    }

    final DateTime selectedMonth = _selectedMonth;
    final JournalEntryType entryType = _entryType;
    final AppLocalizations l10n = AppLocalizations.of(context);
    setState(() => _saving = true);

    try {
      final FutureJournalDataSource dataSource = _dataSource();
      final List<FutureLogSnapshot> snapshots = await _snapshotsFuture;
      final String periodStart = formatFuturePeriodStart(selectedMonth);
      final FutureLogSnapshot target = snapshots.singleWhere(
        (snapshot) => snapshot.periodStart == periodStart,
      );

      await dataSource.capture(
        logId: target.logId,
        type: entryType,
        content: content,
      );

      if (!mounted) {
        return;
      }

      _entryController.clear();
      setState(() {
        _snapshotsFuture = _loadSnapshots();
        _saving = false;
      });
    } catch (error, stackTrace) {
      _reportUnexpectedFutureError('capture', error, stackTrace);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.saveEntryFailed)));
      setState(() => _saving = false);
    }
  }

  Future<void> _applyTaskAction(
    FutureLogEntry entry,
    _FutureTaskAction action,
  ) async {
    if (_taskActionEntryId != null ||
        entry.type != JournalEntryType.task ||
        entry.taskState != JournalTaskState.open) {
      return;
    }

    final AppLocalizations l10n = AppLocalizations.of(context);
    setState(() => _taskActionEntryId = entry.id);

    try {
      final FutureJournalDataSource dataSource = _dataSource();
      switch (action) {
        case _FutureTaskAction.complete:
          await dataSource.completeTask(entryId: entry.id);
          break;
        case _FutureTaskAction.discard:
          await dataSource.discardTask(entryId: entry.id);
          break;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _snapshotsFuture = _loadSnapshots();
        _taskActionEntryId = null;
      });
    } catch (error, stackTrace) {
      _reportUnexpectedFutureError('task action', error, stackTrace);
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
      _reportUnexpectedFutureError('lock', error, stackTrace);
    }
  }

  void _refreshHorizonIfNeeded() {
    final DateTime now = DateTime.now();
    final DateTime currentMonth = DateTime(now.year, now.month);
    if (currentMonth == _anchorMonth) {
      _scheduleHorizonRollover();
      return;
    }

    final String selectedPeriod = formatFuturePeriodStart(_selectedMonth);
    final List<DateTime> months = _futureMonths(currentMonth);
    final int selectedIndex = months.indexWhere(
      (month) => formatFuturePeriodStart(month) == selectedPeriod,
    );

    setState(() {
      _anchorMonth = currentMonth;
      _months = months;
      _selectedMonth = selectedIndex >= 0
          ? months[selectedIndex]
          : months.first;
      _snapshotsFuture = _loadSnapshots();
    });
    _scheduleHorizonRollover();
  }

  void _scheduleHorizonRollover() {
    _horizonRolloverTimer?.cancel();
    if (widget.initialDate != null) {
      return;
    }

    final DateTime now = DateTime.now();
    final DateTime nextMonth = DateTime(now.year, now.month + 1);
    _horizonRolloverTimer = Timer(
      nextMonth.difference(now) + const Duration(seconds: 1),
      _refreshHorizonIfNeeded,
    );
  }

  List<DateTime> _futureMonths(DateTime anchorMonth) {
    return <DateTime>[
      for (int offset = 1; offset <= _visibleMonthCount; offset++)
        DateTime(anchorMonth.year, anchorMonth.month + offset),
    ];
  }
}

enum _FutureTaskAction { complete, discard }

String _entrySymbol(FutureLogEntry entry) => switch (entry.type) {
  JournalEntryType.task => switch (entry.taskState) {
    JournalTaskState.completed => '×',
    JournalTaskState.migrated => '>',
    JournalTaskState.scheduled => '<',
    JournalTaskState.discarded => '•',
    JournalTaskState.open => '•',
    null => '•',
  },
  JournalEntryType.event => '○',
  JournalEntryType.note => '–',
};

void _reportUnexpectedFutureError(
  String operation,
  Object error,
  StackTrace stackTrace,
) {
  FlutterError.reportError(
    FlutterErrorDetails(
      exception: FlutterError(
        'Future Log $operation failed (${error.runtimeType}).',
      ),
      stack: stackTrace,
      library: 'daymark',
    ),
  );
}
