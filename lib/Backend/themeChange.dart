import 'package:flutter/material.dart';

class ThemeChange extends InheritedWidget {
  final Widget child;
  final Function stateFunction;
  const ThemeChange({this.child, this.stateFunction}) : super(child: child);

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) =>
      child != oldWidget.child;

  static ThemeChange of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ThemeChange>();
}

class MiniThemeFunctions {
  static ThemeMode parseTheme(String theme) {
    ThemeMode themeMode;
    switch (theme) {
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
    return themeMode;
  }
}
