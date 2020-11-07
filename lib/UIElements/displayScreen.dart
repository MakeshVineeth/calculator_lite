import 'package:flutter/material.dart';
import 'package:charcode/charcode.dart' as charcode;
import 'package:calculator_lite/UIElements/editText.dart';
import 'package:auto_size_text_field/auto_size_text_field.dart';

class DisplayScreen extends StatefulWidget {
  const DisplayScreen({
    @required this.calculationString,
    @required this.mainValue,
  });

  final List<String> calculationString;
  final double mainValue;

  @override
  _DisplayScreenState createState() => _DisplayScreenState();

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

class _DisplayScreenState extends State<DisplayScreen> {
  final myController = TextEditingController();

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    runInitial();
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
                calculationString: widget.calculationString,
              ),
              AutoSizeTextField(
                controller: myController,
                minLines: 1,
                maxLines: 2,
                readOnly: true,
                showCursor: true,
                decoration: null,
                style: mainValueStyle(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void runInitial() {
    myController.text = DisplayScreen.formatNumber(widget.mainValue);
  }

  TextStyle mainValueStyle() => TextStyle(
        fontSize: 45.0,
        letterSpacing: 1.0,
        fontWeight: FontWeight.bold,
      );
}
