import 'package:calculator_lite/Backend/customFocusEvents.dart';
import 'package:flutter/material.dart';
import 'package:calculator_lite/UIElements/displayScreen.dart';
import 'package:calculator_lite/UIElements/calcButtons.dart';
import 'package:calculator_lite/UIElements/showSlideUp.dart';
import 'package:calculator_lite/Backend/calcParser.dart';
import 'package:calculator_lite/fixedValues.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class CalculatorTab extends StatefulWidget {
  @override
  _CalculatorTabState createState() => _CalculatorTabState();
}

class _CalculatorTabState extends State<CalculatorTab> {
  Widget _currentChild;
  bool secondPageFlip = false;
  List<String> calculationString = [];
  double mainValue;
  String currentMetric;

  @override
  void initState() {
    super.initState();
    _currentChild = buildCalcRows(FixedValues.rowSimple);
    getCurrentMetrics();
  }

  void getCurrentMetrics() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getString('metrics') ?? 'RAD';

    setState(() {
      currentMetric = current;
    });
  }

  void backSpaceBtn() {
    int len = calculationString.length;
    if (len > 0) {
      calculationString.removeAt(len - 1);
    }
  }

  void displayToScreen(
      {@required String value,
      @required BuildContext context,
      @required CustomFocusEvents focus}) {
    bool isFocused = focus.isFocused;
    setState(() {
      // First check for down or up arrow buttons
      if ([FixedValues.upperArrow, FixedValues.downArrow, FixedValues.invButton]
          .contains(value))
        changeButtons(value);

      // Clear button
      else if (value.contains('C')) {
        calculationString.clear();
        mainValue = null;
        if (isFocused) focus.clearData();
      }

      // Back button
      else if (value.contains(FixedValues.backSpaceChar)) {
        if (!isFocused) {
          backSpaceBtn();

          if (calculationString.length > 0)
            runCalcParser(
                null); // Sending null as backSpaceChar is not a value.
          else
            mainValue = 0;
        } else {
          calculationString =
              focus.removeBack(calculationString: calculationString) ??
                  calculationString;
          runCalcParser(null);
        }
      }

      // Code for =
      else if (value.contains('=')) {
        // Incomplete for now.
        calculationString.clear();
        calculationString.add(mainValue.toString());
      }

      // at last
      else {
        if (!isFocused)
          runCalcParser(value);
        else {
          calculationString = focus.getRegulatedString(
                  calculationString: calculationString,
                  currentMetric: currentMetric,
                  value: value) ??
              calculationString;
          runCalcParser(null);
        }
      }
    });
  }

  void runCalcParser(String value) {
    CalcParser calcParser = CalcParser(
        calculationString: calculationString, currentMetric: currentMetric);
    if (value != null)
      calculationString =
          calcParser.addToExpression(value) ?? calculationString;
    mainValue = calcParser.getValue();
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
        children: List.generate(rowData.length, (index) {
          return Consumer<CustomFocusEvents>(
            builder: (context, focus, child) {
              return CalcButtons(
                rowData: rowData,
                index: index,
                isCornerRows: isCornerRows,
                displayFunction: () {
                  displayToScreen(
                      value: rowData[index].toString(),
                      context: context,
                      focus: focus);
                },
              );
            },
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CustomFocusEvents(),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              metricsButton(),
              popUpDotMenu(),
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
      ),
    );
  }

  Widget popUpDotMenu() {
    return Container(
      alignment: Alignment.centerRight,
      child: IconButton(
        onPressed: () => showSlideUp(context),
        icon: Icon(
          Icons.more_vert,
        ),
      ),
    );
  }

  Widget metricsButton() {
    return Container(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 5, 0, 0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
          ),
          onPressed: changeMetrics,
          child: Text(
            '$currentMetric',
            style: TextStyle(
              fontWeight: FontWeight.w600, //w600 is semi-bold.
            ),
          ),
        ),
      ),
    );
  }

  Widget buildCalcRows(List currentRow) {
    return Column(
      key: UniqueKey(),
      children: List.generate(
          currentRow.length, (index) => calcRows(currentRow[index], index)),
    );
  }

  void changeMetrics() async {
    setState(() {
      if (currentMetric == 'RAD')
        currentMetric = 'DEG';
      else
        currentMetric = 'RAD';
      runCalcParser(null);
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('metrics', currentMetric);
  }

  void changeButtons(String value) {
    // If inv clicked, reverse bool var and call changeButtons again with upperArrow to change in second page itself.
    if (value.contains(FixedValues.invButton)) {
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
