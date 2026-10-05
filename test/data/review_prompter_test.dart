import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shotkit/data/app_database.dart';
import 'package:shotkit/data/review_prompter.dart';

void main() {
  late AppDatabase database;
  late ReviewPrompter prompter;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    prompter = ReviewPrompter(database);
  });

  tearDown(() => database.close());

  test('waits for the third app open', () async {
    await prompter.recordOpen();
    await prompter.recordOpen();
    expect(await prompter.shouldAsk(), isFalse);

    await prompter.recordOpen();
    expect(await prompter.shouldAsk(), isTrue);
  });

  test('asks again only after the cooldown', () async {
    for (var i = 0; i < ReviewPrompter.minOpens; i++) {
      await prompter.recordOpen();
    }
    final askedAt = DateTime(2026, 10, 1);
    await database.setSetting('reviewAskedAt', askedAt.toIso8601String());

    expect(
      await prompter.shouldAsk(now: askedAt.add(const Duration(days: 30))),
      isFalse,
    );
    expect(
      await prompter.shouldAsk(now: askedAt.add(ReviewPrompter.cooldown)),
      isTrue,
    );
  });
}
