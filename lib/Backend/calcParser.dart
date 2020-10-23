import 'package:math_expressions/math_expressions.dart';
import 'package:calculator_lite/fixedValues.dart';
import 'package:calculator_lite/UIElements/displayScreen.dart';
import 'package:calculator_lite/Backend/helperFunctions.dart';
import 'dart:math' as math;

class CalcParser {
  List<String> calculationString;
  String currentMetric;
  CalcParser({this.calculationString, this.currentMetric});
  HelperFunctions helperFunctions = HelperFunctions();

  // List of constants for conditional checks.
  List<String> trigFunctions = [
    'sin',
    'cos',
    'tan',
    'ln',
    'log',
    'sin⁻¹',
    'cos⁻¹',
    'tan⁻¹'
  ];
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
    FixedValues.cubeChar,
    FixedValues.changeSignChar,
  ];

  // This function adds elements to displayScreen with formatting.
  List<String> addToExpression(String value) {
    if (calculationString.length != 0) {
      int lastIndex = calculationString.length - 1;
      String lastChar = calculationString[lastIndex];

      bool case1 = (value.contains(FixedValues.minus) &&
          !lastChar
              .contains(FixedValues.minus)); // checks -+, *- etc but not --
      bool case2 = !(helperFunctions.operations.contains(value) &&
          helperFunctions.operations.contains(
              lastChar)); // same operators side-by-side aren't allowed.

      if (case1 || case2) {
        // Code for Square of Number.
        if (value.contains(FixedValues.squareChar))
          calculationString[lastIndex] = '$lastChar' + FixedValues.sup2;

        // Code for Cube of Number.
        if (value.contains(FixedValues.cubeChar))
          calculationString[lastIndex] = '$lastChar' + FixedValues.sup3;

        // Code for reciprocal button.
        else if (value.contains(FixedValues.reciprocalChar))
          reciprocalFunction();

        // Code for add bracket after following functions.
        else if (trigFunctions.contains(value))
          calculationString.add('$value(');

        // Code for replace x with
        else if (value == 'eˣ')
          calculationString.add('e^');
        else if (value == '𝟏𝟬ˣ')
          calculationString.add('10^');

        // Code for cube root
        else if (value.contains(FixedValues.cubeRoot))
          calculationString.add(FixedValues.cubeRootSym);
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
      else if (value.contains(FixedValues.cubeRoot))
        calculationString.add(FixedValues.cubeRootSym);
      else if (value.contains(FixedValues.decimalChar))
        calculationString.add('.');
      // Code for replace x with
      else if (value == 'eˣ')
        calculationString.add('e^');
      else if (value == '𝟏𝟬ˣ')
        calculationString.add('10^');
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
      if (currentMetric == 'DEG') {
        print('Degrees');
      }
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
          ].contains(lastChar))
            tempString.insert(lastIndex, FixedValues.multiplyChar);
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
        ].contains(lastButOne)) if ([
              'sin(',
              'cos(',
              'tan(',
              'ln(',
              'log(',
              'sin⁻¹(',
              'cos⁻¹(',
              'tan⁻¹(',
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

    sym = FixedValues.root;
    symTOTAL = 0;
    tempString.forEach((element) {
      if (element == sym) symTOTAL += 1;
    });
    while (symTOTAL > 0) {
      tempString = getRoot(tempString, sym);
      symTOTAL -= 1;
    }

    symTOTAL = 0;
    tempString.forEach((element) {
      if (element == FixedValues.cubeRootSym) symTOTAL += 1;
    });
    while (symTOTAL > 0) {
      tempString = getRoot(tempString, FixedValues.cubeRootSym);
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
    computerStr = computerStr.replaceAll(FixedValues.sup3, '^3');
    computerStr = computerStr.replaceAll('mod', '%');
    computerStr = computerStr.replaceAll('log(', 'log(10,');
    computerStr = computerStr.replaceAll('sin⁻¹(', 'arcsin(');
    computerStr = computerStr.replaceAll('cos⁻¹(', 'arccos(');
    computerStr = computerStr.replaceAll('tan⁻¹(', 'arctan(');

    // Attach parentheses automatically.
    int countOpen = '('.allMatches(computerStr).length;
    int countClosed = ')'.allMatches(computerStr).length;
    if (countOpen != countClosed) {
      int toAdd = countOpen - countClosed;
      for (int i = 0; i < toAdd; i++) computerStr = computerStr + ')';
    }
    return computerStr;
  }

  // For Root
  List<String> getRoot(List<String> computerStr, String char) {
    int index = computerStr.indexOf(char);
    int count = index + 1;

    // Detect braces first.
    if (index < computerStr.length - 1 && computerStr[count].contains('(')) {
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
    }

    // Detect operators now.
    else {
      for (; count < computerStr.length; count++)
        if (helperFunctions.operations.contains(computerStr[count])) break;
    }

    List<String> valStr = computerStr.getRange(index + 1, count).toList();
    double val = evalFunction(valStr);
    if (val < 0 || val == null) {
      computerStr = ['0/0']; // Make it NaN
    } else {
      List<String> replaceRoot;
      if (char == FixedValues.root)
        replaceRoot = ['sqrt($val)'];
      else
        replaceRoot = ['nrt(3, $val)'];
      computerStr.replaceRange(index, count, replaceRoot);
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
      List<String> prev;
      String lastChar;
      String second;
      double first = val;
      String exp;
      List plusminus = [FixedValues.minus, '+'];
      if (count != -1) {
        prev = computerStr.getRange(0, count + 1).toList();
        lastChar = prev.last;
        if (helperFunctions.operations.contains(lastChar))
          second = prev.getRange(0, count).toList().join();
      }

      // Detects single 55 or 25 etc
      if (count == -1) {
        String exp = '${val / 100}';
        computerStr.replaceRange(count + 1, index, [exp]);
        return computerStr;
      }

      // Detects 8 + 5 % * debug point here (This: 8 + 5% * 5 + 3%); Detects post 5% if it is * or ^ or something else.
      else if ((index < computerStr.length) &&
          ![FixedValues.minus, '+'].contains(computerStr[index])) {
        exp = '${first / 100}';
        computerStr.replaceRange(count + 1, index, [exp]);
      }

      // Detects tan( etc at the end
      else if (helperFunctions.randomList.contains(lastChar)) {
        exp = '${first / 100}';
        computerStr.replaceRange(count + 1, index, [exp]);
      }

      // Detects 9 - tan(2)% and 9 + cos(2) * cos(2)%
      else if ((index - 1 > -1) &&
          !helperFunctions.numbersList.contains(computerStr[index - 1])) {
        if (plusminus.contains(prev[prev.length - 1]))
          exp = '$second*$first/100';
        else
          exp = '${(first / 100)}';
        computerStr.replaceRange(count + 1, index, [exp]);
      }

      // Detects 9 - 5 + 6 * sin(5) + 3%
      else if (plusminus.contains(lastChar)) {
        exp = '$second$lastChar($second)*$first/100';
        computerStr.replaceRange(0, index, [exp]);
      }

      // Detects 9 + 6 * sin(5) * 6%
      else {
        exp = '$second$lastChar${(first / 100)}';
        computerStr.replaceRange(0, index, [exp]);
      }
      return computerStr;
    }

    // Returns null if char is neither % nor ! nor even if it is factorial but unsupported value like decimals etc.
    else
      return null;
  }
}
