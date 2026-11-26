import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:calculator_lite/CurrencyTab/Backend/commons.dart';
import 'package:calculator_lite/CurrencyTab/Backend/copy_data.dart';
import 'package:calculator_lite/CurrencyTab/Backend/currency_list_item.dart';
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
    tempDir = Directory.systemTemp.createTempSync('copy_data_test_');
    PathProviderPlatform.instance = FakePathProviderPlatform(tempDir);
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(CurrencyListItemAdapter());
    }
  });

  tearDown(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('CopyData copyData initializes boxes without error', () async {
    final copyData = CopyData();
    final result = await copyData.copyData;
    expect(result, equals(CommonsData.successToken));
    expect(Hive.isBoxOpen(CommonsData.fromBox), isTrue);
    expect(Hive.isBoxOpen(CommonsData.toBox), isTrue);
    expect(Hive.isBoxOpen(CommonsData.currencyListBox), isTrue);
    expect(Hive.isBoxOpen(CommonsData.updatedDateBox), isTrue);
    expect(await Hive.boxExists('jpy'), isTrue);
    expect(Hive.isBoxOpen('jpy'), isFalse);
    expect(Hive.isBoxOpen('gbp'), isFalse);

    final currencyBox = Hive.box<CurrencyListItem>(CommonsData.currencyListBox);
    expect(currencyBox.length, greaterThanOrEqualTo(180));

    final zarItems =
        currencyBox.values.where((c) => c.currencyCode == 'ZAR').toList();
    expect(zarItems.length, equals(1));
    expect(zarItems.first.flagURL, equals('icons/flags/png100px/za.png'));

    // Check no duplicate keys
    final seen = <String>{};
    for (final item in currencyBox.values) {
      final key = '${item.currencyCode}_${item.currencyName}'.toLowerCase();
      expect(seen.contains(key), isFalse, reason: 'Duplicate found: $key');
      seen.add(key);
    }
  });

  test('CopyData re-seeds if existing box is outdated with legacy 32 items', () async {
    // Simulate legacy box with 32 items and legacy seed version
    final currencyBox =
        await Hive.openBox<CurrencyListItem>(CommonsData.currencyListBox);
    final dateBox = await Hive.openBox<dynamic>(CommonsData.updatedDateBox);
    await dateBox.put(CopyData.kSeedVersionKey, 1); // Old version

    // Insert fake old items
    for (int i = 0; i < 32; i++) {
      await currencyBox.add(CurrencyListItem(
        currencyCode: 'USD',
        currencyName: 'Old Item $i',
        flagURL: '',
      ));
    }
    expect(currencyBox.length, equals(32));

    // Run copyData - should detect version < 2 and re-seed with 180+
    final copyData = CopyData();
    final result = await copyData.copyData;
    expect(result, equals(CommonsData.successToken));
    expect(currencyBox.length, greaterThanOrEqualTo(180));
    expect(dateBox.get(CopyData.kSeedVersionKey), equals(CopyData.kSeedVersion));
  });
}
