import 'package:calculator_lite/fixedValues.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class ProScreen extends StatefulWidget {
  @override
  _ProScreenState createState() => _ProScreenState();
}

class _ProScreenState extends State<ProScreen> {
  final Set<String> _kIds = {'plus1'};
  List<ProductDetails> _products = [];

  @override
  Widget build(BuildContext context) {
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
    return Column(
      children: List.generate(_products.length, (index) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton(
              onPressed: () => _buyProduct(_products.elementAt(index)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(_products.elementAt(index).title +
                    ' ' +
                    _products.elementAt(index).price),
              ),
            ),
          ),
        );
      }),
    );
  }

  Future<void> _getProducts() async {
    final ProductDetailsResponse response =
        await InAppPurchaseConnection.instance.queryProductDetails(_kIds);

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
