import 'dart:math';
import 'package:calculator_lite/CurrencyTab/Backend/commons.dart';
import 'package:calculator_lite/CurrencyTab/Backend/getCurrencyData.dart';
import 'package:calculator_lite/CurrencyTab/CardUI.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class CurrencyTab extends StatefulWidget {
  @override
  _CurrencyTabState createState() => _CurrencyTabState();
}

class _CurrencyTabState extends State<CurrencyTab> {
  @override
  void initState() {
    super.initState();
    updateData();
  }

  @override
  void dispose() {
    Hive.close();
    super.dispose();
  }

  void updateData() async {
    CurrencyData currencyData = CurrencyData();
    await currencyData.getRemoteData();
  }

  Future<void> runData() async {
    await Hive.openBox(CommonsData.fromBox);
    await Hive.openBox(CommonsData.toBox);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () => addCurrencyCard(),
            icon: Icon(
              Icons.add_box_rounded,
            ),
          ),
          FutureBuilder(
            future: runData(),
            builder: (context, snapshot) => widgetsData(snapshot),
          )
        ],
      ),
    );
  }

  void addCurrencyCard() {
    final list = Hive.openBox(CommonsData.currencyListBox) as Box;
    if (list.length > 0) {
      Random random = Random();

      int t1 = random.nextInt(list.length);
      int t2 = random.nextInt(list.length);

      final fromBox = Hive.openBox(CommonsData.fromBox) as Box;
      fromBox.add(list.get(t1));

      final toBox = Hive.openBox(CommonsData.toBox) as Box;
      toBox.add(list.get(t2));
    }
  }

  Widget widgetsData(AsyncSnapshot snapshot) {
    if (snapshot.connectionState == ConnectionState.active) {
      final fromBox = Hive.box(CommonsData.fromBox);

      return ListView.builder(
        itemCount: fromBox.length,
        itemBuilder: (context, index) => CardUI(index: index),
      );
    } else
      return CircularProgressIndicator();
  }
}
