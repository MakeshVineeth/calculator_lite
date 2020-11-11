import 'package:calculator_lite/Backend/focusEvent.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:auto_size_text_field/auto_size_text_field.dart';

class TextFieldCalc extends StatefulWidget {
  const TextFieldCalc({@required this.calculationString});

  final List<String> calculationString;
  @override
  _TextFieldCalcState createState() => _TextFieldCalcState();
}

class _TextFieldCalcState extends State<TextFieldCalc> {
  final myController = TextEditingController();
  final focus = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    myController.dispose();
    focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    onStart(context);
    return AutoSizeTextField(
      style: completeStringStyle(),
      controller: myController,
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: 'Calculate.',
      ),
      readOnly: true,
      stepGranularity: 2,
      minLines: 1,
      maxLines: 2,
      focusNode: focus,
      showCursor: true,
      onChanged: (text) {},
      onTap: () => onTapFunction(context),
    );
  }

  void onStart(BuildContext context) {
    if (this.mounted) {
      FocusEvent focusEvent = Provider.of(context);

      if (focusEvent.isFocused)
        myController.value = TextEditingValue(
            text: this.widget.calculationString.join(),
            selection: TextSelection.fromPosition(
              TextPosition(offset: focusEvent.position),
            ));
      else {
        FocusScope.of(context).unfocus();
        myController.clear();
        myController.value = TextEditingValue(
          text: this.widget.calculationString.join(),
        );
      }
    }
  }

  void onTapFunction(BuildContext context) {
    if (this.mounted) {
      TextSelection i = myController.selection;
      int count = Provider.of<FocusEvent>(context, listen: false).getPosition(
              start: i.start,
              calculationString: this.widget.calculationString) ??
          i.end;

      TextSelection textSelection =
          TextSelection(baseOffset: count, extentOffset: count);
      myController.selection = textSelection;
      Provider.of<FocusEvent>(context, listen: false).updateFocus();
    }
  }

  TextStyle completeStringStyle() => TextStyle(
        fontSize: 60,
        letterSpacing: 1,
      );
}
