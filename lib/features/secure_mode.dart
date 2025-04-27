import 'dart:io' show Platform;
import 'package:calculator_lite/UIElements/fade_scale_widget.dart';
import 'package:calculator_lite/common_methods/common_methods.dart';
import 'package:calculator_lite/features/custom_radio.dart';
import 'package:calculator_lite/fixed_values.dart';
import 'package:flutter/material.dart';

class PrivacyDialog extends StatefulWidget {
  const PrivacyDialog({super.key});

  @override
  State<PrivacyDialog> createState() => _PrivacyDialogState();
}

class _PrivacyDialogState extends State<PrivacyDialog> {
  bool _disabled = true;

  @override
  void initState() {
    super.initState();
    initialTask();
  }

  void initialTask() async {
    bool status = await getPrefs('privacy', true);
    if (mounted) setState(() => _disabled = status);
  }

  @override
  Widget build(BuildContext context) {
    return FadeScale(
      child: AlertDialog(
        title: const Text(
          'Secure Mode',
          style: FixedValues.semiBoldStyle,
        ),
        shape: FixedValues.roundShapeLarge,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioTileCustom(
              value: false,
              groupValue: _disabled,
              title: 'Enable',
              function: _doTask,
            ),
            RadioTileCustom(
              value: true,
              groupValue: _disabled,
              title: 'Disable',
              function: _doTask,
            ),
          ],
        ),
      ),
    );
  }

  void _doTask() async {
    try {
      if (Platform.isAndroid) {
        if (mounted) setState(() => _disabled = !_disabled);
        await setPrefs('privacy', _disabled);
        await setSecure(_disabled);
      }
    } catch (_) {}
  }
}
