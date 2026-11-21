import 'package:calculator_lite/CurrencyTab/Backend/commons.dart';
import 'package:calculator_lite/CurrencyTab/Backend/currency_list_item.dart';
import 'package:calculator_lite/CurrencyTab/flag_icon.dart';
import 'package:flutter/material.dart';
import 'package:calculator_lite/UIElements/show_blur_dialog.dart';
import 'package:calculator_lite/UIElements/fade_scale_widget.dart';
import 'package:calculator_lite/fixed_values.dart';
import 'package:hive_ce/hive.dart';

class CurrencyChooser extends StatefulWidget {
  final int boxIndex;
  final String method;

  const CurrencyChooser({required this.boxIndex, required this.method, super.key});

  @override
  State<CurrencyChooser> createState() => _CurrencyChooserState();

  static Future<void> show({
    required BuildContext context,
    required int index,
    required String method,
  }) async => await showBlurDialog(
    child: CurrencyChooser(boxIndex: index, method: method),
    context: context,
  );
}

class _CurrencyChooserState extends State<CurrencyChooser> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    FocusManager.instance.primaryFocus?.unfocus();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Box<CurrencyListItem> listBoxes =
        Hive.box<CurrencyListItem>(CommonsData.currencyListBox);
    final List<CurrencyListItem> currencyListItems = List.castFrom(
      listBoxes.values.toList(),
    );

    // Defensive deduplication by (currencyCode + currencyName)
    final Set<String> seenKeys = {};
    final List<CurrencyListItem> deduplicatedItems = [];
    for (final item in currencyListItems) {
      final key = '${item.currencyCode}_${item.currencyName}'.toLowerCase();
      if (seenKeys.add(key)) {
        deduplicatedItems.add(item);
      }
    }

    final List<CurrencyListItem> filteredItems = _searchQuery.trim().isEmpty
        ? deduplicatedItems
        : deduplicatedItems.where((item) {
            // OWASP M4: Sanitize search query input
            final query = _searchQuery.toLowerCase().trim();
            final code = item.currencyCode.toLowerCase();
            final name = item.currencyName.toLowerCase();
            return code.contains(query) || name.contains(query);
          }).toList();

    final isLight = Theme.of(context).brightness == Brightness.light;

    return FadeScale(
      child: AlertDialog(
        backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
        elevation: isLight ? 12.0 : 8.0,
        shadowColor: isLight ? const Color(0x33000000) : const Color(0x66000000),
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
          height: MediaQuery.of(context).size.height / 1.5,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: TextField(
                  controller: _searchController,
                  maxLength: 50,
                  buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                  onChanged: (value) => setState(() => _searchQuery = value),
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
                              setState(() => _searchQuery = '');
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
                child: filteredItems.isEmpty
                    ? Center(
                        child: Text(
                          'No currency found',
                          style: TextStyle(
                            color: isLight ? Colors.grey[600] : Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredItems.length,
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        itemBuilder: (context, index) {
                          final CurrencyListItem currencyListItem =
                              filteredItems[index];

                          return ListTile(
                            shape: FixedValues.roundShapeLarge,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            onTap: () async {
                              FocusManager.instance.primaryFocus?.unfocus();
                              await onTap(context, currencyListItem);
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
