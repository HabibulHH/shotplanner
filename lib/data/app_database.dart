import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class DbProjects extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get templateType => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
}

class DbScenes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get projectId =>
      integer().references(DbProjects, #id, onDelete: KeyAction.cascade)();
  TextColumn get title => text()();
  TextColumn get location => text().nullable()();
  TextColumn get timeOfDay => text()();
  TextColumn get notes => text().nullable()();
  IntColumn get sortOrder => integer()();
}

class DbShots extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sceneId =>
      integer().references(DbScenes, #id, onDelete: KeyAction.cascade)();
  TextColumn get description => text()();
  TextColumn get shotSize => text()();
  TextColumn get angle => text()();
  TextColumn get movement => text()();
  TextColumn get lens => text().nullable()();
  TextColumn get camera => text().nullable()();
  IntColumn get durationSec => integer().nullable()();
  TextColumn get priority => text().withDefault(const Constant('must'))();
  TextColumn get notes => text().nullable()();
  TextColumn get imagePath => text().nullable()();
  BoolColumn get isDone => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer()();
}

class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

@DriftDatabase(tables: [DbProjects, DbScenes, DbShots, AppSettings])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (migrator) async {
          await migrator.createAll();
          await customStatement('PRAGMA foreign_keys = ON');
        },
        beforeOpen: (_) => customStatement('PRAGMA foreign_keys = ON'),
      );

  Future<String?> setting(String key) async =>
      (await (select(appSettings)..where((row) => row.key.equals(key)))
              .getSingleOrNull())
          ?.value;

  Future<void> setSetting(String key, String value) =>
      into(appSettings).insertOnConflictUpdate(
        AppSettingsCompanion.insert(key: key, value: value),
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final documents = await getApplicationDocumentsDirectory();
    final file = File(p.join(documents.path, 'shotkit.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
