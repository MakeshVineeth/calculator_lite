import 'package:calculator_lite/fixedValues.dart';
import 'package:flutter/material.dart';

class RadioTileCustom extends StatelessWidget {
  final bool value;
  final bool groupValue;
  final String title;
  final VoidCallback function;

  RadioTileCustom({
    @required this.value,
    @required this.groupValue,
    @required this.title,
    @required this.function,
  });

  @override
  Widget build(BuildContext context) {
    return RadioListTile(
      value: value,
      title: Text(title),
      dense: true,
      groupValue: groupValue,
      shape: FixedValues.roundShapeBtns,
      controlAffinity: ListTileControlAffinity.leading,
      onChanged: (val) => function(),
    );
  }
}
