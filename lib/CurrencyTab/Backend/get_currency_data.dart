import 'dart:convert';
import 'package:calculator_lite/Backend/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'commons.dart';
import 'package:hive/hive.dart';
import 'package:dio/dio.dart';
import 'package:calculator_lite/CurrencyTab/Backend/currency_list_item.dart';

class CurrencyData {
  final HelperFunctions helperFunctions = HelperFunctions();

  Future<String> getRemoteData() async {
    try {
      // gets a list of all currencies.
      List<String> allCurrencies = await writeCurrencyDetails();

      if (allCurrencies.isEmpty) {
        return CommonsData.errorToken;
      }

      // for each currency, store it's values in separate boxes. Each currency is used as base in later part of the code.
      List<Future<String>> futures = [];

      for (String currentBase in allCurrencies) {
        String currentBaseUrl = '${CommonsData.remoteUrl}?from=$currentBase';

        futures.add(
          insertData(
            currency: currentBase,
            currentBaseUrl: currentBaseUrl,
          ),
        );
      }

      List<String> results = await Future.wait<String>(futures);
      return results.contains(CommonsData.errorToken)
          ? CommonsData.errorToken
          : CommonsData.successToken;
    } catch (e) {
      debugPrint("Unable to retrieve remote data: $e");
      return CommonsData.errorToken;
    }
  }

  Future<List<String>> writeCurrencyDetails() async {
    try {
      // Load the countries json asset. Used for getting country code for flag icon.
      String countryJson = await rootBundle.loadString('assets/countries.json');
      Map data = json.decode(countryJson);
      List<dynamic> countriesList = data['countries']
          ['country']; // Should be dynamic, else runtime errors.

      // Load the currencies json. Used for retrieving currency name.
      Response? response = await CommonsData.getResponse(
          'https://api.frankfurter.app/currencies');

      if (response == null) return List.empty();

      final Map<String, String> currencyMap =
          Map<String, String>.from(response.data);

      // Loop through all available currencies.
      for (int keyIndex = 0; keyIndex < currencyMap.length; keyIndex++) {
        String currencyCode = currencyMap.keys.elementAt(keyIndex);
        String flagURL = "";
        String currencyName = "";

        // Find out country code in order to get flag.
        for (int index = 0; index < countriesList.length; index++) {
          Map<String, dynamic> eachCountry = countriesList[index];

          if (eachCountry['currencyCode'] == currencyCode) {
            currencyName = currencyMap[currencyCode]!;

            String countryCode = eachCountry['countryCode'].toLowerCase();
            flagURL = 'icons/flags/png/$countryCode.png';
            break;
          }
        }

        final CurrencyListItem currencyListItem = CurrencyListItem(
          currencyCode: currencyCode,
          currencyName: currencyName,
          flagURL: flagURL,
        );

        final currencyBox = await Hive.openBox(CommonsData.currencyListBox);
        await currencyBox.put(keyIndex, currencyListItem);
      }

      return currencyMap.keys.toList();
    } catch (e) {
      debugPrint("Error writing data: $e");
      return List.empty();
    }
  }

  Future<String> insertData({
    required String currency,
    required String currentBaseUrl,
  }) async {
    try {
      final box = await Hive.openBox(currency.toLowerCase());
      Response? response = await CommonsData.getResponse(currentBaseUrl);

      if (response?.data != null) {
        final Map data = Map<String, dynamic>.from(response?.data);
        Map<String, dynamic> rates = data['rates'];

        await box.putAll(rates);
        return CommonsData.successToken;
      } else {
        debugPrint(
            "Response error with CurrentUrl: $currentBaseUrl and current: $currency.");

        return CommonsData.errorToken;
      }
    } catch (e) {
      debugPrint("Error inserting data: $e");
      return CommonsData.errorToken;
    }
  }
}
