import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:calculator_lite/Backend/themeChange.dart';
import 'package:calculator_lite/UIElements/showBlurDialog.dart';
import 'package:calculator_lite/UIElements/fade_scale_widget.dart';
import 'package:calculator_lite/fixedValues.dart';

// Pop up for Choosing Theme
class PopThemeChooser extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FadeScale(
      child: AlertDialog(
        title: Text(
          'Choose Theme',
          style: FixedValues.semiBoldStyle,
        ),
        content: ThemeButtons(),
        shape: FixedValues.roundShapeLarge,
      ),
    );
  }

  static void showThemeChooser(BuildContext context) {
    showBlurDialog(
      context: context,
      child: PopThemeChooser(),
    );
  }
}

Map<String, String> e = {
  'Light': 'Light',
  'Dark': 'Dark',
  'System Default': 'System Default'
};

class ThemeButtons extends StatefulWidget {
  @override
  _ThemeButtonsState createState() => _ThemeButtonsState();
}

class _ThemeButtonsState extends State<ThemeButtons> {
  String _currentThemeString;
  ThemeChange themeChange;

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
    themeChange = ThemeChange.of(context);

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
