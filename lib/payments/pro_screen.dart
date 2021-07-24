import 'dart:io';
import 'package:calculator_lite/UIElements/fade_scale_widget.dart';
import 'package:calculator_lite/UIElements/showBlurDialog.dart';
import 'package:calculator_lite/fixedValues.dart';
import 'package:calculator_lite/payments/common_purchase_strings.dart';
import 'package:calculator_lite/payments/provider_purchase_status.dart';
import 'package:calculator_lite/payments/purchase_button.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';

class ProScreen extends StatefulWidget {
  @override
  _ProScreenState createState() => _ProScreenState();
}

class _ProScreenState extends State<ProScreen> {
  List<ProductDetails> _products = [];
  PurchaseStatusProvider purchaseStatusProvider;
  final Map<String, String> featuresList = {
    'Support the Developer': 'A token of appreciation from your side :)',
    'Promote the Development':
        'Your donations will keep me motivated in further development of this app :)',
  };

  // The In App Purchase plugin
  InAppPurchase _iap = InAppPurchase.instance;

  bool isPortrait = true;

  Future<void> _loadProductsFut;

  @override
  void initState() {
    super.initState();
    _loadProductsFut = _getProducts();
  }

  @override
  Widget build(BuildContext context) {
    purchaseStatusProvider = context.watch<PurchaseStatusProvider>();
    isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      appBar: AppBar(
        title: Text('Support Us'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: checkPlatformWin(),
          ),
        ),
      ),
    );
  }

  Widget checkPlatformWin() {
    if (!Platform.isAndroid)
      return Center(
        child: Card(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Not Supported',
            style: FixedValues.semiBoldStyle,
          ),
        )),
      );
    else
      return FutureBuilder(
        future: _loadProductsFut,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: isPortrait ? 10 : 5),
                Text(
                  'Donate',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                  textAlign: TextAlign.center,
                ),
                Flexible(
                  child: Container(
                    alignment: Alignment.center,
                    child: FractionallySizedBox(
                      heightFactor: isPortrait ? 0.8 : 1,
                      child: bulletPoints(),
                    ),
                  ),
                ),
                loadProducts(),
                SizedBox(height: 10),
                Text(
                  'Tip: Click on each feature card to learn more.',
                  textAlign: TextAlign.center,
                  style: FixedValues.semiBoldStyle.copyWith(
                    fontSize: 13.5,
                  ),
                ),
              ],
            );
          } else
            return Center(child: CircularProgressIndicator());
        },
      );
  }

  Widget bulletPoints() => ListView(
        physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        children: List.generate(featuresList.length, (index) {
          return Card(
            elevation: Theme.of(context).brightness == Brightness.light
                ? Theme.of(context).cardTheme.elevation
                : 4,
            child: InkWell(
              onTap: () => showBlurDialog(
                context: context,
                child: FadeScale(
                  child: AlertDialog(
                    content: Text(featuresList.values.elementAt(index)),
                    shape: FixedValues.roundShapeLarge,
                  ),
                ),
              ),
              borderRadius: FixedValues.large,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                    SizedBox(width: 5.0),
                    Expanded(
                      child: Text(
                        featuresList.keys.elementAt(index),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      );

  Widget loadProducts() {
    if (_products.isNotEmpty && !purchaseStatusProvider.hasPurchased)
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(
          _products.length,
          (index) => PurchaseButton(
            callback: () => _buyProduct(_products.elementAt(index)),
            fg: Colors.white,
            bg: Colors.blueAccent,
            text: 'BUY ' + _products.elementAt(index).price,
          ),
        ),
      );
    else if (purchaseStatusProvider.hasPurchased)
      return PurchaseButton(
        callback: () => {},
        fg: Colors.white,
        bg: Colors.green,
        text: CommonPurchaseStrings.paymentSuccess,
      );
    else if (purchaseStatusProvider.statusCheck == StatusCheck.Pending)
      return PurchaseButton(
        callback: () => {},
        fg: Colors.white,
        bg: Colors.blueAccent,
        text: CommonPurchaseStrings.paymentPending,
      );
    else
      return PurchaseButton(
        callback: () => {},
        fg: Colors.white,
        bg: Colors.red,
        text: CommonPurchaseStrings.paymentErrors,
      );
  }

  void _buyProduct(ProductDetails prod) async {
    try {
      final PurchaseParam purchaseParam = PurchaseParam(productDetails: prod);
      bool _iapAvailable = await _iap.isAvailable();

      if (_iapAvailable) _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (_) {}
  }

  Future<void> _getProducts() async {
    try {
      _products.clear();
      bool _iapAvailable = await _iap.isAvailable();

      if (_iapAvailable) {
        final ProductDetailsResponse response =
            await _iap.queryProductDetails(CommonPurchaseStrings.productIds);

        if (!response.notFoundIDs.isNotEmpty)
          _products.addAll(response.productDetails);
        else
          _products.clear();
      } else
        _products.clear();
    } catch (_) {
      _products.clear();
      return;
    }
  }
}
