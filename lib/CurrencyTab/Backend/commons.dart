import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class CommonsData {
  static const remoteName = 'FrankFurter API';
  static const remoteSource = 'https://github.com/lineofflight/frankfurter';
  static const remoteUrl = 'https://api.frankfurter.dev/v1/latest';
  static const getCurrencyListUrl = 'https://api.frankfurter.dev/v1/currencies';
  static const currencyListBox = 'currencies';
  static const fromBox = 'from_box';
  static const toBox = 'to_box';
  static const updatedDateBox = 'updated_date';
  static const updatedDateKey = 'date';
  static const lastDateChecked = 'last_checked';
  static const successToken = 'Updated!';
  static const errorToken = 'Failed';
  static const retryString = 'Retrying..';
  static const progressToken = 'Downloading..';
  static const checkingStr = 'Checking...';
  static const upToDate = 'Up to date';
  static const waitingStr = 'Waiting..';
  static const autoUpdateOffStr = 'Auto-update off';
  static const recentCheckWindow = Duration(hours: 3);
  static const autoUpdatePref = 'auto_update_status';
  static const autoUpdateEnabled = 'auto_update_yes';
  static const autoUpdateDisabled = 'auto_update_no';
  static const Duration dur1 = Duration(milliseconds: 500);

  static Future<Response<dynamic>?> getResponse(String url) async {
    final options = BaseOptions(
      baseUrl: remoteUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    );

    final Dio dio = Dio(options);

    try {
      return await dio.get<dynamic>(url);
    } on DioException catch (e) {
      debugPrint('DioException: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('HTTP Request Error: $e');
      return null;
    }
  }
}
