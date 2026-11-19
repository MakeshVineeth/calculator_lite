import 'package:calculator_lite/Backend/custom_focus_events.dart';
import 'package:calculator_lite/Backend/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:auto_size_text_field/auto_size_text_field.dart';

class TextFieldCalc extends StatefulWidget {
  const TextFieldCalc({required this.calculationString, super.key});

  final List<String> calculationString;
  @override
  State<TextFieldCalc> createState() => _TextFieldCalcState();
}

class _TextFieldCalcState extends State<TextFieldCalc> {
  final myController = TextEditingController();
  final focus = FocusNode();
  final ScrollController scrollController = ScrollController();
  bool _showJumpToEnd = false;
  String _previousText = '';

  @override
  void dispose() {
    myController.dispose();
    focus.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void _onScrollNotification(ScrollNotification notification) {
    if (!scrollController.hasClients) return;
    final maxScroll = scrollController.position.maxScrollExtent;
    final currentOffset = scrollController.offset;
    final bool shouldShow = (maxScroll - currentOffset) > 40 && maxScroll > 15;
    if (shouldShow != _showJumpToEnd) {
      setState(() => _showJumpToEnd = shouldShow);
    }
  }

  @override
  Widget build(BuildContext context) {
    onStart(context);
    final Size screenSize = MediaQuery.sizeOf(context);
    final bool isCompact = screenSize.width < 360 || screenSize.height < 450;
    final bool isLand = HelperFunctions().isLandScape(context);

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        _onScrollNotification(notification);
        return false;
      },
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          RawScrollbar(
            controller: scrollController,
            thumbVisibility: true,
            interactive: true,
            thickness: 4.0,
            radius: const Radius.circular(4),
            thumbColor: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            child: AutoSizeTextField(
              textAlign: TextAlign.right,
              style: completeStringStyle(),
              controller: myController,
              scrollController: scrollController,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Calculate.',
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              ),
              readOnly: true,
              stepGranularity: 2,
              minLines: 1,
              maxLines: (isLand || isCompact) ? 2 : 4,
              minFontSize: isCompact ? 12 : 22,
              maxFontSize: (isLand || isCompact) ? 28 : 50,
              focusNode: focus,
              showCursor: true,
              onTap: () => onTapFunction(context),
              scrollPhysics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics()),
            ),
          ),
          if (_showJumpToEnd)
            Positioned(
              bottom: 2,
              right: 6,
              child: AnimatedOpacity(
                opacity: _showJumpToEnd ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 150),
                child: Material(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                  elevation: 2,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      if (scrollController.hasClients) {
                        scrollController.animateTo(
                          scrollController.position.maxScrollExtent,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOut,
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.arrow_downward_rounded,
                            size: 13,
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            'End',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void onStart(BuildContext context) {
    if (mounted) {
      final CustomFocusEvents customFocusEvents = Provider.of(context);
      final String text = widget.calculationString.join();

      if (customFocusEvents.isFocused) {
        myController.value = TextEditingValue(
            text: text,
            selection: TextSelection.fromPosition(
              TextPosition(offset: customFocusEvents.position),
            ));
      } else {
        focus.unfocus();
        myController.clear();
        myController.value = TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );

        if (_previousText != text) {
          _previousText = text;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (scrollController.hasClients) {
              scrollController.animateTo(
                scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOut,
              );
            }
          });
        }
      }
    }
  }

  void onTapFunction(BuildContext context) {
    if (mounted) {
      final TextSelection i = myController.selection;
      final int? count = Provider.of<CustomFocusEvents>(context, listen: false)
              .getPosition(
                  start: i.start,
                  calculationString: widget.calculationString);

      final TextSelection textSelection =
          TextSelection(baseOffset: count!, extentOffset: count);
      myController.selection = textSelection;
      Provider.of<CustomFocusEvents>(context, listen: false).updateFocus();
    }
  }

  TextStyle completeStringStyle() => const TextStyle(
        fontSize: 60,
        letterSpacing: 1,
      );
}
