import 'package:calculator_lite/fixedValues.dart';
import 'package:quick_actions/quick_actions.dart';

class AppShortcuts {
  static final List<ShortcutItem> shortcutsList = [
    calculatorQuickAction,
    currencyQuickAction,
    historyQuickAction,
  ];

  static final calculatorQuickAction = const ShortcutItem(
    type: 'action_calculator',
    localizedTitle: FixedValues.calculatorTabTitle,
  );

  static final currencyQuickAction = const ShortcutItem(
    type: 'action_currency',
    localizedTitle: FixedValues.currencyTabTitle,
  );

  static final historyQuickAction = const ShortcutItem(
    type: 'action_history',
    localizedTitle: FixedValues.historyTabTitle,
  );
}
