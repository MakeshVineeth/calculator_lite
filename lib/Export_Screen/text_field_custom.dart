import 'package:flutter/material.dart';
import 'validate_functions.dart';
import 'custom_themes.dart';

class TextFieldCustom extends StatefulWidget {
  final String title;
  final TextEditingController controller;
  final Function validate;
  final TextInputType textInputType;
  final bool ignoreValidation;

  const TextFieldCustom({
    @required this.title,
    @required this.controller,
    this.validate,
    this.textInputType = TextInputType.text,
    this.ignoreValidation = false,
  });

  @override
  _TextFieldCustomState createState() => _TextFieldCustomState();
}

class _TextFieldCustomState extends State<TextFieldCustom> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          validator: (text) {
            if (widget.ignoreValidation) return null;

            return widget.validate == null
                ? emptyValidator(widget.controller)
                : widget.validate(widget.controller);
          },
          controller: widget.controller,
          textCapitalization: TextCapitalization.characters,
          keyboardType: widget.textInputType,
          decoration: InputDecoration(
            fillColor: Theme.of(context).brightness == Brightness.light
                ? Colors.grey[100]
                : Colors.black26,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: CustomThemes.roundEdge,
              gapPadding: 0.0,
              borderSide: BorderSide.none,
            ),
            labelText: widget.title,
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
