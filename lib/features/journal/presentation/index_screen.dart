import 'package:daymark/core/session/journal_index_session.dart';
import 'package:daymark/core/session/journal_session.dart';
import 'package:daymark/core/session/journal_session_controller.dart';
import 'package:daymark/features/journal/data/index_repository.dart';
import 'package:daymark/features/journal/domain/journal_domain.dart';
import 'package:daymark/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class IndexJournalDataSource {
  Future<List<IndexItem>> list();

  Future<List<IndexCandidate>> candidates();

  Future<void> add(IndexCandidate candidate);
}

final Provider<IndexJournalDataSource> indexJournalDataSourceProvider =
    Provider<IndexJournalDataSource>((ref) {
      final JournalAccessState access = ref
          .watch(journalSessionControllerProvider)
          .requireValue;
      if (access case JournalUnlocked(:final session)) {
        return _SessionIndexJournalDataSource(session);
      }
      throw StateError('Index requires an unlocked journal session.');
    });

final class _SessionIndexJournalDataSource implements IndexJournalDataSource {
  const _SessionIndexJournalDataSource(this._session);

  final JournalSession _session;

  @override
  Future<List<IndexItem>> list() => _session.listIndexItems();

  @override
  Future<List<IndexCandidate>> candidates() {
    return _session.listIndexCandidates();
  }

  @override
  Future<void> add(IndexCandidate candidate) {
    return switch (candidate.targetKind) {
      IndexTargetKind.log => _session.addLogToIndex(candidate.targetId),
      IndexTargetKind.collection => _session.addCollectionToIndex(
        candidate.targetId,
      ),
    };
  }
}

class IndexScreen extends ConsumerStatefulWidget {
  const IndexScreen({super.key});

  @override
  ConsumerState<IndexScreen> createState() => _IndexScreenState();
}

class _IndexScreenState extends ConsumerState<IndexScreen> {
  late Future<List<IndexItem>> _itemsFuture;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _itemsFuture = _dataSource().list();
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
                    l10n.index,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                IconButton(
                  onPressed: _saving ? null : _showAddDialog,
                  tooltip: l10n.addIndexItem,
                  icon: const Icon(Icons.add),
                ),
                IconButton(
                  onPressed: _saving ? null : _lock,
                  tooltip: l10n.lockJournal,
                  icon: const Icon(Icons.lock_outline),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<IndexItem>>(
                future: _itemsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    return Center(child: Text(l10n.indexLoadFailed));
                  }
                  final List<IndexItem> items = snapshot.requireData;
                  if (items.isEmpty) {
                    return Align(
                      alignment: AlignmentDirectional.topStart,
                      child: Text(l10n.emptyIndex),
                    );
                  }
                  return ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final IndexItem item = items[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(_iconFor(item.targetKind, item.logKind)),
                        title: Text(_labelForItem(item, l10n)),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddDialog() async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final IndexJournalDataSource dataSource = _dataSource();
    late final List<IndexCandidate> candidates;

    try {
      candidates = await dataSource.candidates();
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'daymark',
          context: ErrorDescription('while loading Index candidates'),
        ),
      );
      if (mounted) {
        _showError(l10n.indexCandidatesLoadFailed);
      }
      return;
    }

    if (!mounted) {
      return;
    }
    if (candidates.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.noIndexCandidates)));
      return;
    }

    final IndexCandidate? selected = await showDialog<IndexCandidate>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.addIndexItem),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440, maxHeight: 420),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: candidates.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final IndexCandidate candidate = candidates[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    _iconFor(candidate.targetKind, candidate.logKind),
                  ),
                  title: Text(_labelForCandidate(candidate, l10n)),
                  onTap: () => Navigator.of(dialogContext).pop(candidate),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                MaterialLocalizations.of(dialogContext).cancelButtonLabel,
              ),
            ),
          ],
        );
      },
    );

    if (selected == null || !mounted) {
      return;
    }

    setState(() => _saving = true);
    try {
      await dataSource.add(selected);
      if (mounted) {
        setState(() => _itemsFuture = dataSource.list());
      }
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'daymark',
          context: ErrorDescription('while adding an Index item'),
        ),
      );
      if (mounted) {
        _showError(l10n.indexAddFailed);
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  String _labelForItem(IndexItem item, AppLocalizations l10n) {
    return switch (item.targetKind) {
      IndexTargetKind.collection =>
        '${l10n.collections}: ${item.collectionTitle!}',
      IndexTargetKind.log => _logLabel(
        kind: item.logKind!,
        periodStart: item.periodStart!,
        l10n: l10n,
      ),
    };
  }

  String _labelForCandidate(IndexCandidate candidate, AppLocalizations l10n) {
    return switch (candidate.targetKind) {
      IndexTargetKind.collection =>
        '${l10n.collections}: ${candidate.collectionTitle!}',
      IndexTargetKind.log => _logLabel(
        kind: candidate.logKind!,
        periodStart: candidate.periodStart!,
        l10n: l10n,
      ),
    };
  }

  String _logLabel({
    required JournalLogKind kind,
    required String periodStart,
    required AppLocalizations l10n,
  }) {
    final DateTime date = DateTime.parse(periodStart);
    final MaterialLocalizations material = MaterialLocalizations.of(context);
    return switch (kind) {
      JournalLogKind.daily =>
        '${l10n.daily}: ${material.formatMediumDate(date)}',
      JournalLogKind.monthly =>
        '${l10n.monthly}: ${material.formatMonthYear(date)}',
      JournalLogKind.future =>
        '${l10n.future}: ${material.formatMonthYear(date)}',
    };
  }

  IconData _iconFor(IndexTargetKind targetKind, JournalLogKind? logKind) {
    if (targetKind == IndexTargetKind.collection) {
      return Icons.book_outlined;
    }
    return switch (logKind!) {
      JournalLogKind.daily => Icons.today_outlined,
      JournalLogKind.monthly => Icons.calendar_month_outlined,
      JournalLogKind.future => Icons.event_outlined,
    };
  }

  IndexJournalDataSource _dataSource() {
    return ref.read(indexJournalDataSourceProvider);
  }

  Future<void> _lock() {
    return ref.read(journalSessionControllerProvider.notifier).lock();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
