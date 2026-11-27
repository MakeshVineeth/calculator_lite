import 'dart:convert';

import 'package:calculator_lite/Backend/hive_initializer.dart';
import 'package:calculator_lite/CurrencyTab/Backend/commons.dart';
import 'package:calculator_lite/CurrencyTab/Backend/currency_list_item.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hive_ce/hive.dart';

Map<String, dynamic> _decodeJsonMap(String jsonStr) =>
    json.decode(jsonStr) as Map<String, dynamic>;

class CopyData {
  static const int kSeedVersion = 2;
  static const String kSeedVersionKey = 'currency_seed_version_v2';

  static const Map<String, String> _preferredFlagSuffixes = {
    'USD': '/us.png',
    'EUR': '/eu.png',
    'GBP': '/gb.png',
    'AUD': '/au.png',
    'NZD': '/nz.png',
    'INR': '/in.png',
    'CAD': '/ca.png',
    'JPY': '/jp.png',
    'CHF': '/ch.png',
  };

  static CurrencyListItem? findPreferredCurrency(
    Iterable<CurrencyListItem> items,
    String code,
  ) {
    final targetCode = code.toUpperCase();
    CurrencyListItem? fallback;
    final preferredSuffix = _preferredFlagSuffixes[targetCode];

    for (final item in items) {
      if (item.currencyCode.toUpperCase() != targetCode) continue;
      fallback ??= item;
      final flag = item.flagURL.toLowerCase();
      if (preferredSuffix != null && flag.endsWith(preferredSuffix)) {
        return item;
      }
      if (targetCode == 'EUR' &&
          (flag.endsWith('/de.png') || flag.endsWith('/fr.png'))) {
        return item;
      }
    }
    return fallback;
  }

  Future<String> get copyData async {
    try {
      await HiveInitializer.ensureInitialized();

      final checkFuture = Hive.boxExists(CommonsData.currencyListBox);
      final fromFuture = _openBoxSafe<CurrencyListItem>(CommonsData.fromBox);
      final toFuture = _openBoxSafe<CurrencyListItem>(CommonsData.toBox);
      final currencyFuture =
          _openBoxSafe<CurrencyListItem>(CommonsData.currencyListBox);
      final dateFuture = _openBoxSafe<dynamic>(CommonsData.updatedDateBox);

      final bool check = await checkFuture;
      final fromBox = await fromFuture;
      final toBox = await toFuture;
      final currencyBox = await currencyFuture;
      final dateBox = await dateFuture;

      final int existingSeedVersion =
          (await dateBox.get(kSeedVersionKey, defaultValue: 0)) as int;

      bool didSeed = false;
      if (!check ||
          currencyBox.isEmpty ||
          existingSeedVersion < kSeedVersion ||
          currencyBox.length < 180) {
        await seedFromAsset(currencyBox, dateBox);
        await dateBox.put(kSeedVersionKey, kSeedVersion);
        didSeed = true;
      }

      await _ensureDefaultCards(currencyBox, fromBox, toBox);
      if (didSeed) {
        await _healCards(currencyBox, fromBox, toBox);
      }

      return CommonsData.successToken;
    } catch (e) {
      debugPrint('Exception copyData: $e');
      return CommonsData.errorToken;
    }
  }

  Future<void> _ensureDefaultCards(
    Box<CurrencyListItem> currencyBox,
    Box<CurrencyListItem> fromBox,
    Box<CurrencyListItem> toBox,
  ) async {
    if (currencyBox.isEmpty || (fromBox.isNotEmpty && toBox.isNotEmpty)) {
      return;
    }

    final defaultFrom =
        findPreferredCurrency(currencyBox.values, 'USD') ?? currencyBox.getAt(0)!;
    final defaultTo =
        findPreferredCurrency(currencyBox.values, 'EUR') ?? currencyBox.getAt(0)!;

    if (fromBox.isEmpty) await fromBox.add(defaultFrom);
    if (toBox.isEmpty) await toBox.add(defaultTo);
  }

  Future<void> _healCards(
    Box<CurrencyListItem> currencyBox,
    Box<CurrencyListItem> fromBox,
    Box<CurrencyListItem> toBox,
  ) async {
    if (currencyBox.isEmpty || (fromBox.isEmpty && toBox.isEmpty)) return;

    final Set<String> validPairs = {
      for (final item in currencyBox.values)
        '${item.currencyCode.toUpperCase()}|${item.flagURL}',
    };

    for (final Box<CurrencyListItem> cardBox in [fromBox, toBox]) {
      for (int i = 0; i < cardBox.length; i++) {
        final item = cardBox.getAt(i);
        if (item == null) continue;
        final pair = '${item.currencyCode.toUpperCase()}|${item.flagURL}';
        if (item.flagURL.isNotEmpty && validPairs.contains(pair)) {
          continue;
        }
        final match = findPreferredCurrency(currencyBox.values, item.currencyCode);
        if (match != null && match.flagURL != item.flagURL) {
          await cardBox.putAt(i, match);
        }
      }
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
          jsonStr.length > 32768
              ? await compute(_decodeJsonMap, jsonStr)
              : _decodeJsonMap(jsonStr);

      final String updatedDate =
          data['updated_date'] as String? ?? DateTime.now().toString();
      await dateBox.putAll(<String, dynamic>{
        CommonsData.lastDateChecked: updatedDate,
        CommonsData.updatedDateKey: updatedDate,
      });

      await currencyBox.clear();
      final List<dynamic> currenciesList =
          data['currencies'] as List<dynamic>? ?? [];
      final Set<String> seen = {};
      final List<CurrencyListItem> itemsToAdd = [];

      for (int i = 0; i < currenciesList.length; i++) {
        final Map<String, dynamic> item =
            currenciesList[i] as Map<String, dynamic>;
        final String code = (item['currencyCode'] as String? ?? '').trim();
        final String name = (item['currencyName'] as String? ?? '').trim();
        final String flag = (item['flagURL'] as String? ?? '').trim();
        if (code.isEmpty) continue;

        final String dedupeKey = '${code}_$name'.toLowerCase();
        if (!seen.add(dedupeKey)) continue;

        itemsToAdd.add(
          CurrencyListItem(
            currencyCode: code,
            currencyName: name,
            flagURL: flag,
          ),
        );
      }

      if (itemsToAdd.isNotEmpty) {
        await currencyBox.addAll(itemsToAdd);
      }

      final Map<String, dynamic> rates =
          data['rates'] as Map<String, dynamic>? ?? {};
      final rateEntries = rates.entries.toList();
      const int chunkSize = 16;
      for (int i = 0; i < rateEntries.length; i += chunkSize) {
        final int end = (i + chunkSize < rateEntries.length)
            ? i + chunkSize
            : rateEntries.length;
        await Future.wait(
          rateEntries.sublist(i, end).map((entry) async {
            final String baseCode = entry.key.toLowerCase();
            final Map<String, dynamic> rateMap =
                entry.value as Map<String, dynamic>;
            final bool wasOpen = Hive.isBoxOpen(baseCode);
            final Box<dynamic> rateBox = await _openBoxSafe<dynamic>(baseCode);
            final Map<String, double> batch = {};
            for (final r in rateMap.entries) {
              final val = r.value;
              if (val is num) {
                batch[r.key] = val.toDouble();
              }
            }
            if (batch.isNotEmpty) {
              await rateBox.putAll(batch);
            }
            if (!wasOpen) {
              await rateBox.close();
            }
          }),
        );
      }
    } catch (e) {
      debugPrint('Error seeding currency data: $e');
    }
  }
}
