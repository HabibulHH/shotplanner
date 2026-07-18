// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $DbProjectsTable extends DbProjects
    with TableInfo<$DbProjectsTable, DbProject> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DbProjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _templateTypeMeta =
      const VerificationMeta('templateType');
  @override
  late final GeneratedColumn<String> templateType = GeneratedColumn<String>(
      'template_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isArchivedMeta =
      const VerificationMeta('isArchived');
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
      'is_archived', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_archived" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, title, templateType, createdAt, updatedAt, isArchived];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'db_projects';
  @override
  VerificationContext validateIntegrity(Insertable<DbProject> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('template_type')) {
      context.handle(
          _templateTypeMeta,
          templateType.isAcceptableOrUnknown(
              data['template_type']!, _templateTypeMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_archived')) {
      context.handle(
          _isArchivedMeta,
          isArchived.isAcceptableOrUnknown(
              data['is_archived']!, _isArchivedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbProject map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbProject(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      templateType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}template_type']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      isArchived: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_archived'])!,
    );
  }

  @override
  $DbProjectsTable createAlias(String alias) {
    return $DbProjectsTable(attachedDatabase, alias);
  }
}

class DbProject extends DataClass implements Insertable<DbProject> {
  final int id;
  final String title;
  final String? templateType;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isArchived;
  const DbProject(
      {required this.id,
      required this.title,
      this.templateType,
      required this.createdAt,
      required this.updatedAt,
      required this.isArchived});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || templateType != null) {
      map['template_type'] = Variable<String>(templateType);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_archived'] = Variable<bool>(isArchived);
    return map;
  }

  DbProjectsCompanion toCompanion(bool nullToAbsent) {
    return DbProjectsCompanion(
      id: Value(id),
      title: Value(title),
      templateType: templateType == null && nullToAbsent
          ? const Value.absent()
          : Value(templateType),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isArchived: Value(isArchived),
    );
  }

  factory DbProject.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbProject(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      templateType: serializer.fromJson<String?>(json['templateType']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'templateType': serializer.toJson<String?>(templateType),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isArchived': serializer.toJson<bool>(isArchived),
    };
  }

  DbProject copyWith(
          {int? id,
          String? title,
          Value<String?> templateType = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? isArchived}) =>
      DbProject(
        id: id ?? this.id,
        title: title ?? this.title,
        templateType:
            templateType.present ? templateType.value : this.templateType,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isArchived: isArchived ?? this.isArchived,
      );
  DbProject copyWithCompanion(DbProjectsCompanion data) {
    return DbProject(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      templateType: data.templateType.present
          ? data.templateType.value
          : this.templateType,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isArchived:
          data.isArchived.present ? data.isArchived.value : this.isArchived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbProject(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('templateType: $templateType, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isArchived: $isArchived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, title, templateType, createdAt, updatedAt, isArchived);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbProject &&
          other.id == this.id &&
          other.title == this.title &&
          other.templateType == this.templateType &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isArchived == this.isArchived);
}

class DbProjectsCompanion extends UpdateCompanion<DbProject> {
  final Value<int> id;
  final Value<String> title;
  final Value<String?> templateType;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isArchived;
  const DbProjectsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.templateType = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isArchived = const Value.absent(),
  });
  DbProjectsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.templateType = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.isArchived = const Value.absent(),
  })  : title = Value(title),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<DbProject> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? templateType,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isArchived,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (templateType != null) 'template_type': templateType,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isArchived != null) 'is_archived': isArchived,
    });
  }

  DbProjectsCompanion copyWith(
      {Value<int>? id,
      Value<String>? title,
      Value<String?>? templateType,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? isArchived}) {
    return DbProjectsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      templateType: templateType ?? this.templateType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (templateType.present) {
      map['template_type'] = Variable<String>(templateType.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DbProjectsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('templateType: $templateType, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isArchived: $isArchived')
          ..write(')'))
        .toString();
  }
}

class $DbScenesTable extends DbScenes with TableInfo<$DbScenesTable, DbScene> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DbScenesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _projectIdMeta =
      const VerificationMeta('projectId');
  @override
  late final GeneratedColumn<int> projectId = GeneratedColumn<int>(
      'project_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES db_projects (id) ON DELETE CASCADE'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _locationMeta =
      const VerificationMeta('location');
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
      'location', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _timeOfDayMeta =
      const VerificationMeta('timeOfDay');
  @override
  late final GeneratedColumn<String> timeOfDay = GeneratedColumn<String>(
      'time_of_day', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, projectId, title, location, timeOfDay, notes, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'db_scenes';
  @override
  VerificationContext validateIntegrity(Insertable<DbScene> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('project_id')) {
      context.handle(_projectIdMeta,
          projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta));
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('location')) {
      context.handle(_locationMeta,
          location.isAcceptableOrUnknown(data['location']!, _locationMeta));
    }
    if (data.containsKey('time_of_day')) {
      context.handle(
          _timeOfDayMeta,
          timeOfDay.isAcceptableOrUnknown(
              data['time_of_day']!, _timeOfDayMeta));
    } else if (isInserting) {
      context.missing(_timeOfDayMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbScene map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbScene(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      projectId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}project_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      location: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location']),
      timeOfDay: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}time_of_day'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
    );
  }

  @override
  $DbScenesTable createAlias(String alias) {
    return $DbScenesTable(attachedDatabase, alias);
  }
}

class DbScene extends DataClass implements Insertable<DbScene> {
  final int id;
  final int projectId;
  final String title;
  final String? location;
  final String timeOfDay;
  final String? notes;
  final int sortOrder;
  const DbScene(
      {required this.id,
      required this.projectId,
      required this.title,
      this.location,
      required this.timeOfDay,
      this.notes,
      required this.sortOrder});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['project_id'] = Variable<int>(projectId);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    map['time_of_day'] = Variable<String>(timeOfDay);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  DbScenesCompanion toCompanion(bool nullToAbsent) {
    return DbScenesCompanion(
      id: Value(id),
      projectId: Value(projectId),
      title: Value(title),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      timeOfDay: Value(timeOfDay),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      sortOrder: Value(sortOrder),
    );
  }

  factory DbScene.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbScene(
      id: serializer.fromJson<int>(json['id']),
      projectId: serializer.fromJson<int>(json['projectId']),
      title: serializer.fromJson<String>(json['title']),
      location: serializer.fromJson<String?>(json['location']),
      timeOfDay: serializer.fromJson<String>(json['timeOfDay']),
      notes: serializer.fromJson<String?>(json['notes']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'projectId': serializer.toJson<int>(projectId),
      'title': serializer.toJson<String>(title),
      'location': serializer.toJson<String?>(location),
      'timeOfDay': serializer.toJson<String>(timeOfDay),
      'notes': serializer.toJson<String?>(notes),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  DbScene copyWith(
          {int? id,
          int? projectId,
          String? title,
          Value<String?> location = const Value.absent(),
          String? timeOfDay,
          Value<String?> notes = const Value.absent(),
          int? sortOrder}) =>
      DbScene(
        id: id ?? this.id,
        projectId: projectId ?? this.projectId,
        title: title ?? this.title,
        location: location.present ? location.value : this.location,
        timeOfDay: timeOfDay ?? this.timeOfDay,
        notes: notes.present ? notes.value : this.notes,
        sortOrder: sortOrder ?? this.sortOrder,
      );
  DbScene copyWithCompanion(DbScenesCompanion data) {
    return DbScene(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      title: data.title.present ? data.title.value : this.title,
      location: data.location.present ? data.location.value : this.location,
      timeOfDay: data.timeOfDay.present ? data.timeOfDay.value : this.timeOfDay,
      notes: data.notes.present ? data.notes.value : this.notes,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbScene(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('title: $title, ')
          ..write('location: $location, ')
          ..write('timeOfDay: $timeOfDay, ')
          ..write('notes: $notes, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, projectId, title, location, timeOfDay, notes, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbScene &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.title == this.title &&
          other.location == this.location &&
          other.timeOfDay == this.timeOfDay &&
          other.notes == this.notes &&
          other.sortOrder == this.sortOrder);
}

class DbScenesCompanion extends UpdateCompanion<DbScene> {
  final Value<int> id;
  final Value<int> projectId;
  final Value<String> title;
  final Value<String?> location;
  final Value<String> timeOfDay;
  final Value<String?> notes;
  final Value<int> sortOrder;
  const DbScenesCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.title = const Value.absent(),
    this.location = const Value.absent(),
    this.timeOfDay = const Value.absent(),
    this.notes = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  DbScenesCompanion.insert({
    this.id = const Value.absent(),
    required int projectId,
    required String title,
    this.location = const Value.absent(),
    required String timeOfDay,
    this.notes = const Value.absent(),
    required int sortOrder,
  })  : projectId = Value(projectId),
        title = Value(title),
        timeOfDay = Value(timeOfDay),
        sortOrder = Value(sortOrder);
  static Insertable<DbScene> custom({
    Expression<int>? id,
    Expression<int>? projectId,
    Expression<String>? title,
    Expression<String>? location,
    Expression<String>? timeOfDay,
    Expression<String>? notes,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (title != null) 'title': title,
      if (location != null) 'location': location,
      if (timeOfDay != null) 'time_of_day': timeOfDay,
      if (notes != null) 'notes': notes,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  DbScenesCompanion copyWith(
      {Value<int>? id,
      Value<int>? projectId,
      Value<String>? title,
      Value<String?>? location,
      Value<String>? timeOfDay,
      Value<String?>? notes,
      Value<int>? sortOrder}) {
    return DbScenesCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      location: location ?? this.location,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      notes: notes ?? this.notes,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<int>(projectId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (timeOfDay.present) {
      map['time_of_day'] = Variable<String>(timeOfDay.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DbScenesCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('title: $title, ')
          ..write('location: $location, ')
          ..write('timeOfDay: $timeOfDay, ')
          ..write('notes: $notes, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $DbShotsTable extends DbShots with TableInfo<$DbShotsTable, DbShot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DbShotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _sceneIdMeta =
      const VerificationMeta('sceneId');
  @override
  late final GeneratedColumn<int> sceneId = GeneratedColumn<int>(
      'scene_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES db_scenes (id) ON DELETE CASCADE'));
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _shotSizeMeta =
      const VerificationMeta('shotSize');
  @override
  late final GeneratedColumn<String> shotSize = GeneratedColumn<String>(
      'shot_size', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _angleMeta = const VerificationMeta('angle');
  @override
  late final GeneratedColumn<String> angle = GeneratedColumn<String>(
      'angle', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _movementMeta =
      const VerificationMeta('movement');
  @override
  late final GeneratedColumn<String> movement = GeneratedColumn<String>(
      'movement', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lensMeta = const VerificationMeta('lens');
  @override
  late final GeneratedColumn<String> lens = GeneratedColumn<String>(
      'lens', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _cameraMeta = const VerificationMeta('camera');
  @override
  late final GeneratedColumn<String> camera = GeneratedColumn<String>(
      'camera', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _durationSecMeta =
      const VerificationMeta('durationSec');
  @override
  late final GeneratedColumn<int> durationSec = GeneratedColumn<int>(
      'duration_sec', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _priorityMeta =
      const VerificationMeta('priority');
  @override
  late final GeneratedColumn<String> priority = GeneratedColumn<String>(
      'priority', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('must'));
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _imagePathMeta =
      const VerificationMeta('imagePath');
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
      'image_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isDoneMeta = const VerificationMeta('isDone');
  @override
  late final GeneratedColumn<bool> isDone = GeneratedColumn<bool>(
      'is_done', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_done" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        sceneId,
        description,
        shotSize,
        angle,
        movement,
        lens,
        camera,
        durationSec,
        priority,
        notes,
        imagePath,
        isDone,
        sortOrder
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'db_shots';
  @override
  VerificationContext validateIntegrity(Insertable<DbShot> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('scene_id')) {
      context.handle(_sceneIdMeta,
          sceneId.isAcceptableOrUnknown(data['scene_id']!, _sceneIdMeta));
    } else if (isInserting) {
      context.missing(_sceneIdMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('shot_size')) {
      context.handle(_shotSizeMeta,
          shotSize.isAcceptableOrUnknown(data['shot_size']!, _shotSizeMeta));
    } else if (isInserting) {
      context.missing(_shotSizeMeta);
    }
    if (data.containsKey('angle')) {
      context.handle(
          _angleMeta, angle.isAcceptableOrUnknown(data['angle']!, _angleMeta));
    } else if (isInserting) {
      context.missing(_angleMeta);
    }
    if (data.containsKey('movement')) {
      context.handle(_movementMeta,
          movement.isAcceptableOrUnknown(data['movement']!, _movementMeta));
    } else if (isInserting) {
      context.missing(_movementMeta);
    }
    if (data.containsKey('lens')) {
      context.handle(
          _lensMeta, lens.isAcceptableOrUnknown(data['lens']!, _lensMeta));
    }
    if (data.containsKey('camera')) {
      context.handle(_cameraMeta,
          camera.isAcceptableOrUnknown(data['camera']!, _cameraMeta));
    }
    if (data.containsKey('duration_sec')) {
      context.handle(
          _durationSecMeta,
          durationSec.isAcceptableOrUnknown(
              data['duration_sec']!, _durationSecMeta));
    }
    if (data.containsKey('priority')) {
      context.handle(_priorityMeta,
          priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('image_path')) {
      context.handle(_imagePathMeta,
          imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta));
    }
    if (data.containsKey('is_done')) {
      context.handle(_isDoneMeta,
          isDone.isAcceptableOrUnknown(data['is_done']!, _isDoneMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbShot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbShot(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      sceneId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}scene_id'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      shotSize: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}shot_size'])!,
      angle: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}angle'])!,
      movement: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}movement'])!,
      lens: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}lens']),
      camera: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}camera']),
      durationSec: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_sec']),
      priority: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}priority'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      imagePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_path']),
      isDone: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_done'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
    );
  }

  @override
  $DbShotsTable createAlias(String alias) {
    return $DbShotsTable(attachedDatabase, alias);
  }
}

class DbShot extends DataClass implements Insertable<DbShot> {
  final int id;
  final int sceneId;
  final String description;
  final String shotSize;
  final String angle;
  final String movement;
  final String? lens;
  final String? camera;
  final int? durationSec;
  final String priority;
  final String? notes;
  final String? imagePath;
  final bool isDone;
  final int sortOrder;
  const DbShot(
      {required this.id,
      required this.sceneId,
      required this.description,
      required this.shotSize,
      required this.angle,
      required this.movement,
      this.lens,
      this.camera,
      this.durationSec,
      required this.priority,
      this.notes,
      this.imagePath,
      required this.isDone,
      required this.sortOrder});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['scene_id'] = Variable<int>(sceneId);
    map['description'] = Variable<String>(description);
    map['shot_size'] = Variable<String>(shotSize);
    map['angle'] = Variable<String>(angle);
    map['movement'] = Variable<String>(movement);
    if (!nullToAbsent || lens != null) {
      map['lens'] = Variable<String>(lens);
    }
    if (!nullToAbsent || camera != null) {
      map['camera'] = Variable<String>(camera);
    }
    if (!nullToAbsent || durationSec != null) {
      map['duration_sec'] = Variable<int>(durationSec);
    }
    map['priority'] = Variable<String>(priority);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    map['is_done'] = Variable<bool>(isDone);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  DbShotsCompanion toCompanion(bool nullToAbsent) {
    return DbShotsCompanion(
      id: Value(id),
      sceneId: Value(sceneId),
      description: Value(description),
      shotSize: Value(shotSize),
      angle: Value(angle),
      movement: Value(movement),
      lens: lens == null && nullToAbsent ? const Value.absent() : Value(lens),
      camera:
          camera == null && nullToAbsent ? const Value.absent() : Value(camera),
      durationSec: durationSec == null && nullToAbsent
          ? const Value.absent()
          : Value(durationSec),
      priority: Value(priority),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
      isDone: Value(isDone),
      sortOrder: Value(sortOrder),
    );
  }

  factory DbShot.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbShot(
      id: serializer.fromJson<int>(json['id']),
      sceneId: serializer.fromJson<int>(json['sceneId']),
      description: serializer.fromJson<String>(json['description']),
      shotSize: serializer.fromJson<String>(json['shotSize']),
      angle: serializer.fromJson<String>(json['angle']),
      movement: serializer.fromJson<String>(json['movement']),
      lens: serializer.fromJson<String?>(json['lens']),
      camera: serializer.fromJson<String?>(json['camera']),
      durationSec: serializer.fromJson<int?>(json['durationSec']),
      priority: serializer.fromJson<String>(json['priority']),
      notes: serializer.fromJson<String?>(json['notes']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
      isDone: serializer.fromJson<bool>(json['isDone']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sceneId': serializer.toJson<int>(sceneId),
      'description': serializer.toJson<String>(description),
      'shotSize': serializer.toJson<String>(shotSize),
      'angle': serializer.toJson<String>(angle),
      'movement': serializer.toJson<String>(movement),
      'lens': serializer.toJson<String?>(lens),
      'camera': serializer.toJson<String?>(camera),
      'durationSec': serializer.toJson<int?>(durationSec),
      'priority': serializer.toJson<String>(priority),
      'notes': serializer.toJson<String?>(notes),
      'imagePath': serializer.toJson<String?>(imagePath),
      'isDone': serializer.toJson<bool>(isDone),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  DbShot copyWith(
          {int? id,
          int? sceneId,
          String? description,
          String? shotSize,
          String? angle,
          String? movement,
          Value<String?> lens = const Value.absent(),
          Value<String?> camera = const Value.absent(),
          Value<int?> durationSec = const Value.absent(),
          String? priority,
          Value<String?> notes = const Value.absent(),
          Value<String?> imagePath = const Value.absent(),
          bool? isDone,
          int? sortOrder}) =>
      DbShot(
        id: id ?? this.id,
        sceneId: sceneId ?? this.sceneId,
        description: description ?? this.description,
        shotSize: shotSize ?? this.shotSize,
        angle: angle ?? this.angle,
        movement: movement ?? this.movement,
        lens: lens.present ? lens.value : this.lens,
        camera: camera.present ? camera.value : this.camera,
        durationSec: durationSec.present ? durationSec.value : this.durationSec,
        priority: priority ?? this.priority,
        notes: notes.present ? notes.value : this.notes,
        imagePath: imagePath.present ? imagePath.value : this.imagePath,
        isDone: isDone ?? this.isDone,
        sortOrder: sortOrder ?? this.sortOrder,
      );
  DbShot copyWithCompanion(DbShotsCompanion data) {
    return DbShot(
      id: data.id.present ? data.id.value : this.id,
      sceneId: data.sceneId.present ? data.sceneId.value : this.sceneId,
      description:
          data.description.present ? data.description.value : this.description,
      shotSize: data.shotSize.present ? data.shotSize.value : this.shotSize,
      angle: data.angle.present ? data.angle.value : this.angle,
      movement: data.movement.present ? data.movement.value : this.movement,
      lens: data.lens.present ? data.lens.value : this.lens,
      camera: data.camera.present ? data.camera.value : this.camera,
      durationSec:
          data.durationSec.present ? data.durationSec.value : this.durationSec,
      priority: data.priority.present ? data.priority.value : this.priority,
      notes: data.notes.present ? data.notes.value : this.notes,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      isDone: data.isDone.present ? data.isDone.value : this.isDone,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbShot(')
          ..write('id: $id, ')
          ..write('sceneId: $sceneId, ')
          ..write('description: $description, ')
          ..write('shotSize: $shotSize, ')
          ..write('angle: $angle, ')
          ..write('movement: $movement, ')
          ..write('lens: $lens, ')
          ..write('camera: $camera, ')
          ..write('durationSec: $durationSec, ')
          ..write('priority: $priority, ')
          ..write('notes: $notes, ')
          ..write('imagePath: $imagePath, ')
          ..write('isDone: $isDone, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      sceneId,
      description,
      shotSize,
      angle,
      movement,
      lens,
      camera,
      durationSec,
      priority,
      notes,
      imagePath,
      isDone,
      sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbShot &&
          other.id == this.id &&
          other.sceneId == this.sceneId &&
          other.description == this.description &&
          other.shotSize == this.shotSize &&
          other.angle == this.angle &&
          other.movement == this.movement &&
          other.lens == this.lens &&
          other.camera == this.camera &&
          other.durationSec == this.durationSec &&
          other.priority == this.priority &&
          other.notes == this.notes &&
          other.imagePath == this.imagePath &&
          other.isDone == this.isDone &&
          other.sortOrder == this.sortOrder);
}

class DbShotsCompanion extends UpdateCompanion<DbShot> {
  final Value<int> id;
  final Value<int> sceneId;
  final Value<String> description;
  final Value<String> shotSize;
  final Value<String> angle;
  final Value<String> movement;
  final Value<String?> lens;
  final Value<String?> camera;
  final Value<int?> durationSec;
  final Value<String> priority;
  final Value<String?> notes;
  final Value<String?> imagePath;
  final Value<bool> isDone;
  final Value<int> sortOrder;
  const DbShotsCompanion({
    this.id = const Value.absent(),
    this.sceneId = const Value.absent(),
    this.description = const Value.absent(),
    this.shotSize = const Value.absent(),
    this.angle = const Value.absent(),
    this.movement = const Value.absent(),
    this.lens = const Value.absent(),
    this.camera = const Value.absent(),
    this.durationSec = const Value.absent(),
    this.priority = const Value.absent(),
    this.notes = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.isDone = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  DbShotsCompanion.insert({
    this.id = const Value.absent(),
    required int sceneId,
    required String description,
    required String shotSize,
    required String angle,
    required String movement,
    this.lens = const Value.absent(),
    this.camera = const Value.absent(),
    this.durationSec = const Value.absent(),
    this.priority = const Value.absent(),
    this.notes = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.isDone = const Value.absent(),
    required int sortOrder,
  })  : sceneId = Value(sceneId),
        description = Value(description),
        shotSize = Value(shotSize),
        angle = Value(angle),
        movement = Value(movement),
        sortOrder = Value(sortOrder);
  static Insertable<DbShot> custom({
    Expression<int>? id,
    Expression<int>? sceneId,
    Expression<String>? description,
    Expression<String>? shotSize,
    Expression<String>? angle,
    Expression<String>? movement,
    Expression<String>? lens,
    Expression<String>? camera,
    Expression<int>? durationSec,
    Expression<String>? priority,
    Expression<String>? notes,
    Expression<String>? imagePath,
    Expression<bool>? isDone,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sceneId != null) 'scene_id': sceneId,
      if (description != null) 'description': description,
      if (shotSize != null) 'shot_size': shotSize,
      if (angle != null) 'angle': angle,
      if (movement != null) 'movement': movement,
      if (lens != null) 'lens': lens,
      if (camera != null) 'camera': camera,
      if (durationSec != null) 'duration_sec': durationSec,
      if (priority != null) 'priority': priority,
      if (notes != null) 'notes': notes,
      if (imagePath != null) 'image_path': imagePath,
      if (isDone != null) 'is_done': isDone,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  DbShotsCompanion copyWith(
      {Value<int>? id,
      Value<int>? sceneId,
      Value<String>? description,
      Value<String>? shotSize,
      Value<String>? angle,
      Value<String>? movement,
      Value<String?>? lens,
      Value<String?>? camera,
      Value<int?>? durationSec,
      Value<String>? priority,
      Value<String?>? notes,
      Value<String?>? imagePath,
      Value<bool>? isDone,
      Value<int>? sortOrder}) {
    return DbShotsCompanion(
      id: id ?? this.id,
      sceneId: sceneId ?? this.sceneId,
      description: description ?? this.description,
      shotSize: shotSize ?? this.shotSize,
      angle: angle ?? this.angle,
      movement: movement ?? this.movement,
      lens: lens ?? this.lens,
      camera: camera ?? this.camera,
      durationSec: durationSec ?? this.durationSec,
      priority: priority ?? this.priority,
      notes: notes ?? this.notes,
      imagePath: imagePath ?? this.imagePath,
      isDone: isDone ?? this.isDone,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sceneId.present) {
      map['scene_id'] = Variable<int>(sceneId.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (shotSize.present) {
      map['shot_size'] = Variable<String>(shotSize.value);
    }
    if (angle.present) {
      map['angle'] = Variable<String>(angle.value);
    }
    if (movement.present) {
      map['movement'] = Variable<String>(movement.value);
    }
    if (lens.present) {
      map['lens'] = Variable<String>(lens.value);
    }
    if (camera.present) {
      map['camera'] = Variable<String>(camera.value);
    }
    if (durationSec.present) {
      map['duration_sec'] = Variable<int>(durationSec.value);
    }
    if (priority.present) {
      map['priority'] = Variable<String>(priority.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (isDone.present) {
      map['is_done'] = Variable<bool>(isDone.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DbShotsCompanion(')
          ..write('id: $id, ')
          ..write('sceneId: $sceneId, ')
          ..write('description: $description, ')
          ..write('shotSize: $shotSize, ')
          ..write('angle: $angle, ')
          ..write('movement: $movement, ')
          ..write('lens: $lens, ')
          ..write('camera: $camera, ')
          ..write('durationSec: $durationSec, ')
          ..write('priority: $priority, ')
          ..write('notes: $notes, ')
          ..write('imagePath: $imagePath, ')
          ..write('isDone: $isDone, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(Insertable<AppSetting> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String value;
  const AppSetting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      key: Value(key),
      value: Value(value),
    );
  }

  factory AppSetting.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
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

  AppSetting copyWith({String? key, String? value}) => AppSetting(
        key: key ?? this.key,
        value: value ?? this.value,
      );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
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
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        value = Value(value);
  static Insertable<AppSetting> custom({
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

  AppSettingsCompanion copyWith(
      {Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return AppSettingsCompanion(
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
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DbProjectsTable dbProjects = $DbProjectsTable(this);
  late final $DbScenesTable dbScenes = $DbScenesTable(this);
  late final $DbShotsTable dbShots = $DbShotsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [dbProjects, dbScenes, dbShots, appSettings];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('db_projects',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('db_scenes', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('db_scenes',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('db_shots', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$DbProjectsTableCreateCompanionBuilder = DbProjectsCompanion Function({
  Value<int> id,
  required String title,
  Value<String?> templateType,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<bool> isArchived,
});
typedef $$DbProjectsTableUpdateCompanionBuilder = DbProjectsCompanion Function({
  Value<int> id,
  Value<String> title,
  Value<String?> templateType,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isArchived,
});

final class $$DbProjectsTableReferences
    extends BaseReferences<_$AppDatabase, $DbProjectsTable, DbProject> {
  $$DbProjectsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$DbScenesTable, List<DbScene>> _dbScenesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.dbScenes,
          aliasName: 'db_projects__id__db_scenes__project_id');

  $$DbScenesTableProcessedTableManager get dbScenesRefs {
    final manager = $$DbScenesTableTableManager($_db, $_db.dbScenes)
        .filter((f) => f.projectId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_dbScenesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$DbProjectsTableFilterComposer
    extends Composer<_$AppDatabase, $DbProjectsTable> {
  $$DbProjectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get templateType => $composableBuilder(
      column: $table.templateType, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnFilters(column));

  Expression<bool> dbScenesRefs(
      Expression<bool> Function($$DbScenesTableFilterComposer f) f) {
    final $$DbScenesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.dbScenes,
        getReferencedColumn: (t) => t.projectId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DbScenesTableFilterComposer(
              $db: $db,
              $table: $db.dbScenes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$DbProjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $DbProjectsTable> {
  $$DbProjectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get templateType => $composableBuilder(
      column: $table.templateType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnOrderings(column));
}

class $$DbProjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DbProjectsTable> {
  $$DbProjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get templateType => $composableBuilder(
      column: $table.templateType, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => column);

  Expression<T> dbScenesRefs<T extends Object>(
      Expression<T> Function($$DbScenesTableAnnotationComposer a) f) {
    final $$DbScenesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.dbScenes,
        getReferencedColumn: (t) => t.projectId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DbScenesTableAnnotationComposer(
              $db: $db,
              $table: $db.dbScenes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$DbProjectsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DbProjectsTable,
    DbProject,
    $$DbProjectsTableFilterComposer,
    $$DbProjectsTableOrderingComposer,
    $$DbProjectsTableAnnotationComposer,
    $$DbProjectsTableCreateCompanionBuilder,
    $$DbProjectsTableUpdateCompanionBuilder,
    (DbProject, $$DbProjectsTableReferences),
    DbProject,
    PrefetchHooks Function({bool dbScenesRefs})> {
  $$DbProjectsTableTableManager(_$AppDatabase db, $DbProjectsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DbProjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DbProjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DbProjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> templateType = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isArchived = const Value.absent(),
          }) =>
              DbProjectsCompanion(
            id: id,
            title: title,
            templateType: templateType,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isArchived: isArchived,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String title,
            Value<String?> templateType = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<bool> isArchived = const Value.absent(),
          }) =>
              DbProjectsCompanion.insert(
            id: id,
            title: title,
            templateType: templateType,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isArchived: isArchived,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$DbProjectsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({dbScenesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (dbScenesRefs) db.dbScenes],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (dbScenesRefs)
                    await $_getPrefetchedData<DbProject, $DbProjectsTable,
                            DbScene>(
                        currentTable: table,
                        referencedTable:
                            $$DbProjectsTableReferences._dbScenesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$DbProjectsTableReferences(db, table, p0)
                                .dbScenesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.projectId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$DbProjectsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DbProjectsTable,
    DbProject,
    $$DbProjectsTableFilterComposer,
    $$DbProjectsTableOrderingComposer,
    $$DbProjectsTableAnnotationComposer,
    $$DbProjectsTableCreateCompanionBuilder,
    $$DbProjectsTableUpdateCompanionBuilder,
    (DbProject, $$DbProjectsTableReferences),
    DbProject,
    PrefetchHooks Function({bool dbScenesRefs})>;
typedef $$DbScenesTableCreateCompanionBuilder = DbScenesCompanion Function({
  Value<int> id,
  required int projectId,
  required String title,
  Value<String?> location,
  required String timeOfDay,
  Value<String?> notes,
  required int sortOrder,
});
typedef $$DbScenesTableUpdateCompanionBuilder = DbScenesCompanion Function({
  Value<int> id,
  Value<int> projectId,
  Value<String> title,
  Value<String?> location,
  Value<String> timeOfDay,
  Value<String?> notes,
  Value<int> sortOrder,
});

final class $$DbScenesTableReferences
    extends BaseReferences<_$AppDatabase, $DbScenesTable, DbScene> {
  $$DbScenesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DbProjectsTable _projectIdTable(_$AppDatabase db) =>
      db.dbProjects.createAlias('db_scenes__project_id__db_projects__id');

  $$DbProjectsTableProcessedTableManager get projectId {
    final $_column = $_itemColumn<int>('project_id')!;

    final manager = $$DbProjectsTableTableManager($_db, $_db.dbProjects)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$DbShotsTable, List<DbShot>> _dbShotsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.dbShots,
          aliasName: 'db_scenes__id__db_shots__scene_id');

  $$DbShotsTableProcessedTableManager get dbShotsRefs {
    final manager = $$DbShotsTableTableManager($_db, $_db.dbShots)
        .filter((f) => f.sceneId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_dbShotsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$DbScenesTableFilterComposer
    extends Composer<_$AppDatabase, $DbScenesTable> {
  $$DbScenesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get timeOfDay => $composableBuilder(
      column: $table.timeOfDay, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  $$DbProjectsTableFilterComposer get projectId {
    final $$DbProjectsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.projectId,
        referencedTable: $db.dbProjects,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DbProjectsTableFilterComposer(
              $db: $db,
              $table: $db.dbProjects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> dbShotsRefs(
      Expression<bool> Function($$DbShotsTableFilterComposer f) f) {
    final $$DbShotsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.dbShots,
        getReferencedColumn: (t) => t.sceneId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DbShotsTableFilterComposer(
              $db: $db,
              $table: $db.dbShots,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$DbScenesTableOrderingComposer
    extends Composer<_$AppDatabase, $DbScenesTable> {
  $$DbScenesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get timeOfDay => $composableBuilder(
      column: $table.timeOfDay, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  $$DbProjectsTableOrderingComposer get projectId {
    final $$DbProjectsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.projectId,
        referencedTable: $db.dbProjects,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DbProjectsTableOrderingComposer(
              $db: $db,
              $table: $db.dbProjects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DbScenesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DbScenesTable> {
  $$DbScenesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get timeOfDay =>
      $composableBuilder(column: $table.timeOfDay, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $$DbProjectsTableAnnotationComposer get projectId {
    final $$DbProjectsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.projectId,
        referencedTable: $db.dbProjects,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DbProjectsTableAnnotationComposer(
              $db: $db,
              $table: $db.dbProjects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> dbShotsRefs<T extends Object>(
      Expression<T> Function($$DbShotsTableAnnotationComposer a) f) {
    final $$DbShotsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.dbShots,
        getReferencedColumn: (t) => t.sceneId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DbShotsTableAnnotationComposer(
              $db: $db,
              $table: $db.dbShots,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$DbScenesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DbScenesTable,
    DbScene,
    $$DbScenesTableFilterComposer,
    $$DbScenesTableOrderingComposer,
    $$DbScenesTableAnnotationComposer,
    $$DbScenesTableCreateCompanionBuilder,
    $$DbScenesTableUpdateCompanionBuilder,
    (DbScene, $$DbScenesTableReferences),
    DbScene,
    PrefetchHooks Function({bool projectId, bool dbShotsRefs})> {
  $$DbScenesTableTableManager(_$AppDatabase db, $DbScenesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DbScenesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DbScenesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DbScenesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> projectId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> location = const Value.absent(),
            Value<String> timeOfDay = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
          }) =>
              DbScenesCompanion(
            id: id,
            projectId: projectId,
            title: title,
            location: location,
            timeOfDay: timeOfDay,
            notes: notes,
            sortOrder: sortOrder,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int projectId,
            required String title,
            Value<String?> location = const Value.absent(),
            required String timeOfDay,
            Value<String?> notes = const Value.absent(),
            required int sortOrder,
          }) =>
              DbScenesCompanion.insert(
            id: id,
            projectId: projectId,
            title: title,
            location: location,
            timeOfDay: timeOfDay,
            notes: notes,
            sortOrder: sortOrder,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$DbScenesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({projectId = false, dbShotsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (dbShotsRefs) db.dbShots],
              addJoins: <
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
                      dynamic>>(state) {
                if (projectId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.projectId,
                    referencedTable:
                        $$DbScenesTableReferences._projectIdTable(db),
                    referencedColumn:
                        $$DbScenesTableReferences._projectIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (dbShotsRefs)
                    await $_getPrefetchedData<DbScene, $DbScenesTable, DbShot>(
                        currentTable: table,
                        referencedTable:
                            $$DbScenesTableReferences._dbShotsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$DbScenesTableReferences(db, table, p0)
                                .dbShotsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.sceneId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$DbScenesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DbScenesTable,
    DbScene,
    $$DbScenesTableFilterComposer,
    $$DbScenesTableOrderingComposer,
    $$DbScenesTableAnnotationComposer,
    $$DbScenesTableCreateCompanionBuilder,
    $$DbScenesTableUpdateCompanionBuilder,
    (DbScene, $$DbScenesTableReferences),
    DbScene,
    PrefetchHooks Function({bool projectId, bool dbShotsRefs})>;
typedef $$DbShotsTableCreateCompanionBuilder = DbShotsCompanion Function({
  Value<int> id,
  required int sceneId,
  required String description,
  required String shotSize,
  required String angle,
  required String movement,
  Value<String?> lens,
  Value<String?> camera,
  Value<int?> durationSec,
  Value<String> priority,
  Value<String?> notes,
  Value<String?> imagePath,
  Value<bool> isDone,
  required int sortOrder,
});
typedef $$DbShotsTableUpdateCompanionBuilder = DbShotsCompanion Function({
  Value<int> id,
  Value<int> sceneId,
  Value<String> description,
  Value<String> shotSize,
  Value<String> angle,
  Value<String> movement,
  Value<String?> lens,
  Value<String?> camera,
  Value<int?> durationSec,
  Value<String> priority,
  Value<String?> notes,
  Value<String?> imagePath,
  Value<bool> isDone,
  Value<int> sortOrder,
});

final class $$DbShotsTableReferences
    extends BaseReferences<_$AppDatabase, $DbShotsTable, DbShot> {
  $$DbShotsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DbScenesTable _sceneIdTable(_$AppDatabase db) =>
      db.dbScenes.createAlias('db_shots__scene_id__db_scenes__id');

  $$DbScenesTableProcessedTableManager get sceneId {
    final $_column = $_itemColumn<int>('scene_id')!;

    final manager = $$DbScenesTableTableManager($_db, $_db.dbScenes)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sceneIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$DbShotsTableFilterComposer
    extends Composer<_$AppDatabase, $DbShotsTable> {
  $$DbShotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get shotSize => $composableBuilder(
      column: $table.shotSize, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get angle => $composableBuilder(
      column: $table.angle, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get movement => $composableBuilder(
      column: $table.movement, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lens => $composableBuilder(
      column: $table.lens, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get camera => $composableBuilder(
      column: $table.camera, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationSec => $composableBuilder(
      column: $table.durationSec, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imagePath => $composableBuilder(
      column: $table.imagePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDone => $composableBuilder(
      column: $table.isDone, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  $$DbScenesTableFilterComposer get sceneId {
    final $$DbScenesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sceneId,
        referencedTable: $db.dbScenes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DbScenesTableFilterComposer(
              $db: $db,
              $table: $db.dbScenes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DbShotsTableOrderingComposer
    extends Composer<_$AppDatabase, $DbShotsTable> {
  $$DbShotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get shotSize => $composableBuilder(
      column: $table.shotSize, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get angle => $composableBuilder(
      column: $table.angle, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get movement => $composableBuilder(
      column: $table.movement, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lens => $composableBuilder(
      column: $table.lens, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get camera => $composableBuilder(
      column: $table.camera, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationSec => $composableBuilder(
      column: $table.durationSec, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imagePath => $composableBuilder(
      column: $table.imagePath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDone => $composableBuilder(
      column: $table.isDone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  $$DbScenesTableOrderingComposer get sceneId {
    final $$DbScenesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sceneId,
        referencedTable: $db.dbScenes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DbScenesTableOrderingComposer(
              $db: $db,
              $table: $db.dbScenes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DbShotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DbShotsTable> {
  $$DbShotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get shotSize =>
      $composableBuilder(column: $table.shotSize, builder: (column) => column);

  GeneratedColumn<String> get angle =>
      $composableBuilder(column: $table.angle, builder: (column) => column);

  GeneratedColumn<String> get movement =>
      $composableBuilder(column: $table.movement, builder: (column) => column);

  GeneratedColumn<String> get lens =>
      $composableBuilder(column: $table.lens, builder: (column) => column);

  GeneratedColumn<String> get camera =>
      $composableBuilder(column: $table.camera, builder: (column) => column);

  GeneratedColumn<int> get durationSec => $composableBuilder(
      column: $table.durationSec, builder: (column) => column);

  GeneratedColumn<String> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<bool> get isDone =>
      $composableBuilder(column: $table.isDone, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $$DbScenesTableAnnotationComposer get sceneId {
    final $$DbScenesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sceneId,
        referencedTable: $db.dbScenes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DbScenesTableAnnotationComposer(
              $db: $db,
              $table: $db.dbScenes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DbShotsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DbShotsTable,
    DbShot,
    $$DbShotsTableFilterComposer,
    $$DbShotsTableOrderingComposer,
    $$DbShotsTableAnnotationComposer,
    $$DbShotsTableCreateCompanionBuilder,
    $$DbShotsTableUpdateCompanionBuilder,
    (DbShot, $$DbShotsTableReferences),
    DbShot,
    PrefetchHooks Function({bool sceneId})> {
  $$DbShotsTableTableManager(_$AppDatabase db, $DbShotsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DbShotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DbShotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DbShotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> sceneId = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String> shotSize = const Value.absent(),
            Value<String> angle = const Value.absent(),
            Value<String> movement = const Value.absent(),
            Value<String?> lens = const Value.absent(),
            Value<String?> camera = const Value.absent(),
            Value<int?> durationSec = const Value.absent(),
            Value<String> priority = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String?> imagePath = const Value.absent(),
            Value<bool> isDone = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
          }) =>
              DbShotsCompanion(
            id: id,
            sceneId: sceneId,
            description: description,
            shotSize: shotSize,
            angle: angle,
            movement: movement,
            lens: lens,
            camera: camera,
            durationSec: durationSec,
            priority: priority,
            notes: notes,
            imagePath: imagePath,
            isDone: isDone,
            sortOrder: sortOrder,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int sceneId,
            required String description,
            required String shotSize,
            required String angle,
            required String movement,
            Value<String?> lens = const Value.absent(),
            Value<String?> camera = const Value.absent(),
            Value<int?> durationSec = const Value.absent(),
            Value<String> priority = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String?> imagePath = const Value.absent(),
            Value<bool> isDone = const Value.absent(),
            required int sortOrder,
          }) =>
              DbShotsCompanion.insert(
            id: id,
            sceneId: sceneId,
            description: description,
            shotSize: shotSize,
            angle: angle,
            movement: movement,
            lens: lens,
            camera: camera,
            durationSec: durationSec,
            priority: priority,
            notes: notes,
            imagePath: imagePath,
            isDone: isDone,
            sortOrder: sortOrder,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$DbShotsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({sceneId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (sceneId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.sceneId,
                    referencedTable: $$DbShotsTableReferences._sceneIdTable(db),
                    referencedColumn:
                        $$DbShotsTableReferences._sceneIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$DbShotsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DbShotsTable,
    DbShot,
    $$DbShotsTableFilterComposer,
    $$DbShotsTableOrderingComposer,
    $$DbShotsTableAnnotationComposer,
    $$DbShotsTableCreateCompanionBuilder,
    $$DbShotsTableUpdateCompanionBuilder,
    (DbShot, $$DbShotsTableReferences),
    DbShot,
    PrefetchHooks Function({bool sceneId})>;
typedef $$AppSettingsTableCreateCompanionBuilder = AppSettingsCompanion
    Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$AppSettingsTableUpdateCompanionBuilder = AppSettingsCompanion
    Function({
  Value<String> key,
  Value<String> value,
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
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));
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
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));
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

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AppSettingsTable,
    AppSetting,
    $$AppSettingsTableFilterComposer,
    $$AppSettingsTableOrderingComposer,
    $$AppSettingsTableAnnotationComposer,
    $$AppSettingsTableCreateCompanionBuilder,
    $$AppSettingsTableUpdateCompanionBuilder,
    (AppSetting, BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>),
    AppSetting,
    PrefetchHooks Function()> {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AppSettingsCompanion(
            key: key,
            value: value,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) =>
              AppSettingsCompanion.insert(
            key: key,
            value: value,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AppSettingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AppSettingsTable,
    AppSetting,
    $$AppSettingsTableFilterComposer,
    $$AppSettingsTableOrderingComposer,
    $$AppSettingsTableAnnotationComposer,
    $$AppSettingsTableCreateCompanionBuilder,
    $$AppSettingsTableUpdateCompanionBuilder,
    (AppSetting, BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>),
    AppSetting,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DbProjectsTableTableManager get dbProjects =>
      $$DbProjectsTableTableManager(_db, _db.dbProjects);
  $$DbScenesTableTableManager get dbScenes =>
      $$DbScenesTableTableManager(_db, _db.dbScenes);
  $$DbShotsTableTableManager get dbShots =>
      $$DbShotsTableTableManager(_db, _db.dbShots);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}
