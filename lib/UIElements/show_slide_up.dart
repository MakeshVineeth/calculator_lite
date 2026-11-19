import 'package:flutter/material.dart';
import 'package:calculator_lite/fixed_values.dart';

/// Displays a modern, native bottom slide-up sheet with actions.
void showSlideUp({
  required BuildContext context,
  required Map<String, Function> menuList,
}) {
  final isLight = Theme.of(context).brightness == Brightness.light;
  showModalBottomSheet<void>(
    context: context,
    backgroundColor:
        isLight ? Theme.of(context).scaffoldBackgroundColor : Colors.grey[900],
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
    ),
    builder: (BuildContext sheetContext) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[500],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                separatorBuilder: (context, index) =>
                    const Divider(thickness: 1, height: 1),
                itemCount: menuList.length,
                itemBuilder: (context, index) {
                  final entry = menuList.entries.elementAt(index);
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        shape: FixedValues.roundShapeLarge,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        Navigator.of(sheetContext).pop();
                        entry.value();
                      },
                      child: Center(
                        child: Text(
                          entry.key,
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      );
    },
  );
}
