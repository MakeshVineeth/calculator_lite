import 'package:flutter/material.dart';

class ThemeChange extends InheritedWidget {
  final Widget child;
  final Function stateFunction;
  const ThemeChange({this.child, this.stateFunction}) : super(child: child);

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => true;

  static ThemeChange of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ThemeChange>();
}