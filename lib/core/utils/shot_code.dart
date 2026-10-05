import '../../data/models.dart';

String shotSuffix(int index) {
  var value = index + 1;
  var letters = '';
  while (value > 0) {
    value--;
    letters = String.fromCharCode(65 + value % 26) + letters;
    value ~/= 26;
  }
  return letters;
}

String shotCode(int sceneIndex, int shotIndex) =>
    '${sceneIndex + 1}${shotSuffix(shotIndex)}';

String sceneCode(int sceneIndex) =>
    'SC ${(sceneIndex + 1).toString().padLeft(2, '0')}';

/// Compact spec line such as "CU · HANDHELD · 50MM". Eye level and static are
/// the defaults, so they are left out to keep rows short.
String shotSpec(Shot shot, {bool includeCamera = false}) {
  final parts = <String>[
    shot.size,
    if (shot.angle != 'Eye level') shot.angle,
    if (shot.movement != 'Static') shot.movement,
    if (shot.lens.isNotEmpty) shot.lens,
    if (includeCamera && shot.camera != 'A-Cam') shot.camera,
  ];
  return parts.join(' · ').toUpperCase();
}
