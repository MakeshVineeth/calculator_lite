import 'dart:convert';
import 'package:calculator_lite/CurrencyTab/Backend/commons.dart';
import 'package:calculator_lite/CurrencyTab/Backend/currency_list_item.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_ce/hive.dart';

class CurrencyData {
  Future<String> getRemoteData() async {
    try {
      final List<String> allCurrencies = await writeCurrencyList();

      if (allCurrencies.isEmpty) {
        return CommonsData.errorToken;
      }

      final List<Future<String>> futures = [];
      for (final String currentBase in allCurrencies) {
        final String currentBaseUrl = '${CommonsData.remoteUrl}?from=$currentBase';
        futures.add(
          insertData(currency: currentBase, currentBaseUrl: currentBaseUrl),
        );
      }

      final List<String> results = await Future.wait<String>(futures);
      return results.contains(CommonsData.errorToken)
          ? CommonsData.errorToken
          : CommonsData.successToken;
    } catch (e) {
      debugPrint('Unable to retrieve remote data: $e');
      return CommonsData.errorToken;
    }
  }

  Future<List<String>> writeCurrencyList() async {
    try {
      final String countryJson =
          await rootBundle.loadString('assets/countries.json');
      final Map<String, dynamic> data =
          json.decode(countryJson) as Map<String, dynamic>;
      final List<dynamic> countriesList =
          (data['countries'] as Map<String, dynamic>)['country'] as List<dynamic>;

      final Response<dynamic>? response = await CommonsData.getResponse(
        CommonsData.getCurrencyListUrl,
      );

      if (response == null || response.data == null) return List.empty();

      final Map<String, dynamic> rawMap = response.data is Map
          ? (response.data as Map).cast<String, dynamic>()
          : <String, dynamic>{};
      final Map<String, String> currencyMap =
          rawMap.map((k, v) => MapEntry(k, v.toString()));

      final Box<CurrencyListItem> currencyBox =
          await Hive.openBox<CurrencyListItem>(CommonsData.currencyListBox);

      for (int keyIndex = 0; keyIndex < currencyMap.length; keyIndex++) {
        final String currencyCode = currencyMap.keys.elementAt(keyIndex);
        String flagURL = '';
        String currencyName = '';

        for (int index = 0; index < countriesList.length; index++) {
          final Map<String, dynamic> eachCountry =
              countriesList[index] as Map<String, dynamic>;

          if (eachCountry['currencyCode'] == currencyCode) {
            currencyName = currencyMap[currencyCode] ?? '';
            final String countryCode =
                (eachCountry['countryCode'] as String? ?? '').toLowerCase();
            flagURL = 'icons/flags/png100px/$countryCode.png';
            break;
          }
        }

        final CurrencyListItem currencyListItem = CurrencyListItem(
          currencyCode: currencyCode,
          currencyName: currencyName,
          flagURL: flagURL,
        );

        await currencyBox.put(keyIndex, currencyListItem);
      }

      return currencyMap.keys.toList();
    } catch (e) {
      debugPrint('Error writing data: $e');
      return List.empty();
    }
  }

  Future<String> insertData({
    required String currency,
    required String currentBaseUrl,
  }) async {
    try {
      final Box<dynamic> box =
          await Hive.openBox<dynamic>(currency.toLowerCase());
      final Response<dynamic>? response =
          await CommonsData.getResponse(currentBaseUrl);

      if (response?.data != null) {
        final Map<String, dynamic> data =
            Map<String, dynamic>.from(response!.data as Map);
        final Map<String, dynamic> rates =
            Map<String, dynamic>.from(data['rates'] as Map);

        await box.putAll(rates);
        return CommonsData.successToken;
      } else {
        debugPrint(
          'Response error with CurrentUrl: $currentBaseUrl and current: $currency.',
        );
        return CommonsData.errorToken;
      }
    } catch (e) {
      debugPrint('Error inserting data: $e');
      return CommonsData.errorToken;
    }
  }
}
