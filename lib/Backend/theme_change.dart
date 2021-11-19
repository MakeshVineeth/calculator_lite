import 'package:flutter/material.dart';

class ThemeChange extends InheritedWidget {
  final Widget newChild;
  final Function stateFunction;

  const ThemeChange({this.newChild, this.stateFunction, Key key})
      : super(child: newChild, key: key);

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) =>
      newChild != oldWidget.child;

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
