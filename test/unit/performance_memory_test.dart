import 'dart:io';

import 'package:calculator_lite/CurrencyTab/Backend/commons.dart';
import 'package:calculator_lite/CurrencyTab/Backend/currency_list_item.dart';
import 'package:calculator_lite/CurrencyTab/card_ui.dart';
import 'package:calculator_lite/CurrencyTab/currency_tab.dart';
import 'package:calculator_lite/CurrencyTab/reset_form_provider.dart';
import 'package:calculator_lite/HistoryTab/commons_history.dart';
import 'package:calculator_lite/HistoryTab/history_item.dart';
import 'package:calculator_lite/HistoryTab/history_tab.dart';
import 'package:calculator_lite/calculator_tab.dart';
import 'package:calculator_lite/fixed_values.dart' as fv;
import 'package:calculator_lite/main.dart';
import 'package:calculator_lite/payments/provider_purchase_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakePathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  final Directory dir;
  _FakePathProviderPlatform(this.dir);

  @override
  Future<String?> getTemporaryPath() async => dir.path;

  @override
  Future<String?> getApplicationDocumentsPath() async => dir.path;
}

class _TrackableResetFormProvider extends ResetFormProvider {
  bool get trackedHasListeners => hasListeners;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PurchaseStatusProvider unit checks', () {
    test('changeStatusCheck updates field and updateStatus notifies once', () {
      final provider = PurchaseStatusProvider();
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      provider.changeStatusCheck(StatusCheck.pending);
      expect(provider.statusCheck, equals(StatusCheck.pending));
      expect(notifyCount, equals(1));

      provider.updateStatus(true);
      expect(provider.hasPurchased, isTrue);
      expect(provider.statusCheck, equals(StatusCheck.ok));
      expect(notifyCount, equals(2));

      provider.dispose();
    });
  });

  group('Memory & lazy startup widget checks', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync('perf_mem_test_');
      PathProviderPlatform.instance = _FakePathProviderPlatform(tempDir);
      SharedPreferences.setMockInitialValues({
        fv.FixedValues.firstLaunchPref: false,
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
        flagURL: '',
      );
      final eur = CurrencyListItem(
        currencyCode: 'EUR',
        currencyName: 'Euro',
        flagURL: '',
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

    testWidgets('CardUI removes ResetFormProvider listener on dispose',
        (tester) async {
      final resetProvider = _TrackableResetFormProvider();
      addTearDown(resetProvider.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CardUI(
              index: 0,
              resetFormProvider: resetProvider,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(resetProvider.trackedHasListeners, isTrue);

      await tester.pumpWidget(const SizedBox.shrink());
      expect(resetProvider.trackedHasListeners, isFalse);

      expect(() => resetProvider.reset(true), returnsNormally);
    });

    testWidgets(
        'ScaffoldHome mounts CalculatorTab on Frame 1 and lazy-mounts CurrencyTab & HistoryTab on demand',
        (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<PurchaseStatusProvider>(
          create: (_) => PurchaseStatusProvider(),
          child: const MaterialApp(
            home: ScaffoldHome(),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CalculatorTab), findsOneWidget);
      expect(find.byType(CurrencyTab, skipOffstage: false), findsNothing);
      expect(find.byType(HistoryTab, skipOffstage: false), findsNothing);

      await tester.tap(find.text('Currency'));
      await tester.pump();
      expect(find.byType(CurrencyTab), findsOneWidget);
      expect(find.byType(CalculatorTab, skipOffstage: false), findsOneWidget);
      expect(find.byType(HistoryTab, skipOffstage: false), findsNothing);

      await tester.tap(find.text('History'));
      await tester.pump();
      expect(find.byType(HistoryTab), findsOneWidget);
      expect(find.byType(CurrencyTab, skipOffstage: false), findsOneWidget);
      expect(find.byType(CalculatorTab, skipOffstage: false), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    });
  });
}
