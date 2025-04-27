import 'package:calculator_lite/fixed_values.dart';
import 'package:flutter/material.dart';

class DialogTextBtn extends StatelessWidget {
  final Function function;
  final String title;

  const DialogTextBtn({required this.function, required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
        shape: WidgetStateProperty.all(FixedValues.roundShapeLarge),
      ),
      onPressed: () {
        function();
        Navigator.of(context).pop();
      },
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
