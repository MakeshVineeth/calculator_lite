import 'package:calculator_lite/currencyTab.dart';
import 'package:calculator_lite/historyTab.dart';
import 'package:flutter/material.dart';
import 'package:calculator_lite/bottomNavClass.dart';
import 'package:calculator_lite/calculatorTab.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:calculator_lite/fixedValues.dart';
import 'package:calculator_lite/Backend/themeChange.dart';

void main() => runApp(BottomNavBar());

class BottomNavBar extends StatefulWidget {
  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  ThemeMode setTheme = ThemeMode.system;

  void getThemeStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final theme = prefs.getString('theme') ?? 'System Default';
    ThemeMode themeMode;
    switch (theme) {
      case 'System Default':
        themeMode = ThemeMode.system;
        break;
      case 'Dark':
        themeMode = ThemeMode.dark;
        break;
      case 'Light':
        themeMode = ThemeMode.light;
        break;
    }
    setThemeFunction(themeMode);
  }

  void setThemeFunction(ThemeMode themeMode) {
    setState(() {
      setTheme = themeMode;
    });
  }

  @override
  void initState() {
    super.initState();
    getThemeStatus();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeChange(
      stateFunction: setThemeFunction,
      child: MaterialApp(
        title: 'Calculator Lite',
        debugShowCheckedModeBanner: false,
        themeMode: setTheme,
        theme: FixedValues.lightTheme(),
        darkTheme: FixedValues.darkTheme(),
        home: ScaffoldHome(),
      ),
    );
  }
}

class ScaffoldHome extends StatefulWidget {
  @override
  _ScaffoldHomeState createState() => _ScaffoldHomeState();
}

class _ScaffoldHomeState extends State<ScaffoldHome>
    with WidgetsBindingObserver {
  int _currentIndex = 1;

  Map e = {
    'Currency': Icons.monetization_on_outlined,
    'Calculator': Icons.calculate_outlined,
    'History': Icons.history_outlined
  };

  List<Widget> availableWidgets = <Widget>[
    CurrencyTab(),
    CalculatorTab(),
    HistoryTab()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void setFlatStatusBar() {
    // Must be executed every time the theme changes.
    FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);
    ThemeData temp = Theme.of(context);
    bool useWhiteForeground =
        (temp.brightness == Brightness.dark) ? true : false;
    FlutterStatusbarcolor.setStatusBarWhiteForeground(useWhiteForeground);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setFlatStatusBar();
    }
  }

  @override
  Widget build(BuildContext context) {
    setFlatStatusBar();
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: availableWidgets,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        items: List.generate(e.length, (index) {
          return BottomNavClass(
            title: e.keys.elementAt(index),
            icon: e.values.elementAt(index),
          ).returnNavItems();
        }),
        onTap: _onItemTapped,
      ),
    );
  }
}
