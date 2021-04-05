import 'dart:async';
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
  // Is the API available on the device
  bool _available = true;

  Stream _purchaseUpdated;

  // The In App Purchase plugin
  InAppPurchaseConnection _iap = InAppPurchaseConnection.instance;

  // Products for sale
  List<ProductDetails> _products = [];

  // Past purchases
  List<PurchaseDetails> _purchases = [];

  // Updates to purchases
  StreamSubscription<List<PurchaseDetails>> _subscription;

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
    _purchaseUpdated = InAppPurchaseConnection.instance.purchaseUpdatedStream;

    _subscription = _purchaseUpdated.listen(
      (purchaseDetailsList) => _listenToPurchaseUpdated(purchaseDetailsList),
      onDone: () => _subscription.cancel(),
      onError: (error) => print('Error!'),
    );
  }

  // Get all products available for sale
  Future<void> _getProducts() async {
    const Set<String> _kIds = {'product1', 'product2'};

    final ProductDetailsResponse response =
        await InAppPurchaseConnection.instance.queryProductDetails(_kIds);

    if (response.notFoundIDs.isNotEmpty) print('Products not found!');

    _products = response.productDetails;
  }

  // Gets past purchases
  Future<void> _getPastPurchases() async {
    final QueryPurchaseDetailsResponse response =
        await InAppPurchaseConnection.instance.queryPastPurchases();

    if (response.error != null) {
      print('An Error has Occurred!');
    }

    for (PurchaseDetails purchase in response.pastPurchases) {
      _verifyPurchase(purchase);
    }
  }

  // Returns purchase of specific product ID
  PurchaseDetails _hasPurchased(String productID) {
    return _purchases.firstWhere((purchase) => purchase.productID == productID,
        orElse: () => null);
  }

  /// Purchase a product
  void _buyProduct(ProductDetails prod) {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: prod);
    _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  @override
  Widget build(BuildContext context) {
    return StreamProvider.value(
      value: _purchaseUpdated,
      builder: (context, child) => widget.child,
    );
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    _purchases.addAll(purchaseDetailsList);
  }

  void _verifyPurchase(PurchaseDetails purchase) {
    if (purchase.status == PurchaseStatus.purchased) {
      _purchases.add(purchase);
      _deliverPurchase(purchase);
    }
  }

  void _deliverPurchase(PurchaseDetails purchase) {
    // If verified, deliver it. A Separate Provider to unlock the features.
  }
}
