import 'package:flutter_test/flutter_test.dart';
import 'package:shotkit/core/constants/shot_options.dart';
import 'package:shotkit/core/utils/shot_code.dart';
import 'package:shotkit/core/widgets/framing_glyph.dart';
import 'package:shotkit/data/models.dart';

Shot _shot({
  String size = 'CU',
  String angle = 'Eye level',
  String movement = 'Static',
  String lens = '50mm',
  String camera = 'A-Cam',
}) =>
    Shot(
      id: 1,
      description: 'Test',
      size: size,
      angle: angle,
      movement: movement,
      lens: lens,
      camera: camera,
    );

void main() {
  test('shotSpec leaves out eye level and static', () {
    expect(shotSpec(_shot()), 'CU · 50MM');
    expect(
      shotSpec(_shot(angle: 'High', movement: 'Handheld', lens: '85mm')),
      'CU · HIGH · HANDHELD · 85MM',
    );
  });

  test('shotSpec adds a non-default camera only when asked', () {
    final shot = _shot(camera: 'B-Cam');
    expect(shotSpec(shot), 'CU · 50MM');
    expect(shotSpec(shot, includeCamera: true), 'CU · 50MM · B-CAM');
  });

  test('scene and shot codes', () {
    expect(sceneCode(0), 'SC 01');
    expect(sceneCode(11), 'SC 12');
    expect(shotCode(0, 2), '1C');
    expect(shotCode(1, 26), '2AA');
  });

  test('every shot size maps to a framing glyph', () {
    for (final size in ShotOptions.sizes) {
      expect(framingKindFor(size), isA<FramingKind>(), reason: size);
    }
    expect(framingKindFor('ECU'), FramingKind.ecu);
    expect(framingKindFor('CU'), FramingKind.cu);
    expect(framingKindFor('MS'), FramingKind.ms);
    expect(framingKindFor('LS'), FramingKind.ls);
    expect(framingKindFor('Establishing'), FramingKind.wide);
    expect(framingKindFor('Insert'), FramingKind.insert);
    expect(framingKindFor('Two-shot'), FramingKind.two);
  });
}
