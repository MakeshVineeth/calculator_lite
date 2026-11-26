import 'dart:math' as math;
import 'package:angles/angles.dart';
import 'package:calculator_lite/fixed_values.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HelperFunctions {
  const HelperFunctions();

  static final Set<String> _operations = {
    FixedValues.divisionChar,
    FixedValues.multiplyChar,
    FixedValues.minus,
    '+',
    '^',
    'mod',
  };

  static const Set<String> _numbersSet = {
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
  };

  static final Set<String> _constSet = {'e', FixedValues.pi};

  static final Set<String> _randomSet = {
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
  };

  static final DateFormat _hmFormat = DateFormat.Hm();
  static final DateFormat _ymdFormat = DateFormat('yyyy-MM-dd');

  Set<String> get operations => _operations;
  Set<String> get numbersList => _numbersSet;
  Set<String> get constList => _constSet;
  Set<String> get randomList => _randomSet;

  int parseNumbersFromEnd(int i, List<String> str) {
    for (; i >= 0; i--) {
      if (!_numbersSet.contains(str[i]) && str[i] != '0.') break;
    }
    return i;
  }

  int parseRandomFromEnd(int i, List<String> str) {
    for (; i >= 0; i--) {
      if (_randomSet.contains(str[i])) break;
    }
    return i - 1;
  }

  int parseConstFromEnd(int i, List<String> str) {
    for (; i >= 0; i--) {
      if (!_constSet.contains(str[i])) break;
    }
    return i;
  }

  int parseOperatorFromEnd(int i, List<String> str) {
    for (; i >= 0; i--) {
      if (_operations.contains(str[i])) break;
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
        result.addAll(element);
      } else {
        result.add(element.toString());
      }
    }
    return result;
  }

  BigInt factorial(BigInt n) {
    if (n < BigInt.zero) throw ArgumentError('Negative numbers are not allowed.');
    if (n > BigInt.from(170)) {
      throw Exception('Factorial exceeds representation limits.');
    }
    BigInt result = BigInt.one;
    for (BigInt i = BigInt.two; i <= n; i += BigInt.one) {
      result *= i;
    }
    return result;
  }

  double getDegValue(List<String> computerString, int index, double angle) {
    final an = Angle.degrees(angle);
    switch (computerString[index]) {
      case 'cos(':
        return isOddMultiple90(angle) ? an.cos.roundToDouble() : an.cos;
      case 'sin(':
        return an.sin;
      case 'tan(':
        if (angle.abs() == 45) return an.tan.roundToDouble();
        if (check180(angle)) return 0;
        return isOddMultiple90(angle) ? double.infinity : an.tan;
      case 'cos⁻¹(':
        if (angle.abs() > 1) return double.nan;
        final res = Angle.acos(angle).degrees;
        return angle.abs() != 0.5 ? res : res.roundToDouble();
      case 'sin⁻¹(':
        if (angle.abs() > 1) return double.nan;
        final res = Angle.asin(angle).degrees;
        return angle.abs() != 0.5 ? res : res.roundToDouble();
      case 'tan⁻¹(':
        return Angle.atan(angle).degrees;
      default:
        return double.nan;
    }
  }

  bool isOddMultiple90(double angle) {
    if (isInteger(angle) && angle % 90 == 0) {
      final int quotient = angle ~/ 90;
      return quotient.isOdd;
    }
    return false;
  }

  bool check180(double angle) => isInteger(angle) && angle % 180 == 0;

  bool isInteger(num value) => value is int || value == value.roundToDouble();

  String getDate(DateTime dateTime) =>
      '${_ymdFormat.format(dateTime)} ${_hmFormat.format(dateTime)}';

  bool isLandScape(BuildContext context) =>
      MediaQuery.orientationOf(context) == Orientation.landscape;
}
