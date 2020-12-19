import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'commons.dart';
import 'package:hive/hive.dart';
import 'package:dio/dio.dart';
import 'package:calculator_lite/CurrencyTab/Backend/currencyListItem.dart';

class CurrencyData {
  Dio dio = Dio();

  Future<void> getRemoteData(BuildContext context) async {
    try {
      Response _getBaseData =
          await dio.get(CommonsData.remoteUrl); // EUR by default.

      if (_getBaseData != null) {
        Map _baseJson = Map<String, dynamic>.from(_getBaseData.data);

        // Sets the newly updated date.
        String updatedDate = _baseJson['date'];
        Box lastUpdate = await Hive.openBox(CommonsData.updatedDateBox);
        lastUpdate.put(CommonsData.updatedDateKey, updatedDate);

        // get a list of all currencies.
        Map _ratesListBase = _baseJson['rates'];
        List<String> allCurrencies = _ratesListBase.keys.toList();

        // for each currency, store it's values in separate boxes. Each currency is used as base.

        for (String currentBase in allCurrencies) {
          String currentBaseUrl = '${CommonsData.remoteUrl}?from=$currentBase';
          await insertData(currentBase, currentBaseUrl);
        }

        // get list of all currencies and store it with Name, FlagURL, Code.
        for (int count = 0; count < allCurrencies.length; count++)
          await writeCurrencyDetails(
              currencyCode: allCurrencies.elementAt(count),
              context: context,
              keyIndex: count);
      }
    } catch (e) {
      print('Exception: ' + e.toString());
    }
  }

  Future<void> writeCurrencyDetails(
      {@required String currencyCode,
      @required BuildContext context,
      @required int keyIndex}) async {
    String flagURL;
    String countryName;

    String localJson = await DefaultAssetBundle.of(context)
        .loadString('assets/countries.json');
    Map data = json.decode(localJson);
    List mapsList = data['countries']['country'];

    for (Map eachMap in mapsList) {
      if (eachMap['currencyCode'] == currencyCode) {
        countryName = eachMap['countryName'];

        String countryCode =
            eachMap['countryCode'].toString().trim().toLowerCase();
        flagURL = 'icons/flags/png/$countryCode.png';
        break;
      }
    }

    final currencyBox = await Hive.openBox(CommonsData.currencyListBox);
    final CurrencyListItem currencyListItem = CurrencyListItem(
      currencyCode: currencyCode,
      currencyName: countryName, // getting countryName for now.
      flagURL: flagURL,
    );

    await currencyBox.put(keyIndex, currencyListItem);
  }

  Future<void> insertData(String currency, String currentBaseUrl) async {
    final box = await Hive.openBox(currency.toLowerCase());
    try {
      Response response = await dio.get(currentBaseUrl);

      if (response != null) {
        Map data = Map<String, dynamic>.from(response.data);
        Map rates = data['rates'] as Map;

        for (MapEntry each in rates.entries) {
          String key = each.key.toString();
          String val = each.value.toString();

          await box.put(key, val);
        }
      }
    } catch (e) {
      print('Exception: ' + e.toString());
    }

    await box.close();
  }
}
