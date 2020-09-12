import 'package:math_expressions/math_expressions.dart';
import 'package:calculator_lite/fixedValues.dart';

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

  List<String> addToExpression(String value) {
    // Code for Square of Number.
    if (value.contains(FixedValues.squareChar)) {
      int lastIndex = calculationString.length - 1;
      String lastChar = calculationString[lastIndex];
      calculationString[lastIndex] = '$lastChar\u00B2';
    }
    // Code for add bracket after following functions.
    else if (value.contains('sin') ||
        value.contains('cos') ||
        value.contains('tan') ||
        value.contains('ln') ||
        value.contains('log')) {
      calculationString.add('$value(');
    }
    // Code for cube root
    else if (value.contains(FixedValues.cubeRoot)) {
      calculationString.add('\u00B3√');
    } else if (value.contains(FixedValues.decimalChar)) {
      calculationString.add('.');
    }
    // Code for +/- Option
    else if (value.contains(FixedValues.changeSignChar)) {
      setSign();
    } else {
      calculationString.add(value);
    }

    return calculationString;
  }

  void setSign() {
    // Not very advanced but just a basic function to insert or revert signs wherever possible.4

    int lastChar = calculationString.length - 1;
    bool found = false;
    int i = 0;

    for (i = lastChar; i >= 0; i--) {
      if ({'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'}
              .contains(calculationString[i]) ==
          false) {
        break;
      }
    }

    if (i != lastChar) {
      calculationString.insert(i + 1, '(-');
    } else {
      // To get last operator and insert a sign there.
      for (i = lastChar; i >= 0; i--) {
        if (operations.contains(calculationString[i])) {
          found = true;
          break;
        }
      }

      if (found) {
        calculationString.insert(i + 1, '(-');
      }
    }
  }

  double getValue() {
    try {
      Parser p = Parser();
      Expression exp = p.parse(computerString());
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);
      return eval;
    } catch (e) {
      return null;
    }
  }

  String computerString() {
    String computerStr = calculationString.join();
    computerStr = computerStr.replaceAll(FixedValues.divisionChar, '/');
    computerStr = computerStr.replaceAll(FixedValues.multiplyChar, '*');
    computerStr = computerStr.replaceAll('\u00B2', '^2');
    return computerStr;
  }
}
