import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shotkit/data/app_database.dart';
import 'package:shotkit/data/models.dart';
import 'package:shotkit/data/shotkit_store.dart';

void main() {
  test('persists shot completion and reorder into SQLite', () async {
    final database = AppDatabase(NativeDatabase.memory());
    final store = ShotKitStore(database: database, initializePurchases: false);
    await store.ready;
    final project = (await store.addProject('Test', 'Blank'))!;
    final scene =
        (await store.addScene(project, 'Scene', 'Stage', TimeOfDayTag.day))!;
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

  test('enforces the free project and scene limits at creation time', () async {
    final store = ShotKitStore(
        database: AppDatabase(NativeDatabase.memory()),
        initializePurchases: false);
    await store.ready;
    final project = (await store.addProject('Free project', 'Blank'))!;
    expect(await store.addProject('Second project', 'Blank'), isNull);
    expect(await store.addScene(project, 'One', 'Set', TimeOfDayTag.day),
        isNotNull);
    expect(await store.addScene(project, 'Two', 'Set', TimeOfDayTag.day),
        isNotNull);
    expect(await store.addScene(project, 'Three', 'Set', TimeOfDayTag.day),
        isNotNull);
    expect(
        await store.addScene(project, 'Four', 'Set', TimeOfDayTag.day), isNull);
    store.dispose();
  });
}
