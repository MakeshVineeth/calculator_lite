import 'package:math_expressions/math_expressions.dart';
import 'package:calculator_lite/fixedValues.dart';
import 'package:calculator_lite/UIElements/displayScreen.dart';
import 'dart:math' as math;
import 'package:charcode/charcode.dart' as charcode;

class CalcParser {
  List<String> calculationString;
  CalcParser({this.calculationString});
  List<String> operations = [
    FixedValues.divisionChar,
    FixedValues.multiplyChar,
    FixedValues.minus,
    '*',
    '+',
    '-',
    '/',
    '^'
  ];
  List<String> numbersList = [
    '0',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '.',
    FixedValues.decimalChar
  ];
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
      if (!(operations.contains(value) && operations.contains(lastChar))) {
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
        else
          calculationString.add(value);
      }

      // add * to respective positions.
      if (calculationString.length > 1) {
        lastIndex = calculationString.length - 1;
        lastChar = calculationString[lastIndex];

        String lastButOne = calculationString[lastIndex - 1];
        // check pre-value
        if ((numbersList.contains(lastButOne) ||
            ['%', 'e', FixedValues.pi, ')', '!', FixedValues.sup2]
                .contains(lastButOne))) {
          // check post value
          if (['sin(', 'cos(', 'tan(', 'ln(', 'log(', 'e', FixedValues.pi]
              .contains(lastChar)) {
            // should keep number parsing two times
            calculationString.insert(lastIndex, FixedValues.multiplyChar);
          }
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

  void reciprocalFunction() {
    try {
      int lastIndex = calculationString.length - 1;
      int i = 0;
      double value = 0;

      // Parse numbers initially.
      i = parseNumbersFromEnd();
      if (i != lastIndex) {
        value = double.tryParse(
            calculationString.join().substring(i + 1, lastIndex + 1));
      }

      // Run below code for Matching brackets
      else if (calculationString[lastIndex].contains(')')) {
        i = parseMatchingBrackets();
        List<String> temp =
            calculationString.getRange(i, lastIndex + 1).toList();
        value = evalFunction(temp);
        i -=
            1; // Temp solution, i should be 1 low for counting left-most bracket which will be removed using below-most code.
      }

      // Executes if there are no integers from beginning.
      else {
        i = parseOperatorFromEnd();
        List<String> temp =
            calculationString.getRange(i + 1, lastIndex + 1).toList();
        value = evalFunction(temp);
      }

      calculationString.removeRange(i + 1, lastIndex + 1);
      value = 1 / value;
      String valueStr = "";

      // Negative checks happens here
      if (value >= 0)
        valueStr = DisplayScreen.formatNumber(value);
      else {
        valueStr = DisplayScreen.formatNumber(value);
        valueStr = valueStr.replaceAll('-', FixedValues.minus);
        valueStr = "(" + valueStr;
      }

      calculationString.insert(calculationString.length, valueStr);
    }

    // Do nothing for exceptions.
    catch (e) {}
  }

  int parseNumbersFromEnd() {
    int i = calculationString.length - 1;
    // Parse the string from the end to start. Break immediately if any symbol found other than integers.
    for (; i >= 0; i--) if (!numbersList.contains(calculationString[i])) break;
    return i;
  }

  int parseOperatorFromEnd() {
    int i = calculationString.length - 1;
    for (; i >= 0; i--) if (operations.contains(calculationString[i])) break;
    return i;
  }

  void setSign() {
    int lastIndex = calculationString.length - 1; // Get index of last char
    int i = parseNumbersFromEnd();

    // If it is equal to -1 then add sign directly as there are no operators at this point, only a number.
    if (i == -1)
      calculationString.insert(0, FixedValues.minus);

    // Check if i is not equal to last item in the array, meaning there are numbers beginning from the end.
    else if (i != lastIndex)
      insertSign(i);

    // If lastChar is closed bracket, do this matching function.
    else if (calculationString[lastIndex].contains(')')) {
      i = parseMatchingBrackets() - 1;
      if (i != -1)
        insertSign(i);
      else
        calculationString.insert(0, FixedValues.minus);
    }

    // Executes if there is an operator from the end, gets last available operator in calculator string and insert a sign there.
    else {
      i = parseOperatorFromEnd();
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
        if (i != 0)
          calculationString[i] = '+';
        else
          calculationString.removeAt(
              i); // Just remove - instead of adding + when position is at 0.
        break;
      default:
        calculationString.insert(i + 1, '(${FixedValues.minus}');
    }
  }

  int parseMatchingBrackets() {
    int lastIndex = calculationString.length - 1;
    int count = lastIndex;
    int openBrace = 0;
    int closedBrace = 0;
    for (; count >= 0; --count) {
      if (calculationString[count].contains(')')) closedBrace += 1;
      if (calculationString[count].contains('(')) openBrace += 1;
      if (openBrace == closedBrace) break;
    }
    return count;
  }

  void setDecimalChar() {
    int index = parseNumbersFromEnd();
    bool count = calculationString.join().contains('.', index + 1);
    if (!count) calculationString.add('.');
  }

  BigInt factorial(BigInt n) {
    if (n < BigInt.from(0)) throw ('Negative numbers are not allowed.');
    return n <= BigInt.from(1)
        ? BigInt.from(1)
        : n * factorial(n - BigInt.from(1));
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
    String computerStr = calcStr.join();
    computerStr = computerStr.replaceAll(FixedValues.divisionChar, '/');
    computerStr = computerStr.replaceAll(FixedValues.multiplyChar, '*');
    computerStr = computerStr.replaceAll(FixedValues.minus, '-');
    computerStr = computerStr.replaceAll(FixedValues.pi, math.pi.toString());
    computerStr = computerStr.replaceAll('e', math.e.toString());
    computerStr = computerStr.replaceAll(FixedValues.sup2, '^2');
    computerStr = computerStr.replaceAll('mod', '%');

    // Factorial Function
    int total = '!'.allMatches(computerStr).length;
    while (total > 0) {
      int index = computerStr.indexOf('!');
      int count = index - 1;
      for (; count >= 0; count--)
        if (!numbersList.contains(computerStr[count])) break;
      String numberList = computerStr.substring(count + 1,
          index); // i + 1 because one non-int char will be added in for loop and thus must be trimmed.

      if (!numberList.contains('.')) {
        BigInt getNum = BigInt.tryParse(numberList);
        BigInt factNum = factorial(getNum);
        computerStr = computerStr.replaceRange(count + 1, index + 1,
            '(${factNum.toString()})'); // index + 1 to replace the factorial symbol.
      }
      total -= 1;
    }

    // Attach parentheses automatically.
    int countOpen = '('.allMatches(computerStr).length;
    int countClosed = ')'.allMatches(computerStr).length;
    if (countOpen != countClosed) {
      int toAdd = countOpen - countClosed;
      for (int i = 0; i < toAdd; i++) computerStr = computerStr + ')';
    }
    return computerStr;
  }
}
