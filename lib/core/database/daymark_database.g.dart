// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daymark_database.dart';

// ignore_for_file: type=lint
class JournalMetadata extends Table
    with TableInfo<JournalMetadata, JournalMetadataData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  JournalMetadata(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _singletonMeta = const VerificationMeta(
    'singleton',
  );
  late final GeneratedColumn<int> singleton = GeneratedColumn<int>(
    'singleton',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 1 UNIQUE CHECK (singleton = 1)',
    defaultValue: const CustomExpression('1'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (created_at >= 0)',
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (updated_at >= created_at)',
  );
  @override
  List<GeneratedColumn> get $columns => [id, singleton, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'journal_metadata';
  @override
  VerificationContext validateIntegrity(
    Insertable<JournalMetadataData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('singleton')) {
      context.handle(
        _singletonMeta,
        singleton.isAcceptableOrUnknown(data['singleton']!, _singletonMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  JournalMetadataData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JournalMetadataData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      singleton: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}singleton'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  JournalMetadata createAlias(String alias) {
    return JournalMetadata(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class JournalMetadataData extends DataClass
    implements Insertable<JournalMetadataData> {
  final String id;
  final int singleton;
  final int createdAt;
  final int updatedAt;
  const JournalMetadataData({
    required this.id,
    required this.singleton,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['singleton'] = Variable<int>(singleton);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  JournalMetadataCompanion toCompanion(bool nullToAbsent) {
    return JournalMetadataCompanion(
      id: Value(id),
      singleton: Value(singleton),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory JournalMetadataData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JournalMetadataData(
      id: serializer.fromJson<String>(json['id']),
      singleton: serializer.fromJson<int>(json['singleton']),
      createdAt: serializer.fromJson<int>(json['created_at']),
      updatedAt: serializer.fromJson<int>(json['updated_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'singleton': serializer.toJson<int>(singleton),
      'created_at': serializer.toJson<int>(createdAt),
      'updated_at': serializer.toJson<int>(updatedAt),
    };
  }

  JournalMetadataData copyWith({
    String? id,
    int? singleton,
    int? createdAt,
    int? updatedAt,
  }) => JournalMetadataData(
    id: id ?? this.id,
    singleton: singleton ?? this.singleton,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  JournalMetadataData copyWithCompanion(JournalMetadataCompanion data) {
    return JournalMetadataData(
      id: data.id.present ? data.id.value : this.id,
      singleton: data.singleton.present ? data.singleton.value : this.singleton,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JournalMetadataData(')
          ..write('id: $id, ')
          ..write('singleton: $singleton, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, singleton, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JournalMetadataData &&
          other.id == this.id &&
          other.singleton == this.singleton &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class JournalMetadataCompanion extends UpdateCompanion<JournalMetadataData> {
  final Value<String> id;
  final Value<int> singleton;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const JournalMetadataCompanion({
    this.id = const Value.absent(),
    this.singleton = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  JournalMetadataCompanion.insert({
    required String id,
    this.singleton = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<JournalMetadataData> custom({
    Expression<String>? id,
    Expression<int>? singleton,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (singleton != null) 'singleton': singleton,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  JournalMetadataCompanion copyWith({
    Value<String>? id,
    Value<int>? singleton,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return JournalMetadataCompanion(
      id: id ?? this.id,
      singleton: singleton ?? this.singleton,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (singleton.present) {
      map['singleton'] = Variable<int>(singleton.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JournalMetadataCompanion(')
          ..write('id: $id, ')
          ..write('singleton: $singleton, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Logs extends Table with TableInfo<Logs, Log> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Logs(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (kind IN (\'daily\', \'monthly\', \'future\'))',
  );
  static const VerificationMeta _periodStartMeta = const VerificationMeta(
    'periodStart',
  );
  late final GeneratedColumn<String> periodStart = GeneratedColumn<String>(
    'period_start',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (length(period_start) = 10)',
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (created_at >= 0)',
  );
  @override
  List<GeneratedColumn> get $columns => [id, kind, periodStart, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<Log> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('period_start')) {
      context.handle(
        _periodStartMeta,
        periodStart.isAcceptableOrUnknown(
          data['period_start']!,
          _periodStartMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_periodStartMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {kind, periodStart},
  ];
  @override
  Log map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Log(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      periodStart: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}period_start'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  Logs createAlias(String alias) {
    return Logs(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const ['UNIQUE(kind, period_start)'];
  @override
  bool get dontWriteConstraints => true;
}

class Log extends DataClass implements Insertable<Log> {
  final String id;
  final String kind;
  final String periodStart;
  final int createdAt;
  const Log({
    required this.id,
    required this.kind,
    required this.periodStart,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['kind'] = Variable<String>(kind);
    map['period_start'] = Variable<String>(periodStart);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  LogsCompanion toCompanion(bool nullToAbsent) {
    return LogsCompanion(
      id: Value(id),
      kind: Value(kind),
      periodStart: Value(periodStart),
      createdAt: Value(createdAt),
    );
  }

  factory Log.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Log(
      id: serializer.fromJson<String>(json['id']),
      kind: serializer.fromJson<String>(json['kind']),
      periodStart: serializer.fromJson<String>(json['period_start']),
      createdAt: serializer.fromJson<int>(json['created_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'kind': serializer.toJson<String>(kind),
      'period_start': serializer.toJson<String>(periodStart),
      'created_at': serializer.toJson<int>(createdAt),
    };
  }

  Log copyWith({
    String? id,
    String? kind,
    String? periodStart,
    int? createdAt,
  }) => Log(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    periodStart: periodStart ?? this.periodStart,
    createdAt: createdAt ?? this.createdAt,
  );
  Log copyWithCompanion(LogsCompanion data) {
    return Log(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      periodStart: data.periodStart.present
          ? data.periodStart.value
          : this.periodStart,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Log(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('periodStart: $periodStart, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, kind, periodStart, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Log &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.periodStart == this.periodStart &&
          other.createdAt == this.createdAt);
}

class LogsCompanion extends UpdateCompanion<Log> {
  final Value<String> id;
  final Value<String> kind;
  final Value<String> periodStart;
  final Value<int> createdAt;
  final Value<int> rowid;
  const LogsCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.periodStart = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LogsCompanion.insert({
    required String id,
    required String kind,
    required String periodStart,
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       kind = Value(kind),
       periodStart = Value(periodStart),
       createdAt = Value(createdAt);
  static Insertable<Log> custom({
    Expression<String>? id,
    Expression<String>? kind,
    Expression<String>? periodStart,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (periodStart != null) 'period_start': periodStart,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LogsCompanion copyWith({
    Value<String>? id,
    Value<String>? kind,
    Value<String>? periodStart,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return LogsCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      periodStart: periodStart ?? this.periodStart,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (periodStart.present) {
      map['period_start'] = Variable<String>(periodStart.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LogsCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('periodStart: $periodStart, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Collections extends Table with TableInfo<Collections, Collection> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Collections(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (length(trim(title)) > 0)',
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (created_at >= 0)',
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (updated_at >= created_at)',
  );
  @override
  List<GeneratedColumn> get $columns => [id, title, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'collections';
  @override
  VerificationContext validateIntegrity(
    Insertable<Collection> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Collection map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Collection(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  Collections createAlias(String alias) {
    return Collections(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class Collection extends DataClass implements Insertable<Collection> {
  final String id;
  final String title;
  final int createdAt;
  final int updatedAt;
  const Collection({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  CollectionsCompanion toCompanion(bool nullToAbsent) {
    return CollectionsCompanion(
      id: Value(id),
      title: Value(title),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Collection.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Collection(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      createdAt: serializer.fromJson<int>(json['created_at']),
      updatedAt: serializer.fromJson<int>(json['updated_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'created_at': serializer.toJson<int>(createdAt),
      'updated_at': serializer.toJson<int>(updatedAt),
    };
  }

  Collection copyWith({
    String? id,
    String? title,
    int? createdAt,
    int? updatedAt,
  }) => Collection(
    id: id ?? this.id,
    title: title ?? this.title,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Collection copyWithCompanion(CollectionsCompanion data) {
    return Collection(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Collection(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Collection &&
          other.id == this.id &&
          other.title == this.title &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CollectionsCompanion extends UpdateCompanion<Collection> {
  final Value<String> id;
  final Value<String> title;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const CollectionsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CollectionsCompanion.insert({
    required String id,
    required String title,
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Collection> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CollectionsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return CollectionsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CollectionsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Entries extends Table with TableInfo<Entries, Entry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Entries(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _entryTypeMeta = const VerificationMeta(
    'entryType',
  );
  late final GeneratedColumn<String> entryType = GeneratedColumn<String>(
    'entry_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (entry_type IN (\'task\', \'event\', \'note\'))',
  );
  static const VerificationMeta _taskStateMeta = const VerificationMeta(
    'taskState',
  );
  late final GeneratedColumn<String> taskState = GeneratedColumn<String>(
    'task_state',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'CHECK (task_state IN (\'open\', \'completed\', \'migrated\', \'scheduled\', \'discarded\'))',
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (length(trim(content)) > 0)',
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (created_at >= 0)',
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (updated_at >= created_at)',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entryType,
    taskState,
    content,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<Entry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entry_type')) {
      context.handle(
        _entryTypeMeta,
        entryType.isAcceptableOrUnknown(data['entry_type']!, _entryTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entryTypeMeta);
    }
    if (data.containsKey('task_state')) {
      context.handle(
        _taskStateMeta,
        taskState.isAcceptableOrUnknown(data['task_state']!, _taskStateMeta),
      );
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Entry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Entry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      entryType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entry_type'],
      )!,
      taskState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_state'],
      ),
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  Entries createAlias(String alias) {
    return Entries(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'CHECK((entry_type = \'task\' AND task_state IS NOT NULL)OR(entry_type IN (\'event\', \'note\') AND task_state IS NULL))',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class Entry extends DataClass implements Insertable<Entry> {
  final String id;
  final String entryType;
  final String? taskState;
  final String content;
  final int createdAt;
  final int updatedAt;
  const Entry({
    required this.id,
    required this.entryType,
    this.taskState,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entry_type'] = Variable<String>(entryType);
    if (!nullToAbsent || taskState != null) {
      map['task_state'] = Variable<String>(taskState);
    }
    map['content'] = Variable<String>(content);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  EntriesCompanion toCompanion(bool nullToAbsent) {
    return EntriesCompanion(
      id: Value(id),
      entryType: Value(entryType),
      taskState: taskState == null && nullToAbsent
          ? const Value.absent()
          : Value(taskState),
      content: Value(content),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Entry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Entry(
      id: serializer.fromJson<String>(json['id']),
      entryType: serializer.fromJson<String>(json['entry_type']),
      taskState: serializer.fromJson<String?>(json['task_state']),
      content: serializer.fromJson<String>(json['content']),
      createdAt: serializer.fromJson<int>(json['created_at']),
      updatedAt: serializer.fromJson<int>(json['updated_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entry_type': serializer.toJson<String>(entryType),
      'task_state': serializer.toJson<String?>(taskState),
      'content': serializer.toJson<String>(content),
      'created_at': serializer.toJson<int>(createdAt),
      'updated_at': serializer.toJson<int>(updatedAt),
    };
  }

  Entry copyWith({
    String? id,
    String? entryType,
    Value<String?> taskState = const Value.absent(),
    String? content,
    int? createdAt,
    int? updatedAt,
  }) => Entry(
    id: id ?? this.id,
    entryType: entryType ?? this.entryType,
    taskState: taskState.present ? taskState.value : this.taskState,
    content: content ?? this.content,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Entry copyWithCompanion(EntriesCompanion data) {
    return Entry(
      id: data.id.present ? data.id.value : this.id,
      entryType: data.entryType.present ? data.entryType.value : this.entryType,
      taskState: data.taskState.present ? data.taskState.value : this.taskState,
      content: data.content.present ? data.content.value : this.content,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Entry(')
          ..write('id: $id, ')
          ..write('entryType: $entryType, ')
          ..write('taskState: $taskState, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, entryType, taskState, content, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Entry &&
          other.id == this.id &&
          other.entryType == this.entryType &&
          other.taskState == this.taskState &&
          other.content == this.content &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class EntriesCompanion extends UpdateCompanion<Entry> {
  final Value<String> id;
  final Value<String> entryType;
  final Value<String?> taskState;
  final Value<String> content;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const EntriesCompanion({
    this.id = const Value.absent(),
    this.entryType = const Value.absent(),
    this.taskState = const Value.absent(),
    this.content = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EntriesCompanion.insert({
    required String id,
    required String entryType,
    this.taskState = const Value.absent(),
    required String content,
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       entryType = Value(entryType),
       content = Value(content),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Entry> custom({
    Expression<String>? id,
    Expression<String>? entryType,
    Expression<String>? taskState,
    Expression<String>? content,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entryType != null) 'entry_type': entryType,
      if (taskState != null) 'task_state': taskState,
      if (content != null) 'content': content,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? entryType,
    Value<String?>? taskState,
    Value<String>? content,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return EntriesCompanion(
      id: id ?? this.id,
      entryType: entryType ?? this.entryType,
      taskState: taskState ?? this.taskState,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entryType.present) {
      map['entry_type'] = Variable<String>(entryType.value);
    }
    if (taskState.present) {
      map['task_state'] = Variable<String>(taskState.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntriesCompanion(')
          ..write('id: $id, ')
          ..write('entryType: $entryType, ')
          ..write('taskState: $taskState, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class EntryPlacements extends Table
    with TableInfo<EntryPlacements, EntryPlacement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  EntryPlacements(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entryIdMeta = const VerificationMeta(
    'entryId',
  );
  late final GeneratedColumn<String> entryId = GeneratedColumn<String>(
    'entry_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL PRIMARY KEY REFERENCES entries(id)ON DELETE CASCADE',
  );
  static const VerificationMeta _logIdMeta = const VerificationMeta('logId');
  late final GeneratedColumn<String> logId = GeneratedColumn<String>(
    'log_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'REFERENCES logs(id)ON DELETE RESTRICT',
  );
  static const VerificationMeta _collectionIdMeta = const VerificationMeta(
    'collectionId',
  );
  late final GeneratedColumn<String> collectionId = GeneratedColumn<String>(
    'collection_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'REFERENCES collections(id)ON DELETE RESTRICT',
  );
  static const VerificationMeta _ordinalMeta = const VerificationMeta(
    'ordinal',
  );
  late final GeneratedColumn<int> ordinal = GeneratedColumn<int>(
    'ordinal',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (ordinal >= 0)',
  );
  static const VerificationMeta _monthlySectionMeta = const VerificationMeta(
    'monthlySection',
  );
  late final GeneratedColumn<String> monthlySection = GeneratedColumn<String>(
    'monthly_section',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'CHECK (monthly_section IN (\'calendar\', \'tasks\'))',
  );
  static const VerificationMeta _monthlyCalendarDateMeta =
      const VerificationMeta('monthlyCalendarDate');
  late final GeneratedColumn<String> monthlyCalendarDate =
      GeneratedColumn<String>(
        'monthly_calendar_date',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: 'CHECK (monthly_calendar_date IS NULL OR length(monthly_calendar_date) = 10)',
      );
  @override
  List<GeneratedColumn> get $columns => [
    entryId,
    logId,
    collectionId,
    ordinal,
    monthlySection,
    monthlyCalendarDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entry_placements';
  @override
  VerificationContext validateIntegrity(
    Insertable<EntryPlacement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entry_id')) {
      context.handle(
        _entryIdMeta,
        entryId.isAcceptableOrUnknown(data['entry_id']!, _entryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entryIdMeta);
    }
    if (data.containsKey('log_id')) {
      context.handle(
        _logIdMeta,
        logId.isAcceptableOrUnknown(data['log_id']!, _logIdMeta),
      );
    }
    if (data.containsKey('collection_id')) {
      context.handle(
        _collectionIdMeta,
        collectionId.isAcceptableOrUnknown(
          data['collection_id']!,
          _collectionIdMeta,
        ),
      );
    }
    if (data.containsKey('ordinal')) {
      context.handle(
        _ordinalMeta,
        ordinal.isAcceptableOrUnknown(data['ordinal']!, _ordinalMeta),
      );
    } else if (isInserting) {
      context.missing(_ordinalMeta);
    }
    if (data.containsKey('monthly_section')) {
      context.handle(
        _monthlySectionMeta,
        monthlySection.isAcceptableOrUnknown(
          data['monthly_section']!,
          _monthlySectionMeta,
        ),
      );
    }
    if (data.containsKey('monthly_calendar_date')) {
      context.handle(
        _monthlyCalendarDateMeta,
        monthlyCalendarDate.isAcceptableOrUnknown(
          data['monthly_calendar_date']!,
          _monthlyCalendarDateMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entryId};
  @override
  EntryPlacement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EntryPlacement(
      entryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entry_id'],
      )!,
      logId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}log_id'],
      ),
      collectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collection_id'],
      ),
      ordinal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ordinal'],
      )!,
      monthlySection: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}monthly_section'],
      ),
      monthlyCalendarDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}monthly_calendar_date'],
      ),
    );
  }

  @override
  EntryPlacements createAlias(String alias) {
    return EntryPlacements(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'CHECK((log_id IS NOT NULL AND collection_id IS NULL)OR(log_id IS NULL AND collection_id IS NOT NULL))',
    'CHECK(collection_id IS NULL OR monthly_section IS NULL)',
    'CHECK((monthly_section = \'calendar\' AND monthly_calendar_date IS NOT NULL)OR(monthly_section IS NULL AND monthly_calendar_date IS NULL)OR(monthly_section = \'tasks\' AND monthly_calendar_date IS NULL))',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class EntryPlacement extends DataClass implements Insertable<EntryPlacement> {
  final String entryId;
  final String? logId;
  final String? collectionId;
  final int ordinal;
  final String? monthlySection;
  final String? monthlyCalendarDate;
  const EntryPlacement({
    required this.entryId,
    this.logId,
    this.collectionId,
    required this.ordinal,
    this.monthlySection,
    this.monthlyCalendarDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entry_id'] = Variable<String>(entryId);
    if (!nullToAbsent || logId != null) {
      map['log_id'] = Variable<String>(logId);
    }
    if (!nullToAbsent || collectionId != null) {
      map['collection_id'] = Variable<String>(collectionId);
    }
    map['ordinal'] = Variable<int>(ordinal);
    if (!nullToAbsent || monthlySection != null) {
      map['monthly_section'] = Variable<String>(monthlySection);
    }
    if (!nullToAbsent || monthlyCalendarDate != null) {
      map['monthly_calendar_date'] = Variable<String>(monthlyCalendarDate);
    }
    return map;
  }

  EntryPlacementsCompanion toCompanion(bool nullToAbsent) {
    return EntryPlacementsCompanion(
      entryId: Value(entryId),
      logId: logId == null && nullToAbsent
          ? const Value.absent()
          : Value(logId),
      collectionId: collectionId == null && nullToAbsent
          ? const Value.absent()
          : Value(collectionId),
      ordinal: Value(ordinal),
      monthlySection: monthlySection == null && nullToAbsent
          ? const Value.absent()
          : Value(monthlySection),
      monthlyCalendarDate: monthlyCalendarDate == null && nullToAbsent
          ? const Value.absent()
          : Value(monthlyCalendarDate),
    );
  }

  factory EntryPlacement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EntryPlacement(
      entryId: serializer.fromJson<String>(json['entry_id']),
      logId: serializer.fromJson<String?>(json['log_id']),
      collectionId: serializer.fromJson<String?>(json['collection_id']),
      ordinal: serializer.fromJson<int>(json['ordinal']),
      monthlySection: serializer.fromJson<String?>(json['monthly_section']),
      monthlyCalendarDate: serializer.fromJson<String?>(
        json['monthly_calendar_date'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entry_id': serializer.toJson<String>(entryId),
      'log_id': serializer.toJson<String?>(logId),
      'collection_id': serializer.toJson<String?>(collectionId),
      'ordinal': serializer.toJson<int>(ordinal),
      'monthly_section': serializer.toJson<String?>(monthlySection),
      'monthly_calendar_date': serializer.toJson<String?>(monthlyCalendarDate),
    };
  }

  EntryPlacement copyWith({
    String? entryId,
    Value<String?> logId = const Value.absent(),
    Value<String?> collectionId = const Value.absent(),
    int? ordinal,
    Value<String?> monthlySection = const Value.absent(),
    Value<String?> monthlyCalendarDate = const Value.absent(),
  }) => EntryPlacement(
    entryId: entryId ?? this.entryId,
    logId: logId.present ? logId.value : this.logId,
    collectionId: collectionId.present ? collectionId.value : this.collectionId,
    ordinal: ordinal ?? this.ordinal,
    monthlySection: monthlySection.present
        ? monthlySection.value
        : this.monthlySection,
    monthlyCalendarDate: monthlyCalendarDate.present
        ? monthlyCalendarDate.value
        : this.monthlyCalendarDate,
  );
  EntryPlacement copyWithCompanion(EntryPlacementsCompanion data) {
    return EntryPlacement(
      entryId: data.entryId.present ? data.entryId.value : this.entryId,
      logId: data.logId.present ? data.logId.value : this.logId,
      collectionId: data.collectionId.present
          ? data.collectionId.value
          : this.collectionId,
      ordinal: data.ordinal.present ? data.ordinal.value : this.ordinal,
      monthlySection: data.monthlySection.present
          ? data.monthlySection.value
          : this.monthlySection,
      monthlyCalendarDate: data.monthlyCalendarDate.present
          ? data.monthlyCalendarDate.value
          : this.monthlyCalendarDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EntryPlacement(')
          ..write('entryId: $entryId, ')
          ..write('logId: $logId, ')
          ..write('collectionId: $collectionId, ')
          ..write('ordinal: $ordinal, ')
          ..write('monthlySection: $monthlySection, ')
          ..write('monthlyCalendarDate: $monthlyCalendarDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    entryId,
    logId,
    collectionId,
    ordinal,
    monthlySection,
    monthlyCalendarDate,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EntryPlacement &&
          other.entryId == this.entryId &&
          other.logId == this.logId &&
          other.collectionId == this.collectionId &&
          other.ordinal == this.ordinal &&
          other.monthlySection == this.monthlySection &&
          other.monthlyCalendarDate == this.monthlyCalendarDate);
}

class EntryPlacementsCompanion extends UpdateCompanion<EntryPlacement> {
  final Value<String> entryId;
  final Value<String?> logId;
  final Value<String?> collectionId;
  final Value<int> ordinal;
  final Value<String?> monthlySection;
  final Value<String?> monthlyCalendarDate;
  final Value<int> rowid;
  const EntryPlacementsCompanion({
    this.entryId = const Value.absent(),
    this.logId = const Value.absent(),
    this.collectionId = const Value.absent(),
    this.ordinal = const Value.absent(),
    this.monthlySection = const Value.absent(),
    this.monthlyCalendarDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EntryPlacementsCompanion.insert({
    required String entryId,
    this.logId = const Value.absent(),
    this.collectionId = const Value.absent(),
    required int ordinal,
    this.monthlySection = const Value.absent(),
    this.monthlyCalendarDate = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : entryId = Value(entryId),
       ordinal = Value(ordinal);
  static Insertable<EntryPlacement> custom({
    Expression<String>? entryId,
    Expression<String>? logId,
    Expression<String>? collectionId,
    Expression<int>? ordinal,
    Expression<String>? monthlySection,
    Expression<String>? monthlyCalendarDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entryId != null) 'entry_id': entryId,
      if (logId != null) 'log_id': logId,
      if (collectionId != null) 'collection_id': collectionId,
      if (ordinal != null) 'ordinal': ordinal,
      if (monthlySection != null) 'monthly_section': monthlySection,
      if (monthlyCalendarDate != null)
        'monthly_calendar_date': monthlyCalendarDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EntryPlacementsCompanion copyWith({
    Value<String>? entryId,
    Value<String?>? logId,
    Value<String?>? collectionId,
    Value<int>? ordinal,
    Value<String?>? monthlySection,
    Value<String?>? monthlyCalendarDate,
    Value<int>? rowid,
  }) {
    return EntryPlacementsCompanion(
      entryId: entryId ?? this.entryId,
      logId: logId ?? this.logId,
      collectionId: collectionId ?? this.collectionId,
      ordinal: ordinal ?? this.ordinal,
      monthlySection: monthlySection ?? this.monthlySection,
      monthlyCalendarDate: monthlyCalendarDate ?? this.monthlyCalendarDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entryId.present) {
      map['entry_id'] = Variable<String>(entryId.value);
    }
    if (logId.present) {
      map['log_id'] = Variable<String>(logId.value);
    }
    if (collectionId.present) {
      map['collection_id'] = Variable<String>(collectionId.value);
    }
    if (ordinal.present) {
      map['ordinal'] = Variable<int>(ordinal.value);
    }
    if (monthlySection.present) {
      map['monthly_section'] = Variable<String>(monthlySection.value);
    }
    if (monthlyCalendarDate.present) {
      map['monthly_calendar_date'] = Variable<String>(
        monthlyCalendarDate.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntryPlacementsCompanion(')
          ..write('entryId: $entryId, ')
          ..write('logId: $logId, ')
          ..write('collectionId: $collectionId, ')
          ..write('ordinal: $ordinal, ')
          ..write('monthlySection: $monthlySection, ')
          ..write('monthlyCalendarDate: $monthlyCalendarDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Migrations extends Table with TableInfo<Migrations, Migration> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Migrations(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _sourceEntryIdMeta = const VerificationMeta(
    'sourceEntryId',
  );
  late final GeneratedColumn<String> sourceEntryId = GeneratedColumn<String>(
    'source_entry_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL UNIQUE REFERENCES entries(id)ON DELETE RESTRICT',
  );
  static const VerificationMeta _destinationEntryIdMeta =
      const VerificationMeta('destinationEntryId');
  late final GeneratedColumn<String> destinationEntryId =
      GeneratedColumn<String>(
        'destination_entry_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        $customConstraints:
            'NOT NULL UNIQUE REFERENCES entries(id)ON DELETE RESTRICT',
      );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (kind IN (\'migrated\', \'scheduled\'))',
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (created_at >= 0)',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sourceEntryId,
    destinationEntryId,
    kind,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'migrations';
  @override
  VerificationContext validateIntegrity(
    Insertable<Migration> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('source_entry_id')) {
      context.handle(
        _sourceEntryIdMeta,
        sourceEntryId.isAcceptableOrUnknown(
          data['source_entry_id']!,
          _sourceEntryIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceEntryIdMeta);
    }
    if (data.containsKey('destination_entry_id')) {
      context.handle(
        _destinationEntryIdMeta,
        destinationEntryId.isAcceptableOrUnknown(
          data['destination_entry_id']!,
          _destinationEntryIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_destinationEntryIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Migration map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Migration(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sourceEntryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_entry_id'],
      )!,
      destinationEntryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}destination_entry_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  Migrations createAlias(String alias) {
    return Migrations(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'CHECK(source_entry_id <> destination_entry_id)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class Migration extends DataClass implements Insertable<Migration> {
  final String id;
  final String sourceEntryId;
  final String destinationEntryId;
  final String kind;
  final int createdAt;
  const Migration({
    required this.id,
    required this.sourceEntryId,
    required this.destinationEntryId,
    required this.kind,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['source_entry_id'] = Variable<String>(sourceEntryId);
    map['destination_entry_id'] = Variable<String>(destinationEntryId);
    map['kind'] = Variable<String>(kind);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  MigrationsCompanion toCompanion(bool nullToAbsent) {
    return MigrationsCompanion(
      id: Value(id),
      sourceEntryId: Value(sourceEntryId),
      destinationEntryId: Value(destinationEntryId),
      kind: Value(kind),
      createdAt: Value(createdAt),
    );
  }

  factory Migration.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Migration(
      id: serializer.fromJson<String>(json['id']),
      sourceEntryId: serializer.fromJson<String>(json['source_entry_id']),
      destinationEntryId: serializer.fromJson<String>(
        json['destination_entry_id'],
      ),
      kind: serializer.fromJson<String>(json['kind']),
      createdAt: serializer.fromJson<int>(json['created_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'source_entry_id': serializer.toJson<String>(sourceEntryId),
      'destination_entry_id': serializer.toJson<String>(destinationEntryId),
      'kind': serializer.toJson<String>(kind),
      'created_at': serializer.toJson<int>(createdAt),
    };
  }

  Migration copyWith({
    String? id,
    String? sourceEntryId,
    String? destinationEntryId,
    String? kind,
    int? createdAt,
  }) => Migration(
    id: id ?? this.id,
    sourceEntryId: sourceEntryId ?? this.sourceEntryId,
    destinationEntryId: destinationEntryId ?? this.destinationEntryId,
    kind: kind ?? this.kind,
    createdAt: createdAt ?? this.createdAt,
  );
  Migration copyWithCompanion(MigrationsCompanion data) {
    return Migration(
      id: data.id.present ? data.id.value : this.id,
      sourceEntryId: data.sourceEntryId.present
          ? data.sourceEntryId.value
          : this.sourceEntryId,
      destinationEntryId: data.destinationEntryId.present
          ? data.destinationEntryId.value
          : this.destinationEntryId,
      kind: data.kind.present ? data.kind.value : this.kind,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Migration(')
          ..write('id: $id, ')
          ..write('sourceEntryId: $sourceEntryId, ')
          ..write('destinationEntryId: $destinationEntryId, ')
          ..write('kind: $kind, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, sourceEntryId, destinationEntryId, kind, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Migration &&
          other.id == this.id &&
          other.sourceEntryId == this.sourceEntryId &&
          other.destinationEntryId == this.destinationEntryId &&
          other.kind == this.kind &&
          other.createdAt == this.createdAt);
}

class MigrationsCompanion extends UpdateCompanion<Migration> {
  final Value<String> id;
  final Value<String> sourceEntryId;
  final Value<String> destinationEntryId;
  final Value<String> kind;
  final Value<int> createdAt;
  final Value<int> rowid;
  const MigrationsCompanion({
    this.id = const Value.absent(),
    this.sourceEntryId = const Value.absent(),
    this.destinationEntryId = const Value.absent(),
    this.kind = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MigrationsCompanion.insert({
    required String id,
    required String sourceEntryId,
    required String destinationEntryId,
    required String kind,
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sourceEntryId = Value(sourceEntryId),
       destinationEntryId = Value(destinationEntryId),
       kind = Value(kind),
       createdAt = Value(createdAt);
  static Insertable<Migration> custom({
    Expression<String>? id,
    Expression<String>? sourceEntryId,
    Expression<String>? destinationEntryId,
    Expression<String>? kind,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sourceEntryId != null) 'source_entry_id': sourceEntryId,
      if (destinationEntryId != null)
        'destination_entry_id': destinationEntryId,
      if (kind != null) 'kind': kind,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MigrationsCompanion copyWith({
    Value<String>? id,
    Value<String>? sourceEntryId,
    Value<String>? destinationEntryId,
    Value<String>? kind,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return MigrationsCompanion(
      id: id ?? this.id,
      sourceEntryId: sourceEntryId ?? this.sourceEntryId,
      destinationEntryId: destinationEntryId ?? this.destinationEntryId,
      kind: kind ?? this.kind,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sourceEntryId.present) {
      map['source_entry_id'] = Variable<String>(sourceEntryId.value);
    }
    if (destinationEntryId.present) {
      map['destination_entry_id'] = Variable<String>(destinationEntryId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MigrationsCompanion(')
          ..write('id: $id, ')
          ..write('sourceEntryId: $sourceEntryId, ')
          ..write('destinationEntryId: $destinationEntryId, ')
          ..write('kind: $kind, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class CollectionReferences extends Table
    with TableInfo<CollectionReferences, CollectionReference> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  CollectionReferences(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _collectionIdMeta = const VerificationMeta(
    'collectionId',
  );
  late final GeneratedColumn<String> collectionId = GeneratedColumn<String>(
    'collection_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES collections(id)ON DELETE CASCADE',
  );
  static const VerificationMeta _entryIdMeta = const VerificationMeta(
    'entryId',
  );
  late final GeneratedColumn<String> entryId = GeneratedColumn<String>(
    'entry_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES entries(id)ON DELETE CASCADE',
  );
  static const VerificationMeta _ordinalMeta = const VerificationMeta(
    'ordinal',
  );
  late final GeneratedColumn<int> ordinal = GeneratedColumn<int>(
    'ordinal',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (ordinal >= 0)',
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (created_at >= 0)',
  );
  @override
  List<GeneratedColumn> get $columns => [
    collectionId,
    entryId,
    ordinal,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'collection_references';
  @override
  VerificationContext validateIntegrity(
    Insertable<CollectionReference> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('collection_id')) {
      context.handle(
        _collectionIdMeta,
        collectionId.isAcceptableOrUnknown(
          data['collection_id']!,
          _collectionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_collectionIdMeta);
    }
    if (data.containsKey('entry_id')) {
      context.handle(
        _entryIdMeta,
        entryId.isAcceptableOrUnknown(data['entry_id']!, _entryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entryIdMeta);
    }
    if (data.containsKey('ordinal')) {
      context.handle(
        _ordinalMeta,
        ordinal.isAcceptableOrUnknown(data['ordinal']!, _ordinalMeta),
      );
    } else if (isInserting) {
      context.missing(_ordinalMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {collectionId, entryId};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {collectionId, ordinal},
  ];
  @override
  CollectionReference map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CollectionReference(
      collectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collection_id'],
      )!,
      entryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entry_id'],
      )!,
      ordinal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ordinal'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  CollectionReferences createAlias(String alias) {
    return CollectionReferences(attachedDatabase, alias);
  }

  @override
  bool get withoutRowId => true;
  @override
  List<String> get customConstraints => const [
    'PRIMARY KEY(collection_id, entry_id)',
    'UNIQUE(collection_id, ordinal)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class CollectionReference extends DataClass
    implements Insertable<CollectionReference> {
  final String collectionId;
  final String entryId;
  final int ordinal;
  final int createdAt;
  const CollectionReference({
    required this.collectionId,
    required this.entryId,
    required this.ordinal,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['collection_id'] = Variable<String>(collectionId);
    map['entry_id'] = Variable<String>(entryId);
    map['ordinal'] = Variable<int>(ordinal);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  CollectionReferencesCompanion toCompanion(bool nullToAbsent) {
    return CollectionReferencesCompanion(
      collectionId: Value(collectionId),
      entryId: Value(entryId),
      ordinal: Value(ordinal),
      createdAt: Value(createdAt),
    );
  }

  factory CollectionReference.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CollectionReference(
      collectionId: serializer.fromJson<String>(json['collection_id']),
      entryId: serializer.fromJson<String>(json['entry_id']),
      ordinal: serializer.fromJson<int>(json['ordinal']),
      createdAt: serializer.fromJson<int>(json['created_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'collection_id': serializer.toJson<String>(collectionId),
      'entry_id': serializer.toJson<String>(entryId),
      'ordinal': serializer.toJson<int>(ordinal),
      'created_at': serializer.toJson<int>(createdAt),
    };
  }

  CollectionReference copyWith({
    String? collectionId,
    String? entryId,
    int? ordinal,
    int? createdAt,
  }) => CollectionReference(
    collectionId: collectionId ?? this.collectionId,
    entryId: entryId ?? this.entryId,
    ordinal: ordinal ?? this.ordinal,
    createdAt: createdAt ?? this.createdAt,
  );
  CollectionReference copyWithCompanion(CollectionReferencesCompanion data) {
    return CollectionReference(
      collectionId: data.collectionId.present
          ? data.collectionId.value
          : this.collectionId,
      entryId: data.entryId.present ? data.entryId.value : this.entryId,
      ordinal: data.ordinal.present ? data.ordinal.value : this.ordinal,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CollectionReference(')
          ..write('collectionId: $collectionId, ')
          ..write('entryId: $entryId, ')
          ..write('ordinal: $ordinal, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(collectionId, entryId, ordinal, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CollectionReference &&
          other.collectionId == this.collectionId &&
          other.entryId == this.entryId &&
          other.ordinal == this.ordinal &&
          other.createdAt == this.createdAt);
}

class CollectionReferencesCompanion
    extends UpdateCompanion<CollectionReference> {
  final Value<String> collectionId;
  final Value<String> entryId;
  final Value<int> ordinal;
  final Value<int> createdAt;
  const CollectionReferencesCompanion({
    this.collectionId = const Value.absent(),
    this.entryId = const Value.absent(),
    this.ordinal = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  CollectionReferencesCompanion.insert({
    required String collectionId,
    required String entryId,
    required int ordinal,
    required int createdAt,
  }) : collectionId = Value(collectionId),
       entryId = Value(entryId),
       ordinal = Value(ordinal),
       createdAt = Value(createdAt);
  static Insertable<CollectionReference> custom({
    Expression<String>? collectionId,
    Expression<String>? entryId,
    Expression<int>? ordinal,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (collectionId != null) 'collection_id': collectionId,
      if (entryId != null) 'entry_id': entryId,
      if (ordinal != null) 'ordinal': ordinal,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  CollectionReferencesCompanion copyWith({
    Value<String>? collectionId,
    Value<String>? entryId,
    Value<int>? ordinal,
    Value<int>? createdAt,
  }) {
    return CollectionReferencesCompanion(
      collectionId: collectionId ?? this.collectionId,
      entryId: entryId ?? this.entryId,
      ordinal: ordinal ?? this.ordinal,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (collectionId.present) {
      map['collection_id'] = Variable<String>(collectionId.value);
    }
    if (entryId.present) {
      map['entry_id'] = Variable<String>(entryId.value);
    }
    if (ordinal.present) {
      map['ordinal'] = Variable<int>(ordinal.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CollectionReferencesCompanion(')
          ..write('collectionId: $collectionId, ')
          ..write('entryId: $entryId, ')
          ..write('ordinal: $ordinal, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class Signifiers extends Table with TableInfo<Signifiers, Signifier> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Signifiers(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (kind IN (\'builtin\', \'custom\'))',
  );
  static const VerificationMeta _builtinCodeMeta = const VerificationMeta(
    'builtinCode',
  );
  late final GeneratedColumn<String> builtinCode = GeneratedColumn<String>(
    'builtin_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'UNIQUE',
  );
  static const VerificationMeta _customLabelMeta = const VerificationMeta(
    'customLabel',
  );
  late final GeneratedColumn<String> customLabel = GeneratedColumn<String>(
    'custom_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _customSymbolMeta = const VerificationMeta(
    'customSymbol',
  );
  late final GeneratedColumn<String> customSymbol = GeneratedColumn<String>(
    'custom_symbol',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (created_at >= 0)',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kind,
    builtinCode,
    customLabel,
    customSymbol,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'signifiers';
  @override
  VerificationContext validateIntegrity(
    Insertable<Signifier> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('builtin_code')) {
      context.handle(
        _builtinCodeMeta,
        builtinCode.isAcceptableOrUnknown(
          data['builtin_code']!,
          _builtinCodeMeta,
        ),
      );
    }
    if (data.containsKey('custom_label')) {
      context.handle(
        _customLabelMeta,
        customLabel.isAcceptableOrUnknown(
          data['custom_label']!,
          _customLabelMeta,
        ),
      );
    }
    if (data.containsKey('custom_symbol')) {
      context.handle(
        _customSymbolMeta,
        customSymbol.isAcceptableOrUnknown(
          data['custom_symbol']!,
          _customSymbolMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Signifier map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Signifier(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      builtinCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}builtin_code'],
      ),
      customLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_label'],
      ),
      customSymbol: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_symbol'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  Signifiers createAlias(String alias) {
    return Signifiers(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'CHECK((kind = \'builtin\' AND builtin_code IS NOT NULL AND custom_label IS NULL AND custom_symbol IS NULL)OR(kind = \'custom\' AND builtin_code IS NULL AND custom_label IS NOT NULL AND length(trim(custom_label)) > 0))',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class Signifier extends DataClass implements Insertable<Signifier> {
  final String id;
  final String kind;
  final String? builtinCode;
  final String? customLabel;
  final String? customSymbol;
  final int createdAt;
  const Signifier({
    required this.id,
    required this.kind,
    this.builtinCode,
    this.customLabel,
    this.customSymbol,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || builtinCode != null) {
      map['builtin_code'] = Variable<String>(builtinCode);
    }
    if (!nullToAbsent || customLabel != null) {
      map['custom_label'] = Variable<String>(customLabel);
    }
    if (!nullToAbsent || customSymbol != null) {
      map['custom_symbol'] = Variable<String>(customSymbol);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  SignifiersCompanion toCompanion(bool nullToAbsent) {
    return SignifiersCompanion(
      id: Value(id),
      kind: Value(kind),
      builtinCode: builtinCode == null && nullToAbsent
          ? const Value.absent()
          : Value(builtinCode),
      customLabel: customLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(customLabel),
      customSymbol: customSymbol == null && nullToAbsent
          ? const Value.absent()
          : Value(customSymbol),
      createdAt: Value(createdAt),
    );
  }

  factory Signifier.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Signifier(
      id: serializer.fromJson<String>(json['id']),
      kind: serializer.fromJson<String>(json['kind']),
      builtinCode: serializer.fromJson<String?>(json['builtin_code']),
      customLabel: serializer.fromJson<String?>(json['custom_label']),
      customSymbol: serializer.fromJson<String?>(json['custom_symbol']),
      createdAt: serializer.fromJson<int>(json['created_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'kind': serializer.toJson<String>(kind),
      'builtin_code': serializer.toJson<String?>(builtinCode),
      'custom_label': serializer.toJson<String?>(customLabel),
      'custom_symbol': serializer.toJson<String?>(customSymbol),
      'created_at': serializer.toJson<int>(createdAt),
    };
  }

  Signifier copyWith({
    String? id,
    String? kind,
    Value<String?> builtinCode = const Value.absent(),
    Value<String?> customLabel = const Value.absent(),
    Value<String?> customSymbol = const Value.absent(),
    int? createdAt,
  }) => Signifier(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    builtinCode: builtinCode.present ? builtinCode.value : this.builtinCode,
    customLabel: customLabel.present ? customLabel.value : this.customLabel,
    customSymbol: customSymbol.present ? customSymbol.value : this.customSymbol,
    createdAt: createdAt ?? this.createdAt,
  );
  Signifier copyWithCompanion(SignifiersCompanion data) {
    return Signifier(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      builtinCode: data.builtinCode.present
          ? data.builtinCode.value
          : this.builtinCode,
      customLabel: data.customLabel.present
          ? data.customLabel.value
          : this.customLabel,
      customSymbol: data.customSymbol.present
          ? data.customSymbol.value
          : this.customSymbol,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Signifier(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('builtinCode: $builtinCode, ')
          ..write('customLabel: $customLabel, ')
          ..write('customSymbol: $customSymbol, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, kind, builtinCode, customLabel, customSymbol, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Signifier &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.builtinCode == this.builtinCode &&
          other.customLabel == this.customLabel &&
          other.customSymbol == this.customSymbol &&
          other.createdAt == this.createdAt);
}

class SignifiersCompanion extends UpdateCompanion<Signifier> {
  final Value<String> id;
  final Value<String> kind;
  final Value<String?> builtinCode;
  final Value<String?> customLabel;
  final Value<String?> customSymbol;
  final Value<int> createdAt;
  final Value<int> rowid;
  const SignifiersCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.builtinCode = const Value.absent(),
    this.customLabel = const Value.absent(),
    this.customSymbol = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SignifiersCompanion.insert({
    required String id,
    required String kind,
    this.builtinCode = const Value.absent(),
    this.customLabel = const Value.absent(),
    this.customSymbol = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       kind = Value(kind),
       createdAt = Value(createdAt);
  static Insertable<Signifier> custom({
    Expression<String>? id,
    Expression<String>? kind,
    Expression<String>? builtinCode,
    Expression<String>? customLabel,
    Expression<String>? customSymbol,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (builtinCode != null) 'builtin_code': builtinCode,
      if (customLabel != null) 'custom_label': customLabel,
      if (customSymbol != null) 'custom_symbol': customSymbol,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SignifiersCompanion copyWith({
    Value<String>? id,
    Value<String>? kind,
    Value<String?>? builtinCode,
    Value<String?>? customLabel,
    Value<String?>? customSymbol,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return SignifiersCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      builtinCode: builtinCode ?? this.builtinCode,
      customLabel: customLabel ?? this.customLabel,
      customSymbol: customSymbol ?? this.customSymbol,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (builtinCode.present) {
      map['builtin_code'] = Variable<String>(builtinCode.value);
    }
    if (customLabel.present) {
      map['custom_label'] = Variable<String>(customLabel.value);
    }
    if (customSymbol.present) {
      map['custom_symbol'] = Variable<String>(customSymbol.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SignifiersCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('builtinCode: $builtinCode, ')
          ..write('customLabel: $customLabel, ')
          ..write('customSymbol: $customSymbol, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class EntrySignifiers extends Table
    with TableInfo<EntrySignifiers, EntrySignifier> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  EntrySignifiers(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entryIdMeta = const VerificationMeta(
    'entryId',
  );
  late final GeneratedColumn<String> entryId = GeneratedColumn<String>(
    'entry_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES entries(id)ON DELETE CASCADE',
  );
  static const VerificationMeta _signifierIdMeta = const VerificationMeta(
    'signifierId',
  );
  late final GeneratedColumn<String> signifierId = GeneratedColumn<String>(
    'signifier_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES signifiers(id)ON DELETE CASCADE',
  );
  @override
  List<GeneratedColumn> get $columns => [entryId, signifierId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entry_signifiers';
  @override
  VerificationContext validateIntegrity(
    Insertable<EntrySignifier> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entry_id')) {
      context.handle(
        _entryIdMeta,
        entryId.isAcceptableOrUnknown(data['entry_id']!, _entryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entryIdMeta);
    }
    if (data.containsKey('signifier_id')) {
      context.handle(
        _signifierIdMeta,
        signifierId.isAcceptableOrUnknown(
          data['signifier_id']!,
          _signifierIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_signifierIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entryId, signifierId};
  @override
  EntrySignifier map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EntrySignifier(
      entryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entry_id'],
      )!,
      signifierId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}signifier_id'],
      )!,
    );
  }

  @override
  EntrySignifiers createAlias(String alias) {
    return EntrySignifiers(attachedDatabase, alias);
  }

  @override
  bool get withoutRowId => true;
  @override
  List<String> get customConstraints => const [
    'PRIMARY KEY(entry_id, signifier_id)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class EntrySignifier extends DataClass implements Insertable<EntrySignifier> {
  final String entryId;
  final String signifierId;
  const EntrySignifier({required this.entryId, required this.signifierId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entry_id'] = Variable<String>(entryId);
    map['signifier_id'] = Variable<String>(signifierId);
    return map;
  }

  EntrySignifiersCompanion toCompanion(bool nullToAbsent) {
    return EntrySignifiersCompanion(
      entryId: Value(entryId),
      signifierId: Value(signifierId),
    );
  }

  factory EntrySignifier.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EntrySignifier(
      entryId: serializer.fromJson<String>(json['entry_id']),
      signifierId: serializer.fromJson<String>(json['signifier_id']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entry_id': serializer.toJson<String>(entryId),
      'signifier_id': serializer.toJson<String>(signifierId),
    };
  }

  EntrySignifier copyWith({String? entryId, String? signifierId}) =>
      EntrySignifier(
        entryId: entryId ?? this.entryId,
        signifierId: signifierId ?? this.signifierId,
      );
  EntrySignifier copyWithCompanion(EntrySignifiersCompanion data) {
    return EntrySignifier(
      entryId: data.entryId.present ? data.entryId.value : this.entryId,
      signifierId: data.signifierId.present
          ? data.signifierId.value
          : this.signifierId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EntrySignifier(')
          ..write('entryId: $entryId, ')
          ..write('signifierId: $signifierId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(entryId, signifierId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EntrySignifier &&
          other.entryId == this.entryId &&
          other.signifierId == this.signifierId);
}

class EntrySignifiersCompanion extends UpdateCompanion<EntrySignifier> {
  final Value<String> entryId;
  final Value<String> signifierId;
  const EntrySignifiersCompanion({
    this.entryId = const Value.absent(),
    this.signifierId = const Value.absent(),
  });
  EntrySignifiersCompanion.insert({
    required String entryId,
    required String signifierId,
  }) : entryId = Value(entryId),
       signifierId = Value(signifierId);
  static Insertable<EntrySignifier> custom({
    Expression<String>? entryId,
    Expression<String>? signifierId,
  }) {
    return RawValuesInsertable({
      if (entryId != null) 'entry_id': entryId,
      if (signifierId != null) 'signifier_id': signifierId,
    });
  }

  EntrySignifiersCompanion copyWith({
    Value<String>? entryId,
    Value<String>? signifierId,
  }) {
    return EntrySignifiersCompanion(
      entryId: entryId ?? this.entryId,
      signifierId: signifierId ?? this.signifierId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entryId.present) {
      map['entry_id'] = Variable<String>(entryId.value);
    }
    if (signifierId.present) {
      map['signifier_id'] = Variable<String>(signifierId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntrySignifiersCompanion(')
          ..write('entryId: $entryId, ')
          ..write('signifierId: $signifierId')
          ..write(')'))
        .toString();
  }
}

class IndexItems extends Table with TableInfo<IndexItems, IndexItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  IndexItems(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _ordinalMeta = const VerificationMeta(
    'ordinal',
  );
  late final GeneratedColumn<int> ordinal = GeneratedColumn<int>(
    'ordinal',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL UNIQUE CHECK (ordinal >= 0)',
  );
  static const VerificationMeta _logIdMeta = const VerificationMeta('logId');
  late final GeneratedColumn<String> logId = GeneratedColumn<String>(
    'log_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'REFERENCES logs(id)ON DELETE RESTRICT',
  );
  static const VerificationMeta _collectionIdMeta = const VerificationMeta(
    'collectionId',
  );
  late final GeneratedColumn<String> collectionId = GeneratedColumn<String>(
    'collection_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'REFERENCES collections(id)ON DELETE RESTRICT',
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (created_at >= 0)',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ordinal,
    logId,
    collectionId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'index_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<IndexItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('ordinal')) {
      context.handle(
        _ordinalMeta,
        ordinal.isAcceptableOrUnknown(data['ordinal']!, _ordinalMeta),
      );
    } else if (isInserting) {
      context.missing(_ordinalMeta);
    }
    if (data.containsKey('log_id')) {
      context.handle(
        _logIdMeta,
        logId.isAcceptableOrUnknown(data['log_id']!, _logIdMeta),
      );
    }
    if (data.containsKey('collection_id')) {
      context.handle(
        _collectionIdMeta,
        collectionId.isAcceptableOrUnknown(
          data['collection_id']!,
          _collectionIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  IndexItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IndexItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ordinal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ordinal'],
      )!,
      logId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}log_id'],
      ),
      collectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collection_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  IndexItems createAlias(String alias) {
    return IndexItems(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'CHECK((log_id IS NOT NULL AND collection_id IS NULL)OR(log_id IS NULL AND collection_id IS NOT NULL))',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class IndexItem extends DataClass implements Insertable<IndexItem> {
  final String id;
  final int ordinal;
  final String? logId;
  final String? collectionId;
  final int createdAt;
  const IndexItem({
    required this.id,
    required this.ordinal,
    this.logId,
    this.collectionId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['ordinal'] = Variable<int>(ordinal);
    if (!nullToAbsent || logId != null) {
      map['log_id'] = Variable<String>(logId);
    }
    if (!nullToAbsent || collectionId != null) {
      map['collection_id'] = Variable<String>(collectionId);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  IndexItemsCompanion toCompanion(bool nullToAbsent) {
    return IndexItemsCompanion(
      id: Value(id),
      ordinal: Value(ordinal),
      logId: logId == null && nullToAbsent
          ? const Value.absent()
          : Value(logId),
      collectionId: collectionId == null && nullToAbsent
          ? const Value.absent()
          : Value(collectionId),
      createdAt: Value(createdAt),
    );
  }

  factory IndexItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IndexItem(
      id: serializer.fromJson<String>(json['id']),
      ordinal: serializer.fromJson<int>(json['ordinal']),
      logId: serializer.fromJson<String?>(json['log_id']),
      collectionId: serializer.fromJson<String?>(json['collection_id']),
      createdAt: serializer.fromJson<int>(json['created_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ordinal': serializer.toJson<int>(ordinal),
      'log_id': serializer.toJson<String?>(logId),
      'collection_id': serializer.toJson<String?>(collectionId),
      'created_at': serializer.toJson<int>(createdAt),
    };
  }

  IndexItem copyWith({
    String? id,
    int? ordinal,
    Value<String?> logId = const Value.absent(),
    Value<String?> collectionId = const Value.absent(),
    int? createdAt,
  }) => IndexItem(
    id: id ?? this.id,
    ordinal: ordinal ?? this.ordinal,
    logId: logId.present ? logId.value : this.logId,
    collectionId: collectionId.present ? collectionId.value : this.collectionId,
    createdAt: createdAt ?? this.createdAt,
  );
  IndexItem copyWithCompanion(IndexItemsCompanion data) {
    return IndexItem(
      id: data.id.present ? data.id.value : this.id,
      ordinal: data.ordinal.present ? data.ordinal.value : this.ordinal,
      logId: data.logId.present ? data.logId.value : this.logId,
      collectionId: data.collectionId.present
          ? data.collectionId.value
          : this.collectionId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IndexItem(')
          ..write('id: $id, ')
          ..write('ordinal: $ordinal, ')
          ..write('logId: $logId, ')
          ..write('collectionId: $collectionId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, ordinal, logId, collectionId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IndexItem &&
          other.id == this.id &&
          other.ordinal == this.ordinal &&
          other.logId == this.logId &&
          other.collectionId == this.collectionId &&
          other.createdAt == this.createdAt);
}

class IndexItemsCompanion extends UpdateCompanion<IndexItem> {
  final Value<String> id;
  final Value<int> ordinal;
  final Value<String?> logId;
  final Value<String?> collectionId;
  final Value<int> createdAt;
  final Value<int> rowid;
  const IndexItemsCompanion({
    this.id = const Value.absent(),
    this.ordinal = const Value.absent(),
    this.logId = const Value.absent(),
    this.collectionId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IndexItemsCompanion.insert({
    required String id,
    required int ordinal,
    this.logId = const Value.absent(),
    this.collectionId = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ordinal = Value(ordinal),
       createdAt = Value(createdAt);
  static Insertable<IndexItem> custom({
    Expression<String>? id,
    Expression<int>? ordinal,
    Expression<String>? logId,
    Expression<String>? collectionId,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ordinal != null) 'ordinal': ordinal,
      if (logId != null) 'log_id': logId,
      if (collectionId != null) 'collection_id': collectionId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IndexItemsCompanion copyWith({
    Value<String>? id,
    Value<int>? ordinal,
    Value<String?>? logId,
    Value<String?>? collectionId,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return IndexItemsCompanion(
      id: id ?? this.id,
      ordinal: ordinal ?? this.ordinal,
      logId: logId ?? this.logId,
      collectionId: collectionId ?? this.collectionId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ordinal.present) {
      map['ordinal'] = Variable<int>(ordinal.value);
    }
    if (logId.present) {
      map['log_id'] = Variable<String>(logId.value);
    }
    if (collectionId.present) {
      map['collection_id'] = Variable<String>(collectionId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IndexItemsCompanion(')
          ..write('id: $id, ')
          ..write('ordinal: $ordinal, ')
          ..write('logId: $logId, ')
          ..write('collectionId: $collectionId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$DaymarkDatabase extends GeneratedDatabase {
  _$DaymarkDatabase(QueryExecutor e) : super(e);
  $DaymarkDatabaseManager get managers => $DaymarkDatabaseManager(this);
  late final JournalMetadata journalMetadata = JournalMetadata(this);
  late final Logs logs = Logs(this);
  late final Collections collections = Collections(this);
  late final Entries entries = Entries(this);
  late final EntryPlacements entryPlacements = EntryPlacements(this);
  late final Index entryPlacementsLogOrdinal = Index(
    'entry_placements_log_ordinal',
    'CREATE UNIQUE INDEX entry_placements_log_ordinal ON entry_placements (log_id, ordinal) WHERE log_id IS NOT NULL',
  );
  late final Index entryPlacementsCollectionOrdinal = Index(
    'entry_placements_collection_ordinal',
    'CREATE UNIQUE INDEX entry_placements_collection_ordinal ON entry_placements (collection_id, ordinal) WHERE collection_id IS NOT NULL',
  );
  late final Migrations migrations = Migrations(this);
  late final CollectionReferences collectionReferences = CollectionReferences(
    this,
  );
  late final Signifiers signifiers = Signifiers(this);
  late final EntrySignifiers entrySignifiers = EntrySignifiers(this);
  late final IndexItems indexItems = IndexItems(this);
  late final Index indexItemsLogTarget = Index(
    'index_items_log_target',
    'CREATE UNIQUE INDEX index_items_log_target ON index_items (log_id) WHERE log_id IS NOT NULL',
  );
  late final Index indexItemsCollectionTarget = Index(
    'index_items_collection_target',
    'CREATE UNIQUE INDEX index_items_collection_target ON index_items (collection_id) WHERE collection_id IS NOT NULL',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    journalMetadata,
    logs,
    collections,
    entries,
    entryPlacements,
    entryPlacementsLogOrdinal,
    entryPlacementsCollectionOrdinal,
    migrations,
    collectionReferences,
    signifiers,
    entrySignifiers,
    indexItems,
    indexItemsLogTarget,
    indexItemsCollectionTarget,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'entries',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('entry_placements', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'collections',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('collection_references', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'entries',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('collection_references', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'entries',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('entry_signifiers', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'signifiers',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('entry_signifiers', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $JournalMetadataCreateCompanionBuilder =
    JournalMetadataCompanion Function({
      required String id,
      Value<int> singleton,
      required int createdAt,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $JournalMetadataUpdateCompanionBuilder =
    JournalMetadataCompanion Function({
      Value<String> id,
      Value<int> singleton,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $JournalMetadataFilterComposer
    extends Composer<_$DaymarkDatabase, JournalMetadata> {
  $JournalMetadataFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get singleton => $composableBuilder(
    column: $table.singleton,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $JournalMetadataOrderingComposer
    extends Composer<_$DaymarkDatabase, JournalMetadata> {
  $JournalMetadataOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get singleton => $composableBuilder(
    column: $table.singleton,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $JournalMetadataAnnotationComposer
    extends Composer<_$DaymarkDatabase, JournalMetadata> {
  $JournalMetadataAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get singleton =>
      $composableBuilder(column: $table.singleton, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $JournalMetadataTableManager
    extends
        RootTableManager<
          _$DaymarkDatabase,
          JournalMetadata,
          JournalMetadataData,
          $JournalMetadataFilterComposer,
          $JournalMetadataOrderingComposer,
          $JournalMetadataAnnotationComposer,
          $JournalMetadataCreateCompanionBuilder,
          $JournalMetadataUpdateCompanionBuilder,
          (
            JournalMetadataData,
            BaseReferences<
              _$DaymarkDatabase,
              JournalMetadata,
              JournalMetadataData
            >,
          ),
          JournalMetadataData,
          PrefetchHooks Function()
        > {
  $JournalMetadataTableManager(_$DaymarkDatabase db, JournalMetadata table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $JournalMetadataFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $JournalMetadataOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $JournalMetadataAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> singleton = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JournalMetadataCompanion(
                id: id,
                singleton: singleton,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<int> singleton = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => JournalMetadataCompanion.insert(
                id: id,
                singleton: singleton,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $JournalMetadataProcessedTableManager =
    ProcessedTableManager<
      _$DaymarkDatabase,
      JournalMetadata,
      JournalMetadataData,
      $JournalMetadataFilterComposer,
      $JournalMetadataOrderingComposer,
      $JournalMetadataAnnotationComposer,
      $JournalMetadataCreateCompanionBuilder,
      $JournalMetadataUpdateCompanionBuilder,
      (
        JournalMetadataData,
        BaseReferences<_$DaymarkDatabase, JournalMetadata, JournalMetadataData>,
      ),
      JournalMetadataData,
      PrefetchHooks Function()
    >;
typedef $LogsCreateCompanionBuilder = LogsCompanion Function({
  required String id,
  required String kind,
  required String periodStart,
  required int createdAt,
  Value<int> rowid,
});
typedef $LogsUpdateCompanionBuilder = LogsCompanion Function({
  Value<String> id,
  Value<String> kind,
  Value<String> periodStart,
  Value<int> createdAt,
  Value<int> rowid,
});

final class $LogsReferences
    extends BaseReferences<_$DaymarkDatabase, Logs, Log> {
  $LogsReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<EntryPlacements, List<EntryPlacement>>
  _entryPlacementsRefsTable(_$DaymarkDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.entryPlacements,
        aliasName: 'logs__id__entry_placements__log_id',
      );

  $EntryPlacementsProcessedTableManager get entryPlacementsRefs {
    final manager = $EntryPlacementsTableManager(
      $_db,
      $_db.entryPlacements,
    ).filter((f) => f.logId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _entryPlacementsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<IndexItems, List<IndexItem>> _indexItemsRefsTable(
    _$DaymarkDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.indexItems,
    aliasName: 'logs__id__index_items__log_id',
  );

  $IndexItemsProcessedTableManager get indexItemsRefs {
    final manager = $IndexItemsTableManager(
      $_db,
      $_db.indexItems,
    ).filter((f) => f.logId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_indexItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $LogsFilterComposer extends Composer<_$DaymarkDatabase, Logs> {
  $LogsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get periodStart => $composableBuilder(
    column: $table.periodStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> entryPlacementsRefs(
    Expression<bool> Function($EntryPlacementsFilterComposer f) f,
  ) {
    final $EntryPlacementsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entryPlacements,
      getReferencedColumn: (t) => t.logId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $EntryPlacementsFilterComposer(
            $db: $db,
            $table: $db.entryPlacements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> indexItemsRefs(
    Expression<bool> Function($IndexItemsFilterComposer f) f,
  ) {
    final $IndexItemsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.indexItems,
      getReferencedColumn: (t) => t.logId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $IndexItemsFilterComposer(
            $db: $db,
            $table: $db.indexItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $LogsOrderingComposer extends Composer<_$DaymarkDatabase, Logs> {
  $LogsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get periodStart => $composableBuilder(
    column: $table.periodStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $LogsAnnotationComposer extends Composer<_$DaymarkDatabase, Logs> {
  $LogsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get periodStart => $composableBuilder(
    column: $table.periodStart,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> entryPlacementsRefs<T extends Object>(
    Expression<T> Function($EntryPlacementsAnnotationComposer a) f,
  ) {
    final $EntryPlacementsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entryPlacements,
      getReferencedColumn: (t) => t.logId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $EntryPlacementsAnnotationComposer(
            $db: $db,
            $table: $db.entryPlacements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> indexItemsRefs<T extends Object>(
    Expression<T> Function($IndexItemsAnnotationComposer a) f,
  ) {
    final $IndexItemsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.indexItems,
      getReferencedColumn: (t) => t.logId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $IndexItemsAnnotationComposer(
            $db: $db,
            $table: $db.indexItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $LogsTableManager
    extends
        RootTableManager<
          _$DaymarkDatabase,
          Logs,
          Log,
          $LogsFilterComposer,
          $LogsOrderingComposer,
          $LogsAnnotationComposer,
          $LogsCreateCompanionBuilder,
          $LogsUpdateCompanionBuilder,
          (Log, $LogsReferences),
          Log,
          PrefetchHooks Function({
            bool entryPlacementsRefs,
            bool indexItemsRefs,
          })
        > {
  $LogsTableManager(_$DaymarkDatabase db, Logs table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $LogsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $LogsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $LogsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> periodStart = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LogsCompanion(
                id: id,
                kind: kind,
                periodStart: periodStart,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String kind,
                required String periodStart,
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => LogsCompanion.insert(
                id: id,
                kind: kind,
                periodStart: periodStart,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), $LogsReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback:
              ({entryPlacementsRefs = false, indexItemsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (entryPlacementsRefs) db.entryPlacements,
                    if (indexItemsRefs) db.indexItems,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (entryPlacementsRefs)
                        await $_getPrefetchedData<Log, Logs, EntryPlacement>(
                          currentTable: table,
                          referencedTable: $LogsReferences
                              ._entryPlacementsRefsTable(db),
                          managerFromTypedResult: (p0) => $LogsReferences(
                            db,
                            table,
                            p0,
                          ).entryPlacementsRefs,
                          referencedItemsForCurrentItem: (
                            item,
                            referencedItems,
                          ) => referencedItems.where((e) => e.logId == item.id),
                          typedResults: items,
                        ),
                      if (indexItemsRefs)
                        await $_getPrefetchedData<Log, Logs, IndexItem>(
                          currentTable: table,
                          referencedTable: $LogsReferences._indexItemsRefsTable(
                            db,
                          ),
                          managerFromTypedResult: (p0) =>
                              $LogsReferences(db, table, p0).indexItemsRefs,
                          referencedItemsForCurrentItem: (
                            item,
                            referencedItems,
                          ) => referencedItems.where((e) => e.logId == item.id),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $LogsProcessedTableManager =
    ProcessedTableManager<
      _$DaymarkDatabase,
      Logs,
      Log,
      $LogsFilterComposer,
      $LogsOrderingComposer,
      $LogsAnnotationComposer,
      $LogsCreateCompanionBuilder,
      $LogsUpdateCompanionBuilder,
      (Log, $LogsReferences),
      Log,
      PrefetchHooks Function({bool entryPlacementsRefs, bool indexItemsRefs})
    >;
typedef $CollectionsCreateCompanionBuilder = CollectionsCompanion Function({
  required String id,
  required String title,
  required int createdAt,
  required int updatedAt,
  Value<int> rowid,
});
typedef $CollectionsUpdateCompanionBuilder = CollectionsCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int> rowid,
});

final class $CollectionsReferences
    extends BaseReferences<_$DaymarkDatabase, Collections, Collection> {
  $CollectionsReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<EntryPlacements, List<EntryPlacement>>
  _entryPlacementsRefsTable(_$DaymarkDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.entryPlacements,
        aliasName: 'collections__id__entry_placements__collection_id',
      );

  $EntryPlacementsProcessedTableManager get entryPlacementsRefs {
    final manager = $EntryPlacementsTableManager(
      $_db,
      $_db.entryPlacements,
    ).filter((f) => f.collectionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _entryPlacementsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<CollectionReferences, List<CollectionReference>>
  _collectionReferencesRefsTable(_$DaymarkDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.collectionReferences,
        aliasName: 'collections__id__collection_references__collection_id',
      );

  $CollectionReferencesProcessedTableManager get collectionReferencesRefs {
    final manager = $CollectionReferencesTableManager(
      $_db,
      $_db.collectionReferences,
    ).filter((f) => f.collectionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _collectionReferencesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<IndexItems, List<IndexItem>> _indexItemsRefsTable(
    _$DaymarkDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.indexItems,
    aliasName: 'collections__id__index_items__collection_id',
  );

  $IndexItemsProcessedTableManager get indexItemsRefs {
    final manager = $IndexItemsTableManager(
      $_db,
      $_db.indexItems,
    ).filter((f) => f.collectionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_indexItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $CollectionsFilterComposer
    extends Composer<_$DaymarkDatabase, Collections> {
  $CollectionsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> entryPlacementsRefs(
    Expression<bool> Function($EntryPlacementsFilterComposer f) f,
  ) {
    final $EntryPlacementsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entryPlacements,
      getReferencedColumn: (t) => t.collectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $EntryPlacementsFilterComposer(
            $db: $db,
            $table: $db.entryPlacements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> collectionReferencesRefs(
    Expression<bool> Function($CollectionReferencesFilterComposer f) f,
  ) {
    final $CollectionReferencesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.collectionReferences,
      getReferencedColumn: (t) => t.collectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $CollectionReferencesFilterComposer(
            $db: $db,
            $table: $db.collectionReferences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> indexItemsRefs(
    Expression<bool> Function($IndexItemsFilterComposer f) f,
  ) {
    final $IndexItemsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.indexItems,
      getReferencedColumn: (t) => t.collectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $IndexItemsFilterComposer(
            $db: $db,
            $table: $db.indexItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $CollectionsOrderingComposer
    extends Composer<_$DaymarkDatabase, Collections> {
  $CollectionsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $CollectionsAnnotationComposer
    extends Composer<_$DaymarkDatabase, Collections> {
  $CollectionsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> entryPlacementsRefs<T extends Object>(
    Expression<T> Function($EntryPlacementsAnnotationComposer a) f,
  ) {
    final $EntryPlacementsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entryPlacements,
      getReferencedColumn: (t) => t.collectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $EntryPlacementsAnnotationComposer(
            $db: $db,
            $table: $db.entryPlacements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> collectionReferencesRefs<T extends Object>(
    Expression<T> Function($CollectionReferencesAnnotationComposer a) f,
  ) {
    final $CollectionReferencesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.collectionReferences,
      getReferencedColumn: (t) => t.collectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $CollectionReferencesAnnotationComposer(
            $db: $db,
            $table: $db.collectionReferences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> indexItemsRefs<T extends Object>(
    Expression<T> Function($IndexItemsAnnotationComposer a) f,
  ) {
    final $IndexItemsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.indexItems,
      getReferencedColumn: (t) => t.collectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $IndexItemsAnnotationComposer(
            $db: $db,
            $table: $db.indexItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $CollectionsTableManager
    extends
        RootTableManager<
          _$DaymarkDatabase,
          Collections,
          Collection,
          $CollectionsFilterComposer,
          $CollectionsOrderingComposer,
          $CollectionsAnnotationComposer,
          $CollectionsCreateCompanionBuilder,
          $CollectionsUpdateCompanionBuilder,
          (Collection, $CollectionsReferences),
          Collection,
          PrefetchHooks Function({
            bool entryPlacementsRefs,
            bool collectionReferencesRefs,
            bool indexItemsRefs,
          })
        > {
  $CollectionsTableManager(_$DaymarkDatabase db, Collections table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $CollectionsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $CollectionsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $CollectionsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CollectionsCompanion(
                id: id,
                title: title,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required int createdAt,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CollectionsCompanion.insert(
                id: id,
                title: title,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $CollectionsReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                entryPlacementsRefs = false,
                collectionReferencesRefs = false,
                indexItemsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (entryPlacementsRefs) db.entryPlacements,
                    if (collectionReferencesRefs) db.collectionReferences,
                    if (indexItemsRefs) db.indexItems,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (entryPlacementsRefs)
                        await $_getPrefetchedData<
                          Collection,
                          Collections,
                          EntryPlacement
                        >(
                          currentTable: table,
                          referencedTable: $CollectionsReferences
                              ._entryPlacementsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $CollectionsReferences(
                                db,
                                table,
                                p0,
                              ).entryPlacementsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.collectionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (collectionReferencesRefs)
                        await $_getPrefetchedData<
                          Collection,
                          Collections,
                          CollectionReference
                        >(
                          currentTable: table,
                          referencedTable: $CollectionsReferences
                              ._collectionReferencesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $CollectionsReferences(
                                db,
                                table,
                                p0,
                              ).collectionReferencesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.collectionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (indexItemsRefs)
                        await $_getPrefetchedData<
                          Collection,
                          Collections,
                          IndexItem
                        >(
                          currentTable: table,
                          referencedTable: $CollectionsReferences
                              ._indexItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $CollectionsReferences(
                                db,
                                table,
                                p0,
                              ).indexItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.collectionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $CollectionsProcessedTableManager =
    ProcessedTableManager<
      _$DaymarkDatabase,
      Collections,
      Collection,
      $CollectionsFilterComposer,
      $CollectionsOrderingComposer,
      $CollectionsAnnotationComposer,
      $CollectionsCreateCompanionBuilder,
      $CollectionsUpdateCompanionBuilder,
      (Collection, $CollectionsReferences),
      Collection,
      PrefetchHooks Function({
        bool entryPlacementsRefs,
        bool collectionReferencesRefs,
        bool indexItemsRefs,
      })
    >;
typedef $EntriesCreateCompanionBuilder = EntriesCompanion Function({
  required String id,
  required String entryType,
  Value<String?> taskState,
  required String content,
  required int createdAt,
  required int updatedAt,
  Value<int> rowid,
});
typedef $EntriesUpdateCompanionBuilder = EntriesCompanion Function({
  Value<String> id,
  Value<String> entryType,
  Value<String?> taskState,
  Value<String> content,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int> rowid,
});

final class $EntriesReferences
    extends BaseReferences<_$DaymarkDatabase, Entries, Entry> {
  $EntriesReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<EntryPlacements, List<EntryPlacement>>
  _entryPlacementsRefsTable(_$DaymarkDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.entryPlacements,
        aliasName: 'entries__id__entry_placements__entry_id',
      );

  $EntryPlacementsProcessedTableManager get entryPlacementsRefs {
    final manager = $EntryPlacementsTableManager(
      $_db,
      $_db.entryPlacements,
    ).filter((f) => f.entryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _entryPlacementsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<CollectionReferences, List<CollectionReference>>
  _collectionReferencesRefsTable(_$DaymarkDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.collectionReferences,
        aliasName: 'entries__id__collection_references__entry_id',
      );

  $CollectionReferencesProcessedTableManager get collectionReferencesRefs {
    final manager = $CollectionReferencesTableManager(
      $_db,
      $_db.collectionReferences,
    ).filter((f) => f.entryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _collectionReferencesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<EntrySignifiers, List<EntrySignifier>>
  _entrySignifiersRefsTable(_$DaymarkDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.entrySignifiers,
        aliasName: 'entries__id__entry_signifiers__entry_id',
      );

  $EntrySignifiersProcessedTableManager get entrySignifiersRefs {
    final manager = $EntrySignifiersTableManager(
      $_db,
      $_db.entrySignifiers,
    ).filter((f) => f.entryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _entrySignifiersRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $EntriesFilterComposer extends Composer<_$DaymarkDatabase, Entries> {
  $EntriesFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entryType => $composableBuilder(
    column: $table.entryType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taskState => $composableBuilder(
    column: $table.taskState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> entryPlacementsRefs(
    Expression<bool> Function($EntryPlacementsFilterComposer f) f,
  ) {
    final $EntryPlacementsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entryPlacements,
      getReferencedColumn: (t) => t.entryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $EntryPlacementsFilterComposer(
            $db: $db,
            $table: $db.entryPlacements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> collectionReferencesRefs(
    Expression<bool> Function($CollectionReferencesFilterComposer f) f,
  ) {
    final $CollectionReferencesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.collectionReferences,
      getReferencedColumn: (t) => t.entryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $CollectionReferencesFilterComposer(
            $db: $db,
            $table: $db.collectionReferences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> entrySignifiersRefs(
    Expression<bool> Function($EntrySignifiersFilterComposer f) f,
  ) {
    final $EntrySignifiersFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entrySignifiers,
      getReferencedColumn: (t) => t.entryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $EntrySignifiersFilterComposer(
            $db: $db,
            $table: $db.entrySignifiers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $EntriesOrderingComposer extends Composer<_$DaymarkDatabase, Entries> {
  $EntriesOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entryType => $composableBuilder(
    column: $table.entryType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taskState => $composableBuilder(
    column: $table.taskState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $EntriesAnnotationComposer extends Composer<_$DaymarkDatabase, Entries> {
  $EntriesAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entryType =>
      $composableBuilder(column: $table.entryType, builder: (column) => column);

  GeneratedColumn<String> get taskState =>
      $composableBuilder(column: $table.taskState, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> entryPlacementsRefs<T extends Object>(
    Expression<T> Function($EntryPlacementsAnnotationComposer a) f,
  ) {
    final $EntryPlacementsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entryPlacements,
      getReferencedColumn: (t) => t.entryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $EntryPlacementsAnnotationComposer(
            $db: $db,
            $table: $db.entryPlacements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> collectionReferencesRefs<T extends Object>(
    Expression<T> Function($CollectionReferencesAnnotationComposer a) f,
  ) {
    final $CollectionReferencesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.collectionReferences,
      getReferencedColumn: (t) => t.entryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $CollectionReferencesAnnotationComposer(
            $db: $db,
            $table: $db.collectionReferences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> entrySignifiersRefs<T extends Object>(
    Expression<T> Function($EntrySignifiersAnnotationComposer a) f,
  ) {
    final $EntrySignifiersAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entrySignifiers,
      getReferencedColumn: (t) => t.entryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $EntrySignifiersAnnotationComposer(
            $db: $db,
            $table: $db.entrySignifiers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $EntriesTableManager
    extends
        RootTableManager<
          _$DaymarkDatabase,
          Entries,
          Entry,
          $EntriesFilterComposer,
          $EntriesOrderingComposer,
          $EntriesAnnotationComposer,
          $EntriesCreateCompanionBuilder,
          $EntriesUpdateCompanionBuilder,
          (Entry, $EntriesReferences),
          Entry,
          PrefetchHooks Function({
            bool entryPlacementsRefs,
            bool collectionReferencesRefs,
            bool entrySignifiersRefs,
          })
        > {
  $EntriesTableManager(_$DaymarkDatabase db, Entries table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $EntriesFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $EntriesOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $EntriesAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> entryType = const Value.absent(),
                Value<String?> taskState = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EntriesCompanion(
                id: id,
                entryType: entryType,
                taskState: taskState,
                content: content,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String entryType,
                Value<String?> taskState = const Value.absent(),
                required String content,
                required int createdAt,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => EntriesCompanion.insert(
                id: id,
                entryType: entryType,
                taskState: taskState,
                content: content,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (e.readTable(table), $EntriesReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                entryPlacementsRefs = false,
                collectionReferencesRefs = false,
                entrySignifiersRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (entryPlacementsRefs) db.entryPlacements,
                    if (collectionReferencesRefs) db.collectionReferences,
                    if (entrySignifiersRefs) db.entrySignifiers,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (entryPlacementsRefs)
                        await $_getPrefetchedData<
                          Entry,
                          Entries,
                          EntryPlacement
                        >(
                          currentTable: table,
                          referencedTable: $EntriesReferences
                              ._entryPlacementsRefsTable(db),
                          managerFromTypedResult: (p0) => $EntriesReferences(
                            db,
                            table,
                            p0,
                          ).entryPlacementsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.entryId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (collectionReferencesRefs)
                        await $_getPrefetchedData<
                          Entry,
                          Entries,
                          CollectionReference
                        >(
                          currentTable: table,
                          referencedTable: $EntriesReferences
                              ._collectionReferencesRefsTable(db),
                          managerFromTypedResult: (p0) => $EntriesReferences(
                            db,
                            table,
                            p0,
                          ).collectionReferencesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.entryId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (entrySignifiersRefs)
                        await $_getPrefetchedData<
                          Entry,
                          Entries,
                          EntrySignifier
                        >(
                          currentTable: table,
                          referencedTable: $EntriesReferences
                              ._entrySignifiersRefsTable(db),
                          managerFromTypedResult: (p0) => $EntriesReferences(
                            db,
                            table,
                            p0,
                          ).entrySignifiersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.entryId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $EntriesProcessedTableManager =
    ProcessedTableManager<
      _$DaymarkDatabase,
      Entries,
      Entry,
      $EntriesFilterComposer,
      $EntriesOrderingComposer,
      $EntriesAnnotationComposer,
      $EntriesCreateCompanionBuilder,
      $EntriesUpdateCompanionBuilder,
      (Entry, $EntriesReferences),
      Entry,
      PrefetchHooks Function({
        bool entryPlacementsRefs,
        bool collectionReferencesRefs,
        bool entrySignifiersRefs,
      })
    >;
typedef $EntryPlacementsCreateCompanionBuilder =
    EntryPlacementsCompanion Function({
      required String entryId,
      Value<String?> logId,
      Value<String?> collectionId,
      required int ordinal,
      Value<String?> monthlySection,
      Value<String?> monthlyCalendarDate,
      Value<int> rowid,
    });
typedef $EntryPlacementsUpdateCompanionBuilder =
    EntryPlacementsCompanion Function({
      Value<String> entryId,
      Value<String?> logId,
      Value<String?> collectionId,
      Value<int> ordinal,
      Value<String?> monthlySection,
      Value<String?> monthlyCalendarDate,
      Value<int> rowid,
    });

final class $EntryPlacementsReferences
    extends BaseReferences<_$DaymarkDatabase, EntryPlacements, EntryPlacement> {
  $EntryPlacementsReferences(super.$_db, super.$_table, super.$_typedResult);

  static Entries _entryIdTable(_$DaymarkDatabase db) =>
      db.entries.createAlias('entry_placements__entry_id__entries__id');

  $EntriesProcessedTableManager get entryId {
    final $_column = $_itemColumn<String>('entry_id')!;

    final manager = $EntriesTableManager(
      $_db,
      $_db.entries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_entryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static Logs _logIdTable(_$DaymarkDatabase db) =>
      db.logs.createAlias('entry_placements__log_id__logs__id');

  $LogsProcessedTableManager? get logId {
    final $_column = $_itemColumn<String>('log_id');
    if ($_column == null) return null;
    final manager = $LogsTableManager(
      $_db,
      $_db.logs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_logIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static Collections _collectionIdTable(_$DaymarkDatabase db) => db.collections
      .createAlias('entry_placements__collection_id__collections__id');

  $CollectionsProcessedTableManager? get collectionId {
    final $_column = $_itemColumn<String>('collection_id');
    if ($_column == null) return null;
    final manager = $CollectionsTableManager(
      $_db,
      $_db.collections,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_collectionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $EntryPlacementsFilterComposer
    extends Composer<_$DaymarkDatabase, EntryPlacements> {
  $EntryPlacementsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get ordinal => $composableBuilder(
    column: $table.ordinal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get monthlySection => $composableBuilder(
    column: $table.monthlySection,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get monthlyCalendarDate => $composableBuilder(
    column: $table.monthlyCalendarDate,
    builder: (column) => ColumnFilters(column),
  );

  $EntriesFilterComposer get entryId {
    final $EntriesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $EntriesFilterComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $LogsFilterComposer get logId {
    final $LogsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.logId,
      referencedTable: $db.logs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $LogsFilterComposer(
            $db: $db,
            $table: $db.logs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $CollectionsFilterComposer get collectionId {
    final $CollectionsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $CollectionsFilterComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $EntryPlacementsOrderingComposer
    extends Composer<_$DaymarkDatabase, EntryPlacements> {
  $EntryPlacementsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get ordinal => $composableBuilder(
    column: $table.ordinal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get monthlySection => $composableBuilder(
    column: $table.monthlySection,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get monthlyCalendarDate => $composableBuilder(
    column: $table.monthlyCalendarDate,
    builder: (column) => ColumnOrderings(column),
  );

  $EntriesOrderingComposer get entryId {
    final $EntriesOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $EntriesOrderingComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $LogsOrderingComposer get logId {
    final $LogsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.logId,
      referencedTable: $db.logs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $LogsOrderingComposer(
            $db: $db,
            $table: $db.logs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $CollectionsOrderingComposer get collectionId {
    final $CollectionsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $CollectionsOrderingComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $EntryPlacementsAnnotationComposer
    extends Composer<_$DaymarkDatabase, EntryPlacements> {
  $EntryPlacementsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get ordinal =>
      $composableBuilder(column: $table.ordinal, builder: (column) => column);

  GeneratedColumn<String> get monthlySection => $composableBuilder(
    column: $table.monthlySection,
    builder: (column) => column,
  );

  GeneratedColumn<String> get monthlyCalendarDate => $composableBuilder(
    column: $table.monthlyCalendarDate,
    builder: (column) => column,
  );

  $EntriesAnnotationComposer get entryId {
    final $EntriesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $EntriesAnnotationComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $LogsAnnotationComposer get logId {
    final $LogsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.logId,
      referencedTable: $db.logs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $LogsAnnotationComposer(
            $db: $db,
            $table: $db.logs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $CollectionsAnnotationComposer get collectionId {
    final $CollectionsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $CollectionsAnnotationComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $EntryPlacementsTableManager
    extends
        RootTableManager<
          _$DaymarkDatabase,
          EntryPlacements,
          EntryPlacement,
          $EntryPlacementsFilterComposer,
          $EntryPlacementsOrderingComposer,
          $EntryPlacementsAnnotationComposer,
          $EntryPlacementsCreateCompanionBuilder,
          $EntryPlacementsUpdateCompanionBuilder,
          (EntryPlacement, $EntryPlacementsReferences),
          EntryPlacement,
          PrefetchHooks Function({bool entryId, bool logId, bool collectionId})
        > {
  $EntryPlacementsTableManager(_$DaymarkDatabase db, EntryPlacements table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $EntryPlacementsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $EntryPlacementsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $EntryPlacementsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> entryId = const Value.absent(),
                Value<String?> logId = const Value.absent(),
                Value<String?> collectionId = const Value.absent(),
                Value<int> ordinal = const Value.absent(),
                Value<String?> monthlySection = const Value.absent(),
                Value<String?> monthlyCalendarDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EntryPlacementsCompanion(
                entryId: entryId,
                logId: logId,
                collectionId: collectionId,
                ordinal: ordinal,
                monthlySection: monthlySection,
                monthlyCalendarDate: monthlyCalendarDate,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String entryId,
                Value<String?> logId = const Value.absent(),
                Value<String?> collectionId = const Value.absent(),
                required int ordinal,
                Value<String?> monthlySection = const Value.absent(),
                Value<String?> monthlyCalendarDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EntryPlacementsCompanion.insert(
                entryId: entryId,
                logId: logId,
                collectionId: collectionId,
                ordinal: ordinal,
                monthlySection: monthlySection,
                monthlyCalendarDate: monthlyCalendarDate,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $EntryPlacementsReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({entryId = false, logId = false, collectionId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (entryId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.entryId,
                            referencedTable: $EntryPlacementsReferences
                                ._entryIdTable(db),
                            referencedColumn: $EntryPlacementsReferences
                                ._entryIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (logId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.logId,
                            referencedTable: $EntryPlacementsReferences
                                ._logIdTable(db),
                            referencedColumn: $EntryPlacementsReferences
                                ._logIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (collectionId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.collectionId,
                            referencedTable: $EntryPlacementsReferences
                                ._collectionIdTable(db),
                            referencedColumn: $EntryPlacementsReferences
                                ._collectionIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $EntryPlacementsProcessedTableManager =
    ProcessedTableManager<
      _$DaymarkDatabase,
      EntryPlacements,
      EntryPlacement,
      $EntryPlacementsFilterComposer,
      $EntryPlacementsOrderingComposer,
      $EntryPlacementsAnnotationComposer,
      $EntryPlacementsCreateCompanionBuilder,
      $EntryPlacementsUpdateCompanionBuilder,
      (EntryPlacement, $EntryPlacementsReferences),
      EntryPlacement,
      PrefetchHooks Function({bool entryId, bool logId, bool collectionId})
    >;
typedef $MigrationsCreateCompanionBuilder = MigrationsCompanion Function({
  required String id,
  required String sourceEntryId,
  required String destinationEntryId,
  required String kind,
  required int createdAt,
  Value<int> rowid,
});
typedef $MigrationsUpdateCompanionBuilder = MigrationsCompanion Function({
  Value<String> id,
  Value<String> sourceEntryId,
  Value<String> destinationEntryId,
  Value<String> kind,
  Value<int> createdAt,
  Value<int> rowid,
});

final class $MigrationsReferences
    extends BaseReferences<_$DaymarkDatabase, Migrations, Migration> {
  $MigrationsReferences(super.$_db, super.$_table, super.$_typedResult);

  static Entries _sourceEntryIdTable(_$DaymarkDatabase db) =>
      db.entries.createAlias('migrations__source_entry_id__entries__id');

  $EntriesProcessedTableManager get sourceEntryId {
    final $_column = $_itemColumn<String>('source_entry_id')!;

    final manager = $EntriesTableManager(
      $_db,
      $_db.entries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceEntryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static Entries _destinationEntryIdTable(_$DaymarkDatabase db) =>
      db.entries.createAlias('migrations__destination_entry_id__entries__id');

  $EntriesProcessedTableManager get destinationEntryId {
    final $_column = $_itemColumn<String>('destination_entry_id')!;

    final manager = $EntriesTableManager(
      $_db,
      $_db.entries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_destinationEntryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $MigrationsFilterComposer
    extends Composer<_$DaymarkDatabase, Migrations> {
  $MigrationsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $EntriesFilterComposer get sourceEntryId {
    final $EntriesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceEntryId,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $EntriesFilterComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $EntriesFilterComposer get destinationEntryId {
    final $EntriesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.destinationEntryId,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $EntriesFilterComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $MigrationsOrderingComposer
    extends Composer<_$DaymarkDatabase, Migrations> {
  $MigrationsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $EntriesOrderingComposer get sourceEntryId {
    final $EntriesOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceEntryId,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $EntriesOrderingComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $EntriesOrderingComposer get destinationEntryId {
    final $EntriesOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.destinationEntryId,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $EntriesOrderingComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $MigrationsAnnotationComposer
    extends Composer<_$DaymarkDatabase, Migrations> {
  $MigrationsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $EntriesAnnotationComposer get sourceEntryId {
    final $EntriesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceEntryId,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $EntriesAnnotationComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $EntriesAnnotationComposer get destinationEntryId {
    final $EntriesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.destinationEntryId,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $EntriesAnnotationComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $MigrationsTableManager
    extends
        RootTableManager<
          _$DaymarkDatabase,
          Migrations,
          Migration,
          $MigrationsFilterComposer,
          $MigrationsOrderingComposer,
          $MigrationsAnnotationComposer,
          $MigrationsCreateCompanionBuilder,
          $MigrationsUpdateCompanionBuilder,
          (Migration, $MigrationsReferences),
          Migration,
          PrefetchHooks Function({bool sourceEntryId, bool destinationEntryId})
        > {
  $MigrationsTableManager(_$DaymarkDatabase db, Migrations table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $MigrationsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $MigrationsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $MigrationsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sourceEntryId = const Value.absent(),
                Value<String> destinationEntryId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MigrationsCompanion(
                id: id,
                sourceEntryId: sourceEntryId,
                destinationEntryId: destinationEntryId,
                kind: kind,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sourceEntryId,
                required String destinationEntryId,
                required String kind,
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => MigrationsCompanion.insert(
                id: id,
                sourceEntryId: sourceEntryId,
                destinationEntryId: destinationEntryId,
                kind: kind,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $MigrationsReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({sourceEntryId = false, destinationEntryId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (sourceEntryId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.sourceEntryId,
                            referencedTable: $MigrationsReferences
                                ._sourceEntryIdTable(db),
                            referencedColumn: $MigrationsReferences
                                ._sourceEntryIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (destinationEntryId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.destinationEntryId,
                            referencedTable: $MigrationsReferences
                                ._destinationEntryIdTable(db),
                            referencedColumn: $MigrationsReferences
                                ._destinationEntryIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $MigrationsProcessedTableManager =
    ProcessedTableManager<
      _$DaymarkDatabase,
      Migrations,
      Migration,
      $MigrationsFilterComposer,
      $MigrationsOrderingComposer,
      $MigrationsAnnotationComposer,
      $MigrationsCreateCompanionBuilder,
      $MigrationsUpdateCompanionBuilder,
      (Migration, $MigrationsReferences),
      Migration,
      PrefetchHooks Function({bool sourceEntryId, bool destinationEntryId})
    >;
typedef $CollectionReferencesCreateCompanionBuilder =
    CollectionReferencesCompanion Function({
      required String collectionId,
      required String entryId,
      required int ordinal,
      required int createdAt,
    });
typedef $CollectionReferencesUpdateCompanionBuilder =
    CollectionReferencesCompanion Function({
      Value<String> collectionId,
      Value<String> entryId,
      Value<int> ordinal,
      Value<int> createdAt,
    });

final class $CollectionReferencesReferences
    extends
        BaseReferences<
          _$DaymarkDatabase,
          CollectionReferences,
          CollectionReference
        > {
  $CollectionReferencesReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static Collections _collectionIdTable(_$DaymarkDatabase db) => db.collections
      .createAlias('collection_references__collection_id__collections__id');

  $CollectionsProcessedTableManager get collectionId {
    final $_column = $_itemColumn<String>('collection_id')!;

    final manager = $CollectionsTableManager(
      $_db,
      $_db.collections,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_collectionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static Entries _entryIdTable(_$DaymarkDatabase db) =>
      db.entries.createAlias('collection_references__entry_id__entries__id');

  $EntriesProcessedTableManager get entryId {
    final $_column = $_itemColumn<String>('entry_id')!;

    final manager = $EntriesTableManager(
      $_db,
      $_db.entries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_entryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $CollectionReferencesFilterComposer
    extends Composer<_$DaymarkDatabase, CollectionReferences> {
  $CollectionReferencesFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get ordinal => $composableBuilder(
    column: $table.ordinal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $CollectionsFilterComposer get collectionId {
    final $CollectionsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $CollectionsFilterComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $EntriesFilterComposer get entryId {
    final $EntriesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $EntriesFilterComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $CollectionReferencesOrderingComposer
    extends Composer<_$DaymarkDatabase, CollectionReferences> {
  $CollectionReferencesOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get ordinal => $composableBuilder(
    column: $table.ordinal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $CollectionsOrderingComposer get collectionId {
    final $CollectionsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $CollectionsOrderingComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $EntriesOrderingComposer get entryId {
    final $EntriesOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $EntriesOrderingComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $CollectionReferencesAnnotationComposer
    extends Composer<_$DaymarkDatabase, CollectionReferences> {
  $CollectionReferencesAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get ordinal =>
      $composableBuilder(column: $table.ordinal, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $CollectionsAnnotationComposer get collectionId {
    final $CollectionsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $CollectionsAnnotationComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $EntriesAnnotationComposer get entryId {
    final $EntriesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $EntriesAnnotationComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $CollectionReferencesTableManager
    extends
        RootTableManager<
          _$DaymarkDatabase,
          CollectionReferences,
          CollectionReference,
          $CollectionReferencesFilterComposer,
          $CollectionReferencesOrderingComposer,
          $CollectionReferencesAnnotationComposer,
          $CollectionReferencesCreateCompanionBuilder,
          $CollectionReferencesUpdateCompanionBuilder,
          (CollectionReference, $CollectionReferencesReferences),
          CollectionReference,
          PrefetchHooks Function({bool collectionId, bool entryId})
        > {
  $CollectionReferencesTableManager(
    _$DaymarkDatabase db,
    CollectionReferences table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $CollectionReferencesFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $CollectionReferencesOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $CollectionReferencesAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> collectionId = const Value.absent(),
                Value<String> entryId = const Value.absent(),
                Value<int> ordinal = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
              }) => CollectionReferencesCompanion(
                collectionId: collectionId,
                entryId: entryId,
                ordinal: ordinal,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                required String collectionId,
                required String entryId,
                required int ordinal,
                required int createdAt,
              }) => CollectionReferencesCompanion.insert(
                collectionId: collectionId,
                entryId: entryId,
                ordinal: ordinal,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $CollectionReferencesReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({collectionId = false, entryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (collectionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.collectionId,
                        referencedTable: $CollectionReferencesReferences
                            ._collectionIdTable(db),
                        referencedColumn: $CollectionReferencesReferences
                            ._collectionIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (entryId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.entryId,
                        referencedTable: $CollectionReferencesReferences
                            ._entryIdTable(db),
                        referencedColumn: $CollectionReferencesReferences
                            ._entryIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $CollectionReferencesProcessedTableManager =
    ProcessedTableManager<
      _$DaymarkDatabase,
      CollectionReferences,
      CollectionReference,
      $CollectionReferencesFilterComposer,
      $CollectionReferencesOrderingComposer,
      $CollectionReferencesAnnotationComposer,
      $CollectionReferencesCreateCompanionBuilder,
      $CollectionReferencesUpdateCompanionBuilder,
      (CollectionReference, $CollectionReferencesReferences),
      CollectionReference,
      PrefetchHooks Function({bool collectionId, bool entryId})
    >;
typedef $SignifiersCreateCompanionBuilder = SignifiersCompanion Function({
  required String id,
  required String kind,
  Value<String?> builtinCode,
  Value<String?> customLabel,
  Value<String?> customSymbol,
  required int createdAt,
  Value<int> rowid,
});
typedef $SignifiersUpdateCompanionBuilder = SignifiersCompanion Function({
  Value<String> id,
  Value<String> kind,
  Value<String?> builtinCode,
  Value<String?> customLabel,
  Value<String?> customSymbol,
  Value<int> createdAt,
  Value<int> rowid,
});

final class $SignifiersReferences
    extends BaseReferences<_$DaymarkDatabase, Signifiers, Signifier> {
  $SignifiersReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<EntrySignifiers, List<EntrySignifier>>
  _entrySignifiersRefsTable(_$DaymarkDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.entrySignifiers,
        aliasName: 'signifiers__id__entry_signifiers__signifier_id',
      );

  $EntrySignifiersProcessedTableManager get entrySignifiersRefs {
    final manager = $EntrySignifiersTableManager(
      $_db,
      $_db.entrySignifiers,
    ).filter((f) => f.signifierId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _entrySignifiersRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $SignifiersFilterComposer
    extends Composer<_$DaymarkDatabase, Signifiers> {
  $SignifiersFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get builtinCode => $composableBuilder(
    column: $table.builtinCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customLabel => $composableBuilder(
    column: $table.customLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customSymbol => $composableBuilder(
    column: $table.customSymbol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> entrySignifiersRefs(
    Expression<bool> Function($EntrySignifiersFilterComposer f) f,
  ) {
    final $EntrySignifiersFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entrySignifiers,
      getReferencedColumn: (t) => t.signifierId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $EntrySignifiersFilterComposer(
            $db: $db,
            $table: $db.entrySignifiers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $SignifiersOrderingComposer
    extends Composer<_$DaymarkDatabase, Signifiers> {
  $SignifiersOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get builtinCode => $composableBuilder(
    column: $table.builtinCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customLabel => $composableBuilder(
    column: $table.customLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customSymbol => $composableBuilder(
    column: $table.customSymbol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $SignifiersAnnotationComposer
    extends Composer<_$DaymarkDatabase, Signifiers> {
  $SignifiersAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get builtinCode => $composableBuilder(
    column: $table.builtinCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customLabel => $composableBuilder(
    column: $table.customLabel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customSymbol => $composableBuilder(
    column: $table.customSymbol,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> entrySignifiersRefs<T extends Object>(
    Expression<T> Function($EntrySignifiersAnnotationComposer a) f,
  ) {
    final $EntrySignifiersAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entrySignifiers,
      getReferencedColumn: (t) => t.signifierId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $EntrySignifiersAnnotationComposer(
            $db: $db,
            $table: $db.entrySignifiers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $SignifiersTableManager
    extends
        RootTableManager<
          _$DaymarkDatabase,
          Signifiers,
          Signifier,
          $SignifiersFilterComposer,
          $SignifiersOrderingComposer,
          $SignifiersAnnotationComposer,
          $SignifiersCreateCompanionBuilder,
          $SignifiersUpdateCompanionBuilder,
          (Signifier, $SignifiersReferences),
          Signifier,
          PrefetchHooks Function({bool entrySignifiersRefs})
        > {
  $SignifiersTableManager(_$DaymarkDatabase db, Signifiers table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $SignifiersFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $SignifiersOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $SignifiersAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String?> builtinCode = const Value.absent(),
                Value<String?> customLabel = const Value.absent(),
                Value<String?> customSymbol = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SignifiersCompanion(
                id: id,
                kind: kind,
                builtinCode: builtinCode,
                customLabel: customLabel,
                customSymbol: customSymbol,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String kind,
                Value<String?> builtinCode = const Value.absent(),
                Value<String?> customLabel = const Value.absent(),
                Value<String?> customSymbol = const Value.absent(),
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => SignifiersCompanion.insert(
                id: id,
                kind: kind,
                builtinCode: builtinCode,
                customLabel: customLabel,
                customSymbol: customSymbol,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $SignifiersReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({entrySignifiersRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (entrySignifiersRefs) db.entrySignifiers,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (entrySignifiersRefs)
                    await $_getPrefetchedData<
                      Signifier,
                      Signifiers,
                      EntrySignifier
                    >(
                      currentTable: table,
                      referencedTable: $SignifiersReferences
                          ._entrySignifiersRefsTable(db),
                      managerFromTypedResult: (p0) => $SignifiersReferences(
                        db,
                        table,
                        p0,
                      ).entrySignifiersRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.signifierId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $SignifiersProcessedTableManager =
    ProcessedTableManager<
      _$DaymarkDatabase,
      Signifiers,
      Signifier,
      $SignifiersFilterComposer,
      $SignifiersOrderingComposer,
      $SignifiersAnnotationComposer,
      $SignifiersCreateCompanionBuilder,
      $SignifiersUpdateCompanionBuilder,
      (Signifier, $SignifiersReferences),
      Signifier,
      PrefetchHooks Function({bool entrySignifiersRefs})
    >;
typedef $EntrySignifiersCreateCompanionBuilder =
    EntrySignifiersCompanion Function({
      required String entryId,
      required String signifierId,
    });
typedef $EntrySignifiersUpdateCompanionBuilder =
    EntrySignifiersCompanion Function({
      Value<String> entryId,
      Value<String> signifierId,
    });

final class $EntrySignifiersReferences
    extends BaseReferences<_$DaymarkDatabase, EntrySignifiers, EntrySignifier> {
  $EntrySignifiersReferences(super.$_db, super.$_table, super.$_typedResult);

  static Entries _entryIdTable(_$DaymarkDatabase db) =>
      db.entries.createAlias('entry_signifiers__entry_id__entries__id');

  $EntriesProcessedTableManager get entryId {
    final $_column = $_itemColumn<String>('entry_id')!;

    final manager = $EntriesTableManager(
      $_db,
      $_db.entries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_entryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static Signifiers _signifierIdTable(_$DaymarkDatabase db) => db.signifiers
      .createAlias('entry_signifiers__signifier_id__signifiers__id');

  $SignifiersProcessedTableManager get signifierId {
    final $_column = $_itemColumn<String>('signifier_id')!;

    final manager = $SignifiersTableManager(
      $_db,
      $_db.signifiers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_signifierIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $EntrySignifiersFilterComposer
    extends Composer<_$DaymarkDatabase, EntrySignifiers> {
  $EntrySignifiersFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $EntriesFilterComposer get entryId {
    final $EntriesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $EntriesFilterComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $SignifiersFilterComposer get signifierId {
    final $SignifiersFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.signifierId,
      referencedTable: $db.signifiers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $SignifiersFilterComposer(
            $db: $db,
            $table: $db.signifiers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $EntrySignifiersOrderingComposer
    extends Composer<_$DaymarkDatabase, EntrySignifiers> {
  $EntrySignifiersOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $EntriesOrderingComposer get entryId {
    final $EntriesOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $EntriesOrderingComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $SignifiersOrderingComposer get signifierId {
    final $SignifiersOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.signifierId,
      referencedTable: $db.signifiers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $SignifiersOrderingComposer(
            $db: $db,
            $table: $db.signifiers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $EntrySignifiersAnnotationComposer
    extends Composer<_$DaymarkDatabase, EntrySignifiers> {
  $EntrySignifiersAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $EntriesAnnotationComposer get entryId {
    final $EntriesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $EntriesAnnotationComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $SignifiersAnnotationComposer get signifierId {
    final $SignifiersAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.signifierId,
      referencedTable: $db.signifiers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $SignifiersAnnotationComposer(
            $db: $db,
            $table: $db.signifiers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $EntrySignifiersTableManager
    extends
        RootTableManager<
          _$DaymarkDatabase,
          EntrySignifiers,
          EntrySignifier,
          $EntrySignifiersFilterComposer,
          $EntrySignifiersOrderingComposer,
          $EntrySignifiersAnnotationComposer,
          $EntrySignifiersCreateCompanionBuilder,
          $EntrySignifiersUpdateCompanionBuilder,
          (EntrySignifier, $EntrySignifiersReferences),
          EntrySignifier,
          PrefetchHooks Function({bool entryId, bool signifierId})
        > {
  $EntrySignifiersTableManager(_$DaymarkDatabase db, EntrySignifiers table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $EntrySignifiersFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $EntrySignifiersOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $EntrySignifiersAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> entryId = const Value.absent(),
                Value<String> signifierId = const Value.absent(),
              }) => EntrySignifiersCompanion(
                entryId: entryId,
                signifierId: signifierId,
              ),
          createCompanionCallback:
              ({required String entryId, required String signifierId}) =>
                  EntrySignifiersCompanion.insert(
                    entryId: entryId,
                    signifierId: signifierId,
                  ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $EntrySignifiersReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({entryId = false, signifierId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (entryId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.entryId,
                        referencedTable: $EntrySignifiersReferences
                            ._entryIdTable(db),
                        referencedColumn: $EntrySignifiersReferences
                            ._entryIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (signifierId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.signifierId,
                        referencedTable: $EntrySignifiersReferences
                            ._signifierIdTable(db),
                        referencedColumn: $EntrySignifiersReferences
                            ._signifierIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $EntrySignifiersProcessedTableManager =
    ProcessedTableManager<
      _$DaymarkDatabase,
      EntrySignifiers,
      EntrySignifier,
      $EntrySignifiersFilterComposer,
      $EntrySignifiersOrderingComposer,
      $EntrySignifiersAnnotationComposer,
      $EntrySignifiersCreateCompanionBuilder,
      $EntrySignifiersUpdateCompanionBuilder,
      (EntrySignifier, $EntrySignifiersReferences),
      EntrySignifier,
      PrefetchHooks Function({bool entryId, bool signifierId})
    >;
typedef $IndexItemsCreateCompanionBuilder = IndexItemsCompanion Function({
  required String id,
  required int ordinal,
  Value<String?> logId,
  Value<String?> collectionId,
  required int createdAt,
  Value<int> rowid,
});
typedef $IndexItemsUpdateCompanionBuilder = IndexItemsCompanion Function({
  Value<String> id,
  Value<int> ordinal,
  Value<String?> logId,
  Value<String?> collectionId,
  Value<int> createdAt,
  Value<int> rowid,
});

final class $IndexItemsReferences
    extends BaseReferences<_$DaymarkDatabase, IndexItems, IndexItem> {
  $IndexItemsReferences(super.$_db, super.$_table, super.$_typedResult);

  static Logs _logIdTable(_$DaymarkDatabase db) =>
      db.logs.createAlias('index_items__log_id__logs__id');

  $LogsProcessedTableManager? get logId {
    final $_column = $_itemColumn<String>('log_id');
    if ($_column == null) return null;
    final manager = $LogsTableManager(
      $_db,
      $_db.logs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_logIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static Collections _collectionIdTable(_$DaymarkDatabase db) =>
      db.collections.createAlias('index_items__collection_id__collections__id');

  $CollectionsProcessedTableManager? get collectionId {
    final $_column = $_itemColumn<String>('collection_id');
    if ($_column == null) return null;
    final manager = $CollectionsTableManager(
      $_db,
      $_db.collections,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_collectionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $IndexItemsFilterComposer
    extends Composer<_$DaymarkDatabase, IndexItems> {
  $IndexItemsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ordinal => $composableBuilder(
    column: $table.ordinal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $LogsFilterComposer get logId {
    final $LogsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.logId,
      referencedTable: $db.logs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $LogsFilterComposer(
            $db: $db,
            $table: $db.logs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $CollectionsFilterComposer get collectionId {
    final $CollectionsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $CollectionsFilterComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $IndexItemsOrderingComposer
    extends Composer<_$DaymarkDatabase, IndexItems> {
  $IndexItemsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ordinal => $composableBuilder(
    column: $table.ordinal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $LogsOrderingComposer get logId {
    final $LogsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.logId,
      referencedTable: $db.logs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $LogsOrderingComposer(
            $db: $db,
            $table: $db.logs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $CollectionsOrderingComposer get collectionId {
    final $CollectionsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $CollectionsOrderingComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $IndexItemsAnnotationComposer
    extends Composer<_$DaymarkDatabase, IndexItems> {
  $IndexItemsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get ordinal =>
      $composableBuilder(column: $table.ordinal, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $LogsAnnotationComposer get logId {
    final $LogsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.logId,
      referencedTable: $db.logs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $LogsAnnotationComposer(
            $db: $db,
            $table: $db.logs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $CollectionsAnnotationComposer get collectionId {
    final $CollectionsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $CollectionsAnnotationComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $IndexItemsTableManager
    extends
        RootTableManager<
          _$DaymarkDatabase,
          IndexItems,
          IndexItem,
          $IndexItemsFilterComposer,
          $IndexItemsOrderingComposer,
          $IndexItemsAnnotationComposer,
          $IndexItemsCreateCompanionBuilder,
          $IndexItemsUpdateCompanionBuilder,
          (IndexItem, $IndexItemsReferences),
          IndexItem,
          PrefetchHooks Function({bool logId, bool collectionId})
        > {
  $IndexItemsTableManager(_$DaymarkDatabase db, IndexItems table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $IndexItemsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $IndexItemsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $IndexItemsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> ordinal = const Value.absent(),
                Value<String?> logId = const Value.absent(),
                Value<String?> collectionId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IndexItemsCompanion(
                id: id,
                ordinal: ordinal,
                logId: logId,
                collectionId: collectionId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int ordinal,
                Value<String?> logId = const Value.absent(),
                Value<String?> collectionId = const Value.absent(),
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => IndexItemsCompanion.insert(
                id: id,
                ordinal: ordinal,
                logId: logId,
                collectionId: collectionId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $IndexItemsReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({logId = false, collectionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (logId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.logId,
                        referencedTable: $IndexItemsReferences._logIdTable(db),
                        referencedColumn: $IndexItemsReferences
                            ._logIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (collectionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.collectionId,
                        referencedTable: $IndexItemsReferences
                            ._collectionIdTable(db),
                        referencedColumn: $IndexItemsReferences
                            ._collectionIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $IndexItemsProcessedTableManager =
    ProcessedTableManager<
      _$DaymarkDatabase,
      IndexItems,
      IndexItem,
      $IndexItemsFilterComposer,
      $IndexItemsOrderingComposer,
      $IndexItemsAnnotationComposer,
      $IndexItemsCreateCompanionBuilder,
      $IndexItemsUpdateCompanionBuilder,
      (IndexItem, $IndexItemsReferences),
      IndexItem,
      PrefetchHooks Function({bool logId, bool collectionId})
    >;

class $DaymarkDatabaseManager {
  final _$DaymarkDatabase _db;
  $DaymarkDatabaseManager(this._db);
  $JournalMetadataTableManager get journalMetadata =>
      $JournalMetadataTableManager(_db, _db.journalMetadata);
  $LogsTableManager get logs => $LogsTableManager(_db, _db.logs);
  $CollectionsTableManager get collections =>
      $CollectionsTableManager(_db, _db.collections);
  $EntriesTableManager get entries => $EntriesTableManager(_db, _db.entries);
  $EntryPlacementsTableManager get entryPlacements =>
      $EntryPlacementsTableManager(_db, _db.entryPlacements);
  $MigrationsTableManager get migrations =>
      $MigrationsTableManager(_db, _db.migrations);
  $CollectionReferencesTableManager get collectionReferences =>
      $CollectionReferencesTableManager(_db, _db.collectionReferences);
  $SignifiersTableManager get signifiers =>
      $SignifiersTableManager(_db, _db.signifiers);
  $EntrySignifiersTableManager get entrySignifiers =>
      $EntrySignifiersTableManager(_db, _db.entrySignifiers);
  $IndexItemsTableManager get indexItems =>
      $IndexItemsTableManager(_db, _db.indexItems);
}
