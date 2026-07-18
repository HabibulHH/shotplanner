import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shotkit/data/app_database.dart';
import 'package:shotkit/data/shotkit_store.dart';
import 'package:shotkit/main.dart';

void main() {
  testWidgets('creates a project and opens its seeded scene slate',
      (tester) async {
    final store = ShotKitStore(
      database: AppDatabase(NativeDatabase.memory()),
      initializePurchases: false,
    );
    await store.ready;
    final project = await store.addProject('Rahim & Ayesha', 'Wedding');
    expect(project, isNotNull);

    await tester.pumpWidget(ShotKitApp(store: store));
    await tester.pumpAndSettle();

    expect(find.text('SHOTKIT'), findsOneWidget);
    expect(find.text('Rahim & Ayesha'), findsOneWidget);
    await tester.tap(find.text('Rahim & Ayesha'));
    await tester.pumpAndSettle();

    expect(find.text('PRODUCTION RUN'), findsOneWidget);
    expect(find.text('Prep & details'), findsOneWidget);
    store.dispose();
  });
}
