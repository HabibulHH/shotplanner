// Lays out every screen at several phone sizes and Android font scales, with
// deliberately long names, and fails on any overflow or layout error. Lists
// are scrolled to the end so every row gets laid out.
import 'dart:math' as math;

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shotkit/core/theme/app_theme.dart';
import 'package:shotkit/data/app_database.dart';
import 'package:shotkit/data/models.dart';
import 'package:shotkit/data/shotkit_store.dart';
import 'package:shotkit/features/dashboard/dashboard_screen.dart';
import 'package:shotkit/features/export/export_screen.dart';
import 'package:shotkit/features/onset/onset_screen.dart';
import 'package:shotkit/features/projects/project_screen.dart';
import 'package:shotkit/features/projects/projects_screen.dart';
import 'package:shotkit/features/scenes/scene_screen.dart';
import 'package:shotkit/features/settings/settings_screen.dart';
import 'package:shotkit/features/shots/shot_editor_sheet.dart';

import 'support/real_fonts.dart';

const _sizes = {
  '320x568': Size(320, 568),
  '360x640': Size(360, 640),
  '360x780': Size(360, 780),
  '412x915': Size(412, 915),
};
const _textScales = [1.0, 1.3, 2.0];

typedef _Demo = ({
  ShotKitStore store,
  Project wedding,
  Scene longScene,
  Scene bigScene,
  Scene emptyScene,
});

class _Case {
  const _Case(
    this.name,
    this.build, {
    this.act,
    this.daylight = false,
    this.still = false,
  });
  final String name;
  final Widget Function(_Demo demo) build;
  final Future<void> Function(WidgetTester tester, _Demo demo)? act;
  final bool daylight;

  /// Runs with reduced motion, for screens with ambient looping animation.
  final bool still;
}

final _cases = <_Case>[
  _Case('dashboard', (d) => DashboardScreen(store: d.store), still: true),
  _Case('projects', (d) => ProjectsScreen(store: d.store)),
  _Case(
    'home · archived tab',
    (d) => ProjectsScreen(store: d.store),
    act: (tester, _) => _tapText(tester, 'Archived', partial: true),
  ),
  _Case(
    'home · new project sheet',
    (d) => ProjectsScreen(store: d.store),
    act: (tester, _) => _tapTooltip(tester, 'New project'),
  ),
  _Case('project', (d) => ProjectScreen(store: d.store, project: d.wedding)),
  _Case(
    'project · reorder',
    (d) => ProjectScreen(store: d.store, project: d.wedding),
    act: (tester, _) => _tapText(tester, 'Reorder'),
  ),
  _Case(
    'project · add scene sheet',
    (d) => ProjectScreen(store: d.store, project: d.wedding),
    act: (tester, _) => _tapText(tester, 'Add scene'),
  ),
  _Case(
    'project · more menu',
    (d) => ProjectScreen(store: d.store, project: d.wedding),
    act: (tester, _) => _tapTooltip(tester, 'More options'),
  ),
  _Case(
    'scene · long names',
    (d) => SceneScreen(store: d.store, project: d.wedding, scene: d.longScene),
  ),
  _Case(
    'scene · reorder',
    (d) => SceneScreen(store: d.store, project: d.wedding, scene: d.longScene),
    act: (tester, _) => _tapText(tester, 'Reorder'),
  ),
  _Case(
    'scene · swipe open',
    (d) => SceneScreen(store: d.store, project: d.wedding, scene: d.longScene),
    act: (tester, d) async {
      final row = find.text(d.longScene.shots[1].description);
      await _reveal(tester, row);
      await tester.drag(row, const Offset(-300, 0));
      await tester.pumpAndSettle();
    },
  ),
  _Case(
    'scene · 30 shots',
    (d) => SceneScreen(store: d.store, project: d.wedding, scene: d.bigScene),
  ),
  _Case(
    'scene · empty',
    (d) => SceneScreen(store: d.store, project: d.wedding, scene: d.emptyScene),
  ),
  _Case(
    'on set · dark',
    (d) => OnSetScreen(store: d.store, project: d.wedding, scene: d.longScene),
  ),
  _Case(
    'on set · daylight + done list',
    (d) => OnSetScreen(store: d.store, project: d.wedding, scene: d.longScene),
    daylight: true,
    act: (tester, _) => _tapText(tester, 'DONE (', partial: true),
  ),
  _Case(
    'on set · skipped shot',
    (d) => OnSetScreen(store: d.store, project: d.wedding, scene: d.longScene),
    act: (tester, _) => _tapText(tester, 'Skip'),
  ),
  _Case(
    'on set · wrapped',
    (d) => OnSetScreen(
      store: d.store,
      project: d.wedding,
      scene: d.wedding.scenes[1],
    ),
    act: (tester, d) async {
      final scene = d.wedding.scenes[1];
      for (final shot in scene.shots.where((s) => !s.isDone).toList()) {
        await d.store.toggleShot(d.wedding, scene, shot);
      }
      await tester.pumpAndSettle();
    },
  ),
  _Case('settings', (d) => SettingsScreen(store: d.store)),
  _Case('export', (d) => ExportScreen(store: d.store, project: d.wedding)),
  for (var step = 0; step < 6; step++)
    _Case(
      'shot editor · step ${step + 1}',
      (d) => _EditorHost(demo: d),
      // The editor's framing previews loop forever, so pump fixed frames
      // instead of waiting for it to settle.
      act: (tester, _) async {
        await tester.tap(find.text('OPEN EDITOR'));
        await _pumpFrames(tester);
        for (var i = 0; i < step; i++) {
          await tester.tap(find.text('NEXT'));
          await _pumpFrames(tester);
        }
      },
    ),
];

void main() {
  setUpAll(loadRealFonts);

  for (final MapEntry(key: sizeName, value: size) in _sizes.entries) {
    for (final scale in _textScales) {
      group('$sizeName · text ${scale}x', () {
        for (final c in _cases) {
          testWidgets(c.name, (tester) async {
            await _check(tester, c, size, scale, '$sizeName text ${scale}x');
          });
        }
      });
    }
  }
}

Future<void> _check(
  WidgetTester tester,
  _Case c,
  Size size,
  double scale,
  String label,
) async {
  tester.view
    ..physicalSize = size * 3
    ..devicePixelRatio = 3;
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

  final problems = <String>{};
  final previous = FlutterError.onError;
  FlutterError.onError =
      (details) => problems.add('[$label] ${_describe(details)}');
  try {
    if (c.still) {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
          tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    }
    final demo = await _seed(daylight: c.daylight);
    await tester.pumpWidget(
      MaterialApp(theme: buildShotKitTheme(), home: c.build(demo)),
    );
    await tester.pumpAndSettle();
    await c.act?.call(tester, demo);
    await _scrollEverything(tester);
    demo.store.dispose();
  } finally {
    FlutterError.onError = previous;
  }
  expect(problems, isEmpty, reason: problems.join('\n'));
}

String _describe(FlutterErrorDetails details) {
  final message = details.exceptionAsString().split('\n').first;
  final where =
      RegExp(r'(lib/[\w/]+\.dart):(\d+)').firstMatch(details.toString());
  return where == null ? message : '$message  (${where[1]}:${where[2]})';
}

Future<void> _scrollEverything(WidgetTester tester) async {
  for (var round = 0; round < 2; round++) {
    final states =
        tester.stateList<ScrollableState>(find.byType(Scrollable)).toList();
    for (final state in states) {
      for (var i = 0; i < 80 && state.mounted; i++) {
        final position = state.position;
        if (position.pixels >= position.maxScrollExtent) break;
        position.jumpTo(
          math.min(position.pixels + 300, position.maxScrollExtent),
        );
        await tester.pump();
      }
    }
  }
}

Future<void> _pumpFrames(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Large text pushes targets below the fold, where lists haven't built them.
Future<void> _reveal(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      finder,
      200,
      scrollable: find.byType(Scrollable).first,
    );
  }
  await tester.ensureVisible(finder.first);
  await tester.pumpAndSettle();
}

Future<void> _tapText(
  WidgetTester tester,
  String text, {
  bool partial = false,
}) async {
  final finder = partial ? find.textContaining(text) : find.text(text);
  await _reveal(tester, finder);
  await tester.tap(finder.first);
  await tester.pumpAndSettle();
}

Future<void> _tapTooltip(WidgetTester tester, String tooltip) async {
  await tester.tap(find.byTooltip(tooltip).first);
  await tester.pumpAndSettle();
}

class _EditorHost extends StatelessWidget {
  const _EditorHost({required this.demo});
  final _Demo demo;

  @override
  Widget build(BuildContext context) {
    final shot = demo.longScene.shots[1];
    return Scaffold(
      body: Center(
        child: FilledButton(
          onPressed: () => showShotEditor(
            context,
            demo.longScene,
            demo.store.media,
            existing: shot,
          ),
          child: const Text('OPEN EDITOR'),
        ),
      ),
    );
  }
}

/// Worst-case content: long titles everywhere, custom kit names, a 30-shot
/// scene, an empty scene, archived projects.
Future<_Demo> _seed({bool daylight = false}) async {
  final store = ShotKitStore(database: AppDatabase(NativeDatabase.memory()));
  await store.ready;
  await store.database.setSetting('keepAwake', 'false');
  await store.database.setSetting('onsetDaylight', '$daylight');

  for (final title in [
    'Rafi & Mitu Engagement at the Old Dhaka Rooftop',
    'Archived Corporate Interview Series, Part Two',
  ]) {
    await store.archiveProject(await store.addProject(title, 'Interview'));
  }
  await store.addProject(
    'Kopi House Brand Story — Founders, Baristas and Regulars',
    'Interview',
  );
  await store.addProject(
      'Monsoon — Music Video, Director’s Cut', 'Music video');

  final wedding = await store.addProject(
    'Nabila & Arif Wedding — Extended Family Edition, Gazipur Resort',
    'Wedding',
  );
  final longScene = wedding.scenes.first
    ..title = 'Prep & details at the bride’s family home before the ceremony'
    ..location = 'Gulshan Avenue, Road 41, Banani Lake View Residence';
  final long = longScene.shots[1]
    ..description =
        'Bride’s mother fastening the heirloom necklace while her sisters '
            'watch in the dressing-room mirror'
    ..angle = 'Three-quarter rear'
    ..movement = 'Arc / orbit'
    ..lens = '24–70mm f/2.8 GM II'
    ..camera = 'Sony FX3 on gimbal (B unit)'
    ..notes =
        'Wait for the clasp, then push in slowly. Keep the window light on '
            'her face and the sisters soft in the background.'
    ..mustHave = false;
  await store.updateShot(wedding, long);
  await store.toggleShot(wedding, longScene, longScene.shots[0]);

  final bigScene = await store.addScene(
    wedding,
    'Reception highlights with every speech, toast and dance',
    'Grand ballroom, level 3',
    TimeOfDayTag.night,
  );
  for (var i = 0; i < 30; i++) {
    await store.addShot(
      wedding,
      bigScene,
      Shot(
        id: store.nextId(),
        description: 'Reception moment ${i + 1}',
        size: i.isEven ? 'MS' : 'Establishing',
        angle: 'Eye level',
        movement: 'Gimbal',
        lens: '35mm',
        camera: i % 3 == 0 ? 'Drone' : 'A-Cam',
      ),
    );
  }
  final emptyScene = await store.addScene(
    wedding,
    'Pickup shots for anything missed on the day',
    'Location TBC',
    TimeOfDayTag.golden,
  );

  return (
    store: store,
    wedding: wedding,
    longScene: longScene,
    bigScene: bigScene,
    emptyScene: emptyScene,
  );
}
