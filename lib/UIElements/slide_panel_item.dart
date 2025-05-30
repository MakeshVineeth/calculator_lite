import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class SlidePanelItem extends StatelessWidget {
  final Function function;
  final Color light;
  final Color dark;
  final IconData icon;
  final String label;

  const SlidePanelItem(
      {required this.function,
      required this.icon,
      required this.dark,
      required this.light,
      required this.label,
      super.key});

  @override
  Widget build(BuildContext context) {
    return SlidableAction(
      label: label,
      onPressed: (context) => function(),
      autoClose: true,
      icon: icon,
      backgroundColor: Theme.of(context).cardTheme.color!,
      foregroundColor:
          (Theme.of(context).brightness == Brightness.light ? light : dark),
    );
  }
}
