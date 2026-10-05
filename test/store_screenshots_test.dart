// Renders the Play Store screenshots with the real fonts and seeded demo data.
//
//   SHOTKIT_SCREENSHOTS=1 flutter test test/store_screenshots_test.dart
//
// Writes 1080 × 1920 PNGs to assets/play-store/screenshots/. Skipped in normal
// test runs.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shotkit/core/theme/app_theme.dart';
import 'package:shotkit/core/widgets/shotkit_widgets.dart';
import 'package:shotkit/data/app_database.dart';
import 'package:shotkit/data/models.dart';
import 'package:shotkit/data/shotkit_store.dart';
import 'package:shotkit/features/export/export_screen.dart';
import 'package:shotkit/features/onset/onset_screen.dart';
import 'package:shotkit/features/projects/project_screen.dart';
import 'package:shotkit/features/projects/projects_screen.dart';
import 'package:shotkit/features/scenes/scene_screen.dart';

final _enabled = Platform.environment['SHOTKIT_SCREENSHOTS'] == '1';
const _outDir = 'assets/play-store/screenshots';
const _canvas = Size(1080, 1920);
const _phone = Size(390, 844);
const _phoneScale = 2.1;
final _frameKey = GlobalKey();

void main() {
  setUpAll(() async {
    if (_enabled) await _loadFonts();
  });

  testWidgets('01 home', (tester) async {
    final demo = await _seed();
    await _shoot(
      tester,
      name: '01-home',
      eyebrow: 'Shot list planner',
      headline: 'Plan every shoot',
      body:
          'Weddings, interviews, music videos and short films. Works offline.',
      screen: ProjectsScreen(store: demo.store),
    );
    demo.store.dispose();
  }, skip: !_enabled);

  testWidgets('02 shot list', (tester) async {
    final demo = await _seed();
    await _shoot(
      tester,
      name: '02-shot-list',
      eyebrow: 'Shot list',
      headline: 'Never miss a must-have',
      body: 'Framing, lens and movement for every shot, at a glance.',
      screen: SceneScreen(
        store: demo.store,
        project: demo.wedding,
        scene: demo.wedding.scenes.first,
      ),
    );
    demo.store.dispose();
  }, skip: !_enabled);

  testWidgets('03 on set', (tester) async {
    final demo = await _seed();
    await _shoot(
      tester,
      name: '03-on-set',
      eyebrow: 'On-set mode',
      headline: 'Built for the set',
      body: 'The next shot, big and clear. Tap Done and keep rolling.',
      screen: OnSetScreen(
        store: demo.store,
        project: demo.wedding,
        scene: demo.wedding.scenes.first,
      ),
    );
    demo.store.dispose();
  }, skip: !_enabled);

  testWidgets('04 daylight', (tester) async {
    final demo = await _seed(daylight: true);
    await _shoot(
      tester,
      name: '04-daylight',
      eyebrow: 'Daylight mode',
      headline: 'Readable in bright sun',
      body: 'A high-contrast theme for shooting outdoors.',
      screen: OnSetScreen(
        store: demo.store,
        project: demo.wedding,
        scene: demo.wedding.scenes.first,
      ),
    );
    demo.store.dispose();
  }, skip: !_enabled);

  testWidgets('05 scenes', (tester) async {
    final demo = await _seed();
    await _shoot(
      tester,
      name: '05-scenes',
      eyebrow: 'Scenes',
      headline: 'Organized by scene',
      body: 'Locations, time of day and progress in one view.',
      screen: ProjectScreen(store: demo.store, project: demo.wedding),
    );
    demo.store.dispose();
  }, skip: !_enabled);

  testWidgets('06 pdf export', (tester) async {
    final demo = await _seed();
    await _shoot(
      tester,
      name: '06-pdf-export',
      eyebrow: 'PDF export',
      headline: 'Share with your crew',
      body: 'Detailed or compact shot list PDFs, made on your phone.',
      screen: ExportScreen(store: demo.store, project: demo.wedding),
    );
    demo.store.dispose();
  }, skip: !_enabled);
}

/// A believable mid-shoot state: one wedding in progress, a music video two
/// thirds done, a wrapped brand film and one archived project.
Future<({ShotKitStore store, Project wedding})> _seed({
  bool daylight = false,
}) async {
  final store = ShotKitStore(database: AppDatabase(NativeDatabase.memory()));
  await store.ready;
  await store.database.setSetting('keepAwake', 'false');
  await store.database.setSetting('onsetDaylight', '$daylight');

  final archived = await store.addProject('Rafi & Mitu Engagement', 'Wedding');
  await store.archiveProject(archived);

  final brand = await store.addProject('Kopi House Brand Story', 'Interview');
  for (final scene in brand.scenes) {
    for (final shot in [...scene.shots]) {
      await store.toggleShot(brand, scene, shot);
    }
  }

  final music = await store.addProject('Monsoon — Music Video', 'Music video');
  final musicShots = [
    for (final scene in music.scenes)
      for (final shot in scene.shots) (scene, shot),
  ];
  for (final (scene, shot) in musicShots.take(musicShots.length * 2 ~/ 3)) {
    await store.toggleShot(music, scene, shot);
  }

  final wedding = await store.addProject('Nabila & Arif Wedding', 'Wedding');
  const locations = [
    "Bride's home",
    'Garden venue',
    'Lakeside',
    'Banquet hall'
  ];
  for (var i = 0; i < wedding.scenes.length && i < locations.length; i++) {
    wedding.scenes[i].location = locations[i];
  }
  final prep = wedding.scenes.first;
  await store.toggleShot(wedding, prep, prep.shots[0]);
  await store.toggleShot(wedding, prep, prep.shots[1]);
  prep.shots[2].notes =
      'Shoot through the mirror; keep the rig out of the reflection.';
  prep.shots[3].camera = 'B-Cam';
  return (store: store, wedding: wedding);
}

Future<void> _shoot(
  WidgetTester tester, {
  required String name,
  required String eyebrow,
  required String headline,
  required String body,
  required Widget screen,
}) async {
  tester.view
    ..physicalSize = _canvas
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildShotKitTheme(),
      home: RepaintBoundary(
        key: _frameKey,
        child: _StoreFrame(
          eyebrow: eyebrow,
          headline: headline,
          body: body,
          screen: screen,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  final boundary =
      tester.renderObject<RenderRepaintBoundary>(find.byKey(_frameKey));
  await tester.runAsync(() async {
    final image = await boundary.toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    final file = File(p.join(_outDir, '$name.png'));
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes!.buffer.asUint8List());
  });
}

class _StoreFrame extends StatelessWidget {
  const _StoreFrame({
    required this.eyebrow,
    required this.headline,
    required this.body,
    required this.screen,
  });
  final String eyebrow;
  final String headline;
  final String body;
  final Widget screen;

  @override
  Widget build(BuildContext context) {
    final phoneMedia = MediaQuery.of(context).copyWith(
      size: _phone,
      devicePixelRatio: 3,
      padding: const EdgeInsets.only(top: 20),
      viewPadding: const EdgeInsets.only(top: 20),
      viewInsets: EdgeInsets.zero,
      textScaler: TextScaler.noScaling,
    );
    return Material(
      color: ShotKitColors.ink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const HazardStripe(height: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(84, 90, 84, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eyebrow.toUpperCase(),
                  style: ShotKitText.mono(
                    size: 30,
                    weight: FontWeight.w700,
                    color: ShotKitColors.tape,
                    spacing: 5,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  headline.toUpperCase(),
                  style: ShotKitText.display(size: 82).copyWith(height: .98),
                  maxLines: 1,
                  softWrap: false,
                ),
                const SizedBox(height: 20),
                // Two lines tall for every caption so the phones line up.
                SizedBox(
                  height: 100,
                  child: Text(
                    body,
                    maxLines: 2,
                    style: const TextStyle(
                      fontFamily: ShotKitFonts.sans,
                      fontSize: 38,
                      height: 1.3,
                      color: ShotKitColors.subtle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 60),
          Expanded(
            child: OverflowBox(
              alignment: Alignment.topCenter,
              minWidth: 0,
              minHeight: 0,
              maxHeight: double.infinity,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ShotKitColors.strong,
                  borderRadius: BorderRadius.circular(72),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(64),
                  child: SizedBox(
                    width: _phone.width * _phoneScale,
                    height: _phone.height * _phoneScale,
                    child: FittedBox(
                      child: SizedBox.fromSize(
                        size: _phone,
                        child: MediaQuery(
                          data: phoneMedia,
                          child: Navigator(
                            onGenerateRoute: (_) =>
                                MaterialPageRoute(builder: (_) => screen),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _loadFonts() async {
  const families = {
    ShotKitFonts.sans: [
      'Archivo-Regular',
      'Archivo-Medium',
      'Archivo-SemiBold',
      'Archivo-Bold',
      'Archivo-ExtraBold',
    ],
    ShotKitFonts.semiCondensed: ['ArchivoSemiCondensed-ExtraBold'],
    ShotKitFonts.condensed: [
      'ArchivoCondensed-ExtraBold',
      'ArchivoCondensed-Black',
    ],
    ShotKitFonts.mono: [
      'JetBrainsMono-Regular',
      'JetBrainsMono-Medium',
      'JetBrainsMono-Bold',
    ],
  };
  for (final MapEntry(key: family, value: files) in families.entries) {
    final loader = FontLoader(family);
    for (final file in files) {
      loader.addFont(_fontBytes('assets/fonts/$file.ttf'));
    }
    await loader.load();
  }
  await (FontLoader('MaterialIcons')..addFont(_fontBytes(_materialIcons())))
      .load();
}

Future<ByteData> _fontBytes(String path) async =>
    ByteData.sublistView(await File(path).readAsBytes());

/// The Material icon font ships with the Flutter SDK.
String _materialIcons() {
  const relative =
      'bin/cache/artifacts/material_fonts/materialicons-regular.otf';
  final root = Platform.environment['FLUTTER_ROOT'];
  if (root != null && File(p.join(root, relative)).existsSync()) {
    return p.join(root, relative);
  }
  var dir = File(Platform.resolvedExecutable).parent;
  while (dir.parent.path != dir.path) {
    final candidate = File(p.join(dir.path, relative));
    if (candidate.existsSync()) return candidate.path;
    dir = dir.parent;
  }
  throw StateError('MaterialIcons font not found; set FLUTTER_ROOT.');
}
