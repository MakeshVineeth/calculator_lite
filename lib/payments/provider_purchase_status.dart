import 'package:flutter/material.dart';

enum StatusCheck { Error, Pending, OK, Null }

// Simple Provider for actual comparison for rest of the application features.
class PurchaseStatusProvider extends ChangeNotifier {
  bool hasPurchased = false;
  StatusCheck statusCheck = StatusCheck.Null;

  void updateStatus(bool status) {
    if (status) changeStatusCheck(StatusCheck.OK);

    this.hasPurchased = status;
    notifyListeners();
  }

  void changeStatusCheck(StatusCheck _statusCheck) {
    this.statusCheck = _statusCheck;
    notifyListeners();
  }
}
