import 'package:calculator_lite/Backend/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:calculator_lite/UIElements/fade_in_widget.dart';

class CalcButtons extends StatefulWidget {
  final List rowData;
  final int index;
  final Function displayFunction;
  final bool isCornerRows;

  const CalcButtons(
      {this.rowData,
      this.index,
      this.displayFunction,
      this.isCornerRows,
      Key key})
      : super(key: key);

  @override
  _CalcButtonsState createState() => _CalcButtonsState();
}

class _CalcButtonsState extends State<CalcButtons> {
  @override
  Widget build(BuildContext context) {
    Color fgColor = Theme.of(context)
        .textTheme
        .button
        .color; // Initialized as Default Text Color

    if (widget.index == (widget.rowData.length - 1)) {
      fgColor = Theme.of(context)
          .primaryColor; // Last Column as Index 3 and is always primary color like red or blue
    }
    if (widget.isCornerRows) {
      fgColor = Theme.of(context).primaryColor; // Check if it corners rows
    }

    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(5.0),
              child: ElevatedButton(
                onPressed: widget.displayFunction,
                child: IgnorePointer(
                  child: FadeThis(
                    child: Text(
                      widget.rowData[widget.index].toString(),
                      style: calcButtonTextStyle.copyWith(
                        color: fgColor,
                        fontSize: HelperFunctions().isLandScape(context)
                            ? 15.0
                            : 20.0,
                      ),
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

  TextStyle calcButtonTextStyle = const TextStyle(
    fontWeight: FontWeight.w600,
  );
}
