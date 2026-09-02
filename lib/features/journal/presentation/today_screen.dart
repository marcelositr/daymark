import 'package:daymark/core/session/journal_session.dart';
import 'package:daymark/core/session/journal_session_controller.dart';
import 'package:daymark/features/journal/data/daily_log_repository.dart';
import 'package:daymark/features/journal/domain/journal_domain.dart';
import 'package:daymark/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  final TextEditingController _entryController = TextEditingController();

  late final DateTime _today;
  late Future<DailyLogSnapshot> _snapshotFuture;
  JournalEntryType _entryType = JournalEntryType.task;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final DateTime now = DateTime.now();
    _today = DateTime(now.year, now.month, now.day);
    _snapshotFuture = _loadSnapshot();
  }

  @override
  void dispose() {
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
            _buildComposer(context, l10n),
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
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 28,
                child: Text(
                  _entrySymbol(entry.type),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  entry.content,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildComposer(BuildContext context, AppLocalizations l10n) {
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

  Future<DailyLogSnapshot> _loadSnapshot() async {
    final JournalSession session = _session();
    return session.dailyLog.loadOrCreate(formatJournalMethodDate(_today));
  }

  JournalSession _session() {
    final JournalAccessState access = ref
        .read(journalSessionControllerProvider)
        .requireValue;
    if (access is! JournalUnlocked) {
      throw StateError('Today requires an unlocked journal session.');
    }
    return access.session;
  }

  Future<void> _capture() async {
    final String content = _entryController.text.trim();
    if (content.isEmpty) {
      return;
    }

    final AppLocalizations l10n = AppLocalizations.of(context);
    setState(() => _saving = true);

    try {
      final DailyLogSnapshot snapshot = await _snapshotFuture;
      await _session().dailyLog.capture(
        logId: snapshot.logId,
        type: _entryType,
        content: content,
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.saveEntryFailed)));
        setState(() => _saving = false);
      }
      return;
    }

    if (!mounted) {
      return;
    }

    _entryController.clear();
    setState(() {
      _snapshotFuture = _loadSnapshot();
      _saving = false;
    });
  }

  Future<void> _lock() {
    return ref.read(journalSessionControllerProvider.notifier).lock();
  }
}

String _entrySymbol(JournalEntryType type) => switch (type) {
  JournalEntryType.task => '•',
  JournalEntryType.event => '○',
  JournalEntryType.note => '–',
};
