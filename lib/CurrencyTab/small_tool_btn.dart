import 'package:flutter/material.dart';
import 'package:calculator_lite/fixed_values.dart';

class SmallToolBtn extends StatelessWidget {
  final Function function;
  final IconData icon;

  const SmallToolBtn({@required this.function, @required this.icon, Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      shape: FixedValues.roundShapeBtns,
      onPressed: () => function(),
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Center(child: Icon(icon)),
      ),
    );
  }
}
