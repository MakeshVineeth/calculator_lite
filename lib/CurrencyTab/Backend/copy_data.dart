import 'dart:io';
import 'package:calculator_lite/CurrencyTab/Backend/commons.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart';

class CopyData {
  Future<String> get copyData async {
    try {
      bool check = await Hive.boxExists(CommonsData.currencyListBox);

      // If box doesn't exist at all, then copy the data without checking last updated.
      if (!check) {
        await copy();
      } else {
        // read updated_date.txt from app's doc dir.
        String? date = await readData();

        // read updated_date.txt from assets.
        String dateAsset =
            await rootBundle.loadString('assets/updated_date.txt');

        // if not null, then date file exists, then copy all data by checking previous date.
        if (date != null) {
          DateTime? dateTime = DateTime.tryParse(date);
          DateTime? dateTimeAsset = DateTime.tryParse(dateAsset);
          if (dateTime!.isBefore(dateTimeAsset!)) await copy();
        } else {
          await copy();
          await writeData(dateAsset);
        }
      }

      await Hive.openBox(CommonsData.fromBox);
      await Hive.openBox(CommonsData.toBox);
      await Hive.openBox(CommonsData.currencyListBox);
      await Hive.openBox(CommonsData.updatedDateBox);

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
      String folderName = 'hiveUserData';
      String zipFileName = '$folderName.zip';
      ByteData zipContent = await rootBundle.load('assets/$zipFileName');

      Directory tempDir = await getTemporaryDirectory();
      String tempPath = '${tempDir.path}/$zipFileName';

      File zipFile = File(tempPath);
      zipFile.writeAsBytesSync(zipContent.buffer.asUint8List());

      List<int> bytes = File(tempPath).readAsBytesSync();
      Archive archive = ZipDecoder().decodeBytes(bytes);

      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appPath = '${appDocDir.path}/$folderName';
      Directory(appPath).createSync();

      for (ArchiveFile file in archive) {
        String filename = file.name;
        List<int> data = file.content;
        File('$appPath/$filename')
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
      }
    } catch (e) {
      debugPrint("Error Copying Data: $e");
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
      debugPrint("Error Reading data: $e");
      return null;
    }
  }
}
