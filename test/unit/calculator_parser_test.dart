import 'package:calculator_lite/Backend/calc_parser.dart';
import 'package:calculator_lite/fixed_values.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CalcParser - Basic Arithmetic Unit Tests', () {
    test('addition evaluation', () {
      final parser = CalcParser(
        calculationString: ['2', '+', '3'],
        currentMetric: 'RAD',
      );
      final result = parser.evalFunction(['2', '+', '3']);
      expect(result, equals(5.0));
    });

    test('subtraction evaluation', () {
      final parser = CalcParser(
        calculationString: ['1', '0', FixedValues.minus, '4'],
        currentMetric: 'RAD',
      );
      final result =
          parser.evalFunction(['1', '0', FixedValues.minus, '4']);
      expect(result, equals(6.0));
    });

    test('multiplication evaluation', () {
      final parser = CalcParser(
        calculationString: ['7', FixedValues.multiplyChar, '8'],
        currentMetric: 'RAD',
      );
      final result =
          parser.evalFunction(['7', FixedValues.multiplyChar, '8']);
      expect(result, equals(56.0));
    });

    test('division evaluation', () {
      final parser = CalcParser(
        calculationString: ['4', '2', FixedValues.divisionChar, '7'],
        currentMetric: 'RAD',
      );
      final result =
          parser.evalFunction(['4', '2', FixedValues.divisionChar, '7']);
      expect(result, equals(6.0));
    });

    test('operator precedence: multiplication before addition', () {
      final parser = CalcParser(
        calculationString: ['2', '+', '3', FixedValues.multiplyChar, '4'],
        currentMetric: 'RAD',
      );
      final result = parser.evalFunction(
          ['2', '+', '3', FixedValues.multiplyChar, '4']);
      expect(result, equals(14.0));
    });

    test('parentheses alter precedence', () {
      final parser = CalcParser(
        calculationString: ['(', '2', '+', '3', ')', FixedValues.multiplyChar, '4'],
        currentMetric: 'RAD',
      );
      final result = parser.evalFunction(
          ['(', '2', '+', '3', ')', FixedValues.multiplyChar, '4']);
      expect(result, equals(20.0));
    });
  });

  group('CalcParser - Advanced & Scientific Operations', () {
    test('square root evaluation', () {
      final parser = CalcParser(
        calculationString: [FixedValues.root, '(', '1', '6', ')'],
        currentMetric: 'RAD',
      );
      final result =
          parser.evalFunction([FixedValues.root, '(', '1', '6', ')']);
      expect(result, equals(4.0));
    });

    test('cube root evaluation', () {
      final parser = CalcParser(
        calculationString: [FixedValues.cubeRootSym, '(', '2', '7', ')'],
        currentMetric: 'RAD',
      );
      final result =
          parser.evalFunction([FixedValues.cubeRootSym, '(', '2', '7', ')']);
      expect(result, closeTo(3.0, 0.0001));
    });

    test('factorial calculation', () {
      final parser = CalcParser(
        calculationString: ['5', '!'],
        currentMetric: 'RAD',
      );
      final result = parser.evalFunction(['5', '!']);
      expect(result, equals(120.0));
    });

    test('zero factorial equals one', () {
      final parser = CalcParser(
        calculationString: ['0', '!'],
        currentMetric: 'RAD',
      );
      final result = parser.evalFunction(['0', '!']);
      expect(result, equals(1.0));
    });

    test('percentage evaluation single value', () {
      final parser = CalcParser(
        calculationString: ['5', '0', '%'],
        currentMetric: 'RAD',
      );
      final result = parser.evalFunction(['5', '0', '%']);
      expect(result, closeTo(0.5, 0.0001));
    });

    test('power exponentiation evaluation', () {
      final parser = CalcParser(
        calculationString: ['2', '^', '3'],
        currentMetric: 'RAD',
      );
      final result = parser.evalFunction(['2', '^', '3']);
      expect(result, equals(8.0));
    });

    test('trigonometry sin in RAD', () {
      final parser = CalcParser(
        calculationString: ['sin(', '0', ')'],
        currentMetric: 'RAD',
      );
      final result = parser.evalFunction(['sin(', '0', ')']);
      expect(result, closeTo(0.0, 0.0001));
    });

    test('trigonometry cos in RAD', () {
      final parser = CalcParser(
        calculationString: ['cos(', '0', ')'],
        currentMetric: 'RAD',
      );
      final result = parser.evalFunction(['cos(', '0', ')']);
      expect(result, closeTo(1.0, 0.0001));
    });

    test('trigonometry sin(90) in DEG', () {
      final parser = CalcParser(
        calculationString: ['sin(', '9', '0', ')'],
        currentMetric: 'DEG',
      );
      final result = parser.evalFunction(['sin(', '9', '0', ')']);
      expect(result, closeTo(1.0, 0.0001));
    });

    test('trigonometry cos(90) in DEG', () {
      final parser = CalcParser(
        calculationString: ['cos(', '9', '0', ')'],
        currentMetric: 'DEG',
      );
      final result = parser.evalFunction(['cos(', '9', '0', ')']);
      expect(result, closeTo(0.0, 0.0001));
    });

    test('trigonometry tan(45) in DEG', () {
      final parser = CalcParser(
        calculationString: ['tan(', '4', '5', ')'],
        currentMetric: 'DEG',
      );
      final result = parser.evalFunction(['tan(', '4', '5', ')']);
      expect(result, closeTo(1.0, 0.0001));
    });
  });

  group('CalcParser - Edge Cases & Robustness', () {
    test('division by zero produces infinity', () {
      final parser = CalcParser(
        calculationString: ['5', FixedValues.divisionChar, '0'],
        currentMetric: 'RAD',
      );
      final result =
          parser.evalFunction(['5', FixedValues.divisionChar, '0']);
      expect(result.isInfinite, isTrue);
    });

    test('negative square root results in NaN', () {
      final parser = CalcParser(
        calculationString: [FixedValues.root, '(', FixedValues.minus, '4', ')'],
        currentMetric: 'RAD',
      );
      final result = parser.evalFunction(
          [FixedValues.root, '(', FixedValues.minus, '4', ')']);
      expect(result.isNaN, isTrue);
    });

    test('auto-closing open parentheses', () {
      final parser = CalcParser(
        calculationString: ['(', '2', '+', '3'],
        currentMetric: 'RAD',
      );
      final result = parser.evalFunction(['(', '2', '+', '3']);
      expect(result, equals(5.0));
    });

    test('empty expression evaluates safely to NaN', () {
      final parser = CalcParser(
        calculationString: [],
        currentMetric: 'RAD',
      );
      final result = parser.evalFunction([]);
      expect(result.isNaN, isTrue);
    });
  });
}
