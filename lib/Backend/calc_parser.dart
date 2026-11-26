import 'dart:math' as math;

import 'package:calculator_lite/Backend/helper_functions.dart';
import 'package:calculator_lite/UIElements/display_screen.dart';
import 'package:calculator_lite/fixed_values.dart';
import 'package:math_expressions/math_expressions.dart';

class SmartParseResult {
  final int start;
  final double value;

  const SmartParseResult({required this.start, required this.value});
}

class CalcParser {
  List<String> calculationString;
  String currentMetric;

  CalcParser({required this.calculationString, required this.currentMetric});

  final HelperFunctions helperFunctions = const HelperFunctions();

  // List of constants for conditional checks.
  final List<String> trigFunctions = [
    'sin',
    'cos',
    'tan',
    'ln',
    'log',
    'sin⁻¹',
    'cos⁻¹',
    'tan⁻¹'
  ];

  final List<String> trigs = [
    'sin(',
    'cos(',
    'tan(',
    'sin⁻¹(',
    'cos⁻¹(',
    'tan⁻¹('
  ];

  final List<String> avoidFirstElement = [
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
    FixedValues.cubeChar,
    FixedValues.changeSignChar,
  ];

  // This function adds elements to displayScreen with formatting.
  List<String> addToExpression(String value) {
    if (calculationString.isNotEmpty) {
      final int lastIndex = calculationString.length - 1;
      final String lastChar = calculationString[lastIndex];

      // Disallow binary operators after open brackets or functions (e.g. '(+', '√(mod', 'sin(*')
      if (lastChar == '(' || lastChar.endsWith('(')) {
        if (value != FixedValues.minus &&
            helperFunctions.operations.contains(value)) {
          return calculationString;
        }
      }

      // Disallow postfix operators (!, %, ², ³) after operators, open brackets, or '.'
      if (['!', '%', FixedValues.squareChar, FixedValues.cubeChar]
          .contains(value)) {
        if (helperFunctions.operations.contains(lastChar) ||
            lastChar == '(' ||
            lastChar.endsWith('(') ||
            lastChar == '.') {
          return calculationString;
        }
      }

      // Handle operator replacement when consecutive operators are entered
      if (helperFunctions.operations.contains(lastChar) &&
          helperFunctions.operations.contains(value)) {
        // Allow unary minus after binary multiplication, division, or power (e.g. 5 × -3)
        if (value == FixedValues.minus &&
            [FixedValues.multiplyChar, FixedValues.divisionChar, '^']
                .contains(lastChar)) {
          calculationString.add(value);
          return calculationString;
        }

        // If lastChar was a unary minus following another operator (e.g. '×', '-'),
        // and a new operator is pressed, remove the minus so the base operator is replaced
        if (lastChar == FixedValues.minus &&
            calculationString.length > 1 &&
            helperFunctions.operations
                .contains(calculationString[calculationString.length - 2])) {
          calculationString.removeLast();
        }

        // Replace the previous operator with the new one
        calculationString[calculationString.length - 1] = value;
        return calculationString;
      }

      // If user inputs '.' immediately after an operator or open bracket, format as '0.'
      if (value == '.') {
        if (helperFunctions.operations.contains(lastChar) ||
            lastChar == '(' ||
            lastChar.endsWith('(')) {
          calculationString.add('0.');
          return calculationString;
        }
      }

      // Postfix operators: if a number, constant, or function is entered immediately
      // after a closed bracket, factorial, percentage, superscript, or constant,
      // auto-insert multiplication (e.g. '1!5' -> '1! × 5', '5%5' -> '5% × 5', '(2)5' -> '(2) × 5').
      final bool isLastPostfix = [
        ')',
        '!',
        '%',
        FixedValues.sup2,
        FixedValues.sup3,
        FixedValues.pi,
        'e'
      ].contains(lastChar);

      final bool isNextOperand = helperFunctions.numbersList.contains(value) ||
          helperFunctions.constList.contains(value) ||
          trigFunctions.contains(value) ||
          [
            FixedValues.root,
            FixedValues.cubeRoot,
            'eˣ',
            '𝟏𝟬ˣ',
            '('
          ].contains(value);

      if (isLastPostfix && isNextOperand) {
        calculationString.add(FixedValues.multiplyChar);
      }

      final bool case1 = (value.contains(FixedValues.minus) &&
          !lastChar.contains(FixedValues.minus));
      final bool case2 = !(helperFunctions.operations.contains(value) &&
          helperFunctions.operations.contains(lastChar));

      if (case1 || case2) {
        if (value.contains(FixedValues.reciprocalChar)) {
          reciprocalFunction();
        } else if (value.contains(FixedValues.minus)) {
          if (!([FixedValues.cubeRootSym, FixedValues.root, FixedValues.minus]
              .contains(lastChar))) {
            calculationString.add(value);
          }
        } else if (trigFunctions.contains(value)) {
          calculationString.add('$value(');
        } else if ([FixedValues.squareChar, FixedValues.cubeChar].contains(value)) {
          if ([')', FixedValues.pi, 'e'].contains(lastChar) ||
              helperFunctions.numbersList.contains(lastChar) ||
              [FixedValues.sup2, FixedValues.sup3].contains(lastChar)) {
            if (value.contains(FixedValues.squareChar)) {
              calculationString.add(FixedValues.sup2);
            } else {
              calculationString.add(FixedValues.sup3);
            }
          }
        } else if (value == 'eˣ') {
          calculationString.addAll(['e', '^']);
        } else if (value == '𝟏𝟬ˣ') {
          calculationString.addAll(['1', '0', '^']);
        } else if (value == FixedValues.cubeRoot) {
          calculationString.addAll([FixedValues.cubeRootSym, '(']);
        } else if (value == FixedValues.root) {
          calculationString.addAll([FixedValues.root, '(']);
        } else if (value == '.') {
          setDecimalChar();
        } else if (value == FixedValues.changeSignChar) {
          setSign();
        } else if (value == ')') {
          addClosedBracket();
        } else {
          calculationString.add(value);
        }
      }
    } else {
      if (!avoidFirstElement.contains(value)) {
        if (value.startsWith(FixedValues.changeSignChar)) {
          calculationString.add(FixedValues.minus);
        } else if (trigFunctions.contains(value)) {
          calculationString.add('$value(');
        } else if (value == 'eˣ') {
          calculationString.addAll(['e', '^']);
        } else if (value == '𝟏𝟬ˣ') {
          calculationString.addAll(['1', '0', '^']);
        } else if (value == FixedValues.cubeRoot) {
          calculationString.addAll([FixedValues.cubeRootSym, '(']);
        } else if (value == FixedValues.root) {
          calculationString.addAll([FixedValues.root, '(']);
        } else if (value == '.') {
          calculationString.add('0.');
        } else {
          calculationString.add(value);
        }
      }
    }

    return calculationString;
  }

  void addClosedBracket() {
    final String lastChar = calculationString.last;
    final String computerStr = calculationString.join();
    final int count = '('.allMatches(computerStr).length;
    final int count1 = ')'.allMatches(computerStr).length;
    if (count1 < count) {
      if (!helperFunctions.operations.contains(lastChar) &&
          lastChar != '(' &&
          !lastChar.endsWith('(') &&
          lastChar != '.') {
        calculationString.add(')');
      }
    }
  }

  SmartParseResult smartParseLast(int lastIndex, List<String> compStr) {
    double value = 0;
    int start = 0;
    try {
      start = helperFunctions.parseNumbersFromEnd(lastIndex, compStr);
      if (start != lastIndex) {
        value =
            double.tryParse(compStr.getRange(start + 1, lastIndex + 1).join()) ?? 0;
      } else if (compStr[lastIndex].contains(')')) {
        start = helperFunctions.parseMatchingBrackets(lastIndex, compStr);
        final List<String> temp = compStr.getRange(start, lastIndex + 1).toList();
        value = evalFunction(temp);
        start -= 1;
      } else if (helperFunctions.constList.contains(compStr[lastIndex])) {
        start = helperFunctions.parseConstFromEnd(lastIndex, compStr);
        final List<String> temp = compStr.getRange(start + 1, lastIndex + 1).toList();
        value = evalFunction(temp);
      } else if (['%', '!'].contains(compStr[lastIndex])) {
        start = 0;
        List<String> temp = compStr.getRange(start, lastIndex).toList();
        final SmartParseResult getData = smartParseLast(temp.length - 1, temp);
        start = getData.start;
        temp = compStr.getRange(start + 1, lastIndex + 1).toList();
        value = evalFunction(temp);
      } else {
        start = helperFunctions.parseOperatorFromEnd(lastIndex, compStr);
        final List<String> temp = compStr.getRange(start + 1, lastIndex + 1).toList();
        value = evalFunction(temp);
      }
    } catch (_) {}

    return SmartParseResult(start: start, value: value);
  }

  void reciprocalFunction() {
    try {
      if (calculationString.isEmpty) return;
      final int lastIndex = calculationString.length - 1;
      if (!helperFunctions.randomList.contains(calculationString[lastIndex])) {
        final SmartParseResult values =
            smartParseLast(lastIndex, calculationString);

        if (values.value == 0 ||
            values.value.isNaN ||
            values.value.isInfinite) {
          return;
        }

        final double reciprocal = 1 / values.value;
        if (reciprocal.isNaN || reciprocal.isInfinite) {
          return;
        }

        calculationString.removeRange(values.start + 1, lastIndex + 1);
        String valueStr = DisplayScreen.formatNumber(reciprocal);
        valueStr = valueStr.replaceAll('-', FixedValues.minus);

        if (calculationString.isNotEmpty) {
          calculationString.addAll(['(', ...valueStr.split(''), ')']);
        } else {
          calculationString.addAll([...valueStr.split('')]);
        }
      }
    } catch (_) {}
  }

  void setSign() {
    final int lastIndex = calculationString.length - 1;
    final int i = helperFunctions.parseNumbersFromEnd(lastIndex, calculationString);

    if (i == -1) {
      if (calculationString.isNotEmpty &&
          (calculationString.first == '-' ||
              calculationString.first == FixedValues.minus)) {
        calculationString.removeAt(0);
      } else {
        calculationString.insert(0, FixedValues.minus);
      }
    } else if (calculationString[i] == '-' ||
        calculationString[i] == FixedValues.minus) {
      calculationString.removeAt(i);
    } else if (calculationString[i] == '(') {
      if (i > 0 &&
          (calculationString[i - 1] == '-' ||
              calculationString[i - 1] == FixedValues.minus)) {
        calculationString.removeAt(i - 1);
      } else {
        calculationString.insert(i, FixedValues.minus);
      }
    } else if (calculationString[i] == '+') {
      calculationString[i] = FixedValues.minus;
    } else {
      calculationString.insertAll(i + 1, ['(', (FixedValues.minus)]);
    }
  }

  void setDecimalChar() {
    final int index = helperFunctions.parseNumbersFromEnd(
        calculationString.length - 1, calculationString);
    final List<String> getCompareStr = calculationString
        .getRange(index + 1, calculationString.length)
        .toList();
    final bool count = getCompareStr.join().contains('.');
    if (!count) calculationString.add('.');
  }

  Future<double> getValue() =>
      Future<double>.value(evalFunction(calculationString));

  double evalFunction(List<String> calcStr) {
    try {
      final GrammarParser p = GrammarParser();
      final String comptStr = computerString(calcStr);
      final Expression exp = p.parse(comptStr);
      final ContextModel cm = ContextModel();
      final dynamic evalResult = exp.evaluate(EvaluationType.REAL, cm);
      final double eval = evalResult is num ? evalResult.toDouble() : double.nan;

      return eval;
    } catch (_) {
      return double.nan;
    }
  }

  String computerString(List<String> calcStr) {
    List<String> tempString = List.from(calcStr);

    if (tempString.length > 1) {
      for (int i = tempString.length - 1; i > 0; i--) {
        final int lastIndex = i;
        final String lastChar = tempString[lastIndex];
        final String lastButOne = tempString[lastIndex - 1];

        if (lastButOne == '.' &&
            !helperFunctions.numbersList.contains(lastChar)) {
          tempString[lastIndex - 1] = '.0';
        } else if (helperFunctions.numbersList.contains(lastButOne)) {
          if ([
            'sin(',
            'cos(',
            'tan(',
            'ln(',
            'log(',
            'sin⁻¹(',
            'cos⁻¹(',
            'tan⁻¹(',
            'e',
            '(',
            FixedValues.pi,
            FixedValues.root,
            FixedValues.cubeRootSym
          ].contains(lastChar)) {
            tempString.insert(lastIndex, FixedValues.multiplyChar);
          }
        } else if ([
              '%',
              'e',
              FixedValues.pi,
              ')',
              '!',
              FixedValues.sup2,
              FixedValues.sup3
            ].contains(lastButOne) &&
            ([
                  'sin(',
                  'cos(',
                  'tan(',
                  'ln(',
                  'log(',
                  'sin⁻¹(',
                  'cos⁻¹(',
                  'tan⁻¹(',
                  'e',
                  '(',
                  FixedValues.pi
                ].contains(lastChar) ||
                helperFunctions.numbersList.contains(lastChar))) {
          tempString.insert(lastIndex, FixedValues.multiplyChar);
        }
      }
    }

    tempString = helperFunctions.replaceExp(tempString);

    while (tempString.where((value) => value == FixedValues.root).isNotEmpty) {
      tempString = getRoot(tempString, FixedValues.root);
    }

    while (tempString
        .where((value) => value == FixedValues.cubeRootSym)
        .isNotEmpty) {
      tempString = getRoot(tempString, FixedValues.cubeRootSym);
    }

    while (tempString.where((value) => value == '!').isNotEmpty) {
      tempString = getFactorOrPercent(tempString, '!');
    }

    while (tempString.where((value) => value == '%').isNotEmpty) {
      tempString = getFactorOrPercent(tempString, '%');
    }

    String computerStr = tempString.join();
    final int countOpen = '('.allMatches(computerStr).length;
    final int countClosed = ')'.allMatches(computerStr).length;
    if (countOpen != countClosed) {
      final int toAdd = countOpen - countClosed;
      for (int i = 0; i < toAdd; i++) {
        tempString.add(')');
      }
    }

    if (currentMetric == 'DEG') {
      while ((tempString.where((item) => trigs.contains(item))).isNotEmpty) {
        for (int count = 0; count < tempString.length; count++) {
          if (trigs.contains(tempString[count])) {
            int braceCount = count;
            int openBrace = 0;
            int closedBrace = 0;
            for (; braceCount < tempString.length; braceCount++) {
              if (tempString[braceCount].contains('(')) openBrace += 1;
              if (tempString[braceCount].contains(')')) closedBrace += 1;
              if (openBrace == closedBrace) break;
            }
            final List<String> temp =
                tempString.getRange(count + 1, braceCount).toList();
            final double angle = evalFunction(temp);
            final double degVal =
                helperFunctions.getDegValue(tempString, count, angle);
            String replaceThis =
                degVal == double.infinity ? '1/0' : degVal.toString();
            replaceThis = degVal.isNaN ? '0/0' : replaceThis;
            tempString.replaceRange(count, braceCount + 1, [replaceThis]);
            break;
          }
        }
      }
    }

    if (tempString.isNotEmpty && tempString.last == '.') {
      tempString[tempString.length - 1] = '.0';
    }

    computerStr = tempString.join();
    computerStr = computerStr.replaceAll(FixedValues.divisionChar, '/');
    computerStr = computerStr.replaceAll(FixedValues.multiplyChar, '*');
    computerStr = computerStr.replaceAll(FixedValues.minus, '-');
    computerStr = computerStr.replaceAll(FixedValues.pi, math.pi.toString());
    computerStr = computerStr.replaceAll(FixedValues.sup2, '^2');
    computerStr = computerStr.replaceAll(FixedValues.sup3, '^3');
    computerStr = computerStr.replaceAll('mod', '%');
    computerStr = computerStr.replaceAll('log(', 'log(10,');
    computerStr = computerStr.replaceAll('sin⁻¹(', 'arcsin(');
    computerStr = computerStr.replaceAll('cos⁻¹(', 'arccos(');
    computerStr = computerStr.replaceAll('tan⁻¹(', 'arctan(');

    return computerStr;
  }

  List<String> getRoot(List<String> computerStr, String char) {
    final int index = computerStr.indexOf(char);
    if (index != -1) {
      int count = index + 1;

      if (index < computerStr.length - 1 &&
          (computerStr[count].contains('('))) {
        int openBrace = 0;
        int closedBrace = 0;
        for (; count < computerStr.length; count++) {
          if (computerStr[count].contains('(')) openBrace += 1;
          if (computerStr[count].contains(')')) closedBrace += 1;
          if (openBrace == closedBrace) {
            count += 1;
            break;
          }
        }
      } else {
        for (; count < computerStr.length; count++) {
          if (helperFunctions.operations.contains(computerStr[count]) ||
              trigs.contains(computerStr[count]) ||
              [
                '%',
                '!',
                'mod',
                FixedValues.sup2,
                FixedValues.sup3,
                'log(',
                'ln('
              ].contains(computerStr[count])) {
            break;
          }
        }
      }

      final List<String> valStr = computerStr.getRange(index + 1, count).toList();
      final double val = evalFunction(valStr);
      if (val < 0) {
        if (char == FixedValues.root) {
          computerStr = ['0/0'];
        } else {
          final double absVal = val.abs();
          final List<String> replaceRoot = ['(-(nrt(3, $absVal)))'];
          if (index == 0 ||
              helperFunctions.operations.contains(computerStr[index - 1]) ||
              trigs.contains(computerStr[index - 1]) ||
              ['(', FixedValues.root, FixedValues.cubeRootSym]
                  .contains(computerStr[index - 1])) {
            computerStr.replaceRange(index, count, replaceRoot);
          } else {
            replaceRoot[0] = '*${replaceRoot[0]}';
            computerStr.replaceRange(index, count, replaceRoot);
          }
        }
      } else {
        List<String> replaceRoot;
        if (char == FixedValues.root) {
          replaceRoot = ['sqrt($val)'];
        } else {
          replaceRoot = ['nrt(3, $val)'];
        }

        if (index == 0 ||
            helperFunctions.operations.contains(computerStr[index - 1]) ||
            trigs.contains(computerStr[index - 1]) ||
            ['(', FixedValues.root, FixedValues.cubeRootSym]
                .contains(computerStr[index - 1])) {
          computerStr.replaceRange(index, count, replaceRoot);
        } else {
          replaceRoot[0] = '*${replaceRoot[0]}';
          computerStr.replaceRange(index, count, replaceRoot);
        }
      }
      return computerStr;
    } else {
      return computerStr;
    }
  }

  List<String> getFactorOrPercent(List<String> computerStr, String char) {
    final int index = computerStr.indexOf(char);
    computerStr.removeAt(index);
    int count = index - 1;
    final SmartParseResult data = smartParseLast(count, computerStr);
    count = data.start;
    final double val = data.value;
    if (char.contains('!')) {
      if (val % 1 == 0 && val >= 0) {
        final BigInt getNum = BigInt.from(val);
        try {
          final BigInt factNum = helperFunctions.factorial(getNum);
          computerStr.removeRange(count + 1, index);
          computerStr.insert(count + 1, factNum.toString());
        } catch (_) {
          computerStr = ['0/0'];
        }
      } else {
        computerStr = ['0/0'];
      }

      return computerStr;
    } else if (char.contains('%')) {
      List<String> prev = List.empty(growable: true);
      String lastChar = '';
      List<String> second = List.empty(growable: true);
      final double first = val;
      final List<String> plusminus = [FixedValues.minus, '+'];
      bool previousMinus = false;

      if (count != -1) {
        prev = computerStr.getRange(0, count + 1).toList();
        lastChar = prev.last;

        if (helperFunctions.operations.contains(lastChar)) {
          if (lastChar.contains(FixedValues.minus)) {
            if (prev.length < 2 ||
                prev[prev.length - 2].contains('(') ||
                helperFunctions.randomList.contains(prev[prev.length - 2])) {
              previousMinus = true;
            } else {
              second = prev.getRange(0, count).toList();
            }
          } else {
            second = prev.getRange(0, count).toList();
          }
        } else {
          second = prev.getRange(0, count + 1).toList();
        }
      }

      if (count == -1) {
        computerStr.replaceRange(
            count + 1, index, helperFunctions.concatenateList([val / 100]));

        if (index + 1 < computerStr.length && computerStr[index + 1] == '%') {
          int i = index + 1;
          while (computerStr[i] == '%') {
            computerStr[i] = '*0.01';
            i++;
            if (i >= computerStr.length) break;
          }
        }
        return computerStr;
      } else if (previousMinus || prev.last.contains('(${FixedValues.minus}')) {
        computerStr.insertAll(prev.length + 1, ['*', '0.01']);
      } else if ((index < computerStr.length) &&
          ![FixedValues.minus, '+'].contains(computerStr[index])) {
        computerStr.replaceRange(
            count + 1, index, helperFunctions.concatenateList([first / 100]));
      } else if (helperFunctions.randomList.contains(lastChar)) {
        computerStr.replaceRange(
            count + 1, index, helperFunctions.concatenateList([first / 100]));
      } else if ((index - 1 > -1) &&
          !helperFunctions.numbersList.contains(computerStr[index - 1])) {
        if (plusminus.contains(prev[prev.length - 1])) {
          computerStr.replaceRange(
              count + 1,
              index,
              helperFunctions
                  .concatenateList(['(', second, ')', '*', first, '/', '100']));
        } else {
          computerStr.replaceRange(
              count + 1, index, helperFunctions.concatenateList([first / 100]));
        }
      } else if (plusminus.contains(lastChar)) {
        computerStr.replaceRange(
            0,
            index,
            helperFunctions.concatenateList(
                [second, lastChar, '(', second, ')', '*', first, '/', '100']));
      } else {
        computerStr.replaceRange(count + 1, index,
            helperFunctions.concatenateList([first / 100]));
      }

      computerStr = helperFunctions.replaceExp(computerStr);
      return computerStr;
    } else {
      return List.empty();
    }
  }
}
