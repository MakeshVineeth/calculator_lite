import 'dart:io';
import 'package:calculator_lite/CurrencyTab/Backend/commons.dart';
import 'package:hive/hive.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart';

Future<String> copyData() async {
  try {
    bool check = await Hive.boxExists(CommonsData.currencyListBox);

    if (!check) {
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
