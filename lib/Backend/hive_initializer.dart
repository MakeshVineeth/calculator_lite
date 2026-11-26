import 'package:calculator_lite/CurrencyTab/Backend/currency_list_item.dart';
import 'package:calculator_lite/HistoryTab/history_item.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

class HiveInitializer {
  static Future<void>? _initFuture;

  static void startInit() {
    _initFuture ??= _runInit();
  }

  static Future<void> _runInit() async {
    await Hive.initFlutter('hiveUserData');
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(CurrencyListItemAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(HistoryItemAdapter());
    }
  }

  static Future<void> ensureInitialized() async {
    final future = _initFuture;
    if (future != null) {
      await future;
    }
  }
}
