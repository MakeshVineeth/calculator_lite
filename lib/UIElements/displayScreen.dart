import 'package:flutter/material.dart';
import 'package:charcode/charcode.dart' as charcode;

class DisplayScreen extends StatelessWidget {
  const DisplayScreen({
    Key key,
    @required this.calculationString,
    @required this.mainValue,
  }) : super(key: key);

  final List<String> calculationString;
  final double mainValue;

  @override
  Widget build(BuildContext context) {
    String mainValueStr = formatNumber(mainValue);
    return Expanded(
      flex: 2,
      child: Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text Widget for all calculations.
            Text(
              calculationString
                  .join(), // We are storing each button text as objects
              style: completeStringStyle(),
            ),
            Text(
              mainValueStr,
              style: mainValueStyle(),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle mainValueStyle() => TextStyle(
        fontSize: 40.0,
        letterSpacing: 1.0,
        fontWeight: FontWeight.bold,
      );

  TextStyle completeStringStyle() => TextStyle(
        fontSize: 25,
        letterSpacing: 1.5,
      );

  static String formatNumber(double value) {
    int precision = 10;
    String infinity = 'Infinity';
    String infinitySymbol = String.fromCharCode(charcode.$infin);
    if (value % 1 == 0)
      return value.toStringAsFixed(0).replaceAll(infinity, infinitySymbol);
    else
      return value
          .toStringAsFixed(precision)
          .replaceAll(infinity, infinitySymbol);
  }
}
