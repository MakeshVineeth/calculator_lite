import 'package:calculator_lite/Backend/calc_parser.dart';
import 'package:calculator_lite/UIElements/display_screen.dart';
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

  group('CalcParser - Google Drive Bug Regression Tests', () {
    test('Screenshot 1: large number precision and trailing zero stripping', () {
      final parser = CalcParser(
        calculationString: [
          '8', '8', '8', '8', '8', '8', '8', '8', '8', '8', '8', '8', '8', '8', '8',
          '+', '3', '2', '5', '6', 'cos(', '5', '6', ')', '+', '2', '5', '6', '9'
        ],
        currentMetric: 'RAD',
      );
      final result = parser.evalFunction(parser.calculationString);
      expect(result.isFinite, isTrue);
      final formatted = DisplayScreen.formatNumber(result);
      expect(formatted.endsWith('0'), isFalse);
    });

    test('Screenshot 2: 85tan(5) strips trailing zeroes in formatNumber', () {
      final parser = CalcParser(
        calculationString: ['8', '5', 'tan(', '5', ')'],
        currentMetric: 'DEG',
      );
      final result = parser.evalFunction(['8', '5', 'tan(', '5', ')']);
      expect(result, isNotNull);
      final formatted = DisplayScreen.formatNumber(result);
      expect(formatted.endsWith('0'), isFalse);
      expect(DisplayScreen.formatNumber(-287.3437755310), equals('-287.343775531'));
    });

    test('Screenshot 3: cos⁻¹(5) domain error produces NaN and displays Invalid Input', () {
      final parser = CalcParser(
        calculationString: ['cos⁻¹(', '5', ')'],
        currentMetric: 'DEG',
      );
      final result = parser.evalFunction(['cos⁻¹(', '5', ')']);
      expect(result.isNaN, isTrue);
      expect(DisplayScreen.formatNumber(result), equals('Invalid Input'));
    });

    test('Screenshot 4: tan⁻¹(5) is valid in DEG and does not produce NaN', () {
      final parser = CalcParser(
        calculationString: ['tan⁻¹(', '5', ')'],
        currentMetric: 'DEG',
      );
      final result = parser.evalFunction(['tan⁻¹(', '5', ')']);
      expect(result.isNaN, isFalse);
      expect(result, closeTo(78.69, 0.05));
    });

    test('Screenshot 5: 1!5 auto-inserts multiplyChar to avoid digit concatenation', () {
      final parser = CalcParser(
        calculationString: ['1', '!'],
        currentMetric: 'RAD',
      );
      final res = parser.addToExpression('5');
      expect(res, equals(['1', '!', FixedValues.multiplyChar, '5']));
    });

    test('Screenshot 6: operator replacement prevents modmod and blocks binary operator after open bracket', () {
      final parser1 = CalcParser(
        calculationString: ['5', 'mod'],
        currentMetric: 'RAD',
      );
      final res1 = parser1.addToExpression('mod');
      expect(res1, equals(['5', 'mod']));

      final parser2 = CalcParser(
        calculationString: [FixedValues.root, '('],
        currentMetric: 'RAD',
      );
      final res2 = parser2.addToExpression('mod');
      expect(res2, equals([FixedValues.root, '(']));
    });

    test('Screenshot 7: reciprocal of 0 does not insert literal NaN into calculationString', () {
      final parser = CalcParser(
        calculationString: ['0'],
        currentMetric: 'RAD',
      );
      parser.addToExpression(FixedValues.reciprocalChar);
      expect(parser.calculationString.contains('N'), isFalse);
      expect(parser.calculationString.contains('a'), isFalse);
    });

    test('Screenshot 8 & 9: cos⁻¹(tan⁻¹(e^56)) produces NaN and formats to Invalid Input', () {
      final parser = CalcParser(
        calculationString: ['cos⁻¹(', 'tan⁻¹(', 'e', '^', '5', '6', ')', ')'],
        currentMetric: 'RAD',
      );
      final result = parser.evalFunction(parser.calculationString);
      expect(result.isNaN, isTrue);
      expect(DisplayScreen.formatNumber(result), equals('Invalid Input'));
    });
  });

  group('CalcParser - Extreme Edge Cases & Robustness Suite', () {
    test('cube root of negative real numbers evaluates correctly', () {
      final parser = CalcParser(
        calculationString: [FixedValues.cubeRootSym, '(', FixedValues.minus, '8', ')'],
        currentMetric: 'RAD',
      );
      final result = parser.evalFunction(parser.calculationString);
      expect(result, closeTo(-2.0, 0.0001));

      final parser2 = CalcParser(
        calculationString: [FixedValues.cubeRootSym, '(', FixedValues.minus, '2', '7', ')'],
        currentMetric: 'RAD',
      );
      final result2 = parser2.evalFunction(parser2.calculationString);
      expect(result2, closeTo(-3.0, 0.0001));
    });

    test('postfix operators blocked after binary operators and open brackets', () {
      final parser1 = CalcParser(
        calculationString: ['5', '+'],
        currentMetric: 'RAD',
      );
      expect(parser1.addToExpression('!'), equals(['5', '+']));
      expect(parser1.addToExpression('%'), equals(['5', '+']));
      expect(parser1.addToExpression(FixedValues.squareChar), equals(['5', '+']));
      expect(parser1.addToExpression(FixedValues.cubeChar), equals(['5', '+']));

      final parser2 = CalcParser(
        calculationString: ['('],
        currentMetric: 'RAD',
      );
      expect(parser2.addToExpression('!'), equals(['(']));
      expect(parser2.addToExpression('%'), equals(['(']));
    });

    test('decimal point after operator or bracket auto-inserts leading zero', () {
      final parser1 = CalcParser(
        calculationString: ['5', '+'],
        currentMetric: 'RAD',
      );
      expect(parser1.addToExpression('.'), equals(['5', '+', '0.']));

      final parser2 = CalcParser(
        calculationString: ['('],
        currentMetric: 'RAD',
      );
      expect(parser2.addToExpression('.'), equals(['(', '0.']));
    });

    test('trailing decimal point evaluated cleanly as .0', () {
      final parser = CalcParser(
        calculationString: ['5', '.'],
        currentMetric: 'RAD',
      );
      final result = parser.evalFunction(parser.calculationString);
      expect(result, equals(5.0));
    });

    test('closing bracket blocked immediately after operator or dot', () {
      final parser1 = CalcParser(
        calculationString: ['(', '5', '+'],
        currentMetric: 'RAD',
      );
      expect(parser1.addToExpression(')'), equals(['(', '5', '+']));

      final parser2 = CalcParser(
        calculationString: ['(', '5', '.'],
        currentMetric: 'RAD',
      );
      expect(parser2.addToExpression(')'), equals(['(', '5', '.']));
    });

    test('setSign toggles sign with FixedValues.minus', () {
      final parser = CalcParser(
        calculationString: ['5'],
        currentMetric: 'RAD',
      );
      parser.addToExpression(FixedValues.changeSignChar);
      expect(parser.calculationString.first, equals(FixedValues.minus));

      parser.addToExpression(FixedValues.changeSignChar);
      expect(parser.calculationString.contains(FixedValues.minus), isFalse);
    });

    test('extreme trigonometric asymptotes', () {
      final parser = CalcParser(
        calculationString: ['tan(', '9', '0', ')'],
        currentMetric: 'DEG',
      );
      final result = parser.evalFunction(parser.calculationString);
      expect(result.isInfinite, isTrue);
      expect(DisplayScreen.formatNumber(result), equals('∞'));
    });

    test('keypad decimalChar (622·22×30000) normalizes and evaluates cleanly', () {
      final parser = CalcParser(
        calculationString: [],
        currentMetric: 'RAD',
      );
      final inputs = [
        '6',
        '2',
        '2',
        FixedValues.decimalChar,
        '2',
        '2',
        FixedValues.multiplyChar,
        '3',
        '0',
        '0',
        '0',
        '0',
      ];
      for (final token in inputs) {
        parser.addToExpression(token);
      }

      expect(
        parser.calculationString,
        equals([
          '6',
          '2',
          '2',
          '.',
          '2',
          '2',
          FixedValues.multiplyChar,
          '3',
          '0',
          '0',
          '0',
          '0',
        ]),
      );
      final result = parser.evalFunction(parser.calculationString);
      expect(result, equals(18666600.0));
      expect(DisplayScreen.formatNumber(result), equals('18666600'));
    });

    test('decimalChar handles leading, duplicate, postfix, and raw middot tokens',
        () {
      final leading = CalcParser(calculationString: [], currentMetric: 'RAD');
      for (final t in [
        FixedValues.decimalChar,
        '5',
        '+',
        FixedValues.decimalChar,
        '5',
      ]) {
        leading.addToExpression(t);
      }
      expect(leading.calculationString, equals(['0.', '5', '+', '0.', '5']));
      expect(leading.evalFunction(leading.calculationString), equals(1.0));

      final dup = CalcParser(calculationString: [], currentMetric: 'RAD');
      for (final t in [
        '6',
        '2',
        '2',
        FixedValues.decimalChar,
        '2',
        '2',
        FixedValues.decimalChar,
        '3',
      ]) {
        dup.addToExpression(t);
      }
      expect(dup.calculationString.join(), equals('622.223'));

      final zeroDup = CalcParser(calculationString: [], currentMetric: 'RAD');
      for (final t in [
        FixedValues.decimalChar,
        '5',
        FixedValues.decimalChar,
        '2',
      ]) {
        zeroDup.addToExpression(t);
      }
      expect(zeroDup.calculationString.join(), equals('0.52'));

      final postBracket =
          CalcParser(calculationString: ['(', '2', ')'], currentMetric: 'RAD');
      postBracket.addToExpression(FixedValues.decimalChar);
      postBracket.addToExpression('5');
      expect(
        postBracket.calculationString,
        equals(['(', '2', ')', FixedValues.multiplyChar, '0.', '5']),
      );
      expect(
        postBracket.evalFunction(postBracket.calculationString),
        equals(1.0),
      );

      final rawMiddot = CalcParser(calculationString: [], currentMetric: 'RAD');
      expect(
        rawMiddot.evalFunction(
            ['6', '2', '2', FixedValues.decimalChar, '2', '2']),
        closeTo(622.22, 0.0001),
      );
    });
  });
}
