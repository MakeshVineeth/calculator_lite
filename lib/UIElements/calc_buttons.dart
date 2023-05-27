import 'package:auto_size_text/auto_size_text.dart';
import 'package:calculator_lite/UIElements/fade_in_widget.dart';
import 'package:flutter/material.dart';

class CalcButtons extends StatefulWidget {
  final List rowData;
  final int index;
  final VoidCallback displayFunction;
  final bool isCornerRows;

  const CalcButtons(
      {required this.rowData,
      required this.index,
      required this.displayFunction,
      required this.isCornerRows,
      Key? key})
      : super(key: key);

  @override
  State<CalcButtons> createState() => _CalcButtonsState();
}

class _CalcButtonsState extends State<CalcButtons> {
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
                    child: AutoSizeText(
                      widget.rowData[widget.index].toString(),
                      style: TextStyle(
                        color: fgColor,
                        fontSize: 30.0,
                      ),
                      minFontSize: 13,
                      overflow: TextOverflow.ellipsis,
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
