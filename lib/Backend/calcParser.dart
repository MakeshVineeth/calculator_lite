import 'package:math_expressions/math_expressions.dart';
import 'package:calculator_lite/fixedValues.dart';
import 'package:calculator_lite/UIElements/displayScreen.dart';

class CalcParser {
  List<String> calculationString;
  CalcParser({this.calculationString});
  List<String> operations = [
    FixedValues.divisionChar,
    FixedValues.multiplyChar,
    '*',
    '+',
    '-',
    '/'
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
  List<String> addToExpression(String value) {
    if (calculationString.length != 0) {
      int lastIndex = calculationString.length - 1;
      String lastChar = calculationString[lastIndex];
      // Check if previous value is NOT an operator.
      if (!(operations.contains(value) && lastChar.contains(value))) {
        // Code for Square of Number.
        if (value.contains(FixedValues.squareChar))
          calculationString[lastIndex] = '$lastChar\u00B2';

        // Code for reciprocal button.
        else if (value.contains(FixedValues.reciprocalChar))
          reciprocalFunction();

        // Code for add bracket after following functions.

        else if (trigFunctions.contains(value))
          calculationString.add('$value(');

        // Code for cube root
        else if (value.contains(FixedValues.cubeRoot))
          calculationString.add('\u00B3√');
        else if (value.contains(FixedValues.decimalChar))
          calculationString.add('.');
        else if (value.contains(')'))
          addClosedBracket();

        // Code for +/- Option
        else if (value.contains(FixedValues.changeSignChar))
          setSign();
        else
          calculationString.add(value);
      }
    }
    // Following functions should not present in the first position.
    else if (!({
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
    }.contains(value))) {
      // Check if only value present is NOT an operator.

      if (trigFunctions.contains(value))
        calculationString.add('$value(');
      else
        calculationString.add(value);
    }

    if (calculationString.length > 1) {
      // add * to respective positions.
      int lastIndex = calculationString.length - 1;

      // check pre-value
      if ((numbersList.contains(calculationString[lastIndex - 1]) ||
          ['%', 'e', 'π', ')', '!', '\u00B2']
              .contains(calculationString[lastIndex - 1]))) {
        // check post value
        if (calculationString[lastIndex].contains('tan(') ||
            ['e', 'π'].contains(calculationString[lastIndex])) {
          calculationString.insert(lastIndex, '*');
        }
      }
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
      int i = parseNumbersFromEnd();
      double value = 0;
      if (i != lastIndex) {
        // parse numbers
        value = double.tryParse(
            calculationString.join().substring(i + 1, lastIndex + 1));
      } else {
        // Executes if there are no integers from beginning.
        i = parseOperatorFromEnd();
        List<String> temp =
            calculationString.getRange(i + 1, lastIndex + 1).toList();
        value = evalFunction(temp);
      }

      calculationString.removeRange(i + 1, lastIndex + 1);
      calculationString.insert(
          calculationString.length, DisplayScreen.formatNumber(1 / value));
    } catch (e) {}
  }

  int parseNumbersFromEnd() {
    int i = calculationString.length - 1;
    // parse the string from the end to start. Break immediately if any symbol found other than integers.
    for (; i >= 0; i--) if (!numbersList.contains(calculationString[i])) break;
    return i;
  }

  int parseOperatorFromEnd() {
    int i = calculationString.length - 1;
    for (; i >= 0; i--) if (operations.contains(calculationString[i])) break;
    return i;
  }

  void setSign() {
    // Not very advanced but just a basic function to insert minus sign wherever possible

    int lastIndex = calculationString.length - 1; // Get index of last char
    int i = parseNumbersFromEnd();

    if (i == -1)
      // if it is equal to -1 then add sign directly as there are no operators at this point, only a number.
      calculationString.insert(i + 1, '-');

    // check if i is not equal to last item in the array, meaning there are numbers beginning from the end.
    else if (i != lastIndex)
      switch (calculationString[i]) {
        case '(-':
          calculationString.removeAt(i);
          break;
        case '(':
          calculationString.insert(i + 1, '-');
          break;
        case '+':
          calculationString[i] = '-';
          break;
        case '-':
          if (i != 0)
            calculationString[i] = '+';
          else
            calculationString.removeAt(
                i); // Just remove - instead of adding + when position is at 0.
          break;
        default:
          calculationString.insert(i + 1, '(-');
      }

    // executes if there is an operator from the end, gets last available operator in calculator string and insert a sign there.
    else {
      i = parseOperatorFromEnd();
      calculationString.insert(i + 1, '(-');
    }
  }

  double getValue() {
    return evalFunction(calculationString);
  }

  double evalFunction(List<String> calcStr) {
    try {
      Parser p = Parser();
      Expression exp = p.parse(computerString(calcStr));
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
    computerStr = computerStr.replaceAll('\u00B2', '^2');

    // attach parentheses automatically.
    int count = '('.allMatches(computerStr).length;
    int count1 = ')'.allMatches(computerStr).length;
    if (count != count1) {
      int toAdd = count - count1;
      for (int i = 0; i < toAdd; i++) computerStr = computerStr + ')';
    }

    return computerStr;
  }
}
