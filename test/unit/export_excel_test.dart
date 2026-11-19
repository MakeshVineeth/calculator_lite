import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:calculator_lite/Export_Screen/export_method.dart';
import 'package:excel/excel.dart';
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

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('export_test_');
    PathProviderPlatform.instance = FakePathProviderPlatform(tempDir);
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('ExportExcel generates valid Excel file with headers and calculation data', () async {
    const fileName = 'test_export_calc';
    const exportExcel = ExportExcel(fileName: fileName);

    final List<Map<String, String>> sampleData = [
      {
        'Title': 'Calculation 1',
        'Date': '2026-11-18 10:00',
        'Expression': '5 + 5',
        'Value': '10',
      },
      {
        'Title': 'Calculation 2',
        'Date': '2026-11-18 10:05',
        'Expression': '100 * 2',
        'Value': '200',
      },
    ];

    final String? filePath = await exportExcel.writeExcel(data: sampleData);

    expect(filePath, isNotNull);
    final file = File(filePath!);
    expect(file.existsSync(), isTrue);
    expect(file.lengthSync(), greaterThan(0));

    // Verify it is a valid Excel spreadsheet
    final bytes = file.readAsBytesSync();
    final excel = Excel.decodeBytes(bytes);
    expect(excel.tables.keys, contains('Sheet1'));

    final sheet = excel['Sheet1'];
    expect(sheet.maxRows, greaterThanOrEqualTo(3)); // header + empty row + data rows
  });
}
