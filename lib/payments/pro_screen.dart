import 'package:calculator_lite/fixedValues.dart';
import 'package:calculator_lite/payments/common_purchase_strings.dart';
import 'package:calculator_lite/payments/provider_purchase_status.dart';
import 'package:calculator_lite/payments/purchase_button.dart';
import 'package:calculator_lite/payments/purchase_tooltip.dart';
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
  final List<String> featuresList = [
    'Support the Developer',
    'Unlock the Export Feature',
    'Add Unlimited Currency Cards',
    'Enable/Disable Privacy Mode',
  ];

  @override
  Widget build(BuildContext context) {
    purchaseStatusProvider = Provider.of<PurchaseStatusProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Support Us'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: FutureBuilder(
              future: _getProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done)
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Text(
                          'Unlock Everything',
                          style: TextStyle(
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: bulletPoints(),
                      ),
                      loadProducts(),
                    ],
                  );
                else
                  return Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget bulletPoints() {
    return Column(
      children: List.generate(featuresList.length, (index) {
        return Card(
          elevation: Theme.of(context).brightness == Brightness.light
              ? Theme.of(context).cardTheme.elevation
              : 4,
          child: InkWell(
            onTap: () => {},
            borderRadius: FixedValues.large,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                  ),
                  SizedBox(width: 5.0),
                  Flexible(
                    child: Text(
                      featuresList.elementAt(index),
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
  }

  Widget loadProducts() {
    if (!purchaseStatusProvider.hasPurchased && _products.isNotEmpty)
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(
          _products.length,
          (index) => PurchaseButton(products: _products, index: index),
        ),
      );
    else if (purchaseStatusProvider.hasPurchased)
      return PurchaseToolTip(text: CommonPurchaseStrings.paymentSuccess);
    else
      return PurchaseToolTip(text: CommonPurchaseStrings.paymentErrors);
  }

  Future<void> _getProducts() async {
    try {
      _products.clear();
      final ProductDetailsResponse response = await InAppPurchaseConnection
          .instance
          .queryProductDetails(CommonPurchaseStrings.productIds);

      if (response.notFoundIDs.isNotEmpty) return;

      _products.addAll(response.productDetails);
    } catch (e) {
      return;
    }
  }
}
