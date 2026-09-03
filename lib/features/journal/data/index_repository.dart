import 'package:daymark/core/database/daymark_database.dart';
import 'package:daymark/features/journal/domain/journal_domain.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

enum IndexTargetKind { log, collection }

final class IndexItem {
  const IndexItem({
    required this.id,
    required this.ordinal,
    required this.targetKind,
    required this.targetId,
    this.logKind,
    this.periodStart,
    this.collectionTitle,
  });

  final String id;
  final int ordinal;
  final IndexTargetKind targetKind;
  final String targetId;
  final JournalLogKind? logKind;
  final String? periodStart;
  final String? collectionTitle;
}

final class IndexCandidate {
  const IndexCandidate({
    required this.targetKind,
    required this.targetId,
    this.logKind,
    this.periodStart,
    this.collectionTitle,
  });

  final IndexTargetKind targetKind;
  final String targetId;
  final JournalLogKind? logKind;
  final String? periodStart;
  final String? collectionTitle;
}

/// Focused persistence boundary for the deliberate Bullet Journal Index.
///
/// The Index references existing Logs or Collections. It never duplicates entry
/// content and never derives itself automatically from Search or journal data.
final class IndexRepository {
  IndexRepository(
    this._database, {
    String Function()? idGenerator,
    int Function()? nowUtcMicros,
  }) : _idGenerator = idGenerator ?? _defaultIdGenerator,
       _nowUtcMicros = nowUtcMicros ?? _defaultNowUtcMicros;

  final DaymarkDatabase _database;
  final String Function() _idGenerator;
  final int Function() _nowUtcMicros;

  Future<List<IndexItem>> list() async {
    final rows = await _database.customSelect('''
      SELECT
        i.id,
        i.ordinal,
        i.log_id,
        i.collection_id,
        l.kind AS log_kind,
        l.period_start,
        c.title AS collection_title
      FROM index_items AS i
      LEFT JOIN logs AS l ON l.id = i.log_id
      LEFT JOIN collections AS c ON c.id = i.collection_id
      ORDER BY i.ordinal, i.id
      ''').get();

    return rows.map((row) {
      final String? logId = row.readNullable<String>('log_id');
      final String? collectionId = row.readNullable<String>('collection_id');
      if (logId != null) {
        return IndexItem(
          id: row.read<String>('id'),
          ordinal: row.read<int>('ordinal'),
          targetKind: IndexTargetKind.log,
          targetId: logId,
          logKind: _logKindFromCode(row.read<String>('log_kind')),
          periodStart: row.read<String>('period_start'),
        );
      }
      if (collectionId != null) {
        return IndexItem(
          id: row.read<String>('id'),
          ordinal: row.read<int>('ordinal'),
          targetKind: IndexTargetKind.collection,
          targetId: collectionId,
          collectionTitle: row.read<String>('collection_title'),
        );
      }
      throw const JournalInvariantException(
        'Index item does not reference a Log or Collection.',
      );
    }).toList(growable: false);
  }

  Future<List<IndexCandidate>> candidates() async {
    final logRows = await _database.customSelect('''
      SELECT l.id, l.kind, l.period_start
      FROM logs AS l
      WHERE NOT EXISTS (
        SELECT 1 FROM index_items AS i WHERE i.log_id = l.id
      )
      ORDER BY
        CASE l.kind
          WHEN 'daily' THEN 0
          WHEN 'monthly' THEN 1
          ELSE 2
        END,
        l.period_start DESC,
        l.id
      ''').get();

    final collectionRows = await _database.customSelect('''
      SELECT c.id, c.title
      FROM collections AS c
      WHERE NOT EXISTS (
        SELECT 1 FROM index_items AS i WHERE i.collection_id = c.id
      )
      ORDER BY c.created_at, c.id
      ''').get();

    return <IndexCandidate>[
      ...logRows.map(
        (row) => IndexCandidate(
          targetKind: IndexTargetKind.log,
          targetId: row.read<String>('id'),
          logKind: _logKindFromCode(row.read<String>('kind')),
          periodStart: row.read<String>('period_start'),
        ),
      ),
      ...collectionRows.map(
        (row) => IndexCandidate(
          targetKind: IndexTargetKind.collection,
          targetId: row.read<String>('id'),
          collectionTitle: row.read<String>('title'),
        ),
      ),
    ];
  }

  Future<void> addLog(String logId) {
    return _addTarget(logId: logId);
  }

  Future<void> addCollection(String collectionId) {
    return _addTarget(collectionId: collectionId);
  }

  Future<void> _addTarget({String? logId, String? collectionId}) {
    return _database.transaction(() async {
      if ((logId == null) == (collectionId == null)) {
        throw const JournalInvariantException(
          'An Index item must reference exactly one target.',
        );
      }

      if (logId != null) {
        await _requireTarget(table: 'logs', id: logId, entity: 'Log');
      } else {
        await _requireTarget(
          table: 'collections',
          id: collectionId!,
          entity: 'Collection',
        );
      }

      final String targetColumn = logId != null ? 'log_id' : 'collection_id';
      final String targetId = logId ?? collectionId!;
      final duplicate = await _database
          .customSelect(
            'SELECT 1 FROM index_items WHERE $targetColumn = ?',
            variables: <Variable<Object>>[Variable.withString(targetId)],
          )
          .getSingleOrNull();
      if (duplicate != null) {
        throw const JournalInvariantException(
          'This journal structure is already in the Index.',
        );
      }

      final ordinalRow = await _database
          .customSelect(
            'SELECT COALESCE(MAX(ordinal), -1) + 1 AS next_ordinal FROM index_items',
          )
          .getSingle();

      await _database.customStatement(
        '''
        INSERT INTO index_items (
          id, ordinal, log_id, collection_id, created_at
        ) VALUES (?, ?, ?, ?, ?)
        ''',
        <Object?>[
          _newId(),
          ordinalRow.read<int>('next_ordinal'),
          logId,
          collectionId,
          _now(),
        ],
      );
    });
  }

  Future<void> _requireTarget({
    required String table,
    required String id,
    required String entity,
  }) async {
    final row = await _database
        .customSelect(
          'SELECT 1 FROM $table WHERE id = ?',
          variables: <Variable<Object>>[Variable.withString(id)],
        )
        .getSingleOrNull();
    if (row == null) {
      throw JournalNotFoundException(entity, id);
    }
  }

  String _newId() => _idGenerator().toLowerCase();

  int _now() {
    final int value = _nowUtcMicros();
    if (value < 0) {
      throw StateError('UTC microsecond clock returned a negative instant.');
    }
    return value;
  }
}

JournalLogKind _logKindFromCode(String value) => switch (value) {
  'daily' => JournalLogKind.daily,
  'monthly' => JournalLogKind.monthly,
  'future' => JournalLogKind.future,
  _ => throw JournalInvariantException('Unknown log kind: $value.'),
};

String _defaultIdGenerator() => const Uuid().v7();

int _defaultNowUtcMicros() => DateTime.now().toUtc().microsecondsSinceEpoch;
