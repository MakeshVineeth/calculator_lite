import 'dart:io';
import 'package:calculator_lite/CurrencyTab/Backend/commons.dart';
import 'package:calculator_lite/CurrencyTab/Backend/currency_list_item.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart';

class CopyData {
  Future<String> get copyData async {
    try {
      final bool check = await Hive.boxExists(CommonsData.currencyListBox);

      // If box doesn't exist at all, then copy the data without checking last updated.
      if (!check) {
        await copy();
      } else {
        try {
          final String? date = await readData();
          final String dateAsset =
              await rootBundle.loadString('assets/updated_date.txt');

          if (date != null) {
            final DateTime? dateTime = DateTime.tryParse(date);
            final DateTime? dateTimeAsset = DateTime.tryParse(dateAsset);
            if (dateTime != null &&
                dateTimeAsset != null &&
                dateTime.isBefore(dateTimeAsset)) {
              await copy();
            }
          } else {
            await copy();
            await writeData(dateAsset);
          }
        } catch (e) {
          debugPrint('Notice loading updated_date.txt: $e');
        }
      }

      if (!Hive.isBoxOpen(CommonsData.fromBox)) {
        await Hive.openBox<CurrencyListItem>(CommonsData.fromBox);
      }
      if (!Hive.isBoxOpen(CommonsData.toBox)) {
        await Hive.openBox<CurrencyListItem>(CommonsData.toBox);
      }
      if (!Hive.isBoxOpen(CommonsData.currencyListBox)) {
        await Hive.openBox<CurrencyListItem>(CommonsData.currencyListBox);
      }
      if (!Hive.isBoxOpen(CommonsData.updatedDateBox)) {
        await Hive.openBox<dynamic>(CommonsData.updatedDateBox);
      }

      return CommonsData.successToken;
    }

    // For exceptions
    catch (e) {
      debugPrint('Exception copyData: $e');
      return CommonsData.errorToken;
    }
  }

  Future<void> copy() async {
    try {
      const String folderName = 'hiveUserData';
      const String zipFileName = '$folderName.zip';
      final ByteData zipContent = await rootBundle.load('assets/$zipFileName');

      final Directory tempDir = await getTemporaryDirectory();
      final String tempPath = '${tempDir.path}/$zipFileName';

      final File zipFile = File(tempPath);
      zipFile.writeAsBytesSync(zipContent.buffer.asUint8List());

      final List<int> bytes = File(tempPath).readAsBytesSync();
      final Archive archive = ZipDecoder().decodeBytes(bytes);

      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String appPath = '${appDocDir.path}/$folderName';
      Directory(appPath).createSync();

      for (final ArchiveFile file in archive) {
        final String filename = file.name;
        final List<int> data = file.content is List<int>
            ? (file.content as List<int>)
            : (file.content as List<dynamic>).cast<int>();
        File('$appPath/$filename')
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
      }
    } catch (e) {
      debugPrint('Error Copying Data: $e');
    }
  }

  // Gets local path of app doc dir
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  // Gets updated_date text file from App's Document Dir
  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/updated_date.txt');
  }

  // write text to updated_date.txt
  Future<File> writeData(String text) async {
    final file = await _localFile;
    return file.writeAsString(text);
  }

  // read data from updated date text
  Future<String?> readData() async {
    try {
      final file = await _localFile;

      if (file.existsSync()) {
        return await file.readAsString();
      } else {
        return null;
      }
    } catch (e) {
      debugPrint('Error Reading data: $e');
      return null;
    }
  }
}
