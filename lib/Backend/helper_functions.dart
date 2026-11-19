import 'dart:math' as math;
import 'package:angles/angles.dart';
import 'package:calculator_lite/fixed_values.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HelperFunctions {
  final List<String> operations = [
    FixedValues.divisionChar,
    FixedValues.multiplyChar,
    FixedValues.minus,
    '+',
    '^',
    'mod',
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
    '.',
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
    FixedValues.cubeRootSym,
  ];

  int parseNumbersFromEnd(int i, List<String> str) {
    for (; i >= 0; i--) {
      if (!numbersList.contains(str[i])) break;
    }
    return i;
  }

  int parseRandomFromEnd(int i, List<String> str) {
    for (; i >= 0; i--) {
      if (randomList.contains(str[i])) break;
    }
    return i - 1;
  }

  int parseConstFromEnd(int i, List<String> str) {
    for (; i >= 0; i--) {
      if (!constList.contains(str[i])) break;
    }
    return i;
  }

  int parseOperatorFromEnd(int i, List<String> str) {
    for (; i >= 0; i--) {
      if (operations.contains(str[i])) break;
    }
    return i;
  }

  int parseMatchingBrackets(int end, List<String> str) {
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

  List<String> concatenateList(List<dynamic> list) {
    final List<String> result = [];
    for (final element in list) {
      if (element is List<String>) {
        for (final element1 in element) {
          result.add(element1);
        }
      } else if (element is double) {
        result.add(element.toString());
      } else {
        result.add(element.toString());
      }
    }
    return result;
  }

  BigInt factorial(BigInt n) {
    if (n < BigInt.zero) throw ArgumentError('Negative numbers are not allowed.');
    if (n > BigInt.from(170)) throw Exception('Factorial exceeds representation limits.');
    BigInt result = BigInt.one;
    for (BigInt i = BigInt.two; i <= n; i += BigInt.one) {
      result *= i;
    }
    return result;
  }

  double getDegValue(List<String> computerString, int index, double angle) {
    final an = Angle.degrees(angle);
    double angleResult;
    switch (computerString[index]) {
      case 'cos(':
        if (!isOddMultiple90(angle)) {
          angleResult = an.cos;
        } else {
          angleResult = an.cos.roundToDouble();
        }
        break;

      case 'sin(':
        angleResult = an.sin;
        break;

      case 'tan(':
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

      case 'cos⁻¹(':
        if (angle.abs() > 1) {
          angleResult = double.nan;
        } else if (angle.abs() != 0.5) {
          angleResult = Angle.acos(angle).degrees;
        } else {
          angleResult = Angle.acos(angle).degrees.roundToDouble();
        }
        break;

      case 'sin⁻¹(':
        if (angle.abs() > 1) {
          angleResult = double.nan;
        } else if (angle.abs() != 0.5) {
          angleResult = Angle.asin(angle).degrees;
        } else {
          angleResult = Angle.asin(angle).degrees.roundToDouble();
        }
        break;

      case 'tan⁻¹(':
        angleResult = Angle.atan(angle).degrees;
        break;

      default:
        angleResult = double.nan;
    }

    return angleResult;
  }

  bool isOddMultiple90(double angle) {
    bool isMultiple = false;
    if (isInteger(angle) && angle % 90 == 0) {
      final int quotient = angle ~/ 90;
      if (isInteger(quotient)) isMultiple = quotient.isOdd;
    }
    return isMultiple;
  }

  bool check180(double angle) {
    return isInteger(angle) && angle % 180 == 0;
  }

  bool isInteger(num value) => value is int || value == value.roundToDouble();

  String getDate(DateTime dateTime) {
    final String t1 = DateFormat.Hm().format(dateTime);
    final String t2 = DateFormat('yyyy-MM-dd').format(dateTime);
    return '$t2 $t1';
  }

  bool isLandScape(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.landscape;
}
