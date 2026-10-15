import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'app_database.dart';

enum AccessLevel {
  /// A new install inside its free trial.
  trial,

  /// The trial ran out: projects stay viewable, shootable and exportable,
  /// but planning (creating and editing) needs the lifetime unlock.
  readOnly,

  /// Bought the lifetime unlock.
  lifetime,

  /// Installed before ShotKit had a price; free for life.
  earlySupporter,
}

/// Tracks the 10-day trial and the one-time lifetime unlock sold through
/// Google Play. Everything is decided on the device, so it works offline.
class UnlockService extends ChangeNotifier {
  UnlockService(
    this._database, {
    InAppPurchase? billing,
    DateTime Function()? clock,
  })  : _billing = billing,
        _clock = clock ?? DateTime.now;

  static const productId = 'shotkit_lifetime';
  static const trialLength = Duration(days: 10);
  static const _ownedKey = 'lifetimeOwned';
  static const _earlySupporterKey = 'earlySupporter';

  final AppDatabase _database;

  /// Null where there is no Play Store to talk to (tests).
  final InAppPurchase? _billing;
  final DateTime Function() _clock;
  StreamSubscription<List<PurchaseDetails>>? _purchases;
  Completer<void>? _restoring;

  bool _owned = false;
  bool _earlySupporter = false;
  DateTime? _installedAt;

  /// The lifetime product with its local price, once Play has answered.
  ProductDetails? product;

  /// Waiting on Play for the price.
  bool connecting = false;

  /// A purchase or restore is in flight.
  bool busy = false;

  /// Play is waiting on a slow payment method (cash, bank transfer).
  bool pending = false;

  /// What went wrong with the last purchase or restore, for the unlock sheet.
  String? error;

  AccessLevel get level {
    if (_owned) return AccessLevel.lifetime;
    if (_earlySupporter) return AccessLevel.earlySupporter;
    return _clock().isBefore(trialEndsAt)
        ? AccessLevel.trial
        : AccessLevel.readOnly;
  }

  bool get canEdit => level != AccessLevel.readOnly;

  bool get isUnlocked =>
      level == AccessLevel.lifetime || level == AccessLevel.earlySupporter;

  DateTime get trialEndsAt => (_installedAt ?? _clock()).add(trialLength);

  /// Whole days left, counting today, so a fresh install shows 10.
  int get trialDaysLeft {
    final hours = trialEndsAt.difference(_clock()).inHours;
    return hours <= 0 ? 0 : (hours / 24).ceil();
  }

  Future<void> load() async {
    _owned = await _database.setting(_ownedKey) == 'true';
    _earlySupporter = await _database.setting(_earlySupporterKey) == 'true';
    _installedAt = DateTime.tryParse(
      await _database.setting(AppDatabase.installedAtKey) ?? '',
    );
    // Databases created since the trial began record their install time, so
    // one without it was made by 1.0 or 1.1, back when ShotKit was free.
    if (_installedAt == null && !_earlySupporter) {
      _earlySupporter = true;
      await _database.setSetting(_earlySupporterKey, 'true');
    }
    notifyListeners();
  }

  /// Fetches the price and quietly restores a purchase from a reinstall or
  /// another phone. Safe to call again to retry after a network failure.
  Future<void> connect() async {
    final billing = _billing;
    if (billing == null || connecting) return;
    _listen(billing);
    connecting = true;
    notifyListeners();
    try {
      if (!await billing.isAvailable()) return;
      final response = await billing.queryProductDetails({productId});
      product = response.productDetails
          .where((details) => details.id == productId)
          .firstOrNull;
      if (!_owned) await billing.restorePurchases();
    } catch (_) {
      // No Play Store, or Play is unreachable. The sheet offers a retry.
    } finally {
      connecting = false;
      notifyListeners();
    }
  }

  Future<void> buy() async {
    final billing = _billing;
    final product = this.product;
    if (billing == null || product == null || busy) return;
    _listen(billing);
    _start();
    try {
      final started = await billing.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: product),
      );
      if (!started) _fail('Google Play could not start the purchase.');
    } catch (_) {
      _fail('Google Play could not start the purchase.');
    }
    notifyListeners();
  }

  Future<void> restore() async {
    final billing = _billing;
    if (billing == null || busy) return;
    _listen(billing);
    _start();
    final restoring = _restoring = Completer<void>();
    try {
      await billing.restorePurchases();
      // Play answers through the purchase stream, even when nothing is owned.
      await restoring.future.timeout(const Duration(seconds: 5));
      if (!_owned) error = 'No ShotKit purchase found on this Google account.';
    } catch (_) {
      _fail('Could not reach Google Play. Check your connection.');
    }
    _restoring = null;
    busy = false;
    notifyListeners();
  }

  Future<void> _onPurchases(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.productID != productId) continue;
      switch (purchase.status) {
        case PurchaseStatus.pending:
          pending = true;
        case PurchaseStatus.purchased || PurchaseStatus.restored:
          pending = false;
          error = null;
          _owned = true;
          await _database.setSetting(_ownedKey, 'true');
        case PurchaseStatus.error:
          pending = false;
          error = 'The purchase did not go through. '
              'If you already paid, tap Restore purchase.';
        case PurchaseStatus.canceled:
          pending = false;
      }
      // Play refunds a purchase that is not acknowledged within 3 days.
      if (purchase.pendingCompletePurchase) {
        await _billing!.completePurchase(purchase);
      }
    }
    final restoring = _restoring;
    if (restoring == null) {
      busy = false;
    } else if (!restoring.isCompleted) {
      restoring.complete();
    }
    notifyListeners();
  }

  void _listen(InAppPurchase billing) =>
      _purchases ??= billing.purchaseStream.listen(_onPurchases);

  void _start() {
    busy = true;
    error = null;
    notifyListeners();
  }

  void _fail(String message) {
    busy = false;
    error = message;
  }

  @override
  void dispose() {
    _purchases?.cancel();
    super.dispose();
  }
}
