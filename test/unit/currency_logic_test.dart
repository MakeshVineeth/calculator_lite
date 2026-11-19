import 'package:calculator_lite/CurrencyTab/Backend/commons.dart';
import 'package:calculator_lite/CurrencyTab/Backend/currency_list_item.dart';
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
  });
}
