import 'package:flutter/material.dart';
import 'package:charcode/charcode.dart' as charcode;
import 'package:calculator_lite/UIElements/editText.dart';
import 'package:auto_size_text/auto_size_text.dart';

class DisplayScreen extends StatelessWidget {
  const DisplayScreen({
    @required this.calculationString,
    @required this.mainValue,
  });

  final List<String> calculationString;
  final double mainValue;

  @override
  Widget build(BuildContext context) {
    String mainValueStr = formatNumber(mainValue);
    return Expanded(
      flex: 2,
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        child: Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text Widget for all calculations.
              TextFieldCalc(
                calculationString: calculationString,
              ),
              AutoSizeText(
                mainValueStr,
                maxLines: 1,
                style: mainValueStyle(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextStyle mainValueStyle() => TextStyle(
        fontSize: 35.0,
        letterSpacing: 1.0,
        fontWeight: FontWeight.bold,
      );

  static String formatNumber(double value) {
    if (value == -0) value = 0; // For Cos90 = -0
    int precision = 10;
    String infinity = 'Infinity';
    String infinitySymbol = String.fromCharCode(charcode.$infin);
    String valueStr = value.toString();
    if (value % 1 == 0)
      valueStr = value.toStringAsFixed(0);
    else
      valueStr = value.toStringAsFixed(precision);

    return valueStr.replaceAll(infinity, infinitySymbol);
  }
}
