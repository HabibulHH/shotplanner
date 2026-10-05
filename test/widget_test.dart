import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shotkit/core/constants/shot_options.dart';
import 'package:shotkit/core/theme/app_theme.dart';
import 'package:shotkit/data/app_database.dart';
import 'package:shotkit/data/shotkit_store.dart';
import 'package:shotkit/features/onset/onset_screen.dart';
import 'package:shotkit/features/scenes/scene_screen.dart';
import 'package:shotkit/main.dart';

/// Phone-sized test surface (360 × 780 logical px).
void usePhoneSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

Future<ShotKitStore> seededStore() async {
  final store = ShotKitStore(database: AppDatabase(NativeDatabase.memory()));
  await store.ready;
  // Wakelock has no platform implementation in widget tests.
  await store.database.setSetting('keepAwake', 'false');
  return store;
}

Widget themed(Widget child) =>
    MaterialApp(theme: buildShotKitTheme(), home: child);

void main() {
  testWidgets('home shows the next project and opens it', (tester) async {
    usePhoneSize(tester);
    final store = await seededStore();
    await store.addProject('Rahim & Ayesha', 'Wedding');

    await tester.pumpWidget(ShotKitApp(store: store));
    await tester.pumpAndSettle();

    expect(find.text('SHOTKIT'), findsOneWidget);
    expect(find.text('UP NEXT'), findsOneWidget);
    // Once in the "Up next" card, once in the project list.
    expect(find.text('Rahim & Ayesha'), findsNWidgets(2));

    await tester.tap(find.text('Rahim & Ayesha').last);
    await tester.pumpAndSettle();

    expect(find.text('RAHIM & AYESHA'), findsOneWidget);
    expect(find.text('Start on-set'), findsOneWidget);
    expect(find.text('Prep & details'), findsOneWidget);
    store.dispose();
  });

  testWidgets('quick add creates a shot with neutral defaults', (tester) async {
    usePhoneSize(tester);
    final store = await seededStore();
    final project = await store.addProject('Shoot', 'Wedding');
    final scene = project.scenes.first;
    final before = scene.shots.length;

    await tester.pumpWidget(themed(
      SceneScreen(store: store, project: project, scene: scene),
    ));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Groom tying his tie');
    await tester.tap(find.widgetWithText(FilledButton, 'Add'));
    await tester.pump();

    expect(scene.shots.length, before + 1);
    final added = scene.shots.last;
    expect(added.description, 'Groom tying his tie');
    expect(added.size, ShotOptions.quickSize);
    expect(added.lens, ShotOptions.quickLens);
    expect(added.mustHave, isTrue);

    // Let the confirmation snackbar time out.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    store.dispose();
  });

  testWidgets('on-set Done advances and Skip moves a shot to the back',
      (tester) async {
    usePhoneSize(tester);
    final store = await seededStore();
    final project = await store.addProject('Shoot', 'Wedding');
    final scene = project.scenes.first;
    final first = scene.shots[0];
    final second = scene.shots[1];
    final third = scene.shots[2];

    await tester.pumpWidget(themed(
      OnSetScreen(store: store, project: project, scene: scene),
    ));
    await tester.pumpAndSettle();

    expect(find.text('NEXT UP · 1A'), findsOneWidget);
    expect(find.text(first.description), findsOneWidget);

    await tester.tap(find.text('Done · next shot'));
    await tester.pumpAndSettle();
    expect(first.isDone, isTrue);
    expect(find.text('NEXT UP · 1B'), findsOneWidget);

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    expect(second.isDone, isFalse);
    expect(find.text('NEXT UP · 1C'), findsOneWidget);
    expect(find.text(third.description), findsOneWidget);

    // Finished shots stay folded away until asked for.
    expect(find.text('DONE (1)'), findsOneWidget);

    // The skipped shot waits at the back of the queue.
    final skipped = find.textContaining('SKIPPED');
    await tester.scrollUntilVisible(skipped, 200);
    expect(skipped, findsOneWidget);
    store.dispose();
  });
}
