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
    icon: 'icon_calculator',
  );

  static final currencyQuickAction = const ShortcutItem(
      type: 'action_currency',
      localizedTitle: FixedValues.currencyTabTitle,
      icon: 'icon_currency');

  static final historyQuickAction = const ShortcutItem(
      type: 'action_history',
      localizedTitle: FixedValues.historyTabTitle,
      icon: 'icon_history');
}
