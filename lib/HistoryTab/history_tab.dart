import 'dart:io';

import 'package:animated_search_bar/animated_search_bar.dart';
import 'package:calculator_lite/Backend/hive_initializer.dart';
import 'package:calculator_lite/CurrencyTab/Backend/commons.dart';
import 'package:calculator_lite/HistoryTab/commons_history.dart';
import 'package:calculator_lite/HistoryTab/history_card.dart';
import 'package:calculator_lite/HistoryTab/history_item.dart';
import 'package:calculator_lite/UIElements/show_slide_up.dart';
import 'package:calculator_lite/fixed_values.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  String searchString = '';
  final double widthSearchBorder = 1.5;
  late final Future<Box<HistoryItem>?> _historyBoxFuture;
  Box<HistoryItem>? _cachedBox;
  ValueListenable<Box<HistoryItem>>? _boxListenable;

  @override
  void initState() {
    super.initState();
    _historyBoxFuture = getHistoryBox();
  }

  ValueListenable<Box<HistoryItem>> _listenableFor(Box<HistoryItem> box) {
    if (!identical(_cachedBox, box) || _boxListenable == null) {
      _cachedBox = box;
      _boxListenable = box.listenable();
    }
    return _boxListenable!;
  }

  @override
  Widget build(BuildContext context) {
    final bool isLightTheme = Theme.of(context).brightness == Brightness.light;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 0, 0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: AnimatedSearchBar(
                      cursorColor: Theme.of(context).textTheme.labelLarge?.color,
                      searchStyle: TextStyle(
                        color: Theme.of(context).textTheme.labelLarge?.color,
                      ),
                      searchDecoration: InputDecoration(
                        labelText: 'Search',
                        alignLabelWithHint: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 8,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: FixedValues.large,
                          borderSide: BorderSide(
                            color: Theme.of(context).primaryColor,
                            width: widthSearchBorder,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: FixedValues.large,
                          borderSide: BorderSide(
                            color: isLightTheme
                                ? Colors.grey[600]!
                                : Colors.grey[350]!,
                            width: widthSearchBorder,
                          ),
                        ),
                      ),
                      onChanged: (value) => setState(
                        () => searchString = value.trim().toLowerCase(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert_rounded),
                    onPressed: () => menuShow(),
                  ),
                ],
              ),
            ),
            FutureBuilder<Box<HistoryItem>?>(
              future: _historyBoxFuture,
              builder: (context, AsyncSnapshot<Box<HistoryItem>?> data) {
                if (data.connectionState == ConnectionState.done &&
                    data.data != null) {
                  return listWidget(data.data!);
                }
                return const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<Box<HistoryItem>?> getHistoryBox() async {
    try {
      await HiveInitializer.ensureInitialized();
      if (Hive.isBoxOpen(CommonsHistory.historyBox)) {
        return Hive.box<HistoryItem>(CommonsHistory.historyBox);
      }
      return await Hive.openBox<HistoryItem>(CommonsHistory.historyBox);
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, Function>> getMenuList() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String status =
        preferences.getString(CommonsHistory.historyStatusPref) ??
            CommonsHistory.historyEnabled;

    final String menuItemHistStatus =
        status.contains(CommonsHistory.historyEnabled)
            ? 'Disable History'
            : 'Enable History';

    final Map<String, Function> menuList = {
      'Clear All': () => Future.delayed(CommonsData.dur1, () {
        if (Hive.isBoxOpen(CommonsHistory.historyBox)) {
          Hive.box<HistoryItem>(CommonsHistory.historyBox).clear();
        }
      }),
      'Export': () {
        if (!Platform.isAndroid) return;
        Navigator.pushNamed(context, '/export');
      },
      menuItemHistStatus: () {
        if (status.contains(CommonsHistory.historyEnabled)) {
          preferences.setString(
            CommonsHistory.historyStatusPref,
            CommonsHistory.historyDisabled,
          );
        } else {
          preferences.setString(
            CommonsHistory.historyStatusPref,
            CommonsHistory.historyEnabled,
          );
        }
      },
    };

    return menuList;
  }

  void menuShow() async {
    final list = await getMenuList();
    if (!mounted) return;
    showSlideUp(context: context, menuList: list);
  }

  Widget listWidget(Box<HistoryItem> box) =>
      ValueListenableBuilder<Box<HistoryItem>>(
        valueListenable: _listenableFor(box),
        builder: (context, Box<HistoryItem> listener, child) {
          if (listener.isEmpty) {
            return _emptyState(context);
          }

          if (searchString.isEmpty) {
            return Expanded(
              child: ListView.builder(
                itemExtent: 200,
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                itemCount: listener.length,
                itemBuilder: (context, index) {
                  final indexVal = (listener.length - 1) - index;
                  final HistoryItem? historyItem = listener.getAt(indexVal);
                  if (historyItem == null) return const SizedBox.shrink();
                  return HistoryCard(
                    index: indexVal,
                    historyItem: historyItem,
                  );
                },
              ),
            );
          }

          final List<int> matchingIndices = [];
          for (int i = listener.length - 1; i >= 0; i--) {
            final item = listener.getAt(i);
            if (item != null &&
                item.title.trim().toLowerCase().contains(searchString)) {
              matchingIndices.add(i);
            }
          }

          return Expanded(
            child: ListView.builder(
              itemExtent: 200,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              itemCount: matchingIndices.length,
              itemBuilder: (context, index) {
                final indexVal = matchingIndices[index];
                final HistoryItem? historyItem = listener.getAt(indexVal);
                if (historyItem == null) return const SizedBox.shrink();
                return HistoryCard(
                  index: indexVal,
                  historyItem: historyItem,
                );
              },
            ),
          );
        },
      );

  Widget _emptyState(BuildContext context) {
    final color = Theme.of(context).brightness == Brightness.light
        ? Colors.grey
        : Colors.amber.withValues(alpha: 0.9);
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, color: color, size: 30),
          const SizedBox(height: 10),
          Text(
            'Your history will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
