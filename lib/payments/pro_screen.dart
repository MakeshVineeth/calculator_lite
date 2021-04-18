import 'package:calculator_lite/fixedValues.dart';
import 'package:calculator_lite/payments/common_purchase_strings.dart';
import 'package:calculator_lite/payments/provider_purchase_status.dart';
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
                        ),
                      ),
                      product(),
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

  Widget product() {
    if (!purchaseStatusProvider.hasPurchased)
      return Column(
        children: List.generate(_products.length, (index) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton(
                onPressed: () => _buyProduct(_products.elementAt(index)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _products.elementAt(index).title +
                        ' ' +
                        _products.elementAt(index).price,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
        }),
      );
    else
      return Card(
        child: InkWell(
          borderRadius: FixedValues.large,
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 15),
            child: Text(
              'Already Purchased!',
              style: FixedValues.semiBoldStyle,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
  }

  Future<void> _getProducts() async {
    final ProductDetailsResponse response = await InAppPurchaseConnection
        .instance
        .queryProductDetails(CommonPurchaseStrings.productIds);

    if (response.notFoundIDs.isNotEmpty) {
      print('Products not found!');
    }

    _products.addAll(response.productDetails);
  }

  void _buyProduct(ProductDetails prod) {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: prod);
    InAppPurchaseConnection.instance
        .buyNonConsumable(purchaseParam: purchaseParam);
  }
}
