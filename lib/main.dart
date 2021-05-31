import 'package:calculator_lite/Backend/helperFunctions.dart';
import 'package:calculator_lite/CurrencyTab/currencyTab.dart';
import 'package:calculator_lite/Export_Screen/export_screen.dart';
import 'package:calculator_lite/HistoryTab/historyTab.dart';
import 'package:calculator_lite/calculatorTab.dart';
import 'package:calculator_lite/common_methods/common_methods.dart';
import 'package:calculator_lite/payments/payments_wrapper.dart';
import 'package:calculator_lite/payments/pro_screen.dart';
import 'package:calculator_lite/payments/provider_purchase_status.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:calculator_lite/bottomNavClass.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:calculator_lite/fixedValues.dart';
import 'package:calculator_lite/Backend/themeChange.dart';
import 'package:calculator_lite/UIElements/fade_indexed_page.dart';
import 'dart:io' show Platform;
import 'package:calculator_lite/CurrencyTab/Backend/currencyListItem.dart';
import 'HistoryTab/historyItem.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (defaultTargetPlatform == TargetPlatform.android)
    InAppPurchaseAndroidPlatformAddition.enablePendingPurchases();

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
          : ChangeNotifierProvider<PurchaseStatusProvider>.value(
              value: PurchaseStatusProvider(),
              child: materialApp(setTheme),
            ),
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
      '/export': (context) => ExportScreen(),
      FixedValues.buyRoute: (context) => ProScreen(),
    },
  );
}

class ScaffoldHome extends StatefulWidget {
  @override
  _ScaffoldHomeState createState() => _ScaffoldHomeState();
}

class _ScaffoldHomeState extends State<ScaffoldHome> {
  int _currentIndex = 1;
  final double _landScapeFont = 10.0;
  final double _iconSizeLandscape = 15.0;
  final HelperFunctions _helperFunctions = HelperFunctions();

  final Map<String, IconData> e = {
    'Currency': Icons.monetization_on_outlined,
    'Calculator': Icons.calculate_outlined,
    'History': Icons.history_outlined
  };

  final List<Widget> availableWidgets = [
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
        bool isLightTheme = Theme.of(context).brightness == Brightness.light;

        SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: isLightTheme ? Colors.white : Colors.black,
          statusBarIconBrightness:
              isLightTheme ? Brightness.dark : Brightness.light,
        );

        SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
      }
    } catch (_) {}
  }

  @override
  void initState() {
    super.initState();
    doInitialTasks();
  }

  void doInitialTasks() async {
    if (Platform.isAndroid) {
      bool _disabled = await getPrefs('privacy', true);
      setSecure(_disabled);
    }
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
