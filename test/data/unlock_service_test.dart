import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shotkit/data/app_database.dart';
import 'package:shotkit/data/unlock_service.dart';

void main() {
  late AppDatabase database;
  late DateTime now;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    now = DateTime.now();
  });

  tearDown(() => database.close());

  UnlockService service({InAppPurchase? billing}) =>
      UnlockService(database, billing: billing, clock: () => now);

  test('a new install starts a 10-day trial', () async {
    final unlock = service();
    await unlock.load();

    expect(unlock.level, AccessLevel.trial);
    expect(unlock.trialDaysLeft, 10);
    expect(unlock.canEdit, isTrue);
  });

  test('goes read-only when the trial runs out', () async {
    final unlock = service();
    await unlock.load();

    now = now.add(const Duration(days: 9, hours: 1));
    expect(unlock.trialDaysLeft, 1);
    expect(unlock.canEdit, isTrue);

    now = now.add(const Duration(days: 1));
    expect(unlock.level, AccessLevel.readOnly);
    expect(unlock.trialDaysLeft, 0);
    expect(unlock.canEdit, isFalse);
  });

  test('installs from before the trial stay free for life', () async {
    // Databases made by 1.0 and 1.1 have no install time.
    await (database.delete(database.appSettings)
          ..where((row) => row.key.equals(AppDatabase.installedAtKey)))
        .go();
    await service().load();

    now = now.add(const Duration(days: 365));
    final unlock = service();
    await unlock.load();
    expect(unlock.level, AccessLevel.earlySupporter);
    expect(unlock.canEdit, isTrue);
  });

  test('buying unlocks for life and acknowledges the purchase', () async {
    final billing = _FakeBilling();
    final unlock = service(billing: billing);
    await unlock.load();
    await unlock.connect();
    expect(unlock.product?.price, r'$2.99');

    await unlock.buy();
    await pumpEventQueue();
    expect(unlock.level, AccessLevel.lifetime);
    expect(unlock.busy, isFalse);
    expect(billing.completed, hasLength(1));

    now = now.add(const Duration(days: 30));
    final reopened = service();
    await reopened.load();
    expect(reopened.level, AccessLevel.lifetime);
  });

  test('a cancelled purchase keeps the trial running', () async {
    final billing = _FakeBilling()..buyResult = PurchaseStatus.canceled;
    final unlock = service(billing: billing);
    await unlock.load();
    await unlock.connect();

    await unlock.buy();
    await pumpEventQueue();
    expect(unlock.level, AccessLevel.trial);
    expect(unlock.busy, isFalse);
    expect(unlock.error, isNull);
  });

  test('restores a purchase after a reinstall', () async {
    final billing = _FakeBilling()
      ..owned = [_purchase(PurchaseStatus.restored)];
    final unlock = service(billing: billing);
    await unlock.load();
    now = now.add(const Duration(days: 20));
    expect(unlock.level, AccessLevel.readOnly);

    await unlock.restore();
    expect(unlock.level, AccessLevel.lifetime);
    expect(unlock.busy, isFalse);
  });

  test('restore says so when nothing was bought', () async {
    final unlock = service(billing: _FakeBilling());
    await unlock.load();

    await unlock.restore();
    expect(unlock.level, AccessLevel.trial);
    expect(unlock.error, contains('No ShotKit purchase'));
    expect(unlock.busy, isFalse);
  });
}

PurchaseDetails _purchase(PurchaseStatus status) => PurchaseDetails(
      productID: UnlockService.productId,
      verificationData: PurchaseVerificationData(
        localVerificationData: '',
        serverVerificationData: '',
        source: 'test',
      ),
      transactionDate: null,
      status: status,
    )..pendingCompletePurchase = status == PurchaseStatus.purchased;

class _FakeBilling extends Fake implements InAppPurchase {
  final _purchases = StreamController<List<PurchaseDetails>>.broadcast();
  final completed = <PurchaseDetails>[];
  var owned = <PurchaseDetails>[];
  var buyResult = PurchaseStatus.purchased;

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => _purchases.stream;

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<ProductDetailsResponse> queryProductDetails(
    Set<String> identifiers,
  ) async =>
      ProductDetailsResponse(
        productDetails: [
          ProductDetails(
            id: UnlockService.productId,
            title: 'ShotKit Lifetime',
            description: '',
            price: r'$2.99',
            rawPrice: 2.99,
            currencyCode: 'USD',
          ),
        ],
        notFoundIDs: [],
      );

  @override
  Future<void> restorePurchases({String? applicationUserName}) async =>
      _purchases.add(owned);

  @override
  Future<bool> buyNonConsumable({required PurchaseParam purchaseParam}) async {
    _purchases.add([_purchase(buyResult)]);
    return true;
  }

  @override
  Future<void> completePurchase(PurchaseDetails purchase) async =>
      completed.add(purchase);
}
