import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:calculator_lite/CurrencyTab/currency_tab.dart';
import 'package:calculator_lite/CurrencyTab/Backend/commons.dart';
import 'package:calculator_lite/CurrencyTab/Backend/currency_list_item.dart';
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
    final currencyBox = await Hive.openBox<CurrencyListItem>(CommonsData.currencyListBox);
    await Hive.openBox<dynamic>(CommonsData.updatedDateBox);

    final usd = CurrencyListItem(currencyCode: 'USD', currencyName: 'US Dollar', flagURL: 'icons/flags/png100px/us.png');
    final eur = CurrencyListItem(currencyCode: 'EUR', currencyName: 'Euro', flagURL: 'icons/flags/png100px/eu.png');
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
}
