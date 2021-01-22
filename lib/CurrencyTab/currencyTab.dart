import 'dart:math';
import 'package:calculator_lite/CurrencyTab/Backend/commons.dart';
import 'package:calculator_lite/CurrencyTab/Backend/copyData.dart';
import 'package:calculator_lite/CurrencyTab/Backend/currencyListItem.dart';
import 'package:calculator_lite/CurrencyTab/CardUI.dart';
import 'package:calculator_lite/CurrencyTab/resetFormProvider.dart';
import 'package:calculator_lite/CurrencyTab/updateColumn.dart';
import 'package:calculator_lite/UIElements/fade_in_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hive/hive.dart';
import 'package:calculator_lite/fixedValues.dart';

class CurrencyTab extends StatefulWidget {
  @override
  _CurrencyTabState createState() => _CurrencyTabState();
}

class _CurrencyTabState extends State<CurrencyTab> {
  final _scrollController = new ScrollController();
  Box fromBox;
  Box toBox;
  final resetFormProvider = ResetFormProvider();

  Future<void> process() async {
    await copyData();
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
                    child: InkWell(
                      borderRadius: FixedValues.large,
                      onTap: () {},
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Expanded(child: UpdateColumn()),
                            MaterialButton(
                              shape: FixedValues.roundShapeBtns,
                              onPressed: () => resetForm(context),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(Icons.clear_all_outlined),
                              ),
                            ),
                          ],
                        ),
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

  void addCurrencyCard() async {
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
              BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
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
