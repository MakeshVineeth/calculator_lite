import 'package:flutter/material.dart';
import 'package:calculator_lite/fixed_values.dart';

class SmallToolBtn extends StatelessWidget {
  final Function function;
  final IconData icon;

  const SmallToolBtn({required this.function, required this.icon, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      minWidth: 0,
      padding: const EdgeInsets.all(8.0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: FixedValues.roundShapeBtns,
      onPressed: () => function(),
      child: Icon(icon),
    );
  }
}
