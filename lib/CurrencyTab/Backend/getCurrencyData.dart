import 'dart:convert';
import 'package:http/http.dart' as http;
import 'commons.dart';
import 'package:hive/hive.dart';
import 'currencyListItem.dart';

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

        print('All: $allCurrencies Date: $_updatedDate');

        allCurrencies.forEach((currentBase) {
          String currentBaseUrl = '${CommonsData.remoteUrl}?from=$currentBase';
          print('Current Base Url: $currentBaseUrl');

          insertData(currentBase, currentBaseUrl);
        });

        print('Done!');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  void currencyListHive(List<String> allCurrencies) async {
    Box currencyBox = await Hive.openBox(CommonsData.currencyBox);
    allCurrencies.forEach((str) async {
      currencyBox.add(str);
    });

    CurrencyListItem currencyListItem = new CurrencyListItem(currencyCode: 'INR');
    currencyListItem.update();
  }

  void insertData(String currency, String currentBaseUrl) async {
    try {
      http.Response response = await getResponse(currentBaseUrl);
      if (response != null) {
        Map data = jsonDecode(response.body);
        Map rates = data['rates'] as Map;
        if (rates.length > 0) {
          Box box = await Hive.openBox(currency);
          rates.forEach((key, value) => box.put(key, double.tryParse(value)));
        }
      }
    } catch (e) {}
  }
}
