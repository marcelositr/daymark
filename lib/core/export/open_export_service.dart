import 'dart:convert';

import 'package:daymark/core/database/daymark_database.dart';

enum OpenExportFormat { json, markdown }

extension OpenExportFormatFile on OpenExportFormat {
  String get extension => switch (this) {
    OpenExportFormat.json => 'json',
    OpenExportFormat.markdown => 'md',
  };
}

final class OpenExportDocument {
  const OpenExportDocument({required this.format, required this.contents});

  final OpenExportFormat format;
  final String contents;
}

final class OpenExportService {
  OpenExportService(this._database);

  static const String formatName = 'daymark-open-export';
  static const int formatVersion = 2;

  final DaymarkDatabase _database;

  Future<OpenExportDocument> create({required OpenExportFormat format}) {
    return _database.transaction(() async {
      final Map<String, Object?> payload = <String, Object?>{
        'format': formatName,
        'formatVersion': formatVersion,
        'databaseSchemaVersion': DaymarkDatabase.currentSchemaVersion,
        'journalMetadata': await _readTable(
          'SELECT id, singleton, created_at, updated_at '
          'FROM journal_metadata ORDER BY id',
          const <String>['id', 'singleton', 'created_at', 'updated_at'],
        ),
        'logs': await _readTable(
          'SELECT id, kind, period_start, created_at '
          'FROM logs ORDER BY kind, period_start, id',
          const <String>['id', 'kind', 'period_start', 'created_at'],
        ),
        'collections': await _readTable(
          'SELECT id, title, created_at, updated_at '
          'FROM collections ORDER BY created_at, id',
          const <String>['id', 'title', 'created_at', 'updated_at'],
        ),
        'entries': await _readTable(
          'SELECT id, entry_type, task_state, content, created_at, updated_at '
          'FROM entries ORDER BY created_at, id',
          const <String>[
            'id',
            'entry_type',
            'task_state',
            'content',
            'created_at',
            'updated_at',
          ],
        ),
        'entryPlacements': await _readTable(
          'SELECT entry_id, log_id, collection_id, ordinal, monthly_section, '
          'monthly_calendar_date FROM entry_placements '
          'ORDER BY COALESCE(log_id, collection_id), ordinal, entry_id',
          const <String>[
            'entry_id',
            'log_id',
            'collection_id',
            'ordinal',
            'monthly_section',
            'monthly_calendar_date',
          ],
        ),
        'migrations': await _readTable(
          'SELECT id, source_entry_id, destination_entry_id, kind, created_at '
          'FROM migrations ORDER BY created_at, id',
          const <String>[
            'id',
            'source_entry_id',
            'destination_entry_id',
            'kind',
            'created_at',
          ],
        ),
        'collectionReferences': await _readTable(
          'SELECT collection_id, entry_id, ordinal, created_at '
          'FROM collection_references '
          'ORDER BY collection_id, ordinal, entry_id',
          const <String>['collection_id', 'entry_id', 'ordinal', 'created_at'],
        ),
        'signifiers': await _readTable(
          'SELECT id, kind, builtin_code, custom_label, custom_symbol, created_at '
          'FROM signifiers '
          'ORDER BY kind, builtin_code, custom_label, id',
          const <String>[
            'id',
            'kind',
            'builtin_code',
            'custom_label',
            'custom_symbol',
            'created_at',
          ],
        ),
        'entrySignifiers': await _readTable(
          'SELECT entry_id, signifier_id FROM entry_signifiers '
          'ORDER BY entry_id, signifier_id',
          const <String>['entry_id', 'signifier_id'],
        ),
        'indexItems': await _readTable(
          'SELECT id, ordinal, log_id, collection_id, created_at '
          'FROM index_items ORDER BY ordinal, id',
          const <String>[
            'id',
            'ordinal',
            'log_id',
            'collection_id',
            'created_at',
          ],
        ),
        'trackers': await _readTable(
          'SELECT id, title, start_date, planned_end_date, ended_date, '
          'color_slot, created_at, updated_at FROM trackers '
          'ORDER BY start_date, color_slot, created_at, id',
          const <String>[
            'id',
            'title',
            'start_date',
            'planned_end_date',
            'ended_date',
            'color_slot',
            'created_at',
            'updated_at',
          ],
        ),
        'trackerMarks': await _readTable(
          'SELECT tracker_id, method_date, value, created_at, updated_at '
          'FROM tracker_marks ORDER BY tracker_id, method_date',
          const <String>[
            'tracker_id',
            'method_date',
            'value',
            'created_at',
            'updated_at',
          ],
        ),
      };

      final String contents = switch (format) {
        OpenExportFormat.json => const JsonEncoder.withIndent(
          '  ',
        ).convert(payload),
        OpenExportFormat.markdown => _renderMarkdown(payload),
      };

      return OpenExportDocument(format: format, contents: '$contents\n');
    });
  }

  Future<List<Map<String, Object?>>> _readTable(
    String sql,
    List<String> columns,
  ) async {
    final rows = await _database.customSelect(sql).get();
    return <Map<String, Object?>>[
      for (final row in rows)
        <String, Object?>{
          for (final column in columns) _camelCase(column): row.data[column],
        },
    ];
  }
}

String _camelCase(String value) {
  final List<String> parts = value.split('_');
  return parts.first +
      parts
          .skip(1)
          .map(
            (part) => part.isEmpty
                ? ''
                : '${part[0].toUpperCase()}${part.substring(1)}',
          )
          .join();
}

String _renderMarkdown(Map<String, Object?> payload) {
  final StringBuffer buffer = StringBuffer()
    ..writeln('# Daymark Open Export')
    ..writeln()
    ..writeln('Format: ${_inlineCode(payload['format'].toString())}')
    ..writeln(
      'Format version: ${_inlineCode(payload['formatVersion'].toString())}',
    )
    ..writeln(
      'Database schema version: '
      '${_inlineCode(payload['databaseSchemaVersion'].toString())}',
    )
    ..writeln()
    ..writeln(
      '> This is a plaintext export. It is not protected by Daymark encryption.',
    );

  for (final String section in const <String>[
    'journalMetadata',
    'logs',
    'collections',
    'entries',
    'entryPlacements',
    'migrations',
    'collectionReferences',
    'signifiers',
    'entrySignifiers',
    'indexItems',
    'trackers',
    'trackerMarks',
  ]) {
    final List<Object?> records = payload[section]! as List<Object?>;
    buffer
      ..writeln()
      ..writeln('## $section')
      ..writeln();

    if (records.isEmpty) {
      buffer.writeln('_None._');
      continue;
    }

    for (int index = 0; index < records.length; index += 1) {
      final Map<String, Object?> record =
          records[index]! as Map<String, Object?>;
      final Object? id =
          record['id'] ?? record['entryId'] ?? record['trackerId'];
      buffer.writeln(
        '### ${index + 1}'
        '${id == null ? '' : ' · ${_inlineCode(id.toString())}'}',
      );
      buffer.writeln();

      for (final MapEntry<String, Object?> field in record.entries) {
        final String value = _scalar(field.value);
        if (field.key == 'content' || value.contains('\n')) {
          _writeTextBlock(buffer, field.key, value);
          continue;
        }
        buffer.writeln('- ${field.key}: ${_inlineCode(value)}');
      }
      buffer.writeln();
    }
  }

  return buffer.toString().trimRight();
}

void _writeTextBlock(StringBuffer buffer, String key, String content) {
  String fence = '```';
  while (content.contains(fence)) {
    fence += '`';
  }
  buffer
    ..writeln('- $key:')
    ..writeln('${fence}text')
    ..writeln(content)
    ..writeln(fence);
}

String _scalar(Object? value) {
  if (value == null) {
    return 'null';
  }
  return value.toString();
}

String _inlineCode(String value) {
  int longestRun = 0;
  for (final RegExpMatch match in RegExp(r'`+').allMatches(value)) {
    final int length = match.group(0)!.length;
    if (length > longestRun) {
      longestRun = length;
    }
  }

  final String fence = List<String>.filled(longestRun + 1, '`').join();
  final bool needsPadding =
      value.startsWith('`') ||
      value.endsWith('`') ||
      value.startsWith(' ') ||
      value.endsWith(' ');

  return needsPadding ? '$fence $value $fence' : '$fence$value$fence';
}
