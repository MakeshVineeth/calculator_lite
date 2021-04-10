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
  void initState() {
    super.initState();
    _getProducts();
  }

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
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Text(
                    'Get More Features by unlocking the Pro version',
                    style: FixedValues.semiBoldStyle,
                  ),
                ),
                for (ProductDetails item in _products)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextButton(
                        onPressed: () => _buyProduct(item),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(item.id),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
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
