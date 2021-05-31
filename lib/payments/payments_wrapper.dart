import 'dart:async';
import 'package:calculator_lite/payments/common_purchase_strings.dart';
import 'package:calculator_lite/payments/provider_purchase_status.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';

class PaymentsWrapper extends StatefulWidget {
  final Widget child;

  const PaymentsWrapper({@required this.child});

  @override
  _PaymentsWrapperState createState() => _PaymentsWrapperState();
}

class _PaymentsWrapperState extends State<PaymentsWrapper> {
  // Is the API available on the device. Verified on init.
  bool _available = false;

  // The In App Purchase plugin
  InAppPurchase _iap = InAppPurchase.instance;

  // Past purchases
  List<PurchaseDetails> _purchases = [];

  // Updates to purchases
  StreamSubscription<List<PurchaseDetails>> _subscription;

  // Provider
  final PurchaseStatusProvider _purchaseStatus = PurchaseStatusProvider();

  @override
  void initState() {
    _initialize();
    super.initState();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  // Initialize data
  void _initialize() async {
    _available = await _iap.isAvailable();

    if (_available) {
      await _iap.restorePurchases();

      _subscription = _iap.purchaseStream.listen(
        (purchaseDetailsList) => _listenToPurchaseUpdated(purchaseDetailsList),
        onDone: () => _subscription.cancel(),
        onError: (error) => print('Error!'),
      );
    }
  }

  // Returns purchase of specific product ID
  PurchaseDetails _hasPurchased(String productID) => _purchases.firstWhere(
        (purchase) => purchase.productID == productID,
        orElse: () => null,
      );

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PurchaseStatusProvider>.value(
      value: _purchaseStatus,
      child: widget.child,
    );
  }

  Future<void> _listenToPurchaseUpdated(
      List<PurchaseDetails> purchaseDetailsList) async {
    _purchases.addAll(purchaseDetailsList);

    for (var purchase in purchaseDetailsList) {
      _verifyPurchase(purchase);

      if (purchase.pendingCompletePurchase) _iap.completePurchase(purchase);
    }
  }

  void _verifyPurchase(PurchaseDetails purchase) {
    try {
      if (_hasPurchased(purchase.productID) != null) {
        // Check if purchased the right product.
        if (CommonPurchaseStrings.productIds.contains(purchase.productID)) {
          // Now check the product status.

          switch (purchase.status) {
            case PurchaseStatus.restored:
            case PurchaseStatus.purchased:
              _deliverPurchase(purchase);
              break;
            case PurchaseStatus.error:
              _purchaseStatus.changeStatusCheck(StatusCheck.Error);
              break;
            case PurchaseStatus.pending:
              _purchaseStatus.changeStatusCheck(StatusCheck.Pending);
              break;
            default:
              _purchaseStatus.changeStatusCheck(StatusCheck.Null);
              break;
          }
        } else {
          _purchaseStatus.changeStatusCheck(StatusCheck.Error);
        }
      }

      // If a null is received.
      else
        _purchaseStatus.changeStatusCheck(StatusCheck.Error);
    } catch (_) {}
  }

  void _deliverPurchase(PurchaseDetails purchase) {
    // If verified, deliver it. A Separate Provider to unlock the features.
    _purchaseStatus.updateStatus(true);
    _iap.completePurchase(purchase);
  }
}
