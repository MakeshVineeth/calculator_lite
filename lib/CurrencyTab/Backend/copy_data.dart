import 'dart:convert';
import 'package:calculator_lite/CurrencyTab/Backend/commons.dart';
import 'package:calculator_lite/CurrencyTab/Backend/currency_list_item.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:flutter/services.dart';

class CopyData {
  static const int kSeedVersion = 2;
  static const String kSeedVersionKey = 'currency_seed_version_v2';

  Future<String> get copyData async {
    try {
      final bool check = await Hive.boxExists(CommonsData.currencyListBox);

      final fromBox = await _openBoxSafe<CurrencyListItem>(CommonsData.fromBox);
      final toBox = await _openBoxSafe<CurrencyListItem>(CommonsData.toBox);
      final currencyBox =
          await _openBoxSafe<CurrencyListItem>(CommonsData.currencyListBox);
      final dateBox = await _openBoxSafe<dynamic>(CommonsData.updatedDateBox);

      final int existingSeedVersion =
          (await dateBox.get(kSeedVersionKey, defaultValue: 0)) as int;

      // Seed or re-seed if currencies box doesn't exist, is empty, seed version is outdated, or items < 180
      if (!check ||
          currencyBox.isEmpty ||
          existingSeedVersion < kSeedVersion ||
          currencyBox.length < 180) {
        await seedFromAsset(currencyBox, dateBox);
        await dateBox.put(kSeedVersionKey, kSeedVersion);
      }

      // Seed initial from/to cards if empty or invalid
      if (currencyBox.isNotEmpty && (fromBox.isEmpty || toBox.isEmpty)) {
        CurrencyListItem defaultFrom = currencyBox.getAt(0)!;
        CurrencyListItem defaultTo = currencyBox.getAt(0)!;

        for (final item in currencyBox.values) {
          if (item.currencyCode == 'USD') defaultFrom = item;
          if (item.currencyCode == 'EUR') defaultTo = item;
        }

        if (fromBox.isEmpty) await fromBox.add(defaultFrom);
        if (toBox.isEmpty) await toBox.add(defaultTo);
      }

      // Heal existing from/to cards with updated flags/names if needed
      if (fromBox.isNotEmpty && currencyBox.isNotEmpty) {
        for (int i = 0; i < fromBox.length; i++) {
          final item = fromBox.getAt(i);
          if (item != null) {
            final match = currencyBox.values.firstWhere(
              (c) => c.currencyCode == item.currencyCode,
              orElse: () => item,
            );
            if (match.flagURL != item.flagURL) {
              await fromBox.putAt(i, match);
            }
          }
        }
      }
      if (toBox.isNotEmpty && currencyBox.isNotEmpty) {
        for (int i = 0; i < toBox.length; i++) {
          final item = toBox.getAt(i);
          if (item != null) {
            final match = currencyBox.values.firstWhere(
              (c) => c.currencyCode == item.currencyCode,
              orElse: () => item,
            );
            if (match.flagURL != item.flagURL) {
              await toBox.putAt(i, match);
            }
          }
        }
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

      await currencyBox.clear();
      final List<dynamic> currenciesList =
          data['currencies'] as List<dynamic>? ?? [];
      final Set<String> seen = {};
      for (int i = 0; i < currenciesList.length; i++) {
        final Map<String, dynamic> item =
            currenciesList[i] as Map<String, dynamic>;
        final String code = (item['currencyCode'] as String? ?? '').trim();
        final String name = (item['currencyName'] as String? ?? '').trim();
        final String flag = (item['flagURL'] as String? ?? '').trim();
        if (code.isEmpty) continue;

        final String dedupeKey = '${code}_$name'.toLowerCase();
        if (!seen.add(dedupeKey)) continue;

        final currencyItem = CurrencyListItem(
          currencyCode: code,
          currencyName: name,
          flagURL: flag,
        );
        await currencyBox.add(currencyItem);
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
