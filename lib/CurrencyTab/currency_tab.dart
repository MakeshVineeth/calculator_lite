import 'dart:io';
import 'package:calculator_lite/CurrencyTab/Backend/commons.dart';
import 'package:calculator_lite/CurrencyTab/Backend/copy_data.dart';
import 'package:calculator_lite/CurrencyTab/Backend/currency_list_item.dart';
import 'package:calculator_lite/CurrencyTab/card_ui.dart';
import 'package:calculator_lite/CurrencyTab/reset_form_provider.dart';
import 'package:calculator_lite/CurrencyTab/small_tool_btn.dart';
import 'package:calculator_lite/CurrencyTab/update_details_column.dart';
import 'package:calculator_lite/UIElements/fade_in_widget.dart';
import 'package:calculator_lite/UIElements/show_slide_up.dart';
import 'package:calculator_lite/payments/provider_purchase_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hive_ce/hive.dart';
import 'package:calculator_lite/fixed_values.dart';
import 'package:calculator_lite/CurrencyTab/Backend/update_listener.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class CurrencyTab extends StatefulWidget {
  const CurrencyTab({super.key});

  @override
  State<CurrencyTab> createState() => _CurrencyTabState();
}

class _CurrencyTabState extends State<CurrencyTab> {
  final _scrollController = ScrollController();
  late Box fromBox;
  late Box toBox;
  final resetFormProvider = ResetFormProvider();
  final UpdateListen updateListen = UpdateListen();
  late PurchaseStatusProvider _purchaseStatusProvider;

  Future<void> process() async {
    await CopyData().copyData;
    fromBox = Hive.box(CommonsData.fromBox);
    toBox = Hive.box(CommonsData.toBox);

    for (CurrencyListItem item in fromBox.values) {
      await Hive.openBox(item.currencyCode.toLowerCase());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    Hive.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _purchaseStatusProvider = context.watch<PurchaseStatusProvider>();

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: FutureBuilder(
        future: process(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return FadeThis(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Card(
                    shape: FixedValues.roundShapeLarge,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 4,
                            child: UpdateColumn(updateListen: updateListen),
                          ),
                          Flexible(
                            child: SmallToolBtn(
                              function: () => resetForm(context),
                              icon: Icons.clear_all_outlined,
                            ),
                          ),
                          Flexible(
                            child: SmallToolBtn(
                              function: () {
                                popCurBtns().then((value) {
                                  showSlideUp(
                                    context: context,
                                    menuList: value,
                                  );
                                });
                              },
                              icon: Icons.expand_more_outlined,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => addCurrencyCard(),
                    iconSize: 30,
                    icon: const Icon(Icons.add_circle_rounded),
                  ),
                  const SizedBox(height: 10),
                  Expanded(child: widgetsData()),
                ],
              ),
            );
          } else {
            return const FadeThis(
              child: Center(child: CircularProgressIndicator()),
            );
          }
        },
      ),
    );
  }

  Future<Map<String, Function>> popCurBtns() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final status =
        preferences.getString(CommonsData.autoUpdatePref) ??
        CommonsData.autoUpdateEnabled;
    final updateStatusStr =
        status.contains(CommonsData.autoUpdateEnabled)
            ? 'Disable Auto Update'
            : 'Enable Auto Update';

    final Map<String, Function> menuList = {
      'Update Now': () => updateListen.update(),
      'Delete All': () {
        fromBox.clear();
        toBox.clear();
        for (int i = 0; i <= fromBox.length - 1; i++) {
          _animListKey.currentState?.removeItem(
            0,
            (BuildContext context, Animation<double> animation) =>
                SizeTransition(
                  sizeFactor: animation,
                  child: FadeTransition(
                    opacity: animation,
                    child: CardUI(
                      index: 0,
                      remove: true,
                      resetFormProvider: resetFormProvider,
                    ),
                  ),
                ),
          );
        }
      },
      updateStatusStr: () {
        // User Preference for auto update.
        if (status.contains(CommonsData.autoUpdateEnabled)) {
          preferences.setString(
            CommonsData.autoUpdatePref,
            CommonsData.autoUpdateDisabled,
          );
        } else {
          preferences.setString(
            CommonsData.autoUpdatePref,
            CommonsData.autoUpdateEnabled,
          );
        }
      },
    };

    return menuList;
  }

  void addCurrencyCard() async {
    // Check for payment status. And allow not more than 7 currency cards.
    bool paymentStatus = _purchaseStatusProvider.hasPurchased;

    if ((paymentStatus == false && fromBox.length >= 5) && Platform.isAndroid) {
      Navigator.pushNamed(context, FixedValues.buyRoute);
      return;
    }

    final list = Hive.box(CommonsData.currencyListBox);
    if (list.length > 0) {
      final NumberFormat currencyFormat = NumberFormat.currency(
        locale: Localizations.localeOf(context).toString(),
      );
      String currencyCode = currencyFormat.currencyName ?? 'USD';

      List<CurrencyListItem> currencyList =
          list.values.cast<CurrencyListItem>().toList();

      CurrencyListItem fromCur = list.getAt(0);
      CurrencyListItem toCur = list.getAt(0);

      for (CurrencyListItem element in currencyList) {
        if (element.currencyCode == currencyCode) {
          fromCur = element;
          break;
        }
      }

      await Hive.openBox(fromCur.currencyCode.toLowerCase());

      await fromBox.add(fromCur);
      await toBox.add(toCur);

      int index = fromBox.length;
      _animListKey.currentState?.insertItem(
        index - 1,
        duration: CommonsData.dur1,
      );

      SchedulerBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: CommonsData.dur1,
          curve: Curves.easeOut,
        );
      });
    }
  }

  final _formKey = GlobalKey<FormState>();
  final _animListKey = GlobalKey<AnimatedListState>();

  void resetForm(BuildContext buildContext) => resetFormProvider.reset(true);

  final myTween = Tween<Offset>(
    begin: const Offset(0.3, 0),
    end: const Offset(0, 0),
  );

  Widget widgetsData() => Form(
    key: _formKey,
    child: AnimatedList(
      key: _animListKey,
      controller: _scrollController,
      initialItemCount: fromBox.length,
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
      itemBuilder:
          (context, index, animation) => SlideTransition(
            position: CurvedAnimation(
              parent: animation,
              curve: Curves.easeIn,
            ).drive(myTween),
            child: FadeTransition(
              opacity: animation,
              child: CardUI(index: index, resetFormProvider: resetFormProvider),
            ),
          ),
    ),
  );
}
