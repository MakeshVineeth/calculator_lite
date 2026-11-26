import 'package:calculator_lite/Backend/helper_functions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const helper = HelperFunctions();

  group('HelperFunctions - Number and Parsing Logic', () {
    test('parseNumbersFromEnd finds last non-digit index', () {
      final expr = ['1', '2', '+', '3', '4', '5'];
      final idx = helper.parseNumbersFromEnd(expr.length - 1, expr);
      expect(idx, equals(2)); // At '+'
    });

    test('parseMatchingBrackets finds matching opening parenthesis', () {
      final expr = ['(', '1', '+', '2', ')'];
      final start = helper.parseMatchingBrackets(expr.length - 1, expr);
      expect(start, equals(0));
    });

    test('parseMatchingBrackets handles nested parentheses', () {
      final expr = ['(', '1', '+', '(', '2', '*', '3', ')', ')'];
      final start = helper.parseMatchingBrackets(expr.length - 1, expr);
      expect(start, equals(0));
    });

    test('factorial calculation of BigInt', () {
      expect(helper.factorial(BigInt.from(0)), equals(BigInt.one));
      expect(helper.factorial(BigInt.from(1)), equals(BigInt.one));
      expect(helper.factorial(BigInt.from(4)), equals(BigInt.from(24)));
      expect(helper.factorial(BigInt.from(6)), equals(BigInt.from(720)));
    });

    test('factorial throws on negative number', () {
      expect(
        () => helper.factorial(BigInt.from(-1)),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('check180 identifies multiples of 180', () {
      expect(helper.check180(180), isTrue);
      expect(helper.check180(360), isTrue);
      expect(helper.check180(90), isFalse);
      expect(helper.check180(45), isFalse);
    });

    test('isOddMultiple90 identifies odd multiples of 90', () {
      expect(helper.isOddMultiple90(90), isTrue);
      expect(helper.isOddMultiple90(270), isTrue);
      expect(helper.isOddMultiple90(180), isFalse);
      expect(helper.isOddMultiple90(360), isFalse);
    });

    test('isInteger correctly identifies whole numbers', () {
      expect(helper.isInteger(5), isTrue);
      expect(helper.isInteger(5.0), isTrue);
      expect(helper.isInteger(5.25), isFalse);
    });

    test('getDate formats DateTime into yyyy-MM-dd HH:mm', () {
      final dt = DateTime(2026, 11, 17, 14, 30);
      final formatted = helper.getDate(dt);
      expect(formatted, contains('2026-11-17'));
      expect(formatted, contains('14:30'));
    });
  });
}
