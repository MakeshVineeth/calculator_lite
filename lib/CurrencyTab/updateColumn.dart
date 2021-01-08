import 'package:calculator_lite/CurrencyTab/Backend/commons.dart';
import 'package:calculator_lite/CurrencyTab/Backend/getCurrencyData.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:calculator_lite/Backend/helperFunctions.dart';

class UpdateColumn extends StatefulWidget {
  @override
  _UpdateColumnState createState() => _UpdateColumnState();
}

class _UpdateColumnState extends State<UpdateColumn> {
  String src = 'FrankFurter API';
  String status = 'None';
  CurrencyData currencyData = CurrencyData();
  HelperFunctions _helperFunctions = HelperFunctions();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 10), () => updateInitial());
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

      if (mounted)
        setState(() {
          status = CommonsData.checkingStr;
        });

      Response getBaseData = await CommonsData.getResponse(
          CommonsData.remoteUrl); // EUR by default.

      if (getBaseData == null) return;

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

          if (mounted)
            setState(() {
              status = CommonsData.upToDate;
            });
          return;
        }
      }

      if (mounted)
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

      if (mounted)
        setState(() {
          status = result;
        });

      if (result == CommonsData.errorToken) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted)
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

    String lastUpdated = _helperFunctions.getDate(dateTime);

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        textDetail(title: 'Last Checked: ', value: lastUpdated),
        SizedBox(height: 5),
        textDetail(title: 'Status: ', value: status),
        SizedBox(height: 5),
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
        fontSize: 13.5,
      );
}
