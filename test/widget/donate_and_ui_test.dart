import 'dart:async';
import 'dart:io';

import 'package:calculator_lite/CurrencyTab/Backend/commons.dart';
import 'package:calculator_lite/CurrencyTab/Backend/currency_list_item.dart';
import 'package:calculator_lite/CurrencyTab/currency_chooser.dart';
import 'package:calculator_lite/HistoryTab/commons_history.dart';
import 'package:calculator_lite/HistoryTab/history_item.dart';
import 'package:calculator_lite/HistoryTab/history_tab.dart';
import 'package:calculator_lite/UIElements/about_page.dart';
import 'package:calculator_lite/UIElements/buttons_links.dart';
import 'package:calculator_lite/UIElements/display_screen.dart';
import 'package:calculator_lite/calculator_tab.dart';
import 'package:calculator_lite/fixed_values.dart';
import 'package:calculator_lite/payments/common_purchase_strings.dart';
import 'package:calculator_lite/payments/payments_wrapper.dart';
import 'package:calculator_lite/payments/pro_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockInAppPurchase extends Mock implements InAppPurchase {}

class FakePurchaseParam extends Fake implements PurchaseParam {}

class FakePurchaseDetails extends Fake implements PurchaseDetails {}

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

ProductDetails _testProduct() => ProductDetails(
  id: CommonPurchaseStrings.productIds.first,
  title: 'Calculator Lite Pro',
  description: 'Support development',
  price: r'$1.99',
  rawPrice: 1.99,
  currencyCode: 'USD',
);

PurchaseDetails _testPurchase(
  PurchaseStatus status, {
  bool pendingComplete = false,
}) {
  final details = PurchaseDetails(
    purchaseID: 'order_123',
    productID: CommonPurchaseStrings.productIds.first,
    verificationData: PurchaseVerificationData(
      localVerificationData: 'local',
      serverVerificationData: 'server',
      source: 'google_play',
    ),
    transactionDate: '1700000000000',
    status: status,
  );
  details.pendingCompletePurchase = pendingComplete;
  return details;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(FakePurchaseParam());
    registerFallbackValue(FakePurchaseDetails());
  });

  group('AboutPage & ButtonLinks UI', () {
    testWidgets('Play Store and GitHub buttons include horizontal padding', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AboutPage()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      final buttons = tester.widgetList<ButtonLinks>(find.byType(ButtonLinks));
      expect(buttons.length, equals(2));

      final textButtons = tester.widgetList<TextButton>(find.byType(TextButton));
      for (final btn in textButtons) {
        final padding = btn.style?.padding?.resolve(<WidgetState>{});
        expect(padding, isNotNull);
        expect(padding!.horizontal, greaterThanOrEqualTo(24.0));
      }
      expect(tester.takeException(), isNull);
    });
  });

  group('Donate / IAP Logic (ProScreen & PaymentsWrapper)', () {
    late MockInAppPurchase mockIap;
    late StreamController<List<PurchaseDetails>> purchaseController;

    setUp(() {
      mockIap = MockInAppPurchase();
      purchaseController = StreamController<List<PurchaseDetails>>.broadcast();
      when(() => mockIap.purchaseStream)
          .thenAnswer((_) => purchaseController.stream);
      when(() => mockIap.restorePurchases(applicationUserName: any(named: 'applicationUserName')))
          .thenAnswer((_) async {});
      when(() => mockIap.completePurchase(any())).thenAnswer((_) async {});
      when(() => mockIap.buyNonConsumable(purchaseParam: any(named: 'purchaseParam')))
          .thenAnswer((_) async => true);
    });

    tearDown(() async {
      await purchaseController.close();
    });

    testWidgets(
      'Shows BUY price when unpurchased, Pending on pending, Thank You on purchase/restore, and Error when unavailable',
      (WidgetTester tester) async {
        when(() => mockIap.isAvailable()).thenAnswer((_) async => true);
        when(() => mockIap.queryProductDetails(any())).thenAnswer(
          (_) async => ProductDetailsResponse(
            productDetails: [_testProduct()],
            notFoundIDs: const [],
          ),
        );

        await tester.pumpWidget(
          PaymentsWrapper(
            iap: mockIap,
            child: MaterialApp(
              home: ProScreen(iap: mockIap, isAndroidOverride: true),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // 1. Unpurchased state with product loaded -> BUY button, not Thank You
        expect(find.text(r'BUY $1.99'), findsOneWidget);
        expect(find.text(CommonPurchaseStrings.paymentSuccess), findsNothing);

        await tester.tap(find.text(r'BUY $1.99'));
        await tester.pump();
        verify(() => mockIap.buyNonConsumable(purchaseParam: any(named: 'purchaseParam')))
            .called(1);

        // 2. Pending state must take precedence over loaded products
        purchaseController.add([_testPurchase(PurchaseStatus.pending)]);
        await tester.pumpAndSettle();
        expect(find.text(CommonPurchaseStrings.paymentPending), findsOneWidget);
        expect(find.text(r'BUY $1.99'), findsNothing);

        // 3. Restored purchase sets Thank You without calling completePurchase when pendingCompletePurchase == false
        purchaseController.add([
          _testPurchase(PurchaseStatus.restored, pendingComplete: false),
        ]);
        await tester.pumpAndSettle();
        expect(find.text(CommonPurchaseStrings.paymentSuccess), findsOneWidget);
        verifyNever(() => mockIap.completePurchase(any()));

        // 4. Fresh purchase with pendingCompletePurchase == true calls completePurchase ONCE
        purchaseController.add([
          _testPurchase(PurchaseStatus.purchased, pendingComplete: true),
        ]);
        await tester.pumpAndSettle();
        verify(() => mockIap.completePurchase(any())).called(1);
      },
    );

    testWidgets('Shows Error state when store is unavailable', (
      WidgetTester tester,
    ) async {
      when(() => mockIap.isAvailable()).thenAnswer((_) async => false);

      await tester.pumpWidget(
        PaymentsWrapper(
          iap: mockIap,
          child: MaterialApp(
            home: ProScreen(iap: mockIap, isAndroidOverride: true),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(CommonPurchaseStrings.paymentErrors), findsOneWidget);
      expect(find.text(CommonPurchaseStrings.paymentSuccess), findsNothing);
    });
  });

  group('HistoryTab Minimalistic Search Bar', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync('hist_search_test_');
      PathProviderPlatform.instance = FakePathProviderPlatform(tempDir);
      Hive.init(tempDir.path);
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(HistoryItemAdapter());
      }
      final box = await Hive.openBox<HistoryItem>(CommonsHistory.historyBox);
      await box.addAll([
        HistoryItem(
          dateTime: DateTime(2026, 11, 27, 10, 0),
          expression: '100+25',
          metrics: 'RAD',
          value: '125.0',
          title: 'Grocery Budget',
        ),
        HistoryItem(
          dateTime: DateTime(2026, 11, 27, 11, 0),
          expression: '500*0.18',
          metrics: 'RAD',
          value: '90.0',
          title: 'Tax Calculation',
        ),
      ]);
    });

    tearDown(() async {
      await Hive.close();
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    testWidgets(
      'Search bar is always visible without icon tap, filters live, and clears',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: HistoryTab()),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.widgetWithText(TextField, 'Search history'), findsOneWidget);
        expect(find.text('Grocery Budget'), findsOneWidget);
        expect(find.text('Tax Calculation'), findsOneWidget);

        await tester.enterText(find.byType(TextField), 'tax');
        await tester.pumpAndSettle();
        expect(find.text('Tax Calculation'), findsOneWidget);
        expect(find.text('Grocery Budget'), findsNothing);

        await tester.enterText(find.byType(TextField), 'zzznomatch');
        await tester.pumpAndSettle();
        expect(find.text('No matching history found.'), findsOneWidget);

        await tester.tap(find.byIcon(Icons.close_rounded));
        await tester.pumpAndSettle();
        expect(find.text('Grocery Budget'), findsOneWidget);
        expect(find.text('Tax Calculation'), findsOneWidget);

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      },
    );
  });

  group('Calculator & Currency Regression Tests', () {
    testWidgets(
      'Shifted hardware keys (*, (, +), equals cursor clear, and small decimal chaining',
      (WidgetTester tester) async {
        SharedPreferences.setMockInitialValues({});
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: CalculatorTab()),
          ),
        );
        await tester.pumpAndSettle();

        await tester.sendKeyDownEvent(LogicalKeyboardKey.digit2);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.digit2);
        HardwareKeyboard.instance.handleKeyEvent(
          const KeyDownEvent(
            physicalKey: PhysicalKeyboardKey.digit8,
            logicalKey: LogicalKeyboardKey.digit8,
            character: '*',
            timeStamp: Duration.zero,
          ),
        );
        HardwareKeyboard.instance.handleKeyEvent(
          const KeyUpEvent(
            physicalKey: PhysicalKeyboardKey.digit8,
            logicalKey: LogicalKeyboardKey.digit8,
            timeStamp: Duration.zero,
          ),
        );
        await tester.sendKeyDownEvent(LogicalKeyboardKey.digit5);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.digit5);
        await tester.pump();

        var display = tester.widget<DisplayScreen>(find.byType(DisplayScreen));
        expect(
          display.calculationString.join(),
          equals('2${FixedValues.multiplyChar}5'),
        );
        expect(display.mainValue, equals(10.0));

        // Verify Shift+= ('+') and Shift+9 ('(') characters take precedence over keyMap
        HardwareKeyboard.instance.handleKeyEvent(
          const KeyDownEvent(
            physicalKey: PhysicalKeyboardKey.equal,
            logicalKey: LogicalKeyboardKey.equal,
            character: '+',
            timeStamp: Duration(milliseconds: 10),
          ),
        );
        HardwareKeyboard.instance.handleKeyEvent(
          const KeyDownEvent(
            physicalKey: PhysicalKeyboardKey.digit9,
            logicalKey: LogicalKeyboardKey.digit9,
            character: '(',
            timeStamp: Duration(milliseconds: 20),
          ),
        );
        await tester.sendKeyDownEvent(LogicalKeyboardKey.digit2);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.digit2);
        await tester.pump();
        display = tester.widget<DisplayScreen>(find.byType(DisplayScreen));
        expect(
          display.calculationString.join(),
          equals('2${FixedValues.multiplyChar}5+(2'),
        );

        // Reset back to 2×5 before equals cursor test
        await tester.tap(find.widgetWithText(ElevatedButton, 'C'));
        await tester.pump();
        for (final key in ['2', FixedValues.multiplyChar, '5']) {
          await tester.tap(find.widgetWithText(ElevatedButton, key));
          await tester.pump();
        }

        // Focus cursor at offset 1, then tap '=' to verify focus resets safely
        await tester.tap(find.byType(TextField).first);
        await tester.pump();
        await tester.tap(find.widgetWithText(ElevatedButton, '='));
        await tester.pump();
        expect(tester.takeException(), isNull);

        display = tester.widget<DisplayScreen>(find.byType(DisplayScreen));
        expect(display.calculationString.join(), equals('10'));

        // Scientific notation chaining regression: 10^-8 + 1 == 1.00000001
        await tester.tap(find.widgetWithText(ElevatedButton, 'C'));
        await tester.pump();
        for (final key in ['1', '÷', '1', '0', '0', '0', '0', '0', '0', '0', '0', '=']) {
          final label = key == '÷' ? FixedValues.divisionChar : key;
          await tester.tap(find.widgetWithText(ElevatedButton, label));
          await tester.pump();
        }
        await tester.tap(find.widgetWithText(ElevatedButton, '+'));
        await tester.pump();
        await tester.tap(find.widgetWithText(ElevatedButton, '1'));
        await tester.pump();

        display = tester.widget<DisplayScreen>(find.byType(DisplayScreen));
        expect(display.mainValue, closeTo(1.00000001, 1e-10));

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      },
    );

    testWidgets('CurrencyChooser double-tap only selects and pops once', (
      WidgetTester tester,
    ) async {
      final tempDir = Directory.systemTemp.createTempSync('chooser_double_');
      PathProviderPlatform.instance = FakePathProviderPlatform(tempDir);
      await tester.runAsync(() async {
        Hive.init(tempDir.path);
        if (!Hive.isAdapterRegistered(0)) {
          Hive.registerAdapter(CurrencyListItemAdapter());
        }
        final listBox =
            await Hive.openBox<CurrencyListItem>(CommonsData.currencyListBox);
        await listBox.add(
          CurrencyListItem(
            currencyCode: 'USD',
            currencyName: 'US Dollar',
            flagURL: 'icons/flags/png100px/us.png',
          ),
        );
      });

      final completer = Completer<void>();
      int calls = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => CurrencyChooser.show(
                  context: context,
                  index: 0,
                  method: CommonsData.fromBox,
                  onCurrencySelected: (_) async {
                    calls++;
                    await completer.future;
                  },
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      final tile = find.text('US Dollar (USD)');
      await tester.tap(tile);
      await tester.pump();
      await tester.tap(tile);
      await tester.pump();

      expect(calls, equals(1));
      completer.complete();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(CurrencyChooser), findsNothing);
      expect(find.text('Open'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        await Hive.close();
        if (tempDir.existsSync()) {
          tempDir.deleteSync(recursive: true);
        }
      });
    });
  });
}
