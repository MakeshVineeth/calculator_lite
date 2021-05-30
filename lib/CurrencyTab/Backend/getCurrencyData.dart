import 'dart:convert';
import 'package:calculator_lite/Backend/helperFunctions.dart';
import 'package:flutter/cupertino.dart';
import 'commons.dart';
import 'package:hive/hive.dart';
import 'package:dio/dio.dart';
import 'package:calculator_lite/CurrencyTab/Backend/currencyListItem.dart';

class CurrencyData {
  HelperFunctions helperFunctions = HelperFunctions();

  Future<String> getRemoteData(
      {@required BuildContext context, @required Map baseJson}) async {
    try {
      // get a list of all currencies.
      Map<String, double> _ratesListBase = baseJson['rates'];
      List<String> allCurrencies = _ratesListBase.keys.toList();

      // for each currency, store it's values in separate boxes. Each currency is used as base.
      List<Future<String>> futures = [
        writeCurrencyDetails(currencyList: allCurrencies, context: context)
      ];

      for (String currentBase in allCurrencies) {
        String currentBaseUrl = '${CommonsData.remoteUrl}?from=$currentBase';

        futures.add(
          insertData(
              currency: currentBase,
              currentBaseUrl: currentBaseUrl,
              jsonData: (currentBase.toLowerCase() == 'eur') ? baseJson : null),
        );
      }

      await Future.wait(futures);
      return CommonsData.successToken;
    } catch (e) {
      return CommonsData.errorToken;
    }
  }

  Future<String> writeCurrencyDetails({
    @required List<String> currencyList,
    @required BuildContext context,
  }) async {
    try {
      // Load the countries json asset. Used for getting country code for flag icon.
      String countryJson = await DefaultAssetBundle.of(context)
          .loadString('assets/countries.json');
      Map data = json.decode(countryJson);
      List<Map<String, String>> countriesList = data['countries']['country'];

      // Load the currencies json. Used for retrieving currency name.
      Response response = await CommonsData.getResponse(
          'https://api.frankfurter.app/currencies');

      if (response == null) return CommonsData.errorToken;

      Map<String, String> currencyMap = response.data;

      // Loop through all available currencies.
      for (int keyIndex = 0; keyIndex < currencyList.length; keyIndex++) {
        String currencyCode = currencyList.elementAt(keyIndex);
        String flagURL;
        String currencyName;

        // Loop through all countries list and check if currency code is same.
        for (Map<String, String> eachCountry in countriesList)
          if (eachCountry['currencyCode'] == currencyCode) {
            currencyName = currencyMap[currencyCode];

            String countryCode = eachCountry['countryCode'].toLowerCase();
            flagURL = 'icons/flags/png/$countryCode.png';
            break;
          }

        final CurrencyListItem currencyListItem = CurrencyListItem(
          currencyCode: currencyCode,
          currencyName: currencyName,
          flagURL: flagURL,
        );

        final currencyBox = await Hive.openBox(CommonsData.currencyListBox);
        await currencyBox.put(keyIndex, currencyListItem);
      }

      return CommonsData.successToken;
    } catch (_) {
      return CommonsData.errorToken;
    }
  }

  Future<String> insertData({
    @required String currency,
    @required String currentBaseUrl,
    Map jsonData,
  }) async {
    try {
      final box = await Hive.openBox(currency.toLowerCase());

      // if jsonData not null, meaning this currency data already exists, no need to get response again.
      if (jsonData != null) {
        Map<String, double> rates = jsonData['rates'] as Map;
        await box.putAll(rates);
        return CommonsData.successToken;
      }

      Response response = await CommonsData.getResponse(currentBaseUrl);

      if (response != null) {
        Map data = Map<String, dynamic>.from(response.data);
        Map<String, double> rates = data['rates'];

        await box.putAll(rates);
        return CommonsData.successToken;
      } else
        return CommonsData.errorToken;
    } catch (_) {
      return CommonsData.errorToken;
    }
  }
}
