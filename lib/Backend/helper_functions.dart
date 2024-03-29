import 'package:calculator_lite/fixed_values.dart';
import 'package:angles/angles.dart';
import 'dart:math' as math;
import 'package:decimal/decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class HelperFunctions {
  final List<String> operations = [
    FixedValues.divisionChar,
    FixedValues.multiplyChar,
    FixedValues.minus,
    '+',
    '^'
  ];

  final List<String> numbersList = [
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
    '.'
  ];

  final List<String> constList = ['e', FixedValues.pi];

  final List<String> randomList = [
    'tan(',
    'sin(',
    'cos(',
    'log(',
    'ln(',
    'sin⁻¹(',
    'cos⁻¹(',
    'tan⁻¹(',
    FixedValues.root,
    FixedValues.cubeRootSym
  ];

  int parseNumbersFromEnd(int i, var str) {
    // Parse the string from the end to start. Break immediately if any symbol found other than integers.
    for (; i >= 0; i--) {
      if (!numbersList.contains(str[i])) break;
    }
    return i;
  }

  int parseRandomFromEnd(int i, var str) {
    // Parse the string from the end to start. Break immediately if any symbol found other than integers.
    for (; i >= 0; i--) {
      if (randomList.contains(str[i])) break;
    }
    return i - 1;
  }

  int parseConstFromEnd(int i, var str) {
    // Parse the string from the end to start. Break immediately if any symbol found other than integers.
    for (; i >= 0; i--) {
      if (!constList.contains(str[i])) break;
    }
    return i;
  }

  int parseOperatorFromEnd(int i, var str) {
    for (; i >= 0; i--) {
      if (operations.contains(str[i])) break;
    }
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

  List<String> replaceExp(List<String> computerStr) {
    for (int i = 0; i < computerStr.length; i++) {
      if (computerStr[i].contains('e')) {
        if (computerStr[i] == 'e') {
          computerStr[i] = '${math.e}';
        } else {
          final d = Decimal.tryParse(computerStr[i]);
          computerStr[i] = '$d';
        }
      }
    }
    return computerStr;
  }

  List<String> concatenateList(List list) {
    List<String> result = [];
    for (var element in list) {
      if (element is List<String>) {
        for (var element1 in element) {
          result.add(element1);
        }
      } else if (element is double) {
        result.add(element.toString());
      } else {
        result.add(element);
      }
    }
    return result;
  }

  BigInt factorial(BigInt n) {
    if (n < BigInt.from(0)) throw ('Negative numbers are not allowed.');
    return n <= BigInt.from(1)
        ? BigInt.from(1)
        : n * factorial(n - BigInt.from(1));
  }

  double getDegValue(List<String> computerString, int index, double angle) {
    final an = Angle.degrees(angle);
    double angleResult;
    switch (computerString[index]) {
      case 'cos(':
        {
          if (!isOddMultiple90(angle)) {
            angleResult = an.cos;
          } else {
            angleResult = an.cos.roundToDouble();
          }

          break;
        }

      case 'sin(':
        angleResult = an.sin;
        break;

      case 'tan(':
        {
          if (angle.abs() == 45) {
            angleResult = an.tan.roundToDouble();
          } else if (check180(angle)) {
            angleResult = 0;
          } else if (!isOddMultiple90(angle)) {
            angleResult = an.tan;
          } else {
            angleResult = double.infinity;
          }
          break;
        }

      case 'cos⁻¹(':
        {
          if (angle.abs() != 0.5) {
            angleResult = Angle.acos(angle).degrees;
          } else {
            angleResult = Angle.acos(angle).degrees.roundToDouble();
          }
          break;
        }

      case 'sin⁻¹(':
        {
          if (angle.abs() != 0.5) {
            angleResult = Angle.asin(angle).degrees;
          } else {
            angleResult = Angle.asin(angle).degrees.roundToDouble();
          }
          break;
        }

      case 'tan⁻¹(':
        {
          angleResult = Angle.atan(angle).degrees;
          break;
        }

      default:
        angleResult = double.nan;
    }

    if (['cos⁻¹(', 'sin⁻¹(', 'tan⁻¹('].contains(computerString[index])) {
      if (angle.abs() > 1) angleResult = double.nan;
    }

    return angleResult;
  }

  bool isOddMultiple90(double angle) {
    bool isMultiple = false;

    if (isInteger(angle) && angle % 90 == 0) {
      int quotient = angle ~/ 90;
      if (isInteger(quotient)) isMultiple = quotient.isOdd;
    }

    return isMultiple;
  }

  bool check180(double angle) {
    bool isMultiple = false;
    if (isInteger(angle) && angle % 180 == 0) isMultiple = true;
    return isMultiple;
  }

  bool isInteger(num value) => value is int || value == value.roundToDouble();

  String getDate(DateTime dateTime) {
    String t1 = DateFormat.Hm().format(dateTime);
    String t2 = DateFormat('yyyy-MM-dd').format(dateTime);
    String date = '$t2 $t1';

    return date;
  }

  bool isLandScape(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.landscape;
}
