import 'package:flutter/material.dart';
import 'package:calculator_lite/fixedValues.dart';

class SmallToolBtn extends StatelessWidget {
  final Function function;
  final IconData icon;

  SmallToolBtn({@required this.function, @required this.icon});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      shape: FixedValues.roundShapeBtns,
      onPressed: () => function(),
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Icon(icon),
      ),
    );
  }
}
