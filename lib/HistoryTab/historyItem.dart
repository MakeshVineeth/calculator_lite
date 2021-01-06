import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'historyItem.g.dart';

@HiveType(typeId: 1)
class HistoryItem {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final DateTime dateTime;

  @HiveField(2)
  final String expression;

  @HiveField(3)
  final String value;

  @HiveField(4)
  final String metrics;

  const HistoryItem(
      {@required this.title,
      @required this.dateTime,
      @required this.expression,
      @required this.value,
      @required this.metrics});
}
