import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shotkit/data/app_database.dart';
import 'package:shotkit/data/models.dart';
import 'package:shotkit/data/shotkit_store.dart';

void main() {
  test('persists shot completion and reorder into SQLite', () async {
    final database = AppDatabase(NativeDatabase.memory());
    final store = ShotKitStore(database: database);
    await store.ready;
    final project = await store.addProject('Test', 'Blank');
    final scene =
        await store.addScene(project, 'Scene', 'Stage', TimeOfDayTag.day);
    final first = Shot(
        id: store.nextId(),
        description: 'First',
        size: 'MS',
        angle: 'Eye level',
        movement: 'Static',
        lens: '35mm');
    final second = Shot(
        id: store.nextId(),
        description: 'Second',
        size: 'CU',
        angle: 'Eye level',
        movement: 'Static',
        lens: '85mm');
    await store.addShot(project, scene, first);
    await store.addShot(project, scene, second);

    await store.toggleShot(project, scene, first);
    await store.reorderShots(scene, 0, 2);

    final rows = await (database.select(database.dbShots)
          ..orderBy([(row) => OrderingTerm.asc(row.sortOrder)]))
        .get();
    expect(rows.map((row) => row.description), ['Second', 'First']);
    expect(rows.last.isDone, isTrue);
    store.dispose();
  });

  test('allows unlimited projects and scenes', () async {
    final store = ShotKitStore(database: AppDatabase(NativeDatabase.memory()));
    await store.ready;
    final project = await store.addProject('First project', 'Blank');
    expect(await store.addProject('Second project', 'Blank'), isNotNull);
    for (var index = 0; index < 4; index++) {
      expect(
          await store.addScene(project, 'Scene $index', 'Set', TimeOfDayTag.day),
          isNotNull);
    }
    expect(project.scenes.length, 4);
    store.dispose();
  });
}
