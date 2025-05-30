import 'dart:async';
import 'dart:io' show Platform, exit;

import 'package:calculator_lite/Backend/calc_parser.dart';
import 'package:calculator_lite/Backend/custom_focus_events.dart';
import 'package:calculator_lite/Backend/helper_functions.dart';
import 'package:calculator_lite/UIElements/about_page.dart';
import 'package:calculator_lite/UIElements/calc_buttons.dart';
import 'package:calculator_lite/UIElements/display_screen.dart';
import 'package:calculator_lite/UIElements/show_slide_up.dart';
import 'package:calculator_lite/UIElements/theme_chooser.dart';
import 'package:calculator_lite/common_methods/common_methods.dart';
import 'package:calculator_lite/features/secure_mode.dart';
import 'package:calculator_lite/fixed_values.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_ce/hive.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'HistoryTab/Backend/history_functions.dart';
import 'HistoryTab/commons_history.dart';
import 'HistoryTab/history_item.dart';

class CalculatorTab extends StatefulWidget {
  const CalculatorTab({super.key});

  @override
  State<CalculatorTab> createState() => _CalculatorTabState();
}

class _CalculatorTabState extends State<CalculatorTab> {
  late Widget _currentChild;
  bool secondPageFlip = false;
  List<String> calculationString = List.empty(growable: true);
  double mainValue = 0;
  String currentMetric = "";
  Timer? timer;
  final MethodChannel _androidAppRetain =
      const MethodChannel("kotlin.flutter.dev");
  final HelperFunctions _helperFunctions = HelperFunctions();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _currentChild = buildCalcRows(_helperFunctions.isLandScape(context)
        ? FixedValues.horizontalLayout
        : FixedValues.rowSimple);
    getCurrentMetrics();
  }

  @override
  void dispose() {
    if (timer != null && timer!.isActive) {
      timer?.cancel();
    }

    super.dispose();
  }

  void getCurrentMetrics() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getString('metrics') ?? 'RAD';
    setState(() => currentMetric = current);
  }

  void backSpaceBtn() {
    int len = calculationString.length;
    if (len > 0) setState(() => calculationString.removeAt(len - 1));
  }

  void displayToScreen({
    required String value,
    required BuildContext context,
    required CustomFocusEvents focus,
  }) {
    if (timer != null && timer!.isActive) {
      timer?.cancel();
    }

    bool isFocused = focus.isFocused;

    // First check for down or up arrow buttons
    if ([FixedValues.upperArrow, FixedValues.downArrow, FixedValues.invButton]
        .contains(value)) {
      setState(() => changeButtons(value));
    } else if (value.contains('C')) {
      setState(() {
        calculationString.clear();
        mainValue = double.nan;
        if (isFocused) focus.clearData();
      });
    }

    // Back button
    else if (value.contains(FixedValues.backSpaceChar)) {
      if (!isFocused) {
        backSpaceBtn();

        if (calculationString.isNotEmpty) {
          runCalcParser("");
        } else {
          setState(() => mainValue = 0);
        }
      } else {
        setState(() => calculationString =
            focus.removeBack(calculationString: calculationString));

        runCalcParser("");
      }
    }

    // Code for =
    else if (value.contains('=')) {
      if (DisplayScreen.isDoubleValid(mainValue)) {
        String calcStr = calculationString.join();
        addToHistory(calcStr);

        setState(() {
          calculationString.clear();
          calculationString.add(mainValue.toString());
        });
      }
    }

    // at last
    else {
      if (!isFocused) {
        runCalcParser(value);
      } else {
        setState(() => calculationString = focus.getRegulatedString(
              calculationString: calculationString,
              currentMetric: currentMetric,
              value: value,
            ));

        runCalcParser("");
      }
    }
  }

  Future<void> runCalcParser(String value) async {
    final List<String> str = await compute(getCalcStrIsolate, {
      'calculationString': calculationString,
      'value': value,
      'currentMetric': currentMetric,
    });

    setState(() => calculationString = str);

    CalcParser calcParser = CalcParser(
      calculationString: calculationString,
      currentMetric: currentMetric,
    );

    double getValue = await calcParser.getValue();
    setState(() => mainValue = getValue);

    String calcStr = calculationString.join();
    timer = Timer(const Duration(seconds: 6), () => addToHistory(calcStr));
  }

  static List<String> getCalcStrIsolate(Map<dynamic, dynamic> args) {
    // Function to run in isolate.
    CalcParser calcParser = CalcParser(
        calculationString: args['calculationString'],
        currentMetric: args['currentMetric']);

    return calcParser.addToExpression(args['value']);
  }

  void addToHistory(String historyCalcStr) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    String status = preferences.getString(CommonsHistory.historyStatusPref) ??
        CommonsHistory.historyEnabled;

    if (status.contains(CommonsHistory.historyEnabled) &&
        Hive.isBoxOpen(CommonsHistory.historyBox)) {
      final Box box = Hive.box(CommonsHistory.historyBox);

      if (historyCalcStr.isNotEmpty) {
        final DateTime now = DateTime.now();
        final HistoryItem historyItem = HistoryItem(
          expression: historyCalcStr,
          value: mainValue.toString(),
          dateTime: now,
          title: getFormattedTitle(now),
          metrics: currentMetric,
        );

        box.add(historyItem);
      }
    }
  }

  Widget calcRows(List rowData, int index) {
    bool isCornerRows = false;
    if (index == 0) isCornerRows = true;

    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(
          rowData.length,
          (index) => Consumer<CustomFocusEvents>(
            builder: (context, focus, child) => CalcButtons(
              rowData: rowData,
              index: index,
              isCornerRows: isCornerRows,
              displayFunction: () => displayToScreen(
                value: rowData[index].toString(),
                context: context,
                focus: focus,
              ),
            ),
          ),
        ),
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
            children: <Widget>[
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
            flex: _helperFunctions.isLandScape(context) ? 6 : 3,
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
    Map<String, Function> menuList = {
      'Change Theme': () => PopThemeChooser.showThemeChooser(context),
      'Secure Mode': () {
        if (Platform.isAndroid) {
          showDialog(
              context: context, builder: (context) => const PrivacyDialog());
        }
      },
      'Donate': () {
        if (Platform.isAndroid) {
          Navigator.pushNamed(context, FixedValues.buyRoute);
        }
      },
      'FAQ': () => launchThisUrl(url: FixedValues.faqUrl),
      'Rate on Play Store ✨': () => showPlayStorePage(),
      'Privacy Policy': () => launchThisUrl(url: FixedValues.privacyPolicy),
      'About Calculator Lite': () => AboutPage.showAboutDialogFunc(context),
      'Exit': () {
        if (Platform.isAndroid) {
          _androidAppRetain.invokeMethod("sendToBackground");
        } else if (!Platform.isIOS) {
          exit(0);
        } // Not allowed on IOS as it's against Apple Human Interface guidelines to exit the app programmatically.
      }
    };

    return Container(
      alignment: Alignment.centerRight,
      child: IconButton(
        onPressed: () => showSlideUp(
          context: context,
          menuList: menuList,
        ),
        icon: const Icon(
          Icons.more_vert,
        ),
      ),
    );
  }

  Widget metricsButton() => Padding(
        padding: const EdgeInsets.fromLTRB(10, 5, 0, 0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(5.0),
          ),
          onPressed: changeMetrics,
          child: Text(
            currentMetric,
            style: const TextStyle(
              fontWeight: FontWeight.w600, //w600 is semi-bold.
            ),
          ),
        ),
      );

  Widget buildCalcRows(List currentRow) => Column(
        key: UniqueKey(),
        children: List.generate(
            currentRow.length, (index) => calcRows(currentRow[index], index)),
      );

  void changeMetrics() async {
    setState(() {
      if (currentMetric == 'RAD') {
        currentMetric = 'DEG';
      } else {
        currentMetric = 'RAD';
      }
      runCalcParser("");
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('metrics', currentMetric);
  }

  void changeButtons(String value) {
    // If inv clicked, reverse bool var and call changeButtons again with upperArrow to change in second page itself.
    if (value.contains(FixedValues.invButton)) {
      if (secondPageFlip) {
        secondPageFlip = false;
      } else {
        secondPageFlip = true;
      }
      changeButtons(FixedValues.upperArrow);
    }

    // For upper arrow.
    else if (value.contains(FixedValues.upperArrow)) {
      if (secondPageFlip) {
        _currentChild = buildCalcRows(_helperFunctions.isLandScape(context)
            ? FixedValues.horizontalLayoutInverse
            : FixedValues.rowInverse);
      } else {
        _currentChild = buildCalcRows(_helperFunctions.isLandScape(context)
            ? FixedValues.horizontalLayout
            : FixedValues.rowExtras);
      }
    }

    // For down arrow.
    else {
      _currentChild = buildCalcRows(FixedValues.rowSimple);
    }
  }
}
