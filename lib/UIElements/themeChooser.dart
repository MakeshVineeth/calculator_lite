import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:calculator_lite/Backend/themeChange.dart';

// Pop up for Choosing Theme
class PopThemeChooser extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Choose Theme'),
      content: ThemeButtons(),
      elevation: 50.0, // Little Shadows
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
    );
  }
}

Map e = {'Light': 'Light', 'Dark': 'Dark', 'System Default': 'System Default'};

class ThemeButtons extends StatefulWidget {
  @override
  _ThemeButtonsState createState() => _ThemeButtonsState();
}

class _ThemeButtonsState extends State<ThemeButtons> {
  String _currentTheme;
  ThemeChange themeChange;

  void getCurrentThemeStat() async {
    final prefs = await SharedPreferences.getInstance();
    final theme = prefs.getString('theme') ?? 'System Default';
    setState(() {
      _currentTheme = theme;
    });
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
          .map((e) => RadioListTile(
                title: Text(e.key),
                value: e.value,
                groupValue: _currentTheme,
                onChanged: setTheme,
              ))
          .toList(),
    );
  }

  void setTheme(var val) async {
    setState(() {
      _currentTheme = val;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', _currentTheme);
    ThemeMode themeMode;
    switch (_currentTheme) {
      case 'System Default':
        themeMode = ThemeMode.system;
        break;
      case 'Dark':
        themeMode = ThemeMode.dark;
        break;
      case 'Light':
        themeMode = ThemeMode.light;
        break;
    }
    themeChange.stateFunction(themeMode);
  }
}