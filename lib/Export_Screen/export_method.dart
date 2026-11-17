import 'package:excel/excel.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ExportExcel {
  final String fileName;

  const ExportExcel({required this.fileName});

  Future<String?> writeExcel({required List<Map<String, String>> data}) async {
    try {
      final excel = Excel.createExcel();
      final Sheet sheetObject = excel['Sheet1'];

      final List<CellValue> headers =
          data.elementAt(0).keys.map((x) => TextCellValue(x)).toList();
      sheetObject.appendRow(headers);

      // Create empty Row with count as headers.
      final List<CellValue> emptyRow = [];
      for (final CellValue _ in headers) {
        emptyRow.add(TextCellValue(''));
      }

      // emptyRow
      sheetObject.appendRow(emptyRow);

      // Color the header row
      for (int i = 0; i < headers.length; i++) {
        sheetObject.updateCell(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
          headers.elementAt(i),
          cellStyle: CellStyle(
            bold: true,
            fontColorHex: ExcelColor.fromHexString('#0000FF'),
          ),
        );
      }

      for (final element in data) {
        sheetObject.appendRow(
          element.values.map((x) => TextCellValue(x)).toList(),
        );
      }

      final Directory tempDir = await getTemporaryDirectory();
      final String tempPath = '${tempDir.path}/$fileName.xlsx';

      final List<int>? dataInts = excel.encode();
      final File file =
          File(tempPath)
            ..createSync(recursive: true)
            ..writeAsBytesSync(dataInts!);

      final bool present = file.existsSync();
      return present ? tempPath : null;
    } catch (_) {
      return null;
    }
  }
}
