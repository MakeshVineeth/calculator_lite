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
    // Not very advanced but just a basic function to insert minus sign wherever possible

    int lastChar = calculationString.length - 1;
    bool found = false;
    int i = 0;

    // parse the string from the end to start. Break immediately if any symbol found other than integers.
    for (i = lastChar; i >= 0; i--) {
      if ({'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'}
              .contains(calculationString[i]) ==
          false) {
        break;
      }
    }

    // check if i is not equal to last item in the array, meaning there are numbers beginning from the end.
    if (i != lastChar) {
      // pre-check if i is -1 and avoid run-time errors.
      if (i != -1) {
        if (calculationString[i].contains('(')) {
          calculationString.insert(i + 1, '-');
        } else if (calculationString[i].contains('+')) {
          calculationString[i] = '-';
        } else if (calculationString[i].contains('-')) {
          calculationString[i] = '-';
        } else {
          calculationString.insert(i + 1, '(-');
        }
      } else {
        // if it indeed equal to -1 then add sign directly as there are no operators at this point, only a number.
        calculationString.insert(i + 1, '-');
      }
    } else {
      // executes if there is an operator from the end, gets last available operator in calculator string and insert a sign there.
      for (i = lastChar; i >= 0; i--) {
        if (operations.contains(calculationString[i])) {
          found =
              true; // sets to true and can be checked if found and add the sign.
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
