import 'package:calculator_lite/Export_Screen/validate_functions.dart';
import 'package:calculator_lite/HistoryTab/commons_history.dart';
import 'package:calculator_lite/HistoryTab/history_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'export_commons.dart';
import 'export_helpers.dart';
import 'export_method.dart';
import 'button_custom.dart';
import 'date_field_custom.dart';
import 'status_tooltip.dart';
import 'dart:io' show File;
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({Key key}) : super(key: key);

  @override
  _ExportScreenState createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  final _formKey = GlobalKey<FormState>();

  String _status = '';
  bool _visibility = false;
  bool _isError = false;
  bool _isLoading = false;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _dateFrom = TextEditingController();
  final TextEditingController _dateTo = TextEditingController();
  static const platform = MethodChannel('kotlin.flutter.dev');
  Future<bool> isNewerOS;

  @override
  void initState() {
    super.initState();
    isNewerOS = isAboveOreo();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _dateFrom.dispose();
    _dateTo.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export'),
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: FutureBuilder(
            future: isNewerOS,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Card(
                  elevation: 5.0,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics()),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Export History',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 30),
                            DateFieldCustom(
                              dateController: _dateFrom,
                              dateText: 'Date From',
                              ignoreValidation: true,
                            ),
                            const SizedBox(height: 12),
                            DateFieldCustom(
                              dateController: _dateTo,
                              dateText: 'Date To',
                              ignoreValidation: true,
                            ),
                            Card(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              elevation: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Theme.of(context).cardTheme.elevation
                                  : 2,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                physics: const AlwaysScrollableScrollPhysics(
                                    parent: BouncingScrollPhysics()),
                                child: Row(
                                  children: [
                                    ButtonCustom(
                                      text: 'Share',
                                      function: () => exportEvent(),
                                    ),
                                    if (snapshot.data) // Checks if OS SDK26+
                                      ButtonCustom(
                                        text: 'Save',
                                        function: () => exportEvent(save: true),
                                      ),
                                    ButtonCustom(
                                      text: 'Clear',
                                      function: () => clearStatus(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            StatusToolTip(
                              visibility: _visibility,
                              status: _status,
                              isError: _isError,
                              isLoading: _isLoading,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              } else {
                return const CircularProgressIndicator();
              }
            },
          ),
        ),
      ),
    );
  }

  String generateFileName() {
    DateTime now = DateTime.now();
    String date = DateFormat(CommonStrings.dateFormat).format(now);
    String time = DateFormat('H_m_ss').format(now);
    return 'History_${date}_$time';
  }

  void kotlinFile(String path) async {
    try {
      String result = await platform.invokeMethod('createFile', {
        'path': path,
        'fileName': generateFileName(),
      });

      if (result == 'success') {
        setStatus(text: 'Exported!');
      } else {
        setStatus(isError: true, text: 'Unable to export');
      }
    } on PlatformException catch (_) {}
  }

  void setStatus(
      {String text = '', bool isError = false, bool isLoading = false}) {
    setState(() {
      _status = text;
      _visibility = true;
      _isError = isError;
      _isLoading = isLoading;
    });

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void clearStatus() {
    _formKey.currentState.reset();
    _dateFrom.clear();
    _dateTo.clear();
    clearStatusTips();
  }

  void clearStatusTips() {
    setState(() {
      _status = '';
      _visibility = false;
      _isError = false;
      _isLoading = false;
    });
  }

  void exportEvent({bool save = false}) async {
    try {
      clearStatusTips();
      bool isValid = _formKey.currentState.validate();
      setStatus(isLoading: true);
      final Box history = Hive.box(CommonsHistory.historyBox);
      final List<HistoryItem> data = [...history.values.toList()];

      if (isValid && data.isNotEmpty) {
        List<Map<String, String>> allData = [];

        for (var element in data) {
          String formattedDate =
              DateFormat(CommonStrings.dateFormat).format(element.dateTime);
          DateTime val = getDateTime(formattedDate);

          bool case1 = checkDateFormat(_dateFrom) == null &&
              checkDateFormat(_dateTo) == null;
          bool case2 = checkDateFormat(_dateFrom) == null;
          bool case3 = checkDateFormat(_dateTo) == null;
          bool case4 = checkDateFormat(_dateTo) != null;

          if (case1) {
            DateTime from = getDateTime(_dateFrom.text);
            DateTime to = getDateTime(_dateTo.text);

            if (to.compareTo(val) == 0 ||
                from.compareTo(val) == 0 ||
                from.isBefore(val) && to.isAfter(val)) {
              final Map<String, String> eachHistoryItem = {
                CommonStrings.historyTitle: element.title,
                CommonStrings.dateTitle: DateFormat.yMMMMd('en_US')
                    .add_jm()
                    .format(element.dateTime),
                CommonStrings.expTextTitle: element.expression,
                CommonStrings.valTextTile: element.value,
              };

              allData.add(eachHistoryItem);
            }
          } else if (case2) {
            DateTime from = getDateTime(_dateFrom.text);

            if (from.compareTo(val) == 0 || from.isBefore(val)) {
              final Map<String, String> eachHistoryItem = {
                CommonStrings.historyTitle: element.title,
                CommonStrings.dateTitle: DateFormat.yMMMMd('en_US')
                    .add_jm()
                    .format(element.dateTime),
                CommonStrings.expTextTitle: element.expression,
                CommonStrings.valTextTile: element.value,
              };

              allData.add(eachHistoryItem);
            }
          } else if (case3) {
            DateTime to = getDateTime(_dateTo.text);

            if (to.compareTo(val) == 0 || to.isAfter(val)) {
              final Map<String, String> eachHistoryItem = {
                CommonStrings.historyTitle: element.title,
                CommonStrings.dateTitle: DateFormat.yMMMMd('en_US')
                    .add_jm()
                    .format(element.dateTime),
                CommonStrings.expTextTitle: element.expression,
                CommonStrings.valTextTile: element.value,
              };

              allData.add(eachHistoryItem);
            }
          } else if (case4) {
            final Map<String, String> eachHistoryItem = {
              CommonStrings.historyTitle: element.title,
              CommonStrings.dateTitle:
                  DateFormat.yMMMMd('en_US').add_jm().format(element.dateTime),
              CommonStrings.expTextTitle: element.expression,
              CommonStrings.valTextTile: element.value,
            };

            allData.add(eachHistoryItem);
          }
        }

        if (allData.isNotEmpty) {
          String status = await ExportExcel(fileName: generateFileName())
              .writeExcel(data: allData);

          // If not null, then Share as the file exists.
          if (status != null) {
            File file = File(status);

            if (save) {
              kotlinFile(file.path);
            } else {
              await Share.shareFiles([status], text: 'Logging Excel File');
              if (file.existsSync()) {
                file.deleteSync();
                clearStatus();
              }
            }
          }

          // If null, display error.
          else {
            setStatus(text: 'Unable to proceed!', isError: true);
          }
        }

        // If data is not available within criteria.
        else {
          setStatus(text: 'No items available!', isError: true);
        }
      }

      // For validation and data (empty) errors.
      else {
        setStatus(text: 'Unable to Proceed!', isError: true);
      }
    } catch (_) {
      setStatus(text: 'Unable to Proceed!', isError: true);
    }
  }
}
