import 'package:calculator_lite/fixedValues.dart';
import 'package:angles/angles.dart';

class HelperFunctions {
  List<String> operations = [
    FixedValues.divisionChar,
    FixedValues.multiplyChar,
    FixedValues.minus,
    '+',
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
    '.'
  ];
  List<String> constList = ['e', FixedValues.pi];
  List<String> randomList = [
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
  ]; // Cube root too must be added here.
  int parseNumbersFromEnd(int i, var str) {
    // Parse the string from the end to start. Break immediately if any symbol found other than integers.
    for (; i >= 0; i--) if (!numbersList.contains(str[i])) break;
    return i;
  }

  int parseRandomFromEnd(int i, var str) {
    // Parse the string from the end to start. Break immediately if any symbol found other than integers.
    for (; i >= 0; i--) if (randomList.contains(str[i])) break;
    return i - 1;
  }

  int parseConstFromEnd(int i, var str) {
    // Parse the string from the end to start. Break immediately if any symbol found other than integers.
    for (; i >= 0; i--) if (!constList.contains(str[i])) break;
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

  List<String> concatenateList(List list) {
    List<String> result = [];
    list.forEach((element) {
      if (element is List<String>)
        element.forEach((element1) {
          result.add(element1);
        });
      else if (element is double)
        result.add(element.toString());
      else
        result.add(element);
    });
    return result;
  }

  BigInt factorial(BigInt n) {
    if (n < BigInt.from(0)) throw ('Negative numbers are not allowed.');
    return n <= BigInt.from(1)
        ? BigInt.from(1)
        : n * factorial(n - BigInt.from(1));
  }

  double getDegValue(List<String> computerString, int index, double angle) {
    final an = Angle.fromDegrees(angle);
    double angleResult;
    switch (computerString[index]) {
      case 'cos(':
        {
          if (!isMultiple90(angle))
            angleResult = an.cos;
          else
            angleResult = an.cos.roundToDouble();

          break;
        }

      case 'sin(':
        angleResult = an.sin;
        break;

      case 'tan(':
        {
          if (angle.abs() == 45)
            angleResult = an.tan.roundToDouble();
          else if (!isMultiple90(angle))
            angleResult = an.tan;
          else
            angleResult = double.infinity;
          break;
        }

      case 'cos⁻¹(':
        {
          if (angle.abs() != 0.5)
            angleResult = Angle.acos(angle).degrees;
          else
            angleResult = Angle.acos(angle).degrees.roundToDouble();
          break;
        }

      case 'sin⁻¹(':
        {
          if (angle.abs() != 0.5)
            angleResult = Angle.asin(angle).degrees;
          else
            angleResult = Angle.asin(angle).degrees.roundToDouble();
          break;
        }

      case 'tan⁻¹(':
        {
          angleResult = Angle.atan(angle).degrees;
          break;
        }

      default:
        angleResult = null;
    }

    if (['cos⁻¹(', 'sin⁻¹(', 'tan⁻¹('].contains(computerString[index])) {
      if (angle.abs() > 1) angleResult = null;
    }

    return angleResult;
  }

  bool isMultiple90(double angle) {
    bool isMultiple = false;

    if (angle % 1 == 0) {
      int intAngle = angle.toInt().abs();

      for (int i = 1;; i += 2) {
        int temp = 90 * i;
        if (temp > angle) break;
        if (temp == intAngle) {
          isMultiple = true;
          break;
        }
      }
    }

    return isMultiple;
  }
}
