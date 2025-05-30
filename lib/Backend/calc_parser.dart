import 'dart:math' as math;

import 'package:calculator_lite/Backend/helper_functions.dart';
import 'package:calculator_lite/UIElements/display_screen.dart';
import 'package:calculator_lite/fixed_values.dart';
import 'package:flutter/foundation.dart';
import 'package:math_expressions/math_expressions.dart';

class CalcParser {
  List<String> calculationString;
  String currentMetric;

  CalcParser({required this.calculationString, required this.currentMetric});

  final HelperFunctions helperFunctions = HelperFunctions();

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
      int lastIndex = calculationString.length - 1;
      String lastChar = calculationString[lastIndex];

      bool case1 = (value.contains(FixedValues.minus) &&
          !lastChar.contains(
              FixedValues.minus)); // checks -+, *- etc but not -- and root-
      bool case2 = !(helperFunctions.operations.contains(value) &&
          helperFunctions.operations.contains(
              lastChar)); // same operators side-by-side aren't allowed.

      if (case1 || case2) {
        // Code for reciprocal button.
        if (value.contains(FixedValues.reciprocalChar)) {
          reciprocalFunction();
        } else if (value.contains(FixedValues.minus)) {
          if (!([FixedValues.cubeRootSym, FixedValues.root, FixedValues.minus]
              .contains(lastChar))) {
            calculationString.add(value);
          }
        }

        // Code for add bracket after following functions.
        else if (trigFunctions.contains(value)) {
          calculationString.add('$value(');
        } else if ([FixedValues.squareChar, FixedValues.cubeChar]
            .contains(value)) {
          if ([')', FixedValues.pi, 'e'].contains(lastChar) ||
              helperFunctions.numbersList.contains(lastChar) ||
              [FixedValues.sup2, FixedValues.sup3].contains(lastChar)) {
            if (value.contains(FixedValues.squareChar)) {
              calculationString.add(FixedValues.sup2);
            } else {
              calculationString.add(FixedValues.sup3);
            }
          }
        }

        // Code for replace x with
        else if (value == 'eˣ') {
          calculationString.addAll(['e', '^']);
        } else if (value == '𝟏𝟬ˣ') {
          calculationString.addAll(['1', '0', '^']);
        } else if (value == FixedValues.cubeRoot) {
          calculationString.add(FixedValues.cubeRootSym);
        } else if (value.contains(FixedValues.decimalChar)) {
          setDecimalChar();
        } else if (value.contains(')')) {
          addClosedBracket();
        } else if (value.contains(FixedValues.changeSignChar)) {
          setSign();
        } else if (['!', '%', 'mod'].contains(value) ||
            helperFunctions.operations.contains(value)) {
          if (value.contains(FixedValues.minus) ||
              !(helperFunctions.randomList.contains(lastChar) ||
                  lastChar.contains('(') ||
                  helperFunctions.operations.contains(lastChar))) {
            calculationString.add(value);
          }
        } else if (value.isNotEmpty) {
          calculationString.add(value);
        }
      }
    }

    // Following functions should not present in the first position.
    else if (!(avoidFirstElement.contains(value))) {
      // Check if only value present is NOT an operator.
      if (trigFunctions.contains(value)) {
        calculationString.add('$value(');
      } else if (value.contains(FixedValues.cubeRoot)) {
        calculationString.add(FixedValues.cubeRootSym);
      } else if (value.contains(FixedValues.decimalChar)) {
        calculationString.add('.');
      } else if (value == 'eˣ') {
        calculationString.addAll(['e', '^']);
      } else if (value == '𝟏𝟬ˣ') {
        calculationString.addAll(['1', '0', '^']);
      } else if (value.isNotEmpty) {
        calculationString.add(value);
      }
    }
    return calculationString;
  }

  void addClosedBracket() {
    // This function adds closed bracket no more than what is required.
    String lastChar = calculationString.last;
    String computerStr = calculationString.join();
    int count = '('.allMatches(computerStr).length;
    int count1 = ')'.allMatches(computerStr).length;
    if (count1 < count) {
      if (lastChar != FixedValues.minus && lastChar != '(') {
        calculationString.add(')');
      }
    }
  }

  List smartParseLast(int lastIndex, List<String> compStr) {
    double value = 0;
    int start = 0;
    try {
      // Parse numbers initially.
      start = helperFunctions.parseNumbersFromEnd(lastIndex, compStr);
      if (start != lastIndex) {
        value =
            double.tryParse(compStr.getRange(start + 1, lastIndex + 1).join())!;
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

      // Check for % and ! now.
      else if (['%', '!'].contains(compStr[lastIndex])) {
        start = 0;
        List<String> temp = compStr.getRange(start, lastIndex).toList();
        List getData = smartParseLast(temp.length - 1, temp);
        start = getData[0];
        temp = compStr.getRange(start + 1, lastIndex + 1).toList();
        value = evalFunction(temp);
      }

      // Executes if there are no integers from beginning.
      else {
        start = helperFunctions.parseOperatorFromEnd(lastIndex, compStr);
        List<String> temp = compStr.getRange(start + 1, lastIndex + 1).toList();
        value = evalFunction(temp);
      }
    } catch (_) {}

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
        if (values[1] >= 0) {
          valueStr = DisplayScreen.formatNumber(values[1]);
        } else {
          valueStr = DisplayScreen.formatNumber(values[1]);
          valueStr = valueStr.replaceAll('-', FixedValues.minus);
        }

        // if (calculationString.length > 0) valueStr = "(" + valueStr;
        if (calculationString.isNotEmpty) {
          calculationString.addAll(['(', ...valueStr.split('')]);
        } else {
          calculationString.addAll([...valueStr.split('')]);
        }
      }
    }

    // Do nothing for exceptions.
    catch (_) {}
  }

  void setSign() {
    int lastIndex = calculationString.length - 1; // Get index of last char
    int i = helperFunctions.parseNumbersFromEnd(lastIndex, calculationString);

    // If it is equal to -1 then add sign directly as there are no operators at this point, only a number.
    if (i == -1) {
      calculationString.insert(0, FixedValues.minus);
    } else if (calculationString.length == 1) {
      if (calculationString[lastIndex] != FixedValues.minus) {
        calculationString.insert(0, FixedValues.minus);
      } else {
        calculationString.removeAt(lastIndex);
      }
    }

    // Check if i is not equal to last item in the array, meaning there are numbers beginning from the end.
    else if (i != lastIndex) {
      insertSign(i);
    } else if (calculationString[lastIndex] == '(') {
      insertSign(i - 1);
    } else if (calculationString[lastIndex].contains(')')) {
      i = helperFunctions.parseMatchingBrackets(lastIndex, calculationString) -
          1;
      if (i != -1) {
        insertSign(i);
      } else {
        calculationString.insert(0, FixedValues.minus);
      }
    }

    // Use Case
    else if (helperFunctions.constList.contains(calculationString[lastIndex])) {
      i = helperFunctions.parseConstFromEnd(lastIndex, calculationString);
      if (i != -1) insertSign(i);
    }

    // Use Case
    else if (helperFunctions.randomList
        .contains(calculationString[lastIndex])) {
      i = helperFunctions.parseRandomFromEnd(lastIndex, calculationString);
      if (i != -1) insertSign(i);
    }

    // Use Case
    else {
      i = helperFunctions.parseOperatorFromEnd(lastIndex, calculationString);
      if (i != -1) {
        insertSign(i);
      } else {
        calculationString.insert(0, FixedValues.minus);
      }
    }
  }

  void insertSign(int i) {
    // check if last is (-
    if (calculationString.length > 1 &&
        i > 0 &&
        calculationString[i] == '–' &&
        calculationString[i - 1] == '(' &&
        i + 1 <= calculationString.length) {
      calculationString.removeRange(i - 1, i + 1);
    } else {
      switch (calculationString[i]) {
        case 'ln(':
        case 'log(':
        case 'sin(':
        case 'cos(':
        case 'tan(':
        case 'sin⁻¹(':
        case 'cos⁻¹(':
        case 'tan⁻¹(':
        case '(':
          calculationString.insert(i + 1, FixedValues.minus);
          break;
        case '+':
          calculationString[i] = FixedValues.minus;
          break;
        case '–':
          if (i != 0 && !calculationString[i - 1].contains('(')) {
            calculationString[i] = '+';
          } else {
            calculationString.removeAt(i);
          } // Just remove - instead of adding + when position is at 0.
          break;
        default:
          calculationString.insertAll(i + 1, ['(', (FixedValues.minus)]);
      }
    }
  }

  void setDecimalChar() {
    int index = helperFunctions.parseNumbersFromEnd(
        calculationString.length - 1, calculationString);
    List<String> getCompareStr = calculationString
        .getRange(index + 1, calculationString.length)
        .toList();
    bool count = getCompareStr.join().contains('.');
    if (!count) calculationString.add('.');
  }

  // This function called from CalcTab.dart after calling addToExpression.
  Future<double> getValue() => compute(evalFunction, calculationString);

  double evalFunction(List<String> calcStr) {
    try {
      GrammarParser p = GrammarParser();
      String comptStr = computerString(calcStr);
      Expression exp = p.parse(
          comptStr); // evalFunction is executed first, internally function asks for computerString.
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);

      return eval;
    } catch (_) {
      return double.nan;
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
        }

        // another use case
        else if ([
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

    while (tempString.where((value) => value == "!").isNotEmpty) {
      tempString = getFactorOrPercent(tempString, "!");
    }

    while (tempString.where((value) => value == "%").isNotEmpty) {
      tempString = getFactorOrPercent(tempString, "%");
    }

    // Attach parentheses automatically.
    String computerStr = tempString.join();
    int countOpen = '('.allMatches(computerStr).length;
    int countClosed = ')'.allMatches(computerStr).length;
    if (countOpen != countClosed) {
      int toAdd = countOpen - countClosed;
      for (int i = 0; i < toAdd; i++) {
        tempString.add(')');
      }
    }

    // For DEG
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
            List<String> temp =
                tempString.getRange(count + 1, braceCount).toList();
            double angle = evalFunction(temp);
            double degVal =
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

    // Replace with strings that dart/math_exp package can understand.
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

  // For Root
  List<String> getRoot(List<String> computerStr, String char) {
    int index = computerStr.indexOf(char);
    if (index != -1) {
      int count = index + 1;

      // Detect braces first.
      if (index < computerStr.length - 1 &&
          (computerStr[count].contains('('))) {
        int openBrace = 0;
        int closedBrace = 0;
        //if (trigs.contains(computerStr[count])) openBrace = 1;
        for (; count < computerStr.length; count++) {
          if (computerStr[count].contains('(')) openBrace += 1;
          if (computerStr[count].contains(')')) closedBrace += 1;
          if (openBrace == closedBrace) {
            count += 1;
            break;
          }
        }
      }

      // Detect operators now.
      else {
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

      List<String> valStr = computerStr.getRange(index + 1, count).toList();
      double val = evalFunction(valStr);
      if (val < 0) {
        computerStr = ['0/0']; // Make it NaN
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
          replaceRoot[0] =
              '*${replaceRoot[0]}'; // Add * for those that do not contain any operator before.
          computerStr.replaceRange(index, count, replaceRoot);
        }
      }
      return computerStr;
    } else {
      return computerStr;
    }
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
        computerStr.insert(count + 1, factNum.toString());
      } catch (_) {
        computerStr = ['0/0']; // Make it NaN this way.
      }

      return computerStr;
    }

    // For % below code.
    else if (char.contains("%")) {
      List<String> prev = List.empty(growable: true);
      String lastChar = "";
      List<String> second = List.empty(growable: true);
      double first = val;
      List plusminus = [FixedValues.minus, '+'];
      bool previousMinus = false;

      if (count != -1) {
        prev = computerStr.getRange(0, count + 1).toList();
        lastChar = prev.last;

        if (helperFunctions.operations.contains(lastChar)) {
          // Run separate checks for minus
          if (lastChar.contains(FixedValues.minus)) {
            if (prev.length < 2 ||
                prev[prev.length - 2].contains('(') ||
                helperFunctions.randomList.contains(prev[prev.length - 2])) {
              previousMinus = true;
            } else {
              second = prev.getRange(0, count).toList();
            }
          }

          // Return if it is not an minus operator.
          else {
            second = prev.getRange(0, count).toList();
          }
        }
        // Return if it is not any operator.
        else {
          second = prev.getRange(0, count + 1).toList();
        }
      }

      // Detects single 55 or 25 etc
      if (count == -1) {
        computerStr.replaceRange(
            count + 1, index, helperFunctions.concatenateList([val / 100]));

        // Detects %%
        if (index + 1 < computerStr.length && computerStr[index + 1] == "%") {
          int i = index + 1;
          while (computerStr[i] == "%") {
            computerStr[i] = '*0.01';
            i++;
            if (i >= computerStr.length) break;
          }
        }
        return computerStr;
      }

      // Special checks
      else if (previousMinus || prev.last.contains('(${FixedValues.minus}')) {
        computerStr.insertAll(prev.length + 1, ['*', '0.01']);
      }

      // Detects 8 + 5 % * debug point here (This: 8 + 5% * 5 + 3%); Detects post 5% if it is * or ^ or something else.
      else if ((index < computerStr.length) &&
          ![FixedValues.minus, '+'].contains(computerStr[index])) {
        computerStr.replaceRange(
            count + 1, index, helperFunctions.concatenateList([first / 100]));
      }

      // Detects tan( etc at the end
      else if (helperFunctions.randomList.contains(lastChar)) {
        computerStr.replaceRange(
            count + 1, index, helperFunctions.concatenateList([first / 100]));
      }

      // Detects 9 - tan(2)% and 9 + cos(2) * cos(2)%
      else if ((index - 1 > -1) &&
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
      }

      // Detects 9 - 5 + 6 * sin(5) + 3%
      else if (plusminus.contains(lastChar)) {
        computerStr.replaceRange(
            0,
            index,
            helperFunctions.concatenateList(
                [second, lastChar, '(', second, ')', '*', first, '/', '100']));
      }

      // Detects 9 + 6 * sin(5) * 6%
      else {
        computerStr.replaceRange(0, index,
            helperFunctions.concatenateList([second, lastChar, first / 100]));
      }

      computerStr = helperFunctions.replaceExp(computerStr);
      return computerStr;
    }

    // Returns null if char is neither % nor ! nor even if it is factorial but unsupported value like decimals etc.
    else {
      return List.empty();
    }
  }
}
