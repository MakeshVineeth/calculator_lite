import 'package:calculator_lite/CurrencyTab/Backend/commons.dart';
import 'package:calculator_lite/CurrencyTab/Backend/currency_list_item.dart';
import 'package:calculator_lite/CurrencyTab/Backend/get_currency_data.dart';
import 'package:calculator_lite/CurrencyTab/card_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Currency Models & Logic Tests', () {
    test('CurrencyListItem instantiates correctly', () {
      final item = CurrencyListItem(
        currencyCode: 'USD',
        currencyName: 'United States Dollar',
        flagURL: 'icons/flags/png100px/us.png',
      );

      expect(item.currencyCode, equals('USD'));
      expect(item.currencyName, equals('United States Dollar'));
      expect(item.flagURL, equals('icons/flags/png100px/us.png'));
    });

    test('CommonsData constants are valid', () {
      expect(CommonsData.remoteUrl, contains('https://'));
      expect(CommonsData.getCurrencyListUrl, contains('https://'));
      expect(CommonsData.currencyListBox, equals('currencies'));
      expect(CommonsData.fromBox, equals('from_box'));
      expect(CommonsData.toBox, equals('to_box'));
    });

    test('Exchange conversion math calculation', () {
      // 100 USD at rate 0.85 EUR/USD
      const double input = 100.0;
      const double rate = 0.85;
      const double converted = input * rate;
      expect(converted, equals(85.0));

      // Inverse calculation: 85 EUR back to USD
      const double inverted = converted / rate;
      expect(inverted, closeTo(100.0, 0.0001));
    });

    test('parseAndValidateRates filters reserved box names, bad keys, and invalid rates',
        () {
      final parsed = CurrencyData.parseAndValidateRates({
        'rates': {
          'EUR': 0.92,
          'INR': 84.5,
          'history': 999.0,
          'from_box': 1.0,
          '../evil': 2.0,
          'BAD': -5.0,
          'INF': double.infinity,
          'NAN': double.nan,
        },
      });

      expect(parsed, isNotNull);
      expect(parsed!['USD'], equals(1.0));
      expect(parsed['EUR'], equals(0.92));
      expect(parsed['INR'], equals(84.5));
      expect(parsed.containsKey('HISTORY'), isFalse);
      expect(parsed.containsKey('history'), isFalse);
      expect(parsed.containsKey('FROM_BOX'), isFalse);
      expect(parsed.containsKey('../EVIL'), isFalse);
      expect(parsed.containsKey('BAD'), isFalse);
      expect(parsed.containsKey('INF'), isFalse);
      expect(parsed.containsKey('NAN'), isFalse);
    });

    test('sanitizeCurrencyInput handles comma, dot, and NBSP grouping separators',
        () {
      expect(CardUI.sanitizeCurrencyInput('1,000', groupSep: ','), equals('1000'));
      expect(CardUI.sanitizeCurrencyInput('1.000', groupSep: '.'), equals('1000'));
      expect(
        CardUI.sanitizeCurrencyInput('1\u00A0000', groupSep: '\u00A0'),
        equals('1000'),
      );
      expect(
        CardUI.sanitizeCurrencyInput('1\u202F000.50', groupSep: '\u202F'),
        equals('1000.50'),
      );
      expect(CardUI.sanitizeCurrencyInput('12.34.56', groupSep: ','), equals('12.3456'));
    });
  });
}
