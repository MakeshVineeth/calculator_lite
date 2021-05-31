import 'package:calculator_lite/fixedValues.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class SlidePanelItem extends StatelessWidget {
  final Function function;
  final Color light;
  final Color dark;
  final IconData icon;

  const SlidePanelItem(
      {@required this.function, @required this.icon, this.dark, this.light});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: FixedValues.large,
      child: SlidableAction(
        onPressed: (context) => function(),
        autoClose: true,
        icon: icon,
        foregroundColor:
            (Theme.of(context).brightness == Brightness.light ? light : dark) ??
                Theme.of(context).primaryColor,
      ),
    );
  }
}
