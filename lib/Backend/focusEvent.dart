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
    if (calculationString != null && myText != null) {
      if (calculationString.length != myText.length) {
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
      } else
        return position;

      notifyListeners();
    }

    return convertStr.length;
  }

  int getPosition({@required int start, @required List<String> givenText}) {
    try {
      int len = givenText.length;
      if (start > 0 && start < len) {
        myText = givenText.join();
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
      } else {
        position = start;
        return position;
      }
    } catch (e) {
      return null;
    }
  }

  void updateFocus() {
    isFocused = true;
  }

  List<String> removeBack({
    @required List<String> calculationString,
  }) {
    int pos = getCurPosition(calculationString);
    if (pos < calculationString.length) calculationString.removeAt(pos);
    return calculationString;
  }

  List<String> getRegulatedString(
      {@required List<String> calculationString,
      @required var currentMetric,
      @required var value}) {
    try {
      int pos = getCurPosition(calculationString);

      // Temp String for Checking.
      List<String> temp = calculationString.getRange(0, pos).toList();
      int flag = temp.length;
      CalcParser calcParser =
          CalcParser(calculationString: temp, currentMetric: currentMetric);
      temp = calcParser.addToExpression(value);
      if (flag != temp.length) {
        // add the next element to check if it able to insert.
        if (pos < calculationString.length) {
          flag = temp.length;
          temp = calcParser.addToExpression(calculationString[pos]);
        }

        // Replace string and move position to next item.
        if (flag != temp.length) {
          // replace by checking if pos is within range.
          if (pos < calculationString.length)
            calculationString.replaceRange(0, pos + 1, temp);
          else
            calculationString.replaceRange(0, pos, temp);

          // move position here.
          String tempStr = temp.join();
          if (!lists.contains(temp.join()[position]))
            position += 1;

          // detected cos, tan, sin etc here.
          else {
            int i = position + 1;
            for (; i < tempStr.length; i++) {
              if (!lists.contains(tempStr[i])) break;
            }
            position = i + 1;
          }
        }
      }

      // save newly made text and return final string.
      myText = calculationString.join();
      return calculationString;
    } catch (e) {
      return null;
    }
  }

  void clearData() {
    position = 0;
    myText = '';
    isFocused = false;
  }
}
