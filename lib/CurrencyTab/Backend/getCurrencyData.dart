import 'dart:convert';
import 'package:calculator_lite/Backend/helperFunctions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'commons.dart';
import 'package:hive/hive.dart';
import 'package:dio/dio.dart';
import 'package:calculator_lite/CurrencyTab/Backend/currencyListItem.dart';

class CurrencyData {
  final HelperFunctions helperFunctions = HelperFunctions();

  Future<String> getRemoteData(
      {@required BuildContext context, @required Map baseJson}) async {
    try {
      // get a list of all currencies. Value must be dynamic as it can contain both ints and doubles.
      Map<String, dynamic> _ratesListBase = baseJson['rates'];
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

      List<String> results = await Future.wait<String>(futures);
      return results.contains(CommonsData.errorToken)
          ? CommonsData.errorToken
          : CommonsData.successToken;
    } catch (_) {
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
      List<dynamic> countriesList = data['countries']
          ['country']; // Should be dynamic, else runtime errors.

      // Load the currencies json. Used for retrieving currency name.
      Response response = await CommonsData.getResponse(
          'https://api.frankfurter.app/currencies');

      if (response == null) return CommonsData.errorToken;

      final Map<String, String> currencyMap =
          Map<String, String>.from(response.data);

      // Loop through all available currencies.
      for (int keyIndex = 0; keyIndex < currencyList.length; keyIndex++) {
        String currencyCode = currencyList.elementAt(keyIndex);
        String flagURL;
        String currencyName;

        for (int index = 0; index < countriesList.length; index++) {
          Map<String, dynamic> eachCountry = countriesList[index];

          if (eachCountry['currencyCode'] == currencyCode) {
            currencyName = currencyMap[currencyCode];

            String countryCode = eachCountry['countryCode'].toLowerCase();
            flagURL = 'icons/flags/png/$countryCode.png';
            break;
          }
        }

        // Loop through all countries list and check if currency code is same.

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
        final Map<String, dynamic> rates = jsonData['rates'];
        await box.putAll(rates);
        return CommonsData.successToken;
      }

      Response response = await CommonsData.getResponse(currentBaseUrl);

      if (response != null) {
        final Map data = Map<String, dynamic>.from(response.data);
        Map<String, dynamic> rates = data['rates'];

        await box.putAll(rates);
        return CommonsData.successToken;
      } else
        return CommonsData.errorToken;
    } catch (_) {
      return CommonsData.errorToken;
    }
  }
}
