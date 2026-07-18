import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';

class EntitlementService {
  EntitlementService({required this.onUnlocked});

  static const productId = 'pro_unlock';
  final Future<void> Function() onUnlocked;
  InAppPurchase? _purchaseInstance;
  InAppPurchase get _purchase => _purchaseInstance ??= InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  ProductDetails? product;
  String? error;
  bool available = false;

  Future<void> initialize() async {
    _subscription = _purchase.purchaseStream.listen(_handlePurchases,
        onError: (Object issue) {
      error = issue.toString();
    });
    try {
      available = await _purchase.isAvailable();
      if (!available) return;
      final response = await _purchase.queryProductDetails({productId});
      if (response.productDetails.isNotEmpty) {
        product = response.productDetails.first;
      }
      error = response.error?.message;
    } catch (issue) {
      error = issue.toString();
    }
  }

  Future<bool> buy() async {
    if (product == null) return false;
    return _purchase.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: product!));
  }

  Future<void> restore() => _purchase.restorePurchases();

  Future<void> _handlePurchases(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.productID == productId &&
          (purchase.status == PurchaseStatus.purchased ||
              purchase.status == PurchaseStatus.restored)) {
        await onUnlocked();
      }
      if (purchase.pendingCompletePurchase) {
        await _purchase.completePurchase(purchase);
      }
    }
  }

  void dispose() => _subscription?.cancel();
}
