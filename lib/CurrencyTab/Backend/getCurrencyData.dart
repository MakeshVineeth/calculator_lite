import 'dart:convert';
import 'package:http/http.dart' as http;
import 'commons.dart';

class CurrencyData {
  Future<http.Response> getResponse(String url) async {
    try {
      String httpTag = 'https://';
      return await http.get('$httpTag$url');
    } catch (e) {
      return null;
    }
  }

  void getRemoteData() async {
    try {
      http.Response _getBaseData =
          await getResponse(CommonsData.remoteUrl); // EUR by default.

      if (_getBaseData != null) {
        Map _baseJson = jsonDecode(_getBaseData.body);

        print(_baseJson);

        String _updatedDate = _baseJson['date'];
        Map _ratesListBase = _baseJson['rates'];
        List<String> allCurrencies = _ratesListBase.keys.toList();

        allCurrencies.forEach((current) {});
      }
    } catch (e) {
      print('Exception: $e');
    }
  }
}
