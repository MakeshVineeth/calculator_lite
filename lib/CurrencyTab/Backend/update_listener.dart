import 'package:flutter/material.dart';

class UpdateListen extends ChangeNotifier {
  bool inProgress = false;

  void update() => notifyListeners();
}
