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
      const String usdUrl = '${CommonsData.remoteUrl}?from=USD';
      final Response<dynamic>? response = await CommonsData.getResponse(usdUrl);

      if (response == null || response.data == null) {
        return CommonsData.errorToken;
      }

      final Map<String, dynamic> data =
          Map<String, dynamic>.from(response.data as Map);
      final Map<String, dynamic> rawRates =
          Map<String, dynamic>.from(data['rates'] as Map);

      final Map<String, double> usdRates = {'USD': 1.0};
      for (final entry in rawRates.entries) {
        final val = entry.value;
        if (val is num) {
          usdRates[entry.key] = val.toDouble();
        }
      }

      final activeBaseCodes = _activeBaseCurrencyCodes();
      final bool usdWasOpen = Hive.isBoxOpen('usd');
      final Box<dynamic> usdBox = await _openBoxSafe<dynamic>('usd');
      await usdBox.putAll(usdRates);

      final Box<CurrencyListItem> currencyBox =
          await _openBoxSafe<CurrencyListItem>(CommonsData.currencyListBox);
      await _registerNewCurrencies(usdRates.keys.toList(), currencyBox);

      for (final baseCode in usdRates.keys) {
        final baseToUsd = usdRates[baseCode];
        if (baseToUsd == null || baseToUsd <= 0) continue;

        final String baseCodeLower = baseCode.toLowerCase();
        if (baseCodeLower == 'usd') continue;

        final Map<String, double> ratesForBase = {};
        for (final targetCode in usdRates.keys) {
          final targetToUsd = usdRates[targetCode];
          if (targetToUsd != null) {
            ratesForBase[targetCode] = targetToUsd / baseToUsd;
          }
        }

        final bool wasOpen = Hive.isBoxOpen(baseCodeLower);
        final Box<dynamic> baseBox = await _openBoxSafe<dynamic>(baseCodeLower);
        await baseBox.putAll(ratesForBase);
        if (!wasOpen && !activeBaseCodes.contains(baseCodeLower)) {
          await baseBox.close();
        }
      }

      if (!usdWasOpen && !activeBaseCodes.contains('usd')) {
        await usdBox.close();
      }

      return CommonsData.successToken;
    } catch (e) {
      debugPrint('Unable to retrieve remote data: $e');
      return CommonsData.errorToken;
    }
  }

  Set<String> _activeBaseCurrencyCodes() {
    if (!Hive.isBoxOpen(CommonsData.fromBox)) {
      return const {};
    }
    return Hive.box<CurrencyListItem>(CommonsData.fromBox)
        .values
        .map((e) => e.currencyCode.toLowerCase())
        .toSet();
  }

  Future<void> _registerNewCurrencies(
    List<String> remoteCodes,
    Box<CurrencyListItem> currencyBox,
  ) async {
    try {
      final existingCodes =
          currencyBox.values.map((e) => e.currencyCode.toUpperCase()).toSet();

      final newCodes = remoteCodes
          .map((k) => k.toUpperCase())
          .where((k) => !existingCodes.contains(k))
          .toList();

      if (newCodes.isEmpty) return;

      final String jsonStr =
          await rootBundle.loadString('assets/countries.json');
      final Map<String, dynamic> data =
          json.decode(jsonStr) as Map<String, dynamic>;
      final List<dynamic> countryList =
          (data['countries'] as Map<String, dynamic>)['country']
                  as List<dynamic>? ??
              [];

      final Map<String, Map<String, String>> countryMap = {};
      for (final c in countryList) {
        final code = (c['currencyCode'] as String? ?? '').toUpperCase();
        if (code.isNotEmpty && !countryMap.containsKey(code)) {
          countryMap[code] = {
            'countryName': c['countryName'] as String? ?? '',
            'countryCode': (c['countryCode'] as String? ?? '').toLowerCase(),
          };
        }
      }

      final List<CurrencyListItem> toAdd = [];
      for (final code in newCodes) {
        final info = countryMap[code];
        final String countryName = info?['countryName'] ?? '';
        final String countryCode = info?['countryCode'] ?? '';
        final String displayName =
            countryName.isNotEmpty ? '$countryName - $code' : code;
        final String flagURL =
            countryCode.isNotEmpty ? 'icons/flags/png100px/$countryCode.png' : '';

        toAdd.add(
          CurrencyListItem(
            currencyCode: code,
            currencyName: displayName,
            flagURL: flagURL,
          ),
        );
      }

      if (toAdd.isNotEmpty) {
        await currencyBox.addAll(toAdd);
      }
    } catch (e) {
      debugPrint('Error registering new dynamic currencies: $e');
    }
  }

  Future<Box<T>> _openBoxSafe<T>(String name) async {
    if (Hive.isBoxOpen(name)) {
      return Hive.box<T>(name);
    }
    return await Hive.openBox<T>(name);
  }
}
