import 'package:flutter/material.dart';

enum StatusCheck { error, pending, ok, isNull }

class PurchaseStatusProvider extends ChangeNotifier {
  bool hasPurchased = false;
  StatusCheck statusCheck = StatusCheck.isNull;

  void updateStatus(bool status) {
    if (status) {
      statusCheck = StatusCheck.ok;
    }
    hasPurchased = status;
    notifyListeners();
  }

  void changeStatusCheck(StatusCheck statusCheck) {
    this.statusCheck = statusCheck;
    notifyListeners();
  }
}
