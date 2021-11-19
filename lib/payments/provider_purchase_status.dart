import 'package:flutter/material.dart';

enum StatusCheck { error, pending, ok, isNull }

// Simple Provider for actual comparison for rest of the application features.
class PurchaseStatusProvider extends ChangeNotifier {
  bool hasPurchased = false;
  StatusCheck statusCheck = StatusCheck.isNull;

  void updateStatus(bool status) {
    if (status) changeStatusCheck(StatusCheck.ok);

    hasPurchased = status;
    notifyListeners();
  }

  void changeStatusCheck(StatusCheck _statusCheck) {
    statusCheck = _statusCheck;
    notifyListeners();
  }
}
