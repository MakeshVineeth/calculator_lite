import 'package:flutter/material.dart';
import 'package:calculator_lite/UIElements/themeChooser.dart';
import 'package:calculator_lite/UIElements/displayScreen.dart';
import 'package:calculator_lite/UIElements/calcButtons.dart';
import 'package:calculator_lite/Backend/calcParser.dart';
import 'package:calculator_lite/fixedValues.dart';
import 'package:calculator_lite/UIElements/aboutPage.dart';

class CalculatorTab extends StatefulWidget {
  @override
  _CalculatorTabState createState() => _CalculatorTabState();
}

class _CalculatorTabState extends State<CalculatorTab> {
  Widget _currentChild;
  bool secondPageFlip = false;
  List<String> calculationString = [];
  double mainValue = 0.0;
  List<String> menuList = ['About', 'Change Theme'];

  @override
  void initState() {
    super.initState();
    _currentChild = buildCalcRows(FixedValues.rowSimple);
  }

  void backSpaceBtn() {
    int len = calculationString.length;
    if (len > 0) {
      calculationString.removeAt(len - 1);
    }
  }

  void displayToScreen(String value) {
    setState(() {
      // First check for down or up arrow buttons
      if ([FixedValues.upperArrow, FixedValues.downArrow, 'inv']
          .contains(value))
        changeButtons(value);

      // Clear button
      else if (value.contains('C')) {
        calculationString.clear();
        mainValue = 0.0;
      }

      // Back button
      else if (value.contains(FixedValues.backSpaceChar)) {
        backSpaceBtn();

        if (calculationString.length > 0)
          runCalcParser(null); // Sending null as backSpaceChar is not a value.
        else
          mainValue = 0;
      }

      // Code for =
      else if (value.contains('=')) {
        // Incomplete for now.
        calculationString.clear();
        calculationString.add(mainValue.toString());
      } else
        runCalcParser(value);
    });
  }

  void runCalcParser(String value) {
    CalcParser calcParser = CalcParser(calculationString: calculationString);
    if (value != null) calculationString = calcParser.addToExpression(value);
    mainValue = calcParser.getValue() ??
        mainValue; // Used null-aware operator to default to mainValue in case of null.
  }

  Widget calcRows(List rowData, int index) {
    bool isCornerRows = false;
    if (index == 0) {
      isCornerRows = true;
    }
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(
            rowData.length,
            (index) => CalcButtons(
                  rowData: rowData,
                  index: index,
                  isCornerRows: isCornerRows,
                  displayFunction: () {
                    displayToScreen(
                      rowData[index].toString(),
                    );
                  },
                )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              child: MaterialButton(
                minWidth: 30,
                onPressed: () {},
                child: Text('RAD'),
              ),
            ),
            Container(
              alignment: Alignment.centerRight,
              child: PopupMenuButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                itemBuilder: (context) => List.generate(
                    menuList.length,
                    (index) => PopupMenuItem(
                          value: index,
                          child: Text(menuList[index]),
                        )),
                elevation: 5.0,
                icon: Icon(
                  Icons.more_vert,
                ),
                onSelected: (value) => popUpFunction(value),
              ),
            ),
          ],
        ),
        // Display Widget
        DisplayScreen(
          calculationString: calculationString,
          mainValue: mainValue,
        ),
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _currentChild,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildCalcRows(List currentRow) {
    return Column(
      key: UniqueKey(),
      children: List.generate(
          currentRow.length, (index) => calcRows(currentRow[index], index)),
    );
  }

  void popUpFunction(int value) {
    switch (value) {
      case 0:
        AboutPage.showAboutDialogFunc(context);
        break;
      case 1:
        PopThemeChooser.showThemeChooser(context);
        break;
    }
  }

  void changeButtons(String value) {
    // If inv clicked, reverse bool var and call changeButtons again with upperArrow to change in second page itself.
    if (value.contains('inv')) {
      if (secondPageFlip)
        secondPageFlip = false;
      else
        secondPageFlip = true;
      changeButtons(FixedValues.upperArrow);
    }

    // For upper arrow.
    else if (value.contains(FixedValues.upperArrow)) {
      if (secondPageFlip)
        _currentChild = buildCalcRows(FixedValues.rowInverse);
      else
        _currentChild = buildCalcRows(FixedValues.rowExtras);
    }

    // For down arrow.
    else
      _currentChild = buildCalcRows(FixedValues.rowSimple);
  }
}
