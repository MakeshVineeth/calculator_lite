import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

@HiveType()
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
