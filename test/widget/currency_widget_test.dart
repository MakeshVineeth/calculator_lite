import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:calculator_lite/CurrencyTab/currency_tab.dart';
import 'package:calculator_lite/CurrencyTab/currency_chooser.dart';
import 'package:calculator_lite/CurrencyTab/Backend/commons.dart';
import 'package:calculator_lite/CurrencyTab/Backend/currency_list_item.dart';
import 'package:calculator_lite/UIElements/fade_scale_widget.dart';
import 'package:calculator_lite/payments/provider_purchase_status.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

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

void _configureMotorolaViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.625;
  tester.view.padding = const FakeViewPadding(top: 95, bottom: 126);
  tester.view.viewPadding = const FakeViewPadding(top: 95, bottom: 126);
  addTearDown(() {
    tester.view.resetViewInsets();
    tester.view.resetViewPadding();
    tester.view.resetPadding();
    tester.view.resetDevicePixelRatio();
    tester.view.resetPhysicalSize();
  });
}

Future<void> _pumpAndOpenChooser(
  WidgetTester tester, {
  Future<void> Function(CurrencyListItem item)? onCurrencySelected,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => CurrencyChooser.show(
              context: context,
              index: 0,
              method: CommonsData.fromBox,
              onCurrencySelected: onCurrencySelected,
            ),
            child: const Text('Open Chooser'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open Chooser'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 900));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('currency_test_');
    PathProviderPlatform.instance = FakePathProviderPlatform(tempDir);
    SharedPreferences.setMockInitialValues({
      CommonsData.autoUpdatePref: CommonsData.autoUpdateDisabled,
    });

    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(CurrencyListItemAdapter());
    }

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
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  testWidgets('CurrencyTab loads and displays without crashing', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<PurchaseStatusProvider>(
            create: (_) => PurchaseStatusProvider(),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: CurrencyTab(),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(CurrencyTab), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'CurrencyChooser search keeps focus and state across keyboard viewInsets updates on Motorola G57 Power 5G viewport',
    (tester) async {
      _configureMotorolaViewport(tester);
      await _pumpAndOpenChooser(tester);

      final State chooserState = tester.state(find.byType(CurrencyChooser));
      final State fadeScaleState = tester.state(find.byType(FadeScale));

      await tester.tap(find.byType(TextField));
      await tester.pump();

      final searchFocus =
          tester.widget<EditableText>(find.byType(EditableText)).focusNode;
      expect(searchFocus.hasFocus, isTrue);

      for (final double insetBottom in [300, 600, 880]) {
        tester.view.viewInsets = FakeViewPadding(bottom: insetBottom);
        tester.view.padding = const FakeViewPadding(top: 95, bottom: 0);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        expect(
          identical(tester.state(find.byType(CurrencyChooser)), chooserState),
          isTrue,
        );
        expect(
          identical(tester.state(find.byType(FadeScale)), fadeScaleState),
          isTrue,
        );
        expect(searchFocus.hasFocus, isTrue);
        expect(tester.takeException(), isNull);
      }

      await tester.enterText(find.byType(TextField), 'Euro');
      await tester.pump();
      expect(find.text('Euro (EUR)'), findsOneWidget);
      expect(find.text('US Dollar (USD)'), findsNothing);

      await tester.tap(find.text('Select Currency'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(CurrencyChooser), findsOneWidget);

      await tester.tapAt(const Offset(10, 10));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(CurrencyChooser), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'Selecting filtered currency updates selection and closes chooser',
    (tester) async {
      _configureMotorolaViewport(tester);
      CurrencyListItem? selected;
      await _pumpAndOpenChooser(
        tester,
        onCurrencySelected: (item) async {
          selected = item;
        },
      );

      await tester.enterText(find.byType(TextField), 'Euro');
      await tester.pump();

      await tester.tap(find.text('Euro (EUR)'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(CurrencyChooser), findsNothing);
      expect(selected?.currencyCode, 'EUR');

      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
