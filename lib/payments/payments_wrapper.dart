import 'dart:async';
import 'package:calculator_lite/payments/common_purchase_strings.dart';
import 'package:calculator_lite/payments/provider_purchase_status.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';

class PaymentsWrapper extends StatefulWidget {
  final Widget child;

  const PaymentsWrapper({required this.child, super.key});

  @override
  State<PaymentsWrapper> createState() => _PaymentsWrapperState();
}

class _PaymentsWrapperState extends State<PaymentsWrapper> {
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  final PurchaseStatusProvider _purchaseStatus = PurchaseStatusProvider();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _initialize();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _purchaseStatus.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    try {
      final Stream<List<PurchaseDetails>> purchaseUpdated = _iap.purchaseStream;

      _subscription = purchaseUpdated.listen(
        (purchaseDetailsList) => _listenToPurchaseUpdated(purchaseDetailsList),
        onDone: () => _subscription?.cancel(),
        onError: (_) {
          if (mounted) _purchaseStatus.changeStatusCheck(StatusCheck.error);
        },
      );

      final bool available = await _iap.isAvailable();
      if (!mounted) return;
      if (available) {
        await _iap.restorePurchases(applicationUserName: null);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PurchaseStatusProvider>.value(
      value: _purchaseStatus,
      child: widget.child,
    );
  }

  Future<void> _listenToPurchaseUpdated(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    for (final purchase in purchaseDetailsList) {
      if (!mounted) return;
      _verifyPurchase(purchase);

      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  void _verifyPurchase(PurchaseDetails purchase) {
    try {
      if (CommonPurchaseStrings.productIds.contains(purchase.productID)) {
        switch (purchase.status) {
          case PurchaseStatus.restored:
          case PurchaseStatus.purchased:
            _deliverPurchase(purchase);
            break;
          case PurchaseStatus.error:
            _purchaseStatus.changeStatusCheck(StatusCheck.error);
            break;
          case PurchaseStatus.pending:
            _purchaseStatus.changeStatusCheck(StatusCheck.pending);
            break;
          default:
            _purchaseStatus.changeStatusCheck(StatusCheck.isNull);
            break;
        }
      } else {
        _purchaseStatus.changeStatusCheck(StatusCheck.error);
      }
    } catch (_) {}
  }

  void _deliverPurchase(PurchaseDetails purchase) {
    if (!mounted) return;
    _purchaseStatus.updateStatus(true);
    _iap.completePurchase(purchase);
  }
}
