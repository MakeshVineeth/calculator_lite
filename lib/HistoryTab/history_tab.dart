import 'dart:io';
import 'package:calculator_lite/HistoryTab/history_card.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'commons_history.dart';
import 'package:calculator_lite/UIElements/show_slide_up.dart';
import 'package:calculator_lite/CurrencyTab/Backend/commons.dart';

class HistoryTab extends StatefulWidget {
  const HistoryTab({Key key}) : super(key: key);

  @override
  _HistoryTabState createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          alignment: Alignment.centerRight,
          child: IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            onPressed: () => menuShow(),
          ),
        ),
        FutureBuilder(
          future: getHistoryBox(),
          builder: (context, AsyncSnapshot<Box> data) {
            if (data.connectionState == ConnectionState.done &&
                data.data != null) {
              return listWidget(data.data);
            } else {
              return const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
          },
        ),
      ],
    );
  }

  Future<Box> getHistoryBox() async {
    try {
      return await Hive.openBox(CommonsHistory.historyBox);
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, Function>> getMenuList() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String status = preferences.getString(CommonsHistory.historyStatusPref) ??
        CommonsHistory.historyEnabled;

    String menuItemHistStatus = status.contains(CommonsHistory.historyEnabled)
        ? 'Disable History'
        : 'Enable History';

    final Map<String, Function> menuList = {
      'Clear All': () => Future.delayed(
          CommonsData.dur1, () => Hive.box(CommonsHistory.historyBox).clear()),
      'Export': () {
        if (!Platform.isAndroid) return;
        Navigator.pushNamed(context, '/export');
      },
      menuItemHistStatus: () {
        if (status.contains(CommonsHistory.historyEnabled)) {
          preferences.setString(
              CommonsHistory.historyStatusPref, CommonsHistory.historyDisabled);
        } else {
          preferences.setString(
              CommonsHistory.historyStatusPref, CommonsHistory.historyEnabled);
        }
      },
    };

    return menuList;
  }

  void menuShow() async => showSlideUp(
        context: context,
        menuList: await getMenuList(),
      );

  Widget listWidget(Box box) => ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box listener, child) {
          if (listener.isNotEmpty) {
            return Expanded(
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics()),
                itemCount: listener.length,
                itemExtent: 200,
                cacheExtent: 2000,
                itemBuilder: (context, index) => HistoryCard(index: index),
              ),
            );
          } else {
            return Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.grey
                        : Colors.amber.withOpacity(0.9),
                    size: 30,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Your history will appear here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.grey
                          : Colors.amber.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      );
}
