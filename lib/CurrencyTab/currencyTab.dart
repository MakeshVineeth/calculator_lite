import 'package:calculator_lite/CurrencyTab/Backend/currencyListItem.dart';
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
    //CurrencyData currencyData = CurrencyData();
    //currencyData.getRemoteData();

    CurrencyListItem currencyListItem =
        new CurrencyListItem(currencyCode: 'INR');
    currencyListItem.update();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
