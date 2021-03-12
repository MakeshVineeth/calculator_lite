import 'package:calculator_lite/CurrencyTab/Backend/commons.dart';
import 'package:calculator_lite/CurrencyTab/Backend/getCurrencyData.dart';
import 'package:calculator_lite/common_methods/common_methods.dart';
import 'package:calculator_lite/fixedValues.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:calculator_lite/Backend/helperFunctions.dart';
import 'package:calculator_lite/CurrencyTab/Backend/updateListen.dart';

class UpdateColumn extends StatefulWidget {
  final UpdateListen updateListen;

  UpdateColumn({@required this.updateListen});

  @override
  _UpdateColumnState createState() => _UpdateColumnState();
}

class _UpdateColumnState extends State<UpdateColumn> {
  String status = 'None';
  final CurrencyData currencyData = CurrencyData();
  final HelperFunctions _helperFunctions = HelperFunctions();
  static final int defaultTries = 1;
  int triesLeft = defaultTries;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 10), () => updateInitial());

    // Check if Update now is clicked from other screen or widget.
    widget.updateListen.addListener(() => updateInitial(force: true));
  }

  void updateInitial({bool force = false}) async {
    try {
      if (widget.updateListen.inProgress) return;
      widget.updateListen.inProgress = true;

      DateTime now = DateTime.now();
      bool checkDateBox = await Hive.boxExists(CommonsData.updatedDateBox);

      if (checkDateBox && !force) {
        final Box dateBox = await Hive.openBox(CommonsData.updatedDateBox);

        String lastChecked = dateBox.get(CommonsData.lastDateChecked);
        DateTime lastCheckedDate = DateTime.tryParse(lastChecked);

        if (lastCheckedDate != null &&
            lastCheckedDate.difference(now).inHours >= -3 &&
            lastCheckedDate.difference(now).inDays == 0) {
          widget.updateListen.inProgress = false;
          return;
        }
      }

      if (mounted) setState(() => status = CommonsData.checkingStr);

      Response getBaseData = await CommonsData.getResponse(
          CommonsData.remoteUrl); // EUR by default.

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

          if (mounted) setState(() => status = CommonsData.upToDate);
          {
            widget.updateListen.inProgress = false;
            return;
          }
        }
      }

      if (mounted) setState(() => status = CommonsData.progressToken);

      String result = await currencyData.getRemoteData(
        context: context,
        baseJson: baseJson,
      );

      if (result == CommonsData.successToken) {
        Box dateBox = await Hive.openBox(CommonsData.updatedDateBox);
        await dateBox.put(CommonsData.updatedDateKey, updatedDate);
        await dateBox.put(CommonsData.lastDateChecked, now.toString());
        if (mounted) setState(() => triesLeft = defaultTries);
      }

      if (mounted) setState(() => status = result);
      retryMethod(result);
    } catch (e) {
      widget.updateListen.inProgress = false;
      if (mounted) setState(() => status = CommonsData.errorToken);
      retryMethod(CommonsData.errorToken);
    }
  }

  void retryMethod(String result) {
    if (triesLeft == 0) return;

    if (result == CommonsData.errorToken) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted)
          setState(() {
            status = CommonsData.retryString;
            if (triesLeft > 0) triesLeft -= 1;
          });

        Future.delayed(
            const Duration(seconds: 1), () => updateInitial(force: true));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateTime dateTime = DateTime.tryParse(
        Hive.box(CommonsData.updatedDateBox).get(CommonsData.lastDateChecked));
    final String lastUpdated = _helperFunctions.getDate(dateTime);

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        textDetail(
            title: 'Last Checked: ', value: lastUpdated, context: context),
        SizedBox(height: 5),
        textDetail(title: 'Status: ', value: status, context: context),
        SizedBox(height: 5),
        srcLink(context: context),
      ],
    );
  }

  Widget textDetail(
      {@required String title,
      @required String value,
      @required BuildContext context}) {
    Color _default = Theme.of(context).textTheme.button.color;

    if (value == CommonsData.errorToken) _default = Colors.redAccent;

    if (value == CommonsData.successToken || value == CommonsData.upToDate)
      _default = Colors.green;

    return Row(
      children: [
        Text(
          title,
          style: statusStyle,
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            value,
            style: statusStyle.copyWith(
              color: _default,
            ),
            key: UniqueKey(),
          ),
        ),
      ],
    );
  }

  Widget srcLink({@required BuildContext context}) {
    return Row(
      children: [
        Text(
          'Source: ',
          style: statusStyle,
        ),
        InkWell(
          onTap: () => launchUrl(url: CommonsData.remoteSource),
          borderRadius: FixedValues.large,
          child: Padding(
            padding: const EdgeInsets.all(3.0),
            child: Text(
              CommonsData.remoteName,
              style: statusStyle.copyWith(
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    );
  }

  TextStyle statusStyle = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 13.5,
  );
}
