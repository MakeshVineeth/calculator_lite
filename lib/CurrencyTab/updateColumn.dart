import 'package:calculator_lite/CurrencyTab/Backend/commons.dart';
import 'package:calculator_lite/CurrencyTab/Backend/getCurrencyData.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class UpdateColumn extends StatefulWidget {
  @override
  _UpdateColumnState createState() => _UpdateColumnState();
}

class _UpdateColumnState extends State<UpdateColumn> {
  String src = 'FrankFurter API';
  String status = 'None';
  CurrencyData currencyData = CurrencyData();

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 20), () async {
      // String result = await currencyData.getRemoteData(context);
      // print(result);
    });
  }

  @override
  Widget build(BuildContext context) {
    DateTime dateTime = DateTime.tryParse(
        Hive.box(CommonsData.updatedDateBox).get(CommonsData.lastDateChecked));
    String lastUpdated =
        '${dateTime.day}-${dateTime.month}-${dateTime.year} ${dateTime.hour}:${dateTime.minute}';

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        textDetail(title: 'Last Checked: ', value: lastUpdated),
        textDetail(title: 'Status: ', value: status),
        textDetail(title: 'Source: ', value: src),
      ],
    );
  }

  Widget textDetail({@required String title, @required String value}) => Row(
        children: [
          Text(
            title,
            style: statusStyle(),
          ),
          Text(
            value,
            style: statusStyle(),
          )
        ],
      );

  TextStyle statusStyle() => TextStyle(
        fontWeight: FontWeight.w600,
        height: 1.8,
        fontSize: 13,
      );
}
