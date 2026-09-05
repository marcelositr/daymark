import 'dart:async';

import 'package:daymark/core/session/journal_search_session.dart';
import 'package:daymark/core/session/journal_session.dart';
import 'package:daymark/core/session/journal_session_controller.dart';
import 'package:daymark/features/journal/data/search_repository.dart';
import 'package:daymark/features/journal/domain/journal_domain.dart';
import 'package:daymark/features/journal/presentation/source_navigation.dart';
import 'package:daymark/l10n/app_localizations.dart';
import 'package:daymark/presentation/app_section_scope.dart';
import 'package:daymark/presentation/daymark_empty_state.dart';
import 'package:daymark/presentation/daymark_notice.dart';
import 'package:daymark/presentation/daymark_page_frame.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

abstract interface class SearchJournalDataSource {
  Future<List<JournalSearchResult>> search(String query);
}

final Provider<SearchJournalDataSource> searchJournalDataSourceProvider =
    Provider<SearchJournalDataSource>((ref) {
      final JournalAccessState access = ref
          .watch(journalSessionControllerProvider)
          .requireValue;
      if (access case JournalUnlocked(:final session)) {
        return _SessionSearchJournalDataSource(session);
      }
      throw StateError('Search requires an unlocked journal session.');
    });

final class _SessionSearchJournalDataSource implements SearchJournalDataSource {
  const _SessionSearchJournalDataSource(this._session);

  final JournalSession _session;

  @override
  Future<List<JournalSearchResult>> search(String query) {
    return _session.searchJournal(query);
  }
}

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<JournalSearchResult> _results = const <JournalSearchResult>[];
  bool _searching = false;
  bool _hasSearched = false;
  bool _failed = false;
  bool _sectionScopeInitialized = false;
  bool _wasSearchSectionActive = false;
  int _searchRequestId = 0;
  String? _lastSubmittedQuery;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final int? currentSectionIndex = AppSectionScope.maybeCurrentIndexOf(
      context,
    );
    if (currentSectionIndex == null) {
      return;
    }

    final bool isSearchSectionActive =
        currentSectionIndex == AppSectionScope.searchSectionIndex;
    if (_sectionScopeInitialized &&
        isSearchSectionActive &&
        !_wasSearchSectionActive &&
        !_searching) {
      final String? query = _lastSubmittedQuery;
      if (query != null) {
        unawaited(_executeSearch(query, showProgress: false));
      }
      _restoreSearchFocus();
    }
    _sectionScopeInitialized = true;
    _wasSearchSectionActive = isSearchSectionActive;
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return DaymarkPageFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.search,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              IconButton(
                onPressed: _searching ? null : _lock,
                tooltip: l10n.lockJournal,
                icon: const Icon(Icons.lock_outline),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            focusNode: _searchFocusNode,
            autofocus: defaultTargetPlatform == TargetPlatform.linux,
            enabled: !_searching,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _runSearch(),
            decoration: InputDecoration(
              hintText: l10n.searchHint,
              suffixIcon: IconButton(
                onPressed: _searching ? null : _runSearch,
                tooltip: l10n.searchAction,
                icon: const Icon(Icons.search),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(child: _buildResults(context, l10n)),
          const DaymarkNoticeRegion(),
        ],
      ),
    );
  }

  Widget _buildResults(BuildContext context, AppLocalizations l10n) {
    if (_searching) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_failed) {
      return Align(
        alignment: AlignmentDirectional.topStart,
        child: Text(l10n.searchFailed),
      );
    }
    if (!_hasSearched) {
      return DaymarkEmptyState(message: l10n.searchPrompt);
    }
    if (_results.isEmpty) {
      return DaymarkEmptyState(message: l10n.searchNoResults);
    }

    return ListView.separated(
      itemCount: _results.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final JournalSearchResult result = _results[index];
        final bool discarded = result.taskState == JournalTaskState.discarded;
        return ListTile(
          onTap: () => context.go(sourceLocationForSearchResult(result)),
          contentPadding: EdgeInsets.zero,
          leading: SizedBox(
            width: 24,
            child: Text(
              _entrySymbol(result),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          title: Text(
            result.content,
            style: discarded
                ? const TextStyle(decoration: TextDecoration.lineThrough)
                : null,
          ),
          subtitle: Text(_contextLabel(result, l10n)),
        );
      },
    );
  }

  void _restoreSearchFocus() {
    if (defaultTargetPlatform != TargetPlatform.linux || _searching) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_searching) {
        _searchFocusNode.requestFocus();
      }
    });
  }

  Future<void> _runSearch() async {
    final String query = _controller.text.trim();
    if (query.isEmpty) {
      _searchRequestId++;
      if (mounted) {
        setState(() {
          _results = const <JournalSearchResult>[];
          _hasSearched = false;
          _failed = false;
          _lastSubmittedQuery = null;
        });
      }
      return;
    }

    _lastSubmittedQuery = query;
    await _executeSearch(query, showProgress: true);
  }

  Future<void> _executeSearch(
    String query, {
    required bool showProgress,
  }) async {
    final int requestId = ++_searchRequestId;
    if (showProgress && mounted) {
      setState(() {
        _searching = true;
        _failed = false;
      });
    }

    try {
      final List<JournalSearchResult> results = await _dataSource().search(
        query,
      );
      if (mounted && requestId == _searchRequestId) {
        setState(() {
          _results = results;
          _hasSearched = true;
          _failed = false;
        });
      }
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'daymark',
          context: ErrorDescription('while searching journal entries'),
        ),
      );
      if (mounted && requestId == _searchRequestId) {
        setState(() {
          _results = const <JournalSearchResult>[];
          _hasSearched = true;
          _failed = true;
        });
      }
    } finally {
      if (showProgress && mounted && requestId == _searchRequestId) {
        setState(() => _searching = false);
        _restoreSearchFocus();
      }
    }
  }

  String _contextLabel(JournalSearchResult result, AppLocalizations l10n) {
    if (result.ownerKind == SearchOwnerKind.collection) {
      return '${l10n.collections}: ${result.collectionTitle!}';
    }

    final DateTime period = DateTime.parse(result.periodStart!);
    final MaterialLocalizations material = MaterialLocalizations.of(context);
    return switch (result.logKind!) {
      JournalLogKind.daily =>
        '${l10n.daily}: ${material.formatMediumDate(period)}',
      JournalLogKind.monthly => _monthlyContext(result, l10n, material, period),
      JournalLogKind.future =>
        '${l10n.future}: ${material.formatMonthYear(period)}',
    };
  }

  String _monthlyContext(
    JournalSearchResult result,
    AppLocalizations l10n,
    MaterialLocalizations material,
    DateTime period,
  ) {
    final String month = material.formatMonthYear(period);
    if (result.monthlySection == JournalMonthlySection.calendar &&
        result.monthlyCalendarDate != null) {
      final DateTime calendarDate = DateTime.parse(result.monthlyCalendarDate!);
      return '${l10n.monthly}: $month · ${l10n.monthlyCalendar}: '
          '${material.formatMediumDate(calendarDate)}';
    }
    return '${l10n.monthly}: $month · ${l10n.monthlyTasks}';
  }

  SearchJournalDataSource _dataSource() {
    return ref.read(searchJournalDataSourceProvider);
  }

  Future<void> _lock() {
    return ref.read(journalSessionControllerProvider.notifier).lock();
  }
}

String _entrySymbol(JournalSearchResult result) => switch (result.type) {
  JournalEntryType.task => switch (result.taskState) {
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
