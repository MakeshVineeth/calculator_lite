import 'dart:async';
import 'package:calculator_lite/CurrencyTab/Backend/commons.dart';
import 'package:calculator_lite/CurrencyTab/Backend/get_currency_data.dart';
import 'package:calculator_lite/common_methods/common_methods.dart';
import 'package:calculator_lite/fixed_values.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:calculator_lite/Backend/helper_functions.dart';
import 'package:calculator_lite/CurrencyTab/Backend/update_listener.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateColumn extends StatefulWidget {
  final UpdateListen updateListen;

  const UpdateColumn({required this.updateListen, super.key});

  @override
  State<UpdateColumn> createState() => _UpdateColumnState();
}

class _UpdateColumnState extends State<UpdateColumn> {
  late String status;
  final CurrencyData currencyData = CurrencyData();
  final HelperFunctions _helperFunctions = HelperFunctions();
  static const int defaultTries = 1;
  int triesLeft = defaultTries;

  Timer? _autoUpdateTimer;

  String _initialStatus() {
    final String? lastChecked = Hive.box<dynamic>(CommonsData.updatedDateBox)
        .get(CommonsData.lastDateChecked) as String?;
    final DateTime? lastCheckedDate =
        lastChecked == null ? null : DateTime.tryParse(lastChecked);
    final bool checkedRecently = lastCheckedDate != null &&
        DateTime.now().difference(lastCheckedDate) <
            CommonsData.recentCheckWindow;
    return checkedRecently ? CommonsData.upToDate : CommonsData.waitingStr;
  }

  @override
  void initState() {
    super.initState();
    status = _initialStatus();
    _autoUpdateTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) updateInitial();
    });

    // Check if Update now is clicked from other screen or widget.
    widget.updateListen.addListener(_handleUpdateListener);
  }

  void _handleUpdateListener() {
    if (mounted) updateInitial(force: true);
  }

  @override
  void dispose() {
    _autoUpdateTimer?.cancel();
    widget.updateListen.removeListener(_handleUpdateListener);
    super.dispose();
  }

  Future<void> updateInitial({bool force = false}) async {
    try {
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      final updateStatus = preferences.getString(CommonsData.autoUpdatePref) ??
          CommonsData.autoUpdateEnabled;

      // Checking if user disabled auto updates. And allow manual update.
      if (updateStatus.contains(CommonsData.autoUpdateDisabled) && !force) {
        if (mounted) setState(() => status = CommonsData.autoUpdateOffStr);
        return;
      }

      if (widget.updateListen.inProgress) return;
      widget.updateListen.inProgress = true;

      final DateTime now = DateTime.now();
      final bool checkDateBox = await Hive.boxExists(CommonsData.updatedDateBox);

      // if force is enabled, skip date checking.
      if (checkDateBox && !force) {
        final Box<dynamic> dateBox =
            await Hive.openBox<dynamic>(CommonsData.updatedDateBox);

        final String? lastChecked =
            dateBox.get(CommonsData.lastDateChecked) as String?;
        if (lastChecked != null) {
          final DateTime? lastCheckedDate = DateTime.tryParse(lastChecked);

          if (lastCheckedDate != null &&
              lastCheckedDate.difference(now).inHours >= -3 &&
              lastCheckedDate.difference(now).inDays == 0) {
            widget.updateListen.inProgress = false;
            return;
          }
        }
      }

      if (mounted) setState(() => status = CommonsData.checkingStr);

      final Response<dynamic>? getBaseData =
          await CommonsData.getResponse(CommonsData.remoteUrl);

      if (getBaseData?.data == null) {
        widget.updateListen.inProgress = false;
        if (mounted) setState(() => status = CommonsData.errorToken);
        retryMethod(CommonsData.errorToken);
        return;
      }

      final Map<String, dynamic> baseJson =
          Map<String, dynamic>.from(getBaseData!.data as Map);

      final String updatedDate = baseJson['date'] as String? ?? '';
      if (checkDateBox && !force && updatedDate.isNotEmpty) {
        final Box<dynamic> dateBox =
            Hive.box<dynamic>(CommonsData.updatedDateBox);
        final String? dateStr =
            dateBox.get(CommonsData.updatedDateKey) as String?;
        if (dateStr != null) {
          final DateTime? dateTimeObj = DateTime.tryParse(dateStr);
          final DateTime? online = DateTime.tryParse(updatedDate);

          if (dateTimeObj != null &&
              online != null &&
              dateTimeObj.year == online.year &&
              dateTimeObj.day == online.day &&
              dateTimeObj.month == online.month) {
            await dateBox.put(CommonsData.lastDateChecked, now.toString());
            widget.updateListen.inProgress = false;

            if (mounted) setState(() => status = CommonsData.upToDate);
            return;
          }
        }
      }

      if (mounted) setState(() => status = CommonsData.progressToken);

      final String result = await currencyData.getRemoteData();
      debugPrint('Data retrieve result: $result');

      if (result == CommonsData.successToken) {
        final Box<dynamic> dateBox =
            await Hive.openBox<dynamic>(CommonsData.updatedDateBox);
        await dateBox.put(CommonsData.updatedDateKey, updatedDate);
        await dateBox.put(CommonsData.lastDateChecked, now.toString());

        if (mounted) setState(() => triesLeft = defaultTries);
      }

      if (mounted) setState(() => status = result);
      widget.updateListen.inProgress = false;

      retryMethod(result);
    } catch (e) {
      debugPrint('Error Updating: $e');
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
    final String lastCheckedStr =
        (Hive.box<dynamic>(CommonsData.updatedDateBox)
                .get(CommonsData.lastDateChecked) as String?) ??
            DateTime.now().toString();
    final DateTime? dateTime = DateTime.tryParse(lastCheckedStr);
    final String lastUpdated =
        _helperFunctions.getDate(dateTime ?? DateTime.now());

    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          textDetail(
              title: 'Last Checked: ', value: lastUpdated, context: context),
          const SizedBox(height: 5),
          textDetail(title: 'Status: ', value: status, context: context),
          const SizedBox(height: 5),
          srcLink(context: context),
        ],
      ),
    );
  }

  Widget textDetail(
      {required String title,
      required String value,
      required BuildContext context}) {
    Color? defaultColor = Theme.of(context).textTheme.labelLarge!.color;

    if (value == CommonsData.errorToken) defaultColor = Colors.redAccent;
    if (value == CommonsData.successToken || value == CommonsData.upToDate) {
      defaultColor = Colors.green;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
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
              color: defaultColor,
            ),
            key: UniqueKey(),
          ),
        ),
      ],
    );
  }

  Widget srcLink({required BuildContext context}) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Source: ',
            style: statusStyle,
          ),
          InkWell(
            onTap: () => launchThisUrl(url: CommonsData.remoteSource),
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
