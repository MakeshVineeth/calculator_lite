import 'package:calculator_lite/fixedValues.dart';
import 'package:flutter/cupertino.dart';
import 'package:calculator_lite/Backend/calcParser.dart';

class FocusEvent extends ChangeNotifier {
  int position = 0;

  List<String> lists = 'sicotao⁻¹mngl'.split('');
  String myText;
  bool isFocused = false;

  int getCurPosition(List<String> calculationString) {
    List<String> convertStr = [];
    if (calculationString != null &&
        myText != null &&
        calculationString.length != myText.length) {
      String trimmedText = myText.substring(0, position);

      for (int i = 0; i < trimmedText.length; i++) {
        if ((lists.contains(trimmedText[i]) || trimmedText.contains('(')) &&
            i - 1 >= 0 &&
            lists.contains(trimmedText[i - 1])) {
          int len = convertStr.length - 1;
          convertStr[len] = '${convertStr[len]}${trimmedText[i]}';
        } else
          convertStr.add('${trimmedText[i]}');
      }
    }

    notifyListeners();
    return convertStr.length;
  }

  int getPosition({@required int start, @required String givenText}) {
    try {
      myText = givenText;
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

  void updateFocus() {
    isFocused = true;
  }

  List<String> getRegulatedString(
      {@required List<String> calculationString,
      @required var currentMetric,
      @required var value}) {
    try {
      int pos = getCurPosition(calculationString);
      List<String> temp = calculationString.getRange(0, pos).toList();
      int flag = temp.length;
      CalcParser calcParser1 =
          CalcParser(calculationString: temp, currentMetric: currentMetric);
      temp = calcParser1.addToExpression(value);
      if (flag != temp.length) {
        calculationString.insert(pos, value);
        position += 1;
      }
      return calculationString;
    } catch (e) {
      print('Exception: $e');
      return calculationString;
    }
  }
}
