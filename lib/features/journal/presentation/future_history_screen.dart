import 'package:daymark/core/session/journal_future_history_session.dart';
import 'package:daymark/core/session/journal_session.dart';
import 'package:daymark/core/session/journal_session_controller.dart';
import 'package:daymark/features/journal/data/future_log_repository.dart';
import 'package:daymark/features/journal/domain/journal_domain.dart';
import 'package:daymark/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

abstract interface class FutureHistoryDataSource {
  Future<FutureLogSnapshot?> find(String periodStart);
}

final Provider<FutureHistoryDataSource> futureHistoryDataSourceProvider =
    Provider<FutureHistoryDataSource>((ref) {
      final JournalAccessState access = ref
          .watch(journalSessionControllerProvider)
          .requireValue;
      if (access case JournalUnlocked(:final session)) {
        return _SessionFutureHistoryDataSource(session);
      }
      throw StateError('Future history requires an unlocked journal session.');
    });

final class _SessionFutureHistoryDataSource implements FutureHistoryDataSource {
  const _SessionFutureHistoryDataSource(this._session);

  final JournalSession _session;

  @override
  Future<FutureLogSnapshot?> find(String periodStart) {
    return _session.findFutureLog(periodStart);
  }
}

class FutureHistoryScreen extends ConsumerStatefulWidget {
  const FutureHistoryScreen({required this.periodStart, super.key});

  final String periodStart;

  @override
  ConsumerState<FutureHistoryScreen> createState() =>
      _FutureHistoryScreenState();
}

class _FutureHistoryScreenState extends ConsumerState<FutureHistoryScreen> {
  late final DateTime _month;
  late final Future<FutureLogSnapshot?> _snapshotFuture;

  @override
  void initState() {
    super.initState();
    validateFuturePeriodStart(widget.periodStart);
    _month = DateTime.parse(widget.periodStart);
    _snapshotFuture = _dataSource().find(widget.periodStart);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final MaterialLocalizations material = MaterialLocalizations.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => context.go('/future'),
                  tooltip: material.backButtonTooltip,
                  icon: const Icon(Icons.arrow_back),
                ),
                Expanded(
                  child: Text(
                    material.formatMonthYear(_month),
                    textAlign: TextAlign.center,
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
            const SizedBox(height: 8),
            Text(
              l10n.futureHistoryReadOnly,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<FutureLogSnapshot?>(
                future: _snapshotFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text(l10n.futureLogLoadFailed));
                  }
                  final FutureLogSnapshot? future = snapshot.data;
                  if (future == null || future.entries.isEmpty) {
                    return Align(
                      alignment: AlignmentDirectional.topStart,
                      child: Text(l10n.emptyFutureMonth),
                    );
                  }
                  return _buildEntries(context, future.entries);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntries(BuildContext context, List<FutureLogEntry> entries) {
    return ListView.separated(
      itemCount: entries.length,
      separatorBuilder: (context, index) => const SizedBox(height: 6),
      itemBuilder: (context, index) {
        final FutureLogEntry entry = entries[index];
        final bool discarded = entry.taskState == JournalTaskState.discarded;
        final TextStyle? style = Theme.of(context).textTheme.bodyLarge;
        final TextStyle? markerStyle = Theme.of(context).textTheme.titleMedium;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 28,
                child: Text(
                  _futureHistoryEntrySymbol(entry),
                  textAlign: TextAlign.center,
                  style: discarded
                      ? markerStyle?.copyWith(
                          decoration: TextDecoration.lineThrough,
                        )
                      : markerStyle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  entry.content,
                  style: discarded
                      ? style?.copyWith(decoration: TextDecoration.lineThrough)
                      : style,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  FutureHistoryDataSource _dataSource() {
    return ref.read(futureHistoryDataSourceProvider);
  }

  Future<void> _lock() {
    return ref.read(journalSessionControllerProvider.notifier).lock();
  }
}

String _futureHistoryEntrySymbol(FutureLogEntry entry) => switch (entry.type) {
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
