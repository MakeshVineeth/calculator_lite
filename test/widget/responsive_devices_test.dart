import 'dart:io';
import 'package:calculator_lite/CurrencyTab/Backend/commons.dart';
import 'package:calculator_lite/CurrencyTab/Backend/currency_list_item.dart';
import 'package:calculator_lite/HistoryTab/commons_history.dart';
import 'package:calculator_lite/HistoryTab/history_item.dart';
import 'package:calculator_lite/calculator_tab.dart';
import 'package:calculator_lite/CurrencyTab/currency_tab.dart';
import 'package:calculator_lite/HistoryTab/history_tab.dart';
import 'package:calculator_lite/UIElements/display_screen.dart';
import 'package:calculator_lite/payments/provider_purchase_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakePathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  final Directory dir;
  FakePathProviderPlatform(this.dir);

  @override
  Future<String?> getTemporaryPath() async => dir.path;

  @override
  Future<String?> getApplicationDocumentsPath() async => dir.path;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('responsive_test_');
    PathProviderPlatform.instance = FakePathProviderPlatform(tempDir);
    SharedPreferences.setMockInitialValues({
      CommonsData.autoUpdatePref: CommonsData.autoUpdateDisabled,
      CommonsHistory.historyStatusPref: CommonsHistory.historyEnabled,
    });

    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(CurrencyListItemAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(HistoryItemAdapter());
    }

    await Hive.openBox<HistoryItem>(CommonsHistory.historyBox);
    final fromBox = await Hive.openBox<CurrencyListItem>(CommonsData.fromBox);
    final toBox = await Hive.openBox<CurrencyListItem>(CommonsData.toBox);
    final currencyBox =
        await Hive.openBox<CurrencyListItem>(CommonsData.currencyListBox);
    await Hive.openBox<dynamic>(CommonsData.updatedDateBox);

    final usd = CurrencyListItem(
      currencyCode: 'USD',
      currencyName: 'US Dollar',
      flagURL: 'icons/flags/png100px/us.png',
    );
    final eur = CurrencyListItem(
      currencyCode: 'EUR',
      currencyName: 'Euro',
      flagURL: 'icons/flags/png100px/eu.png',
    );
    await currencyBox.addAll([usd, eur]);
    await fromBox.add(usd);
    await toBox.add(eur);

    final usdRates = await Hive.openBox<dynamic>('usd');
    await usdRates.put('EUR', 0.85);
  });

  tearDown(() async {
    await Hive.close();
    try {
      if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  Widget buildTestApp(Widget child) {
    return ChangeNotifierProvider<PurchaseStatusProvider>(
      create: (_) => PurchaseStatusProvider(),
      child: MaterialApp(
        home: Scaffold(
          body: SafeArea(child: child),
        ),
      ),
    );
  }

  group('Multi-Device Responsive & Adaptive Layout Tests', () {
    final Map<String, Size> deviceResolutions = {
      'WearOS / Watch (Square)': const Size(280, 280),
      'Small Phone (320x568)': const Size(320, 568),
      'Mid Phone (390x844)': const Size(390, 844),
      'Foldable (673x841)': const Size(673, 841),
      'Tablet Portrait (800x1280)': const Size(800, 1280),
      'Tablet Landscape (1280x800)': const Size(1280, 800),
      'TV / 1080p Desktop (1920x1080)': const Size(1920, 1080),
      'Phone Half Split-Screen (390x400)': const Size(390, 400),
      'Phone 1/3 Split-Screen (390x270)': const Size(390, 270),
      'Foldable Side-by-Side Split (400x841)': const Size(400, 841),
    };

    for (final entry in deviceResolutions.entries) {
      testWidgets('CalculatorTab renders with zero overflow on ${entry.key}',
          (WidgetTester tester) async {
        tester.view.physicalSize = entry.value;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(buildTestApp(const CalculatorTab()));
        await tester.pumpAndSettle();

        expect(find.byType(CalculatorTab), findsOneWidget);
        expect(find.byType(DisplayScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('Hardware Keyboard input triggers calculation on CalculatorTab',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(const CalculatorTab()));
      await tester.pumpAndSettle();

      await tester.runAsync(() async {
        await tester.sendKeyEvent(LogicalKeyboardKey.digit5);
        await Future<void>.delayed(const Duration(milliseconds: 80));
        await tester.sendKeyEvent(LogicalKeyboardKey.numpadAdd);
        await Future<void>.delayed(const Duration(milliseconds: 80));
        await tester.sendKeyEvent(LogicalKeyboardKey.digit3);
        await Future<void>.delayed(const Duration(milliseconds: 80));
      });
      await tester.pump();

      final displayFinder = find.byType(DisplayScreen);
      expect(displayFinder, findsOneWidget);
      final DisplayScreen display = tester.widget(displayFinder);
      expect(display.calculationString.join(), contains('5+3'));

      await tester.runAsync(() async {
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await Future<void>.delayed(const Duration(milliseconds: 80));
        await tester.sendKeyEvent(LogicalKeyboardKey.keyC);
        await Future<void>.delayed(const Duration(milliseconds: 80));
      });
      await tester.pump();

      final DisplayScreen clearedDisplay = tester.widget(displayFinder);
      expect(clearedDisplay.calculationString, isEmpty);
      expect(tester.takeException(), isNull);
    });

    testWidgets('HistoryTab renders cleanly within constrained bounds on Tablet',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestApp(const HistoryTab()));
      await tester.pumpAndSettle();

      expect(find.byType(HistoryTab), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('CurrencyTab renders cleanly within constrained bounds on Tablet',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestApp(const CurrencyTab()));
      await tester.pump();

      expect(find.byType(CurrencyTab), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
