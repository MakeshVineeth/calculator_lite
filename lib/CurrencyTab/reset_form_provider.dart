import 'package:flutter/cupertino.dart';

class ResetFormProvider extends ChangeNotifier {
  void reset(bool value) {
    notifyListeners();
  }
}
