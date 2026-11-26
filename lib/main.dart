import 'dart:async';
import 'dart:io' show Platform;

import 'package:calculator_lite/Backend/helper_functions.dart';
import 'package:calculator_lite/Backend/hive_initializer.dart';
import 'package:calculator_lite/Backend/theme_change.dart';
import 'package:calculator_lite/CurrencyTab/currency_tab.dart';
import 'package:calculator_lite/Export_Screen/export_screen.dart';
import 'package:calculator_lite/HistoryTab/commons_history.dart';
import 'package:calculator_lite/HistoryTab/history_item.dart';
import 'package:calculator_lite/HistoryTab/history_tab.dart';
import 'package:calculator_lite/UIElements/fade_indexed_page.dart';
import 'package:calculator_lite/UIElements/show_blur_dialog.dart';
import 'package:calculator_lite/UIElements/tutorial_dialog.dart';
import 'package:calculator_lite/bottom_nav_class.dart';
import 'package:calculator_lite/calculator_tab.dart';
import 'package:calculator_lite/common_methods/common_methods.dart';
import 'package:calculator_lite/features/app_shortcuts.dart';
import 'package:calculator_lite/fixed_values.dart';
import 'package:calculator_lite/l10n/app_localizations.dart';
import 'package:calculator_lite/payments/payments_wrapper.dart';
import 'package:calculator_lite/payments/pro_screen.dart';
import 'package:calculator_lite/payments/provider_purchase_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  HiveInitializer.startInit();
  runApp(const BottomNavBar());
}

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  ThemeMode setTheme = ThemeMode.system;

  void getThemeStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString('theme') ?? 'System Default';
    final ThemeMode themeMode = MiniThemeFunctions.parseTheme(themeString);
    setThemeFunction(themeMode);
  }

  void setThemeFunction(ThemeMode themeMode) {
    if (!mounted || setTheme == themeMode) return;
    setState(() => setTheme = themeMode);
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
      newChild: Platform.isAndroid
          ? PaymentsWrapper(child: materialApp(setTheme, context))
          : ChangeNotifierProvider<PurchaseStatusProvider>(
              create: (_) => PurchaseStatusProvider(),
              child: materialApp(setTheme, context),
            ),
    );
  }
}

Widget materialApp(final ThemeMode setTheme, BuildContext context) =>
    MaterialApp(
      title: FixedValues.appName,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
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
  const ScaffoldHome({super.key});

  @override
  State<ScaffoldHome> createState() => _ScaffoldHomeState();
}

class _ScaffoldHomeState extends State<ScaffoldHome>
    with RestorationMixin, WidgetsBindingObserver {
  final RestorableInt _currentIndex = RestorableInt(1);
  final Set<int> _activatedTabs = <int>{1};
  final double _landScapeFont = 10.0;
  final double _iconSizeLandscape = 15.0;
  final HelperFunctions _helperFunctions = const HelperFunctions();
  final QuickActions quickActions = const QuickActions();
  Timer? _tutorialTimer;
  Brightness? _lastStatusBrightness;

  static final Map<String, IconData> tabs = {
    FixedValues.currencyTabTitle: Icons.monetization_on_outlined,
    FixedValues.calculatorTabTitle: Icons.calculate_outlined,
    FixedValues.historyTabTitle: Icons.history_outlined,
  };

  final List<Widget> availableWidgets = const <Widget>[
    CurrencyTab(),
    CalculatorTab(),
    HistoryTab(),
  ];

  late final List<BottomNavigationBarItem> _navItems = List.generate(
    tabs.length,
    (index) => BottomNavClass(
      title: tabs.keys.elementAt(index),
      icon: tabs.values.elementAt(index),
    ).returnNavItems(),
  );

  void _onItemTapped(int index) {
    if (!mounted) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _currentIndex.value = index;
      _activatedTabs.add(index);
    });
  }

  void setFlatStatusBar() {
    if (Platform.isAndroid) {
      final isLightTheme = Theme.of(context).brightness == Brightness.light;
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarDividerColor: Colors.transparent,
          systemNavigationBarContrastEnforced: false,
          statusBarIconBrightness:
              isLightTheme ? Brightness.dark : Brightness.light,
          statusBarBrightness:
              isLightTheme ? Brightness.light : Brightness.dark,
          systemNavigationBarIconBrightness:
              isLightTheme ? Brightness.dark : Brightness.light,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) doInitialTasks();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final brightness = Theme.of(context).brightness;
    if (_lastStatusBrightness != brightness) {
      _lastStatusBrightness = brightness;
      setFlatStatusBar();
    }
  }

  @override
  void dispose() {
    _tutorialTimer?.cancel();
    _currentIndex.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (mounted) setFlatStatusBar();
    }
  }

  Future<void> _initAndroidStartup() async {
    await Future.wait<void>([
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge)
          .catchError((_) {}),
      FlutterDisplayMode.setHighRefreshRate().catchError((_) {}),
      quickActions
          .initialize((shortcutType) {
            int index = 1;
            if (shortcutType == AppShortcuts.calculatorQuickAction.type) {
              index = 1;
            } else if (shortcutType == AppShortcuts.currencyQuickAction.type) {
              index = 0;
            } else if (shortcutType == AppShortcuts.historyQuickAction.type) {
              index = 2;
            }
            _onItemTapped(index);
          })
          .catchError((_) {}),
      quickActions
          .setShortcutItems(AppShortcuts.shortcutsList)
          .catchError((_) {}),
    ]);
  }

  Future<void> doInitialTasks() async {
    try {
      final prefsFuture = SharedPreferences.getInstance();
      if (Platform.isAndroid) {
        await _initAndroidStartup();
      }

      final prefs = await prefsFuture;
      if (!mounted) return;

      if (Platform.isAndroid) {
        final bool disabled = prefs.getBool('privacy') ?? true;
        if (!disabled) {
          await setSecure(false);
        }
      }

      final bool showTutorial = prefs.getBool(FixedValues.firstLaunchPref) ?? true;
      if (showTutorial) {
        await prefs.setBool(FixedValues.firstLaunchPref, false);
        await HiveInitializer.ensureInitialized();

        final Box<HistoryItem> box =
            await Hive.openBox<HistoryItem>(CommonsHistory.historyBox);
        final DateTime now = DateTime.now();
        final HistoryItem historyItem = HistoryItem(
          expression: '5+3',
          value: '8.0',
          dateTime: now,
          title: 'Sample history item. Swipe to see more actions.',
          metrics: 'RAD',
        );

        await box.add(historyItem);

        _tutorialTimer = Timer(const Duration(milliseconds: 600), () {
          if (mounted) {
            showBlurDialog(context: context, child: const TutorialDialog());
          }
        });
      }

      await askForReview();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final bool isLandscape = _helperFunctions.isLandScape(context);

    return Scaffold(
      body: SafeArea(
        child: FadeIndexedStack(
          index: _currentIndex.value,
          children: List<Widget>.generate(
            availableWidgets.length,
            (i) => _activatedTabs.contains(i)
                ? availableWidgets[i]
                : const SizedBox.shrink(),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        maintainBottomViewPadding: true,
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SizedBox(
              height: isLandscape ? 48 : 58,
              child: BottomNavigationBar(
                currentIndex: _currentIndex.value,
                selectedLabelStyle: FixedValues.semiBoldStyle,
                unselectedLabelStyle: FixedValues.semiBoldStyle,
                elevation: 0,
                iconSize: isLandscape ? _iconSizeLandscape : 24.0,
                selectedFontSize: isLandscape ? _landScapeFont : 14.0,
                unselectedFontSize: isLandscape ? _landScapeFont : 12.0,
                type: BottomNavigationBarType.fixed,
                items: _navItems,
                onTap: _onItemTapped,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  String get restorationId => 'landing_tab_index';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_currentIndex, restorationId);
    _activatedTabs.add(_currentIndex.value);
  }
}
