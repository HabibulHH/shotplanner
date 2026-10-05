import 'package:in_app_review/in_app_review.dart';

import 'app_database.dart';

/// Asks for a Play review only after a real win (a wrapped scene, a shared
/// PDF), never before the third app open, and at most once per [cooldown].
/// Play applies its own quota on top, so a request may show nothing.
class ReviewPrompter {
  ReviewPrompter(this._database, {InAppReview? review})
      : _review = review ?? InAppReview.instance;

  final AppDatabase _database;
  final InAppReview _review;

  static const minOpens = 3;
  static const cooldown = Duration(days: 90);

  Future<int> get _opens async =>
      int.tryParse(await _database.setting('appOpens') ?? '') ?? 0;

  Future<void> recordOpen() async =>
      _database.setSetting('appOpens', '${await _opens + 1}');

  Future<bool> shouldAsk({DateTime? now}) async {
    if (await _opens < minOpens) return false;
    final last =
        DateTime.tryParse(await _database.setting('reviewAskedAt') ?? '');
    return last == null || (now ?? DateTime.now()).difference(last) >= cooldown;
  }

  Future<void> maybeAsk() async {
    if (!await shouldAsk()) return;
    try {
      if (!await _review.isAvailable()) return;
      await _database.setSetting(
        'reviewAskedAt',
        DateTime.now().toIso8601String(),
      );
      await _review.requestReview();
    } catch (_) {
      // No Play Store on this device (emulators, sideloads, tests).
    }
  }
}
