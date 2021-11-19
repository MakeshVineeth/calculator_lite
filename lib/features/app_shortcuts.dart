import 'package:calculator_lite/fixed_values.dart';
import 'package:quick_actions/quick_actions.dart';

class AppShortcuts {
  static final List<ShortcutItem> shortcutsList = [
    calculatorQuickAction,
    currencyQuickAction,
    historyQuickAction,
  ];

  static const calculatorQuickAction = ShortcutItem(
    type: 'action_calculator',
    localizedTitle: FixedValues.calculatorTabTitle,
    icon: 'icon_calculator',
  );

  static const currencyQuickAction = ShortcutItem(
      type: 'action_currency',
      localizedTitle: FixedValues.currencyTabTitle,
      icon: 'icon_currency');

  static const historyQuickAction = ShortcutItem(
      type: 'action_history',
      localizedTitle: FixedValues.historyTabTitle,
      icon: 'icon_history');
}
