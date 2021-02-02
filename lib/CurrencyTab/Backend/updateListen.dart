import 'package:flutter/cupertino.dart';

class UpdateListen extends ChangeNotifier {
  bool inProgress = false;

  void update() => notifyListeners();
}
