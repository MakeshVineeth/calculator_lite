import 'package:flutter/cupertino.dart';

// Simple Provider for actual comparison for rest of the application features.
class PurchaseStatusProvider extends ChangeNotifier {
  bool hasPurchased = false;

  void updateStatus(bool status) {
    this.hasPurchased = status;
    notifyListeners();
  }
}
