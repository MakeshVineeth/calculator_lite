import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class CalcButtons extends StatelessWidget {
  final List<dynamic> rowData;
  final int index;
  final VoidCallback displayFunction;
  final bool isCornerRows;
  final AutoSizeGroup? autoSizeGroup;
  final bool isSmallScreen;

  const CalcButtons({
    required this.rowData,
    required this.index,
    required this.displayFunction,
    required this.isCornerRows,
    this.autoSizeGroup,
    this.isSmallScreen = false,
    super.key,
  });

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
    final theme = Theme.of(context);
    Color? fgColor = theme.textTheme.labelLarge?.color;

    if (index == (rowData.length - 1) || isCornerRows) {
      fgColor = theme.primaryColor;
    }

    final String text = rowData[index].toString();
    final bool isFunctionWord = _textFunctions.contains(text);
    final bool isSingleChar = text.length == 1 || text == '+/-';

    final double fontSize;
    final double minFontSize;
    final AutoSizeGroup? group;

    if (isFunctionWord) {
      fontSize = 20.0;
      minFontSize = isSmallScreen ? 8.0 : 12.0;
      group = autoSizeGroup;
    } else if (isSingleChar) {
      fontSize = 28.0;
      minFontSize = isSmallScreen ? 9.0 : 16.0;
      group = null;
    } else {
      fontSize = 18.0;
      minFontSize = isSmallScreen ? 8.0 : 10.0;
      group = null;
    }

    final double marginVal = isSmallScreen ? 2.0 : 5.0;

    return Expanded(
      child: Padding(
        padding: EdgeInsets.all(marginVal),
        child: SizedBox.expand(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero,
              elevation: 1.0,
            ).copyWith(
              side: WidgetStateProperty.resolveWith<BorderSide?>(
                (states) => states.contains(WidgetState.focused)
                    ? BorderSide(
                        color: theme.colorScheme.primary,
                        width: 2.5,
                      )
                    : null,
              ),
            ),
            onPressed: displayFunction,
            child: IgnorePointer(
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
    );
  }
}
