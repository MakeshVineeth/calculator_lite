import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:calculator_lite/Backend/theme_change.dart';
import 'package:calculator_lite/UIElements/show_blur_dialog.dart';
import 'package:calculator_lite/UIElements/fade_scale_widget.dart';
import 'package:calculator_lite/fixed_values.dart';

// Pop up for Choosing Theme
class PopThemeChooser extends StatelessWidget {
  const PopThemeChooser({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FadeScale(
      child: AlertDialog(
        title: const Text(
          'Choose Theme',
          style: FixedValues.semiBoldStyle,
        ),
        content: const ThemeButtons(),
        shape: FixedValues.roundShapeLarge,
      ),
    );
  }

  static void showThemeChooser(BuildContext context) => showBlurDialog(
        context: context,
        child: const PopThemeChooser(),
      );
}

final Map<String, String> e = {
  'Light': 'Light',
  'Dark': 'Dark',
  'System Default': 'System Default'
};

class ThemeButtons extends StatefulWidget {
  const ThemeButtons({Key? key}) : super(key: key);

  @override
  State<ThemeButtons> createState() => _ThemeButtonsState();
}

class _ThemeButtonsState extends State<ThemeButtons> {
  String _currentThemeString = 'System Default';
  late ThemeChange themeChange;

  void getCurrentThemeStat() async {
    final prefs = await SharedPreferences.getInstance();
    final theme = prefs.getString('theme') ?? 'System Default';
    setState(() => _currentThemeString = theme);
  }

  @override
  void initState() {
    super.initState();
    getCurrentThemeStat();
  }

  @override
  Widget build(BuildContext context) {
    themeChange = ThemeChange.of(context)!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: e.entries
          .map((e) => ListTile(
                shape: FixedValues.roundShapeLarge,
                title: Text(
                  e.key,
                  style: FixedValues.semiBoldStyle,
                ),
                onTap: () => setTheme(e.value),
                leading: Radio(
                  value: e.value,
                  groupValue: _currentThemeString,
                  onChanged: setTheme,
                ),
              ))
          .toList(),
    );
  }

  void setTheme(var val) async {
    setState(() => _currentThemeString = val);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', _currentThemeString);
    ThemeMode themeMode = MiniThemeFunctions.parseTheme(_currentThemeString);
    themeChange.stateFunction(themeMode);
  }
}
