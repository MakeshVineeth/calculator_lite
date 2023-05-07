import 'package:calculator_lite/fixed_values.dart';
import 'package:flutter/material.dart';

class RadioTileCustom extends StatelessWidget {
  final bool value;
  final bool groupValue;
  final String title;
  final VoidCallback function;

  const RadioTileCustom(
      {required this.value,
      required this.groupValue,
      required this.title,
      required this.function,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RadioListTile(
      value: value,
      title: Text(
        title,
        style: FixedValues.semiBoldStyle,
      ),
      groupValue: groupValue,
      shape: FixedValues.roundShapeLarge,
      onChanged: (val) => function(),
    );
  }
}
