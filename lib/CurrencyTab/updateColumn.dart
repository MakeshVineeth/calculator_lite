import 'package:calculator_lite/CurrencyTab/Backend/getCurrencyData.dart';
import 'package:flutter/material.dart';

class UpdateColumn extends StatefulWidget {
  @override
  _UpdateColumnState createState() => _UpdateColumnState();
}

class _UpdateColumnState extends State<UpdateColumn> {
  String lastUpdated = '';
  String src = '';
  String status = '';
  CurrencyData currencyData = CurrencyData();

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 10), () async {
      String result = await currencyData.getRemoteData(context);
      print(result);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        textDetail(title: 'Last Updated: ', value: lastUpdated),
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
      );
}
