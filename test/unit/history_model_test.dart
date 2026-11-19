import 'package:calculator_lite/HistoryTab/Backend/history_functions.dart';
import 'package:calculator_lite/HistoryTab/commons_history.dart';
import 'package:calculator_lite/HistoryTab/history_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HistoryItem Model & CommonsHistory Tests', () {
    test('HistoryItem instantiates with required fields', () {
      final now = DateTime.now();
      final item = HistoryItem(
        title: 'Calculation 1',
        dateTime: now,
        expression: '12 * 12',
        value: '144.0',
        metrics: 'RAD',
      );

      expect(item.title, equals('Calculation 1'));
      expect(item.dateTime, equals(now));
      expect(item.expression, equals('12 * 12'));
      expect(item.value, equals('144.0'));
      expect(item.metrics, equals('RAD'));
    });

    test('getFormattedTitle formats timestamp properly', () {
      final date = DateTime(2026, 11, 17, 10, 15);
      final title = getFormattedTitle(date);
      expect(title, isNotEmpty);
      expect(title, contains('2026'));
    });

    test('CommonsHistory constants are well defined', () {
      expect(CommonsHistory.historyBox, equals('history_box'));
      expect(CommonsHistory.historyEnabled, equals('enabled'));
      expect(CommonsHistory.historyDisabled, equals('disabled'));
    });
  });
}
