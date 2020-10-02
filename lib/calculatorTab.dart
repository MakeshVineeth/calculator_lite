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
  bool isSimple = true;
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
      if (value.contains(FixedValues.upperArrow) ||
          value.contains(FixedValues.downArrow))
        changeButtons(); // Up and Down Arrows
      else if (value.contains('inv')) {
        // when inv clicked, inverse buttons.
      } else if (value.contains('C')) {
        calculationString.clear();
        mainValue = 0.0;
      } else if (value.contains(FixedValues.backSpaceChar)) {
        // Back Button
        backSpaceBtn();

        if (calculationString.length > 0)
          runCalcParser(null); // Sending null as backSpaceChar is not a value.
        else
          mainValue = 0;
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
        Container(
          alignment: Alignment.centerRight,
          child: PopupMenuButton(
            itemBuilder: (context) => List.generate(
                menuList.length,
                (index) => PopupMenuItem(
                      value: index,
                      child: Text(menuList[index]),
                    )),
            offset: Offset(0, 50),
            elevation: 5.0,
            icon: Icon(
              Icons.more_vert,
            ),
            onSelected: (value) => popUpFunction(value),
          ),
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
      key: ValueKey(isSimple),
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

  void changeButtons() {
    if (isSimple) {
      isSimple = false;
      _currentChild = buildCalcRows(FixedValues.rowExtras);
    } else {
      isSimple = true;
      _currentChild = buildCalcRows(FixedValues.rowSimple);
    }
  }
}
