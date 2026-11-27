import 'dart:io';

import 'package:calculator_lite/Export_Screen/export_commons.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

class ExportExcel {
  final String fileName;

  const ExportExcel({required this.fileName});

  static final RegExp _controlCharsRegex =
      RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F]');
  static final RegExp _fileNameUnsafeRegex = RegExp(r'[^A-Za-z0-9_-]');

  static String sanitizeCellText(String value) {
    final cleaned = value.replaceAll(_controlCharsRegex, '');
    final trimmedLeft = cleaned.trimLeft();
    if (trimmedLeft.isNotEmpty) {
      final first = trimmedLeft[0];
      if (first == '=' ||
          first == '+' ||
          first == '-' ||
          first == '@' ||
          cleaned.startsWith('\t') ||
          cleaned.startsWith('\r')) {
        return "'$cleaned";
      }
    }
    return cleaned;
  }

  static CellValue toSafeCellValue(String key, String value) {
    if (key == CommonStrings.valTextTile || key.toLowerCase() == 'value') {
      final parsed = double.tryParse(value.trim());
      if (parsed != null && parsed.isFinite) {
        return DoubleCellValue(parsed);
      }
    }
    return TextCellValue(sanitizeCellText(value));
  }

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
          element.entries
              .map((entry) => toSafeCellValue(entry.key, entry.value))
              .toList(),
        );
      }

      final Directory tempDir = await getTemporaryDirectory();
      final String safeFileName =
          fileName.replaceAll(_fileNameUnsafeRegex, '_');
      final String tempPath =
          '${tempDir.path}/${safeFileName.isEmpty ? 'export' : safeFileName}.xlsx';

      final List<int>? dataInts = excel.encode();
      if (dataInts == null) return null;
      final File file = File(tempPath);
      await file.create(recursive: true);
      await file.writeAsBytes(dataInts);

      final bool present = await file.exists();
      return present ? tempPath : null;
    } catch (_) {
      return null;
    }
  }
}
