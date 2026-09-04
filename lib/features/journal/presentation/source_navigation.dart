import 'package:daymark/features/journal/data/index_repository.dart';
import 'package:daymark/features/journal/data/search_repository.dart';
import 'package:daymark/features/journal/domain/journal_domain.dart';

String sourceLocationForSearchResult(JournalSearchResult result) {
  if (result.ownerKind == SearchOwnerKind.collection) {
    return '/collections/${result.ownerId}';
  }

  final JournalLogKind kind =
      result.logKind ??
      (throw StateError('Search Log result is missing its Log kind.'));
  final String periodStart =
      result.periodStart ??
      (throw StateError('Search Log result is missing its period.'));

  return switch (kind) {
    JournalLogKind.daily => '/daily/$periodStart',
    JournalLogKind.monthly => _monthlyLocation(
      periodStart,
      result.monthlySection,
    ),
    JournalLogKind.future => '/future/$periodStart',
  };
}

String sourceLocationForIndexItem(IndexItem item) {
  if (item.targetKind == IndexTargetKind.collection) {
    return '/collections/${item.targetId}';
  }

  final JournalLogKind kind =
      item.logKind ??
      (throw StateError('Indexed Log is missing its Log kind.'));
  final String periodStart =
      item.periodStart ??
      (throw StateError('Indexed Log is missing its period.'));

  return switch (kind) {
    JournalLogKind.daily => '/daily/$periodStart',
    JournalLogKind.monthly => '/monthly/$periodStart',
    JournalLogKind.future => '/future/$periodStart',
  };
}

String _monthlyLocation(String periodStart, JournalMonthlySection? section) {
  final String base = '/monthly/$periodStart';
  if (section == null) {
    return base;
  }
  return '$base?section=${section.code}';
}
