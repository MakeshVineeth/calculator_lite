import 'package:calculator_lite/CurrencyTab/Backend/commons.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';

class CurrencyData {
  Future<String> getRemoteData() async {
    try {
      // 1. Fetch latest USD-based rates from remote API
      const String usdUrl = '${CommonsData.remoteUrl}?from=USD';
      final Response<dynamic>? response = await CommonsData.getResponse(usdUrl);

      if (response == null || response.data == null) {
        return CommonsData.errorToken;
      }

      final Map<String, dynamic> data =
          Map<String, dynamic>.from(response.data as Map);
      final Map<String, dynamic> rawRates =
          Map<String, dynamic>.from(data['rates'] as Map);

      // Store USD rates
      final Map<String, double> usdRates = {'USD': 1.0};
      for (final entry in rawRates.entries) {
        final val = entry.value;
        if (val is num) {
          usdRates[entry.key] = val.toDouble();
        }
      }

      final Box<dynamic> usdBox = await _openBoxSafe<dynamic>('usd');
      await usdBox.putAll(usdRates);

      // Compute and update cross-rates for all returned currencies:
      // Rate(Base -> Target) = Rate(USD -> Target) / Rate(USD -> Base)
      for (final baseCode in usdRates.keys) {
        final baseToUsd = usdRates[baseCode];
        if (baseToUsd == null || baseToUsd <= 0) continue;

        final Map<String, double> ratesForBase = {};
        for (final targetCode in usdRates.keys) {
          final targetToUsd = usdRates[targetCode];
          if (targetToUsd != null) {
            ratesForBase[targetCode] = targetToUsd / baseToUsd;
          }
        }

        final Box<dynamic> baseBox =
            await _openBoxSafe<dynamic>(baseCode.toLowerCase());
        await baseBox.putAll(ratesForBase);
      }

      return CommonsData.successToken;
    } catch (e) {
      debugPrint('Unable to retrieve remote data: $e');
      return CommonsData.errorToken;
    }
  }

  Future<Box<T>> _openBoxSafe<T>(String name) async {
    if (Hive.isBoxOpen(name)) {
      return Hive.box<T>(name);
    }
    return await Hive.openBox<T>(name);
  }
}
