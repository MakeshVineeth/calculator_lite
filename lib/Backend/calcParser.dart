import 'package:math_expressions/math_expressions.dart';
import 'package:calculator_lite/fixedValues.dart';
import 'package:calculator_lite/UIElements/displayScreen.dart';
import 'package:calculator_lite/Backend/helperFunctions.dart';
import 'package:charcode/charcode.dart' as charcode;
import 'dart:math' as math;

class CalcParser {
  List<String> calculationString;
  CalcParser({this.calculationString});
  HelperFunctions helperFunctions = HelperFunctions();

  // List of constants for conditional checks.
  List<String> trigFunctions = ['sin', 'cos', 'tan', 'ln', 'log'];
  List<String> avoidFirstElement = [
    '+',
    '*',
    '/',
    FixedValues.divisionChar,
    FixedValues.multiplyChar,
    ')',
    '!',
    FixedValues.reciprocalChar,
    'mod',
    FixedValues.capChar,
    '%',
    FixedValues.squareChar,
    FixedValues.changeSignChar,
  ];

  // This function adds elements to displayScreen with formatting.
  List<String> addToExpression(String value) {
    if (calculationString.length != 0) {
      int lastIndex = calculationString.length - 1;
      String lastChar = calculationString[lastIndex];

      // Check if previous value is NOT an operator.
      if ((value.contains(FixedValues.minus) &&
              !lastChar.contains(FixedValues.minus)) ||
          !(helperFunctions.operations.contains(value) &&
              helperFunctions.operations.contains(lastChar))) {
        // Code for Square of Number.
        if (value.contains(FixedValues.squareChar))
          calculationString[lastIndex] = '$lastChar' + FixedValues.sup2;

        // Code for reciprocal button.
        else if (value.contains(FixedValues.reciprocalChar))
          reciprocalFunction();

        // Code for add bracket after following functions.

        else if (trigFunctions.contains(value))
          calculationString.add('$value(');

        // Code for cube root
        else if (value.contains(FixedValues.cubeRoot))
          calculationString
              .add(String.fromCharCodes([charcode.$sup3, charcode.$radic]));
        else if (value.contains(FixedValues.decimalChar))
          setDecimalChar();
        else if (value.contains(')'))
          addClosedBracket();

        // Code for +/- Option
        else if (value.contains(FixedValues.changeSignChar))
          setSign();

        // Factorial
        else if (['!', '%'].contains(value) ||
            helperFunctions.operations.contains(value)) {
          if (value.contains(FixedValues.minus) ||
              !(helperFunctions.randomList.contains(lastChar) ||
                  helperFunctions.operations.contains(lastChar)))
            calculationString.add(value);
        } else {
          calculationString.add(value);
        }
      }
    }
    // Following functions should not present in the first position.
    else if (!(avoidFirstElement.contains(value))) {
      // Check if only value present is NOT an operator.
      if (trigFunctions.contains(value))
        calculationString.add('$value(');
      else if (value.contains(FixedValues.decimalChar))
        calculationString.add('.');
      else
        calculationString.add(value);
    }
    return calculationString;
  }

  void addClosedBracket() {
    // This function adds closed bracket no more than what is required.
    String computerStr = calculationString.join();
    int count = '('.allMatches(computerStr).length;
    int count1 = ')'.allMatches(computerStr).length;
    if (count1 < count) calculationString.add(')');
  }

  List smartParseLast(int lastIndex, List<String> compStr) {
    double value = 0;
    int start = 0;
    try {
      // Parse numbers initially.
      start = helperFunctions.parseNumbersFromEnd(lastIndex, compStr);
      if (start != lastIndex) {
        value =
            double.tryParse(compStr.getRange(start + 1, lastIndex + 1).join());
      }

      // Run below code for Matching brackets
      else if (compStr[lastIndex].contains(')')) {
        start = helperFunctions.parseMatchingBrackets(lastIndex, compStr);
        List<String> temp = compStr.getRange(start, lastIndex + 1).toList();
        value = evalFunction(temp);
        start -=
            1; // Temp solution, i should be 1 low to keep left-most bracket as it will be removed during the process.
      }

      // Check for constants.
      else if (helperFunctions.constList.contains(compStr[lastIndex])) {
        start = helperFunctions.parseConstFromEnd(lastIndex, compStr);
        List<String> temp = compStr.getRange(start + 1, lastIndex + 1).toList();
        value = evalFunction(temp);
      }

      // Executes if there are no integers from beginning.
      else {
        start = helperFunctions.parseOperatorFromEnd(lastIndex, compStr);
        List<String> temp = compStr.getRange(start + 1, lastIndex + 1).toList();
        value = evalFunction(temp);
      }
    } catch (e) {}

    return [start, value];
  }

  void reciprocalFunction() {
    try {
      int lastIndex = calculationString.length - 1;
      if (!helperFunctions.randomList.contains(calculationString[lastIndex])) {
        List values = smartParseLast(lastIndex, calculationString);

        calculationString.removeRange(values[0] + 1, lastIndex + 1);
        values[1] = 1 / values[1];
        String valueStr = "";

        // Negative checks happens here
        if (values[1] >= 0)
          valueStr = DisplayScreen.formatNumber(values[1]);
        else {
          valueStr = DisplayScreen.formatNumber(values[1]);
          valueStr = valueStr.replaceAll('-', FixedValues.minus);
          valueStr = "(" + valueStr;
        }

        calculationString.insert(calculationString.length, valueStr);
      }
    }

    // Do nothing for exceptions.
    catch (e) {}
  }

  void setSign() {
    int lastIndex = calculationString.length - 1; // Get index of last char
    int i = helperFunctions.parseNumbersFromEnd(lastIndex, calculationString);

    // If it is equal to -1 then add sign directly as there are no operators at this point, only a number.
    if (i == -1)
      calculationString.insert(0, FixedValues.minus);

    // Check if i is not equal to last item in the array, meaning there are numbers beginning from the end.
    else if (i != lastIndex)
      insertSign(i);

    // If lastChar is closed bracket, do this matching function.
    else if (calculationString[lastIndex].contains(')')) {
      i = helperFunctions.parseMatchingBrackets(lastIndex, calculationString) -
          1;
      if (i != -1)
        insertSign(i);
      else
        calculationString.insert(0, FixedValues.minus);
    } else if (helperFunctions.constList
        .contains(calculationString[lastIndex])) {
      i = helperFunctions.parseConstFromEnd(lastIndex, calculationString);
      if (i != -1) insertSign(i);
    } else if (helperFunctions.randomList
        .contains(calculationString[lastIndex])) {
      i = helperFunctions.parseRandomFromEnd(lastIndex, calculationString);
      if (i != -1) insertSign(i);
    } else {
      i = helperFunctions.parseOperatorFromEnd(lastIndex, calculationString);
      if (i != -1)
        insertSign(i);
      else
        calculationString.insert(0, FixedValues.minus);
    }
  }

  void insertSign(int i) {
    switch (calculationString[i]) {
      case '(–':
        calculationString.removeAt(i);
        break;
      case '(':
        calculationString.insert(i + 1, FixedValues.minus);
        break;
      case '+':
        calculationString[i] = FixedValues.minus;
        break;
      case '–':
        if (i != 0 && !calculationString[i - 1].contains('('))
          calculationString[i] = '+';
        else
          calculationString.removeAt(
              i); // Just remove - instead of adding + when position is at 0.
        break;
      default:
        calculationString.insert(i + 1, '(${FixedValues.minus}');
    }
  }

  void setDecimalChar() {
    int index = helperFunctions.parseNumbersFromEnd(
        calculationString.length - 1, calculationString);
    bool count = calculationString.join().contains('.', index + 1);
    if (!count) calculationString.add('.');
  }

  // This function called from CalcTab.dart after calling addToExpression.
  double getValue() => evalFunction(calculationString);

  double evalFunction(List<String> calcStr) {
    try {
      Parser p = Parser();
      String comptStr = computerString(calcStr);
      Expression exp = p.parse(
          comptStr); // evalFunction is executed first, internally function asks for computerString.
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);
      return eval;
    } catch (e) {
      return null;
    }
  }

  String computerString(List<String> calcStr) {
    // Go through Custom Functions
    List<String> tempString = List.from(calcStr);

    // add * to respective positions.
    if (tempString.length > 1) {
      for (int i = tempString.length - 1; i > 0; i--) {
        int lastIndex = i;
        String lastChar = tempString[lastIndex];
        String lastButOne = tempString[lastIndex - 1];

        if (lastButOne == '.' &&
            !helperFunctions.numbersList.contains(lastChar)) {
          tempString[lastIndex - 1] = '.0';
        }
        // check pre-value
        else if (helperFunctions.numbersList.contains(lastButOne)) {
          // check post value
          if (['sin(', 'cos(', 'tan(', 'ln(', 'log(', 'e', '(', FixedValues.pi]
              .contains(lastChar))
            tempString.insert(lastIndex, FixedValues.multiplyChar);
        } else if ([
          '%',
          'e',
          FixedValues.pi,
          ')',
          '!',
          FixedValues.sup2
        ].contains(lastButOne)) if ([
              'sin(',
              'cos(',
              'tan(',
              'ln(',
              'log(',
              'e',
              FixedValues.pi
            ].contains(lastChar) ||
            helperFunctions.numbersList.contains(lastChar)) {
          tempString.insert(lastIndex, FixedValues.multiplyChar);
        }
      }
    }

    String sym = "!";
    int symTOTAL = sym.allMatches(tempString.join()).length;
    while (symTOTAL > 0) {
      tempString = getFactorOrPercent(tempString, sym);
      symTOTAL -= 1;
    }

    sym = "%";
    symTOTAL = sym.allMatches(tempString.join()).length;
    while (symTOTAL > 0) {
      tempString = getFactorOrPercent(tempString, sym);
      symTOTAL -= 1;
    }

    String computerStr = tempString.join();
    // Replace with strings that dart/math_exp package can understand.
    computerStr = computerStr.replaceAll(FixedValues.divisionChar, '/');
    computerStr = computerStr.replaceAll(FixedValues.multiplyChar, '*');
    computerStr = computerStr.replaceAll(FixedValues.minus, '-');
    computerStr = computerStr.replaceAll(FixedValues.pi, math.pi.toString());
    computerStr = computerStr.replaceAll('e', math.e.toString());
    computerStr = computerStr.replaceAll(FixedValues.sup2, '^2');
    computerStr = computerStr.replaceAll('mod', '%');
    computerStr = computerStr.replaceAll('log(', 'log(10,');

    // Attach parentheses automatically.
    int countOpen = '('.allMatches(computerStr).length;
    int countClosed = ')'.allMatches(computerStr).length;
    if (countOpen != countClosed) {
      int toAdd = countOpen - countClosed;
      for (int i = 0; i < toAdd; i++) computerStr = computerStr + ')';
    }
    return computerStr;
  }

  // Factorial Function
  List<String> getFactorOrPercent(List<String> computerStr, String char) {
    int index = computerStr.indexOf(char);
    computerStr.removeAt(index);
    int count = index - 1;
    List data = smartParseLast(count, computerStr);
    count = data[0];
    double val = data[1];
    if (char.contains('!') && (val % 1 == 0 && val >= 0)) {
      BigInt getNum = BigInt.from(val);
      BigInt factNum;

      // Catch overloaded values here.
      try {
        factNum = helperFunctions.factorial(getNum);
        computerStr.removeRange(count + 1, index);
        computerStr.insert(count + 1, '${factNum.toString()}');
      } catch (StackOverflowError) {
        computerStr = ['0/0']; // Make it NaN this way.
      }

      return computerStr;
    }

    // For % below code.
    else if (char.contains("%")) {
      List<String> prev = computerStr.getRange(0, count).toList();
      double csk = evalFunction(prev);
      double first = data[1];

      List data2 = smartParseLast(count - 1, computerStr);
      double second = data2[1];
      second = csk;
      String exp;

      if ((index < computerStr.length) &&
          ![FixedValues.minus, '+'].contains(computerStr[index])) {
        exp = '${(first / 100)}';
        computerStr.replaceRange(count + 1, count + 2, [exp]);
      } else if ((index - 1 > -1) &&
          !helperFunctions.numbersList.contains(computerStr[index - 1])) {
        exp = '${(second * first / 100)}';
        computerStr.replaceRange(count + 1, index, [exp]);
      } else if ([FixedValues.minus, '+'].contains(computerStr[count])) {
        exp = '$second${computerStr[count]}${(second * first / 100)}';
        computerStr.replaceRange(0, count + 2, [exp]);
      } else {
        exp = '($second${computerStr[count]}${(first / 100)})';
        computerStr.replaceRange(0, count + 2, [exp]);
      }
      return computerStr;
    } else
      return null;
  }
}
