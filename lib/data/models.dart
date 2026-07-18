enum TimeOfDayTag { day, night, golden, indoor }

extension TimeOfDayTagLabel on TimeOfDayTag {
  String get label => switch (this) {
        TimeOfDayTag.day => 'DAY',
        TimeOfDayTag.night => 'NIGHT',
        TimeOfDayTag.golden => 'GOLDEN',
        TimeOfDayTag.indoor => 'INDOOR',
      };
}

class Shot {
  Shot({
    required this.id,
    required this.description,
    required this.size,
    required this.angle,
    required this.movement,
    required this.lens,
    this.camera = 'A-Cam',
    this.notes = '',
    this.imagePath,
    this.durationSec,
    this.mustHave = true,
    this.isDone = false,
  });

  final int id;
  String description;
  String size;
  String angle;
  String movement;
  String lens;
  String camera;
  String notes;
  String? imagePath;
  int? durationSec;
  bool mustHave;
  bool isDone;
}

class Scene {
  Scene({
    required this.id,
    required this.title,
    required this.location,
    required this.timeOfDay,
    required this.shots,
  });

  final int id;
  String title;
  String location;
  TimeOfDayTag timeOfDay;
  final List<Shot> shots;

  int get completed => shots.where((shot) => shot.isDone).length;
  double get progress => shots.isEmpty ? 0 : completed / shots.length;
}

class Project {
  Project({
    required this.id,
    required this.title,
    required this.type,
    required this.updatedLabel,
    required this.scenes,
    this.isArchived = false,
  });

  final int id;
  String title;
  final String type;
  String updatedLabel;
  final List<Scene> scenes;
  bool isArchived;

  int get shotCount => scenes.fold(0, (sum, scene) => sum + scene.shots.length);
  int get completed => scenes.fold(0, (sum, scene) => sum + scene.completed);
  double get progress => shotCount == 0 ? 0 : completed / shotCount;
}
