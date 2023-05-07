import 'package:flutter/material.dart';
import 'package:calculator_lite/fixed_values.dart';

class DialogTextBtn extends StatelessWidget {
  final Function function;
  final String title;

  const DialogTextBtn({required this.function, required this.title, Key key})
      : super(key: key);

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
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
