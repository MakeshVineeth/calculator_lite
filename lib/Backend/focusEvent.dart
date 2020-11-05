import 'package:calculator_lite/fixedValues.dart';
import 'package:flutter/cupertino.dart';

class FocusEvent extends ChangeNotifier {
  int position = 0;

  static String list = 'sicotao⁻¹mngl';
  List<String> lists = list.split('');

  int getCurPosition() {
    notifyListeners();
    return position;
  }

  int getPosition({@required int start, @required String myText}) {
    try {
      if (myText[start].contains(FixedValues.root) &&
          myText.length > 1 &&
          myText[start - 1].contains(FixedValues.sup3)) start -= 1;

      int count = start - 1;
      for (; count >= 0; count--) {
        if (!lists.contains(myText[count])) {
          count += 1;
          break;
        }
      }

      position = count;
      return position;
    } catch (e) {
      return null;
    }
  }
}
