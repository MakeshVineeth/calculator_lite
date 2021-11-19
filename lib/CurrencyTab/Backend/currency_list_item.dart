import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'currency_list_item.g.dart';

@HiveType(typeId: 0)
class CurrencyListItem {
  @HiveField(0)
  final String currencyCode;

  @HiveField(1)
  final String flagURL;

  @HiveField(2)
  final String currencyName;

  CurrencyListItem({
    @required this.currencyCode,
    @required this.flagURL,
    @required this.currencyName,
  });
}
