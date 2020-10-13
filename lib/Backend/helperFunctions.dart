import 'package:calculator_lite/fixedValues.dart';

class HelperFunctions {
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
  int parseNumbersFromEnd(int i, var str) {
    // Parse the string from the end to start. Break immediately if any symbol found other than integers.
    for (; i >= 0; i--) if (!numbersList.contains(str[i])) break;
    return i;
  }

  int parseOperatorFromEnd(int i, var str) {
    for (; i >= 0; i--) if (operations.contains(str[i])) break;
    return i;
  }

  int parseMatchingBrackets(int end, var str) {
    int openBrace = 0;
    int closedBrace = 0;
    for (; end >= 0; --end) {
      if (str[end].contains(')')) closedBrace += 1;
      if (str[end].contains('(')) openBrace += 1;
      if (openBrace == closedBrace) break;
    }
    return end;
  }

  BigInt factorial(BigInt n) {
    if (n < BigInt.from(0)) throw ('Negative numbers are not allowed.');
    return n <= BigInt.from(1)
        ? BigInt.from(1)
        : n * factorial(n - BigInt.from(1));
  }
}
