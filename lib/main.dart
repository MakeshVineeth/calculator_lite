import 'package:calculator_lite/Backend/helper_functions.dart';
import 'package:calculator_lite/CurrencyTab/currency_tab.dart';
import 'package:calculator_lite/Export_Screen/export_screen.dart';
import 'package:calculator_lite/HistoryTab/commons_history.dart';
import 'package:calculator_lite/HistoryTab/history_tab.dart';
import 'package:calculator_lite/UIElements/tutorial_dialog.dart';
import 'package:calculator_lite/UIElements/show_blur_dialog.dart';
import 'package:calculator_lite/calculator_tab.dart';
import 'package:calculator_lite/common_methods/common_methods.dart';
import 'package:calculator_lite/features/app_shortcuts.dart';
import 'package:calculator_lite/payments/payments_wrapper.dart';
import 'package:calculator_lite/payments/pro_screen.dart';
import 'package:calculator_lite/payments/provider_purchase_status.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:calculator_lite/bottom_nav_class.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_statusbarcolor_ns/flutter_statusbarcolor_ns.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:calculator_lite/fixed_values.dart';
import 'package:calculator_lite/Backend/theme_change.dart';
import 'package:calculator_lite/UIElements/fade_indexed_page.dart';
import 'dart:io' show Platform;
import 'package:calculator_lite/CurrencyTab/Backend/currency_list_item.dart';
import 'HistoryTab/history_item.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter('hiveUserData');
  Hive.registerAdapter(CurrencyListItemAdapter());
  Hive.registerAdapter(HistoryItemAdapter());
  runApp(const BottomNavBar());
}

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({Key key}) : super(key: key);

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
      newChild: (Platform.isAndroid)
          ? PaymentsWrapper(child: materialApp(setTheme, context))
          : ChangeNotifierProvider<PurchaseStatusProvider>.value(
              value: PurchaseStatusProvider(),
              child: materialApp(setTheme, context),
            ),
    );
  }
}

Widget materialApp(final ThemeMode setTheme, BuildContext context) =>
    MaterialApp(
      title: FixedValues.appName,
      debugShowCheckedModeBanner: false,
      themeMode: setTheme,
      restorationScopeId: 'root',
      theme: FixedValues.getThemeData(Brightness.light, context),
      darkTheme: FixedValues.getThemeData(Brightness.dark, context),
      initialRoute: '/',
      routes: {
        '/': (context) => const ScaffoldHome(),
        '/export': (context) => const ExportScreen(),
        FixedValues.buyRoute: (context) => const ProScreen(),
      },
    );

class ScaffoldHome extends StatefulWidget {
  const ScaffoldHome({Key key}) : super(key: key);

  @override
  _ScaffoldHomeState createState() => _ScaffoldHomeState();
}

class _ScaffoldHomeState extends State<ScaffoldHome>
    with RestorationMixin, WidgetsBindingObserver {
  final RestorableInt _currentIndex = RestorableInt(1);
  final double _landScapeFont = 10.0;
  final double _iconSizeLandscape = 15.0;
  final HelperFunctions _helperFunctions = HelperFunctions();
  final QuickActions quickActions = const QuickActions();

  final Map<String, IconData> tabs = {
    FixedValues.currencyTabTitle: Icons.monetization_on_outlined,
    FixedValues.calculatorTabTitle: Icons.calculate_outlined,
    FixedValues.historyTabTitle: Icons.history_outlined
  };

  final List<Widget> availableWidgets = <Widget>[
    const CurrencyTab(),
    const CalculatorTab(),
    const HistoryTab()
  ];

  void _onItemTapped(int index) {
    FocusScope.of(context).unfocus();
    if (mounted) setState(() => _currentIndex.value = index);
  }

  void setFlatStatusBar() {
    if (Platform.isAndroid) {
      bool isLightTheme = Theme.of(context).brightness == Brightness.light;
      FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);
      if (isLightTheme) {
        FlutterStatusbarcolor.setStatusBarWhiteForeground(false);
      } else {
        FlutterStatusbarcolor.setStatusBarWhiteForeground(true);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    doInitialTasks();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (mounted) setFlatStatusBar();
    }
  }

  Future<void> doInitialTasks() async {
    try {
      if (Platform.isAndroid) {
        try {
          DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
          AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
          int sdkVer = androidInfo.version.sdkInt;

          if (sdkVer >= 23) await FlutterDisplayMode.setHighRefreshRate();
        } catch (_) {}

        bool _disabled = await getPrefs('privacy', true);
        setSecure(_disabled);

        quickActions.initialize((shortcutType) {
          int index = 1;

          if (shortcutType == AppShortcuts.calculatorQuickAction.type) {
            index = 1;
          } else if (shortcutType == AppShortcuts.currencyQuickAction.type) {
            index = 0;
          } else if (shortcutType == AppShortcuts.historyQuickAction.type) {
            index = 2;
          }

          _onItemTapped(index);
        });

        quickActions.setShortcutItems(AppShortcuts.shortcutsList);
      }

      if (await isFirstLaunch()) {
        await setPrefs(FixedValues.firstLaunchPref, false);

        // Add a sample history item.
        final Box box = await Hive.openBox(CommonsHistory.historyBox);
        DateTime now = DateTime.now();
        final HistoryItem historyItem = HistoryItem(
          expression: '5+3',
          value: '8.0',
          dateTime: now,
          title: 'Sample history item. Swipe to see more actions.',
          metrics: 'RAD',
        );

        await box.add(historyItem);

        Future.delayed(
          const Duration(milliseconds: 600),
          () => showBlurDialog(
            context: context,
            child: const TutorialDialog(),
          ),
        );
      }

      await askForReview();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    setFlatStatusBar();

    return Scaffold(
      body: SafeArea(
        child: FadeIndexedStack(
          index: _currentIndex.value,
          children: availableWidgets,
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: _helperFunctions.isLandScape(context) ? 40 : 58,
        child: BottomNavigationBar(
          currentIndex: _currentIndex.value,
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
              tabs.length,
              (index) => BottomNavClass(
                    title: tabs.keys.elementAt(index),
                    icon: tabs.values.elementAt(index),
                  ).returnNavItems()),
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  @override
  String get restorationId => 'landing_tab_index';

  @override
  void restoreState(RestorationBucket oldBucket, bool initialRestore) {
    registerForRestoration(_currentIndex, restorationId);
  }
}
