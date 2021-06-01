import 'dart:async';
import 'package:calculator_lite/Backend/helperFunctions.dart';
import 'package:calculator_lite/common_methods/common_methods.dart';
import 'package:calculator_lite/features/secure_mode.dart';
import 'package:calculator_lite/payments/provider_purchase_status.dart';
import 'package:flutter/foundation.dart';
import 'HistoryTab/commonsHistory.dart';
import 'package:calculator_lite/Backend/customFocusEvents.dart';
import 'package:flutter/material.dart';
import 'package:calculator_lite/UIElements/displayScreen.dart';
import 'package:calculator_lite/UIElements/calcButtons.dart';
import 'package:calculator_lite/UIElements/showSlideUp.dart';
import 'package:calculator_lite/Backend/calcParser.dart';
import 'package:calculator_lite/fixedValues.dart';
import 'package:hive/hive.dart';
import 'HistoryTab/historyItem.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'HistoryTab/Backend/historyFunctions.dart';
import 'package:calculator_lite/UIElements/aboutPage.dart';
import 'package:calculator_lite/UIElements/themeChooser.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform, exit;

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
  Timer timer;
  final MethodChannel _androidAppRetain = MethodChannel("kotlin.flutter.dev");
  final HelperFunctions _helperFunctions = HelperFunctions();
  PurchaseStatusProvider _purchaseStatusProvider;

  @override
  void initState() {
    super.initState();
  }

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
    super.dispose();
    if (timer != null) timer.cancel();
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
    @required String value,
    @required BuildContext context,
    @required CustomFocusEvents focus,
  }) {
    if (timer != null && timer.isActive) timer.cancel();
    bool isFocused = focus.isFocused;

    // First check for down or up arrow buttons
    if ([FixedValues.upperArrow, FixedValues.downArrow, FixedValues.invButton]
        .contains(value))
      setState(() => changeButtons(value));

    // Clear button
    else if (value.contains('C')) {
      setState(() {
        calculationString.clear();
        mainValue = null;
        if (isFocused) focus.clearData();
      });
    }

    // Back button
    else if (value.contains(FixedValues.backSpaceChar)) {
      if (!isFocused) {
        backSpaceBtn();

        if (calculationString.length > 0)
          runCalcParser(null); // Sending null as backSpaceChar is not a value.
        else
          setState(() => mainValue = 0);
      } else {
        setState(() => calculationString =
            focus.removeBack(calculationString: calculationString) ??
                calculationString);

        runCalcParser(null);
      }
    }

    // Code for =
    else if (value.contains('=')) {
      if (DisplayScreen.isDoubleValid(mainValue)) {
        addToHistory();

        setState(() {
          calculationString.clear();
          calculationString.add(mainValue.toString());
        });
      }
    }

    // at last
    else {
      if (!isFocused)
        runCalcParser(value);
      else {
        setState(() => calculationString = focus.getRegulatedString(
                calculationString: calculationString,
                currentMetric: currentMetric,
                value: value) ??
            calculationString);

        runCalcParser(null);
      }
    }
  }

  Future<void> runCalcParser(String value) async {
    if (value != null) {
      List<String> str = await compute(getCalcStrIsolate, {
        'calculationString': calculationString,
        'value': value,
        'currentMetric': currentMetric,
      });

      setState(() => calculationString = str ?? calculationString);
    }

    CalcParser calcParser = CalcParser(
        calculationString: calculationString, currentMetric: currentMetric);
    double getValue = await calcParser.getValue();
    setState(() => mainValue = getValue);

    timer = Timer(Duration(seconds: 5), () => addToHistory());
  }

  static List<String> getCalcStrIsolate(Map<dynamic, dynamic> args) {
    // Function to run in isolate.
    CalcParser calcParser = CalcParser(
        calculationString: args['calculationString'],
        currentMetric: args['currentMetric']);
    return calcParser?.addToExpression(args['value']);
  }

  void addToHistory() {
    if (Hive.isBoxOpen(CommonsHistory.historyBox)) {
      final Box box = Hive.box(CommonsHistory.historyBox);

      if (calculationString.length > 0 && mainValue != null) {
        DateTime now = DateTime.now();
        final HistoryItem historyItem = HistoryItem(
          expression: calculationString.join(),
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
    _purchaseStatusProvider = Provider.of<PurchaseStatusProvider>(context);

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
        if (_purchaseStatusProvider.hasPurchased || Platform.isWindows)
          showDialog(context: context, builder: (context) => PrivacyDialog());
        else
          Navigator.pushNamed(context, FixedValues.buyRoute);
      },
      'Get Pro Edition': () {
        if (Platform.isAndroid)
          Navigator.pushNamed(context, FixedValues.buyRoute);
      },
      'Rate on Play Store ✨': () => launchUrl(
          url:
              'https://play.google.com/store/apps/details?id=com.makeshtech.calculator_lite'),
      'Privacy Policy': () =>
          launchUrl(url: 'https://makeshvineeth.github.io/privacy_policy/'),
      'About Calculator Lite': () => AboutPage.showAboutDialogFunc(context),
      'Exit': () {
        if (Platform.isAndroid)
          _androidAppRetain.invokeMethod("sendToBackground");
        else if (!Platform.isIOS)
          exit(
              0); // Not allowed on IOS as it's against Apple Human Interface guidelines to exit the app programmatically.
      }
    };

    return Container(
      alignment: Alignment.centerRight,
      child: IconButton(
        onPressed: () => showSlideUp(
          context: context,
          menuList: menuList,
        ),
        icon: Icon(
          Icons.more_vert,
        ),
      ),
    );
  }

  Widget metricsButton() => Container(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 5, 0, 0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.all(5.0),
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

  Widget buildCalcRows(List currentRow) => Column(
        key: UniqueKey(),
        children: List.generate(
            currentRow.length, (index) => calcRows(currentRow[index], index)),
      );

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
        _currentChild = buildCalcRows(_helperFunctions.isLandScape(context)
            ? FixedValues.horizontalLayoutInverse
            : FixedValues.rowInverse);
      else
        _currentChild = buildCalcRows(_helperFunctions.isLandScape(context)
            ? FixedValues.horizontalLayout
            : FixedValues.rowExtras);
    }

    // For down arrow.
    else
      _currentChild = buildCalcRows(FixedValues.rowSimple);
  }
}
