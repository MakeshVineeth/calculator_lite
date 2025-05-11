import 'dart:io';
import 'package:calculator_lite/UIElements/fade_scale_widget.dart';
import 'package:calculator_lite/UIElements/show_blur_dialog.dart';
import 'package:calculator_lite/fixed_values.dart';
import 'package:calculator_lite/payments/common_purchase_strings.dart';
import 'package:calculator_lite/payments/provider_purchase_status.dart';
import 'package:calculator_lite/payments/purchase_button.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';

class ProScreen extends StatefulWidget {
  const ProScreen({super.key});

  @override
  State<ProScreen> createState() => _ProScreenState();
}

class _ProScreenState extends State<ProScreen> {
  final List<ProductDetails> _products = [];
  late PurchaseStatusProvider purchaseStatusProvider;
  final Map<String, String> featuresList = {
    'Support the Developer': 'A token of appreciation from your side :)',
    'Promote Development':
        'Your donations will keep me motivated in further development of this app :)',
  };

  // The In App Purchase plugin
  final InAppPurchase _iap = InAppPurchase.instance;

  bool isPortrait = true;

  late Future<void> _loadProductsFut;

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
      appBar: AppBar(title: const Text('Support Us'), elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Card(
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: checkPlatformWin(),
          ),
        ),
      ),
    );
  }

  Widget checkPlatformWin() {
    if (!Platform.isAndroid) {
      return const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Not Supported', style: FixedValues.semiBoldStyle),
          ),
        ),
      );
    } else {
      return FutureBuilder(
        future: _loadProductsFut,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: isPortrait ? 10 : 5),
                const Text(
                  'Donations',
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
                const SizedBox(height: 10),
                Text(
                  'Tip: Click on each feature card to learn more.',
                  textAlign: TextAlign.center,
                  style: FixedValues.semiBoldStyle.copyWith(
                    fontSize: 13.5,
                    color:
                        Theme.of(context).brightness == Brightness.light
                            ? Colors.black54
                            : Colors.white70,
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      );
    }
  }

  Widget bulletPoints() => ListView(
    physics: const AlwaysScrollableScrollPhysics(
      parent: BouncingScrollPhysics(),
    ),
    children: List.generate(featuresList.length, (index) {
      return Card(
        color:
            Theme.of(context).brightness == Brightness.light
                ? Colors.white
                : Colors.black87,
        elevation:
            Theme.of(context).brightness == Brightness.light
                ? Theme.of(context).cardTheme.elevation
                : 4,
        child: InkWell(
          onTap:
              () => showBlurDialog(
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 5.0),
                Expanded(
                  child: Text(
                    featuresList.keys.elementAt(index),
                    style: const TextStyle(
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
    if (_products.isNotEmpty && !purchaseStatusProvider.hasPurchased) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(
          _products.length,
          (index) => PurchaseButton(
            callback: () => _buyProduct(_products.elementAt(index)),
            fg: Colors.white,
            bg: Colors.blueAccent,
            text: 'BUY ${_products.elementAt(index).price}',
          ),
        ),
      );
    } else if (purchaseStatusProvider.hasPurchased) {
      return PurchaseButton(
        callback: () => {},
        fg: Colors.white,
        bg: Colors.green,
        text: CommonPurchaseStrings.paymentSuccess,
      );
    } else if (purchaseStatusProvider.statusCheck == StatusCheck.pending) {
      return PurchaseButton(
        callback: () => {},
        fg: Colors.white,
        bg: Colors.blueAccent,
        text: CommonPurchaseStrings.paymentPending,
      );
    } else {
      return PurchaseButton(
        callback: () => {},
        fg: Colors.white,
        bg: Colors.red,
        text: CommonPurchaseStrings.paymentErrors,
      );
    }
  }

  void _buyProduct(ProductDetails prod) async {
    try {
      final PurchaseParam purchaseParam = PurchaseParam(productDetails: prod);
      bool iapAvailable = await _iap.isAvailable();

      if (iapAvailable) _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (_) {}
  }

  Future<void> _getProducts() async {
    try {
      _products.clear();
      bool iapAvailable = await _iap.isAvailable();

      if (iapAvailable) {
        final ProductDetailsResponse response = await _iap.queryProductDetails(
          CommonPurchaseStrings.productIds,
        );

        if (!response.notFoundIDs.isNotEmpty) {
          _products.addAll(response.productDetails);
        } else {
          _products.clear();
        }
      } else {
        _products.clear();
      }
    } catch (_) {
      _products.clear();
      return;
    }
  }
}
