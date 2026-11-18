import 'dart:convert';
import 'package:calculator_lite/CurrencyTab/Backend/commons.dart';
import 'package:calculator_lite/CurrencyTab/Backend/currency_list_item.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:flutter/services.dart';

class CopyData {
  Future<String> get copyData async {
    try {
      final bool check = await Hive.boxExists(CommonsData.currencyListBox);

      final fromBox = await _openBoxSafe<CurrencyListItem>(CommonsData.fromBox);
      final toBox = await _openBoxSafe<CurrencyListItem>(CommonsData.toBox);
      final currencyBox =
          await _openBoxSafe<CurrencyListItem>(CommonsData.currencyListBox);
      final dateBox = await _openBoxSafe<dynamic>(CommonsData.updatedDateBox);

      // Seed data if currencies box is empty or doesn't exist
      if (!check || currencyBox.isEmpty) {
        await seedFromAsset(currencyBox, dateBox);
      }

      // Seed initial from/to cards if empty
      if (fromBox.isEmpty && currencyBox.isNotEmpty) {
        CurrencyListItem defaultFrom = currencyBox.getAt(0)!;
        CurrencyListItem defaultTo = currencyBox.getAt(0)!;

        for (final item in currencyBox.values) {
          if (item.currencyCode == 'USD') defaultFrom = item;
          if (item.currencyCode == 'EUR') defaultTo = item;
        }

        await fromBox.add(defaultFrom);
        await toBox.add(defaultTo);
      }

      return CommonsData.successToken;
    } catch (e) {
      debugPrint('Exception copyData: $e');
      return CommonsData.errorToken;
    }
  }

  Future<Box<T>> _openBoxSafe<T>(String name) async {
    if (Hive.isBoxOpen(name)) {
      return Hive.box<T>(name);
    }
    return await Hive.openBox<T>(name);
  }

  Future<void> seedFromAsset(
    Box<CurrencyListItem> currencyBox,
    Box<dynamic> dateBox,
  ) async {
    try {
      final String jsonStr =
          await rootBundle.loadString('assets/currencies_data.json');
      final Map<String, dynamic> data =
          json.decode(jsonStr) as Map<String, dynamic>;

      final String updatedDate =
          data['updated_date'] as String? ?? DateTime.now().toString();
      await dateBox.put(CommonsData.lastDateChecked, updatedDate);
      await dateBox.put(CommonsData.updatedDateKey, updatedDate);

      final List<dynamic> currenciesList =
          data['currencies'] as List<dynamic>? ?? [];
      for (int i = 0; i < currenciesList.length; i++) {
        final Map<String, dynamic> item =
            currenciesList[i] as Map<String, dynamic>;
        final currencyItem = CurrencyListItem(
          currencyCode: item['currencyCode'] as String,
          currencyName: item['currencyName'] as String,
          flagURL: item['flagURL'] as String,
        );
        await currencyBox.put(i, currencyItem);
      }

      final Map<String, dynamic> rates =
          data['rates'] as Map<String, dynamic>? ?? {};
      for (final entry in rates.entries) {
        final String baseCode = entry.key.toLowerCase();
        final Map<String, dynamic> rateMap =
            entry.value as Map<String, dynamic>;
        final Box<dynamic> rateBox = await _openBoxSafe<dynamic>(baseCode);
        for (final r in rateMap.entries) {
          final val = r.value;
          if (val is num) {
            await rateBox.put(r.key, val.toDouble());
          }
        }
      }
    } catch (e) {
      debugPrint('Error seeding currency data: $e');
    }
  }
}
