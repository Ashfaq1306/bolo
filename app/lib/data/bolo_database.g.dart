// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bolo_database.dart';

// ignore_for_file: type=lint
class $RemindersTable extends Reminders
    with TableInfo<$RemindersTable, ReminderRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RemindersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerScopeMeta = const VerificationMeta(
    'ownerScope',
  );
  @override
  late final GeneratedColumn<String> ownerScope = GeneratedColumn<String>(
    'owner_scope',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revMeta = const VerificationMeta('rev');
  @override
  late final GeneratedColumn<int> rev = GeneratedColumn<int>(
    'rev',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _lastDeviceIdMeta = const VerificationMeta(
    'lastDeviceId',
  );
  @override
  late final GeneratedColumn<String> lastDeviceId = GeneratedColumn<String>(
    'last_device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(SyncStates.local),
  );
  static const VerificationMeta _serverUpdatedAtMeta = const VerificationMeta(
    'serverUpdatedAt',
  );
  @override
  late final GeneratedColumn<int> serverUpdatedAt = GeneratedColumn<int>(
    'server_updated_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originMeta = const VerificationMeta('origin');
  @override
  late final GeneratedColumn<String> origin = GeneratedColumn<String>(
    'origin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(RecordOrigins.local),
  );
  static const VerificationMeta _schemaVersionMeta = const VerificationMeta(
    'schemaVersion',
  );
  @override
  late final GeneratedColumn<int> schemaVersion = GeneratedColumn<int>(
    'schema_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remindAtMeta = const VerificationMeta(
    'remindAt',
  );
  @override
  late final GeneratedColumn<int> remindAt = GeneratedColumn<int>(
    'remind_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _repeatMeta = const VerificationMeta('repeat');
  @override
  late final GeneratedColumn<String> repeat = GeneratedColumn<String>(
    'repeat',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeZoneMeta = const VerificationMeta(
    'timeZone',
  );
  @override
  late final GeneratedColumn<String> timeZone = GeneratedColumn<String>(
    'time_zone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Asia/Dhaka'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerScope,
    createdAt,
    updatedAt,
    deletedAt,
    rev,
    lastDeviceId,
    syncState,
    serverUpdatedAt,
    origin,
    schemaVersion,
    title,
    remindAt,
    repeat,
    status,
    source,
    timeZone,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminders';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReminderRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_scope')) {
      context.handle(
        _ownerScopeMeta,
        ownerScope.isAcceptableOrUnknown(data['owner_scope']!, _ownerScopeMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerScopeMeta);
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
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('rev')) {
      context.handle(
        _revMeta,
        rev.isAcceptableOrUnknown(data['rev']!, _revMeta),
      );
    }
    if (data.containsKey('last_device_id')) {
      context.handle(
        _lastDeviceIdMeta,
        lastDeviceId.isAcceptableOrUnknown(
          data['last_device_id']!,
          _lastDeviceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastDeviceIdMeta);
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
        _serverUpdatedAtMeta,
        serverUpdatedAt.isAcceptableOrUnknown(
          data['server_updated_at']!,
          _serverUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('origin')) {
      context.handle(
        _originMeta,
        origin.isAcceptableOrUnknown(data['origin']!, _originMeta),
      );
    }
    if (data.containsKey('schema_version')) {
      context.handle(
        _schemaVersionMeta,
        schemaVersion.isAcceptableOrUnknown(
          data['schema_version']!,
          _schemaVersionMeta,
        ),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('remind_at')) {
      context.handle(
        _remindAtMeta,
        remindAt.isAcceptableOrUnknown(data['remind_at']!, _remindAtMeta),
      );
    } else if (isInserting) {
      context.missing(_remindAtMeta);
    }
    if (data.containsKey('repeat')) {
      context.handle(
        _repeatMeta,
        repeat.isAcceptableOrUnknown(data['repeat']!, _repeatMeta),
      );
    } else if (isInserting) {
      context.missing(_repeatMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('time_zone')) {
      context.handle(
        _timeZoneMeta,
        timeZone.isAcceptableOrUnknown(data['time_zone']!, _timeZoneMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReminderRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReminderRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerScope: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_scope'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      rev: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rev'],
      )!,
      lastDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_device_id'],
      )!,
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_updated_at'],
      ),
      origin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin'],
      )!,
      schemaVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}schema_version'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      remindAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}remind_at'],
      )!,
      repeat: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}repeat'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      timeZone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}time_zone'],
      )!,
    );
  }

  @override
  $RemindersTable createAlias(String alias) {
    return $RemindersTable(attachedDatabase, alias);
  }
}

class ReminderRow extends DataClass implements Insertable<ReminderRow> {
  /// Stable text id. Records migrated from Firestore keep their document id.
  final String id;

  /// `device:<deviceId>` for a guest, `account:<uid>` for a registered user.
  final String ownerScope;
  final int createdAt;
  final int updatedAt;

  /// Tombstone: set instead of deleting the row, so sync can propagate it.
  final int? deletedAt;

  /// Bumped on every local change.
  final int rev;
  final String lastDeviceId;

  /// `local` (guest, never syncs), `pending`, `synced`, `conflict`.
  final String syncState;

  /// Firestore `updatedAt` of the copy this row was last reconciled with.
  final int? serverUpdatedAt;

  /// `local`, `migrated` (copied from the old Firestore guest data), `imported`.
  final String origin;
  final int schemaVersion;
  final String title;
  final int remindAt;
  final String repeat;

  /// `pending` or `done`.
  final String status;
  final String source;

  /// IANA zone the user meant the time in.
  final String timeZone;
  const ReminderRow({
    required this.id,
    required this.ownerScope,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.rev,
    required this.lastDeviceId,
    required this.syncState,
    this.serverUpdatedAt,
    required this.origin,
    required this.schemaVersion,
    required this.title,
    required this.remindAt,
    required this.repeat,
    required this.status,
    required this.source,
    required this.timeZone,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_scope'] = Variable<String>(ownerScope);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['rev'] = Variable<int>(rev);
    map['last_device_id'] = Variable<String>(lastDeviceId);
    map['sync_state'] = Variable<String>(syncState);
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt);
    }
    map['origin'] = Variable<String>(origin);
    map['schema_version'] = Variable<int>(schemaVersion);
    map['title'] = Variable<String>(title);
    map['remind_at'] = Variable<int>(remindAt);
    map['repeat'] = Variable<String>(repeat);
    map['status'] = Variable<String>(status);
    map['source'] = Variable<String>(source);
    map['time_zone'] = Variable<String>(timeZone);
    return map;
  }

  RemindersCompanion toCompanion(bool nullToAbsent) {
    return RemindersCompanion(
      id: Value(id),
      ownerScope: Value(ownerScope),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      rev: Value(rev),
      lastDeviceId: Value(lastDeviceId),
      syncState: Value(syncState),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
      origin: Value(origin),
      schemaVersion: Value(schemaVersion),
      title: Value(title),
      remindAt: Value(remindAt),
      repeat: Value(repeat),
      status: Value(status),
      source: Value(source),
      timeZone: Value(timeZone),
    );
  }

  factory ReminderRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReminderRow(
      id: serializer.fromJson<String>(json['id']),
      ownerScope: serializer.fromJson<String>(json['ownerScope']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      rev: serializer.fromJson<int>(json['rev']),
      lastDeviceId: serializer.fromJson<String>(json['lastDeviceId']),
      syncState: serializer.fromJson<String>(json['syncState']),
      serverUpdatedAt: serializer.fromJson<int?>(json['serverUpdatedAt']),
      origin: serializer.fromJson<String>(json['origin']),
      schemaVersion: serializer.fromJson<int>(json['schemaVersion']),
      title: serializer.fromJson<String>(json['title']),
      remindAt: serializer.fromJson<int>(json['remindAt']),
      repeat: serializer.fromJson<String>(json['repeat']),
      status: serializer.fromJson<String>(json['status']),
      source: serializer.fromJson<String>(json['source']),
      timeZone: serializer.fromJson<String>(json['timeZone']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerScope': serializer.toJson<String>(ownerScope),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'rev': serializer.toJson<int>(rev),
      'lastDeviceId': serializer.toJson<String>(lastDeviceId),
      'syncState': serializer.toJson<String>(syncState),
      'serverUpdatedAt': serializer.toJson<int?>(serverUpdatedAt),
      'origin': serializer.toJson<String>(origin),
      'schemaVersion': serializer.toJson<int>(schemaVersion),
      'title': serializer.toJson<String>(title),
      'remindAt': serializer.toJson<int>(remindAt),
      'repeat': serializer.toJson<String>(repeat),
      'status': serializer.toJson<String>(status),
      'source': serializer.toJson<String>(source),
      'timeZone': serializer.toJson<String>(timeZone),
    };
  }

  ReminderRow copyWith({
    String? id,
    String? ownerScope,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    int? rev,
    String? lastDeviceId,
    String? syncState,
    Value<int?> serverUpdatedAt = const Value.absent(),
    String? origin,
    int? schemaVersion,
    String? title,
    int? remindAt,
    String? repeat,
    String? status,
    String? source,
    String? timeZone,
  }) => ReminderRow(
    id: id ?? this.id,
    ownerScope: ownerScope ?? this.ownerScope,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    rev: rev ?? this.rev,
    lastDeviceId: lastDeviceId ?? this.lastDeviceId,
    syncState: syncState ?? this.syncState,
    serverUpdatedAt: serverUpdatedAt.present
        ? serverUpdatedAt.value
        : this.serverUpdatedAt,
    origin: origin ?? this.origin,
    schemaVersion: schemaVersion ?? this.schemaVersion,
    title: title ?? this.title,
    remindAt: remindAt ?? this.remindAt,
    repeat: repeat ?? this.repeat,
    status: status ?? this.status,
    source: source ?? this.source,
    timeZone: timeZone ?? this.timeZone,
  );
  ReminderRow copyWithCompanion(RemindersCompanion data) {
    return ReminderRow(
      id: data.id.present ? data.id.value : this.id,
      ownerScope: data.ownerScope.present
          ? data.ownerScope.value
          : this.ownerScope,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      rev: data.rev.present ? data.rev.value : this.rev,
      lastDeviceId: data.lastDeviceId.present
          ? data.lastDeviceId.value
          : this.lastDeviceId,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
      origin: data.origin.present ? data.origin.value : this.origin,
      schemaVersion: data.schemaVersion.present
          ? data.schemaVersion.value
          : this.schemaVersion,
      title: data.title.present ? data.title.value : this.title,
      remindAt: data.remindAt.present ? data.remindAt.value : this.remindAt,
      repeat: data.repeat.present ? data.repeat.value : this.repeat,
      status: data.status.present ? data.status.value : this.status,
      source: data.source.present ? data.source.value : this.source,
      timeZone: data.timeZone.present ? data.timeZone.value : this.timeZone,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReminderRow(')
          ..write('id: $id, ')
          ..write('ownerScope: $ownerScope, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rev: $rev, ')
          ..write('lastDeviceId: $lastDeviceId, ')
          ..write('syncState: $syncState, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('origin: $origin, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('title: $title, ')
          ..write('remindAt: $remindAt, ')
          ..write('repeat: $repeat, ')
          ..write('status: $status, ')
          ..write('source: $source, ')
          ..write('timeZone: $timeZone')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerScope,
    createdAt,
    updatedAt,
    deletedAt,
    rev,
    lastDeviceId,
    syncState,
    serverUpdatedAt,
    origin,
    schemaVersion,
    title,
    remindAt,
    repeat,
    status,
    source,
    timeZone,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReminderRow &&
          other.id == this.id &&
          other.ownerScope == this.ownerScope &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.rev == this.rev &&
          other.lastDeviceId == this.lastDeviceId &&
          other.syncState == this.syncState &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.origin == this.origin &&
          other.schemaVersion == this.schemaVersion &&
          other.title == this.title &&
          other.remindAt == this.remindAt &&
          other.repeat == this.repeat &&
          other.status == this.status &&
          other.source == this.source &&
          other.timeZone == this.timeZone);
}

class RemindersCompanion extends UpdateCompanion<ReminderRow> {
  final Value<String> id;
  final Value<String> ownerScope;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<int> rev;
  final Value<String> lastDeviceId;
  final Value<String> syncState;
  final Value<int?> serverUpdatedAt;
  final Value<String> origin;
  final Value<int> schemaVersion;
  final Value<String> title;
  final Value<int> remindAt;
  final Value<String> repeat;
  final Value<String> status;
  final Value<String> source;
  final Value<String> timeZone;
  final Value<int> rowid;
  const RemindersCompanion({
    this.id = const Value.absent(),
    this.ownerScope = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rev = const Value.absent(),
    this.lastDeviceId = const Value.absent(),
    this.syncState = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.origin = const Value.absent(),
    this.schemaVersion = const Value.absent(),
    this.title = const Value.absent(),
    this.remindAt = const Value.absent(),
    this.repeat = const Value.absent(),
    this.status = const Value.absent(),
    this.source = const Value.absent(),
    this.timeZone = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RemindersCompanion.insert({
    required String id,
    required String ownerScope,
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.rev = const Value.absent(),
    required String lastDeviceId,
    this.syncState = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.origin = const Value.absent(),
    this.schemaVersion = const Value.absent(),
    required String title,
    required int remindAt,
    required String repeat,
    required String status,
    required String source,
    this.timeZone = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerScope = Value(ownerScope),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       lastDeviceId = Value(lastDeviceId),
       title = Value(title),
       remindAt = Value(remindAt),
       repeat = Value(repeat),
       status = Value(status),
       source = Value(source);
  static Insertable<ReminderRow> custom({
    Expression<String>? id,
    Expression<String>? ownerScope,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? rev,
    Expression<String>? lastDeviceId,
    Expression<String>? syncState,
    Expression<int>? serverUpdatedAt,
    Expression<String>? origin,
    Expression<int>? schemaVersion,
    Expression<String>? title,
    Expression<int>? remindAt,
    Expression<String>? repeat,
    Expression<String>? status,
    Expression<String>? source,
    Expression<String>? timeZone,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerScope != null) 'owner_scope': ownerScope,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rev != null) 'rev': rev,
      if (lastDeviceId != null) 'last_device_id': lastDeviceId,
      if (syncState != null) 'sync_state': syncState,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (origin != null) 'origin': origin,
      if (schemaVersion != null) 'schema_version': schemaVersion,
      if (title != null) 'title': title,
      if (remindAt != null) 'remind_at': remindAt,
      if (repeat != null) 'repeat': repeat,
      if (status != null) 'status': status,
      if (source != null) 'source': source,
      if (timeZone != null) 'time_zone': timeZone,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RemindersCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerScope,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<int>? rev,
    Value<String>? lastDeviceId,
    Value<String>? syncState,
    Value<int?>? serverUpdatedAt,
    Value<String>? origin,
    Value<int>? schemaVersion,
    Value<String>? title,
    Value<int>? remindAt,
    Value<String>? repeat,
    Value<String>? status,
    Value<String>? source,
    Value<String>? timeZone,
    Value<int>? rowid,
  }) {
    return RemindersCompanion(
      id: id ?? this.id,
      ownerScope: ownerScope ?? this.ownerScope,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rev: rev ?? this.rev,
      lastDeviceId: lastDeviceId ?? this.lastDeviceId,
      syncState: syncState ?? this.syncState,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      origin: origin ?? this.origin,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      title: title ?? this.title,
      remindAt: remindAt ?? this.remindAt,
      repeat: repeat ?? this.repeat,
      status: status ?? this.status,
      source: source ?? this.source,
      timeZone: timeZone ?? this.timeZone,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerScope.present) {
      map['owner_scope'] = Variable<String>(ownerScope.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (rev.present) {
      map['rev'] = Variable<int>(rev.value);
    }
    if (lastDeviceId.present) {
      map['last_device_id'] = Variable<String>(lastDeviceId.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt.value);
    }
    if (origin.present) {
      map['origin'] = Variable<String>(origin.value);
    }
    if (schemaVersion.present) {
      map['schema_version'] = Variable<int>(schemaVersion.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (remindAt.present) {
      map['remind_at'] = Variable<int>(remindAt.value);
    }
    if (repeat.present) {
      map['repeat'] = Variable<String>(repeat.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (timeZone.present) {
      map['time_zone'] = Variable<String>(timeZone.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RemindersCompanion(')
          ..write('id: $id, ')
          ..write('ownerScope: $ownerScope, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rev: $rev, ')
          ..write('lastDeviceId: $lastDeviceId, ')
          ..write('syncState: $syncState, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('origin: $origin, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('title: $title, ')
          ..write('remindAt: $remindAt, ')
          ..write('repeat: $repeat, ')
          ..write('status: $status, ')
          ..write('source: $source, ')
          ..write('timeZone: $timeZone, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TasksTable extends Tasks with TableInfo<$TasksTable, TaskRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerScopeMeta = const VerificationMeta(
    'ownerScope',
  );
  @override
  late final GeneratedColumn<String> ownerScope = GeneratedColumn<String>(
    'owner_scope',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revMeta = const VerificationMeta('rev');
  @override
  late final GeneratedColumn<int> rev = GeneratedColumn<int>(
    'rev',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _lastDeviceIdMeta = const VerificationMeta(
    'lastDeviceId',
  );
  @override
  late final GeneratedColumn<String> lastDeviceId = GeneratedColumn<String>(
    'last_device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(SyncStates.local),
  );
  static const VerificationMeta _serverUpdatedAtMeta = const VerificationMeta(
    'serverUpdatedAt',
  );
  @override
  late final GeneratedColumn<int> serverUpdatedAt = GeneratedColumn<int>(
    'server_updated_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originMeta = const VerificationMeta('origin');
  @override
  late final GeneratedColumn<String> origin = GeneratedColumn<String>(
    'origin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(RecordOrigins.local),
  );
  static const VerificationMeta _schemaVersionMeta = const VerificationMeta(
    'schemaVersion',
  );
  @override
  late final GeneratedColumn<int> schemaVersion = GeneratedColumn<int>(
    'schema_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueAtMeta = const VerificationMeta('dueAt');
  @override
  late final GeneratedColumn<int> dueAt = GeneratedColumn<int>(
    'due_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remindAtMeta = const VerificationMeta(
    'remindAt',
  );
  @override
  late final GeneratedColumn<int> remindAt = GeneratedColumn<int>(
    'remind_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<String> priority = GeneratedColumn<String>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<int> completedAt = GeneratedColumn<int>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeZoneMeta = const VerificationMeta(
    'timeZone',
  );
  @override
  late final GeneratedColumn<String> timeZone = GeneratedColumn<String>(
    'time_zone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Asia/Dhaka'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerScope,
    createdAt,
    updatedAt,
    deletedAt,
    rev,
    lastDeviceId,
    syncState,
    serverUpdatedAt,
    origin,
    schemaVersion,
    title,
    dueAt,
    remindAt,
    priority,
    status,
    completedAt,
    source,
    timeZone,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaskRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_scope')) {
      context.handle(
        _ownerScopeMeta,
        ownerScope.isAcceptableOrUnknown(data['owner_scope']!, _ownerScopeMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerScopeMeta);
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
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('rev')) {
      context.handle(
        _revMeta,
        rev.isAcceptableOrUnknown(data['rev']!, _revMeta),
      );
    }
    if (data.containsKey('last_device_id')) {
      context.handle(
        _lastDeviceIdMeta,
        lastDeviceId.isAcceptableOrUnknown(
          data['last_device_id']!,
          _lastDeviceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastDeviceIdMeta);
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
        _serverUpdatedAtMeta,
        serverUpdatedAt.isAcceptableOrUnknown(
          data['server_updated_at']!,
          _serverUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('origin')) {
      context.handle(
        _originMeta,
        origin.isAcceptableOrUnknown(data['origin']!, _originMeta),
      );
    }
    if (data.containsKey('schema_version')) {
      context.handle(
        _schemaVersionMeta,
        schemaVersion.isAcceptableOrUnknown(
          data['schema_version']!,
          _schemaVersionMeta,
        ),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('due_at')) {
      context.handle(
        _dueAtMeta,
        dueAt.isAcceptableOrUnknown(data['due_at']!, _dueAtMeta),
      );
    }
    if (data.containsKey('remind_at')) {
      context.handle(
        _remindAtMeta,
        remindAt.isAcceptableOrUnknown(data['remind_at']!, _remindAtMeta),
      );
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    } else if (isInserting) {
      context.missing(_priorityMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('time_zone')) {
      context.handle(
        _timeZoneMeta,
        timeZone.isAcceptableOrUnknown(data['time_zone']!, _timeZoneMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaskRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerScope: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_scope'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      rev: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rev'],
      )!,
      lastDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_device_id'],
      )!,
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_updated_at'],
      ),
      origin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin'],
      )!,
      schemaVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}schema_version'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      dueAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}due_at'],
      ),
      remindAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}remind_at'],
      ),
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}priority'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_at'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      timeZone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}time_zone'],
      )!,
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }
}

class TaskRow extends DataClass implements Insertable<TaskRow> {
  /// Stable text id. Records migrated from Firestore keep their document id.
  final String id;

  /// `device:<deviceId>` for a guest, `account:<uid>` for a registered user.
  final String ownerScope;
  final int createdAt;
  final int updatedAt;

  /// Tombstone: set instead of deleting the row, so sync can propagate it.
  final int? deletedAt;

  /// Bumped on every local change.
  final int rev;
  final String lastDeviceId;

  /// `local` (guest, never syncs), `pending`, `synced`, `conflict`.
  final String syncState;

  /// Firestore `updatedAt` of the copy this row was last reconciled with.
  final int? serverUpdatedAt;

  /// `local`, `migrated` (copied from the old Firestore guest data), `imported`.
  final String origin;
  final int schemaVersion;
  final String title;
  final int? dueAt;
  final int? remindAt;

  /// `normal` or `high`.
  final String priority;

  /// `open` or `done`.
  final String status;
  final int? completedAt;
  final String source;
  final String timeZone;
  const TaskRow({
    required this.id,
    required this.ownerScope,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.rev,
    required this.lastDeviceId,
    required this.syncState,
    this.serverUpdatedAt,
    required this.origin,
    required this.schemaVersion,
    required this.title,
    this.dueAt,
    this.remindAt,
    required this.priority,
    required this.status,
    this.completedAt,
    required this.source,
    required this.timeZone,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_scope'] = Variable<String>(ownerScope);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['rev'] = Variable<int>(rev);
    map['last_device_id'] = Variable<String>(lastDeviceId);
    map['sync_state'] = Variable<String>(syncState);
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt);
    }
    map['origin'] = Variable<String>(origin);
    map['schema_version'] = Variable<int>(schemaVersion);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || dueAt != null) {
      map['due_at'] = Variable<int>(dueAt);
    }
    if (!nullToAbsent || remindAt != null) {
      map['remind_at'] = Variable<int>(remindAt);
    }
    map['priority'] = Variable<String>(priority);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<int>(completedAt);
    }
    map['source'] = Variable<String>(source);
    map['time_zone'] = Variable<String>(timeZone);
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      ownerScope: Value(ownerScope),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      rev: Value(rev),
      lastDeviceId: Value(lastDeviceId),
      syncState: Value(syncState),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
      origin: Value(origin),
      schemaVersion: Value(schemaVersion),
      title: Value(title),
      dueAt: dueAt == null && nullToAbsent
          ? const Value.absent()
          : Value(dueAt),
      remindAt: remindAt == null && nullToAbsent
          ? const Value.absent()
          : Value(remindAt),
      priority: Value(priority),
      status: Value(status),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      source: Value(source),
      timeZone: Value(timeZone),
    );
  }

  factory TaskRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskRow(
      id: serializer.fromJson<String>(json['id']),
      ownerScope: serializer.fromJson<String>(json['ownerScope']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      rev: serializer.fromJson<int>(json['rev']),
      lastDeviceId: serializer.fromJson<String>(json['lastDeviceId']),
      syncState: serializer.fromJson<String>(json['syncState']),
      serverUpdatedAt: serializer.fromJson<int?>(json['serverUpdatedAt']),
      origin: serializer.fromJson<String>(json['origin']),
      schemaVersion: serializer.fromJson<int>(json['schemaVersion']),
      title: serializer.fromJson<String>(json['title']),
      dueAt: serializer.fromJson<int?>(json['dueAt']),
      remindAt: serializer.fromJson<int?>(json['remindAt']),
      priority: serializer.fromJson<String>(json['priority']),
      status: serializer.fromJson<String>(json['status']),
      completedAt: serializer.fromJson<int?>(json['completedAt']),
      source: serializer.fromJson<String>(json['source']),
      timeZone: serializer.fromJson<String>(json['timeZone']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerScope': serializer.toJson<String>(ownerScope),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'rev': serializer.toJson<int>(rev),
      'lastDeviceId': serializer.toJson<String>(lastDeviceId),
      'syncState': serializer.toJson<String>(syncState),
      'serverUpdatedAt': serializer.toJson<int?>(serverUpdatedAt),
      'origin': serializer.toJson<String>(origin),
      'schemaVersion': serializer.toJson<int>(schemaVersion),
      'title': serializer.toJson<String>(title),
      'dueAt': serializer.toJson<int?>(dueAt),
      'remindAt': serializer.toJson<int?>(remindAt),
      'priority': serializer.toJson<String>(priority),
      'status': serializer.toJson<String>(status),
      'completedAt': serializer.toJson<int?>(completedAt),
      'source': serializer.toJson<String>(source),
      'timeZone': serializer.toJson<String>(timeZone),
    };
  }

  TaskRow copyWith({
    String? id,
    String? ownerScope,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    int? rev,
    String? lastDeviceId,
    String? syncState,
    Value<int?> serverUpdatedAt = const Value.absent(),
    String? origin,
    int? schemaVersion,
    String? title,
    Value<int?> dueAt = const Value.absent(),
    Value<int?> remindAt = const Value.absent(),
    String? priority,
    String? status,
    Value<int?> completedAt = const Value.absent(),
    String? source,
    String? timeZone,
  }) => TaskRow(
    id: id ?? this.id,
    ownerScope: ownerScope ?? this.ownerScope,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    rev: rev ?? this.rev,
    lastDeviceId: lastDeviceId ?? this.lastDeviceId,
    syncState: syncState ?? this.syncState,
    serverUpdatedAt: serverUpdatedAt.present
        ? serverUpdatedAt.value
        : this.serverUpdatedAt,
    origin: origin ?? this.origin,
    schemaVersion: schemaVersion ?? this.schemaVersion,
    title: title ?? this.title,
    dueAt: dueAt.present ? dueAt.value : this.dueAt,
    remindAt: remindAt.present ? remindAt.value : this.remindAt,
    priority: priority ?? this.priority,
    status: status ?? this.status,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    source: source ?? this.source,
    timeZone: timeZone ?? this.timeZone,
  );
  TaskRow copyWithCompanion(TasksCompanion data) {
    return TaskRow(
      id: data.id.present ? data.id.value : this.id,
      ownerScope: data.ownerScope.present
          ? data.ownerScope.value
          : this.ownerScope,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      rev: data.rev.present ? data.rev.value : this.rev,
      lastDeviceId: data.lastDeviceId.present
          ? data.lastDeviceId.value
          : this.lastDeviceId,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
      origin: data.origin.present ? data.origin.value : this.origin,
      schemaVersion: data.schemaVersion.present
          ? data.schemaVersion.value
          : this.schemaVersion,
      title: data.title.present ? data.title.value : this.title,
      dueAt: data.dueAt.present ? data.dueAt.value : this.dueAt,
      remindAt: data.remindAt.present ? data.remindAt.value : this.remindAt,
      priority: data.priority.present ? data.priority.value : this.priority,
      status: data.status.present ? data.status.value : this.status,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      source: data.source.present ? data.source.value : this.source,
      timeZone: data.timeZone.present ? data.timeZone.value : this.timeZone,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskRow(')
          ..write('id: $id, ')
          ..write('ownerScope: $ownerScope, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rev: $rev, ')
          ..write('lastDeviceId: $lastDeviceId, ')
          ..write('syncState: $syncState, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('origin: $origin, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('title: $title, ')
          ..write('dueAt: $dueAt, ')
          ..write('remindAt: $remindAt, ')
          ..write('priority: $priority, ')
          ..write('status: $status, ')
          ..write('completedAt: $completedAt, ')
          ..write('source: $source, ')
          ..write('timeZone: $timeZone')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerScope,
    createdAt,
    updatedAt,
    deletedAt,
    rev,
    lastDeviceId,
    syncState,
    serverUpdatedAt,
    origin,
    schemaVersion,
    title,
    dueAt,
    remindAt,
    priority,
    status,
    completedAt,
    source,
    timeZone,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskRow &&
          other.id == this.id &&
          other.ownerScope == this.ownerScope &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.rev == this.rev &&
          other.lastDeviceId == this.lastDeviceId &&
          other.syncState == this.syncState &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.origin == this.origin &&
          other.schemaVersion == this.schemaVersion &&
          other.title == this.title &&
          other.dueAt == this.dueAt &&
          other.remindAt == this.remindAt &&
          other.priority == this.priority &&
          other.status == this.status &&
          other.completedAt == this.completedAt &&
          other.source == this.source &&
          other.timeZone == this.timeZone);
}

class TasksCompanion extends UpdateCompanion<TaskRow> {
  final Value<String> id;
  final Value<String> ownerScope;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<int> rev;
  final Value<String> lastDeviceId;
  final Value<String> syncState;
  final Value<int?> serverUpdatedAt;
  final Value<String> origin;
  final Value<int> schemaVersion;
  final Value<String> title;
  final Value<int?> dueAt;
  final Value<int?> remindAt;
  final Value<String> priority;
  final Value<String> status;
  final Value<int?> completedAt;
  final Value<String> source;
  final Value<String> timeZone;
  final Value<int> rowid;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.ownerScope = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rev = const Value.absent(),
    this.lastDeviceId = const Value.absent(),
    this.syncState = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.origin = const Value.absent(),
    this.schemaVersion = const Value.absent(),
    this.title = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.remindAt = const Value.absent(),
    this.priority = const Value.absent(),
    this.status = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.source = const Value.absent(),
    this.timeZone = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TasksCompanion.insert({
    required String id,
    required String ownerScope,
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.rev = const Value.absent(),
    required String lastDeviceId,
    this.syncState = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.origin = const Value.absent(),
    this.schemaVersion = const Value.absent(),
    required String title,
    this.dueAt = const Value.absent(),
    this.remindAt = const Value.absent(),
    required String priority,
    required String status,
    this.completedAt = const Value.absent(),
    required String source,
    this.timeZone = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerScope = Value(ownerScope),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       lastDeviceId = Value(lastDeviceId),
       title = Value(title),
       priority = Value(priority),
       status = Value(status),
       source = Value(source);
  static Insertable<TaskRow> custom({
    Expression<String>? id,
    Expression<String>? ownerScope,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? rev,
    Expression<String>? lastDeviceId,
    Expression<String>? syncState,
    Expression<int>? serverUpdatedAt,
    Expression<String>? origin,
    Expression<int>? schemaVersion,
    Expression<String>? title,
    Expression<int>? dueAt,
    Expression<int>? remindAt,
    Expression<String>? priority,
    Expression<String>? status,
    Expression<int>? completedAt,
    Expression<String>? source,
    Expression<String>? timeZone,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerScope != null) 'owner_scope': ownerScope,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rev != null) 'rev': rev,
      if (lastDeviceId != null) 'last_device_id': lastDeviceId,
      if (syncState != null) 'sync_state': syncState,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (origin != null) 'origin': origin,
      if (schemaVersion != null) 'schema_version': schemaVersion,
      if (title != null) 'title': title,
      if (dueAt != null) 'due_at': dueAt,
      if (remindAt != null) 'remind_at': remindAt,
      if (priority != null) 'priority': priority,
      if (status != null) 'status': status,
      if (completedAt != null) 'completed_at': completedAt,
      if (source != null) 'source': source,
      if (timeZone != null) 'time_zone': timeZone,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TasksCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerScope,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<int>? rev,
    Value<String>? lastDeviceId,
    Value<String>? syncState,
    Value<int?>? serverUpdatedAt,
    Value<String>? origin,
    Value<int>? schemaVersion,
    Value<String>? title,
    Value<int?>? dueAt,
    Value<int?>? remindAt,
    Value<String>? priority,
    Value<String>? status,
    Value<int?>? completedAt,
    Value<String>? source,
    Value<String>? timeZone,
    Value<int>? rowid,
  }) {
    return TasksCompanion(
      id: id ?? this.id,
      ownerScope: ownerScope ?? this.ownerScope,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rev: rev ?? this.rev,
      lastDeviceId: lastDeviceId ?? this.lastDeviceId,
      syncState: syncState ?? this.syncState,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      origin: origin ?? this.origin,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      title: title ?? this.title,
      dueAt: dueAt ?? this.dueAt,
      remindAt: remindAt ?? this.remindAt,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      completedAt: completedAt ?? this.completedAt,
      source: source ?? this.source,
      timeZone: timeZone ?? this.timeZone,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerScope.present) {
      map['owner_scope'] = Variable<String>(ownerScope.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (rev.present) {
      map['rev'] = Variable<int>(rev.value);
    }
    if (lastDeviceId.present) {
      map['last_device_id'] = Variable<String>(lastDeviceId.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt.value);
    }
    if (origin.present) {
      map['origin'] = Variable<String>(origin.value);
    }
    if (schemaVersion.present) {
      map['schema_version'] = Variable<int>(schemaVersion.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (dueAt.present) {
      map['due_at'] = Variable<int>(dueAt.value);
    }
    if (remindAt.present) {
      map['remind_at'] = Variable<int>(remindAt.value);
    }
    if (priority.present) {
      map['priority'] = Variable<String>(priority.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<int>(completedAt.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (timeZone.present) {
      map['time_zone'] = Variable<String>(timeZone.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('ownerScope: $ownerScope, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rev: $rev, ')
          ..write('lastDeviceId: $lastDeviceId, ')
          ..write('syncState: $syncState, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('origin: $origin, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('title: $title, ')
          ..write('dueAt: $dueAt, ')
          ..write('remindAt: $remindAt, ')
          ..write('priority: $priority, ')
          ..write('status: $status, ')
          ..write('completedAt: $completedAt, ')
          ..write('source: $source, ')
          ..write('timeZone: $timeZone, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExpensesTable extends Expenses
    with TableInfo<$ExpensesTable, ExpenseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpensesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerScopeMeta = const VerificationMeta(
    'ownerScope',
  );
  @override
  late final GeneratedColumn<String> ownerScope = GeneratedColumn<String>(
    'owner_scope',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revMeta = const VerificationMeta('rev');
  @override
  late final GeneratedColumn<int> rev = GeneratedColumn<int>(
    'rev',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _lastDeviceIdMeta = const VerificationMeta(
    'lastDeviceId',
  );
  @override
  late final GeneratedColumn<String> lastDeviceId = GeneratedColumn<String>(
    'last_device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(SyncStates.local),
  );
  static const VerificationMeta _serverUpdatedAtMeta = const VerificationMeta(
    'serverUpdatedAt',
  );
  @override
  late final GeneratedColumn<int> serverUpdatedAt = GeneratedColumn<int>(
    'server_updated_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originMeta = const VerificationMeta('origin');
  @override
  late final GeneratedColumn<String> origin = GeneratedColumn<String>(
    'origin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(RecordOrigins.local),
  );
  static const VerificationMeta _schemaVersionMeta = const VerificationMeta(
    'schemaVersion',
  );
  @override
  late final GeneratedColumn<int> schemaVersion = GeneratedColumn<int>(
    'schema_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('BDT'),
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _spentAtMeta = const VerificationMeta(
    'spentAt',
  );
  @override
  late final GeneratedColumn<int> spentAt = GeneratedColumn<int>(
    'spent_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerScope,
    createdAt,
    updatedAt,
    deletedAt,
    rev,
    lastDeviceId,
    syncState,
    serverUpdatedAt,
    origin,
    schemaVersion,
    amountMinor,
    currency,
    category,
    note,
    spentAt,
    source,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expenses';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExpenseRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_scope')) {
      context.handle(
        _ownerScopeMeta,
        ownerScope.isAcceptableOrUnknown(data['owner_scope']!, _ownerScopeMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerScopeMeta);
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
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('rev')) {
      context.handle(
        _revMeta,
        rev.isAcceptableOrUnknown(data['rev']!, _revMeta),
      );
    }
    if (data.containsKey('last_device_id')) {
      context.handle(
        _lastDeviceIdMeta,
        lastDeviceId.isAcceptableOrUnknown(
          data['last_device_id']!,
          _lastDeviceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastDeviceIdMeta);
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
        _serverUpdatedAtMeta,
        serverUpdatedAt.isAcceptableOrUnknown(
          data['server_updated_at']!,
          _serverUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('origin')) {
      context.handle(
        _originMeta,
        origin.isAcceptableOrUnknown(data['origin']!, _originMeta),
      );
    }
    if (data.containsKey('schema_version')) {
      context.handle(
        _schemaVersionMeta,
        schemaVersion.isAcceptableOrUnknown(
          data['schema_version']!,
          _schemaVersionMeta,
        ),
      );
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    } else if (isInserting) {
      context.missing(_noteMeta);
    }
    if (data.containsKey('spent_at')) {
      context.handle(
        _spentAtMeta,
        spentAt.isAcceptableOrUnknown(data['spent_at']!, _spentAtMeta),
      );
    } else if (isInserting) {
      context.missing(_spentAtMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExpenseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExpenseRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerScope: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_scope'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      rev: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rev'],
      )!,
      lastDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_device_id'],
      )!,
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_updated_at'],
      ),
      origin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin'],
      )!,
      schemaVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}schema_version'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      spentAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}spent_at'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
    );
  }

  @override
  $ExpensesTable createAlias(String alias) {
    return $ExpensesTable(attachedDatabase, alias);
  }
}

class ExpenseRow extends DataClass implements Insertable<ExpenseRow> {
  /// Stable text id. Records migrated from Firestore keep their document id.
  final String id;

  /// `device:<deviceId>` for a guest, `account:<uid>` for a registered user.
  final String ownerScope;
  final int createdAt;
  final int updatedAt;

  /// Tombstone: set instead of deleting the row, so sync can propagate it.
  final int? deletedAt;

  /// Bumped on every local change.
  final int rev;
  final String lastDeviceId;

  /// `local` (guest, never syncs), `pending`, `synced`, `conflict`.
  final String syncState;

  /// Firestore `updatedAt` of the copy this row was last reconciled with.
  final int? serverUpdatedAt;

  /// `local`, `migrated` (copied from the old Firestore guest data), `imported`.
  final String origin;
  final int schemaVersion;
  final int amountMinor;
  final String currency;
  final String category;
  final String note;
  final int spentAt;
  final String source;
  const ExpenseRow({
    required this.id,
    required this.ownerScope,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.rev,
    required this.lastDeviceId,
    required this.syncState,
    this.serverUpdatedAt,
    required this.origin,
    required this.schemaVersion,
    required this.amountMinor,
    required this.currency,
    required this.category,
    required this.note,
    required this.spentAt,
    required this.source,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_scope'] = Variable<String>(ownerScope);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['rev'] = Variable<int>(rev);
    map['last_device_id'] = Variable<String>(lastDeviceId);
    map['sync_state'] = Variable<String>(syncState);
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt);
    }
    map['origin'] = Variable<String>(origin);
    map['schema_version'] = Variable<int>(schemaVersion);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['currency'] = Variable<String>(currency);
    map['category'] = Variable<String>(category);
    map['note'] = Variable<String>(note);
    map['spent_at'] = Variable<int>(spentAt);
    map['source'] = Variable<String>(source);
    return map;
  }

  ExpensesCompanion toCompanion(bool nullToAbsent) {
    return ExpensesCompanion(
      id: Value(id),
      ownerScope: Value(ownerScope),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      rev: Value(rev),
      lastDeviceId: Value(lastDeviceId),
      syncState: Value(syncState),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
      origin: Value(origin),
      schemaVersion: Value(schemaVersion),
      amountMinor: Value(amountMinor),
      currency: Value(currency),
      category: Value(category),
      note: Value(note),
      spentAt: Value(spentAt),
      source: Value(source),
    );
  }

  factory ExpenseRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExpenseRow(
      id: serializer.fromJson<String>(json['id']),
      ownerScope: serializer.fromJson<String>(json['ownerScope']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      rev: serializer.fromJson<int>(json['rev']),
      lastDeviceId: serializer.fromJson<String>(json['lastDeviceId']),
      syncState: serializer.fromJson<String>(json['syncState']),
      serverUpdatedAt: serializer.fromJson<int?>(json['serverUpdatedAt']),
      origin: serializer.fromJson<String>(json['origin']),
      schemaVersion: serializer.fromJson<int>(json['schemaVersion']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      currency: serializer.fromJson<String>(json['currency']),
      category: serializer.fromJson<String>(json['category']),
      note: serializer.fromJson<String>(json['note']),
      spentAt: serializer.fromJson<int>(json['spentAt']),
      source: serializer.fromJson<String>(json['source']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerScope': serializer.toJson<String>(ownerScope),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'rev': serializer.toJson<int>(rev),
      'lastDeviceId': serializer.toJson<String>(lastDeviceId),
      'syncState': serializer.toJson<String>(syncState),
      'serverUpdatedAt': serializer.toJson<int?>(serverUpdatedAt),
      'origin': serializer.toJson<String>(origin),
      'schemaVersion': serializer.toJson<int>(schemaVersion),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'currency': serializer.toJson<String>(currency),
      'category': serializer.toJson<String>(category),
      'note': serializer.toJson<String>(note),
      'spentAt': serializer.toJson<int>(spentAt),
      'source': serializer.toJson<String>(source),
    };
  }

  ExpenseRow copyWith({
    String? id,
    String? ownerScope,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    int? rev,
    String? lastDeviceId,
    String? syncState,
    Value<int?> serverUpdatedAt = const Value.absent(),
    String? origin,
    int? schemaVersion,
    int? amountMinor,
    String? currency,
    String? category,
    String? note,
    int? spentAt,
    String? source,
  }) => ExpenseRow(
    id: id ?? this.id,
    ownerScope: ownerScope ?? this.ownerScope,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    rev: rev ?? this.rev,
    lastDeviceId: lastDeviceId ?? this.lastDeviceId,
    syncState: syncState ?? this.syncState,
    serverUpdatedAt: serverUpdatedAt.present
        ? serverUpdatedAt.value
        : this.serverUpdatedAt,
    origin: origin ?? this.origin,
    schemaVersion: schemaVersion ?? this.schemaVersion,
    amountMinor: amountMinor ?? this.amountMinor,
    currency: currency ?? this.currency,
    category: category ?? this.category,
    note: note ?? this.note,
    spentAt: spentAt ?? this.spentAt,
    source: source ?? this.source,
  );
  ExpenseRow copyWithCompanion(ExpensesCompanion data) {
    return ExpenseRow(
      id: data.id.present ? data.id.value : this.id,
      ownerScope: data.ownerScope.present
          ? data.ownerScope.value
          : this.ownerScope,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      rev: data.rev.present ? data.rev.value : this.rev,
      lastDeviceId: data.lastDeviceId.present
          ? data.lastDeviceId.value
          : this.lastDeviceId,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
      origin: data.origin.present ? data.origin.value : this.origin,
      schemaVersion: data.schemaVersion.present
          ? data.schemaVersion.value
          : this.schemaVersion,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      currency: data.currency.present ? data.currency.value : this.currency,
      category: data.category.present ? data.category.value : this.category,
      note: data.note.present ? data.note.value : this.note,
      spentAt: data.spentAt.present ? data.spentAt.value : this.spentAt,
      source: data.source.present ? data.source.value : this.source,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExpenseRow(')
          ..write('id: $id, ')
          ..write('ownerScope: $ownerScope, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rev: $rev, ')
          ..write('lastDeviceId: $lastDeviceId, ')
          ..write('syncState: $syncState, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('origin: $origin, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('category: $category, ')
          ..write('note: $note, ')
          ..write('spentAt: $spentAt, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerScope,
    createdAt,
    updatedAt,
    deletedAt,
    rev,
    lastDeviceId,
    syncState,
    serverUpdatedAt,
    origin,
    schemaVersion,
    amountMinor,
    currency,
    category,
    note,
    spentAt,
    source,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExpenseRow &&
          other.id == this.id &&
          other.ownerScope == this.ownerScope &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.rev == this.rev &&
          other.lastDeviceId == this.lastDeviceId &&
          other.syncState == this.syncState &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.origin == this.origin &&
          other.schemaVersion == this.schemaVersion &&
          other.amountMinor == this.amountMinor &&
          other.currency == this.currency &&
          other.category == this.category &&
          other.note == this.note &&
          other.spentAt == this.spentAt &&
          other.source == this.source);
}

class ExpensesCompanion extends UpdateCompanion<ExpenseRow> {
  final Value<String> id;
  final Value<String> ownerScope;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<int> rev;
  final Value<String> lastDeviceId;
  final Value<String> syncState;
  final Value<int?> serverUpdatedAt;
  final Value<String> origin;
  final Value<int> schemaVersion;
  final Value<int> amountMinor;
  final Value<String> currency;
  final Value<String> category;
  final Value<String> note;
  final Value<int> spentAt;
  final Value<String> source;
  final Value<int> rowid;
  const ExpensesCompanion({
    this.id = const Value.absent(),
    this.ownerScope = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rev = const Value.absent(),
    this.lastDeviceId = const Value.absent(),
    this.syncState = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.origin = const Value.absent(),
    this.schemaVersion = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.category = const Value.absent(),
    this.note = const Value.absent(),
    this.spentAt = const Value.absent(),
    this.source = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExpensesCompanion.insert({
    required String id,
    required String ownerScope,
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.rev = const Value.absent(),
    required String lastDeviceId,
    this.syncState = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.origin = const Value.absent(),
    this.schemaVersion = const Value.absent(),
    required int amountMinor,
    this.currency = const Value.absent(),
    required String category,
    required String note,
    required int spentAt,
    required String source,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerScope = Value(ownerScope),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       lastDeviceId = Value(lastDeviceId),
       amountMinor = Value(amountMinor),
       category = Value(category),
       note = Value(note),
       spentAt = Value(spentAt),
       source = Value(source);
  static Insertable<ExpenseRow> custom({
    Expression<String>? id,
    Expression<String>? ownerScope,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? rev,
    Expression<String>? lastDeviceId,
    Expression<String>? syncState,
    Expression<int>? serverUpdatedAt,
    Expression<String>? origin,
    Expression<int>? schemaVersion,
    Expression<int>? amountMinor,
    Expression<String>? currency,
    Expression<String>? category,
    Expression<String>? note,
    Expression<int>? spentAt,
    Expression<String>? source,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerScope != null) 'owner_scope': ownerScope,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rev != null) 'rev': rev,
      if (lastDeviceId != null) 'last_device_id': lastDeviceId,
      if (syncState != null) 'sync_state': syncState,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (origin != null) 'origin': origin,
      if (schemaVersion != null) 'schema_version': schemaVersion,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (currency != null) 'currency': currency,
      if (category != null) 'category': category,
      if (note != null) 'note': note,
      if (spentAt != null) 'spent_at': spentAt,
      if (source != null) 'source': source,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExpensesCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerScope,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<int>? rev,
    Value<String>? lastDeviceId,
    Value<String>? syncState,
    Value<int?>? serverUpdatedAt,
    Value<String>? origin,
    Value<int>? schemaVersion,
    Value<int>? amountMinor,
    Value<String>? currency,
    Value<String>? category,
    Value<String>? note,
    Value<int>? spentAt,
    Value<String>? source,
    Value<int>? rowid,
  }) {
    return ExpensesCompanion(
      id: id ?? this.id,
      ownerScope: ownerScope ?? this.ownerScope,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rev: rev ?? this.rev,
      lastDeviceId: lastDeviceId ?? this.lastDeviceId,
      syncState: syncState ?? this.syncState,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      origin: origin ?? this.origin,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      amountMinor: amountMinor ?? this.amountMinor,
      currency: currency ?? this.currency,
      category: category ?? this.category,
      note: note ?? this.note,
      spentAt: spentAt ?? this.spentAt,
      source: source ?? this.source,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerScope.present) {
      map['owner_scope'] = Variable<String>(ownerScope.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (rev.present) {
      map['rev'] = Variable<int>(rev.value);
    }
    if (lastDeviceId.present) {
      map['last_device_id'] = Variable<String>(lastDeviceId.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt.value);
    }
    if (origin.present) {
      map['origin'] = Variable<String>(origin.value);
    }
    if (schemaVersion.present) {
      map['schema_version'] = Variable<int>(schemaVersion.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (spentAt.present) {
      map['spent_at'] = Variable<int>(spentAt.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpensesCompanion(')
          ..write('id: $id, ')
          ..write('ownerScope: $ownerScope, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rev: $rev, ')
          ..write('lastDeviceId: $lastDeviceId, ')
          ..write('syncState: $syncState, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('origin: $origin, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('category: $category, ')
          ..write('note: $note, ')
          ..write('spentAt: $spentAt, ')
          ..write('source: $source, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LedgerEntriesTable extends LedgerEntries
    with TableInfo<$LedgerEntriesTable, LedgerRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LedgerEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerScopeMeta = const VerificationMeta(
    'ownerScope',
  );
  @override
  late final GeneratedColumn<String> ownerScope = GeneratedColumn<String>(
    'owner_scope',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revMeta = const VerificationMeta('rev');
  @override
  late final GeneratedColumn<int> rev = GeneratedColumn<int>(
    'rev',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _lastDeviceIdMeta = const VerificationMeta(
    'lastDeviceId',
  );
  @override
  late final GeneratedColumn<String> lastDeviceId = GeneratedColumn<String>(
    'last_device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(SyncStates.local),
  );
  static const VerificationMeta _serverUpdatedAtMeta = const VerificationMeta(
    'serverUpdatedAt',
  );
  @override
  late final GeneratedColumn<int> serverUpdatedAt = GeneratedColumn<int>(
    'server_updated_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originMeta = const VerificationMeta('origin');
  @override
  late final GeneratedColumn<String> origin = GeneratedColumn<String>(
    'origin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(RecordOrigins.local),
  );
  static const VerificationMeta _schemaVersionMeta = const VerificationMeta(
    'schemaVersion',
  );
  @override
  late final GeneratedColumn<int> schemaVersion = GeneratedColumn<int>(
    'schema_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _directionMeta = const VerificationMeta(
    'direction',
  );
  @override
  late final GeneratedColumn<String> direction = GeneratedColumn<String>(
    'direction',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _personMeta = const VerificationMeta('person');
  @override
  late final GeneratedColumn<String> person = GeneratedColumn<String>(
    'person',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('BDT'),
  );
  static const VerificationMeta _dueAtMeta = const VerificationMeta('dueAt');
  @override
  late final GeneratedColumn<int> dueAt = GeneratedColumn<int>(
    'due_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _settledAtMeta = const VerificationMeta(
    'settledAt',
  );
  @override
  late final GeneratedColumn<int> settledAt = GeneratedColumn<int>(
    'settled_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerScope,
    createdAt,
    updatedAt,
    deletedAt,
    rev,
    lastDeviceId,
    syncState,
    serverUpdatedAt,
    origin,
    schemaVersion,
    direction,
    person,
    amountMinor,
    currency,
    dueAt,
    status,
    settledAt,
    note,
    source,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ledger_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<LedgerRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_scope')) {
      context.handle(
        _ownerScopeMeta,
        ownerScope.isAcceptableOrUnknown(data['owner_scope']!, _ownerScopeMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerScopeMeta);
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
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('rev')) {
      context.handle(
        _revMeta,
        rev.isAcceptableOrUnknown(data['rev']!, _revMeta),
      );
    }
    if (data.containsKey('last_device_id')) {
      context.handle(
        _lastDeviceIdMeta,
        lastDeviceId.isAcceptableOrUnknown(
          data['last_device_id']!,
          _lastDeviceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastDeviceIdMeta);
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
        _serverUpdatedAtMeta,
        serverUpdatedAt.isAcceptableOrUnknown(
          data['server_updated_at']!,
          _serverUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('origin')) {
      context.handle(
        _originMeta,
        origin.isAcceptableOrUnknown(data['origin']!, _originMeta),
      );
    }
    if (data.containsKey('schema_version')) {
      context.handle(
        _schemaVersionMeta,
        schemaVersion.isAcceptableOrUnknown(
          data['schema_version']!,
          _schemaVersionMeta,
        ),
      );
    }
    if (data.containsKey('direction')) {
      context.handle(
        _directionMeta,
        direction.isAcceptableOrUnknown(data['direction']!, _directionMeta),
      );
    } else if (isInserting) {
      context.missing(_directionMeta);
    }
    if (data.containsKey('person')) {
      context.handle(
        _personMeta,
        person.isAcceptableOrUnknown(data['person']!, _personMeta),
      );
    } else if (isInserting) {
      context.missing(_personMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('due_at')) {
      context.handle(
        _dueAtMeta,
        dueAt.isAcceptableOrUnknown(data['due_at']!, _dueAtMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('settled_at')) {
      context.handle(
        _settledAtMeta,
        settledAt.isAcceptableOrUnknown(data['settled_at']!, _settledAtMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    } else if (isInserting) {
      context.missing(_noteMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LedgerRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LedgerRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerScope: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_scope'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      rev: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rev'],
      )!,
      lastDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_device_id'],
      )!,
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_updated_at'],
      ),
      origin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin'],
      )!,
      schemaVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}schema_version'],
      )!,
      direction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}direction'],
      )!,
      person: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}person'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      dueAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}due_at'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      settledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}settled_at'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
    );
  }

  @override
  $LedgerEntriesTable createAlias(String alias) {
    return $LedgerEntriesTable(attachedDatabase, alias);
  }
}

class LedgerRow extends DataClass implements Insertable<LedgerRow> {
  /// Stable text id. Records migrated from Firestore keep their document id.
  final String id;

  /// `device:<deviceId>` for a guest, `account:<uid>` for a registered user.
  final String ownerScope;
  final int createdAt;
  final int updatedAt;

  /// Tombstone: set instead of deleting the row, so sync can propagate it.
  final int? deletedAt;

  /// Bumped on every local change.
  final int rev;
  final String lastDeviceId;

  /// `local` (guest, never syncs), `pending`, `synced`, `conflict`.
  final String syncState;

  /// Firestore `updatedAt` of the copy this row was last reconciled with.
  final int? serverUpdatedAt;

  /// `local`, `migrated` (copied from the old Firestore guest data), `imported`.
  final String origin;
  final int schemaVersion;

  /// `receivable` or `payable`.
  final String direction;
  final String person;
  final int amountMinor;
  final String currency;
  final int? dueAt;

  /// `open` or `settled`.
  final String status;
  final int? settledAt;
  final String note;
  final String source;
  const LedgerRow({
    required this.id,
    required this.ownerScope,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.rev,
    required this.lastDeviceId,
    required this.syncState,
    this.serverUpdatedAt,
    required this.origin,
    required this.schemaVersion,
    required this.direction,
    required this.person,
    required this.amountMinor,
    required this.currency,
    this.dueAt,
    required this.status,
    this.settledAt,
    required this.note,
    required this.source,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_scope'] = Variable<String>(ownerScope);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['rev'] = Variable<int>(rev);
    map['last_device_id'] = Variable<String>(lastDeviceId);
    map['sync_state'] = Variable<String>(syncState);
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt);
    }
    map['origin'] = Variable<String>(origin);
    map['schema_version'] = Variable<int>(schemaVersion);
    map['direction'] = Variable<String>(direction);
    map['person'] = Variable<String>(person);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['currency'] = Variable<String>(currency);
    if (!nullToAbsent || dueAt != null) {
      map['due_at'] = Variable<int>(dueAt);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || settledAt != null) {
      map['settled_at'] = Variable<int>(settledAt);
    }
    map['note'] = Variable<String>(note);
    map['source'] = Variable<String>(source);
    return map;
  }

  LedgerEntriesCompanion toCompanion(bool nullToAbsent) {
    return LedgerEntriesCompanion(
      id: Value(id),
      ownerScope: Value(ownerScope),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      rev: Value(rev),
      lastDeviceId: Value(lastDeviceId),
      syncState: Value(syncState),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
      origin: Value(origin),
      schemaVersion: Value(schemaVersion),
      direction: Value(direction),
      person: Value(person),
      amountMinor: Value(amountMinor),
      currency: Value(currency),
      dueAt: dueAt == null && nullToAbsent
          ? const Value.absent()
          : Value(dueAt),
      status: Value(status),
      settledAt: settledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(settledAt),
      note: Value(note),
      source: Value(source),
    );
  }

  factory LedgerRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LedgerRow(
      id: serializer.fromJson<String>(json['id']),
      ownerScope: serializer.fromJson<String>(json['ownerScope']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      rev: serializer.fromJson<int>(json['rev']),
      lastDeviceId: serializer.fromJson<String>(json['lastDeviceId']),
      syncState: serializer.fromJson<String>(json['syncState']),
      serverUpdatedAt: serializer.fromJson<int?>(json['serverUpdatedAt']),
      origin: serializer.fromJson<String>(json['origin']),
      schemaVersion: serializer.fromJson<int>(json['schemaVersion']),
      direction: serializer.fromJson<String>(json['direction']),
      person: serializer.fromJson<String>(json['person']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      currency: serializer.fromJson<String>(json['currency']),
      dueAt: serializer.fromJson<int?>(json['dueAt']),
      status: serializer.fromJson<String>(json['status']),
      settledAt: serializer.fromJson<int?>(json['settledAt']),
      note: serializer.fromJson<String>(json['note']),
      source: serializer.fromJson<String>(json['source']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerScope': serializer.toJson<String>(ownerScope),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'rev': serializer.toJson<int>(rev),
      'lastDeviceId': serializer.toJson<String>(lastDeviceId),
      'syncState': serializer.toJson<String>(syncState),
      'serverUpdatedAt': serializer.toJson<int?>(serverUpdatedAt),
      'origin': serializer.toJson<String>(origin),
      'schemaVersion': serializer.toJson<int>(schemaVersion),
      'direction': serializer.toJson<String>(direction),
      'person': serializer.toJson<String>(person),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'currency': serializer.toJson<String>(currency),
      'dueAt': serializer.toJson<int?>(dueAt),
      'status': serializer.toJson<String>(status),
      'settledAt': serializer.toJson<int?>(settledAt),
      'note': serializer.toJson<String>(note),
      'source': serializer.toJson<String>(source),
    };
  }

  LedgerRow copyWith({
    String? id,
    String? ownerScope,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    int? rev,
    String? lastDeviceId,
    String? syncState,
    Value<int?> serverUpdatedAt = const Value.absent(),
    String? origin,
    int? schemaVersion,
    String? direction,
    String? person,
    int? amountMinor,
    String? currency,
    Value<int?> dueAt = const Value.absent(),
    String? status,
    Value<int?> settledAt = const Value.absent(),
    String? note,
    String? source,
  }) => LedgerRow(
    id: id ?? this.id,
    ownerScope: ownerScope ?? this.ownerScope,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    rev: rev ?? this.rev,
    lastDeviceId: lastDeviceId ?? this.lastDeviceId,
    syncState: syncState ?? this.syncState,
    serverUpdatedAt: serverUpdatedAt.present
        ? serverUpdatedAt.value
        : this.serverUpdatedAt,
    origin: origin ?? this.origin,
    schemaVersion: schemaVersion ?? this.schemaVersion,
    direction: direction ?? this.direction,
    person: person ?? this.person,
    amountMinor: amountMinor ?? this.amountMinor,
    currency: currency ?? this.currency,
    dueAt: dueAt.present ? dueAt.value : this.dueAt,
    status: status ?? this.status,
    settledAt: settledAt.present ? settledAt.value : this.settledAt,
    note: note ?? this.note,
    source: source ?? this.source,
  );
  LedgerRow copyWithCompanion(LedgerEntriesCompanion data) {
    return LedgerRow(
      id: data.id.present ? data.id.value : this.id,
      ownerScope: data.ownerScope.present
          ? data.ownerScope.value
          : this.ownerScope,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      rev: data.rev.present ? data.rev.value : this.rev,
      lastDeviceId: data.lastDeviceId.present
          ? data.lastDeviceId.value
          : this.lastDeviceId,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
      origin: data.origin.present ? data.origin.value : this.origin,
      schemaVersion: data.schemaVersion.present
          ? data.schemaVersion.value
          : this.schemaVersion,
      direction: data.direction.present ? data.direction.value : this.direction,
      person: data.person.present ? data.person.value : this.person,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      currency: data.currency.present ? data.currency.value : this.currency,
      dueAt: data.dueAt.present ? data.dueAt.value : this.dueAt,
      status: data.status.present ? data.status.value : this.status,
      settledAt: data.settledAt.present ? data.settledAt.value : this.settledAt,
      note: data.note.present ? data.note.value : this.note,
      source: data.source.present ? data.source.value : this.source,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LedgerRow(')
          ..write('id: $id, ')
          ..write('ownerScope: $ownerScope, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rev: $rev, ')
          ..write('lastDeviceId: $lastDeviceId, ')
          ..write('syncState: $syncState, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('origin: $origin, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('direction: $direction, ')
          ..write('person: $person, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('dueAt: $dueAt, ')
          ..write('status: $status, ')
          ..write('settledAt: $settledAt, ')
          ..write('note: $note, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerScope,
    createdAt,
    updatedAt,
    deletedAt,
    rev,
    lastDeviceId,
    syncState,
    serverUpdatedAt,
    origin,
    schemaVersion,
    direction,
    person,
    amountMinor,
    currency,
    dueAt,
    status,
    settledAt,
    note,
    source,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LedgerRow &&
          other.id == this.id &&
          other.ownerScope == this.ownerScope &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.rev == this.rev &&
          other.lastDeviceId == this.lastDeviceId &&
          other.syncState == this.syncState &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.origin == this.origin &&
          other.schemaVersion == this.schemaVersion &&
          other.direction == this.direction &&
          other.person == this.person &&
          other.amountMinor == this.amountMinor &&
          other.currency == this.currency &&
          other.dueAt == this.dueAt &&
          other.status == this.status &&
          other.settledAt == this.settledAt &&
          other.note == this.note &&
          other.source == this.source);
}

class LedgerEntriesCompanion extends UpdateCompanion<LedgerRow> {
  final Value<String> id;
  final Value<String> ownerScope;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<int> rev;
  final Value<String> lastDeviceId;
  final Value<String> syncState;
  final Value<int?> serverUpdatedAt;
  final Value<String> origin;
  final Value<int> schemaVersion;
  final Value<String> direction;
  final Value<String> person;
  final Value<int> amountMinor;
  final Value<String> currency;
  final Value<int?> dueAt;
  final Value<String> status;
  final Value<int?> settledAt;
  final Value<String> note;
  final Value<String> source;
  final Value<int> rowid;
  const LedgerEntriesCompanion({
    this.id = const Value.absent(),
    this.ownerScope = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rev = const Value.absent(),
    this.lastDeviceId = const Value.absent(),
    this.syncState = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.origin = const Value.absent(),
    this.schemaVersion = const Value.absent(),
    this.direction = const Value.absent(),
    this.person = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.status = const Value.absent(),
    this.settledAt = const Value.absent(),
    this.note = const Value.absent(),
    this.source = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LedgerEntriesCompanion.insert({
    required String id,
    required String ownerScope,
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.rev = const Value.absent(),
    required String lastDeviceId,
    this.syncState = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.origin = const Value.absent(),
    this.schemaVersion = const Value.absent(),
    required String direction,
    required String person,
    required int amountMinor,
    this.currency = const Value.absent(),
    this.dueAt = const Value.absent(),
    required String status,
    this.settledAt = const Value.absent(),
    required String note,
    required String source,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerScope = Value(ownerScope),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       lastDeviceId = Value(lastDeviceId),
       direction = Value(direction),
       person = Value(person),
       amountMinor = Value(amountMinor),
       status = Value(status),
       note = Value(note),
       source = Value(source);
  static Insertable<LedgerRow> custom({
    Expression<String>? id,
    Expression<String>? ownerScope,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? rev,
    Expression<String>? lastDeviceId,
    Expression<String>? syncState,
    Expression<int>? serverUpdatedAt,
    Expression<String>? origin,
    Expression<int>? schemaVersion,
    Expression<String>? direction,
    Expression<String>? person,
    Expression<int>? amountMinor,
    Expression<String>? currency,
    Expression<int>? dueAt,
    Expression<String>? status,
    Expression<int>? settledAt,
    Expression<String>? note,
    Expression<String>? source,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerScope != null) 'owner_scope': ownerScope,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rev != null) 'rev': rev,
      if (lastDeviceId != null) 'last_device_id': lastDeviceId,
      if (syncState != null) 'sync_state': syncState,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (origin != null) 'origin': origin,
      if (schemaVersion != null) 'schema_version': schemaVersion,
      if (direction != null) 'direction': direction,
      if (person != null) 'person': person,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (currency != null) 'currency': currency,
      if (dueAt != null) 'due_at': dueAt,
      if (status != null) 'status': status,
      if (settledAt != null) 'settled_at': settledAt,
      if (note != null) 'note': note,
      if (source != null) 'source': source,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LedgerEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerScope,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<int>? rev,
    Value<String>? lastDeviceId,
    Value<String>? syncState,
    Value<int?>? serverUpdatedAt,
    Value<String>? origin,
    Value<int>? schemaVersion,
    Value<String>? direction,
    Value<String>? person,
    Value<int>? amountMinor,
    Value<String>? currency,
    Value<int?>? dueAt,
    Value<String>? status,
    Value<int?>? settledAt,
    Value<String>? note,
    Value<String>? source,
    Value<int>? rowid,
  }) {
    return LedgerEntriesCompanion(
      id: id ?? this.id,
      ownerScope: ownerScope ?? this.ownerScope,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rev: rev ?? this.rev,
      lastDeviceId: lastDeviceId ?? this.lastDeviceId,
      syncState: syncState ?? this.syncState,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      origin: origin ?? this.origin,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      direction: direction ?? this.direction,
      person: person ?? this.person,
      amountMinor: amountMinor ?? this.amountMinor,
      currency: currency ?? this.currency,
      dueAt: dueAt ?? this.dueAt,
      status: status ?? this.status,
      settledAt: settledAt ?? this.settledAt,
      note: note ?? this.note,
      source: source ?? this.source,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerScope.present) {
      map['owner_scope'] = Variable<String>(ownerScope.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (rev.present) {
      map['rev'] = Variable<int>(rev.value);
    }
    if (lastDeviceId.present) {
      map['last_device_id'] = Variable<String>(lastDeviceId.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt.value);
    }
    if (origin.present) {
      map['origin'] = Variable<String>(origin.value);
    }
    if (schemaVersion.present) {
      map['schema_version'] = Variable<int>(schemaVersion.value);
    }
    if (direction.present) {
      map['direction'] = Variable<String>(direction.value);
    }
    if (person.present) {
      map['person'] = Variable<String>(person.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (dueAt.present) {
      map['due_at'] = Variable<int>(dueAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (settledAt.present) {
      map['settled_at'] = Variable<int>(settledAt.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LedgerEntriesCompanion(')
          ..write('id: $id, ')
          ..write('ownerScope: $ownerScope, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rev: $rev, ')
          ..write('lastDeviceId: $lastDeviceId, ')
          ..write('syncState: $syncState, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('origin: $origin, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('direction: $direction, ')
          ..write('person: $person, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('dueAt: $dueAt, ')
          ..write('status: $status, ')
          ..write('settledAt: $settledAt, ')
          ..write('note: $note, ')
          ..write('source: $source, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InboxItemsTable extends InboxItems
    with TableInfo<$InboxItemsTable, InboxRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InboxItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerScopeMeta = const VerificationMeta(
    'ownerScope',
  );
  @override
  late final GeneratedColumn<String> ownerScope = GeneratedColumn<String>(
    'owner_scope',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fromVoiceMeta = const VerificationMeta(
    'fromVoice',
  );
  @override
  late final GeneratedColumn<bool> fromVoice = GeneratedColumn<bool>(
    'from_voice',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("from_voice" IN (0, 1))',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerScope,
    body,
    fromVoice,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'inbox_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<InboxRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_scope')) {
      context.handle(
        _ownerScopeMeta,
        ownerScope.isAcceptableOrUnknown(data['owner_scope']!, _ownerScopeMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerScopeMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('from_voice')) {
      context.handle(
        _fromVoiceMeta,
        fromVoice.isAcceptableOrUnknown(data['from_voice']!, _fromVoiceMeta),
      );
    } else if (isInserting) {
      context.missing(_fromVoiceMeta);
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
  InboxRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InboxRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerScope: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_scope'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      fromVoice: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}from_voice'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $InboxItemsTable createAlias(String alias) {
    return $InboxItemsTable(attachedDatabase, alias);
  }
}

class InboxRow extends DataClass implements Insertable<InboxRow> {
  final String id;
  final String ownerScope;
  final String body;
  final bool fromVoice;
  final int createdAt;
  const InboxRow({
    required this.id,
    required this.ownerScope,
    required this.body,
    required this.fromVoice,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_scope'] = Variable<String>(ownerScope);
    map['body'] = Variable<String>(body);
    map['from_voice'] = Variable<bool>(fromVoice);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  InboxItemsCompanion toCompanion(bool nullToAbsent) {
    return InboxItemsCompanion(
      id: Value(id),
      ownerScope: Value(ownerScope),
      body: Value(body),
      fromVoice: Value(fromVoice),
      createdAt: Value(createdAt),
    );
  }

  factory InboxRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InboxRow(
      id: serializer.fromJson<String>(json['id']),
      ownerScope: serializer.fromJson<String>(json['ownerScope']),
      body: serializer.fromJson<String>(json['body']),
      fromVoice: serializer.fromJson<bool>(json['fromVoice']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerScope': serializer.toJson<String>(ownerScope),
      'body': serializer.toJson<String>(body),
      'fromVoice': serializer.toJson<bool>(fromVoice),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  InboxRow copyWith({
    String? id,
    String? ownerScope,
    String? body,
    bool? fromVoice,
    int? createdAt,
  }) => InboxRow(
    id: id ?? this.id,
    ownerScope: ownerScope ?? this.ownerScope,
    body: body ?? this.body,
    fromVoice: fromVoice ?? this.fromVoice,
    createdAt: createdAt ?? this.createdAt,
  );
  InboxRow copyWithCompanion(InboxItemsCompanion data) {
    return InboxRow(
      id: data.id.present ? data.id.value : this.id,
      ownerScope: data.ownerScope.present
          ? data.ownerScope.value
          : this.ownerScope,
      body: data.body.present ? data.body.value : this.body,
      fromVoice: data.fromVoice.present ? data.fromVoice.value : this.fromVoice,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InboxRow(')
          ..write('id: $id, ')
          ..write('ownerScope: $ownerScope, ')
          ..write('body: $body, ')
          ..write('fromVoice: $fromVoice, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, ownerScope, body, fromVoice, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InboxRow &&
          other.id == this.id &&
          other.ownerScope == this.ownerScope &&
          other.body == this.body &&
          other.fromVoice == this.fromVoice &&
          other.createdAt == this.createdAt);
}

class InboxItemsCompanion extends UpdateCompanion<InboxRow> {
  final Value<String> id;
  final Value<String> ownerScope;
  final Value<String> body;
  final Value<bool> fromVoice;
  final Value<int> createdAt;
  final Value<int> rowid;
  const InboxItemsCompanion({
    this.id = const Value.absent(),
    this.ownerScope = const Value.absent(),
    this.body = const Value.absent(),
    this.fromVoice = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InboxItemsCompanion.insert({
    required String id,
    required String ownerScope,
    required String body,
    required bool fromVoice,
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerScope = Value(ownerScope),
       body = Value(body),
       fromVoice = Value(fromVoice),
       createdAt = Value(createdAt);
  static Insertable<InboxRow> custom({
    Expression<String>? id,
    Expression<String>? ownerScope,
    Expression<String>? body,
    Expression<bool>? fromVoice,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerScope != null) 'owner_scope': ownerScope,
      if (body != null) 'body': body,
      if (fromVoice != null) 'from_voice': fromVoice,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InboxItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerScope,
    Value<String>? body,
    Value<bool>? fromVoice,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return InboxItemsCompanion(
      id: id ?? this.id,
      ownerScope: ownerScope ?? this.ownerScope,
      body: body ?? this.body,
      fromVoice: fromVoice ?? this.fromVoice,
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
    if (ownerScope.present) {
      map['owner_scope'] = Variable<String>(ownerScope.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (fromVoice.present) {
      map['from_voice'] = Variable<bool>(fromVoice.value);
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
    return (StringBuffer('InboxItemsCompanion(')
          ..write('id: $id, ')
          ..write('ownerScope: $ownerScope, ')
          ..write('body: $body, ')
          ..write('fromVoice: $fromVoice, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppMetaTable extends AppMeta with TableInfo<$AppMetaTable, AppMetaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppMetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppMetaRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppMetaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppMetaRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppMetaTable createAlias(String alias) {
    return $AppMetaTable(attachedDatabase, alias);
  }
}

class AppMetaRow extends DataClass implements Insertable<AppMetaRow> {
  final String key;
  final String value;
  const AppMetaRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppMetaCompanion toCompanion(bool nullToAbsent) {
    return AppMetaCompanion(key: Value(key), value: Value(value));
  }

  factory AppMetaRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppMetaRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppMetaRow copyWith({String? key, String? value}) =>
      AppMetaRow(key: key ?? this.key, value: value ?? this.value);
  AppMetaRow copyWithCompanion(AppMetaCompanion data) {
    return AppMetaRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppMetaRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppMetaRow &&
          other.key == this.key &&
          other.value == this.value);
}

class AppMetaCompanion extends UpdateCompanion<AppMetaRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppMetaCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppMetaCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppMetaRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppMetaCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppMetaCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppMetaCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MigrationRunsTable extends MigrationRuns
    with TableInfo<$MigrationRunsTable, MigrationRunRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MigrationRunsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<int> startedAt = GeneratedColumn<int>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _countsMeta = const VerificationMeta('counts');
  @override
  late final GeneratedColumn<String> counts = GeneratedColumn<String>(
    'counts',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _errorCodeMeta = const VerificationMeta(
    'errorCode',
  );
  @override
  late final GeneratedColumn<String> errorCode = GeneratedColumn<String>(
    'error_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    state,
    startedAt,
    updatedAt,
    counts,
    errorCode,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'migration_runs';
  @override
  VerificationContext validateIntegrity(
    Insertable<MigrationRunRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('counts')) {
      context.handle(
        _countsMeta,
        counts.isAcceptableOrUnknown(data['counts']!, _countsMeta),
      );
    }
    if (data.containsKey('error_code')) {
      context.handle(
        _errorCodeMeta,
        errorCode.isAcceptableOrUnknown(data['error_code']!, _errorCodeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MigrationRunRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MigrationRunRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}started_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      counts: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}counts'],
      )!,
      errorCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_code'],
      ),
    );
  }

  @override
  $MigrationRunsTable createAlias(String alias) {
    return $MigrationRunsTable(attachedDatabase, alias);
  }
}

class MigrationRunRow extends DataClass implements Insertable<MigrationRunRow> {
  final int id;

  /// started, copied_cache, cache_only, copied_server, verified, done, failed.
  final String state;
  final int startedAt;
  final int updatedAt;

  /// JSON: per-collection counts. Never contains record content.
  final String counts;

  /// Error class only (e.g. `FirebaseException:unavailable`), never a message with user data.
  final String? errorCode;
  const MigrationRunRow({
    required this.id,
    required this.state,
    required this.startedAt,
    required this.updatedAt,
    required this.counts,
    this.errorCode,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['state'] = Variable<String>(state);
    map['started_at'] = Variable<int>(startedAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['counts'] = Variable<String>(counts);
    if (!nullToAbsent || errorCode != null) {
      map['error_code'] = Variable<String>(errorCode);
    }
    return map;
  }

  MigrationRunsCompanion toCompanion(bool nullToAbsent) {
    return MigrationRunsCompanion(
      id: Value(id),
      state: Value(state),
      startedAt: Value(startedAt),
      updatedAt: Value(updatedAt),
      counts: Value(counts),
      errorCode: errorCode == null && nullToAbsent
          ? const Value.absent()
          : Value(errorCode),
    );
  }

  factory MigrationRunRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MigrationRunRow(
      id: serializer.fromJson<int>(json['id']),
      state: serializer.fromJson<String>(json['state']),
      startedAt: serializer.fromJson<int>(json['startedAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      counts: serializer.fromJson<String>(json['counts']),
      errorCode: serializer.fromJson<String?>(json['errorCode']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'state': serializer.toJson<String>(state),
      'startedAt': serializer.toJson<int>(startedAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'counts': serializer.toJson<String>(counts),
      'errorCode': serializer.toJson<String?>(errorCode),
    };
  }

  MigrationRunRow copyWith({
    int? id,
    String? state,
    int? startedAt,
    int? updatedAt,
    String? counts,
    Value<String?> errorCode = const Value.absent(),
  }) => MigrationRunRow(
    id: id ?? this.id,
    state: state ?? this.state,
    startedAt: startedAt ?? this.startedAt,
    updatedAt: updatedAt ?? this.updatedAt,
    counts: counts ?? this.counts,
    errorCode: errorCode.present ? errorCode.value : this.errorCode,
  );
  MigrationRunRow copyWithCompanion(MigrationRunsCompanion data) {
    return MigrationRunRow(
      id: data.id.present ? data.id.value : this.id,
      state: data.state.present ? data.state.value : this.state,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      counts: data.counts.present ? data.counts.value : this.counts,
      errorCode: data.errorCode.present ? data.errorCode.value : this.errorCode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MigrationRunRow(')
          ..write('id: $id, ')
          ..write('state: $state, ')
          ..write('startedAt: $startedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('counts: $counts, ')
          ..write('errorCode: $errorCode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, state, startedAt, updatedAt, counts, errorCode);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MigrationRunRow &&
          other.id == this.id &&
          other.state == this.state &&
          other.startedAt == this.startedAt &&
          other.updatedAt == this.updatedAt &&
          other.counts == this.counts &&
          other.errorCode == this.errorCode);
}

class MigrationRunsCompanion extends UpdateCompanion<MigrationRunRow> {
  final Value<int> id;
  final Value<String> state;
  final Value<int> startedAt;
  final Value<int> updatedAt;
  final Value<String> counts;
  final Value<String?> errorCode;
  const MigrationRunsCompanion({
    this.id = const Value.absent(),
    this.state = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.counts = const Value.absent(),
    this.errorCode = const Value.absent(),
  });
  MigrationRunsCompanion.insert({
    this.id = const Value.absent(),
    required String state,
    required int startedAt,
    required int updatedAt,
    this.counts = const Value.absent(),
    this.errorCode = const Value.absent(),
  }) : state = Value(state),
       startedAt = Value(startedAt),
       updatedAt = Value(updatedAt);
  static Insertable<MigrationRunRow> custom({
    Expression<int>? id,
    Expression<String>? state,
    Expression<int>? startedAt,
    Expression<int>? updatedAt,
    Expression<String>? counts,
    Expression<String>? errorCode,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (state != null) 'state': state,
      if (startedAt != null) 'started_at': startedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (counts != null) 'counts': counts,
      if (errorCode != null) 'error_code': errorCode,
    });
  }

  MigrationRunsCompanion copyWith({
    Value<int>? id,
    Value<String>? state,
    Value<int>? startedAt,
    Value<int>? updatedAt,
    Value<String>? counts,
    Value<String?>? errorCode,
  }) {
    return MigrationRunsCompanion(
      id: id ?? this.id,
      state: state ?? this.state,
      startedAt: startedAt ?? this.startedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      counts: counts ?? this.counts,
      errorCode: errorCode ?? this.errorCode,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<int>(startedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (counts.present) {
      map['counts'] = Variable<String>(counts.value);
    }
    if (errorCode.present) {
      map['error_code'] = Variable<String>(errorCode.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MigrationRunsCompanion(')
          ..write('id: $id, ')
          ..write('state: $state, ')
          ..write('startedAt: $startedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('counts: $counts, ')
          ..write('errorCode: $errorCode')
          ..write(')'))
        .toString();
  }
}

class $MigrationItemsTable extends MigrationItems
    with TableInfo<$MigrationItemsTable, MigrationItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MigrationItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _runIdMeta = const VerificationMeta('runId');
  @override
  late final GeneratedColumn<int> runId = GeneratedColumn<int>(
    'run_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _collectionMeta = const VerificationMeta(
    'collection',
  );
  @override
  late final GeneratedColumn<String> collection = GeneratedColumn<String>(
    'collection',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _checksumMeta = const VerificationMeta(
    'checksum',
  );
  @override
  late final GeneratedColumn<String> checksum = GeneratedColumn<String>(
    'checksum',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [runId, collection, sourceId, checksum];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'migration_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<MigrationItemRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('run_id')) {
      context.handle(
        _runIdMeta,
        runId.isAcceptableOrUnknown(data['run_id']!, _runIdMeta),
      );
    } else if (isInserting) {
      context.missing(_runIdMeta);
    }
    if (data.containsKey('collection')) {
      context.handle(
        _collectionMeta,
        collection.isAcceptableOrUnknown(data['collection']!, _collectionMeta),
      );
    } else if (isInserting) {
      context.missing(_collectionMeta);
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('checksum')) {
      context.handle(
        _checksumMeta,
        checksum.isAcceptableOrUnknown(data['checksum']!, _checksumMeta),
      );
    } else if (isInserting) {
      context.missing(_checksumMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {collection, sourceId};
  @override
  MigrationItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MigrationItemRow(
      runId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}run_id'],
      )!,
      collection: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collection'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      checksum: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}checksum'],
      )!,
    );
  }

  @override
  $MigrationItemsTable createAlias(String alias) {
    return $MigrationItemsTable(attachedDatabase, alias);
  }
}

class MigrationItemRow extends DataClass
    implements Insertable<MigrationItemRow> {
  final int runId;
  final String collection;
  final String sourceId;

  /// Checksum of the copied record's fields, or `kept_local` when a newer
  /// local version was kept instead.
  final String checksum;
  const MigrationItemRow({
    required this.runId,
    required this.collection,
    required this.sourceId,
    required this.checksum,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['run_id'] = Variable<int>(runId);
    map['collection'] = Variable<String>(collection);
    map['source_id'] = Variable<String>(sourceId);
    map['checksum'] = Variable<String>(checksum);
    return map;
  }

  MigrationItemsCompanion toCompanion(bool nullToAbsent) {
    return MigrationItemsCompanion(
      runId: Value(runId),
      collection: Value(collection),
      sourceId: Value(sourceId),
      checksum: Value(checksum),
    );
  }

  factory MigrationItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MigrationItemRow(
      runId: serializer.fromJson<int>(json['runId']),
      collection: serializer.fromJson<String>(json['collection']),
      sourceId: serializer.fromJson<String>(json['sourceId']),
      checksum: serializer.fromJson<String>(json['checksum']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'runId': serializer.toJson<int>(runId),
      'collection': serializer.toJson<String>(collection),
      'sourceId': serializer.toJson<String>(sourceId),
      'checksum': serializer.toJson<String>(checksum),
    };
  }

  MigrationItemRow copyWith({
    int? runId,
    String? collection,
    String? sourceId,
    String? checksum,
  }) => MigrationItemRow(
    runId: runId ?? this.runId,
    collection: collection ?? this.collection,
    sourceId: sourceId ?? this.sourceId,
    checksum: checksum ?? this.checksum,
  );
  MigrationItemRow copyWithCompanion(MigrationItemsCompanion data) {
    return MigrationItemRow(
      runId: data.runId.present ? data.runId.value : this.runId,
      collection: data.collection.present
          ? data.collection.value
          : this.collection,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      checksum: data.checksum.present ? data.checksum.value : this.checksum,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MigrationItemRow(')
          ..write('runId: $runId, ')
          ..write('collection: $collection, ')
          ..write('sourceId: $sourceId, ')
          ..write('checksum: $checksum')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(runId, collection, sourceId, checksum);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MigrationItemRow &&
          other.runId == this.runId &&
          other.collection == this.collection &&
          other.sourceId == this.sourceId &&
          other.checksum == this.checksum);
}

class MigrationItemsCompanion extends UpdateCompanion<MigrationItemRow> {
  final Value<int> runId;
  final Value<String> collection;
  final Value<String> sourceId;
  final Value<String> checksum;
  final Value<int> rowid;
  const MigrationItemsCompanion({
    this.runId = const Value.absent(),
    this.collection = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.checksum = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MigrationItemsCompanion.insert({
    required int runId,
    required String collection,
    required String sourceId,
    required String checksum,
    this.rowid = const Value.absent(),
  }) : runId = Value(runId),
       collection = Value(collection),
       sourceId = Value(sourceId),
       checksum = Value(checksum);
  static Insertable<MigrationItemRow> custom({
    Expression<int>? runId,
    Expression<String>? collection,
    Expression<String>? sourceId,
    Expression<String>? checksum,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (runId != null) 'run_id': runId,
      if (collection != null) 'collection': collection,
      if (sourceId != null) 'source_id': sourceId,
      if (checksum != null) 'checksum': checksum,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MigrationItemsCompanion copyWith({
    Value<int>? runId,
    Value<String>? collection,
    Value<String>? sourceId,
    Value<String>? checksum,
    Value<int>? rowid,
  }) {
    return MigrationItemsCompanion(
      runId: runId ?? this.runId,
      collection: collection ?? this.collection,
      sourceId: sourceId ?? this.sourceId,
      checksum: checksum ?? this.checksum,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (runId.present) {
      map['run_id'] = Variable<int>(runId.value);
    }
    if (collection.present) {
      map['collection'] = Variable<String>(collection.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (checksum.present) {
      map['checksum'] = Variable<String>(checksum.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MigrationItemsCompanion(')
          ..write('runId: $runId, ')
          ..write('collection: $collection, ')
          ..write('sourceId: $sourceId, ')
          ..write('checksum: $checksum, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$BoloDatabase extends GeneratedDatabase {
  _$BoloDatabase(QueryExecutor e) : super(e);
  $BoloDatabaseManager get managers => $BoloDatabaseManager(this);
  late final $RemindersTable reminders = $RemindersTable(this);
  late final $TasksTable tasks = $TasksTable(this);
  late final $ExpensesTable expenses = $ExpensesTable(this);
  late final $LedgerEntriesTable ledgerEntries = $LedgerEntriesTable(this);
  late final $InboxItemsTable inboxItems = $InboxItemsTable(this);
  late final $AppMetaTable appMeta = $AppMetaTable(this);
  late final $MigrationRunsTable migrationRuns = $MigrationRunsTable(this);
  late final $MigrationItemsTable migrationItems = $MigrationItemsTable(this);
  late final Index remindersOwnerStatus = Index(
    'reminders_owner_status',
    'CREATE INDEX reminders_owner_status ON reminders (owner_scope, deleted_at, status)',
  );
  late final Index remindersOwnerTime = Index(
    'reminders_owner_time',
    'CREATE INDEX reminders_owner_time ON reminders (owner_scope, remind_at)',
  );
  late final Index remindersSync = Index(
    'reminders_sync',
    'CREATE INDEX reminders_sync ON reminders (sync_state)',
  );
  late final Index tasksOwnerStatus = Index(
    'tasks_owner_status',
    'CREATE INDEX tasks_owner_status ON tasks (owner_scope, deleted_at, status)',
  );
  late final Index tasksSync = Index(
    'tasks_sync',
    'CREATE INDEX tasks_sync ON tasks (sync_state)',
  );
  late final Index expensesOwnerTime = Index(
    'expenses_owner_time',
    'CREATE INDEX expenses_owner_time ON expenses (owner_scope, spent_at)',
  );
  late final Index expensesSync = Index(
    'expenses_sync',
    'CREATE INDEX expenses_sync ON expenses (sync_state)',
  );
  late final Index ledgerOwnerStatus = Index(
    'ledger_owner_status',
    'CREATE INDEX ledger_owner_status ON ledger_entries (owner_scope, deleted_at, status)',
  );
  late final Index ledgerSync = Index(
    'ledger_sync',
    'CREATE INDEX ledger_sync ON ledger_entries (sync_state)',
  );
  late final Index inboxOwnerTime = Index(
    'inbox_owner_time',
    'CREATE INDEX inbox_owner_time ON inbox_items (owner_scope, created_at)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    reminders,
    tasks,
    expenses,
    ledgerEntries,
    inboxItems,
    appMeta,
    migrationRuns,
    migrationItems,
    remindersOwnerStatus,
    remindersOwnerTime,
    remindersSync,
    tasksOwnerStatus,
    tasksSync,
    expensesOwnerTime,
    expensesSync,
    ledgerOwnerStatus,
    ledgerSync,
    inboxOwnerTime,
  ];
}

typedef $$RemindersTableCreateCompanionBuilder = RemindersCompanion Function({
  required String id,
  required String ownerScope,
  required int createdAt,
  required int updatedAt,
  Value<int?> deletedAt,
  Value<int> rev,
  required String lastDeviceId,
  Value<String> syncState,
  Value<int?> serverUpdatedAt,
  Value<String> origin,
  Value<int> schemaVersion,
  required String title,
  required int remindAt,
  required String repeat,
  required String status,
  required String source,
  Value<String> timeZone,
  Value<int> rowid,
});
typedef $$RemindersTableUpdateCompanionBuilder = RemindersCompanion Function({
  Value<String> id,
  Value<String> ownerScope,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> deletedAt,
  Value<int> rev,
  Value<String> lastDeviceId,
  Value<String> syncState,
  Value<int?> serverUpdatedAt,
  Value<String> origin,
  Value<int> schemaVersion,
  Value<String> title,
  Value<int> remindAt,
  Value<String> repeat,
  Value<String> status,
  Value<String> source,
  Value<String> timeZone,
  Value<int> rowid,
});

class $$RemindersTableFilterComposer
    extends Composer<_$BoloDatabase, $RemindersTable> {
  $$RemindersTableFilterComposer({
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

  ColumnFilters<String> get ownerScope => $composableBuilder(
    column: $table.ownerScope,
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

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rev => $composableBuilder(
    column: $table.rev,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastDeviceId => $composableBuilder(
    column: $table.lastDeviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get remindAt => $composableBuilder(
    column: $table.remindAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get repeat => $composableBuilder(
    column: $table.repeat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timeZone => $composableBuilder(
    column: $table.timeZone,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RemindersTableOrderingComposer
    extends Composer<_$BoloDatabase, $RemindersTable> {
  $$RemindersTableOrderingComposer({
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

  ColumnOrderings<String> get ownerScope => $composableBuilder(
    column: $table.ownerScope,
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

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rev => $composableBuilder(
    column: $table.rev,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastDeviceId => $composableBuilder(
    column: $table.lastDeviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get remindAt => $composableBuilder(
    column: $table.remindAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get repeat => $composableBuilder(
    column: $table.repeat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timeZone => $composableBuilder(
    column: $table.timeZone,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RemindersTableAnnotationComposer
    extends Composer<_$BoloDatabase, $RemindersTable> {
  $$RemindersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerScope => $composableBuilder(
    column: $table.ownerScope,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get rev =>
      $composableBuilder(column: $table.rev, builder: (column) => column);

  GeneratedColumn<String> get lastDeviceId => $composableBuilder(
    column: $table.lastDeviceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);

  GeneratedColumn<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get remindAt =>
      $composableBuilder(column: $table.remindAt, builder: (column) => column);

  GeneratedColumn<String> get repeat =>
      $composableBuilder(column: $table.repeat, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get timeZone =>
      $composableBuilder(column: $table.timeZone, builder: (column) => column);
}

class $$RemindersTableTableManager
    extends
        RootTableManager<
          _$BoloDatabase,
          $RemindersTable,
          ReminderRow,
          $$RemindersTableFilterComposer,
          $$RemindersTableOrderingComposer,
          $$RemindersTableAnnotationComposer,
          $$RemindersTableCreateCompanionBuilder,
          $$RemindersTableUpdateCompanionBuilder,
          (
            ReminderRow,
            BaseReferences<_$BoloDatabase, $RemindersTable, ReminderRow>,
          ),
          ReminderRow,
          PrefetchHooks Function()
        > {
  $$RemindersTableTableManager(_$BoloDatabase db, $RemindersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RemindersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RemindersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RemindersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerScope = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rev = const Value.absent(),
                Value<String> lastDeviceId = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<String> origin = const Value.absent(),
                Value<int> schemaVersion = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> remindAt = const Value.absent(),
                Value<String> repeat = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String> timeZone = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RemindersCompanion(
                id: id,
                ownerScope: ownerScope,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rev: rev,
                lastDeviceId: lastDeviceId,
                syncState: syncState,
                serverUpdatedAt: serverUpdatedAt,
                origin: origin,
                schemaVersion: schemaVersion,
                title: title,
                remindAt: remindAt,
                repeat: repeat,
                status: status,
                source: source,
                timeZone: timeZone,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ownerScope,
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rev = const Value.absent(),
                required String lastDeviceId,
                Value<String> syncState = const Value.absent(),
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<String> origin = const Value.absent(),
                Value<int> schemaVersion = const Value.absent(),
                required String title,
                required int remindAt,
                required String repeat,
                required String status,
                required String source,
                Value<String> timeZone = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RemindersCompanion.insert(
                id: id,
                ownerScope: ownerScope,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rev: rev,
                lastDeviceId: lastDeviceId,
                syncState: syncState,
                serverUpdatedAt: serverUpdatedAt,
                origin: origin,
                schemaVersion: schemaVersion,
                title: title,
                remindAt: remindAt,
                repeat: repeat,
                status: status,
                source: source,
                timeZone: timeZone,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RemindersTable, ReminderRow>(table),
                  BaseReferences<_$BoloDatabase, $RemindersTable, ReminderRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RemindersTableProcessedTableManager =
    ProcessedTableManager<
      _$BoloDatabase,
      $RemindersTable,
      ReminderRow,
      $$RemindersTableFilterComposer,
      $$RemindersTableOrderingComposer,
      $$RemindersTableAnnotationComposer,
      $$RemindersTableCreateCompanionBuilder,
      $$RemindersTableUpdateCompanionBuilder,
      (
        ReminderRow,
        BaseReferences<_$BoloDatabase, $RemindersTable, ReminderRow>,
      ),
      ReminderRow,
      PrefetchHooks Function()
    >;
typedef $$TasksTableCreateCompanionBuilder = TasksCompanion Function({
  required String id,
  required String ownerScope,
  required int createdAt,
  required int updatedAt,
  Value<int?> deletedAt,
  Value<int> rev,
  required String lastDeviceId,
  Value<String> syncState,
  Value<int?> serverUpdatedAt,
  Value<String> origin,
  Value<int> schemaVersion,
  required String title,
  Value<int?> dueAt,
  Value<int?> remindAt,
  required String priority,
  required String status,
  Value<int?> completedAt,
  required String source,
  Value<String> timeZone,
  Value<int> rowid,
});
typedef $$TasksTableUpdateCompanionBuilder = TasksCompanion Function({
  Value<String> id,
  Value<String> ownerScope,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> deletedAt,
  Value<int> rev,
  Value<String> lastDeviceId,
  Value<String> syncState,
  Value<int?> serverUpdatedAt,
  Value<String> origin,
  Value<int> schemaVersion,
  Value<String> title,
  Value<int?> dueAt,
  Value<int?> remindAt,
  Value<String> priority,
  Value<String> status,
  Value<int?> completedAt,
  Value<String> source,
  Value<String> timeZone,
  Value<int> rowid,
});

class $$TasksTableFilterComposer extends Composer<_$BoloDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
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

  ColumnFilters<String> get ownerScope => $composableBuilder(
    column: $table.ownerScope,
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

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rev => $composableBuilder(
    column: $table.rev,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastDeviceId => $composableBuilder(
    column: $table.lastDeviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get remindAt => $composableBuilder(
    column: $table.remindAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timeZone => $composableBuilder(
    column: $table.timeZone,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TasksTableOrderingComposer
    extends Composer<_$BoloDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
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

  ColumnOrderings<String> get ownerScope => $composableBuilder(
    column: $table.ownerScope,
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

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rev => $composableBuilder(
    column: $table.rev,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastDeviceId => $composableBuilder(
    column: $table.lastDeviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get remindAt => $composableBuilder(
    column: $table.remindAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timeZone => $composableBuilder(
    column: $table.timeZone,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TasksTableAnnotationComposer
    extends Composer<_$BoloDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerScope => $composableBuilder(
    column: $table.ownerScope,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get rev =>
      $composableBuilder(column: $table.rev, builder: (column) => column);

  GeneratedColumn<String> get lastDeviceId => $composableBuilder(
    column: $table.lastDeviceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);

  GeneratedColumn<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get dueAt =>
      $composableBuilder(column: $table.dueAt, builder: (column) => column);

  GeneratedColumn<int> get remindAt =>
      $composableBuilder(column: $table.remindAt, builder: (column) => column);

  GeneratedColumn<String> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get timeZone =>
      $composableBuilder(column: $table.timeZone, builder: (column) => column);
}

class $$TasksTableTableManager
    extends
        RootTableManager<
          _$BoloDatabase,
          $TasksTable,
          TaskRow,
          $$TasksTableFilterComposer,
          $$TasksTableOrderingComposer,
          $$TasksTableAnnotationComposer,
          $$TasksTableCreateCompanionBuilder,
          $$TasksTableUpdateCompanionBuilder,
          (TaskRow, BaseReferences<_$BoloDatabase, $TasksTable, TaskRow>),
          TaskRow,
          PrefetchHooks Function()
        > {
  $$TasksTableTableManager(_$BoloDatabase db, $TasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerScope = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rev = const Value.absent(),
                Value<String> lastDeviceId = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<String> origin = const Value.absent(),
                Value<int> schemaVersion = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int?> dueAt = const Value.absent(),
                Value<int?> remindAt = const Value.absent(),
                Value<String> priority = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> completedAt = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String> timeZone = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TasksCompanion(
                id: id,
                ownerScope: ownerScope,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rev: rev,
                lastDeviceId: lastDeviceId,
                syncState: syncState,
                serverUpdatedAt: serverUpdatedAt,
                origin: origin,
                schemaVersion: schemaVersion,
                title: title,
                dueAt: dueAt,
                remindAt: remindAt,
                priority: priority,
                status: status,
                completedAt: completedAt,
                source: source,
                timeZone: timeZone,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ownerScope,
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rev = const Value.absent(),
                required String lastDeviceId,
                Value<String> syncState = const Value.absent(),
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<String> origin = const Value.absent(),
                Value<int> schemaVersion = const Value.absent(),
                required String title,
                Value<int?> dueAt = const Value.absent(),
                Value<int?> remindAt = const Value.absent(),
                required String priority,
                required String status,
                Value<int?> completedAt = const Value.absent(),
                required String source,
                Value<String> timeZone = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TasksCompanion.insert(
                id: id,
                ownerScope: ownerScope,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rev: rev,
                lastDeviceId: lastDeviceId,
                syncState: syncState,
                serverUpdatedAt: serverUpdatedAt,
                origin: origin,
                schemaVersion: schemaVersion,
                title: title,
                dueAt: dueAt,
                remindAt: remindAt,
                priority: priority,
                status: status,
                completedAt: completedAt,
                source: source,
                timeZone: timeZone,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TasksTable, TaskRow>(table),
                  BaseReferences<_$BoloDatabase, $TasksTable, TaskRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TasksTableProcessedTableManager =
    ProcessedTableManager<
      _$BoloDatabase,
      $TasksTable,
      TaskRow,
      $$TasksTableFilterComposer,
      $$TasksTableOrderingComposer,
      $$TasksTableAnnotationComposer,
      $$TasksTableCreateCompanionBuilder,
      $$TasksTableUpdateCompanionBuilder,
      (TaskRow, BaseReferences<_$BoloDatabase, $TasksTable, TaskRow>),
      TaskRow,
      PrefetchHooks Function()
    >;
typedef $$ExpensesTableCreateCompanionBuilder = ExpensesCompanion Function({
  required String id,
  required String ownerScope,
  required int createdAt,
  required int updatedAt,
  Value<int?> deletedAt,
  Value<int> rev,
  required String lastDeviceId,
  Value<String> syncState,
  Value<int?> serverUpdatedAt,
  Value<String> origin,
  Value<int> schemaVersion,
  required int amountMinor,
  Value<String> currency,
  required String category,
  required String note,
  required int spentAt,
  required String source,
  Value<int> rowid,
});
typedef $$ExpensesTableUpdateCompanionBuilder = ExpensesCompanion Function({
  Value<String> id,
  Value<String> ownerScope,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> deletedAt,
  Value<int> rev,
  Value<String> lastDeviceId,
  Value<String> syncState,
  Value<int?> serverUpdatedAt,
  Value<String> origin,
  Value<int> schemaVersion,
  Value<int> amountMinor,
  Value<String> currency,
  Value<String> category,
  Value<String> note,
  Value<int> spentAt,
  Value<String> source,
  Value<int> rowid,
});

class $$ExpensesTableFilterComposer
    extends Composer<_$BoloDatabase, $ExpensesTable> {
  $$ExpensesTableFilterComposer({
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

  ColumnFilters<String> get ownerScope => $composableBuilder(
    column: $table.ownerScope,
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

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rev => $composableBuilder(
    column: $table.rev,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastDeviceId => $composableBuilder(
    column: $table.lastDeviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get spentAt => $composableBuilder(
    column: $table.spentAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExpensesTableOrderingComposer
    extends Composer<_$BoloDatabase, $ExpensesTable> {
  $$ExpensesTableOrderingComposer({
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

  ColumnOrderings<String> get ownerScope => $composableBuilder(
    column: $table.ownerScope,
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

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rev => $composableBuilder(
    column: $table.rev,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastDeviceId => $composableBuilder(
    column: $table.lastDeviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get spentAt => $composableBuilder(
    column: $table.spentAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExpensesTableAnnotationComposer
    extends Composer<_$BoloDatabase, $ExpensesTable> {
  $$ExpensesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerScope => $composableBuilder(
    column: $table.ownerScope,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get rev =>
      $composableBuilder(column: $table.rev, builder: (column) => column);

  GeneratedColumn<String> get lastDeviceId => $composableBuilder(
    column: $table.lastDeviceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);

  GeneratedColumn<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get spentAt =>
      $composableBuilder(column: $table.spentAt, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);
}

class $$ExpensesTableTableManager
    extends
        RootTableManager<
          _$BoloDatabase,
          $ExpensesTable,
          ExpenseRow,
          $$ExpensesTableFilterComposer,
          $$ExpensesTableOrderingComposer,
          $$ExpensesTableAnnotationComposer,
          $$ExpensesTableCreateCompanionBuilder,
          $$ExpensesTableUpdateCompanionBuilder,
          (
            ExpenseRow,
            BaseReferences<_$BoloDatabase, $ExpensesTable, ExpenseRow>,
          ),
          ExpenseRow,
          PrefetchHooks Function()
        > {
  $$ExpensesTableTableManager(_$BoloDatabase db, $ExpensesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpensesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpensesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExpensesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerScope = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rev = const Value.absent(),
                Value<String> lastDeviceId = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<String> origin = const Value.absent(),
                Value<int> schemaVersion = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<int> spentAt = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExpensesCompanion(
                id: id,
                ownerScope: ownerScope,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rev: rev,
                lastDeviceId: lastDeviceId,
                syncState: syncState,
                serverUpdatedAt: serverUpdatedAt,
                origin: origin,
                schemaVersion: schemaVersion,
                amountMinor: amountMinor,
                currency: currency,
                category: category,
                note: note,
                spentAt: spentAt,
                source: source,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ownerScope,
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rev = const Value.absent(),
                required String lastDeviceId,
                Value<String> syncState = const Value.absent(),
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<String> origin = const Value.absent(),
                Value<int> schemaVersion = const Value.absent(),
                required int amountMinor,
                Value<String> currency = const Value.absent(),
                required String category,
                required String note,
                required int spentAt,
                required String source,
                Value<int> rowid = const Value.absent(),
              }) => ExpensesCompanion.insert(
                id: id,
                ownerScope: ownerScope,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rev: rev,
                lastDeviceId: lastDeviceId,
                syncState: syncState,
                serverUpdatedAt: serverUpdatedAt,
                origin: origin,
                schemaVersion: schemaVersion,
                amountMinor: amountMinor,
                currency: currency,
                category: category,
                note: note,
                spentAt: spentAt,
                source: source,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExpensesTable, ExpenseRow>(table),
                  BaseReferences<_$BoloDatabase, $ExpensesTable, ExpenseRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExpensesTableProcessedTableManager =
    ProcessedTableManager<
      _$BoloDatabase,
      $ExpensesTable,
      ExpenseRow,
      $$ExpensesTableFilterComposer,
      $$ExpensesTableOrderingComposer,
      $$ExpensesTableAnnotationComposer,
      $$ExpensesTableCreateCompanionBuilder,
      $$ExpensesTableUpdateCompanionBuilder,
      (ExpenseRow, BaseReferences<_$BoloDatabase, $ExpensesTable, ExpenseRow>),
      ExpenseRow,
      PrefetchHooks Function()
    >;
typedef $$LedgerEntriesTableCreateCompanionBuilder =
    LedgerEntriesCompanion Function({
      required String id,
      required String ownerScope,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      Value<int> rev,
      required String lastDeviceId,
      Value<String> syncState,
      Value<int?> serverUpdatedAt,
      Value<String> origin,
      Value<int> schemaVersion,
      required String direction,
      required String person,
      required int amountMinor,
      Value<String> currency,
      Value<int?> dueAt,
      required String status,
      Value<int?> settledAt,
      required String note,
      required String source,
      Value<int> rowid,
    });
typedef $$LedgerEntriesTableUpdateCompanionBuilder =
    LedgerEntriesCompanion Function({
      Value<String> id,
      Value<String> ownerScope,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<int> rev,
      Value<String> lastDeviceId,
      Value<String> syncState,
      Value<int?> serverUpdatedAt,
      Value<String> origin,
      Value<int> schemaVersion,
      Value<String> direction,
      Value<String> person,
      Value<int> amountMinor,
      Value<String> currency,
      Value<int?> dueAt,
      Value<String> status,
      Value<int?> settledAt,
      Value<String> note,
      Value<String> source,
      Value<int> rowid,
    });

class $$LedgerEntriesTableFilterComposer
    extends Composer<_$BoloDatabase, $LedgerEntriesTable> {
  $$LedgerEntriesTableFilterComposer({
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

  ColumnFilters<String> get ownerScope => $composableBuilder(
    column: $table.ownerScope,
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

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rev => $composableBuilder(
    column: $table.rev,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastDeviceId => $composableBuilder(
    column: $table.lastDeviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get person => $composableBuilder(
    column: $table.person,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get settledAt => $composableBuilder(
    column: $table.settledAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LedgerEntriesTableOrderingComposer
    extends Composer<_$BoloDatabase, $LedgerEntriesTable> {
  $$LedgerEntriesTableOrderingComposer({
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

  ColumnOrderings<String> get ownerScope => $composableBuilder(
    column: $table.ownerScope,
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

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rev => $composableBuilder(
    column: $table.rev,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastDeviceId => $composableBuilder(
    column: $table.lastDeviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get person => $composableBuilder(
    column: $table.person,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get settledAt => $composableBuilder(
    column: $table.settledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LedgerEntriesTableAnnotationComposer
    extends Composer<_$BoloDatabase, $LedgerEntriesTable> {
  $$LedgerEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerScope => $composableBuilder(
    column: $table.ownerScope,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get rev =>
      $composableBuilder(column: $table.rev, builder: (column) => column);

  GeneratedColumn<String> get lastDeviceId => $composableBuilder(
    column: $table.lastDeviceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);

  GeneratedColumn<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<String> get person =>
      $composableBuilder(column: $table.person, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<int> get dueAt =>
      $composableBuilder(column: $table.dueAt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get settledAt =>
      $composableBuilder(column: $table.settledAt, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);
}

class $$LedgerEntriesTableTableManager
    extends
        RootTableManager<
          _$BoloDatabase,
          $LedgerEntriesTable,
          LedgerRow,
          $$LedgerEntriesTableFilterComposer,
          $$LedgerEntriesTableOrderingComposer,
          $$LedgerEntriesTableAnnotationComposer,
          $$LedgerEntriesTableCreateCompanionBuilder,
          $$LedgerEntriesTableUpdateCompanionBuilder,
          (
            LedgerRow,
            BaseReferences<_$BoloDatabase, $LedgerEntriesTable, LedgerRow>,
          ),
          LedgerRow,
          PrefetchHooks Function()
        > {
  $$LedgerEntriesTableTableManager(_$BoloDatabase db, $LedgerEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LedgerEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LedgerEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LedgerEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerScope = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rev = const Value.absent(),
                Value<String> lastDeviceId = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<String> origin = const Value.absent(),
                Value<int> schemaVersion = const Value.absent(),
                Value<String> direction = const Value.absent(),
                Value<String> person = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<int?> dueAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> settledAt = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LedgerEntriesCompanion(
                id: id,
                ownerScope: ownerScope,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rev: rev,
                lastDeviceId: lastDeviceId,
                syncState: syncState,
                serverUpdatedAt: serverUpdatedAt,
                origin: origin,
                schemaVersion: schemaVersion,
                direction: direction,
                person: person,
                amountMinor: amountMinor,
                currency: currency,
                dueAt: dueAt,
                status: status,
                settledAt: settledAt,
                note: note,
                source: source,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ownerScope,
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rev = const Value.absent(),
                required String lastDeviceId,
                Value<String> syncState = const Value.absent(),
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<String> origin = const Value.absent(),
                Value<int> schemaVersion = const Value.absent(),
                required String direction,
                required String person,
                required int amountMinor,
                Value<String> currency = const Value.absent(),
                Value<int?> dueAt = const Value.absent(),
                required String status,
                Value<int?> settledAt = const Value.absent(),
                required String note,
                required String source,
                Value<int> rowid = const Value.absent(),
              }) => LedgerEntriesCompanion.insert(
                id: id,
                ownerScope: ownerScope,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rev: rev,
                lastDeviceId: lastDeviceId,
                syncState: syncState,
                serverUpdatedAt: serverUpdatedAt,
                origin: origin,
                schemaVersion: schemaVersion,
                direction: direction,
                person: person,
                amountMinor: amountMinor,
                currency: currency,
                dueAt: dueAt,
                status: status,
                settledAt: settledAt,
                note: note,
                source: source,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LedgerEntriesTable, LedgerRow>(table),
                  BaseReferences<
                    _$BoloDatabase,
                    $LedgerEntriesTable,
                    LedgerRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LedgerEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$BoloDatabase,
      $LedgerEntriesTable,
      LedgerRow,
      $$LedgerEntriesTableFilterComposer,
      $$LedgerEntriesTableOrderingComposer,
      $$LedgerEntriesTableAnnotationComposer,
      $$LedgerEntriesTableCreateCompanionBuilder,
      $$LedgerEntriesTableUpdateCompanionBuilder,
      (
        LedgerRow,
        BaseReferences<_$BoloDatabase, $LedgerEntriesTable, LedgerRow>,
      ),
      LedgerRow,
      PrefetchHooks Function()
    >;
typedef $$InboxItemsTableCreateCompanionBuilder = InboxItemsCompanion Function({
  required String id,
  required String ownerScope,
  required String body,
  required bool fromVoice,
  required int createdAt,
  Value<int> rowid,
});
typedef $$InboxItemsTableUpdateCompanionBuilder = InboxItemsCompanion Function({
  Value<String> id,
  Value<String> ownerScope,
  Value<String> body,
  Value<bool> fromVoice,
  Value<int> createdAt,
  Value<int> rowid,
});

class $$InboxItemsTableFilterComposer
    extends Composer<_$BoloDatabase, $InboxItemsTable> {
  $$InboxItemsTableFilterComposer({
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

  ColumnFilters<String> get ownerScope => $composableBuilder(
    column: $table.ownerScope,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get fromVoice => $composableBuilder(
    column: $table.fromVoice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$InboxItemsTableOrderingComposer
    extends Composer<_$BoloDatabase, $InboxItemsTable> {
  $$InboxItemsTableOrderingComposer({
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

  ColumnOrderings<String> get ownerScope => $composableBuilder(
    column: $table.ownerScope,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get fromVoice => $composableBuilder(
    column: $table.fromVoice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InboxItemsTableAnnotationComposer
    extends Composer<_$BoloDatabase, $InboxItemsTable> {
  $$InboxItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerScope => $composableBuilder(
    column: $table.ownerScope,
    builder: (column) => column,
  );

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<bool> get fromVoice =>
      $composableBuilder(column: $table.fromVoice, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$InboxItemsTableTableManager
    extends
        RootTableManager<
          _$BoloDatabase,
          $InboxItemsTable,
          InboxRow,
          $$InboxItemsTableFilterComposer,
          $$InboxItemsTableOrderingComposer,
          $$InboxItemsTableAnnotationComposer,
          $$InboxItemsTableCreateCompanionBuilder,
          $$InboxItemsTableUpdateCompanionBuilder,
          (
            InboxRow,
            BaseReferences<_$BoloDatabase, $InboxItemsTable, InboxRow>,
          ),
          InboxRow,
          PrefetchHooks Function()
        > {
  $$InboxItemsTableTableManager(_$BoloDatabase db, $InboxItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InboxItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InboxItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InboxItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerScope = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<bool> fromVoice = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InboxItemsCompanion(
                id: id,
                ownerScope: ownerScope,
                body: body,
                fromVoice: fromVoice,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ownerScope,
                required String body,
                required bool fromVoice,
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => InboxItemsCompanion.insert(
                id: id,
                ownerScope: ownerScope,
                body: body,
                fromVoice: fromVoice,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$InboxItemsTable, InboxRow>(table),
                  BaseReferences<_$BoloDatabase, $InboxItemsTable, InboxRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InboxItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$BoloDatabase,
      $InboxItemsTable,
      InboxRow,
      $$InboxItemsTableFilterComposer,
      $$InboxItemsTableOrderingComposer,
      $$InboxItemsTableAnnotationComposer,
      $$InboxItemsTableCreateCompanionBuilder,
      $$InboxItemsTableUpdateCompanionBuilder,
      (InboxRow, BaseReferences<_$BoloDatabase, $InboxItemsTable, InboxRow>),
      InboxRow,
      PrefetchHooks Function()
    >;
typedef $$AppMetaTableCreateCompanionBuilder = AppMetaCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$AppMetaTableUpdateCompanionBuilder = AppMetaCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$AppMetaTableFilterComposer
    extends Composer<_$BoloDatabase, $AppMetaTable> {
  $$AppMetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppMetaTableOrderingComposer
    extends Composer<_$BoloDatabase, $AppMetaTable> {
  $$AppMetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppMetaTableAnnotationComposer
    extends Composer<_$BoloDatabase, $AppMetaTable> {
  $$AppMetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppMetaTableTableManager
    extends
        RootTableManager<
          _$BoloDatabase,
          $AppMetaTable,
          AppMetaRow,
          $$AppMetaTableFilterComposer,
          $$AppMetaTableOrderingComposer,
          $$AppMetaTableAnnotationComposer,
          $$AppMetaTableCreateCompanionBuilder,
          $$AppMetaTableUpdateCompanionBuilder,
          (
            AppMetaRow,
            BaseReferences<_$BoloDatabase, $AppMetaTable, AppMetaRow>,
          ),
          AppMetaRow,
          PrefetchHooks Function()
        > {
  $$AppMetaTableTableManager(_$BoloDatabase db, $AppMetaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => AppMetaCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) => AppMetaCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppMetaTable, AppMetaRow>(table),
                  BaseReferences<_$BoloDatabase, $AppMetaTable, AppMetaRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppMetaTableProcessedTableManager =
    ProcessedTableManager<
      _$BoloDatabase,
      $AppMetaTable,
      AppMetaRow,
      $$AppMetaTableFilterComposer,
      $$AppMetaTableOrderingComposer,
      $$AppMetaTableAnnotationComposer,
      $$AppMetaTableCreateCompanionBuilder,
      $$AppMetaTableUpdateCompanionBuilder,
      (AppMetaRow, BaseReferences<_$BoloDatabase, $AppMetaTable, AppMetaRow>),
      AppMetaRow,
      PrefetchHooks Function()
    >;
typedef $$MigrationRunsTableCreateCompanionBuilder =
    MigrationRunsCompanion Function({
      Value<int> id,
      required String state,
      required int startedAt,
      required int updatedAt,
      Value<String> counts,
      Value<String?> errorCode,
    });
typedef $$MigrationRunsTableUpdateCompanionBuilder =
    MigrationRunsCompanion Function({
      Value<int> id,
      Value<String> state,
      Value<int> startedAt,
      Value<int> updatedAt,
      Value<String> counts,
      Value<String?> errorCode,
    });

class $$MigrationRunsTableFilterComposer
    extends Composer<_$BoloDatabase, $MigrationRunsTable> {
  $$MigrationRunsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get counts => $composableBuilder(
    column: $table.counts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorCode => $composableBuilder(
    column: $table.errorCode,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MigrationRunsTableOrderingComposer
    extends Composer<_$BoloDatabase, $MigrationRunsTable> {
  $$MigrationRunsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get counts => $composableBuilder(
    column: $table.counts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorCode => $composableBuilder(
    column: $table.errorCode,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MigrationRunsTableAnnotationComposer
    extends Composer<_$BoloDatabase, $MigrationRunsTable> {
  $$MigrationRunsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<int> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get counts =>
      $composableBuilder(column: $table.counts, builder: (column) => column);

  GeneratedColumn<String> get errorCode =>
      $composableBuilder(column: $table.errorCode, builder: (column) => column);
}

class $$MigrationRunsTableTableManager
    extends
        RootTableManager<
          _$BoloDatabase,
          $MigrationRunsTable,
          MigrationRunRow,
          $$MigrationRunsTableFilterComposer,
          $$MigrationRunsTableOrderingComposer,
          $$MigrationRunsTableAnnotationComposer,
          $$MigrationRunsTableCreateCompanionBuilder,
          $$MigrationRunsTableUpdateCompanionBuilder,
          (
            MigrationRunRow,
            BaseReferences<
              _$BoloDatabase,
              $MigrationRunsTable,
              MigrationRunRow
            >,
          ),
          MigrationRunRow,
          PrefetchHooks Function()
        > {
  $$MigrationRunsTableTableManager(_$BoloDatabase db, $MigrationRunsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MigrationRunsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MigrationRunsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MigrationRunsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<int> startedAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String> counts = const Value.absent(),
                Value<String?> errorCode = const Value.absent(),
              }) => MigrationRunsCompanion(
                id: id,
                state: state,
                startedAt: startedAt,
                updatedAt: updatedAt,
                counts: counts,
                errorCode: errorCode,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String state,
                required int startedAt,
                required int updatedAt,
                Value<String> counts = const Value.absent(),
                Value<String?> errorCode = const Value.absent(),
              }) => MigrationRunsCompanion.insert(
                id: id,
                state: state,
                startedAt: startedAt,
                updatedAt: updatedAt,
                counts: counts,
                errorCode: errorCode,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MigrationRunsTable, MigrationRunRow>(table),
                  BaseReferences<
                    _$BoloDatabase,
                    $MigrationRunsTable,
                    MigrationRunRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MigrationRunsTableProcessedTableManager =
    ProcessedTableManager<
      _$BoloDatabase,
      $MigrationRunsTable,
      MigrationRunRow,
      $$MigrationRunsTableFilterComposer,
      $$MigrationRunsTableOrderingComposer,
      $$MigrationRunsTableAnnotationComposer,
      $$MigrationRunsTableCreateCompanionBuilder,
      $$MigrationRunsTableUpdateCompanionBuilder,
      (
        MigrationRunRow,
        BaseReferences<_$BoloDatabase, $MigrationRunsTable, MigrationRunRow>,
      ),
      MigrationRunRow,
      PrefetchHooks Function()
    >;
typedef $$MigrationItemsTableCreateCompanionBuilder =
    MigrationItemsCompanion Function({
      required int runId,
      required String collection,
      required String sourceId,
      required String checksum,
      Value<int> rowid,
    });
typedef $$MigrationItemsTableUpdateCompanionBuilder =
    MigrationItemsCompanion Function({
      Value<int> runId,
      Value<String> collection,
      Value<String> sourceId,
      Value<String> checksum,
      Value<int> rowid,
    });

class $$MigrationItemsTableFilterComposer
    extends Composer<_$BoloDatabase, $MigrationItemsTable> {
  $$MigrationItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get runId => $composableBuilder(
    column: $table.runId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get collection => $composableBuilder(
    column: $table.collection,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get checksum => $composableBuilder(
    column: $table.checksum,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MigrationItemsTableOrderingComposer
    extends Composer<_$BoloDatabase, $MigrationItemsTable> {
  $$MigrationItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get runId => $composableBuilder(
    column: $table.runId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get collection => $composableBuilder(
    column: $table.collection,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get checksum => $composableBuilder(
    column: $table.checksum,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MigrationItemsTableAnnotationComposer
    extends Composer<_$BoloDatabase, $MigrationItemsTable> {
  $$MigrationItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get runId =>
      $composableBuilder(column: $table.runId, builder: (column) => column);

  GeneratedColumn<String> get collection => $composableBuilder(
    column: $table.collection,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get checksum =>
      $composableBuilder(column: $table.checksum, builder: (column) => column);
}

class $$MigrationItemsTableTableManager
    extends
        RootTableManager<
          _$BoloDatabase,
          $MigrationItemsTable,
          MigrationItemRow,
          $$MigrationItemsTableFilterComposer,
          $$MigrationItemsTableOrderingComposer,
          $$MigrationItemsTableAnnotationComposer,
          $$MigrationItemsTableCreateCompanionBuilder,
          $$MigrationItemsTableUpdateCompanionBuilder,
          (
            MigrationItemRow,
            BaseReferences<
              _$BoloDatabase,
              $MigrationItemsTable,
              MigrationItemRow
            >,
          ),
          MigrationItemRow,
          PrefetchHooks Function()
        > {
  $$MigrationItemsTableTableManager(
    _$BoloDatabase db,
    $MigrationItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MigrationItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MigrationItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MigrationItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> runId = const Value.absent(),
                Value<String> collection = const Value.absent(),
                Value<String> sourceId = const Value.absent(),
                Value<String> checksum = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MigrationItemsCompanion(
                runId: runId,
                collection: collection,
                sourceId: sourceId,
                checksum: checksum,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int runId,
                required String collection,
                required String sourceId,
                required String checksum,
                Value<int> rowid = const Value.absent(),
              }) => MigrationItemsCompanion.insert(
                runId: runId,
                collection: collection,
                sourceId: sourceId,
                checksum: checksum,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MigrationItemsTable, MigrationItemRow>(table),
                  BaseReferences<
                    _$BoloDatabase,
                    $MigrationItemsTable,
                    MigrationItemRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MigrationItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$BoloDatabase,
      $MigrationItemsTable,
      MigrationItemRow,
      $$MigrationItemsTableFilterComposer,
      $$MigrationItemsTableOrderingComposer,
      $$MigrationItemsTableAnnotationComposer,
      $$MigrationItemsTableCreateCompanionBuilder,
      $$MigrationItemsTableUpdateCompanionBuilder,
      (
        MigrationItemRow,
        BaseReferences<_$BoloDatabase, $MigrationItemsTable, MigrationItemRow>,
      ),
      MigrationItemRow,
      PrefetchHooks Function()
    >;

class $BoloDatabaseManager {
  final _$BoloDatabase _db;
  $BoloDatabaseManager(this._db);
  $$RemindersTableTableManager get reminders =>
      $$RemindersTableTableManager(_db, _db.reminders);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
  $$ExpensesTableTableManager get expenses =>
      $$ExpensesTableTableManager(_db, _db.expenses);
  $$LedgerEntriesTableTableManager get ledgerEntries =>
      $$LedgerEntriesTableTableManager(_db, _db.ledgerEntries);
  $$InboxItemsTableTableManager get inboxItems =>
      $$InboxItemsTableTableManager(_db, _db.inboxItems);
  $$AppMetaTableTableManager get appMeta =>
      $$AppMetaTableTableManager(_db, _db.appMeta);
  $$MigrationRunsTableTableManager get migrationRuns =>
      $$MigrationRunsTableTableManager(_db, _db.migrationRuns);
  $$MigrationItemsTableTableManager get migrationItems =>
      $$MigrationItemsTableTableManager(_db, _db.migrationItems);
}
