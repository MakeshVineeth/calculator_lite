import 'package:calculator_lite/CurrencyTab/Backend/commons.dart';
import 'package:calculator_lite/CurrencyTab/Backend/copy_data.dart';
import 'package:calculator_lite/CurrencyTab/Backend/get_currency_data.dart';
import 'package:calculator_lite/common_methods/common_methods.dart';
import 'package:calculator_lite/fixed_values.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:calculator_lite/Backend/helper_functions.dart';
import 'package:calculator_lite/CurrencyTab/Backend/update_listener.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateColumn extends StatefulWidget {
  final UpdateListen updateListen;

  const UpdateColumn({@required this.updateListen, Key key}) : super(key: key);

  @override
  _UpdateColumnState createState() => _UpdateColumnState();
}

class _UpdateColumnState extends State<UpdateColumn> {
  String status = 'None';
  final CurrencyData currencyData = CurrencyData();
  final HelperFunctions _helperFunctions = HelperFunctions();
  static const int defaultTries = 1;
  int triesLeft = defaultTries;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () => updateInitial());

    // Check if Update now is clicked from other screen or widget.
    widget.updateListen.addListener(() => updateInitial(force: true));
  }

  Future<void> updateInitial({bool force = false}) async {
    try {
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      final updateStatus = preferences.getString(CommonsData.autoUpdatePref) ??
          CommonsData.autoUpdateEnabled;

      // Checking if user disabled auto updates. And allow manual update.
      if (updateStatus.contains(CommonsData.autoUpdateDisabled) && !force) {
        return;
      }

      if (widget.updateListen.inProgress) return;
      widget.updateListen.inProgress = true;

      DateTime now = DateTime.now();
      bool checkDateBox = await Hive.boxExists(CommonsData.updatedDateBox);

      // if force is enabled, skip date checking.
      if (checkDateBox && !force) {
        final Box dateBox = await Hive.openBox(CommonsData.updatedDateBox);

        String lastChecked = dateBox.get(CommonsData.lastDateChecked);
        DateTime lastCheckedDate = DateTime.tryParse(lastChecked);

        if (lastCheckedDate.difference(now).inHours >= -3 &&
            lastCheckedDate.difference(now).inDays == 0) {
          widget.updateListen.inProgress = false;
          return;
        }
      }

      if (mounted) setState(() => status = CommonsData.checkingStr);

      Response getBaseData =
          await CommonsData.getResponse(CommonsData.remoteUrl);

      // Gets the base currency data to get a database data for checking.
      Map baseJson = Map<String, dynamic>.from(getBaseData.data);

      // Gets the newly updated date online.
      String updatedDate = baseJson['date'];
      if (checkDateBox && !force) {
        final Box dateBox = Hive.box(CommonsData.updatedDateBox);
        String dateStr = dateBox.get(CommonsData.updatedDateKey);
        DateTime dateTimeObj = DateTime.tryParse(dateStr);
        DateTime online = DateTime.tryParse(updatedDate);

        if (dateTimeObj.year == online.year &&
            dateTimeObj.day == online.day &&
            dateTimeObj.month == online.month) {
          await dateBox.put(CommonsData.lastDateChecked, now.toString());
          widget.updateListen.inProgress = false;

          if (mounted) setState(() => status = CommonsData.upToDate);
          return;
        }
      }

      if (mounted) setState(() => status = CommonsData.progressToken);

      String result = await currencyData.getRemoteData(context: context);
      debugPrint("Data retrieve result: $result");

      if (result == CommonsData.successToken) {
        Box dateBox = await Hive.openBox(CommonsData.updatedDateBox);
        await dateBox.put(CommonsData.updatedDateKey, updatedDate);
        await dateBox.put(CommonsData.lastDateChecked, now.toString());

        // writes the updated_date.txt in app's doc dir.
        await CopyData().writeData(updatedDate);
        if (mounted) setState(() => triesLeft = defaultTries);
      }

      if (mounted) setState(() => status = result);
      widget.updateListen.inProgress = false;

      retryMethod(result);
    } catch (e) {
      debugPrint("Error Updating: $e");
      widget.updateListen.inProgress = false;

      if (mounted) setState(() => status = CommonsData.errorToken);
      retryMethod(CommonsData.errorToken);
    }
  }

  // Retries in case of network issues.
  void retryMethod(String result) {
    // Keep track of no of tries
    if (triesLeft == 0) {
      widget.updateListen.inProgress = false;
      return;
    }

    // Wait for 4 seconds and retry again.
    if (result == CommonsData.errorToken) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            status = CommonsData.retryString;
            if (triesLeft > 0) triesLeft -= 1;
          });
        }

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
        const SizedBox(height: 5),
        textDetail(title: 'Status: ', value: status, context: context),
        const SizedBox(height: 5),
        srcLink(context: context),
      ],
    );
  }

  Widget textDetail(
      {@required String title,
      @required String value,
      @required BuildContext context}) {
    Color default = Theme.of(context).textTheme.labelLarge.color;

    if (value == CommonsData.errorToken) default = Colors.redAccent;
    if (value == CommonsData.successToken || value == CommonsData.upToDate) {
      default = Colors.green;
    }

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
              color: default,
            ),
            key: UniqueKey(),
          ),
        ),
      ],
    );
  }

  Widget srcLink({@required BuildContext context}) => Row(
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

  TextStyle statusStyle = const TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 13.5,
  );
}
