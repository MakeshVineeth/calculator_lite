import 'package:calculator_lite/Backend/calc_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Security & Input Validation Tests (OWASP Mobile M4 & M6)', () {
    test('malformed deeply nested brackets evaluate safely without crashing', () {
      final parser = CalcParser(
        calculationString: ['(', '(', '(', '1', '+', '2', ')', ')', ')'],
        currentMetric: 'RAD',
      );
      final result =
          parser.evalFunction(['(', '(', '(', '1', '+', '2', ')', ')', ')']);
      expect(result, equals(3.0));
    });

    test('division by zero produces infinite value without unhandled exception', () {
      final parser = CalcParser(
        calculationString: ['1', '/', '0'],
        currentMetric: 'RAD',
      );
      final result = parser.evalFunction(['1', '/', '0']);
      expect(result.isInfinite, isTrue);
    });

    test('unbalanced opening brackets are auto-balanced safely', () {
      final parser = CalcParser(
        calculationString: ['(', '(', '5', '+', '5'],
        currentMetric: 'RAD',
      );
      final result = parser.evalFunction(['(', '(', '5', '+', '5']);
      expect(result, equals(10.0));
    });

    test('consecutive operators are safely guarded in addToExpression', () {
      final parser = CalcParser(
        calculationString: ['5', '+'],
        currentMetric: 'RAD',
      );
      // Adding '+' again to '+' should be rejected
      final expr = parser.addToExpression('+');
      expect(expr, equals(['5', '+']));
    });

    test('invalid start tokens are rejected', () {
      final parser = CalcParser(
        calculationString: [],
        currentMetric: 'RAD',
      );
      // Adding '*' or '/' on empty expression should not add it
      final expr = parser.addToExpression('*');
      expect(expr, isEmpty);
    });
  });
}
