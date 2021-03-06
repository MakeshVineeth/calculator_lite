import 'package:dio/dio.dart';

class CommonsData {
  static const remoteName = 'FrankFurter API';
  static const remoteSource = 'https://github.com/hakanensari/frankfurter';
  static const remoteUrl = 'https://api.frankfurter.app/latest';
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
  static final Duration dur1 = const Duration(milliseconds: 500);
  static const int timeOut = 5000;

  static Future<Response> getResponse(url) async {
    final options = BaseOptions(
      baseUrl: remoteUrl,
      connectTimeout: timeOut,
      receiveTimeout: timeOut,
      sendTimeout: timeOut,
    );

    Dio dio = Dio(options);

    try {
      return await dio.get(url);
    } on DioError catch (_) {
      return null;
    } catch (_) {
      return null;
    }
  }
}
