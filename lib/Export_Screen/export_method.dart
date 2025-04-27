import 'package:excel/excel.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ExportExcel {
  final String fileName;

  const ExportExcel({required this.fileName});

  Future<String?> writeExcel({required List<Map<String, String>> data}) async {
    try {
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Sheet1'];

      List<CellValue> headers =
          data.elementAt(0).keys.map((x) => TextCellValue(x)).toList();
      sheetObject.appendRow(headers);

      // Create empty Row with count as headers.
      List<CellValue> emptyRow = [];
      for (CellValue _ in headers) {
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
            fontColorHex: ExcelColor.fromHexString("#0000FF"),
          ),
        );
      }

      for (var element in data) {
        sheetObject.appendRow(
          element.values.map((x) => TextCellValue(x)).toList(),
        );
      }

      Directory tempDir = await getTemporaryDirectory();
      String tempPath = '${tempDir.path}/$fileName.xlsx';

      List<int>? dataInts = excel.encode();
      File file =
          File(tempPath)
            ..createSync(recursive: true)
            ..writeAsBytesSync(dataInts!);

      bool present = file.existsSync();
      return present ? tempPath : null;
    } catch (_) {
      return null;
    }
  }
}
