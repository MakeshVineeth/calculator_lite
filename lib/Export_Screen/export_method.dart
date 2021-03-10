import 'package:excel/excel.dart';
import 'package:meta/meta.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ExportExcel {
  final String fileName;

  const ExportExcel({@required this.fileName});

  Future<String> writeExcel({@required List<Map<String, String>> data}) async {
    try {
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Sheet1'];

      List<String> headers = data.elementAt(0).keys.toList();
      sheetObject.appendRow(headers);

      // Create empty Row with count as headers.
      List<String> emptyRow = [];
      headers.forEach((element) => emptyRow.add(''));

      // emptyRow
      sheetObject.appendRow(emptyRow);

      // Color the header row
      for (int i = 0; i < headers.length; i++) {
        sheetObject.updateCell(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
          headers.elementAt(i),
          cellStyle: CellStyle(
            bold: true,
            fontColorHex: '#0000FF',
          ),
        );
      }

      data.forEach((element) {
        sheetObject.appendRow(element.values.toList());
      });

      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path + '/${this.fileName}.xlsx';

      List<int> dataInts = await excel.encode();
      File file = File(tempPath);
      file
        ..createSync(recursive: true)
        ..writeAsBytesSync(dataInts);

      bool present = file.existsSync();
      return present ? tempPath : null;
    } catch (e) {
      print('Export Error: ' + e.toString());
      return null;
    }
  }
}
