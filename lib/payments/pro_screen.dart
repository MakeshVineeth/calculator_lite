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

  @override
  Widget build(BuildContext context) {
    purchaseStatusProvider = Provider.of<PurchaseStatusProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Buy Pro Version'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: FutureBuilder(
              future: _getProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done)
                  return Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Text(
                          'Get More Features by unlocking the Pro version',
                          style: FixedValues.semiBoldStyle,
                          textAlign: TextAlign.center,
                        ),
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

  Widget loadProducts() {
    if (!purchaseStatusProvider.hasPurchased && _products.isNotEmpty)
      return Column(
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
