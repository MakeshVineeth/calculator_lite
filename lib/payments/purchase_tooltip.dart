import 'package:calculator_lite/fixedValues.dart';
import 'package:flutter/material.dart';

class PurchaseToolTip extends StatelessWidget {
  final text;

  const PurchaseToolTip({@required this.text});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: FixedValues.large,
        onTap: () {
          final snackBar = SnackBar(
            content: Text(text),
            duration: const Duration(seconds: 1),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 15),
          child: Text(
            text,
            style: FixedValues.semiBoldStyle,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
