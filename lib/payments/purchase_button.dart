import 'package:calculator_lite/fixedValues.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class PurchaseButton extends StatelessWidget {
  final List<ProductDetails> products;
  final index;

  const PurchaseButton({@required this.products, @required this.index});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextButton(
          onPressed: () => _buyProduct(products.elementAt(index)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              products.elementAt(index).title +
                  ' ' +
                  products.elementAt(index).price,
              textAlign: TextAlign.center,
              style: FixedValues.semiBoldStyle,
            ),
          ),
        ),
      ),
    );
  }

  void _buyProduct(ProductDetails prod) {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: prod);
    InAppPurchaseConnection.instance
        .buyNonConsumable(purchaseParam: purchaseParam);
  }
}
