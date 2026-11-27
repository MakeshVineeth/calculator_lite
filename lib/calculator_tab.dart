import 'dart:async';
import 'dart:io' show Platform, exit;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:calculator_lite/Backend/calc_parser.dart';
import 'package:calculator_lite/Backend/custom_focus_events.dart';
import 'package:calculator_lite/Backend/helper_functions.dart';
import 'package:calculator_lite/Backend/hive_initializer.dart';
import 'package:calculator_lite/UIElements/about_page.dart';
import 'package:calculator_lite/UIElements/calc_buttons.dart';
import 'package:calculator_lite/UIElements/display_screen.dart';
import 'package:calculator_lite/UIElements/edit_text.dart';
import 'package:calculator_lite/UIElements/show_slide_up.dart';
import 'package:calculator_lite/UIElements/theme_chooser.dart';
import 'package:calculator_lite/common_methods/common_methods.dart';
import 'package:calculator_lite/features/secure_mode.dart';
import 'package:calculator_lite/fixed_values.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_ce/hive.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'HistoryTab/Backend/history_functions.dart';
import 'HistoryTab/commons_history.dart';
import 'HistoryTab/history_item.dart';

class CalculatorTab extends StatefulWidget {
  final bool isActive;

  const CalculatorTab({this.isActive = true, super.key});

  @override
  State<CalculatorTab> createState() => _CalculatorTabState();
}

class _CalculatorTabState extends State<CalculatorTab> {
  late Widget _currentChild;
  bool _isExtrasOpen = false;
  bool secondPageFlip = false;
  bool? _lastIsLandscape;
  bool? _lastIsSmallScreen;
  List<String> calculationString = List.empty(growable: true);
  double mainValue = 0;
  String currentMetric = '';
  Timer? timer;
  final MethodChannel _androidAppRetain =
      const MethodChannel('kotlin.flutter.dev');
  final HelperFunctions _helperFunctions = const HelperFunctions();
  final AutoSizeGroup _advKeypadGroup = AutoSizeGroup();
  final CustomFocusEvents _customFocusEvents = CustomFocusEvents();

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleHardwareKey);
    getCurrentMetrics();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bool isLandscape = _helperFunctions.isLandScape(context);
    final Size screenSize = MediaQuery.sizeOf(context);
    final bool isSmallScreen =
        screenSize.width < 360 || screenSize.height < 450;

    if (_lastIsLandscape != isLandscape ||
        _lastIsSmallScreen != isSmallScreen) {
      _lastIsLandscape = isLandscape;
      _lastIsSmallScreen = isSmallScreen;
      _rebuildActiveKeypad(
        isLandscape: isLandscape,
        isSmallScreen: isSmallScreen,
      );
    }
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleHardwareKey);
    timer?.cancel();
    _customFocusEvents.dispose();
    super.dispose();
  }

  void getCurrentMetrics() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final current = prefs.getString('metrics') ?? 'RAD';
    setState(() => currentMetric = current);
  }

  void _rebuildActiveKeypad({
    required bool isLandscape,
    required bool isSmallScreen,
  }) {
    if (isLandscape) {
      final rows = secondPageFlip
          ? FixedValues.horizontalLayoutInverse
          : FixedValues.horizontalLayout;
      _currentChild = buildCalcRows(
        rows,
        keypadKey: secondPageFlip ? 'land_inverse' : 'land',
        autoSizeGroup: _advKeypadGroup,
        isSmallScreen: isSmallScreen,
      );
      return;
    }

    if (secondPageFlip) {
      _currentChild = buildCalcRows(
        FixedValues.rowInverse,
        keypadKey: 'inverse',
        autoSizeGroup: _advKeypadGroup,
        isSmallScreen: isSmallScreen,
      );
    } else if (_isExtrasOpen) {
      _currentChild = buildCalcRows(
        FixedValues.rowExtras,
        keypadKey: 'extras',
        autoSizeGroup: _advKeypadGroup,
        isSmallScreen: isSmallScreen,
      );
    } else {
      _currentChild = buildCalcRows(
        FixedValues.rowSimple,
        keypadKey: 'simple',
        isSmallScreen: isSmallScreen,
      );
    }
  }

  void backSpaceBtn() {
    final int len = calculationString.length;
    if (len > 0) setState(() => calculationString.removeAt(len - 1));
  }

  List<String> _tokensFromResult(double value) {
    String formatted = DisplayScreen.formatNumber(value);
    if (formatted.contains('e')) {
      final exactDecimal = Decimal.tryParse(value.toString());
      if (exactDecimal != null) {
        final plain = exactDecimal.toString();
        if (plain.length <= 24) {
          formatted = plain;
        } else {
          final parts = formatted.split('e');
          if (parts.length == 2) {
            final mantissa = parts[0].replaceAll('-', FixedValues.minus);
            final expStr =
                parts[1].replaceFirst('+', '').replaceAll('-', FixedValues.minus);
            return [
              ...mantissa.split(''),
              FixedValues.multiplyChar,
              '1',
              '0',
              '^',
              '(',
              ...expStr.split(''),
              ')',
            ];
          }
        }
      }
    }
    return formatted.replaceAll('-', FixedValues.minus).split('');
  }

  void displayToScreen({
    required String value,
    required BuildContext context,
    required CustomFocusEvents focus,
  }) {
    timer?.cancel();

    final bool isFocused = focus.isFocused;

    if ([FixedValues.upperArrow, FixedValues.downArrow, FixedValues.invButton]
        .contains(value)) {
      setState(() => changeButtons(value));
    } else if (value.contains('C')) {
      setState(() {
        calculationString.clear();
        mainValue = 0;
        if (isFocused) focus.clearData();
      });
    } else if (value.contains(FixedValues.backSpaceChar)) {
      if (!isFocused) {
        backSpaceBtn();
        if (calculationString.isNotEmpty) {
          runCalcParser('');
        } else {
          setState(() => mainValue = 0);
        }
      } else {
        setState(
          () => calculationString =
              focus.removeBack(calculationString: calculationString),
        );
        runCalcParser('');
      }
    } else if (value.contains('=')) {
      if (DisplayScreen.isDoubleValid(mainValue) && mainValue.isFinite) {
        final String calcStr = calculationString.join();
        final double valueSnapshot = mainValue;
        final String metricSnapshot = currentMetric;
        addToHistory(calcStr, valueSnapshot, metricSnapshot);

        setState(() {
          focus.clearData();
          calculationString.clear();
          calculationString.addAll(_tokensFromResult(valueSnapshot));
        });
      }
    } else {
      if (!isFocused) {
        runCalcParser(value);
      } else {
        setState(
          () => calculationString = focus.getRegulatedString(
            calculationString: calculationString,
            currentMetric: currentMetric,
            value: value,
          ),
        );
        runCalcParser('');
      }
    }
  }

  void runCalcParser(String value) {
    timer?.cancel();
    final CalcParser calcParser = CalcParser(
      calculationString: List<String>.from(calculationString),
      currentMetric: currentMetric,
    );

    final List<String> updatedString = value.isEmpty
        ? List<String>.from(calculationString)
        : calcParser.addToExpression(value);
    calcParser.calculationString = updatedString;
    final double computedValue = calcParser.evalFunction(updatedString);

    setState(() {
      calculationString = updatedString;
      mainValue = computedValue;
    });

    if (DisplayScreen.isDoubleValid(computedValue) && computedValue.isFinite) {
      final String calcStr = updatedString.join();
      final String metricSnapshot = currentMetric;
      timer = Timer(
        const Duration(seconds: 6),
        () => addToHistory(calcStr, computedValue, metricSnapshot),
      );
    }
  }

  void addToHistory(
    String historyCalcStr,
    double valueSnapshot,
    String metricSnapshot,
  ) async {
    if (historyCalcStr.isEmpty ||
        valueSnapshot.isNaN ||
        valueSnapshot.isInfinite) {
      return;
    }

    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String status =
        preferences.getString(CommonsHistory.historyStatusPref) ??
            CommonsHistory.historyEnabled;

    if (!status.contains(CommonsHistory.historyEnabled)) return;

    await HiveInitializer.ensureInitialized();
    final Box<HistoryItem> box = Hive.isBoxOpen(CommonsHistory.historyBox)
        ? Hive.box<HistoryItem>(CommonsHistory.historyBox)
        : await Hive.openBox<HistoryItem>(CommonsHistory.historyBox);

    final DateTime now = DateTime.now();
    final HistoryItem historyItem = HistoryItem(
      expression: historyCalcStr,
      value: valueSnapshot.toString(),
      dateTime: now,
      title: getFormattedTitle(now),
      metrics: metricSnapshot,
    );

    await box.add(historyItem);
  }

  Widget calcRows(
    List<dynamic> rowData,
    int rowIndex, {
    AutoSizeGroup? autoSizeGroup,
    bool isSmallScreen = false,
  }) {
    final bool isCornerRows = rowIndex == 0;

    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(
          rowData.length,
          (colIndex) => CalcButtons(
            rowData: rowData,
            index: colIndex,
            isCornerRows: isCornerRows,
            autoSizeGroup: autoSizeGroup,
            isSmallScreen: isSmallScreen,
            displayFunction: () => displayToScreen(
              value: rowData[colIndex].toString(),
              context: context,
              focus: _customFocusEvents,
            ),
          ),
        ),
      ),
    );
  }

  static final Map<LogicalKeyboardKey, String> _keyMap = {
    LogicalKeyboardKey.digit0: '0',
    LogicalKeyboardKey.numpad0: '0',
    LogicalKeyboardKey.digit1: '1',
    LogicalKeyboardKey.numpad1: '1',
    LogicalKeyboardKey.digit2: '2',
    LogicalKeyboardKey.numpad2: '2',
    LogicalKeyboardKey.digit3: '3',
    LogicalKeyboardKey.numpad3: '3',
    LogicalKeyboardKey.digit4: '4',
    LogicalKeyboardKey.numpad4: '4',
    LogicalKeyboardKey.digit5: '5',
    LogicalKeyboardKey.numpad5: '5',
    LogicalKeyboardKey.digit6: '6',
    LogicalKeyboardKey.numpad6: '6',
    LogicalKeyboardKey.digit7: '7',
    LogicalKeyboardKey.numpad7: '7',
    LogicalKeyboardKey.digit8: '8',
    LogicalKeyboardKey.numpad8: '8',
    LogicalKeyboardKey.digit9: '9',
    LogicalKeyboardKey.numpad9: '9',
    LogicalKeyboardKey.period: '.',
    LogicalKeyboardKey.numpadDecimal: '.',
    LogicalKeyboardKey.add: '+',
    LogicalKeyboardKey.numpadAdd: '+',
    LogicalKeyboardKey.minus: FixedValues.minus,
    LogicalKeyboardKey.numpadSubtract: FixedValues.minus,
    LogicalKeyboardKey.asterisk: FixedValues.multiplyChar,
    LogicalKeyboardKey.numpadMultiply: FixedValues.multiplyChar,
    LogicalKeyboardKey.slash: FixedValues.divisionChar,
    LogicalKeyboardKey.numpadDivide: FixedValues.divisionChar,
    LogicalKeyboardKey.enter: '=',
    LogicalKeyboardKey.numpadEnter: '=',
    LogicalKeyboardKey.equal: '=',
    LogicalKeyboardKey.backspace: FixedValues.backSpaceChar,
    LogicalKeyboardKey.delete: FixedValues.backSpaceChar,
    LogicalKeyboardKey.escape: 'C',
    LogicalKeyboardKey.keyC: 'C',
  };

  bool _handleHardwareKey(KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    if (!mounted || !widget.isActive) return false;
    if (ModalRoute.of(context)?.isCurrent != true) return false;

    final focusContext = FocusManager.instance.primaryFocus?.context;
    if (focusContext != null) {
      final hasEditable =
          focusContext.findAncestorWidgetOfExactType<EditableText>() != null;
      final isCalcInput =
          focusContext.findAncestorWidgetOfExactType<TextFieldCalc>() != null;
      if (hasEditable && !isCalcInput) {
        return false;
      }
    }

    final char = event.character;
    if (char != null) {
      String? charMapped;
      if (char == '+') {
        charMapped = '+';
      } else if (char == '-') {
        charMapped = FixedValues.minus;
      } else if (char == '*') {
        charMapped = FixedValues.multiplyChar;
      } else if (char == '/') {
        charMapped = FixedValues.divisionChar;
      } else if (const ['(', ')', '%', '^', '.', '='].contains(char)) {
        charMapped = char;
      }
      if (charMapped != null) {
        displayToScreen(
          value: charMapped,
          context: context,
          focus: _customFocusEvents,
        );
        return true;
      }
    }

    final mappedVal = _keyMap[event.logicalKey];
    if (mappedVal != null) {
      displayToScreen(
        value: mappedVal,
        context: context,
        focus: _customFocusEvents,
      );
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.sizeOf(context);
    final bool isLand = _helperFunctions.isLandScape(context);
    final double maxW = isLand ? 960.0 : 650.0;
    final bool isCompact = screenSize.width < 360 || screenSize.height < 450;

    return ChangeNotifierProvider<CustomFocusEvents>.value(
      value: _customFocusEvents,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxW),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  metricsButton(isCompact: isCompact),
                  popUpDotMenu(isCompact: isCompact),
                ],
              ),
              DisplayScreen(
                calculationString: calculationString,
                mainValue: mainValue,
              ),
              Expanded(
                flex: isLand ? 4 : 3,
                child: Padding(
                  padding: EdgeInsets.all(isCompact ? 2.0 : 5.0),
                  child: RepaintBoundary(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _currentChild,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, Function> _buildDotMenu() => {
    'Change Theme': () => PopThemeChooser.showThemeChooser(context),
    'Secure Mode': () {
      if (Platform.isAndroid) {
        showDialog<void>(
          context: context,
          builder: (context) => const PrivacyDialog(),
        );
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
        _androidAppRetain.invokeMethod<void>('sendToBackground');
      } else if (!Platform.isIOS) {
        exit(0);
      }
    },
  };

  Widget popUpDotMenu({bool isCompact = false}) {
    return Container(
      alignment: Alignment.centerRight,
      child: IconButton(
        padding:
            isCompact ? const EdgeInsets.all(4.0) : const EdgeInsets.all(8.0),
        constraints: isCompact ? const BoxConstraints() : null,
        visualDensity: isCompact ? VisualDensity.compact : null,
        onPressed: () => showSlideUp(
          context: context,
          menuList: _buildDotMenu(),
        ),
        icon: const Icon(Icons.more_vert),
      ),
    );
  }

  Widget metricsButton({bool isCompact = false}) => Padding(
    padding: EdgeInsets.fromLTRB(10, isCompact ? 0 : 5, 0, 0),
    child: SizedBox(
      height: isCompact ? 30 : null,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 8.0 : 12.0,
            vertical: isCompact ? 2.0 : 5.0,
          ),
        ),
        onPressed: changeMetrics,
        child: Text(
          currentMetric,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    ),
  );

  Widget buildCalcRows(
    List<List<dynamic>> currentRow, {
    required String keypadKey,
    AutoSizeGroup? autoSizeGroup,
    bool isSmallScreen = false,
  }) =>
      Column(
        key: ValueKey<String>(keypadKey),
        children: List.generate(
          currentRow.length,
          (index) => calcRows(
            currentRow[index],
            index,
            autoSizeGroup: autoSizeGroup,
            isSmallScreen: isSmallScreen,
          ),
        ),
      );

  void changeMetrics() async {
    currentMetric = currentMetric == 'RAD' ? 'DEG' : 'RAD';
    if (calculationString.isNotEmpty) {
      runCalcParser('');
    } else {
      setState(() {});
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('metrics', currentMetric);
  }

  void changeButtons(String value) {
    final bool isLandscape = _helperFunctions.isLandScape(context);
    final Size screenSize = MediaQuery.sizeOf(context);
    final bool isSmallScreen =
        screenSize.width < 360 || screenSize.height < 450;

    if (value.contains(FixedValues.invButton)) {
      secondPageFlip = !secondPageFlip;
      _isExtrasOpen = true;
    } else if (value.contains(FixedValues.upperArrow)) {
      _isExtrasOpen = true;
    } else {
      _isExtrasOpen = false;
      secondPageFlip = false;
    }

    _rebuildActiveKeypad(
      isLandscape: isLandscape,
      isSmallScreen: isSmallScreen,
    );
  }
}
