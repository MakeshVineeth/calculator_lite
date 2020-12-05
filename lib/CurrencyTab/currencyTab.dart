import 'package:flutter/material.dart';
import 'Backend/getCurrencyData.dart';
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
    currencyData.getRemoteData();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
