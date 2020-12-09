import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'commons.dart';
import 'package:hive/hive.dart';
import 'package:calculator_lite/CurrencyTab/Backend/currencyListItem.dart';

class CurrencyData {
  Future<http.Response> getResponse(String url) async {
    try {
      String httpTag = 'https://';
      return await http.get('$httpTag$url');
    } catch (e) {
      return null;
    }
  }

  Future<void> getRemoteData(BuildContext context) async {
    try {
      http.Response _getBaseData =
          await getResponse(CommonsData.remoteUrl); // EUR by default.

      if (_getBaseData != null) {
        Map _baseJson = jsonDecode(_getBaseData.body);

        // Sets the newly updated date.
        String updatedDate = _baseJson['date'];
        Box lastUpdate = await Hive.openBox(CommonsData.updatedDateBox);
        lastUpdate.put(CommonsData.updatedDateKey, updatedDate);

        // get a list of all currencies.
        Map _ratesListBase = _baseJson['rates'];
        List<String> allCurrencies = _ratesListBase.keys.toList();

        // for each currency, store it's values in separate boxes. Each currency is used as base.
        allCurrencies.forEach((currentBase) async {
          String currentBaseUrl = '${CommonsData.remoteUrl}?from=$currentBase';
          await insertData(currentBase, currentBaseUrl);
        });

        // get list of all currencies and store it with Name, FlagURL, Code.
        await Hive.openBox(CommonsData.currencyListBox);
        allCurrencies.forEach((currencyCode) async {
          await writeCurrencyDetails(currencyCode, context);
        });
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  Future<void> writeCurrencyDetails(
      String currencyCode, BuildContext context) async {
    String flagURL;
    String countryName;

    String localJson = await DefaultAssetBundle.of(context)
        .loadString('assets/countries.json');
    List mapsList = json.decode(localJson)['countries']['country'];

    for (Map eachMap in mapsList) {
      if (eachMap['currencyCode'] == currencyCode) {
        countryName = eachMap['countryName'];

        String countryCode =
            eachMap['countryCode'].toString().trim().toLowerCase();
        flagURL = 'icons/flags/$countryCode.png';
        break;
      }
    }

    final currencyBox = Hive.box(CommonsData.currencyListBox);
    final CurrencyListItem currencyListItem = CurrencyListItem(
      currencyCode: currencyCode,
      currencyName: countryName, // getting countryName for now.
      flagURL: flagURL,
    );

    currencyBox.add(currencyListItem);
  }

  Future<void> insertData(String currency, String currentBaseUrl) async {
    try {
      http.Response response = await getResponse(currentBaseUrl);
      if (response != null) {
        Map data = jsonDecode(response.body);
        Map rates = data['rates'] as Map;
        if (rates.length > 0) {
          final box = await Hive.openBox(currency);
          rates.forEach((key, value) => box.put(key, double.tryParse(value)));
        }
      }
    } catch (e) {}
  }
}
