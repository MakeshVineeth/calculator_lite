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
