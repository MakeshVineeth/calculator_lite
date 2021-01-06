import 'package:calculator_lite/HistoryTab/historyCard.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'commonsHistory.dart';

class HistoryTab extends StatefulWidget {
  @override
  _HistoryTabState createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Hive.openBox(CommonsHistory.historyBox),
      builder: (context, AsyncSnapshot data) {
        if (data.connectionState == ConnectionState.done) {
          final Box box = data.data;
          return ListView.builder(
            physics:
                BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            itemCount: box.length,
            itemBuilder: (context, index) => HistoryCard(index: index),
          );
        } else
          return CircularProgressIndicator();
      },
    );
  }
}
