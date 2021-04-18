import 'package:calculator_lite/Backend/helperFunctions.dart';
import 'package:calculator_lite/CurrencyTab/currencyTab.dart';
import 'package:calculator_lite/Export_Screen/export_screen.dart';
import 'package:calculator_lite/HistoryTab/historyTab.dart';
import 'package:calculator_lite/calculatorTab.dart';
import 'package:calculator_lite/common_methods/common_methods.dart';
import 'package:calculator_lite/payments/payments_wrapper.dart';
import 'package:calculator_lite/payments/pro_screen.dart';
import 'package:flutter/material.dart';
import 'package:calculator_lite/bottomNavClass.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:calculator_lite/fixedValues.dart';
import 'package:calculator_lite/Backend/themeChange.dart';
import 'package:calculator_lite/UIElements/fade_indexed_page.dart';
import 'dart:io' show Platform;
import 'package:calculator_lite/CurrencyTab/Backend/currencyListItem.dart';
import 'HistoryTab/historyItem.dart';
import 'package:calculator_lite/screens/privacy_policy.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  InAppPurchaseConnection.enablePendingPurchases();
  await Hive.initFlutter('hiveUserData');
  Hive.registerAdapter(CurrencyListItemAdapter());
  Hive.registerAdapter(HistoryItemAdapter());
  runApp(BottomNavBar());
}

class BottomNavBar extends StatefulWidget {
  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  ThemeMode setTheme = ThemeMode.system;

  void getThemeStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString('theme') ?? 'System Default';
    ThemeMode themeMode = MiniThemeFunctions.parseTheme(themeString);
    setThemeFunction(themeMode);
  }

  void setThemeFunction(ThemeMode themeMode) =>
      setState(() => setTheme = themeMode);

  @override
  void initState() {
    super.initState();
    getThemeStatus();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeChange(
      stateFunction: setThemeFunction,
      child: (Platform.isAndroid)
          ? PaymentsWrapper(child: materialApp(setTheme))
          : materialApp(setTheme),
    );
  }
}

Widget materialApp(final ThemeMode setTheme) {
  return MaterialApp(
    title: FixedValues.appName,
    debugShowCheckedModeBanner: false,
    themeMode: setTheme,
    theme: FixedValues.getTotalData(Brightness.light),
    darkTheme: FixedValues.getTotalData(Brightness.dark),
    initialRoute: '/',
    routes: {
      '/': (context) => ScaffoldHome(),
      '/privacy': (context) => PrivacyPolicy(),
      '/export': (context) => ExportScreen(),
      '/buy': (context) => ProScreen(),
    },
  );
}

class ScaffoldHome extends StatefulWidget {
  @override
  _ScaffoldHomeState createState() => _ScaffoldHomeState();
}

class _ScaffoldHomeState extends State<ScaffoldHome>
    with WidgetsBindingObserver {
  int _currentIndex = 1;
  double _landScapeFont = 10.0;
  double _iconSizeLandscape = 15.0;
  final HelperFunctions _helperFunctions = HelperFunctions();

  Map e = {
    'Currency': Icons.monetization_on_outlined,
    'Calculator': Icons.calculate_outlined,
    'History': Icons.history_outlined
  };

  List<Widget> availableWidgets = [
    CurrencyTab(),
    CalculatorTab(),
    HistoryTab()
  ];

  void _onItemTapped(int index) {
    FocusScope.of(context).unfocus();
    if (mounted) setState(() => _currentIndex = index);
  }

  void setFlatStatusBar() {
    try {
      if (!(Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
        // Must be executed every time the theme changes.
        FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);
        ThemeData temp = Theme.of(context);
        bool useWhiteForeground =
            (temp.brightness == Brightness.dark) ? true : false;
        FlutterStatusbarcolor.setStatusBarWhiteForeground(useWhiteForeground);

        bool isLightTheme = Theme.of(context).brightness == Brightness.light;
        FlutterStatusbarcolor.setNavigationBarColor(
            isLightTheme ? Colors.white : Colors.black);
        FlutterStatusbarcolor.setNavigationBarWhiteForeground(
            useWhiteForeground);
      }
    } catch (e) {}
  }

  @override
  void initState() {
    super.initState();
    doInitialTasks();
    WidgetsBinding.instance.addObserver(this);
  }

  void doInitialTasks() async {
    if (Platform.isAndroid) {
      bool _disabled = await getPrefs('privacy', true);
      setSecure(_disabled);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) setFlatStatusBar();
  }

  @override
  Widget build(BuildContext context) {
    setFlatStatusBar();
    return Scaffold(
      body: SafeArea(
        child: FadeIndexedStack(
          index: _currentIndex,
          children: availableWidgets,
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: _helperFunctions.isLandScape(context) ? 40 : 58,
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedLabelStyle: FixedValues.semiBoldStyle,
          unselectedLabelStyle: FixedValues.semiBoldStyle,
          elevation: 0,
          iconSize:
              _helperFunctions.isLandScape(context) ? _iconSizeLandscape : 24.0,
          selectedFontSize:
              _helperFunctions.isLandScape(context) ? _landScapeFont : 14.0,
          unselectedFontSize:
              _helperFunctions.isLandScape(context) ? _landScapeFont : 12.0,
          type: BottomNavigationBarType.fixed,
          items: List.generate(
              e.length,
              (index) => BottomNavClass(
                    title: e.keys.elementAt(index),
                    icon: e.values.elementAt(index),
                  ).returnNavItems()),
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
