import 'dart:io';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:calculator_lite/HistoryTab/commonsHistory.dart';

class ExportFunction {
  Future<void> export() async {
    List<Directory> dir = await getExternalStorageDirectories();
    dir.forEach((element) {
      print(element.path);
    });

    final box = Hive.box(CommonsHistory.historyBox);
    print(box.length);
  }
}
