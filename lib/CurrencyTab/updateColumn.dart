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

    Future.delayed(const Duration(seconds: 5), () async {
      DateTime now = DateTime.now();
      bool checkDateBox = await Hive.boxExists(CommonsData.updatedDateBox);

      if (checkDateBox) {
        final Box dateBox = await Hive.openBox(CommonsData.updatedDateBox);

        String lastChecked = dateBox.get(CommonsData.lastDateChecked);
        DateTime lastCheckedDate = DateTime.tryParse(lastChecked);

        if (lastCheckedDate != null &&
            lastCheckedDate.difference(now).inHours <= 3 &&
            lastCheckedDate.difference(now).inDays == 0) return;
      }

      setState(() {
        status = CommonsData.checkingStr;
      });

      String result = await currencyData.getRemoteData(context);
      setState(() {
        status = result;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    DateTime dateTime = DateTime.tryParse(
        Hive.box(CommonsData.updatedDateBox).get(CommonsData.lastDateChecked));

    String day = dateTime.day.toString();
    String month = dateTime.month.toString();
    String year = dateTime.year.toString();
    String hour = (dateTime.hour == 0) ? '00' : dateTime.hour.toString();
    String minute = (dateTime.minute == 0) ? '00' : dateTime.minute.toString();
    String lastUpdated = '$day-$month-$year $hour:$minute';

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
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              value,
              style: statusStyle(),
              key: UniqueKey(),
            ),
          ),
        ],
      );

  TextStyle statusStyle() => TextStyle(
        fontWeight: FontWeight.w600,
        height: 1.8,
        fontSize: 13,
      );
}
