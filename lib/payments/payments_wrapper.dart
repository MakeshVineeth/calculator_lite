import 'dart:async';
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
  InAppPurchaseConnection _iap = InAppPurchaseConnection.instance;

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
      await _getPastPurchases();

      _subscription = _iap.purchaseUpdatedStream.listen(
        (purchaseDetailsList) => _listenToPurchaseUpdated(purchaseDetailsList),
        onDone: () => _subscription.cancel(),
        onError: (error) => print('Error!'),
      );
    }
  }

  // Gets past purchases
  Future<void> _getPastPurchases() async {
    final QueryPurchaseDetailsResponse response =
        await _iap.queryPastPurchases();

    if (response.error != null) {
      print('An Error has Occurred!');
    }

    for (PurchaseDetails purchase in response.pastPurchases) {
      _verifyPurchase(purchase);
    }
  }

  // Returns purchase of specific product ID
  PurchaseDetails _hasPurchased(String productID) {
    return _purchases.firstWhere(
      (purchase) => purchase.productID == productID,
      orElse: () => null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PurchaseStatusProvider>.value(
      value: _purchaseStatus,
      child: widget.child,
    );
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    _purchases.addAll(purchaseDetailsList);
    purchaseDetailsList.forEach((element) => _verifyPurchase(element));
  }

  void _verifyPurchase(PurchaseDetails purchase) {
    if (_hasPurchased(purchase.productID) != null ||
        purchase.status == PurchaseStatus.purchased) {
      _deliverPurchase(purchase);
    }
  }

  void _deliverPurchase(PurchaseDetails purchase) {
    // If verified, deliver it. A Separate Provider to unlock the features.
    _purchaseStatus.updateStatus(true);
  }
}
