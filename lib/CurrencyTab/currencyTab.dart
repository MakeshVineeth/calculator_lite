import 'dart:io';
import 'dart:math';
import 'package:calculator_lite/CurrencyTab/Backend/commons.dart';
import 'package:calculator_lite/CurrencyTab/Backend/copyData.dart';
import 'package:calculator_lite/CurrencyTab/Backend/currencyListItem.dart';
import 'package:calculator_lite/CurrencyTab/CardUI.dart';
import 'package:calculator_lite/CurrencyTab/resetFormProvider.dart';
import 'package:calculator_lite/CurrencyTab/smallToolBtn.dart';
import 'package:calculator_lite/CurrencyTab/updateColumn.dart';
import 'package:calculator_lite/UIElements/fade_in_widget.dart';
import 'package:calculator_lite/UIElements/showSlideUp.dart';
import 'package:calculator_lite/payments/provider_purchase_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hive/hive.dart';
import 'package:calculator_lite/fixedValues.dart';
import 'package:calculator_lite/CurrencyTab/Backend/updateListen.dart';
import 'package:provider/provider.dart';

class CurrencyTab extends StatefulWidget {
  @override
  _CurrencyTabState createState() => _CurrencyTabState();
}

class _CurrencyTabState extends State<CurrencyTab> {
  final _scrollController = ScrollController();
  Box fromBox;
  Box toBox;
  final resetFormProvider = ResetFormProvider();
  final UpdateListen updateListen = UpdateListen();
  PurchaseStatusProvider _purchaseStatusProvider;

  Future<void> process() async {
    await CopyData().copyData;
    fromBox = Hive.box(CommonsData.fromBox);
    toBox = Hive.box(CommonsData.toBox);

    for (CurrencyListItem item in fromBox.values)
      await Hive.openBox(item.currencyCode.toLowerCase());
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    Hive.close();
  }

  @override
  Widget build(BuildContext context) {
    _purchaseStatusProvider = Provider.of<PurchaseStatusProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: FutureBuilder(
        future: process(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done)
            return FadeThis(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    shape: FixedValues.roundShapeLarge,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: UpdateColumn(
                              updateListen: updateListen,
                            ),
                          ),
                          Expanded(
                            child: SmallToolBtn(
                              function: () => resetForm(context),
                              icon: Icons.clear_all_outlined,
                            ),
                          ),
                          Expanded(
                            child: SmallToolBtn(
                              function: () => popCurBtns(),
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
                    icon: Icon(Icons.add_circle_rounded),
                  ),
                  SizedBox(height: 10),
                  Expanded(child: widgetsData())
                ],
              ),
            );
          else
            return FadeThis(child: Center(child: CircularProgressIndicator()));
        },
      ),
    );
  }

  void popCurBtns() {
    Map<String, Function> menuList = {
      'Update Now': () => updateListen.update(),
      'Delete All': () {
        fromBox.clear();
        toBox.clear();
        for (int i = 0; i <= fromBox.length - 1; i++) {
          _animListKey.currentState.removeItem(
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
                  ));
        }
      },
    };

    showSlideUp(context: context, menuList: menuList);
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
      Random random = Random();

      int t1 = random.nextInt(list.length);
      int t2 = random.nextInt(list.length);

      CurrencyListItem fromCur = list.getAt(t1);
      CurrencyListItem toCur = list.getAt(t2);
      await Hive.openBox(fromCur.currencyCode.toLowerCase());

      await fromBox.add(fromCur);
      await toBox.add(toCur);

      int index = fromBox.length;
      _animListKey.currentState
          .insertItem(index - 1, duration: CommonsData.dur1);

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

  final myTween =
      Tween<Offset>(begin: const Offset(0.3, 0), end: const Offset(0, 0));

  Widget widgetsData() => Form(
        key: _formKey,
        child: AnimatedList(
          key: _animListKey,
          controller: _scrollController,
          initialItemCount: fromBox.length,
          physics:
              AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
          itemBuilder: (context, index, animation) => SlideTransition(
            position: CurvedAnimation(parent: animation, curve: Curves.easeIn)
                .drive(myTween),
            child: FadeTransition(
              opacity: animation,
              child: CardUI(
                index: index,
                resetFormProvider: resetFormProvider,
              ),
            ),
          ),
        ),
      );
}
