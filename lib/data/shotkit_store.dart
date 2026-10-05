import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import 'app_database.dart';
import 'media_service.dart';
import 'models.dart';
import 'templates.dart';

class ShotKitStore extends ChangeNotifier {
  ShotKitStore({AppDatabase? database}) : database = database ?? AppDatabase() {
    media = MediaService();
    ready = _load();
  }

  final AppDatabase database;
  late final MediaService media;
  final List<Project> projects = [];
  late final Future<void> ready;
  int _nextId = 1000;

  int nextId() => _nextId++;
  List<Project> get activeProjects =>
      projects.where((project) => !project.isArchived).toList();
  List<Project> get archivedProjects =>
      projects.where((project) => project.isArchived).toList();

  Future<void> _load() async {
    final projectRows = await (database.select(database.dbProjects)
          ..orderBy([(row) => OrderingTerm.desc(row.updatedAt)]))
        .get();
    final sceneRows = await (database.select(database.dbScenes)
          ..orderBy([(row) => OrderingTerm.asc(row.sortOrder)]))
        .get();
    final shotRows = await (database.select(database.dbShots)
          ..orderBy([(row) => OrderingTerm.asc(row.sortOrder)]))
        .get();

    projects
      ..clear()
      ..addAll(projectRows.map((projectRow) {
        final scenes = sceneRows
            .where((scene) => scene.projectId == projectRow.id)
            .map((sceneRow) {
          final shots = shotRows
              .where((shot) => shot.sceneId == sceneRow.id)
              .map((shotRow) {
            return Shot(
              id: shotRow.id,
              description: shotRow.description,
              size: shotRow.shotSize,
              angle: shotRow.angle,
              movement: shotRow.movement,
              lens: shotRow.lens ?? '',
              camera: shotRow.camera ?? 'A-Cam',
              durationSec: shotRow.durationSec,
              notes: shotRow.notes ?? '',
              imagePath: shotRow.imagePath,
              mustHave: shotRow.priority == 'must',
              isDone: shotRow.isDone,
            );
          }).toList();
          return Scene(
            id: sceneRow.id,
            title: sceneRow.title,
            location: sceneRow.location ?? 'Location TBC',
            timeOfDay: TimeOfDayTag.values.firstWhere(
              (tag) => tag.name == sceneRow.timeOfDay,
              orElse: () => TimeOfDayTag.day,
            ),
            shots: shots,
          );
        }).toList();
        return Project(
          id: projectRow.id,
          title: projectRow.title,
          type: (projectRow.templateType ?? 'Blank').toUpperCase(),
          updatedLabel: _relativeDate(projectRow.updatedAt),
          isArchived: projectRow.isArchived,
          scenes: scenes,
        );
      }));

    final ids = <int>[
      ...projects.map((project) => project.id),
      ...projects.expand((project) => project.scenes).map((scene) => scene.id),
      ...projects
          .expand((project) => project.scenes)
          .expand((scene) => scene.shots)
          .map((shot) => shot.id),
    ];
    if (ids.isNotEmpty) _nextId = ids.reduce((a, b) => a > b ? a : b) + 1;
    notifyListeners();
  }

  Future<void> toggleShot(Project project, Scene scene, Shot shot) async {
    shot.isDone = !shot.isDone;
    project.updatedLabel = 'Just now';
    notifyListeners();
    await (database.update(database.dbShots)
          ..where((row) => row.id.equals(shot.id)))
        .write(
      DbShotsCompanion(isDone: Value(shot.isDone)),
    );
    await _touch(project);
  }

  Future<void> addShot(Project project, Scene scene, Shot shot) async {
    scene.shots.add(shot);
    project.updatedLabel = 'Just now';
    notifyListeners();
    await database.into(database.dbShots).insert(
          DbShotsCompanion.insert(
            id: Value(shot.id),
            sceneId: scene.id,
            description: shot.description,
            shotSize: shot.size,
            angle: shot.angle,
            movement: shot.movement,
            lens: Value(shot.lens),
            camera: Value(shot.camera),
            durationSec: Value(shot.durationSec),
            priority: Value(shot.mustHave ? 'must' : 'nice'),
            notes: Value(shot.notes),
            imagePath: Value(shot.imagePath),
            sortOrder: scene.shots.length - 1,
          ),
        );
    await _touch(project);
  }

  Future<void> updateShot(Project project, Shot shot) async {
    await (database.update(database.dbShots)
          ..where((row) => row.id.equals(shot.id)))
        .write(
      DbShotsCompanion(
        description: Value(shot.description),
        shotSize: Value(shot.size),
        angle: Value(shot.angle),
        movement: Value(shot.movement),
        lens: Value(shot.lens),
        camera: Value(shot.camera),
        durationSec: Value(shot.durationSec),
        priority: Value(shot.mustHave ? 'must' : 'nice'),
        notes: Value(shot.notes),
        imagePath: Value(shot.imagePath),
      ),
    );
    await _touch(project);
    notifyListeners();
  }

  Future<void> deleteShot(Project project, Scene scene, Shot shot) async {
    scene.shots.remove(shot);
    notifyListeners();
    await (database.delete(database.dbShots)
          ..where((row) => row.id.equals(shot.id)))
        .go();
    await reorderShots(scene, 0, 0);
    await _touch(project);
  }

  Future<void> duplicateShot(Project project, Scene scene, Shot source) async {
    await addShot(
      project,
      scene,
      Shot(
        id: nextId(),
        description: '${source.description} copy',
        size: source.size,
        angle: source.angle,
        movement: source.movement,
        lens: source.lens,
        camera: source.camera,
        durationSec: source.durationSec,
        notes: source.notes,
        imagePath: source.imagePath,
        mustHave: source.mustHave,
      ),
    );
  }

  /// Legacy ReorderableListView semantics: [newIndex] counts the moved item
  /// as still being in place.
  Future<void> reorderShots(Scene scene, int oldIndex, int newIndex) =>
      moveShot(scene, oldIndex, newIndex > oldIndex ? newIndex - 1 : newIndex);

  /// Moves the shot at [from] so it ends up at index [to].
  Future<void> moveShot(Scene scene, int from, int to) async {
    if (scene.shots.isNotEmpty && from != to) {
      final shot = scene.shots.removeAt(from);
      scene.shots.insert(to, shot);
      notifyListeners();
    }
    await database.batch((batch) {
      for (var index = 0; index < scene.shots.length; index++) {
        batch.update(
          database.dbShots,
          DbShotsCompanion(sortOrder: Value(index)),
          where: (row) => row.id.equals(scene.shots[index].id),
        );
      }
    });
  }

  Future<Scene> addScene(
      Project project, String title, String location, TimeOfDayTag tag) async {
    final scene = Scene(
        id: nextId(),
        title: title,
        location: location,
        timeOfDay: tag,
        shots: []);
    project.scenes.add(scene);
    project.updatedLabel = 'Just now';
    notifyListeners();
    await database.into(database.dbScenes).insert(
          DbScenesCompanion.insert(
            id: Value(scene.id),
            projectId: project.id,
            title: title,
            location: Value(location),
            timeOfDay: tag.name,
            sortOrder: project.scenes.length - 1,
          ),
        );
    await _touch(project);
    return scene;
  }

  Future<void> duplicateScene(Project project, Scene source) async {
    final scene = Scene(
      id: nextId(),
      title: '${source.title} copy',
      location: source.location,
      timeOfDay: source.timeOfDay,
      shots: source.shots
          .map((shot) => Shot(
                id: nextId(),
                description: shot.description,
                size: shot.size,
                angle: shot.angle,
                movement: shot.movement,
                lens: shot.lens,
                camera: shot.camera,
                durationSec: shot.durationSec,
                notes: shot.notes,
                imagePath: shot.imagePath,
                mustHave: shot.mustHave,
              ))
          .toList(),
    );
    await _insertScene(project, scene, project.scenes.length);
    project.scenes.add(scene);
    await _touch(project);
    notifyListeners();
  }

  Future<void> reorderScenes(
    Project project,
    int oldIndex,
    int newIndex,
  ) =>
      moveScene(
          project, oldIndex, newIndex > oldIndex ? newIndex - 1 : newIndex);

  /// Moves the scene at [from] so it ends up at index [to].
  Future<void> moveScene(Project project, int from, int to) async {
    final scene = project.scenes.removeAt(from);
    project.scenes.insert(to, scene);
    notifyListeners();
    await database.batch((batch) {
      for (var index = 0; index < project.scenes.length; index++) {
        batch.update(
          database.dbScenes,
          DbScenesCompanion(sortOrder: Value(index)),
          where: (row) => row.id.equals(project.scenes[index].id),
        );
      }
    });
    await _touch(project);
  }

  Future<void> deleteScene(Project project, Scene scene) async {
    project.scenes.remove(scene);
    notifyListeners();
    await (database.delete(database.dbScenes)
          ..where((row) => row.id.equals(scene.id)))
        .go();
    await database.batch((batch) {
      for (var index = 0; index < project.scenes.length; index++) {
        batch.update(
          database.dbScenes,
          DbScenesCompanion(sortOrder: Value(index)),
          where: (row) => row.id.equals(project.scenes[index].id),
        );
      }
    });
    await _touch(project);
  }

  Future<Project> addProject(String title, String template) async {
    final project = Project(
      id: nextId(),
      title: title,
      type: template.toUpperCase(),
      updatedLabel: 'Just now',
      scenes: buildTemplate(template, nextId),
    );
    projects.insert(0, project);
    notifyListeners();
    final now = DateTime.now();
    await database.transaction(() async {
      await database.into(database.dbProjects).insert(
            DbProjectsCompanion.insert(
              id: Value(project.id),
              title: project.title,
              templateType: Value(template),
              createdAt: now,
              updatedAt: now,
            ),
          );
      for (var index = 0; index < project.scenes.length; index++) {
        await _insertScene(project, project.scenes[index], index);
      }
    });
    return project;
  }

  Future<void> archiveProject(Project project) async {
    project.isArchived = true;
    notifyListeners();
    await (database.update(database.dbProjects)
          ..where((row) => row.id.equals(project.id)))
        .write(
      const DbProjectsCompanion(isArchived: Value(true)),
    );
  }

  Future<void> unarchiveProject(Project project) async {
    project.isArchived = false;
    notifyListeners();
    await (database.update(database.dbProjects)
          ..where((row) => row.id.equals(project.id)))
        .write(
      const DbProjectsCompanion(isArchived: Value(false)),
    );
  }

  Future<void> _insertScene(Project project, Scene scene, int sortOrder) async {
    await database.into(database.dbScenes).insert(
          DbScenesCompanion.insert(
            id: Value(scene.id),
            projectId: project.id,
            title: scene.title,
            location: Value(scene.location),
            timeOfDay: scene.timeOfDay.name,
            sortOrder: sortOrder,
          ),
        );
    for (var index = 0; index < scene.shots.length; index++) {
      final shot = scene.shots[index];
      await database.into(database.dbShots).insert(
            DbShotsCompanion.insert(
              id: Value(shot.id),
              sceneId: scene.id,
              description: shot.description,
              shotSize: shot.size,
              angle: shot.angle,
              movement: shot.movement,
              lens: Value(shot.lens),
              camera: Value(shot.camera),
              durationSec: Value(shot.durationSec),
              priority: Value(shot.mustHave ? 'must' : 'nice'),
              notes: Value(shot.notes),
              imagePath: Value(shot.imagePath),
              sortOrder: index,
            ),
          );
    }
  }

  Future<void> _touch(Project project) async {
    project.updatedLabel = 'Just now';
    await (database.update(database.dbProjects)
          ..where((row) => row.id.equals(project.id)))
        .write(
      DbProjectsCompanion(updatedAt: Value(DateTime.now())),
    );
  }

  @override
  void dispose() {
    unawaited(database.close());
    super.dispose();
  }
}

String _relativeDate(DateTime date) {
  final difference = DateTime.now().difference(date);
  if (difference.inMinutes < 2) return 'Just now';
  if (difference.inHours < 1) return '${difference.inMinutes}m ago';
  if (difference.inHours < 24) return '${difference.inHours}h ago';
  if (difference.inDays < 7) return '${difference.inDays}d ago';
  return '${date.day}/${date.month}/${date.year}';
}
