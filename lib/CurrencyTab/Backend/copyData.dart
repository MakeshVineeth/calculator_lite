import 'dart:io';
import 'package:calculator_lite/CurrencyTab/Backend/commons.dart';
import 'package:hive/hive.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart';

class CopyData {
  Future<String> get copyData async {
    try {
      bool check = await Hive.boxExists(CommonsData.currencyListBox);

      if (!check)
        await copy();
      else {
        String date = await readData();
        String dateAsset =
            await rootBundle.loadString('assets/updated_date.txt');

        if (date != null) {
          DateTime dateTime = DateTime.tryParse(date);
          DateTime dateTimeAsset = DateTime.tryParse(dateAsset);
          if (dateTime.isBefore(dateTimeAsset)) await copy();
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
      print('Exception copyData: ' + e.toString());
      return CommonsData.errorToken;
    }
  }

  Future<void> copy() async {
    try {
      String folderName = 'hiveUserData';
      String zipFileName = folderName + '.zip';
      ByteData zipContent = await rootBundle.load('assets/' + zipFileName);

      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path + '/' + zipFileName;

      File zipFile = File(tempPath);
      zipFile.writeAsBytesSync(zipContent.buffer.asUint8List());

      List<int> bytes = File(tempPath).readAsBytesSync();
      Archive archive = ZipDecoder().decodeBytes(bytes);

      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appPath = appDocDir.path + '/$folderName';
      Directory(appPath).createSync();

      for (ArchiveFile file in archive) {
        String filename = file.name;
        List<int> data = file.content;
        File(appPath + '/' + filename)
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
      }
    } catch (e) {}
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/updated_date.txt');
  }

  Future<File> writeData(String text) async {
    final file = await _localFile;
    return file.writeAsString('$text');
  }

  Future<String> readData() async {
    try {
      final file = await _localFile;

      if (file.existsSync())
        return await file.readAsString();
      else
        return null;
    } catch (e) {
      return null;
    }
  }
}
