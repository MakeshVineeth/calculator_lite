import 'package:auto_size_text/auto_size_text.dart';
import 'package:calculator_lite/UIElements/fade_in_widget.dart';
import 'package:flutter/material.dart';

class CalcButtons extends StatefulWidget {
  final List<dynamic> rowData;
  final int index;
  final VoidCallback displayFunction;
  final bool isCornerRows;
  final AutoSizeGroup? autoSizeGroup;

  const CalcButtons({
    required this.rowData,
    required this.index,
    required this.displayFunction,
    required this.isCornerRows,
    this.autoSizeGroup,
    super.key,
  });

  @override
  State<CalcButtons> createState() => _CalcButtonsState();
}

class _CalcButtonsState extends State<CalcButtons> {
  static const Set<String> _textFunctions = {
    'sin',
    'cos',
    'tan',
    'ln',
    'log',
    'mod',
    'inv',
  };

  @override
  Widget build(BuildContext context) {
    Color? fgColor = Theme.of(context)
        .textTheme
        .labelLarge!
        .color; // Initialized as Default Text Color

    if (widget.index == (widget.rowData.length - 1)) {
      fgColor = Theme.of(context)
          .primaryColor; // Last Column as Index 3 and is always primary color like red or blue
    }
    if (widget.isCornerRows) {
      fgColor = Theme.of(context).primaryColor; // Check if it corners rows
    }

    final String text = widget.rowData[widget.index].toString();
    final bool isFunctionWord = _textFunctions.contains(text);
    final bool isSingleChar = text.length == 1 || text == '+/-';

    final double screenWidth = MediaQuery.sizeOf(context).width;
    final bool isSmallScreen = screenWidth < 360;

    final double fontSize;
    final double minFontSize;
    final AutoSizeGroup? group;

    if (isFunctionWord) {
      fontSize = 20.0;
      minFontSize = isSmallScreen ? 8.0 : 12.0;
      group = widget.autoSizeGroup;
    } else if (isSingleChar) {
      fontSize = 28.0;
      minFontSize = isSmallScreen ? 9.0 : 16.0;
      group = null;
    } else {
      fontSize = 18.0;
      minFontSize = isSmallScreen ? 8.0 : 10.0;
      group = null;
    }

    final double marginVal = isSmallScreen ? 2.5 : 5.0;

    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              margin: EdgeInsets.all(marginVal),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  elevation: 1.0,
                ),
                onPressed: widget.displayFunction,
                child: IgnorePointer(
                  child: FadeThis(
                    child: AutoSizeText(
                      text,
                      group: group,
                      style: TextStyle(
                        color: fgColor,
                        fontSize: fontSize,
                        fontWeight: FontWeight.w500,
                      ),
                      minFontSize: minFontSize,
                      stepGranularity: 1,
                      maxLines: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
