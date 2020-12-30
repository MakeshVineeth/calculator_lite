import 'package:calculator_lite/CurrencyTab/Backend/commons.dart';
import 'package:calculator_lite/CurrencyTab/Backend/getCurrencyData.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
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
  Dio dio = Dio();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () => updateInitial());
  }

  void updateInitial() async {
    try {
      DateTime now = DateTime.now();
      bool checkDateBox = await Hive.boxExists(CommonsData.updatedDateBox);

      if (checkDateBox) {
        final Box dateBox = await Hive.openBox(CommonsData.updatedDateBox);

        String lastChecked = dateBox.get(CommonsData.lastDateChecked);
        DateTime lastCheckedDate = DateTime.tryParse(lastChecked);

        if (lastCheckedDate != null &&
            lastCheckedDate.difference(now).inHours >= -3 &&
            lastCheckedDate.difference(now).inDays == 0) return;
      }

      setState(() {
        status = CommonsData.checkingStr;
      });

      Response getBaseData =
          await dio.get(CommonsData.remoteUrl); // EUR by default.

      Map baseJson = Map<String, dynamic>.from(getBaseData.data);

      // Gets the newly updated date online.
      String updatedDate = baseJson['date'];
      if (checkDateBox) {
        final Box dateBox = Hive.box(CommonsData.updatedDateBox);
        String dateStr = dateBox.get(CommonsData.updatedDateKey);
        DateTime dateTimeObj = DateTime.tryParse(dateStr);
        DateTime online = DateTime.tryParse(updatedDate);

        if (dateTimeObj != null &&
            dateTimeObj.year == online.year &&
            dateTimeObj.day == online.day &&
            dateTimeObj.month == online.month) {
          await dateBox.put(CommonsData.lastDateChecked, now.toString());

          setState(() {
            status = CommonsData.upToDate;
          });
          return;
        }
      }

      setState(() {
        status = CommonsData.progressToken;
      });

      String result = await currencyData.getRemoteData(
          context: context, baseJson: baseJson);

      if (result == CommonsData.successToken) {
        Box dateBox = await Hive.openBox(CommonsData.updatedDateBox);
        await dateBox.put(CommonsData.updatedDateKey, updatedDate);
        await dateBox.put(CommonsData.lastDateChecked, now.toString());
      }

      setState(() {
        status = result;
      });

      if (result == CommonsData.errorToken) {
        Future.delayed(const Duration(seconds: 2), () {
          setState(() {
            status = CommonsData.retryString;
            Future.delayed(const Duration(seconds: 1), () => updateInitial());
          });
        });
      }
    }

    // on network error
    on DioError catch (e) {
      print('Exception: ' + e.toString());
    } catch (e) {
      print('Exception: ' + e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime dateTime = DateTime.tryParse(
        Hive.box(CommonsData.updatedDateBox).get(CommonsData.lastDateChecked));

    String day = dateTime.day.toString();
    String month = dateTime.month.toString();
    String year = dateTime.year.toString();
    String time = DateFormat.Hm().format(dateTime);
    String lastUpdated = '$day-$month-$year $time';

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
        fontSize: 13.5,
      );
}
