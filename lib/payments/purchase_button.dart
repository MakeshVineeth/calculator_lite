import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class PurchaseButton extends StatelessWidget {
  final List<ProductDetails> products;
  final index;

  const PurchaseButton({@required this.products, @required this.index});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _buyProduct(products.elementAt(index)),
      style: ElevatedButton.styleFrom(
        primary: Colors.blueAccent,
        onPrimary: Colors.white,
        elevation: 10,
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Text(
          'Buy',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 25.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _buyProduct(ProductDetails prod) async {
    try {
      final PurchaseParam purchaseParam = PurchaseParam(productDetails: prod);

      InAppPurchaseConnection _iap = InAppPurchaseConnection.instance;
      bool _iapAvailable = await _iap.isAvailable();

      if (_iapAvailable) _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {}
  }
}
