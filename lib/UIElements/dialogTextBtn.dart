import 'package:flutter/material.dart';
import 'package:calculator_lite/fixedValues.dart';

class DialogTextBtn extends StatelessWidget {
  final Function function;
  final String title;

  const DialogTextBtn({@required this.function, @required this.title});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
        shape: MaterialStateProperty.all(FixedValues.roundShapeLarge),
      ),
      onPressed: () => function(),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Text(
          title,
          textAlign: TextAlign.end,
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
