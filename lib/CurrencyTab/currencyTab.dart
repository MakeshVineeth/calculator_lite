import 'dart:math';
import 'package:calculator_lite/CurrencyTab/Backend/commons.dart';
import 'package:calculator_lite/CurrencyTab/Backend/getCurrencyData.dart';
import 'package:calculator_lite/CurrencyTab/CardUI.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

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

  int n = 0;

  void updateData() async {
    CurrencyData currencyData = CurrencyData();
    await currencyData.getRemoteData(context);
  }

  Future<void> runData() async {
    await Hive.openBox(CommonsData.fromBox);
    await Hive.openBox(CommonsData.toBox);
    await Hive.openBox(CommonsData.currencyListBox);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () => addCurrencyCard(),
            icon: Icon(
              Icons.add_circle_rounded,
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: runData(),
              builder: (context, snapshot) => widgetsData(snapshot),
            ),
          )
        ],
      ),
    );
  }

  void addCurrencyCard() async {
    final list = Hive.box(CommonsData.currencyListBox);
    if (list.length > 0) {
      Random random = Random();

      int t1 = random.nextInt(list.length);
      int t2 = random.nextInt(list.length);

      final fromBox = await Hive.openBox(CommonsData.fromBox);
      fromBox.add(list.getAt(t1));

      final toBox = await Hive.openBox(CommonsData.toBox);
      toBox.add(list.getAt(t2));
    }
  }

  Widget widgetsData(AsyncSnapshot snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      if (!snapshot.hasError) {
        final box = Hive.box(CommonsData.fromBox);
        return ValueListenableBuilder(
          valueListenable: box.listenable(),
          builder: (context, fromBox, widget) => ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) => CardUI(index: index),
          ),
        );
      } else
        return Text('Error'); // for error receiving.
    } else
      return CircularProgressIndicator();
  }
}
