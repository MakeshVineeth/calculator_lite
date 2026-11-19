import 'package:calculator_lite/Backend/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:charcode/charcode.dart' as charcode;
import 'package:calculator_lite/UIElements/edit_text.dart';
import 'package:auto_size_text_field/auto_size_text_field.dart';

class DisplayScreen extends StatefulWidget {
  const DisplayScreen(
      {required this.calculationString, required this.mainValue, super.key});

  final List<String> calculationString;
  final double mainValue;

  @override
  State<DisplayScreen> createState() => _DisplayScreenState();

  static String formatNumber(double value) {
    if (value == -0) value = 0; // For Cos90 = -0
    if (value.isNaN) return 'Invalid Input';
    const String infinity = 'Infinity';
    final String infinitySymbol = String.fromCharCode(charcode.$infin);
    if (value.isInfinite) {
      return value.isNegative ? '-$infinitySymbol' : infinitySymbol;
    }

    const int precision = 10;
    String valueStr = '';
    if (value % 1 == 0 && value.abs() < 1e15) {
      valueStr = value.toStringAsFixed(0);
    } else if (value.abs() >= 1e15 || (value.abs() > 0 && value.abs() < 1e-7)) {
      valueStr = value.toString();
    } else {
      valueStr = value.toStringAsFixed(precision);
      valueStr = valueStr
          .replaceFirst(RegExp(r'0+$'), '')
          .replaceFirst(RegExp(r'\.$'), '');
    }

    return valueStr.replaceAll(infinity, infinitySymbol);
  }

  static bool isDoubleValid(double? val) {
    if (val == null) return false;

    if (val.isNaN) return false;

    return true;
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
      child: LayoutBuilder(
        builder: (context, constraints) => ListView(
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
                    showCursor: false,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                    style: mainValueStyle.copyWith(
                      fontSize:
                          HelperFunctions().isLandScape(context) ? 30 : 45.0,
                    ),
                    scrollPhysics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static bool _isExpressionComplete(List<String> calcStr) {
    if (calcStr.isEmpty) return false;
    final last = calcStr.last;
    if (last == '.' ||
        last == '(' ||
        last.endsWith('(') ||
        HelperFunctions().operations.contains(last)) {
      return false;
    }
    return true;
  }

  void runInitial() {
    if (mounted) {
      if (DisplayScreen.isDoubleValid(widget.mainValue)) {
        myController.text = DisplayScreen.formatNumber(widget.mainValue);
      } else if (widget.mainValue.isNaN &&
          _isExpressionComplete(widget.calculationString)) {
        myController.text = 'Invalid Input';
      } else {
        myController.clear();
      }
    }
  }

  TextStyle mainValueStyle = const TextStyle(
    letterSpacing: 1.0,
    fontWeight: FontWeight.w800,
  );
}
