// dart format width=80
// ignore_for_file: type=lint
part of 'app_database.dart';

class $PersonalListsTable extends PersonalLists
    with TableInfo<$PersonalListsTable, PersonalListRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PersonalListsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorValueMeta = const VerificationMeta(
    'colorValue',
  );
  @override
  late final GeneratedColumn<int> colorValue = GeneratedColumn<int>(
    'color_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0xFF44BBA4),
  );
  static const VerificationMeta _iconCodePointMeta = const VerificationMeta(
    'iconCodePoint',
  );
  @override
  late final GeneratedColumn<int> iconCodePoint = GeneratedColumn<int>(
    'icon_code_point',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0xe156),
  );
  static const VerificationMeta _isPrivateDefaultMeta = const VerificationMeta(
    'isPrivateDefault',
  );
  @override
  late final GeneratedColumn<bool> isPrivateDefault = GeneratedColumn<bool>(
    'is_private_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_private_default" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    colorValue,
    iconCodePoint,
    isPrivateDefault,
    position,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'personal_lists';
  @override
  VerificationContext validateIntegrity(
    Insertable<PersonalListRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color_value')) {
      context.handle(
        _colorValueMeta,
        colorValue.isAcceptableOrUnknown(data['color_value']!, _colorValueMeta),
      );
    }
    if (data.containsKey('icon_code_point')) {
      context.handle(
        _iconCodePointMeta,
        iconCodePoint.isAcceptableOrUnknown(
          data['icon_code_point']!,
          _iconCodePointMeta,
        ),
      );
    }
    if (data.containsKey('is_private_default')) {
      context.handle(
        _isPrivateDefaultMeta,
        isPrivateDefault.isAcceptableOrUnknown(
          data['is_private_default']!,
          _isPrivateDefaultMeta,
        ),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
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
  PersonalListRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PersonalListRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      colorValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_value'],
      )!,
      iconCodePoint: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}icon_code_point'],
      )!,
      isPrivateDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_private_default'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PersonalListsTable createAlias(String alias) {
    return $PersonalListsTable(attachedDatabase, alias);
  }
}

class PersonalListRow extends DataClass implements Insertable<PersonalListRow> {
  final String id;
  final String name;
  final int colorValue;
  final int iconCodePoint;
  final bool isPrivateDefault;
  final int position;
  final DateTime createdAt;
  final DateTime updatedAt;
  const PersonalListRow({
    required this.id,
    required this.name,
    required this.colorValue,
    required this.iconCodePoint,
    required this.isPrivateDefault,
    required this.position,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['color_value'] = Variable<int>(colorValue);
    map['icon_code_point'] = Variable<int>(iconCodePoint);
    map['is_private_default'] = Variable<bool>(isPrivateDefault);
    map['position'] = Variable<int>(position);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PersonalListsCompanion toCompanion(bool nullToAbsent) {
    return PersonalListsCompanion(
      id: Value(id),
      name: Value(name),
      colorValue: Value(colorValue),
      iconCodePoint: Value(iconCodePoint),
      isPrivateDefault: Value(isPrivateDefault),
      position: Value(position),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory PersonalListRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PersonalListRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      colorValue: serializer.fromJson<int>(json['colorValue']),
      iconCodePoint: serializer.fromJson<int>(json['iconCodePoint']),
      isPrivateDefault: serializer.fromJson<bool>(json['isPrivateDefault']),
      position: serializer.fromJson<int>(json['position']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'colorValue': serializer.toJson<int>(colorValue),
      'iconCodePoint': serializer.toJson<int>(iconCodePoint),
      'isPrivateDefault': serializer.toJson<bool>(isPrivateDefault),
      'position': serializer.toJson<int>(position),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PersonalListRow copyWith({
    String? id,
    String? name,
    int? colorValue,
    int? iconCodePoint,
    bool? isPrivateDefault,
    int? position,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => PersonalListRow(
    id: id ?? this.id,
    name: name ?? this.name,
    colorValue: colorValue ?? this.colorValue,
    iconCodePoint: iconCodePoint ?? this.iconCodePoint,
    isPrivateDefault: isPrivateDefault ?? this.isPrivateDefault,
    position: position ?? this.position,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PersonalListRow copyWithCompanion(PersonalListsCompanion data) {
    return PersonalListRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      colorValue: data.colorValue.present
          ? data.colorValue.value
          : this.colorValue,
      iconCodePoint: data.iconCodePoint.present
          ? data.iconCodePoint.value
          : this.iconCodePoint,
      isPrivateDefault: data.isPrivateDefault.present
          ? data.isPrivateDefault.value
          : this.isPrivateDefault,
      position: data.position.present ? data.position.value : this.position,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PersonalListRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('colorValue: $colorValue, ')
          ..write('iconCodePoint: $iconCodePoint, ')
          ..write('isPrivateDefault: $isPrivateDefault, ')
          ..write('position: $position, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    colorValue,
    iconCodePoint,
    isPrivateDefault,
    position,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PersonalListRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.colorValue == this.colorValue &&
          other.iconCodePoint == this.iconCodePoint &&
          other.isPrivateDefault == this.isPrivateDefault &&
          other.position == this.position &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PersonalListsCompanion extends UpdateCompanion<PersonalListRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> colorValue;
  final Value<int> iconCodePoint;
  final Value<bool> isPrivateDefault;
  final Value<int> position;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PersonalListsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.colorValue = const Value.absent(),
    this.iconCodePoint = const Value.absent(),
    this.isPrivateDefault = const Value.absent(),
    this.position = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PersonalListsCompanion.insert({
    required String id,
    required String name,
    this.colorValue = const Value.absent(),
    this.iconCodePoint = const Value.absent(),
    this.isPrivateDefault = const Value.absent(),
    this.position = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<PersonalListRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? colorValue,
    Expression<int>? iconCodePoint,
    Expression<bool>? isPrivateDefault,
    Expression<int>? position,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (colorValue != null) 'color_value': colorValue,
      if (iconCodePoint != null) 'icon_code_point': iconCodePoint,
      if (isPrivateDefault != null) 'is_private_default': isPrivateDefault,
      if (position != null) 'position': position,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PersonalListsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? colorValue,
    Value<int>? iconCodePoint,
    Value<bool>? isPrivateDefault,
    Value<int>? position,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PersonalListsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      isPrivateDefault: isPrivateDefault ?? this.isPrivateDefault,
      position: position ?? this.position,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (colorValue.present) {
      map['color_value'] = Variable<int>(colorValue.value);
    }
    if (iconCodePoint.present) {
      map['icon_code_point'] = Variable<int>(iconCodePoint.value);
    }
    if (isPrivateDefault.present) {
      map['is_private_default'] = Variable<bool>(isPrivateDefault.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PersonalListsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('colorValue: $colorValue, ')
          ..write('iconCodePoint: $iconCodePoint, ')
          ..write('isPrivateDefault: $isPrivateDefault, ')
          ..write('position: $position, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PersonalTasksTable extends PersonalTasks
    with TableInfo<$PersonalTasksTable, PersonalTaskRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PersonalTasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _listIdMeta = const VerificationMeta('listId');
  @override
  late final GeneratedColumn<String> listId = GeneratedColumn<String>(
    'list_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES personal_lists (id)',
    ),
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
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isAllDayMeta = const VerificationMeta(
    'isAllDay',
  );
  @override
  late final GeneratedColumn<bool> isAllDay = GeneratedColumn<bool>(
    'is_all_day',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_all_day" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _recurrenceRuleMeta = const VerificationMeta(
    'recurrenceRule',
  );
  @override
  late final GeneratedColumn<String> recurrenceRule = GeneratedColumn<String>(
    'recurrence_rule',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isFlaggedMeta = const VerificationMeta(
    'isFlagged',
  );
  @override
  late final GeneratedColumn<bool> isFlagged = GeneratedColumn<bool>(
    'is_flagged',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_flagged" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isPrivateMeta = const VerificationMeta(
    'isPrivate',
  );
  @override
  late final GeneratedColumn<bool> isPrivate = GeneratedColumn<bool>(
    'is_private',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_private" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _kidsTaskIdMeta = const VerificationMeta(
    'kidsTaskId',
  );
  @override
  late final GeneratedColumn<String> kidsTaskId = GeneratedColumn<String>(
    'kids_task_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetKidIdMeta = const VerificationMeta(
    'targetKidId',
  );
  @override
  late final GeneratedColumn<String> targetKidId = GeneratedColumn<String>(
    'target_kid_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _verifierLinkIdMeta = const VerificationMeta(
    'verifierLinkId',
  );
  @override
  late final GeneratedColumn<String> verifierLinkId = GeneratedColumn<String>(
    'verifier_link_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _xpRewardMeta = const VerificationMeta(
    'xpReward',
  );
  @override
  late final GeneratedColumn<int> xpReward = GeneratedColumn<int>(
    'xp_reward',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(10),
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
    requiredDuringInsert: false,
    defaultValue: const Constant('other'),
  );
  static const VerificationMeta _customCategoryMeta = const VerificationMeta(
    'customCategory',
  );
  @override
  late final GeneratedColumn<String> customCategory = GeneratedColumn<String>(
    'custom_category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remindAtMeta = const VerificationMeta(
    'remindAt',
  );
  @override
  late final GeneratedColumn<DateTime> remindAt = GeneratedColumn<DateTime>(
    'remind_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _webdavEtagMeta = const VerificationMeta(
    'webdavEtag',
  );
  @override
  late final GeneratedColumn<String> webdavEtag = GeneratedColumn<String>(
    'webdav_etag',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    defaultValue: const Constant('dirty'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    listId,
    title,
    notes,
    priority,
    dueDate,
    isAllDay,
    recurrenceRule,
    isCompleted,
    completedAt,
    isFlagged,
    isPrivate,
    kidsTaskId,
    targetKidId,
    verifierLinkId,
    xpReward,
    category,
    customCategory,
    remindAt,
    sortOrder,
    webdavEtag,
    syncState,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'personal_tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<PersonalTaskRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('list_id')) {
      context.handle(
        _listIdMeta,
        listId.isAcceptableOrUnknown(data['list_id']!, _listIdMeta),
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
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    }
    if (data.containsKey('is_all_day')) {
      context.handle(
        _isAllDayMeta,
        isAllDay.isAcceptableOrUnknown(data['is_all_day']!, _isAllDayMeta),
      );
    }
    if (data.containsKey('recurrence_rule')) {
      context.handle(
        _recurrenceRuleMeta,
        recurrenceRule.isAcceptableOrUnknown(
          data['recurrence_rule']!,
          _recurrenceRuleMeta,
        ),
      );
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
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
    if (data.containsKey('is_flagged')) {
      context.handle(
        _isFlaggedMeta,
        isFlagged.isAcceptableOrUnknown(data['is_flagged']!, _isFlaggedMeta),
      );
    }
    if (data.containsKey('is_private')) {
      context.handle(
        _isPrivateMeta,
        isPrivate.isAcceptableOrUnknown(data['is_private']!, _isPrivateMeta),
      );
    }
    if (data.containsKey('kids_task_id')) {
      context.handle(
        _kidsTaskIdMeta,
        kidsTaskId.isAcceptableOrUnknown(
          data['kids_task_id']!,
          _kidsTaskIdMeta,
        ),
      );
    }
    if (data.containsKey('target_kid_id')) {
      context.handle(
        _targetKidIdMeta,
        targetKidId.isAcceptableOrUnknown(
          data['target_kid_id']!,
          _targetKidIdMeta,
        ),
      );
    }
    if (data.containsKey('verifier_link_id')) {
      context.handle(
        _verifierLinkIdMeta,
        verifierLinkId.isAcceptableOrUnknown(
          data['verifier_link_id']!,
          _verifierLinkIdMeta,
        ),
      );
    }
    if (data.containsKey('xp_reward')) {
      context.handle(
        _xpRewardMeta,
        xpReward.isAcceptableOrUnknown(data['xp_reward']!, _xpRewardMeta),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('custom_category')) {
      context.handle(
        _customCategoryMeta,
        customCategory.isAcceptableOrUnknown(
          data['custom_category']!,
          _customCategoryMeta,
        ),
      );
    }
    if (data.containsKey('remind_at')) {
      context.handle(
        _remindAtMeta,
        remindAt.isAcceptableOrUnknown(data['remind_at']!, _remindAtMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('webdav_etag')) {
      context.handle(
        _webdavEtagMeta,
        webdavEtag.isAcceptableOrUnknown(data['webdav_etag']!, _webdavEtagMeta),
      );
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
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
  PersonalTaskRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PersonalTaskRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      listId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}list_id'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      ),
      isAllDay: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_all_day'],
      )!,
      recurrenceRule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurrence_rule'],
      ),
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      isFlagged: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_flagged'],
      )!,
      isPrivate: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_private'],
      )!,
      kidsTaskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kids_task_id'],
      ),
      targetKidId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_kid_id'],
      ),
      verifierLinkId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}verifier_link_id'],
      ),
      xpReward: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}xp_reward'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      customCategory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_category'],
      ),
      remindAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}remind_at'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      webdavEtag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}webdav_etag'],
      ),
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PersonalTasksTable createAlias(String alias) {
    return $PersonalTasksTable(attachedDatabase, alias);
  }
}

class PersonalTaskRow extends DataClass implements Insertable<PersonalTaskRow> {
  final String id;
  final String? listId;
  final String title;
  final String? notes;
  final int priority;
  final DateTime? dueDate;
  final bool isAllDay;
  final String? recurrenceRule;
  final bool isCompleted;
  final DateTime? completedAt;
  final bool isFlagged;
  final bool isPrivate;
  final String? kidsTaskId;
  final String? targetKidId;

  /// Link member who must verify kids completion; null = any participating link member.
  final String? verifierLinkId;
  final int xpReward;
  final String category;
  final String? customCategory;

  /// When to fire a local reminder notification; null = no reminder.
  final DateTime? remindAt;
  final int sortOrder;

  /// ETag returned by the server after the last successful PUT/GET.
  /// Null = never synced.
  final String? webdavEtag;

  /// 'clean' | 'dirty' | 'deleted'. 'dirty' = local change not yet pushed.
  final String syncState;
  final DateTime createdAt;
  final DateTime updatedAt;
  const PersonalTaskRow({
    required this.id,
    this.listId,
    required this.title,
    this.notes,
    required this.priority,
    this.dueDate,
    required this.isAllDay,
    this.recurrenceRule,
    required this.isCompleted,
    this.completedAt,
    required this.isFlagged,
    required this.isPrivate,
    this.kidsTaskId,
    this.targetKidId,
    this.verifierLinkId,
    required this.xpReward,
    required this.category,
    this.customCategory,
    this.remindAt,
    required this.sortOrder,
    this.webdavEtag,
    required this.syncState,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || listId != null) {
      map['list_id'] = Variable<String>(listId);
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['priority'] = Variable<int>(priority);
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    map['is_all_day'] = Variable<bool>(isAllDay);
    if (!nullToAbsent || recurrenceRule != null) {
      map['recurrence_rule'] = Variable<String>(recurrenceRule);
    }
    map['is_completed'] = Variable<bool>(isCompleted);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['is_flagged'] = Variable<bool>(isFlagged);
    map['is_private'] = Variable<bool>(isPrivate);
    if (!nullToAbsent || kidsTaskId != null) {
      map['kids_task_id'] = Variable<String>(kidsTaskId);
    }
    if (!nullToAbsent || targetKidId != null) {
      map['target_kid_id'] = Variable<String>(targetKidId);
    }
    if (!nullToAbsent || verifierLinkId != null) {
      map['verifier_link_id'] = Variable<String>(verifierLinkId);
    }
    map['xp_reward'] = Variable<int>(xpReward);
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || customCategory != null) {
      map['custom_category'] = Variable<String>(customCategory);
    }
    if (!nullToAbsent || remindAt != null) {
      map['remind_at'] = Variable<DateTime>(remindAt);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    if (!nullToAbsent || webdavEtag != null) {
      map['webdav_etag'] = Variable<String>(webdavEtag);
    }
    map['sync_state'] = Variable<String>(syncState);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PersonalTasksCompanion toCompanion(bool nullToAbsent) {
    return PersonalTasksCompanion(
      id: Value(id),
      listId: listId == null && nullToAbsent
          ? const Value.absent()
          : Value(listId),
      title: Value(title),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      priority: Value(priority),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      isAllDay: Value(isAllDay),
      recurrenceRule: recurrenceRule == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceRule),
      isCompleted: Value(isCompleted),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      isFlagged: Value(isFlagged),
      isPrivate: Value(isPrivate),
      kidsTaskId: kidsTaskId == null && nullToAbsent
          ? const Value.absent()
          : Value(kidsTaskId),
      targetKidId: targetKidId == null && nullToAbsent
          ? const Value.absent()
          : Value(targetKidId),
      verifierLinkId: verifierLinkId == null && nullToAbsent
          ? const Value.absent()
          : Value(verifierLinkId),
      xpReward: Value(xpReward),
      category: Value(category),
      customCategory: customCategory == null && nullToAbsent
          ? const Value.absent()
          : Value(customCategory),
      remindAt: remindAt == null && nullToAbsent
          ? const Value.absent()
          : Value(remindAt),
      sortOrder: Value(sortOrder),
      webdavEtag: webdavEtag == null && nullToAbsent
          ? const Value.absent()
          : Value(webdavEtag),
      syncState: Value(syncState),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory PersonalTaskRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PersonalTaskRow(
      id: serializer.fromJson<String>(json['id']),
      listId: serializer.fromJson<String?>(json['listId']),
      title: serializer.fromJson<String>(json['title']),
      notes: serializer.fromJson<String?>(json['notes']),
      priority: serializer.fromJson<int>(json['priority']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      isAllDay: serializer.fromJson<bool>(json['isAllDay']),
      recurrenceRule: serializer.fromJson<String?>(json['recurrenceRule']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      isFlagged: serializer.fromJson<bool>(json['isFlagged']),
      isPrivate: serializer.fromJson<bool>(json['isPrivate']),
      kidsTaskId: serializer.fromJson<String?>(json['kidsTaskId']),
      targetKidId: serializer.fromJson<String?>(json['targetKidId']),
      verifierLinkId: serializer.fromJson<String?>(json['verifierLinkId']),
      xpReward: serializer.fromJson<int>(json['xpReward']),
      category: serializer.fromJson<String>(json['category']),
      customCategory: serializer.fromJson<String?>(json['customCategory']),
      remindAt: serializer.fromJson<DateTime?>(json['remindAt']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      webdavEtag: serializer.fromJson<String?>(json['webdavEtag']),
      syncState: serializer.fromJson<String>(json['syncState']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'listId': serializer.toJson<String?>(listId),
      'title': serializer.toJson<String>(title),
      'notes': serializer.toJson<String?>(notes),
      'priority': serializer.toJson<int>(priority),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'isAllDay': serializer.toJson<bool>(isAllDay),
      'recurrenceRule': serializer.toJson<String?>(recurrenceRule),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'isFlagged': serializer.toJson<bool>(isFlagged),
      'isPrivate': serializer.toJson<bool>(isPrivate),
      'kidsTaskId': serializer.toJson<String?>(kidsTaskId),
      'targetKidId': serializer.toJson<String?>(targetKidId),
      'verifierLinkId': serializer.toJson<String?>(verifierLinkId),
      'xpReward': serializer.toJson<int>(xpReward),
      'category': serializer.toJson<String>(category),
      'customCategory': serializer.toJson<String?>(customCategory),
      'remindAt': serializer.toJson<DateTime?>(remindAt),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'webdavEtag': serializer.toJson<String?>(webdavEtag),
      'syncState': serializer.toJson<String>(syncState),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PersonalTaskRow copyWith({
    String? id,
    Value<String?> listId = const Value.absent(),
    String? title,
    Value<String?> notes = const Value.absent(),
    int? priority,
    Value<DateTime?> dueDate = const Value.absent(),
    bool? isAllDay,
    Value<String?> recurrenceRule = const Value.absent(),
    bool? isCompleted,
    Value<DateTime?> completedAt = const Value.absent(),
    bool? isFlagged,
    bool? isPrivate,
    Value<String?> kidsTaskId = const Value.absent(),
    Value<String?> targetKidId = const Value.absent(),
    Value<String?> verifierLinkId = const Value.absent(),
    int? xpReward,
    String? category,
    Value<String?> customCategory = const Value.absent(),
    Value<DateTime?> remindAt = const Value.absent(),
    int? sortOrder,
    Value<String?> webdavEtag = const Value.absent(),
    String? syncState,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => PersonalTaskRow(
    id: id ?? this.id,
    listId: listId.present ? listId.value : this.listId,
    title: title ?? this.title,
    notes: notes.present ? notes.value : this.notes,
    priority: priority ?? this.priority,
    dueDate: dueDate.present ? dueDate.value : this.dueDate,
    isAllDay: isAllDay ?? this.isAllDay,
    recurrenceRule: recurrenceRule.present
        ? recurrenceRule.value
        : this.recurrenceRule,
    isCompleted: isCompleted ?? this.isCompleted,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    isFlagged: isFlagged ?? this.isFlagged,
    isPrivate: isPrivate ?? this.isPrivate,
    kidsTaskId: kidsTaskId.present ? kidsTaskId.value : this.kidsTaskId,
    targetKidId: targetKidId.present ? targetKidId.value : this.targetKidId,
    verifierLinkId: verifierLinkId.present
        ? verifierLinkId.value
        : this.verifierLinkId,
    xpReward: xpReward ?? this.xpReward,
    category: category ?? this.category,
    customCategory: customCategory.present
        ? customCategory.value
        : this.customCategory,
    remindAt: remindAt.present ? remindAt.value : this.remindAt,
    sortOrder: sortOrder ?? this.sortOrder,
    webdavEtag: webdavEtag.present ? webdavEtag.value : this.webdavEtag,
    syncState: syncState ?? this.syncState,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PersonalTaskRow copyWithCompanion(PersonalTasksCompanion data) {
    return PersonalTaskRow(
      id: data.id.present ? data.id.value : this.id,
      listId: data.listId.present ? data.listId.value : this.listId,
      title: data.title.present ? data.title.value : this.title,
      notes: data.notes.present ? data.notes.value : this.notes,
      priority: data.priority.present ? data.priority.value : this.priority,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      isAllDay: data.isAllDay.present ? data.isAllDay.value : this.isAllDay,
      recurrenceRule: data.recurrenceRule.present
          ? data.recurrenceRule.value
          : this.recurrenceRule,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      isFlagged: data.isFlagged.present ? data.isFlagged.value : this.isFlagged,
      isPrivate: data.isPrivate.present ? data.isPrivate.value : this.isPrivate,
      kidsTaskId: data.kidsTaskId.present
          ? data.kidsTaskId.value
          : this.kidsTaskId,
      targetKidId: data.targetKidId.present
          ? data.targetKidId.value
          : this.targetKidId,
      verifierLinkId: data.verifierLinkId.present
          ? data.verifierLinkId.value
          : this.verifierLinkId,
      xpReward: data.xpReward.present ? data.xpReward.value : this.xpReward,
      category: data.category.present ? data.category.value : this.category,
      customCategory: data.customCategory.present
          ? data.customCategory.value
          : this.customCategory,
      remindAt: data.remindAt.present ? data.remindAt.value : this.remindAt,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      webdavEtag: data.webdavEtag.present
          ? data.webdavEtag.value
          : this.webdavEtag,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PersonalTaskRow(')
          ..write('id: $id, ')
          ..write('listId: $listId, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('priority: $priority, ')
          ..write('dueDate: $dueDate, ')
          ..write('isAllDay: $isAllDay, ')
          ..write('recurrenceRule: $recurrenceRule, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('completedAt: $completedAt, ')
          ..write('isFlagged: $isFlagged, ')
          ..write('isPrivate: $isPrivate, ')
          ..write('kidsTaskId: $kidsTaskId, ')
          ..write('targetKidId: $targetKidId, ')
          ..write('verifierLinkId: $verifierLinkId, ')
          ..write('xpReward: $xpReward, ')
          ..write('category: $category, ')
          ..write('customCategory: $customCategory, ')
          ..write('remindAt: $remindAt, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('webdavEtag: $webdavEtag, ')
          ..write('syncState: $syncState, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    listId,
    title,
    notes,
    priority,
    dueDate,
    isAllDay,
    recurrenceRule,
    isCompleted,
    completedAt,
    isFlagged,
    isPrivate,
    kidsTaskId,
    targetKidId,
    verifierLinkId,
    xpReward,
    category,
    customCategory,
    remindAt,
    sortOrder,
    webdavEtag,
    syncState,
    createdAt,
    updatedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PersonalTaskRow &&
          other.id == this.id &&
          other.listId == this.listId &&
          other.title == this.title &&
          other.notes == this.notes &&
          other.priority == this.priority &&
          other.dueDate == this.dueDate &&
          other.isAllDay == this.isAllDay &&
          other.recurrenceRule == this.recurrenceRule &&
          other.isCompleted == this.isCompleted &&
          other.completedAt == this.completedAt &&
          other.isFlagged == this.isFlagged &&
          other.isPrivate == this.isPrivate &&
          other.kidsTaskId == this.kidsTaskId &&
          other.targetKidId == this.targetKidId &&
          other.verifierLinkId == this.verifierLinkId &&
          other.xpReward == this.xpReward &&
          other.category == this.category &&
          other.customCategory == this.customCategory &&
          other.remindAt == this.remindAt &&
          other.sortOrder == this.sortOrder &&
          other.webdavEtag == this.webdavEtag &&
          other.syncState == this.syncState &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PersonalTasksCompanion extends UpdateCompanion<PersonalTaskRow> {
  final Value<String> id;
  final Value<String?> listId;
  final Value<String> title;
  final Value<String?> notes;
  final Value<int> priority;
  final Value<DateTime?> dueDate;
  final Value<bool> isAllDay;
  final Value<String?> recurrenceRule;
  final Value<bool> isCompleted;
  final Value<DateTime?> completedAt;
  final Value<bool> isFlagged;
  final Value<bool> isPrivate;
  final Value<String?> kidsTaskId;
  final Value<String?> targetKidId;
  final Value<String?> verifierLinkId;
  final Value<int> xpReward;
  final Value<String> category;
  final Value<String?> customCategory;
  final Value<DateTime?> remindAt;
  final Value<int> sortOrder;
  final Value<String?> webdavEtag;
  final Value<String> syncState;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PersonalTasksCompanion({
    this.id = const Value.absent(),
    this.listId = const Value.absent(),
    this.title = const Value.absent(),
    this.notes = const Value.absent(),
    this.priority = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.isAllDay = const Value.absent(),
    this.recurrenceRule = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.isFlagged = const Value.absent(),
    this.isPrivate = const Value.absent(),
    this.kidsTaskId = const Value.absent(),
    this.targetKidId = const Value.absent(),
    this.verifierLinkId = const Value.absent(),
    this.xpReward = const Value.absent(),
    this.category = const Value.absent(),
    this.customCategory = const Value.absent(),
    this.remindAt = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.webdavEtag = const Value.absent(),
    this.syncState = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PersonalTasksCompanion.insert({
    required String id,
    this.listId = const Value.absent(),
    required String title,
    this.notes = const Value.absent(),
    this.priority = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.isAllDay = const Value.absent(),
    this.recurrenceRule = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.isFlagged = const Value.absent(),
    this.isPrivate = const Value.absent(),
    this.kidsTaskId = const Value.absent(),
    this.targetKidId = const Value.absent(),
    this.verifierLinkId = const Value.absent(),
    this.xpReward = const Value.absent(),
    this.category = const Value.absent(),
    this.customCategory = const Value.absent(),
    this.remindAt = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.webdavEtag = const Value.absent(),
    this.syncState = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<PersonalTaskRow> custom({
    Expression<String>? id,
    Expression<String>? listId,
    Expression<String>? title,
    Expression<String>? notes,
    Expression<int>? priority,
    Expression<DateTime>? dueDate,
    Expression<bool>? isAllDay,
    Expression<String>? recurrenceRule,
    Expression<bool>? isCompleted,
    Expression<DateTime>? completedAt,
    Expression<bool>? isFlagged,
    Expression<bool>? isPrivate,
    Expression<String>? kidsTaskId,
    Expression<String>? targetKidId,
    Expression<String>? verifierLinkId,
    Expression<int>? xpReward,
    Expression<String>? category,
    Expression<String>? customCategory,
    Expression<DateTime>? remindAt,
    Expression<int>? sortOrder,
    Expression<String>? webdavEtag,
    Expression<String>? syncState,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (listId != null) 'list_id': listId,
      if (title != null) 'title': title,
      if (notes != null) 'notes': notes,
      if (priority != null) 'priority': priority,
      if (dueDate != null) 'due_date': dueDate,
      if (isAllDay != null) 'is_all_day': isAllDay,
      if (recurrenceRule != null) 'recurrence_rule': recurrenceRule,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (completedAt != null) 'completed_at': completedAt,
      if (isFlagged != null) 'is_flagged': isFlagged,
      if (isPrivate != null) 'is_private': isPrivate,
      if (kidsTaskId != null) 'kids_task_id': kidsTaskId,
      if (targetKidId != null) 'target_kid_id': targetKidId,
      if (verifierLinkId != null) 'verifier_link_id': verifierLinkId,
      if (xpReward != null) 'xp_reward': xpReward,
      if (category != null) 'category': category,
      if (customCategory != null) 'custom_category': customCategory,
      if (remindAt != null) 'remind_at': remindAt,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (webdavEtag != null) 'webdav_etag': webdavEtag,
      if (syncState != null) 'sync_state': syncState,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PersonalTasksCompanion copyWith({
    Value<String>? id,
    Value<String?>? listId,
    Value<String>? title,
    Value<String?>? notes,
    Value<int>? priority,
    Value<DateTime?>? dueDate,
    Value<bool>? isAllDay,
    Value<String?>? recurrenceRule,
    Value<bool>? isCompleted,
    Value<DateTime?>? completedAt,
    Value<bool>? isFlagged,
    Value<bool>? isPrivate,
    Value<String?>? kidsTaskId,
    Value<String?>? targetKidId,
    Value<String?>? verifierLinkId,
    Value<int>? xpReward,
    Value<String>? category,
    Value<String?>? customCategory,
    Value<DateTime?>? remindAt,
    Value<int>? sortOrder,
    Value<String?>? webdavEtag,
    Value<String>? syncState,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PersonalTasksCompanion(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      isAllDay: isAllDay ?? this.isAllDay,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      isFlagged: isFlagged ?? this.isFlagged,
      isPrivate: isPrivate ?? this.isPrivate,
      kidsTaskId: kidsTaskId ?? this.kidsTaskId,
      targetKidId: targetKidId ?? this.targetKidId,
      verifierLinkId: verifierLinkId ?? this.verifierLinkId,
      xpReward: xpReward ?? this.xpReward,
      category: category ?? this.category,
      customCategory: customCategory ?? this.customCategory,
      remindAt: remindAt ?? this.remindAt,
      sortOrder: sortOrder ?? this.sortOrder,
      webdavEtag: webdavEtag ?? this.webdavEtag,
      syncState: syncState ?? this.syncState,
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
    if (listId.present) {
      map['list_id'] = Variable<String>(listId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (isAllDay.present) {
      map['is_all_day'] = Variable<bool>(isAllDay.value);
    }
    if (recurrenceRule.present) {
      map['recurrence_rule'] = Variable<String>(recurrenceRule.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (isFlagged.present) {
      map['is_flagged'] = Variable<bool>(isFlagged.value);
    }
    if (isPrivate.present) {
      map['is_private'] = Variable<bool>(isPrivate.value);
    }
    if (kidsTaskId.present) {
      map['kids_task_id'] = Variable<String>(kidsTaskId.value);
    }
    if (targetKidId.present) {
      map['target_kid_id'] = Variable<String>(targetKidId.value);
    }
    if (verifierLinkId.present) {
      map['verifier_link_id'] = Variable<String>(verifierLinkId.value);
    }
    if (xpReward.present) {
      map['xp_reward'] = Variable<int>(xpReward.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (customCategory.present) {
      map['custom_category'] = Variable<String>(customCategory.value);
    }
    if (remindAt.present) {
      map['remind_at'] = Variable<DateTime>(remindAt.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (webdavEtag.present) {
      map['webdav_etag'] = Variable<String>(webdavEtag.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PersonalTasksCompanion(')
          ..write('id: $id, ')
          ..write('listId: $listId, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('priority: $priority, ')
          ..write('dueDate: $dueDate, ')
          ..write('isAllDay: $isAllDay, ')
          ..write('recurrenceRule: $recurrenceRule, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('completedAt: $completedAt, ')
          ..write('isFlagged: $isFlagged, ')
          ..write('isPrivate: $isPrivate, ')
          ..write('kidsTaskId: $kidsTaskId, ')
          ..write('targetKidId: $targetKidId, ')
          ..write('verifierLinkId: $verifierLinkId, ')
          ..write('xpReward: $xpReward, ')
          ..write('category: $category, ')
          ..write('customCategory: $customCategory, ')
          ..write('remindAt: $remindAt, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('webdavEtag: $webdavEtag, ')
          ..write('syncState: $syncState, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PersonalNotesTable extends PersonalNotes
    with TableInfo<$PersonalNotesTable, PersonalNoteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PersonalNotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isSharedMeta = const VerificationMeta(
    'isShared',
  );
  @override
  late final GeneratedColumn<bool> isShared = GeneratedColumn<bool>(
    'is_shared',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_shared" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sharedMemberIdsMeta = const VerificationMeta(
    'sharedMemberIds',
  );
  @override
  late final GeneratedColumn<String> sharedMemberIds = GeneratedColumn<String>(
    'shared_member_ids',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remindAtMeta = const VerificationMeta(
    'remindAt',
  );
  @override
  late final GeneratedColumn<DateTime> remindAt = GeneratedColumn<DateTime>(
    'remind_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isContentHiddenMeta = const VerificationMeta(
    'isContentHidden',
  );
  @override
  late final GeneratedColumn<bool> isContentHidden = GeneratedColumn<bool>(
    'is_content_hidden',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_content_hidden" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isLocalOnlyMeta = const VerificationMeta(
    'isLocalOnly',
  );
  @override
  late final GeneratedColumn<bool> isLocalOnly = GeneratedColumn<bool>(
    'is_local_only',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_local_only" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _linkedTaskIdsMeta = const VerificationMeta(
    'linkedTaskIds',
  );
  @override
  late final GeneratedColumn<String> linkedTaskIds = GeneratedColumn<String>(
    'linked_task_ids',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _webdavEtagMeta = const VerificationMeta(
    'webdavEtag',
  );
  @override
  late final GeneratedColumn<String> webdavEtag = GeneratedColumn<String>(
    'webdav_etag',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    defaultValue: const Constant('dirty'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedByLinkIdMeta = const VerificationMeta(
    'updatedByLinkId',
  );
  @override
  late final GeneratedColumn<String> updatedByLinkId = GeneratedColumn<String>(
    'updated_by_link_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    body,
    isShared,
    sharedMemberIds,
    remindAt,
    category,
    sortOrder,
    isContentHidden,
    isLocalOnly,
    linkedTaskIds,
    webdavEtag,
    syncState,
    createdAt,
    updatedAt,
    updatedByLinkId,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'personal_notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<PersonalNoteRow> instance, {
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
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    }
    if (data.containsKey('is_shared')) {
      context.handle(
        _isSharedMeta,
        isShared.isAcceptableOrUnknown(data['is_shared']!, _isSharedMeta),
      );
    }
    if (data.containsKey('shared_member_ids')) {
      context.handle(
        _sharedMemberIdsMeta,
        sharedMemberIds.isAcceptableOrUnknown(
          data['shared_member_ids']!,
          _sharedMemberIdsMeta,
        ),
      );
    }
    if (data.containsKey('remind_at')) {
      context.handle(
        _remindAtMeta,
        remindAt.isAcceptableOrUnknown(data['remind_at']!, _remindAtMeta),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('is_content_hidden')) {
      context.handle(
        _isContentHiddenMeta,
        isContentHidden.isAcceptableOrUnknown(
          data['is_content_hidden']!,
          _isContentHiddenMeta,
        ),
      );
    }
    if (data.containsKey('is_local_only')) {
      context.handle(
        _isLocalOnlyMeta,
        isLocalOnly.isAcceptableOrUnknown(
          data['is_local_only']!,
          _isLocalOnlyMeta,
        ),
      );
    }
    if (data.containsKey('linked_task_ids')) {
      context.handle(
        _linkedTaskIdsMeta,
        linkedTaskIds.isAcceptableOrUnknown(
          data['linked_task_ids']!,
          _linkedTaskIdsMeta,
        ),
      );
    }
    if (data.containsKey('webdav_etag')) {
      context.handle(
        _webdavEtagMeta,
        webdavEtag.isAcceptableOrUnknown(data['webdav_etag']!, _webdavEtagMeta),
      );
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
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
    if (data.containsKey('updated_by_link_id')) {
      context.handle(
        _updatedByLinkIdMeta,
        updatedByLinkId.isAcceptableOrUnknown(
          data['updated_by_link_id']!,
          _updatedByLinkIdMeta,
        ),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PersonalNoteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PersonalNoteRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      isShared: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_shared'],
      )!,
      sharedMemberIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shared_member_ids'],
      ),
      remindAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}remind_at'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      isContentHidden: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_content_hidden'],
      )!,
      isLocalOnly: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_local_only'],
      )!,
      linkedTaskIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}linked_task_ids'],
      ),
      webdavEtag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}webdav_etag'],
      ),
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      updatedByLinkId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by_link_id'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $PersonalNotesTable createAlias(String alias) {
    return $PersonalNotesTable(attachedDatabase, alias);
  }
}

class PersonalNoteRow extends DataClass implements Insertable<PersonalNoteRow> {
  final String id;
  final String title;
  final String body;

  /// true = encrypted with family key and stored in shared WebDAV folder.
  final bool isShared;

  /// JSON list of link member ids; null/empty with [isShared] = all link members.
  final String? sharedMemberIds;
  final DateTime? remindAt;
  final String? category;
  final int sortOrder;

  /// When true, body is hidden in the notes list and opening requires
  /// device biometrics / PIN. Local-only flag (not synced); note body still
  /// syncs via WebDAV unless [isLocalOnly] is true.
  final bool isContentHidden;

  /// When true, this note never leaves the device (no WebDAV PUT). Local-only.
  final bool isLocalOnly;

  /// JSON list of [PersonalTasks.id] linked to this note (synced when not local-only).
  final String? linkedTaskIds;
  final String? webdavEtag;
  final String syncState;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Link member id of the last editor (synced for shared notes).
  final String? updatedByLinkId;

  /// Set when the note is moved to trash; null = active.
  final DateTime? deletedAt;
  const PersonalNoteRow({
    required this.id,
    required this.title,
    required this.body,
    required this.isShared,
    this.sharedMemberIds,
    this.remindAt,
    this.category,
    required this.sortOrder,
    required this.isContentHidden,
    required this.isLocalOnly,
    this.linkedTaskIds,
    this.webdavEtag,
    required this.syncState,
    required this.createdAt,
    required this.updatedAt,
    this.updatedByLinkId,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['body'] = Variable<String>(body);
    map['is_shared'] = Variable<bool>(isShared);
    if (!nullToAbsent || sharedMemberIds != null) {
      map['shared_member_ids'] = Variable<String>(sharedMemberIds);
    }
    if (!nullToAbsent || remindAt != null) {
      map['remind_at'] = Variable<DateTime>(remindAt);
    }
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_content_hidden'] = Variable<bool>(isContentHidden);
    map['is_local_only'] = Variable<bool>(isLocalOnly);
    if (!nullToAbsent || linkedTaskIds != null) {
      map['linked_task_ids'] = Variable<String>(linkedTaskIds);
    }
    if (!nullToAbsent || webdavEtag != null) {
      map['webdav_etag'] = Variable<String>(webdavEtag);
    }
    map['sync_state'] = Variable<String>(syncState);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || updatedByLinkId != null) {
      map['updated_by_link_id'] = Variable<String>(updatedByLinkId);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  PersonalNotesCompanion toCompanion(bool nullToAbsent) {
    return PersonalNotesCompanion(
      id: Value(id),
      title: Value(title),
      body: Value(body),
      isShared: Value(isShared),
      sharedMemberIds: sharedMemberIds == null && nullToAbsent
          ? const Value.absent()
          : Value(sharedMemberIds),
      remindAt: remindAt == null && nullToAbsent
          ? const Value.absent()
          : Value(remindAt),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      sortOrder: Value(sortOrder),
      isContentHidden: Value(isContentHidden),
      isLocalOnly: Value(isLocalOnly),
      linkedTaskIds: linkedTaskIds == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedTaskIds),
      webdavEtag: webdavEtag == null && nullToAbsent
          ? const Value.absent()
          : Value(webdavEtag),
      syncState: Value(syncState),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      updatedByLinkId: updatedByLinkId == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedByLinkId),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory PersonalNoteRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PersonalNoteRow(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      body: serializer.fromJson<String>(json['body']),
      isShared: serializer.fromJson<bool>(json['isShared']),
      sharedMemberIds: serializer.fromJson<String?>(json['sharedMemberIds']),
      remindAt: serializer.fromJson<DateTime?>(json['remindAt']),
      category: serializer.fromJson<String?>(json['category']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isContentHidden: serializer.fromJson<bool>(json['isContentHidden']),
      isLocalOnly: serializer.fromJson<bool>(json['isLocalOnly']),
      linkedTaskIds: serializer.fromJson<String?>(json['linkedTaskIds']),
      webdavEtag: serializer.fromJson<String?>(json['webdavEtag']),
      syncState: serializer.fromJson<String>(json['syncState']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      updatedByLinkId: serializer.fromJson<String?>(json['updatedByLinkId']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'body': serializer.toJson<String>(body),
      'isShared': serializer.toJson<bool>(isShared),
      'sharedMemberIds': serializer.toJson<String?>(sharedMemberIds),
      'remindAt': serializer.toJson<DateTime?>(remindAt),
      'category': serializer.toJson<String?>(category),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isContentHidden': serializer.toJson<bool>(isContentHidden),
      'isLocalOnly': serializer.toJson<bool>(isLocalOnly),
      'linkedTaskIds': serializer.toJson<String?>(linkedTaskIds),
      'webdavEtag': serializer.toJson<String?>(webdavEtag),
      'syncState': serializer.toJson<String>(syncState),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'updatedByLinkId': serializer.toJson<String?>(updatedByLinkId),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  PersonalNoteRow copyWith({
    String? id,
    String? title,
    String? body,
    bool? isShared,
    Value<String?> sharedMemberIds = const Value.absent(),
    Value<DateTime?> remindAt = const Value.absent(),
    Value<String?> category = const Value.absent(),
    int? sortOrder,
    bool? isContentHidden,
    bool? isLocalOnly,
    Value<String?> linkedTaskIds = const Value.absent(),
    Value<String?> webdavEtag = const Value.absent(),
    String? syncState,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<String?> updatedByLinkId = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => PersonalNoteRow(
    id: id ?? this.id,
    title: title ?? this.title,
    body: body ?? this.body,
    isShared: isShared ?? this.isShared,
    sharedMemberIds: sharedMemberIds.present
        ? sharedMemberIds.value
        : this.sharedMemberIds,
    remindAt: remindAt.present ? remindAt.value : this.remindAt,
    category: category.present ? category.value : this.category,
    sortOrder: sortOrder ?? this.sortOrder,
    isContentHidden: isContentHidden ?? this.isContentHidden,
    isLocalOnly: isLocalOnly ?? this.isLocalOnly,
    linkedTaskIds: linkedTaskIds.present
        ? linkedTaskIds.value
        : this.linkedTaskIds,
    webdavEtag: webdavEtag.present ? webdavEtag.value : this.webdavEtag,
    syncState: syncState ?? this.syncState,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    updatedByLinkId: updatedByLinkId.present
        ? updatedByLinkId.value
        : this.updatedByLinkId,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  PersonalNoteRow copyWithCompanion(PersonalNotesCompanion data) {
    return PersonalNoteRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      body: data.body.present ? data.body.value : this.body,
      isShared: data.isShared.present ? data.isShared.value : this.isShared,
      sharedMemberIds: data.sharedMemberIds.present
          ? data.sharedMemberIds.value
          : this.sharedMemberIds,
      remindAt: data.remindAt.present ? data.remindAt.value : this.remindAt,
      category: data.category.present ? data.category.value : this.category,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isContentHidden: data.isContentHidden.present
          ? data.isContentHidden.value
          : this.isContentHidden,
      isLocalOnly: data.isLocalOnly.present
          ? data.isLocalOnly.value
          : this.isLocalOnly,
      linkedTaskIds: data.linkedTaskIds.present
          ? data.linkedTaskIds.value
          : this.linkedTaskIds,
      webdavEtag: data.webdavEtag.present
          ? data.webdavEtag.value
          : this.webdavEtag,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      updatedByLinkId: data.updatedByLinkId.present
          ? data.updatedByLinkId.value
          : this.updatedByLinkId,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PersonalNoteRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('isShared: $isShared, ')
          ..write('sharedMemberIds: $sharedMemberIds, ')
          ..write('remindAt: $remindAt, ')
          ..write('category: $category, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isContentHidden: $isContentHidden, ')
          ..write('isLocalOnly: $isLocalOnly, ')
          ..write('linkedTaskIds: $linkedTaskIds, ')
          ..write('webdavEtag: $webdavEtag, ')
          ..write('syncState: $syncState, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedByLinkId: $updatedByLinkId, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    body,
    isShared,
    sharedMemberIds,
    remindAt,
    category,
    sortOrder,
    isContentHidden,
    isLocalOnly,
    linkedTaskIds,
    webdavEtag,
    syncState,
    createdAt,
    updatedAt,
    updatedByLinkId,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PersonalNoteRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.body == this.body &&
          other.isShared == this.isShared &&
          other.sharedMemberIds == this.sharedMemberIds &&
          other.remindAt == this.remindAt &&
          other.category == this.category &&
          other.sortOrder == this.sortOrder &&
          other.isContentHidden == this.isContentHidden &&
          other.isLocalOnly == this.isLocalOnly &&
          other.linkedTaskIds == this.linkedTaskIds &&
          other.webdavEtag == this.webdavEtag &&
          other.syncState == this.syncState &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.updatedByLinkId == this.updatedByLinkId &&
          other.deletedAt == this.deletedAt);
}

class PersonalNotesCompanion extends UpdateCompanion<PersonalNoteRow> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> body;
  final Value<bool> isShared;
  final Value<String?> sharedMemberIds;
  final Value<DateTime?> remindAt;
  final Value<String?> category;
  final Value<int> sortOrder;
  final Value<bool> isContentHidden;
  final Value<bool> isLocalOnly;
  final Value<String?> linkedTaskIds;
  final Value<String?> webdavEtag;
  final Value<String> syncState;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String?> updatedByLinkId;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const PersonalNotesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.isShared = const Value.absent(),
    this.sharedMemberIds = const Value.absent(),
    this.remindAt = const Value.absent(),
    this.category = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isContentHidden = const Value.absent(),
    this.isLocalOnly = const Value.absent(),
    this.linkedTaskIds = const Value.absent(),
    this.webdavEtag = const Value.absent(),
    this.syncState = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedByLinkId = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PersonalNotesCompanion.insert({
    required String id,
    required String title,
    this.body = const Value.absent(),
    this.isShared = const Value.absent(),
    this.sharedMemberIds = const Value.absent(),
    this.remindAt = const Value.absent(),
    this.category = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isContentHidden = const Value.absent(),
    this.isLocalOnly = const Value.absent(),
    this.linkedTaskIds = const Value.absent(),
    this.webdavEtag = const Value.absent(),
    this.syncState = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.updatedByLinkId = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<PersonalNoteRow> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? body,
    Expression<bool>? isShared,
    Expression<String>? sharedMemberIds,
    Expression<DateTime>? remindAt,
    Expression<String>? category,
    Expression<int>? sortOrder,
    Expression<bool>? isContentHidden,
    Expression<bool>? isLocalOnly,
    Expression<String>? linkedTaskIds,
    Expression<String>? webdavEtag,
    Expression<String>? syncState,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? updatedByLinkId,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (isShared != null) 'is_shared': isShared,
      if (sharedMemberIds != null) 'shared_member_ids': sharedMemberIds,
      if (remindAt != null) 'remind_at': remindAt,
      if (category != null) 'category': category,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isContentHidden != null) 'is_content_hidden': isContentHidden,
      if (isLocalOnly != null) 'is_local_only': isLocalOnly,
      if (linkedTaskIds != null) 'linked_task_ids': linkedTaskIds,
      if (webdavEtag != null) 'webdav_etag': webdavEtag,
      if (syncState != null) 'sync_state': syncState,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (updatedByLinkId != null) 'updated_by_link_id': updatedByLinkId,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PersonalNotesCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? body,
    Value<bool>? isShared,
    Value<String?>? sharedMemberIds,
    Value<DateTime?>? remindAt,
    Value<String?>? category,
    Value<int>? sortOrder,
    Value<bool>? isContentHidden,
    Value<bool>? isLocalOnly,
    Value<String?>? linkedTaskIds,
    Value<String?>? webdavEtag,
    Value<String>? syncState,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String?>? updatedByLinkId,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return PersonalNotesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      isShared: isShared ?? this.isShared,
      sharedMemberIds: sharedMemberIds ?? this.sharedMemberIds,
      remindAt: remindAt ?? this.remindAt,
      category: category ?? this.category,
      sortOrder: sortOrder ?? this.sortOrder,
      isContentHidden: isContentHidden ?? this.isContentHidden,
      isLocalOnly: isLocalOnly ?? this.isLocalOnly,
      linkedTaskIds: linkedTaskIds ?? this.linkedTaskIds,
      webdavEtag: webdavEtag ?? this.webdavEtag,
      syncState: syncState ?? this.syncState,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedByLinkId: updatedByLinkId ?? this.updatedByLinkId,
      deletedAt: deletedAt ?? this.deletedAt,
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
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (isShared.present) {
      map['is_shared'] = Variable<bool>(isShared.value);
    }
    if (sharedMemberIds.present) {
      map['shared_member_ids'] = Variable<String>(sharedMemberIds.value);
    }
    if (remindAt.present) {
      map['remind_at'] = Variable<DateTime>(remindAt.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isContentHidden.present) {
      map['is_content_hidden'] = Variable<bool>(isContentHidden.value);
    }
    if (isLocalOnly.present) {
      map['is_local_only'] = Variable<bool>(isLocalOnly.value);
    }
    if (linkedTaskIds.present) {
      map['linked_task_ids'] = Variable<String>(linkedTaskIds.value);
    }
    if (webdavEtag.present) {
      map['webdav_etag'] = Variable<String>(webdavEtag.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (updatedByLinkId.present) {
      map['updated_by_link_id'] = Variable<String>(updatedByLinkId.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PersonalNotesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('isShared: $isShared, ')
          ..write('sharedMemberIds: $sharedMemberIds, ')
          ..write('remindAt: $remindAt, ')
          ..write('category: $category, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isContentHidden: $isContentHidden, ')
          ..write('isLocalOnly: $isLocalOnly, ')
          ..write('linkedTaskIds: $linkedTaskIds, ')
          ..write('webdavEtag: $webdavEtag, ')
          ..write('syncState: $syncState, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedByLinkId: $updatedByLinkId, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PersonalSubtasksTable extends PersonalSubtasks
    with TableInfo<$PersonalSubtasksTable, PersonalSubtaskRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PersonalSubtasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES personal_tasks (id)',
    ),
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
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    taskId,
    title,
    isCompleted,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'personal_subtasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<PersonalSubtaskRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PersonalSubtaskRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PersonalSubtaskRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $PersonalSubtasksTable createAlias(String alias) {
    return $PersonalSubtasksTable(attachedDatabase, alias);
  }
}

class PersonalSubtaskRow extends DataClass
    implements Insertable<PersonalSubtaskRow> {
  final String id;
  final String taskId;
  final String title;
  final bool isCompleted;
  final int sortOrder;
  const PersonalSubtaskRow({
    required this.id,
    required this.taskId,
    required this.title,
    required this.isCompleted,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['task_id'] = Variable<String>(taskId);
    map['title'] = Variable<String>(title);
    map['is_completed'] = Variable<bool>(isCompleted);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  PersonalSubtasksCompanion toCompanion(bool nullToAbsent) {
    return PersonalSubtasksCompanion(
      id: Value(id),
      taskId: Value(taskId),
      title: Value(title),
      isCompleted: Value(isCompleted),
      sortOrder: Value(sortOrder),
    );
  }

  factory PersonalSubtaskRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PersonalSubtaskRow(
      id: serializer.fromJson<String>(json['id']),
      taskId: serializer.fromJson<String>(json['taskId']),
      title: serializer.fromJson<String>(json['title']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'taskId': serializer.toJson<String>(taskId),
      'title': serializer.toJson<String>(title),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  PersonalSubtaskRow copyWith({
    String? id,
    String? taskId,
    String? title,
    bool? isCompleted,
    int? sortOrder,
  }) => PersonalSubtaskRow(
    id: id ?? this.id,
    taskId: taskId ?? this.taskId,
    title: title ?? this.title,
    isCompleted: isCompleted ?? this.isCompleted,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  PersonalSubtaskRow copyWithCompanion(PersonalSubtasksCompanion data) {
    return PersonalSubtaskRow(
      id: data.id.present ? data.id.value : this.id,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      title: data.title.present ? data.title.value : this.title,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PersonalSubtaskRow(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('title: $title, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, taskId, title, isCompleted, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PersonalSubtaskRow &&
          other.id == this.id &&
          other.taskId == this.taskId &&
          other.title == this.title &&
          other.isCompleted == this.isCompleted &&
          other.sortOrder == this.sortOrder);
}

class PersonalSubtasksCompanion extends UpdateCompanion<PersonalSubtaskRow> {
  final Value<String> id;
  final Value<String> taskId;
  final Value<String> title;
  final Value<bool> isCompleted;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const PersonalSubtasksCompanion({
    this.id = const Value.absent(),
    this.taskId = const Value.absent(),
    this.title = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PersonalSubtasksCompanion.insert({
    required String id,
    required String taskId,
    required String title,
    this.isCompleted = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       taskId = Value(taskId),
       title = Value(title);
  static Insertable<PersonalSubtaskRow> custom({
    Expression<String>? id,
    Expression<String>? taskId,
    Expression<String>? title,
    Expression<bool>? isCompleted,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (taskId != null) 'task_id': taskId,
      if (title != null) 'title': title,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PersonalSubtasksCompanion copyWith({
    Value<String>? id,
    Value<String>? taskId,
    Value<String>? title,
    Value<bool>? isCompleted,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return PersonalSubtasksCompanion(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PersonalSubtasksCompanion(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('title: $title, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LinkMemberProposalsTable extends LinkMemberProposals
    with TableInfo<$LinkMemberProposalsTable, LinkMemberProposalRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LinkMemberProposalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fromLinkIdMeta = const VerificationMeta(
    'fromLinkId',
  );
  @override
  late final GeneratedColumn<String> fromLinkId = GeneratedColumn<String>(
    'from_link_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _toMemberIdMeta = const VerificationMeta(
    'toMemberId',
  );
  @override
  late final GeneratedColumn<String> toMemberId = GeneratedColumn<String>(
    'to_member_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _taskTitleMeta = const VerificationMeta(
    'taskTitle',
  );
  @override
  late final GeneratedColumn<String> taskTitle = GeneratedColumn<String>(
    'task_title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taskNotesMeta = const VerificationMeta(
    'taskNotes',
  );
  @override
  late final GeneratedColumn<String> taskNotes = GeneratedColumn<String>(
    'task_notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _taskCategoryMeta = const VerificationMeta(
    'taskCategory',
  );
  @override
  late final GeneratedColumn<String> taskCategory = GeneratedColumn<String>(
    'task_category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('other'),
  );
  static const VerificationMeta _taskPriorityMeta = const VerificationMeta(
    'taskPriority',
  );
  @override
  late final GeneratedColumn<int> taskPriority = GeneratedColumn<int>(
    'task_priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _taskDueDateMeta = const VerificationMeta(
    'taskDueDate',
  );
  @override
  late final GeneratedColumn<DateTime> taskDueDate = GeneratedColumn<DateTime>(
    'task_due_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _autoGeneratedMeta = const VerificationMeta(
    'autoGenerated',
  );
  @override
  late final GeneratedColumn<bool> autoGenerated = GeneratedColumn<bool>(
    'auto_generated',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("auto_generated" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
    defaultValue: const Constant('clean'),
  );
  static const VerificationMeta _sourceTaskIdMeta = const VerificationMeta(
    'sourceTaskId',
  );
  @override
  late final GeneratedColumn<String> sourceTaskId = GeneratedColumn<String>(
    'source_task_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _resultTaskIdMeta = const VerificationMeta(
    'resultTaskId',
  );
  @override
  late final GeneratedColumn<String> resultTaskId = GeneratedColumn<String>(
    'result_task_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _receivedAtMeta = const VerificationMeta(
    'receivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> receivedAt = GeneratedColumn<DateTime>(
    'received_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    fromLinkId,
    toMemberId,
    taskTitle,
    taskNotes,
    taskCategory,
    taskPriority,
    taskDueDate,
    status,
    autoGenerated,
    syncState,
    sourceTaskId,
    resultTaskId,
    receivedAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'link_member_proposals';
  @override
  VerificationContext validateIntegrity(
    Insertable<LinkMemberProposalRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('from_link_id')) {
      context.handle(
        _fromLinkIdMeta,
        fromLinkId.isAcceptableOrUnknown(
          data['from_link_id']!,
          _fromLinkIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fromLinkIdMeta);
    }
    if (data.containsKey('to_member_id')) {
      context.handle(
        _toMemberIdMeta,
        toMemberId.isAcceptableOrUnknown(
          data['to_member_id']!,
          _toMemberIdMeta,
        ),
      );
    }
    if (data.containsKey('task_title')) {
      context.handle(
        _taskTitleMeta,
        taskTitle.isAcceptableOrUnknown(data['task_title']!, _taskTitleMeta),
      );
    } else if (isInserting) {
      context.missing(_taskTitleMeta);
    }
    if (data.containsKey('task_notes')) {
      context.handle(
        _taskNotesMeta,
        taskNotes.isAcceptableOrUnknown(data['task_notes']!, _taskNotesMeta),
      );
    }
    if (data.containsKey('task_category')) {
      context.handle(
        _taskCategoryMeta,
        taskCategory.isAcceptableOrUnknown(
          data['task_category']!,
          _taskCategoryMeta,
        ),
      );
    }
    if (data.containsKey('task_priority')) {
      context.handle(
        _taskPriorityMeta,
        taskPriority.isAcceptableOrUnknown(
          data['task_priority']!,
          _taskPriorityMeta,
        ),
      );
    }
    if (data.containsKey('task_due_date')) {
      context.handle(
        _taskDueDateMeta,
        taskDueDate.isAcceptableOrUnknown(
          data['task_due_date']!,
          _taskDueDateMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('auto_generated')) {
      context.handle(
        _autoGeneratedMeta,
        autoGenerated.isAcceptableOrUnknown(
          data['auto_generated']!,
          _autoGeneratedMeta,
        ),
      );
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    if (data.containsKey('source_task_id')) {
      context.handle(
        _sourceTaskIdMeta,
        sourceTaskId.isAcceptableOrUnknown(
          data['source_task_id']!,
          _sourceTaskIdMeta,
        ),
      );
    }
    if (data.containsKey('result_task_id')) {
      context.handle(
        _resultTaskIdMeta,
        resultTaskId.isAcceptableOrUnknown(
          data['result_task_id']!,
          _resultTaskIdMeta,
        ),
      );
    }
    if (data.containsKey('received_at')) {
      context.handle(
        _receivedAtMeta,
        receivedAt.isAcceptableOrUnknown(data['received_at']!, _receivedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_receivedAtMeta);
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
  LinkMemberProposalRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LinkMemberProposalRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      fromLinkId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}from_link_id'],
      )!,
      toMemberId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}to_member_id'],
      ),
      taskTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_title'],
      )!,
      taskNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_notes'],
      ),
      taskCategory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_category'],
      )!,
      taskPriority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}task_priority'],
      )!,
      taskDueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}task_due_date'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      autoGenerated: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}auto_generated'],
      )!,
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
      sourceTaskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_task_id'],
      ),
      resultTaskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}result_task_id'],
      ),
      receivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}received_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LinkMemberProposalsTable createAlias(String alias) {
    return $LinkMemberProposalsTable(attachedDatabase, alias);
  }
}

class LinkMemberProposalRow extends DataClass
    implements Insertable<LinkMemberProposalRow> {
  final String id;
  final String fromLinkId;

  /// Target link member id; null = any / all other link members (legacy).
  final String? toMemberId;
  final String taskTitle;
  final String? taskNotes;
  final String taskCategory;
  final int taskPriority;
  final DateTime? taskDueDate;
  final String status;
  final bool autoGenerated;
  final String syncState;

  /// Sender's personal task id when this proposal was created (link→link send).
  final String? sourceTaskId;

  /// Receiver's personal task id created when this proposal was accepted.
  final String? resultTaskId;
  final DateTime receivedAt;
  final DateTime updatedAt;
  const LinkMemberProposalRow({
    required this.id,
    required this.fromLinkId,
    this.toMemberId,
    required this.taskTitle,
    this.taskNotes,
    required this.taskCategory,
    required this.taskPriority,
    this.taskDueDate,
    required this.status,
    required this.autoGenerated,
    required this.syncState,
    this.sourceTaskId,
    this.resultTaskId,
    required this.receivedAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['from_link_id'] = Variable<String>(fromLinkId);
    if (!nullToAbsent || toMemberId != null) {
      map['to_member_id'] = Variable<String>(toMemberId);
    }
    map['task_title'] = Variable<String>(taskTitle);
    if (!nullToAbsent || taskNotes != null) {
      map['task_notes'] = Variable<String>(taskNotes);
    }
    map['task_category'] = Variable<String>(taskCategory);
    map['task_priority'] = Variable<int>(taskPriority);
    if (!nullToAbsent || taskDueDate != null) {
      map['task_due_date'] = Variable<DateTime>(taskDueDate);
    }
    map['status'] = Variable<String>(status);
    map['auto_generated'] = Variable<bool>(autoGenerated);
    map['sync_state'] = Variable<String>(syncState);
    if (!nullToAbsent || sourceTaskId != null) {
      map['source_task_id'] = Variable<String>(sourceTaskId);
    }
    if (!nullToAbsent || resultTaskId != null) {
      map['result_task_id'] = Variable<String>(resultTaskId);
    }
    map['received_at'] = Variable<DateTime>(receivedAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LinkMemberProposalsCompanion toCompanion(bool nullToAbsent) {
    return LinkMemberProposalsCompanion(
      id: Value(id),
      fromLinkId: Value(fromLinkId),
      toMemberId: toMemberId == null && nullToAbsent
          ? const Value.absent()
          : Value(toMemberId),
      taskTitle: Value(taskTitle),
      taskNotes: taskNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(taskNotes),
      taskCategory: Value(taskCategory),
      taskPriority: Value(taskPriority),
      taskDueDate: taskDueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(taskDueDate),
      status: Value(status),
      autoGenerated: Value(autoGenerated),
      syncState: Value(syncState),
      sourceTaskId: sourceTaskId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceTaskId),
      resultTaskId: resultTaskId == null && nullToAbsent
          ? const Value.absent()
          : Value(resultTaskId),
      receivedAt: Value(receivedAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory LinkMemberProposalRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LinkMemberProposalRow(
      id: serializer.fromJson<String>(json['id']),
      fromLinkId: serializer.fromJson<String>(json['fromLinkId']),
      toMemberId: serializer.fromJson<String?>(json['toMemberId']),
      taskTitle: serializer.fromJson<String>(json['taskTitle']),
      taskNotes: serializer.fromJson<String?>(json['taskNotes']),
      taskCategory: serializer.fromJson<String>(json['taskCategory']),
      taskPriority: serializer.fromJson<int>(json['taskPriority']),
      taskDueDate: serializer.fromJson<DateTime?>(json['taskDueDate']),
      status: serializer.fromJson<String>(json['status']),
      autoGenerated: serializer.fromJson<bool>(json['autoGenerated']),
      syncState: serializer.fromJson<String>(json['syncState']),
      sourceTaskId: serializer.fromJson<String?>(json['sourceTaskId']),
      resultTaskId: serializer.fromJson<String?>(json['resultTaskId']),
      receivedAt: serializer.fromJson<DateTime>(json['receivedAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'fromLinkId': serializer.toJson<String>(fromLinkId),
      'toMemberId': serializer.toJson<String?>(toMemberId),
      'taskTitle': serializer.toJson<String>(taskTitle),
      'taskNotes': serializer.toJson<String?>(taskNotes),
      'taskCategory': serializer.toJson<String>(taskCategory),
      'taskPriority': serializer.toJson<int>(taskPriority),
      'taskDueDate': serializer.toJson<DateTime?>(taskDueDate),
      'status': serializer.toJson<String>(status),
      'autoGenerated': serializer.toJson<bool>(autoGenerated),
      'syncState': serializer.toJson<String>(syncState),
      'sourceTaskId': serializer.toJson<String?>(sourceTaskId),
      'resultTaskId': serializer.toJson<String?>(resultTaskId),
      'receivedAt': serializer.toJson<DateTime>(receivedAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LinkMemberProposalRow copyWith({
    String? id,
    String? fromLinkId,
    Value<String?> toMemberId = const Value.absent(),
    String? taskTitle,
    Value<String?> taskNotes = const Value.absent(),
    String? taskCategory,
    int? taskPriority,
    Value<DateTime?> taskDueDate = const Value.absent(),
    String? status,
    bool? autoGenerated,
    String? syncState,
    Value<String?> sourceTaskId = const Value.absent(),
    Value<String?> resultTaskId = const Value.absent(),
    DateTime? receivedAt,
    DateTime? updatedAt,
  }) => LinkMemberProposalRow(
    id: id ?? this.id,
    fromLinkId: fromLinkId ?? this.fromLinkId,
    toMemberId: toMemberId.present ? toMemberId.value : this.toMemberId,
    taskTitle: taskTitle ?? this.taskTitle,
    taskNotes: taskNotes.present ? taskNotes.value : this.taskNotes,
    taskCategory: taskCategory ?? this.taskCategory,
    taskPriority: taskPriority ?? this.taskPriority,
    taskDueDate: taskDueDate.present ? taskDueDate.value : this.taskDueDate,
    status: status ?? this.status,
    autoGenerated: autoGenerated ?? this.autoGenerated,
    syncState: syncState ?? this.syncState,
    sourceTaskId: sourceTaskId.present ? sourceTaskId.value : this.sourceTaskId,
    resultTaskId: resultTaskId.present ? resultTaskId.value : this.resultTaskId,
    receivedAt: receivedAt ?? this.receivedAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LinkMemberProposalRow copyWithCompanion(LinkMemberProposalsCompanion data) {
    return LinkMemberProposalRow(
      id: data.id.present ? data.id.value : this.id,
      fromLinkId: data.fromLinkId.present
          ? data.fromLinkId.value
          : this.fromLinkId,
      toMemberId: data.toMemberId.present
          ? data.toMemberId.value
          : this.toMemberId,
      taskTitle: data.taskTitle.present ? data.taskTitle.value : this.taskTitle,
      taskNotes: data.taskNotes.present ? data.taskNotes.value : this.taskNotes,
      taskCategory: data.taskCategory.present
          ? data.taskCategory.value
          : this.taskCategory,
      taskPriority: data.taskPriority.present
          ? data.taskPriority.value
          : this.taskPriority,
      taskDueDate: data.taskDueDate.present
          ? data.taskDueDate.value
          : this.taskDueDate,
      status: data.status.present ? data.status.value : this.status,
      autoGenerated: data.autoGenerated.present
          ? data.autoGenerated.value
          : this.autoGenerated,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      sourceTaskId: data.sourceTaskId.present
          ? data.sourceTaskId.value
          : this.sourceTaskId,
      resultTaskId: data.resultTaskId.present
          ? data.resultTaskId.value
          : this.resultTaskId,
      receivedAt: data.receivedAt.present
          ? data.receivedAt.value
          : this.receivedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LinkMemberProposalRow(')
          ..write('id: $id, ')
          ..write('fromLinkId: $fromLinkId, ')
          ..write('toMemberId: $toMemberId, ')
          ..write('taskTitle: $taskTitle, ')
          ..write('taskNotes: $taskNotes, ')
          ..write('taskCategory: $taskCategory, ')
          ..write('taskPriority: $taskPriority, ')
          ..write('taskDueDate: $taskDueDate, ')
          ..write('status: $status, ')
          ..write('autoGenerated: $autoGenerated, ')
          ..write('syncState: $syncState, ')
          ..write('sourceTaskId: $sourceTaskId, ')
          ..write('resultTaskId: $resultTaskId, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    fromLinkId,
    toMemberId,
    taskTitle,
    taskNotes,
    taskCategory,
    taskPriority,
    taskDueDate,
    status,
    autoGenerated,
    syncState,
    sourceTaskId,
    resultTaskId,
    receivedAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LinkMemberProposalRow &&
          other.id == this.id &&
          other.fromLinkId == this.fromLinkId &&
          other.toMemberId == this.toMemberId &&
          other.taskTitle == this.taskTitle &&
          other.taskNotes == this.taskNotes &&
          other.taskCategory == this.taskCategory &&
          other.taskPriority == this.taskPriority &&
          other.taskDueDate == this.taskDueDate &&
          other.status == this.status &&
          other.autoGenerated == this.autoGenerated &&
          other.syncState == this.syncState &&
          other.sourceTaskId == this.sourceTaskId &&
          other.resultTaskId == this.resultTaskId &&
          other.receivedAt == this.receivedAt &&
          other.updatedAt == this.updatedAt);
}

class LinkMemberProposalsCompanion
    extends UpdateCompanion<LinkMemberProposalRow> {
  final Value<String> id;
  final Value<String> fromLinkId;
  final Value<String?> toMemberId;
  final Value<String> taskTitle;
  final Value<String?> taskNotes;
  final Value<String> taskCategory;
  final Value<int> taskPriority;
  final Value<DateTime?> taskDueDate;
  final Value<String> status;
  final Value<bool> autoGenerated;
  final Value<String> syncState;
  final Value<String?> sourceTaskId;
  final Value<String?> resultTaskId;
  final Value<DateTime> receivedAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LinkMemberProposalsCompanion({
    this.id = const Value.absent(),
    this.fromLinkId = const Value.absent(),
    this.toMemberId = const Value.absent(),
    this.taskTitle = const Value.absent(),
    this.taskNotes = const Value.absent(),
    this.taskCategory = const Value.absent(),
    this.taskPriority = const Value.absent(),
    this.taskDueDate = const Value.absent(),
    this.status = const Value.absent(),
    this.autoGenerated = const Value.absent(),
    this.syncState = const Value.absent(),
    this.sourceTaskId = const Value.absent(),
    this.resultTaskId = const Value.absent(),
    this.receivedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LinkMemberProposalsCompanion.insert({
    required String id,
    required String fromLinkId,
    this.toMemberId = const Value.absent(),
    required String taskTitle,
    this.taskNotes = const Value.absent(),
    this.taskCategory = const Value.absent(),
    this.taskPriority = const Value.absent(),
    this.taskDueDate = const Value.absent(),
    this.status = const Value.absent(),
    this.autoGenerated = const Value.absent(),
    this.syncState = const Value.absent(),
    this.sourceTaskId = const Value.absent(),
    this.resultTaskId = const Value.absent(),
    required DateTime receivedAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       fromLinkId = Value(fromLinkId),
       taskTitle = Value(taskTitle),
       receivedAt = Value(receivedAt),
       updatedAt = Value(updatedAt);
  static Insertable<LinkMemberProposalRow> custom({
    Expression<String>? id,
    Expression<String>? fromLinkId,
    Expression<String>? toMemberId,
    Expression<String>? taskTitle,
    Expression<String>? taskNotes,
    Expression<String>? taskCategory,
    Expression<int>? taskPriority,
    Expression<DateTime>? taskDueDate,
    Expression<String>? status,
    Expression<bool>? autoGenerated,
    Expression<String>? syncState,
    Expression<String>? sourceTaskId,
    Expression<String>? resultTaskId,
    Expression<DateTime>? receivedAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fromLinkId != null) 'from_link_id': fromLinkId,
      if (toMemberId != null) 'to_member_id': toMemberId,
      if (taskTitle != null) 'task_title': taskTitle,
      if (taskNotes != null) 'task_notes': taskNotes,
      if (taskCategory != null) 'task_category': taskCategory,
      if (taskPriority != null) 'task_priority': taskPriority,
      if (taskDueDate != null) 'task_due_date': taskDueDate,
      if (status != null) 'status': status,
      if (autoGenerated != null) 'auto_generated': autoGenerated,
      if (syncState != null) 'sync_state': syncState,
      if (sourceTaskId != null) 'source_task_id': sourceTaskId,
      if (resultTaskId != null) 'result_task_id': resultTaskId,
      if (receivedAt != null) 'received_at': receivedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LinkMemberProposalsCompanion copyWith({
    Value<String>? id,
    Value<String>? fromLinkId,
    Value<String?>? toMemberId,
    Value<String>? taskTitle,
    Value<String?>? taskNotes,
    Value<String>? taskCategory,
    Value<int>? taskPriority,
    Value<DateTime?>? taskDueDate,
    Value<String>? status,
    Value<bool>? autoGenerated,
    Value<String>? syncState,
    Value<String?>? sourceTaskId,
    Value<String?>? resultTaskId,
    Value<DateTime>? receivedAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LinkMemberProposalsCompanion(
      id: id ?? this.id,
      fromLinkId: fromLinkId ?? this.fromLinkId,
      toMemberId: toMemberId ?? this.toMemberId,
      taskTitle: taskTitle ?? this.taskTitle,
      taskNotes: taskNotes ?? this.taskNotes,
      taskCategory: taskCategory ?? this.taskCategory,
      taskPriority: taskPriority ?? this.taskPriority,
      taskDueDate: taskDueDate ?? this.taskDueDate,
      status: status ?? this.status,
      autoGenerated: autoGenerated ?? this.autoGenerated,
      syncState: syncState ?? this.syncState,
      sourceTaskId: sourceTaskId ?? this.sourceTaskId,
      resultTaskId: resultTaskId ?? this.resultTaskId,
      receivedAt: receivedAt ?? this.receivedAt,
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
    if (fromLinkId.present) {
      map['from_link_id'] = Variable<String>(fromLinkId.value);
    }
    if (toMemberId.present) {
      map['to_member_id'] = Variable<String>(toMemberId.value);
    }
    if (taskTitle.present) {
      map['task_title'] = Variable<String>(taskTitle.value);
    }
    if (taskNotes.present) {
      map['task_notes'] = Variable<String>(taskNotes.value);
    }
    if (taskCategory.present) {
      map['task_category'] = Variable<String>(taskCategory.value);
    }
    if (taskPriority.present) {
      map['task_priority'] = Variable<int>(taskPriority.value);
    }
    if (taskDueDate.present) {
      map['task_due_date'] = Variable<DateTime>(taskDueDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (autoGenerated.present) {
      map['auto_generated'] = Variable<bool>(autoGenerated.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (sourceTaskId.present) {
      map['source_task_id'] = Variable<String>(sourceTaskId.value);
    }
    if (resultTaskId.present) {
      map['result_task_id'] = Variable<String>(resultTaskId.value);
    }
    if (receivedAt.present) {
      map['received_at'] = Variable<DateTime>(receivedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LinkMemberProposalsCompanion(')
          ..write('id: $id, ')
          ..write('fromLinkId: $fromLinkId, ')
          ..write('toMemberId: $toMemberId, ')
          ..write('taskTitle: $taskTitle, ')
          ..write('taskNotes: $taskNotes, ')
          ..write('taskCategory: $taskCategory, ')
          ..write('taskPriority: $taskPriority, ')
          ..write('taskDueDate: $taskDueDate, ')
          ..write('status: $status, ')
          ..write('autoGenerated: $autoGenerated, ')
          ..write('syncState: $syncState, ')
          ..write('sourceTaskId: $sourceTaskId, ')
          ..write('resultTaskId: $resultTaskId, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSettingsRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
    defaultValue: const Constant('default'),
  );
  static const VerificationMeta _themeMeta = const VerificationMeta('theme');
  @override
  late final GeneratedColumn<String> theme = GeneratedColumn<String>(
    'theme',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('dark'),
  );
  static const VerificationMeta _localeCodeMeta = const VerificationMeta(
    'localeCode',
  );
  @override
  late final GeneratedColumn<String> localeCode = GeneratedColumn<String>(
    'locale_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('en'),
  );
  static const VerificationMeta _taskCategoryOrderMeta = const VerificationMeta(
    'taskCategoryOrder',
  );
  @override
  late final GeneratedColumn<String> taskCategoryOrder =
      GeneratedColumn<String>(
        'task_category_order',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _noteCategoryOrderMeta = const VerificationMeta(
    'noteCategoryOrder',
  );
  @override
  late final GeneratedColumn<String> noteCategoryOrder =
      GeneratedColumn<String>(
        'note_category_order',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastSuggestionRunAtMeta =
      const VerificationMeta('lastSuggestionRunAt');
  @override
  late final GeneratedColumn<DateTime> lastSuggestionRunAt =
      GeneratedColumn<DateTime>(
        'last_suggestion_run_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastFamilyMemberSuggestionRunAtMeta =
      const VerificationMeta('lastFamilyMemberSuggestionRunAt');
  @override
  late final GeneratedColumn<DateTime> lastFamilyMemberSuggestionRunAt =
      GeneratedColumn<DateTime>(
        'last_family_member_suggestion_run_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    key,
    theme,
    localeCode,
    taskCategoryOrder,
    noteCategoryOrder,
    lastSuggestionRunAt,
    lastFamilyMemberSuggestionRunAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSettingsRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    }
    if (data.containsKey('theme')) {
      context.handle(
        _themeMeta,
        theme.isAcceptableOrUnknown(data['theme']!, _themeMeta),
      );
    }
    if (data.containsKey('locale_code')) {
      context.handle(
        _localeCodeMeta,
        localeCode.isAcceptableOrUnknown(data['locale_code']!, _localeCodeMeta),
      );
    }
    if (data.containsKey('task_category_order')) {
      context.handle(
        _taskCategoryOrderMeta,
        taskCategoryOrder.isAcceptableOrUnknown(
          data['task_category_order']!,
          _taskCategoryOrderMeta,
        ),
      );
    }
    if (data.containsKey('note_category_order')) {
      context.handle(
        _noteCategoryOrderMeta,
        noteCategoryOrder.isAcceptableOrUnknown(
          data['note_category_order']!,
          _noteCategoryOrderMeta,
        ),
      );
    }
    if (data.containsKey('last_suggestion_run_at')) {
      context.handle(
        _lastSuggestionRunAtMeta,
        lastSuggestionRunAt.isAcceptableOrUnknown(
          data['last_suggestion_run_at']!,
          _lastSuggestionRunAtMeta,
        ),
      );
    }
    if (data.containsKey('last_family_member_suggestion_run_at')) {
      context.handle(
        _lastFamilyMemberSuggestionRunAtMeta,
        lastFamilyMemberSuggestionRunAt.isAcceptableOrUnknown(
          data['last_family_member_suggestion_run_at']!,
          _lastFamilyMemberSuggestionRunAtMeta,
        ),
      );
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
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSettingsRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettingsRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      theme: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theme'],
      )!,
      localeCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locale_code'],
      )!,
      taskCategoryOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_category_order'],
      ),
      noteCategoryOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note_category_order'],
      ),
      lastSuggestionRunAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_suggestion_run_at'],
      ),
      lastFamilyMemberSuggestionRunAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_family_member_suggestion_run_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSettingsRow extends DataClass implements Insertable<AppSettingsRow> {
  final String key;
  final String theme;
  final String localeCode;
  final String? taskCategoryOrder;
  final String? noteCategoryOrder;
  final DateTime? lastSuggestionRunAt;
  final DateTime? lastFamilyMemberSuggestionRunAt;
  final DateTime updatedAt;
  const AppSettingsRow({
    required this.key,
    required this.theme,
    required this.localeCode,
    this.taskCategoryOrder,
    this.noteCategoryOrder,
    this.lastSuggestionRunAt,
    this.lastFamilyMemberSuggestionRunAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['theme'] = Variable<String>(theme);
    map['locale_code'] = Variable<String>(localeCode);
    if (!nullToAbsent || taskCategoryOrder != null) {
      map['task_category_order'] = Variable<String>(taskCategoryOrder);
    }
    if (!nullToAbsent || noteCategoryOrder != null) {
      map['note_category_order'] = Variable<String>(noteCategoryOrder);
    }
    if (!nullToAbsent || lastSuggestionRunAt != null) {
      map['last_suggestion_run_at'] = Variable<DateTime>(lastSuggestionRunAt);
    }
    if (!nullToAbsent || lastFamilyMemberSuggestionRunAt != null) {
      map['last_family_member_suggestion_run_at'] = Variable<DateTime>(
        lastFamilyMemberSuggestionRunAt,
      );
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      key: Value(key),
      theme: Value(theme),
      localeCode: Value(localeCode),
      taskCategoryOrder: taskCategoryOrder == null && nullToAbsent
          ? const Value.absent()
          : Value(taskCategoryOrder),
      noteCategoryOrder: noteCategoryOrder == null && nullToAbsent
          ? const Value.absent()
          : Value(noteCategoryOrder),
      lastSuggestionRunAt: lastSuggestionRunAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSuggestionRunAt),
      lastFamilyMemberSuggestionRunAt:
          lastFamilyMemberSuggestionRunAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastFamilyMemberSuggestionRunAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory AppSettingsRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettingsRow(
      key: serializer.fromJson<String>(json['key']),
      theme: serializer.fromJson<String>(json['theme']),
      localeCode: serializer.fromJson<String>(json['localeCode']),
      taskCategoryOrder: serializer.fromJson<String?>(
        json['taskCategoryOrder'],
      ),
      noteCategoryOrder: serializer.fromJson<String?>(
        json['noteCategoryOrder'],
      ),
      lastSuggestionRunAt: serializer.fromJson<DateTime?>(
        json['lastSuggestionRunAt'],
      ),
      lastFamilyMemberSuggestionRunAt: serializer.fromJson<DateTime?>(
        json['lastFamilyMemberSuggestionRunAt'],
      ),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'theme': serializer.toJson<String>(theme),
      'localeCode': serializer.toJson<String>(localeCode),
      'taskCategoryOrder': serializer.toJson<String?>(taskCategoryOrder),
      'noteCategoryOrder': serializer.toJson<String?>(noteCategoryOrder),
      'lastSuggestionRunAt': serializer.toJson<DateTime?>(lastSuggestionRunAt),
      'lastFamilyMemberSuggestionRunAt': serializer.toJson<DateTime?>(
        lastFamilyMemberSuggestionRunAt,
      ),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AppSettingsRow copyWith({
    String? key,
    String? theme,
    String? localeCode,
    Value<String?> taskCategoryOrder = const Value.absent(),
    Value<String?> noteCategoryOrder = const Value.absent(),
    Value<DateTime?> lastSuggestionRunAt = const Value.absent(),
    Value<DateTime?> lastFamilyMemberSuggestionRunAt = const Value.absent(),
    DateTime? updatedAt,
  }) => AppSettingsRow(
    key: key ?? this.key,
    theme: theme ?? this.theme,
    localeCode: localeCode ?? this.localeCode,
    taskCategoryOrder: taskCategoryOrder.present
        ? taskCategoryOrder.value
        : this.taskCategoryOrder,
    noteCategoryOrder: noteCategoryOrder.present
        ? noteCategoryOrder.value
        : this.noteCategoryOrder,
    lastSuggestionRunAt: lastSuggestionRunAt.present
        ? lastSuggestionRunAt.value
        : this.lastSuggestionRunAt,
    lastFamilyMemberSuggestionRunAt: lastFamilyMemberSuggestionRunAt.present
        ? lastFamilyMemberSuggestionRunAt.value
        : this.lastFamilyMemberSuggestionRunAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AppSettingsRow copyWithCompanion(AppSettingsCompanion data) {
    return AppSettingsRow(
      key: data.key.present ? data.key.value : this.key,
      theme: data.theme.present ? data.theme.value : this.theme,
      localeCode: data.localeCode.present
          ? data.localeCode.value
          : this.localeCode,
      taskCategoryOrder: data.taskCategoryOrder.present
          ? data.taskCategoryOrder.value
          : this.taskCategoryOrder,
      noteCategoryOrder: data.noteCategoryOrder.present
          ? data.noteCategoryOrder.value
          : this.noteCategoryOrder,
      lastSuggestionRunAt: data.lastSuggestionRunAt.present
          ? data.lastSuggestionRunAt.value
          : this.lastSuggestionRunAt,
      lastFamilyMemberSuggestionRunAt:
          data.lastFamilyMemberSuggestionRunAt.present
          ? data.lastFamilyMemberSuggestionRunAt.value
          : this.lastFamilyMemberSuggestionRunAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsRow(')
          ..write('key: $key, ')
          ..write('theme: $theme, ')
          ..write('localeCode: $localeCode, ')
          ..write('taskCategoryOrder: $taskCategoryOrder, ')
          ..write('noteCategoryOrder: $noteCategoryOrder, ')
          ..write('lastSuggestionRunAt: $lastSuggestionRunAt, ')
          ..write(
            'lastFamilyMemberSuggestionRunAt: $lastFamilyMemberSuggestionRunAt, ',
          )
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    key,
    theme,
    localeCode,
    taskCategoryOrder,
    noteCategoryOrder,
    lastSuggestionRunAt,
    lastFamilyMemberSuggestionRunAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettingsRow &&
          other.key == this.key &&
          other.theme == this.theme &&
          other.localeCode == this.localeCode &&
          other.taskCategoryOrder == this.taskCategoryOrder &&
          other.noteCategoryOrder == this.noteCategoryOrder &&
          other.lastSuggestionRunAt == this.lastSuggestionRunAt &&
          other.lastFamilyMemberSuggestionRunAt ==
              this.lastFamilyMemberSuggestionRunAt &&
          other.updatedAt == this.updatedAt);
}

class AppSettingsCompanion extends UpdateCompanion<AppSettingsRow> {
  final Value<String> key;
  final Value<String> theme;
  final Value<String> localeCode;
  final Value<String?> taskCategoryOrder;
  final Value<String?> noteCategoryOrder;
  final Value<DateTime?> lastSuggestionRunAt;
  final Value<DateTime?> lastFamilyMemberSuggestionRunAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.theme = const Value.absent(),
    this.localeCode = const Value.absent(),
    this.taskCategoryOrder = const Value.absent(),
    this.noteCategoryOrder = const Value.absent(),
    this.lastSuggestionRunAt = const Value.absent(),
    this.lastFamilyMemberSuggestionRunAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    this.key = const Value.absent(),
    this.theme = const Value.absent(),
    this.localeCode = const Value.absent(),
    this.taskCategoryOrder = const Value.absent(),
    this.noteCategoryOrder = const Value.absent(),
    this.lastSuggestionRunAt = const Value.absent(),
    this.lastFamilyMemberSuggestionRunAt = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : updatedAt = Value(updatedAt);
  static Insertable<AppSettingsRow> custom({
    Expression<String>? key,
    Expression<String>? theme,
    Expression<String>? localeCode,
    Expression<String>? taskCategoryOrder,
    Expression<String>? noteCategoryOrder,
    Expression<DateTime>? lastSuggestionRunAt,
    Expression<DateTime>? lastFamilyMemberSuggestionRunAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (theme != null) 'theme': theme,
      if (localeCode != null) 'locale_code': localeCode,
      if (taskCategoryOrder != null) 'task_category_order': taskCategoryOrder,
      if (noteCategoryOrder != null) 'note_category_order': noteCategoryOrder,
      if (lastSuggestionRunAt != null)
        'last_suggestion_run_at': lastSuggestionRunAt,
      if (lastFamilyMemberSuggestionRunAt != null)
        'last_family_member_suggestion_run_at': lastFamilyMemberSuggestionRunAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? theme,
    Value<String>? localeCode,
    Value<String?>? taskCategoryOrder,
    Value<String?>? noteCategoryOrder,
    Value<DateTime?>? lastSuggestionRunAt,
    Value<DateTime?>? lastFamilyMemberSuggestionRunAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      theme: theme ?? this.theme,
      localeCode: localeCode ?? this.localeCode,
      taskCategoryOrder: taskCategoryOrder ?? this.taskCategoryOrder,
      noteCategoryOrder: noteCategoryOrder ?? this.noteCategoryOrder,
      lastSuggestionRunAt: lastSuggestionRunAt ?? this.lastSuggestionRunAt,
      lastFamilyMemberSuggestionRunAt:
          lastFamilyMemberSuggestionRunAt ??
          this.lastFamilyMemberSuggestionRunAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (theme.present) {
      map['theme'] = Variable<String>(theme.value);
    }
    if (localeCode.present) {
      map['locale_code'] = Variable<String>(localeCode.value);
    }
    if (taskCategoryOrder.present) {
      map['task_category_order'] = Variable<String>(taskCategoryOrder.value);
    }
    if (noteCategoryOrder.present) {
      map['note_category_order'] = Variable<String>(noteCategoryOrder.value);
    }
    if (lastSuggestionRunAt.present) {
      map['last_suggestion_run_at'] = Variable<DateTime>(
        lastSuggestionRunAt.value,
      );
    }
    if (lastFamilyMemberSuggestionRunAt.present) {
      map['last_family_member_suggestion_run_at'] = Variable<DateTime>(
        lastFamilyMemberSuggestionRunAt.value,
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('theme: $theme, ')
          ..write('localeCode: $localeCode, ')
          ..write('taskCategoryOrder: $taskCategoryOrder, ')
          ..write('noteCategoryOrder: $noteCategoryOrder, ')
          ..write('lastSuggestionRunAt: $lastSuggestionRunAt, ')
          ..write(
            'lastFamilyMemberSuggestionRunAt: $lastFamilyMemberSuggestionRunAt, ',
          )
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExclusionRulesTable extends ExclusionRules
    with TableInfo<$ExclusionRulesTable, ExclusionRuleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExclusionRulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _patternMeta = const VerificationMeta(
    'pattern',
  );
  @override
  late final GeneratedColumn<String> pattern = GeneratedColumn<String>(
    'pattern',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _penaltyScoreMeta = const VerificationMeta(
    'penaltyScore',
  );
  @override
  late final GeneratedColumn<int> penaltyScore = GeneratedColumn<int>(
    'penalty_score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(40),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, pattern, penaltyScore, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exclusion_rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExclusionRuleRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('pattern')) {
      context.handle(
        _patternMeta,
        pattern.isAcceptableOrUnknown(data['pattern']!, _patternMeta),
      );
    } else if (isInserting) {
      context.missing(_patternMeta);
    }
    if (data.containsKey('penalty_score')) {
      context.handle(
        _penaltyScoreMeta,
        penaltyScore.isAcceptableOrUnknown(
          data['penalty_score']!,
          _penaltyScoreMeta,
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
  ExclusionRuleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExclusionRuleRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      pattern: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pattern'],
      )!,
      penaltyScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}penalty_score'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ExclusionRulesTable createAlias(String alias) {
    return $ExclusionRulesTable(attachedDatabase, alias);
  }
}

class ExclusionRuleRow extends DataClass
    implements Insertable<ExclusionRuleRow> {
  final String id;
  final String pattern;
  final int penaltyScore;
  final DateTime createdAt;
  const ExclusionRuleRow({
    required this.id,
    required this.pattern,
    required this.penaltyScore,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['pattern'] = Variable<String>(pattern);
    map['penalty_score'] = Variable<int>(penaltyScore);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ExclusionRulesCompanion toCompanion(bool nullToAbsent) {
    return ExclusionRulesCompanion(
      id: Value(id),
      pattern: Value(pattern),
      penaltyScore: Value(penaltyScore),
      createdAt: Value(createdAt),
    );
  }

  factory ExclusionRuleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExclusionRuleRow(
      id: serializer.fromJson<String>(json['id']),
      pattern: serializer.fromJson<String>(json['pattern']),
      penaltyScore: serializer.fromJson<int>(json['penaltyScore']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'pattern': serializer.toJson<String>(pattern),
      'penaltyScore': serializer.toJson<int>(penaltyScore),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ExclusionRuleRow copyWith({
    String? id,
    String? pattern,
    int? penaltyScore,
    DateTime? createdAt,
  }) => ExclusionRuleRow(
    id: id ?? this.id,
    pattern: pattern ?? this.pattern,
    penaltyScore: penaltyScore ?? this.penaltyScore,
    createdAt: createdAt ?? this.createdAt,
  );
  ExclusionRuleRow copyWithCompanion(ExclusionRulesCompanion data) {
    return ExclusionRuleRow(
      id: data.id.present ? data.id.value : this.id,
      pattern: data.pattern.present ? data.pattern.value : this.pattern,
      penaltyScore: data.penaltyScore.present
          ? data.penaltyScore.value
          : this.penaltyScore,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExclusionRuleRow(')
          ..write('id: $id, ')
          ..write('pattern: $pattern, ')
          ..write('penaltyScore: $penaltyScore, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, pattern, penaltyScore, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExclusionRuleRow &&
          other.id == this.id &&
          other.pattern == this.pattern &&
          other.penaltyScore == this.penaltyScore &&
          other.createdAt == this.createdAt);
}

class ExclusionRulesCompanion extends UpdateCompanion<ExclusionRuleRow> {
  final Value<String> id;
  final Value<String> pattern;
  final Value<int> penaltyScore;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ExclusionRulesCompanion({
    this.id = const Value.absent(),
    this.pattern = const Value.absent(),
    this.penaltyScore = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExclusionRulesCompanion.insert({
    required String id,
    required String pattern,
    this.penaltyScore = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       pattern = Value(pattern),
       createdAt = Value(createdAt);
  static Insertable<ExclusionRuleRow> custom({
    Expression<String>? id,
    Expression<String>? pattern,
    Expression<int>? penaltyScore,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pattern != null) 'pattern': pattern,
      if (penaltyScore != null) 'penalty_score': penaltyScore,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExclusionRulesCompanion copyWith({
    Value<String>? id,
    Value<String>? pattern,
    Value<int>? penaltyScore,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ExclusionRulesCompanion(
      id: id ?? this.id,
      pattern: pattern ?? this.pattern,
      penaltyScore: penaltyScore ?? this.penaltyScore,
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
    if (pattern.present) {
      map['pattern'] = Variable<String>(pattern.value);
    }
    if (penaltyScore.present) {
      map['penalty_score'] = Variable<int>(penaltyScore.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExclusionRulesCompanion(')
          ..write('id: $id, ')
          ..write('pattern: $pattern, ')
          ..write('penaltyScore: $penaltyScore, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AiSuggestionsTable extends AiSuggestions
    with TableInfo<$AiSuggestionsTable, AiSuggestionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AiSuggestionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
    requiredDuringInsert: false,
    defaultValue: const Constant('other'),
  );
  static const VerificationMeta _suggestedDueDateMeta = const VerificationMeta(
    'suggestedDueDate',
  );
  @override
  late final GeneratedColumn<DateTime> suggestedDueDate =
      GeneratedColumn<DateTime>(
        'suggested_due_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
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
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _snoozeUntilMeta = const VerificationMeta(
    'snoozeUntil',
  );
  @override
  late final GeneratedColumn<DateTime> snoozeUntil = GeneratedColumn<DateTime>(
    'snooze_until',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _explanationMeta = const VerificationMeta(
    'explanation',
  );
  @override
  late final GeneratedColumn<String> explanation = GeneratedColumn<String>(
    'explanation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dedupeKeyMeta = const VerificationMeta(
    'dedupeKey',
  );
  @override
  late final GeneratedColumn<String> dedupeKey = GeneratedColumn<String>(
    'dedupe_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _relatedTaskIdsMeta = const VerificationMeta(
    'relatedTaskIds',
  );
  @override
  late final GeneratedColumn<String> relatedTaskIds = GeneratedColumn<String>(
    'related_task_ids',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    notes,
    priority,
    category,
    suggestedDueDate,
    reason,
    status,
    snoozeUntil,
    explanation,
    dedupeKey,
    relatedTaskIds,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ai_suggestions';
  @override
  VerificationContext validateIntegrity(
    Insertable<AiSuggestionRow> instance, {
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
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('suggested_due_date')) {
      context.handle(
        _suggestedDueDateMeta,
        suggestedDueDate.isAcceptableOrUnknown(
          data['suggested_due_date']!,
          _suggestedDueDateMeta,
        ),
      );
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('snooze_until')) {
      context.handle(
        _snoozeUntilMeta,
        snoozeUntil.isAcceptableOrUnknown(
          data['snooze_until']!,
          _snoozeUntilMeta,
        ),
      );
    }
    if (data.containsKey('explanation')) {
      context.handle(
        _explanationMeta,
        explanation.isAcceptableOrUnknown(
          data['explanation']!,
          _explanationMeta,
        ),
      );
    }
    if (data.containsKey('dedupe_key')) {
      context.handle(
        _dedupeKeyMeta,
        dedupeKey.isAcceptableOrUnknown(data['dedupe_key']!, _dedupeKeyMeta),
      );
    }
    if (data.containsKey('related_task_ids')) {
      context.handle(
        _relatedTaskIdsMeta,
        relatedTaskIds.isAcceptableOrUnknown(
          data['related_task_ids']!,
          _relatedTaskIdsMeta,
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
  AiSuggestionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AiSuggestionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      suggestedDueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}suggested_due_date'],
      ),
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      snoozeUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}snooze_until'],
      ),
      explanation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}explanation'],
      ),
      dedupeKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dedupe_key'],
      )!,
      relatedTaskIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}related_task_ids'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AiSuggestionsTable createAlias(String alias) {
    return $AiSuggestionsTable(attachedDatabase, alias);
  }
}

class AiSuggestionRow extends DataClass implements Insertable<AiSuggestionRow> {
  final String id;
  final String title;
  final String? notes;
  final int priority;
  final String category;
  final DateTime? suggestedDueDate;
  final String reason;
  final String status;
  final DateTime? snoozeUntil;

  /// Human-readable explanation of why this suggestion was generated.
  final String? explanation;

  /// Stable identity used to suppress a dismissed suggestion forever.
  /// Example: `calendar:school-supplies`, `stale:<taskId>`.
  final String dedupeKey;

  /// Comma-separated personal-task ids this suggestion applies to
  /// (stale reminder, categorize).
  final String? relatedTaskIds;
  final DateTime createdAt;
  final DateTime updatedAt;
  const AiSuggestionRow({
    required this.id,
    required this.title,
    this.notes,
    required this.priority,
    required this.category,
    this.suggestedDueDate,
    required this.reason,
    required this.status,
    this.snoozeUntil,
    this.explanation,
    required this.dedupeKey,
    this.relatedTaskIds,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['priority'] = Variable<int>(priority);
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || suggestedDueDate != null) {
      map['suggested_due_date'] = Variable<DateTime>(suggestedDueDate);
    }
    map['reason'] = Variable<String>(reason);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || snoozeUntil != null) {
      map['snooze_until'] = Variable<DateTime>(snoozeUntil);
    }
    if (!nullToAbsent || explanation != null) {
      map['explanation'] = Variable<String>(explanation);
    }
    map['dedupe_key'] = Variable<String>(dedupeKey);
    if (!nullToAbsent || relatedTaskIds != null) {
      map['related_task_ids'] = Variable<String>(relatedTaskIds);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AiSuggestionsCompanion toCompanion(bool nullToAbsent) {
    return AiSuggestionsCompanion(
      id: Value(id),
      title: Value(title),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      priority: Value(priority),
      category: Value(category),
      suggestedDueDate: suggestedDueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(suggestedDueDate),
      reason: Value(reason),
      status: Value(status),
      snoozeUntil: snoozeUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(snoozeUntil),
      explanation: explanation == null && nullToAbsent
          ? const Value.absent()
          : Value(explanation),
      dedupeKey: Value(dedupeKey),
      relatedTaskIds: relatedTaskIds == null && nullToAbsent
          ? const Value.absent()
          : Value(relatedTaskIds),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory AiSuggestionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AiSuggestionRow(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      notes: serializer.fromJson<String?>(json['notes']),
      priority: serializer.fromJson<int>(json['priority']),
      category: serializer.fromJson<String>(json['category']),
      suggestedDueDate: serializer.fromJson<DateTime?>(
        json['suggestedDueDate'],
      ),
      reason: serializer.fromJson<String>(json['reason']),
      status: serializer.fromJson<String>(json['status']),
      snoozeUntil: serializer.fromJson<DateTime?>(json['snoozeUntil']),
      explanation: serializer.fromJson<String?>(json['explanation']),
      dedupeKey: serializer.fromJson<String>(json['dedupeKey']),
      relatedTaskIds: serializer.fromJson<String?>(json['relatedTaskIds']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'notes': serializer.toJson<String?>(notes),
      'priority': serializer.toJson<int>(priority),
      'category': serializer.toJson<String>(category),
      'suggestedDueDate': serializer.toJson<DateTime?>(suggestedDueDate),
      'reason': serializer.toJson<String>(reason),
      'status': serializer.toJson<String>(status),
      'snoozeUntil': serializer.toJson<DateTime?>(snoozeUntil),
      'explanation': serializer.toJson<String?>(explanation),
      'dedupeKey': serializer.toJson<String>(dedupeKey),
      'relatedTaskIds': serializer.toJson<String?>(relatedTaskIds),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AiSuggestionRow copyWith({
    String? id,
    String? title,
    Value<String?> notes = const Value.absent(),
    int? priority,
    String? category,
    Value<DateTime?> suggestedDueDate = const Value.absent(),
    String? reason,
    String? status,
    Value<DateTime?> snoozeUntil = const Value.absent(),
    Value<String?> explanation = const Value.absent(),
    String? dedupeKey,
    Value<String?> relatedTaskIds = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => AiSuggestionRow(
    id: id ?? this.id,
    title: title ?? this.title,
    notes: notes.present ? notes.value : this.notes,
    priority: priority ?? this.priority,
    category: category ?? this.category,
    suggestedDueDate: suggestedDueDate.present
        ? suggestedDueDate.value
        : this.suggestedDueDate,
    reason: reason ?? this.reason,
    status: status ?? this.status,
    snoozeUntil: snoozeUntil.present ? snoozeUntil.value : this.snoozeUntil,
    explanation: explanation.present ? explanation.value : this.explanation,
    dedupeKey: dedupeKey ?? this.dedupeKey,
    relatedTaskIds: relatedTaskIds.present
        ? relatedTaskIds.value
        : this.relatedTaskIds,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AiSuggestionRow copyWithCompanion(AiSuggestionsCompanion data) {
    return AiSuggestionRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      notes: data.notes.present ? data.notes.value : this.notes,
      priority: data.priority.present ? data.priority.value : this.priority,
      category: data.category.present ? data.category.value : this.category,
      suggestedDueDate: data.suggestedDueDate.present
          ? data.suggestedDueDate.value
          : this.suggestedDueDate,
      reason: data.reason.present ? data.reason.value : this.reason,
      status: data.status.present ? data.status.value : this.status,
      snoozeUntil: data.snoozeUntil.present
          ? data.snoozeUntil.value
          : this.snoozeUntil,
      explanation: data.explanation.present
          ? data.explanation.value
          : this.explanation,
      dedupeKey: data.dedupeKey.present ? data.dedupeKey.value : this.dedupeKey,
      relatedTaskIds: data.relatedTaskIds.present
          ? data.relatedTaskIds.value
          : this.relatedTaskIds,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AiSuggestionRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('priority: $priority, ')
          ..write('category: $category, ')
          ..write('suggestedDueDate: $suggestedDueDate, ')
          ..write('reason: $reason, ')
          ..write('status: $status, ')
          ..write('snoozeUntil: $snoozeUntil, ')
          ..write('explanation: $explanation, ')
          ..write('dedupeKey: $dedupeKey, ')
          ..write('relatedTaskIds: $relatedTaskIds, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    notes,
    priority,
    category,
    suggestedDueDate,
    reason,
    status,
    snoozeUntil,
    explanation,
    dedupeKey,
    relatedTaskIds,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AiSuggestionRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.notes == this.notes &&
          other.priority == this.priority &&
          other.category == this.category &&
          other.suggestedDueDate == this.suggestedDueDate &&
          other.reason == this.reason &&
          other.status == this.status &&
          other.snoozeUntil == this.snoozeUntil &&
          other.explanation == this.explanation &&
          other.dedupeKey == this.dedupeKey &&
          other.relatedTaskIds == this.relatedTaskIds &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class AiSuggestionsCompanion extends UpdateCompanion<AiSuggestionRow> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> notes;
  final Value<int> priority;
  final Value<String> category;
  final Value<DateTime?> suggestedDueDate;
  final Value<String> reason;
  final Value<String> status;
  final Value<DateTime?> snoozeUntil;
  final Value<String?> explanation;
  final Value<String> dedupeKey;
  final Value<String?> relatedTaskIds;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AiSuggestionsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.notes = const Value.absent(),
    this.priority = const Value.absent(),
    this.category = const Value.absent(),
    this.suggestedDueDate = const Value.absent(),
    this.reason = const Value.absent(),
    this.status = const Value.absent(),
    this.snoozeUntil = const Value.absent(),
    this.explanation = const Value.absent(),
    this.dedupeKey = const Value.absent(),
    this.relatedTaskIds = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AiSuggestionsCompanion.insert({
    required String id,
    required String title,
    this.notes = const Value.absent(),
    this.priority = const Value.absent(),
    this.category = const Value.absent(),
    this.suggestedDueDate = const Value.absent(),
    required String reason,
    this.status = const Value.absent(),
    this.snoozeUntil = const Value.absent(),
    this.explanation = const Value.absent(),
    this.dedupeKey = const Value.absent(),
    this.relatedTaskIds = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       reason = Value(reason),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<AiSuggestionRow> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? notes,
    Expression<int>? priority,
    Expression<String>? category,
    Expression<DateTime>? suggestedDueDate,
    Expression<String>? reason,
    Expression<String>? status,
    Expression<DateTime>? snoozeUntil,
    Expression<String>? explanation,
    Expression<String>? dedupeKey,
    Expression<String>? relatedTaskIds,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (notes != null) 'notes': notes,
      if (priority != null) 'priority': priority,
      if (category != null) 'category': category,
      if (suggestedDueDate != null) 'suggested_due_date': suggestedDueDate,
      if (reason != null) 'reason': reason,
      if (status != null) 'status': status,
      if (snoozeUntil != null) 'snooze_until': snoozeUntil,
      if (explanation != null) 'explanation': explanation,
      if (dedupeKey != null) 'dedupe_key': dedupeKey,
      if (relatedTaskIds != null) 'related_task_ids': relatedTaskIds,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AiSuggestionsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String?>? notes,
    Value<int>? priority,
    Value<String>? category,
    Value<DateTime?>? suggestedDueDate,
    Value<String>? reason,
    Value<String>? status,
    Value<DateTime?>? snoozeUntil,
    Value<String?>? explanation,
    Value<String>? dedupeKey,
    Value<String?>? relatedTaskIds,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AiSuggestionsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      suggestedDueDate: suggestedDueDate ?? this.suggestedDueDate,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      snoozeUntil: snoozeUntil ?? this.snoozeUntil,
      explanation: explanation ?? this.explanation,
      dedupeKey: dedupeKey ?? this.dedupeKey,
      relatedTaskIds: relatedTaskIds ?? this.relatedTaskIds,
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
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (suggestedDueDate.present) {
      map['suggested_due_date'] = Variable<DateTime>(suggestedDueDate.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (snoozeUntil.present) {
      map['snooze_until'] = Variable<DateTime>(snoozeUntil.value);
    }
    if (explanation.present) {
      map['explanation'] = Variable<String>(explanation.value);
    }
    if (dedupeKey.present) {
      map['dedupe_key'] = Variable<String>(dedupeKey.value);
    }
    if (relatedTaskIds.present) {
      map['related_task_ids'] = Variable<String>(relatedTaskIds.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AiSuggestionsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('priority: $priority, ')
          ..write('category: $category, ')
          ..write('suggestedDueDate: $suggestedDueDate, ')
          ..write('reason: $reason, ')
          ..write('status: $status, ')
          ..write('snoozeUntil: $snoozeUntil, ')
          ..write('explanation: $explanation, ')
          ..write('dedupeKey: $dedupeKey, ')
          ..write('relatedTaskIds: $relatedTaskIds, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PersonalListsTable personalLists = $PersonalListsTable(this);
  late final $PersonalTasksTable personalTasks = $PersonalTasksTable(this);
  late final $PersonalNotesTable personalNotes = $PersonalNotesTable(this);
  late final $PersonalSubtasksTable personalSubtasks = $PersonalSubtasksTable(
    this,
  );
  late final $LinkMemberProposalsTable linkMemberProposals =
      $LinkMemberProposalsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $ExclusionRulesTable exclusionRules = $ExclusionRulesTable(this);
  late final $AiSuggestionsTable aiSuggestions = $AiSuggestionsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    personalLists,
    personalTasks,
    personalNotes,
    personalSubtasks,
    linkMemberProposals,
    appSettings,
    exclusionRules,
    aiSuggestions,
  ];
}

typedef $$PersonalListsTableCreateCompanionBuilder =
    PersonalListsCompanion Function({
      required String id,
      required String name,
      Value<int> colorValue,
      Value<int> iconCodePoint,
      Value<bool> isPrivateDefault,
      Value<int> position,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$PersonalListsTableUpdateCompanionBuilder =
    PersonalListsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> colorValue,
      Value<int> iconCodePoint,
      Value<bool> isPrivateDefault,
      Value<int> position,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$PersonalListsTableReferences
    extends
        BaseReferences<_$AppDatabase, $PersonalListsTable, PersonalListRow> {
  $$PersonalListsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$PersonalTasksTable, List<PersonalTaskRow>>
  _personalTasksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.personalTasks,
    aliasName: 'personal_lists__id__personal_tasks__list_id',
  );

  $$PersonalTasksTableProcessedTableManager get personalTasksRefs {
    final manager = $$PersonalTasksTableTableManager(
      $_db,
      $_db.personalTasks,
    ).filter((f) => f.listId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_personalTasksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PersonalListsTableFilterComposer
    extends Composer<_$AppDatabase, $PersonalListsTable> {
  $$PersonalListsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get iconCodePoint => $composableBuilder(
    column: $table.iconCodePoint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPrivateDefault => $composableBuilder(
    column: $table.isPrivateDefault,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> personalTasksRefs(
    Expression<bool> Function($$PersonalTasksTableFilterComposer f) f,
  ) {
    final $$PersonalTasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.personalTasks,
      getReferencedColumn: (t) => t.listId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonalTasksTableFilterComposer(
            $db: $db,
            $table: $db.personalTasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PersonalListsTableOrderingComposer
    extends Composer<_$AppDatabase, $PersonalListsTable> {
  $$PersonalListsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get iconCodePoint => $composableBuilder(
    column: $table.iconCodePoint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPrivateDefault => $composableBuilder(
    column: $table.isPrivateDefault,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PersonalListsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PersonalListsTable> {
  $$PersonalListsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => column,
  );

  GeneratedColumn<int> get iconCodePoint => $composableBuilder(
    column: $table.iconCodePoint,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isPrivateDefault => $composableBuilder(
    column: $table.isPrivateDefault,
    builder: (column) => column,
  );

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> personalTasksRefs<T extends Object>(
    Expression<T> Function($$PersonalTasksTableAnnotationComposer a) f,
  ) {
    final $$PersonalTasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.personalTasks,
      getReferencedColumn: (t) => t.listId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonalTasksTableAnnotationComposer(
            $db: $db,
            $table: $db.personalTasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PersonalListsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PersonalListsTable,
          PersonalListRow,
          $$PersonalListsTableFilterComposer,
          $$PersonalListsTableOrderingComposer,
          $$PersonalListsTableAnnotationComposer,
          $$PersonalListsTableCreateCompanionBuilder,
          $$PersonalListsTableUpdateCompanionBuilder,
          (PersonalListRow, $$PersonalListsTableReferences),
          PersonalListRow,
          PrefetchHooks Function({bool personalTasksRefs})
        > {
  $$PersonalListsTableTableManager(_$AppDatabase db, $PersonalListsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PersonalListsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PersonalListsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PersonalListsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> colorValue = const Value.absent(),
                Value<int> iconCodePoint = const Value.absent(),
                Value<bool> isPrivateDefault = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PersonalListsCompanion(
                id: id,
                name: name,
                colorValue: colorValue,
                iconCodePoint: iconCodePoint,
                isPrivateDefault: isPrivateDefault,
                position: position,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<int> colorValue = const Value.absent(),
                Value<int> iconCodePoint = const Value.absent(),
                Value<bool> isPrivateDefault = const Value.absent(),
                Value<int> position = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => PersonalListsCompanion.insert(
                id: id,
                name: name,
                colorValue: colorValue,
                iconCodePoint: iconCodePoint,
                isPrivateDefault: isPrivateDefault,
                position: position,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PersonalListsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({personalTasksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (personalTasksRefs) db.personalTasks,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (personalTasksRefs)
                    await $_getPrefetchedData<
                      PersonalListRow,
                      $PersonalListsTable,
                      PersonalTaskRow
                    >(
                      currentTable: table,
                      referencedTable: $$PersonalListsTableReferences
                          ._personalTasksRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$PersonalListsTableReferences(
                            db,
                            table,
                            p0,
                          ).personalTasksRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.listId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PersonalListsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PersonalListsTable,
      PersonalListRow,
      $$PersonalListsTableFilterComposer,
      $$PersonalListsTableOrderingComposer,
      $$PersonalListsTableAnnotationComposer,
      $$PersonalListsTableCreateCompanionBuilder,
      $$PersonalListsTableUpdateCompanionBuilder,
      (PersonalListRow, $$PersonalListsTableReferences),
      PersonalListRow,
      PrefetchHooks Function({bool personalTasksRefs})
    >;
typedef $$PersonalTasksTableCreateCompanionBuilder =
    PersonalTasksCompanion Function({
      required String id,
      Value<String?> listId,
      required String title,
      Value<String?> notes,
      Value<int> priority,
      Value<DateTime?> dueDate,
      Value<bool> isAllDay,
      Value<String?> recurrenceRule,
      Value<bool> isCompleted,
      Value<DateTime?> completedAt,
      Value<bool> isFlagged,
      Value<bool> isPrivate,
      Value<String?> kidsTaskId,
      Value<String?> targetKidId,
      Value<String?> verifierLinkId,
      Value<int> xpReward,
      Value<String> category,
      Value<String?> customCategory,
      Value<DateTime?> remindAt,
      Value<int> sortOrder,
      Value<String?> webdavEtag,
      Value<String> syncState,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$PersonalTasksTableUpdateCompanionBuilder =
    PersonalTasksCompanion Function({
      Value<String> id,
      Value<String?> listId,
      Value<String> title,
      Value<String?> notes,
      Value<int> priority,
      Value<DateTime?> dueDate,
      Value<bool> isAllDay,
      Value<String?> recurrenceRule,
      Value<bool> isCompleted,
      Value<DateTime?> completedAt,
      Value<bool> isFlagged,
      Value<bool> isPrivate,
      Value<String?> kidsTaskId,
      Value<String?> targetKidId,
      Value<String?> verifierLinkId,
      Value<int> xpReward,
      Value<String> category,
      Value<String?> customCategory,
      Value<DateTime?> remindAt,
      Value<int> sortOrder,
      Value<String?> webdavEtag,
      Value<String> syncState,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$PersonalTasksTableReferences
    extends
        BaseReferences<_$AppDatabase, $PersonalTasksTable, PersonalTaskRow> {
  $$PersonalTasksTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PersonalListsTable _listIdTable(_$AppDatabase db) => db.personalLists
      .createAlias('personal_tasks__list_id__personal_lists__id');

  $$PersonalListsTableProcessedTableManager? get listId {
    final $_column = $_itemColumn<String>('list_id');
    if ($_column == null) return null;
    final manager = $$PersonalListsTableTableManager(
      $_db,
      $_db.personalLists,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_listIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$PersonalSubtasksTable, List<PersonalSubtaskRow>>
  _personalSubtasksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.personalSubtasks,
    aliasName: 'personal_tasks__id__personal_subtasks__task_id',
  );

  $$PersonalSubtasksTableProcessedTableManager get personalSubtasksRefs {
    final manager = $$PersonalSubtasksTableTableManager(
      $_db,
      $_db.personalSubtasks,
    ).filter((f) => f.taskId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _personalSubtasksRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PersonalTasksTableFilterComposer
    extends Composer<_$AppDatabase, $PersonalTasksTable> {
  $$PersonalTasksTableFilterComposer({
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

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAllDay => $composableBuilder(
    column: $table.isAllDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recurrenceRule => $composableBuilder(
    column: $table.recurrenceRule,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFlagged => $composableBuilder(
    column: $table.isFlagged,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPrivate => $composableBuilder(
    column: $table.isPrivate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kidsTaskId => $composableBuilder(
    column: $table.kidsTaskId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetKidId => $composableBuilder(
    column: $table.targetKidId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get verifierLinkId => $composableBuilder(
    column: $table.verifierLinkId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get xpReward => $composableBuilder(
    column: $table.xpReward,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customCategory => $composableBuilder(
    column: $table.customCategory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get remindAt => $composableBuilder(
    column: $table.remindAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get webdavEtag => $composableBuilder(
    column: $table.webdavEtag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PersonalListsTableFilterComposer get listId {
    final $$PersonalListsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.listId,
      referencedTable: $db.personalLists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonalListsTableFilterComposer(
            $db: $db,
            $table: $db.personalLists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> personalSubtasksRefs(
    Expression<bool> Function($$PersonalSubtasksTableFilterComposer f) f,
  ) {
    final $$PersonalSubtasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.personalSubtasks,
      getReferencedColumn: (t) => t.taskId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonalSubtasksTableFilterComposer(
            $db: $db,
            $table: $db.personalSubtasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PersonalTasksTableOrderingComposer
    extends Composer<_$AppDatabase, $PersonalTasksTable> {
  $$PersonalTasksTableOrderingComposer({
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

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAllDay => $composableBuilder(
    column: $table.isAllDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recurrenceRule => $composableBuilder(
    column: $table.recurrenceRule,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFlagged => $composableBuilder(
    column: $table.isFlagged,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPrivate => $composableBuilder(
    column: $table.isPrivate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kidsTaskId => $composableBuilder(
    column: $table.kidsTaskId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetKidId => $composableBuilder(
    column: $table.targetKidId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get verifierLinkId => $composableBuilder(
    column: $table.verifierLinkId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get xpReward => $composableBuilder(
    column: $table.xpReward,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customCategory => $composableBuilder(
    column: $table.customCategory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get remindAt => $composableBuilder(
    column: $table.remindAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get webdavEtag => $composableBuilder(
    column: $table.webdavEtag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PersonalListsTableOrderingComposer get listId {
    final $$PersonalListsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.listId,
      referencedTable: $db.personalLists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonalListsTableOrderingComposer(
            $db: $db,
            $table: $db.personalLists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PersonalTasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $PersonalTasksTable> {
  $$PersonalTasksTableAnnotationComposer({
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

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<bool> get isAllDay =>
      $composableBuilder(column: $table.isAllDay, builder: (column) => column);

  GeneratedColumn<String> get recurrenceRule => $composableBuilder(
    column: $table.recurrenceRule,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isFlagged =>
      $composableBuilder(column: $table.isFlagged, builder: (column) => column);

  GeneratedColumn<bool> get isPrivate =>
      $composableBuilder(column: $table.isPrivate, builder: (column) => column);

  GeneratedColumn<String> get kidsTaskId => $composableBuilder(
    column: $table.kidsTaskId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get targetKidId => $composableBuilder(
    column: $table.targetKidId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get verifierLinkId => $composableBuilder(
    column: $table.verifierLinkId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get xpReward =>
      $composableBuilder(column: $table.xpReward, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get customCategory => $composableBuilder(
    column: $table.customCategory,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get remindAt =>
      $composableBuilder(column: $table.remindAt, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get webdavEtag => $composableBuilder(
    column: $table.webdavEtag,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$PersonalListsTableAnnotationComposer get listId {
    final $$PersonalListsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.listId,
      referencedTable: $db.personalLists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonalListsTableAnnotationComposer(
            $db: $db,
            $table: $db.personalLists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> personalSubtasksRefs<T extends Object>(
    Expression<T> Function($$PersonalSubtasksTableAnnotationComposer a) f,
  ) {
    final $$PersonalSubtasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.personalSubtasks,
      getReferencedColumn: (t) => t.taskId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonalSubtasksTableAnnotationComposer(
            $db: $db,
            $table: $db.personalSubtasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PersonalTasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PersonalTasksTable,
          PersonalTaskRow,
          $$PersonalTasksTableFilterComposer,
          $$PersonalTasksTableOrderingComposer,
          $$PersonalTasksTableAnnotationComposer,
          $$PersonalTasksTableCreateCompanionBuilder,
          $$PersonalTasksTableUpdateCompanionBuilder,
          (PersonalTaskRow, $$PersonalTasksTableReferences),
          PersonalTaskRow,
          PrefetchHooks Function({bool listId, bool personalSubtasksRefs})
        > {
  $$PersonalTasksTableTableManager(_$AppDatabase db, $PersonalTasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PersonalTasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PersonalTasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PersonalTasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> listId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<bool> isAllDay = const Value.absent(),
                Value<String?> recurrenceRule = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<bool> isFlagged = const Value.absent(),
                Value<bool> isPrivate = const Value.absent(),
                Value<String?> kidsTaskId = const Value.absent(),
                Value<String?> targetKidId = const Value.absent(),
                Value<String?> verifierLinkId = const Value.absent(),
                Value<int> xpReward = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String?> customCategory = const Value.absent(),
                Value<DateTime?> remindAt = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String?> webdavEtag = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PersonalTasksCompanion(
                id: id,
                listId: listId,
                title: title,
                notes: notes,
                priority: priority,
                dueDate: dueDate,
                isAllDay: isAllDay,
                recurrenceRule: recurrenceRule,
                isCompleted: isCompleted,
                completedAt: completedAt,
                isFlagged: isFlagged,
                isPrivate: isPrivate,
                kidsTaskId: kidsTaskId,
                targetKidId: targetKidId,
                verifierLinkId: verifierLinkId,
                xpReward: xpReward,
                category: category,
                customCategory: customCategory,
                remindAt: remindAt,
                sortOrder: sortOrder,
                webdavEtag: webdavEtag,
                syncState: syncState,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> listId = const Value.absent(),
                required String title,
                Value<String?> notes = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<bool> isAllDay = const Value.absent(),
                Value<String?> recurrenceRule = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<bool> isFlagged = const Value.absent(),
                Value<bool> isPrivate = const Value.absent(),
                Value<String?> kidsTaskId = const Value.absent(),
                Value<String?> targetKidId = const Value.absent(),
                Value<String?> verifierLinkId = const Value.absent(),
                Value<int> xpReward = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String?> customCategory = const Value.absent(),
                Value<DateTime?> remindAt = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String?> webdavEtag = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => PersonalTasksCompanion.insert(
                id: id,
                listId: listId,
                title: title,
                notes: notes,
                priority: priority,
                dueDate: dueDate,
                isAllDay: isAllDay,
                recurrenceRule: recurrenceRule,
                isCompleted: isCompleted,
                completedAt: completedAt,
                isFlagged: isFlagged,
                isPrivate: isPrivate,
                kidsTaskId: kidsTaskId,
                targetKidId: targetKidId,
                verifierLinkId: verifierLinkId,
                xpReward: xpReward,
                category: category,
                customCategory: customCategory,
                remindAt: remindAt,
                sortOrder: sortOrder,
                webdavEtag: webdavEtag,
                syncState: syncState,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PersonalTasksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({listId = false, personalSubtasksRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (personalSubtasksRefs) db.personalSubtasks,
                  ],
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
                        if (listId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.listId,
                                    referencedTable:
                                        $$PersonalTasksTableReferences
                                            ._listIdTable(db),
                                    referencedColumn:
                                        $$PersonalTasksTableReferences
                                            ._listIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (personalSubtasksRefs)
                        await $_getPrefetchedData<
                          PersonalTaskRow,
                          $PersonalTasksTable,
                          PersonalSubtaskRow
                        >(
                          currentTable: table,
                          referencedTable: $$PersonalTasksTableReferences
                              ._personalSubtasksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PersonalTasksTableReferences(
                                db,
                                table,
                                p0,
                              ).personalSubtasksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.taskId == item.id,
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

typedef $$PersonalTasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PersonalTasksTable,
      PersonalTaskRow,
      $$PersonalTasksTableFilterComposer,
      $$PersonalTasksTableOrderingComposer,
      $$PersonalTasksTableAnnotationComposer,
      $$PersonalTasksTableCreateCompanionBuilder,
      $$PersonalTasksTableUpdateCompanionBuilder,
      (PersonalTaskRow, $$PersonalTasksTableReferences),
      PersonalTaskRow,
      PrefetchHooks Function({bool listId, bool personalSubtasksRefs})
    >;
typedef $$PersonalNotesTableCreateCompanionBuilder =
    PersonalNotesCompanion Function({
      required String id,
      required String title,
      Value<String> body,
      Value<bool> isShared,
      Value<String?> sharedMemberIds,
      Value<DateTime?> remindAt,
      Value<String?> category,
      Value<int> sortOrder,
      Value<bool> isContentHidden,
      Value<bool> isLocalOnly,
      Value<String?> linkedTaskIds,
      Value<String?> webdavEtag,
      Value<String> syncState,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<String?> updatedByLinkId,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$PersonalNotesTableUpdateCompanionBuilder =
    PersonalNotesCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> body,
      Value<bool> isShared,
      Value<String?> sharedMemberIds,
      Value<DateTime?> remindAt,
      Value<String?> category,
      Value<int> sortOrder,
      Value<bool> isContentHidden,
      Value<bool> isLocalOnly,
      Value<String?> linkedTaskIds,
      Value<String?> webdavEtag,
      Value<String> syncState,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String?> updatedByLinkId,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

class $$PersonalNotesTableFilterComposer
    extends Composer<_$AppDatabase, $PersonalNotesTable> {
  $$PersonalNotesTableFilterComposer({
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

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isShared => $composableBuilder(
    column: $table.isShared,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sharedMemberIds => $composableBuilder(
    column: $table.sharedMemberIds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get remindAt => $composableBuilder(
    column: $table.remindAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isContentHidden => $composableBuilder(
    column: $table.isContentHidden,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isLocalOnly => $composableBuilder(
    column: $table.isLocalOnly,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get linkedTaskIds => $composableBuilder(
    column: $table.linkedTaskIds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get webdavEtag => $composableBuilder(
    column: $table.webdavEtag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedByLinkId => $composableBuilder(
    column: $table.updatedByLinkId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PersonalNotesTableOrderingComposer
    extends Composer<_$AppDatabase, $PersonalNotesTable> {
  $$PersonalNotesTableOrderingComposer({
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

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isShared => $composableBuilder(
    column: $table.isShared,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sharedMemberIds => $composableBuilder(
    column: $table.sharedMemberIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get remindAt => $composableBuilder(
    column: $table.remindAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isContentHidden => $composableBuilder(
    column: $table.isContentHidden,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isLocalOnly => $composableBuilder(
    column: $table.isLocalOnly,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get linkedTaskIds => $composableBuilder(
    column: $table.linkedTaskIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get webdavEtag => $composableBuilder(
    column: $table.webdavEtag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedByLinkId => $composableBuilder(
    column: $table.updatedByLinkId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PersonalNotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PersonalNotesTable> {
  $$PersonalNotesTableAnnotationComposer({
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

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<bool> get isShared =>
      $composableBuilder(column: $table.isShared, builder: (column) => column);

  GeneratedColumn<String> get sharedMemberIds => $composableBuilder(
    column: $table.sharedMemberIds,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get remindAt =>
      $composableBuilder(column: $table.remindAt, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get isContentHidden => $composableBuilder(
    column: $table.isContentHidden,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isLocalOnly => $composableBuilder(
    column: $table.isLocalOnly,
    builder: (column) => column,
  );

  GeneratedColumn<String> get linkedTaskIds => $composableBuilder(
    column: $table.linkedTaskIds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get webdavEtag => $composableBuilder(
    column: $table.webdavEtag,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get updatedByLinkId => $composableBuilder(
    column: $table.updatedByLinkId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$PersonalNotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PersonalNotesTable,
          PersonalNoteRow,
          $$PersonalNotesTableFilterComposer,
          $$PersonalNotesTableOrderingComposer,
          $$PersonalNotesTableAnnotationComposer,
          $$PersonalNotesTableCreateCompanionBuilder,
          $$PersonalNotesTableUpdateCompanionBuilder,
          (
            PersonalNoteRow,
            BaseReferences<_$AppDatabase, $PersonalNotesTable, PersonalNoteRow>,
          ),
          PersonalNoteRow,
          PrefetchHooks Function()
        > {
  $$PersonalNotesTableTableManager(_$AppDatabase db, $PersonalNotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PersonalNotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PersonalNotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PersonalNotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<bool> isShared = const Value.absent(),
                Value<String?> sharedMemberIds = const Value.absent(),
                Value<DateTime?> remindAt = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isContentHidden = const Value.absent(),
                Value<bool> isLocalOnly = const Value.absent(),
                Value<String?> linkedTaskIds = const Value.absent(),
                Value<String?> webdavEtag = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String?> updatedByLinkId = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PersonalNotesCompanion(
                id: id,
                title: title,
                body: body,
                isShared: isShared,
                sharedMemberIds: sharedMemberIds,
                remindAt: remindAt,
                category: category,
                sortOrder: sortOrder,
                isContentHidden: isContentHidden,
                isLocalOnly: isLocalOnly,
                linkedTaskIds: linkedTaskIds,
                webdavEtag: webdavEtag,
                syncState: syncState,
                createdAt: createdAt,
                updatedAt: updatedAt,
                updatedByLinkId: updatedByLinkId,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String> body = const Value.absent(),
                Value<bool> isShared = const Value.absent(),
                Value<String?> sharedMemberIds = const Value.absent(),
                Value<DateTime?> remindAt = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isContentHidden = const Value.absent(),
                Value<bool> isLocalOnly = const Value.absent(),
                Value<String?> linkedTaskIds = const Value.absent(),
                Value<String?> webdavEtag = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<String?> updatedByLinkId = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PersonalNotesCompanion.insert(
                id: id,
                title: title,
                body: body,
                isShared: isShared,
                sharedMemberIds: sharedMemberIds,
                remindAt: remindAt,
                category: category,
                sortOrder: sortOrder,
                isContentHidden: isContentHidden,
                isLocalOnly: isLocalOnly,
                linkedTaskIds: linkedTaskIds,
                webdavEtag: webdavEtag,
                syncState: syncState,
                createdAt: createdAt,
                updatedAt: updatedAt,
                updatedByLinkId: updatedByLinkId,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PersonalNotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PersonalNotesTable,
      PersonalNoteRow,
      $$PersonalNotesTableFilterComposer,
      $$PersonalNotesTableOrderingComposer,
      $$PersonalNotesTableAnnotationComposer,
      $$PersonalNotesTableCreateCompanionBuilder,
      $$PersonalNotesTableUpdateCompanionBuilder,
      (
        PersonalNoteRow,
        BaseReferences<_$AppDatabase, $PersonalNotesTable, PersonalNoteRow>,
      ),
      PersonalNoteRow,
      PrefetchHooks Function()
    >;
typedef $$PersonalSubtasksTableCreateCompanionBuilder =
    PersonalSubtasksCompanion Function({
      required String id,
      required String taskId,
      required String title,
      Value<bool> isCompleted,
      Value<int> sortOrder,
      Value<int> rowid,
    });
typedef $$PersonalSubtasksTableUpdateCompanionBuilder =
    PersonalSubtasksCompanion Function({
      Value<String> id,
      Value<String> taskId,
      Value<String> title,
      Value<bool> isCompleted,
      Value<int> sortOrder,
      Value<int> rowid,
    });

final class $$PersonalSubtasksTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PersonalSubtasksTable,
          PersonalSubtaskRow
        > {
  $$PersonalSubtasksTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PersonalTasksTable _taskIdTable(_$AppDatabase db) => db.personalTasks
      .createAlias('personal_subtasks__task_id__personal_tasks__id');

  $$PersonalTasksTableProcessedTableManager get taskId {
    final $_column = $_itemColumn<String>('task_id')!;

    final manager = $$PersonalTasksTableTableManager(
      $_db,
      $_db.personalTasks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_taskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PersonalSubtasksTableFilterComposer
    extends Composer<_$AppDatabase, $PersonalSubtasksTable> {
  $$PersonalSubtasksTableFilterComposer({
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

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  $$PersonalTasksTableFilterComposer get taskId {
    final $$PersonalTasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.personalTasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonalTasksTableFilterComposer(
            $db: $db,
            $table: $db.personalTasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PersonalSubtasksTableOrderingComposer
    extends Composer<_$AppDatabase, $PersonalSubtasksTable> {
  $$PersonalSubtasksTableOrderingComposer({
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

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  $$PersonalTasksTableOrderingComposer get taskId {
    final $$PersonalTasksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.personalTasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonalTasksTableOrderingComposer(
            $db: $db,
            $table: $db.personalTasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PersonalSubtasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $PersonalSubtasksTable> {
  $$PersonalSubtasksTableAnnotationComposer({
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

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $$PersonalTasksTableAnnotationComposer get taskId {
    final $$PersonalTasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.personalTasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonalTasksTableAnnotationComposer(
            $db: $db,
            $table: $db.personalTasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PersonalSubtasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PersonalSubtasksTable,
          PersonalSubtaskRow,
          $$PersonalSubtasksTableFilterComposer,
          $$PersonalSubtasksTableOrderingComposer,
          $$PersonalSubtasksTableAnnotationComposer,
          $$PersonalSubtasksTableCreateCompanionBuilder,
          $$PersonalSubtasksTableUpdateCompanionBuilder,
          (PersonalSubtaskRow, $$PersonalSubtasksTableReferences),
          PersonalSubtaskRow,
          PrefetchHooks Function({bool taskId})
        > {
  $$PersonalSubtasksTableTableManager(
    _$AppDatabase db,
    $PersonalSubtasksTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PersonalSubtasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PersonalSubtasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PersonalSubtasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> taskId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PersonalSubtasksCompanion(
                id: id,
                taskId: taskId,
                title: title,
                isCompleted: isCompleted,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String taskId,
                required String title,
                Value<bool> isCompleted = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PersonalSubtasksCompanion.insert(
                id: id,
                taskId: taskId,
                title: title,
                isCompleted: isCompleted,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PersonalSubtasksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({taskId = false}) {
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
                    if (taskId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.taskId,
                                referencedTable:
                                    $$PersonalSubtasksTableReferences
                                        ._taskIdTable(db),
                                referencedColumn:
                                    $$PersonalSubtasksTableReferences
                                        ._taskIdTable(db)
                                        .id,
                              )
                              as T;
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

typedef $$PersonalSubtasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PersonalSubtasksTable,
      PersonalSubtaskRow,
      $$PersonalSubtasksTableFilterComposer,
      $$PersonalSubtasksTableOrderingComposer,
      $$PersonalSubtasksTableAnnotationComposer,
      $$PersonalSubtasksTableCreateCompanionBuilder,
      $$PersonalSubtasksTableUpdateCompanionBuilder,
      (PersonalSubtaskRow, $$PersonalSubtasksTableReferences),
      PersonalSubtaskRow,
      PrefetchHooks Function({bool taskId})
    >;
typedef $$LinkMemberProposalsTableCreateCompanionBuilder =
    LinkMemberProposalsCompanion Function({
      required String id,
      required String fromLinkId,
      Value<String?> toMemberId,
      required String taskTitle,
      Value<String?> taskNotes,
      Value<String> taskCategory,
      Value<int> taskPriority,
      Value<DateTime?> taskDueDate,
      Value<String> status,
      Value<bool> autoGenerated,
      Value<String> syncState,
      Value<String?> sourceTaskId,
      Value<String?> resultTaskId,
      required DateTime receivedAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$LinkMemberProposalsTableUpdateCompanionBuilder =
    LinkMemberProposalsCompanion Function({
      Value<String> id,
      Value<String> fromLinkId,
      Value<String?> toMemberId,
      Value<String> taskTitle,
      Value<String?> taskNotes,
      Value<String> taskCategory,
      Value<int> taskPriority,
      Value<DateTime?> taskDueDate,
      Value<String> status,
      Value<bool> autoGenerated,
      Value<String> syncState,
      Value<String?> sourceTaskId,
      Value<String?> resultTaskId,
      Value<DateTime> receivedAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LinkMemberProposalsTableFilterComposer
    extends Composer<_$AppDatabase, $LinkMemberProposalsTable> {
  $$LinkMemberProposalsTableFilterComposer({
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

  ColumnFilters<String> get fromLinkId => $composableBuilder(
    column: $table.fromLinkId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toMemberId => $composableBuilder(
    column: $table.toMemberId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taskTitle => $composableBuilder(
    column: $table.taskTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taskNotes => $composableBuilder(
    column: $table.taskNotes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taskCategory => $composableBuilder(
    column: $table.taskCategory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get taskPriority => $composableBuilder(
    column: $table.taskPriority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get taskDueDate => $composableBuilder(
    column: $table.taskDueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get autoGenerated => $composableBuilder(
    column: $table.autoGenerated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceTaskId => $composableBuilder(
    column: $table.sourceTaskId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resultTaskId => $composableBuilder(
    column: $table.resultTaskId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LinkMemberProposalsTableOrderingComposer
    extends Composer<_$AppDatabase, $LinkMemberProposalsTable> {
  $$LinkMemberProposalsTableOrderingComposer({
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

  ColumnOrderings<String> get fromLinkId => $composableBuilder(
    column: $table.fromLinkId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toMemberId => $composableBuilder(
    column: $table.toMemberId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taskTitle => $composableBuilder(
    column: $table.taskTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taskNotes => $composableBuilder(
    column: $table.taskNotes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taskCategory => $composableBuilder(
    column: $table.taskCategory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get taskPriority => $composableBuilder(
    column: $table.taskPriority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get taskDueDate => $composableBuilder(
    column: $table.taskDueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get autoGenerated => $composableBuilder(
    column: $table.autoGenerated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceTaskId => $composableBuilder(
    column: $table.sourceTaskId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resultTaskId => $composableBuilder(
    column: $table.resultTaskId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LinkMemberProposalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LinkMemberProposalsTable> {
  $$LinkMemberProposalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fromLinkId => $composableBuilder(
    column: $table.fromLinkId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get toMemberId => $composableBuilder(
    column: $table.toMemberId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get taskTitle =>
      $composableBuilder(column: $table.taskTitle, builder: (column) => column);

  GeneratedColumn<String> get taskNotes =>
      $composableBuilder(column: $table.taskNotes, builder: (column) => column);

  GeneratedColumn<String> get taskCategory => $composableBuilder(
    column: $table.taskCategory,
    builder: (column) => column,
  );

  GeneratedColumn<int> get taskPriority => $composableBuilder(
    column: $table.taskPriority,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get taskDueDate => $composableBuilder(
    column: $table.taskDueDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get autoGenerated => $composableBuilder(
    column: $table.autoGenerated,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<String> get sourceTaskId => $composableBuilder(
    column: $table.sourceTaskId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get resultTaskId => $composableBuilder(
    column: $table.resultTaskId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LinkMemberProposalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LinkMemberProposalsTable,
          LinkMemberProposalRow,
          $$LinkMemberProposalsTableFilterComposer,
          $$LinkMemberProposalsTableOrderingComposer,
          $$LinkMemberProposalsTableAnnotationComposer,
          $$LinkMemberProposalsTableCreateCompanionBuilder,
          $$LinkMemberProposalsTableUpdateCompanionBuilder,
          (
            LinkMemberProposalRow,
            BaseReferences<
              _$AppDatabase,
              $LinkMemberProposalsTable,
              LinkMemberProposalRow
            >,
          ),
          LinkMemberProposalRow,
          PrefetchHooks Function()
        > {
  $$LinkMemberProposalsTableTableManager(
    _$AppDatabase db,
    $LinkMemberProposalsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LinkMemberProposalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LinkMemberProposalsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LinkMemberProposalsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> fromLinkId = const Value.absent(),
                Value<String?> toMemberId = const Value.absent(),
                Value<String> taskTitle = const Value.absent(),
                Value<String?> taskNotes = const Value.absent(),
                Value<String> taskCategory = const Value.absent(),
                Value<int> taskPriority = const Value.absent(),
                Value<DateTime?> taskDueDate = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<bool> autoGenerated = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<String?> sourceTaskId = const Value.absent(),
                Value<String?> resultTaskId = const Value.absent(),
                Value<DateTime> receivedAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LinkMemberProposalsCompanion(
                id: id,
                fromLinkId: fromLinkId,
                toMemberId: toMemberId,
                taskTitle: taskTitle,
                taskNotes: taskNotes,
                taskCategory: taskCategory,
                taskPriority: taskPriority,
                taskDueDate: taskDueDate,
                status: status,
                autoGenerated: autoGenerated,
                syncState: syncState,
                sourceTaskId: sourceTaskId,
                resultTaskId: resultTaskId,
                receivedAt: receivedAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String fromLinkId,
                Value<String?> toMemberId = const Value.absent(),
                required String taskTitle,
                Value<String?> taskNotes = const Value.absent(),
                Value<String> taskCategory = const Value.absent(),
                Value<int> taskPriority = const Value.absent(),
                Value<DateTime?> taskDueDate = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<bool> autoGenerated = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<String?> sourceTaskId = const Value.absent(),
                Value<String?> resultTaskId = const Value.absent(),
                required DateTime receivedAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => LinkMemberProposalsCompanion.insert(
                id: id,
                fromLinkId: fromLinkId,
                toMemberId: toMemberId,
                taskTitle: taskTitle,
                taskNotes: taskNotes,
                taskCategory: taskCategory,
                taskPriority: taskPriority,
                taskDueDate: taskDueDate,
                status: status,
                autoGenerated: autoGenerated,
                syncState: syncState,
                sourceTaskId: sourceTaskId,
                resultTaskId: resultTaskId,
                receivedAt: receivedAt,
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

typedef $$LinkMemberProposalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LinkMemberProposalsTable,
      LinkMemberProposalRow,
      $$LinkMemberProposalsTableFilterComposer,
      $$LinkMemberProposalsTableOrderingComposer,
      $$LinkMemberProposalsTableAnnotationComposer,
      $$LinkMemberProposalsTableCreateCompanionBuilder,
      $$LinkMemberProposalsTableUpdateCompanionBuilder,
      (
        LinkMemberProposalRow,
        BaseReferences<
          _$AppDatabase,
          $LinkMemberProposalsTable,
          LinkMemberProposalRow
        >,
      ),
      LinkMemberProposalRow,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> theme,
      Value<String> localeCode,
      Value<String?> taskCategoryOrder,
      Value<String?> noteCategoryOrder,
      Value<DateTime?> lastSuggestionRunAt,
      Value<DateTime?> lastFamilyMemberSuggestionRunAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> theme,
      Value<String> localeCode,
      Value<String?> taskCategoryOrder,
      Value<String?> noteCategoryOrder,
      Value<DateTime?> lastSuggestionRunAt,
      Value<DateTime?> lastFamilyMemberSuggestionRunAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
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

  ColumnFilters<String> get theme => $composableBuilder(
    column: $table.theme,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localeCode => $composableBuilder(
    column: $table.localeCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taskCategoryOrder => $composableBuilder(
    column: $table.taskCategoryOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get noteCategoryOrder => $composableBuilder(
    column: $table.noteCategoryOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSuggestionRunAt => $composableBuilder(
    column: $table.lastSuggestionRunAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastFamilyMemberSuggestionRunAt =>
      $composableBuilder(
        column: $table.lastFamilyMemberSuggestionRunAt,
        builder: (column) => ColumnFilters(column),
      );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
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

  ColumnOrderings<String> get theme => $composableBuilder(
    column: $table.theme,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localeCode => $composableBuilder(
    column: $table.localeCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taskCategoryOrder => $composableBuilder(
    column: $table.taskCategoryOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get noteCategoryOrder => $composableBuilder(
    column: $table.noteCategoryOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSuggestionRunAt => $composableBuilder(
    column: $table.lastSuggestionRunAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastFamilyMemberSuggestionRunAt =>
      $composableBuilder(
        column: $table.lastFamilyMemberSuggestionRunAt,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get theme =>
      $composableBuilder(column: $table.theme, builder: (column) => column);

  GeneratedColumn<String> get localeCode => $composableBuilder(
    column: $table.localeCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get taskCategoryOrder => $composableBuilder(
    column: $table.taskCategoryOrder,
    builder: (column) => column,
  );

  GeneratedColumn<String> get noteCategoryOrder => $composableBuilder(
    column: $table.noteCategoryOrder,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSuggestionRunAt => $composableBuilder(
    column: $table.lastSuggestionRunAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastFamilyMemberSuggestionRunAt =>
      $composableBuilder(
        column: $table.lastFamilyMemberSuggestionRunAt,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSettingsRow,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSettingsRow,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSettingsRow>,
          ),
          AppSettingsRow,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> theme = const Value.absent(),
                Value<String> localeCode = const Value.absent(),
                Value<String?> taskCategoryOrder = const Value.absent(),
                Value<String?> noteCategoryOrder = const Value.absent(),
                Value<DateTime?> lastSuggestionRunAt = const Value.absent(),
                Value<DateTime?> lastFamilyMemberSuggestionRunAt =
                    const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(
                key: key,
                theme: theme,
                localeCode: localeCode,
                taskCategoryOrder: taskCategoryOrder,
                noteCategoryOrder: noteCategoryOrder,
                lastSuggestionRunAt: lastSuggestionRunAt,
                lastFamilyMemberSuggestionRunAt:
                    lastFamilyMemberSuggestionRunAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> theme = const Value.absent(),
                Value<String> localeCode = const Value.absent(),
                Value<String?> taskCategoryOrder = const Value.absent(),
                Value<String?> noteCategoryOrder = const Value.absent(),
                Value<DateTime?> lastSuggestionRunAt = const Value.absent(),
                Value<DateTime?> lastFamilyMemberSuggestionRunAt =
                    const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                theme: theme,
                localeCode: localeCode,
                taskCategoryOrder: taskCategoryOrder,
                noteCategoryOrder: noteCategoryOrder,
                lastSuggestionRunAt: lastSuggestionRunAt,
                lastFamilyMemberSuggestionRunAt:
                    lastFamilyMemberSuggestionRunAt,
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

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSettingsRow,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSettingsRow,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSettingsRow>,
      ),
      AppSettingsRow,
      PrefetchHooks Function()
    >;
typedef $$ExclusionRulesTableCreateCompanionBuilder =
    ExclusionRulesCompanion Function({
      required String id,
      required String pattern,
      Value<int> penaltyScore,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$ExclusionRulesTableUpdateCompanionBuilder =
    ExclusionRulesCompanion Function({
      Value<String> id,
      Value<String> pattern,
      Value<int> penaltyScore,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$ExclusionRulesTableFilterComposer
    extends Composer<_$AppDatabase, $ExclusionRulesTable> {
  $$ExclusionRulesTableFilterComposer({
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

  ColumnFilters<String> get pattern => $composableBuilder(
    column: $table.pattern,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get penaltyScore => $composableBuilder(
    column: $table.penaltyScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExclusionRulesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExclusionRulesTable> {
  $$ExclusionRulesTableOrderingComposer({
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

  ColumnOrderings<String> get pattern => $composableBuilder(
    column: $table.pattern,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get penaltyScore => $composableBuilder(
    column: $table.penaltyScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExclusionRulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExclusionRulesTable> {
  $$ExclusionRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get pattern =>
      $composableBuilder(column: $table.pattern, builder: (column) => column);

  GeneratedColumn<int> get penaltyScore => $composableBuilder(
    column: $table.penaltyScore,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ExclusionRulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExclusionRulesTable,
          ExclusionRuleRow,
          $$ExclusionRulesTableFilterComposer,
          $$ExclusionRulesTableOrderingComposer,
          $$ExclusionRulesTableAnnotationComposer,
          $$ExclusionRulesTableCreateCompanionBuilder,
          $$ExclusionRulesTableUpdateCompanionBuilder,
          (
            ExclusionRuleRow,
            BaseReferences<
              _$AppDatabase,
              $ExclusionRulesTable,
              ExclusionRuleRow
            >,
          ),
          ExclusionRuleRow,
          PrefetchHooks Function()
        > {
  $$ExclusionRulesTableTableManager(
    _$AppDatabase db,
    $ExclusionRulesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExclusionRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExclusionRulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExclusionRulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> pattern = const Value.absent(),
                Value<int> penaltyScore = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExclusionRulesCompanion(
                id: id,
                pattern: pattern,
                penaltyScore: penaltyScore,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String pattern,
                Value<int> penaltyScore = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ExclusionRulesCompanion.insert(
                id: id,
                pattern: pattern,
                penaltyScore: penaltyScore,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExclusionRulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExclusionRulesTable,
      ExclusionRuleRow,
      $$ExclusionRulesTableFilterComposer,
      $$ExclusionRulesTableOrderingComposer,
      $$ExclusionRulesTableAnnotationComposer,
      $$ExclusionRulesTableCreateCompanionBuilder,
      $$ExclusionRulesTableUpdateCompanionBuilder,
      (
        ExclusionRuleRow,
        BaseReferences<_$AppDatabase, $ExclusionRulesTable, ExclusionRuleRow>,
      ),
      ExclusionRuleRow,
      PrefetchHooks Function()
    >;
typedef $$AiSuggestionsTableCreateCompanionBuilder =
    AiSuggestionsCompanion Function({
      required String id,
      required String title,
      Value<String?> notes,
      Value<int> priority,
      Value<String> category,
      Value<DateTime?> suggestedDueDate,
      required String reason,
      Value<String> status,
      Value<DateTime?> snoozeUntil,
      Value<String?> explanation,
      Value<String> dedupeKey,
      Value<String?> relatedTaskIds,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$AiSuggestionsTableUpdateCompanionBuilder =
    AiSuggestionsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String?> notes,
      Value<int> priority,
      Value<String> category,
      Value<DateTime?> suggestedDueDate,
      Value<String> reason,
      Value<String> status,
      Value<DateTime?> snoozeUntil,
      Value<String?> explanation,
      Value<String> dedupeKey,
      Value<String?> relatedTaskIds,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$AiSuggestionsTableFilterComposer
    extends Composer<_$AppDatabase, $AiSuggestionsTable> {
  $$AiSuggestionsTableFilterComposer({
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

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get suggestedDueDate => $composableBuilder(
    column: $table.suggestedDueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get snoozeUntil => $composableBuilder(
    column: $table.snoozeUntil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dedupeKey => $composableBuilder(
    column: $table.dedupeKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relatedTaskIds => $composableBuilder(
    column: $table.relatedTaskIds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AiSuggestionsTableOrderingComposer
    extends Composer<_$AppDatabase, $AiSuggestionsTable> {
  $$AiSuggestionsTableOrderingComposer({
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

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get suggestedDueDate => $composableBuilder(
    column: $table.suggestedDueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get snoozeUntil => $composableBuilder(
    column: $table.snoozeUntil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dedupeKey => $composableBuilder(
    column: $table.dedupeKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relatedTaskIds => $composableBuilder(
    column: $table.relatedTaskIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AiSuggestionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AiSuggestionsTable> {
  $$AiSuggestionsTableAnnotationComposer({
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

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<DateTime> get suggestedDueDate => $composableBuilder(
    column: $table.suggestedDueDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get snoozeUntil => $composableBuilder(
    column: $table.snoozeUntil,
    builder: (column) => column,
  );

  GeneratedColumn<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dedupeKey =>
      $composableBuilder(column: $table.dedupeKey, builder: (column) => column);

  GeneratedColumn<String> get relatedTaskIds => $composableBuilder(
    column: $table.relatedTaskIds,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AiSuggestionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AiSuggestionsTable,
          AiSuggestionRow,
          $$AiSuggestionsTableFilterComposer,
          $$AiSuggestionsTableOrderingComposer,
          $$AiSuggestionsTableAnnotationComposer,
          $$AiSuggestionsTableCreateCompanionBuilder,
          $$AiSuggestionsTableUpdateCompanionBuilder,
          (
            AiSuggestionRow,
            BaseReferences<_$AppDatabase, $AiSuggestionsTable, AiSuggestionRow>,
          ),
          AiSuggestionRow,
          PrefetchHooks Function()
        > {
  $$AiSuggestionsTableTableManager(_$AppDatabase db, $AiSuggestionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AiSuggestionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AiSuggestionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AiSuggestionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<DateTime?> suggestedDueDate = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> snoozeUntil = const Value.absent(),
                Value<String?> explanation = const Value.absent(),
                Value<String> dedupeKey = const Value.absent(),
                Value<String?> relatedTaskIds = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AiSuggestionsCompanion(
                id: id,
                title: title,
                notes: notes,
                priority: priority,
                category: category,
                suggestedDueDate: suggestedDueDate,
                reason: reason,
                status: status,
                snoozeUntil: snoozeUntil,
                explanation: explanation,
                dedupeKey: dedupeKey,
                relatedTaskIds: relatedTaskIds,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String?> notes = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<DateTime?> suggestedDueDate = const Value.absent(),
                required String reason,
                Value<String> status = const Value.absent(),
                Value<DateTime?> snoozeUntil = const Value.absent(),
                Value<String?> explanation = const Value.absent(),
                Value<String> dedupeKey = const Value.absent(),
                Value<String?> relatedTaskIds = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => AiSuggestionsCompanion.insert(
                id: id,
                title: title,
                notes: notes,
                priority: priority,
                category: category,
                suggestedDueDate: suggestedDueDate,
                reason: reason,
                status: status,
                snoozeUntil: snoozeUntil,
                explanation: explanation,
                dedupeKey: dedupeKey,
                relatedTaskIds: relatedTaskIds,
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

typedef $$AiSuggestionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AiSuggestionsTable,
      AiSuggestionRow,
      $$AiSuggestionsTableFilterComposer,
      $$AiSuggestionsTableOrderingComposer,
      $$AiSuggestionsTableAnnotationComposer,
      $$AiSuggestionsTableCreateCompanionBuilder,
      $$AiSuggestionsTableUpdateCompanionBuilder,
      (
        AiSuggestionRow,
        BaseReferences<_$AppDatabase, $AiSuggestionsTable, AiSuggestionRow>,
      ),
      AiSuggestionRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PersonalListsTableTableManager get personalLists =>
      $$PersonalListsTableTableManager(_db, _db.personalLists);
  $$PersonalTasksTableTableManager get personalTasks =>
      $$PersonalTasksTableTableManager(_db, _db.personalTasks);
  $$PersonalNotesTableTableManager get personalNotes =>
      $$PersonalNotesTableTableManager(_db, _db.personalNotes);
  $$PersonalSubtasksTableTableManager get personalSubtasks =>
      $$PersonalSubtasksTableTableManager(_db, _db.personalSubtasks);
  $$LinkMemberProposalsTableTableManager get linkMemberProposals =>
      $$LinkMemberProposalsTableTableManager(_db, _db.linkMemberProposals);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$ExclusionRulesTableTableManager get exclusionRules =>
      $$ExclusionRulesTableTableManager(_db, _db.exclusionRules);
  $$AiSuggestionsTableTableManager get aiSuggestions =>
      $$AiSuggestionsTableTableManager(_db, _db.aiSuggestions);
}
