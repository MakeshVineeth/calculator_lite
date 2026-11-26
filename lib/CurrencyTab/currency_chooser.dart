import 'dart:math' as math;

import 'package:calculator_lite/CurrencyTab/Backend/commons.dart';
import 'package:calculator_lite/CurrencyTab/Backend/currency_list_item.dart';
import 'package:calculator_lite/CurrencyTab/flag_icon.dart';
import 'package:calculator_lite/UIElements/fade_scale_widget.dart';
import 'package:calculator_lite/UIElements/show_blur_dialog.dart';
import 'package:calculator_lite/fixed_values.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';

class CurrencyChooser extends StatefulWidget {
  final int boxIndex;
  final String method;
  final Future<void> Function(CurrencyListItem item)? onCurrencySelected;

  const CurrencyChooser({
    required this.boxIndex,
    required this.method,
    this.onCurrencySelected,
    super.key,
  });

  @override
  State<CurrencyChooser> createState() => _CurrencyChooserState();

  static Future<void> show({
    required BuildContext context,
    required int index,
    required String method,
    Future<void> Function(CurrencyListItem item)? onCurrencySelected,
  }) async =>
      await showBlurDialog(
        child: CurrencyChooser(
          boxIndex: index,
          method: method,
          onCurrencySelected: onCurrencySelected,
        ),
        context: context,
      );
}

class _CurrencyChooserState extends State<CurrencyChooser> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late final List<CurrencyListItem> _allItems;
  late List<CurrencyListItem> _filteredItems;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    final Box<CurrencyListItem> listBoxes =
        Hive.box<CurrencyListItem>(CommonsData.currencyListBox);
    _allItems = _deduplicateItems(listBoxes.values.toList());
    _filteredItems = _allItems;
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<CurrencyListItem> _deduplicateItems(List<CurrencyListItem> items) {
    final Set<String> seenKeys = {};
    final List<CurrencyListItem> deduplicatedItems = [];
    for (final item in items) {
      final key = '${item.currencyCode}_${item.currencyName}'.toLowerCase();
      if (seenKeys.add(key)) {
        deduplicatedItems.add(item);
      }
    }
    return deduplicatedItems;
  }

  void _applyFilter(String value) {
    // OWASP M4: Sanitize search query input
    final query = value.toLowerCase().trim();
    setState(() {
      _searchQuery = value;
      if (query.isEmpty) {
        _filteredItems = _allItems;
      } else {
        _filteredItems = _allItems.where((item) {
          final code = item.currencyCode.toLowerCase();
          final name = item.currencyName.toLowerCase();
          return code.contains(query) || name.contains(query);
        }).toList();
      }
    });
  }

  Size _dialogSize(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final topInset = mediaQuery.viewPadding.top;
    final bottomInset = math.max(
      mediaQuery.viewInsets.bottom,
      mediaQuery.viewPadding.bottom,
    );
    final availableHeight = mediaQuery.size.height - topInset - bottomInset;
    final maxContentHeight = (availableHeight - 168.0).clamp(80.0, 560.0);
    final preferredHeight = (mediaQuery.size.height / 1.5).clamp(80.0, 560.0);
    final height = math.min(preferredHeight, maxContentHeight);
    final width = (mediaQuery.size.width - 80.0).clamp(240.0, 480.0);
    return Size(width, height);
  }

  @override
  Widget build(BuildContext context) {
    final dialogSize = _dialogSize(context);
    final isLight = Theme.of(context).brightness == Brightness.light;

    return FadeScale(
      child: AlertDialog(
        backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
        elevation: isLight ? 12.0 : 8.0,
        shadowColor:
            isLight ? const Color(0x33000000) : const Color(0x66000000),
        shape: FixedValues.roundDialogShape(context),
        title: Text(
          'Select Currency',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: isLight ? Colors.black87 : Colors.white,
          ),
        ),
        content: SizedBox(
          height: dialogSize.height,
          width: dialogSize.width,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  textInputAction: TextInputAction.search,
                  maxLength: 50,
                  buildCounter: (
                    context, {
                    required currentLength,
                    required isFocused,
                    maxLength,
                  }) =>
                      null,
                  onChanged: _applyFilter,
                  style: TextStyle(
                    fontSize: 14,
                    color: isLight ? Colors.black87 : Colors.white,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search currency name or code...',
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: isLight ? Colors.grey[600] : Colors.grey[400],
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      size: 20,
                      color: isLight ? Colors.grey[700] : Colors.grey[300],
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              _applyFilter('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: isLight ? Colors.grey[100] : Colors.grey[850],
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _filteredItems.isEmpty
                    ? Center(
                        child: Text(
                          'No currency found',
                          style: TextStyle(
                            color:
                                isLight ? Colors.grey[600] : Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredItems.length,
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        itemBuilder: (context, index) {
                          final CurrencyListItem currencyListItem =
                              _filteredItems[index];

                          return ListTile(
                            shape: FixedValues.roundShapeLarge,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            onTap: () async {
                              _searchFocusNode.unfocus();
                              final callback = widget.onCurrencySelected;
                              if (callback != null) {
                                await callback(currencyListItem);
                              } else {
                                await onTap(context, currencyListItem);
                              }
                              if (!context.mounted) return;
                              Navigator.of(context, rootNavigator: true).pop();
                            },
                            leading: FlagIcon(flagURL: currencyListItem.flagURL),
                            title: Text(
                              '${currencyListItem.currencyName} (${currencyListItem.currencyCode})',
                              style: TextStyle(
                                fontSize: 14,
                                color: isLight ? Colors.black87 : Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> onTap(
    BuildContext context,
    CurrencyListItem currencyListItem,
  ) async {
    final Box<CurrencyListItem> box = Hive.box<CurrencyListItem>(widget.method);
    await box.putAt(widget.boxIndex, currencyListItem);
    final String codeLower = currencyListItem.currencyCode.toLowerCase();
    if (!Hive.isBoxOpen(codeLower)) {
      await Hive.openBox<dynamic>(codeLower);
    }
  }
}
