import 'package:calculator_lite/Backend/focusEvent.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TextFieldCalc extends StatefulWidget {
  const TextFieldCalc({@required this.calculationString});

  final List<String> calculationString;
  @override
  _TextFieldCalcState createState() => _TextFieldCalcState();
}

class _TextFieldCalcState extends State<TextFieldCalc> {
  final myController = TextEditingController();
  final myFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    myFocus.addListener(onFocusChange);
  }

  void onFocusChange() {
    print('hasFocus: ${myFocus.hasFocus}');
  }

  @override
  void dispose() {
    myController.dispose();
    myFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    myController.value = TextEditingValue(
        text: this.widget.calculationString.join(),
        selection: TextSelection.fromPosition(
          TextPosition(offset: this.widget.calculationString.join().length),
        ));
    return TextField(
      style: completeStringStyle(),
      controller: myController,
      decoration: null,
      readOnly: true,
      showCursor: true,
      focusNode: myFocus,
      onChanged: (text) {},
      onTap: () => onTapFunction(context),
    );
  }

  void onTapFunction(BuildContext context) {
    TextSelection i = myController.selection;
    String myText = myController.text;
    int count = Provider.of<FocusEvent>(context, listen: false)
            .getPosition(start: i.start, givenText: myText) ??
        i.end;

    TextSelection textSelection =
        TextSelection(baseOffset: count, extentOffset: count);
    myController.selection = textSelection;
  }

  TextStyle completeStringStyle() => TextStyle(
        fontSize: 40,
        letterSpacing: 1.5,
      );
}
