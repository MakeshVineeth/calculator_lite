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
  });
}
