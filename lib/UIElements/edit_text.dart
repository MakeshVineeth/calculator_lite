import 'package:auto_size_text_field/auto_size_text_field.dart';
import 'package:calculator_lite/Backend/custom_focus_events.dart';
import 'package:calculator_lite/Backend/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncExpression(Provider.of<CustomFocusEvents>(context));
  }

  @override
  void didUpdateWidget(covariant TextFieldCalc oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncExpression(Provider.of<CustomFocusEvents>(context, listen: false));
  }

  @override
  void dispose() {
    myController.dispose();
    focus.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void _syncExpression(CustomFocusEvents customFocusEvents) {
    if (!mounted) return;
    final String text = widget.calculationString.join();

    if (customFocusEvents.isFocused) {
      final int safeOffset = customFocusEvents.position.clamp(0, text.length);
      final targetValue = TextEditingValue(
        text: text,
        selection: TextSelection.fromPosition(
          TextPosition(offset: safeOffset),
        ),
      );
      if (myController.value != targetValue) {
        myController.value = targetValue;
      }
      _previousText = text;
      return;
    }

    if (focus.hasFocus) {
      focus.unfocus();
    }
    final targetValue = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    if (myController.value != targetValue) {
      myController.value = targetValue;
    }

    if (_previousText != text) {
      _previousText = text;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
          );
        }
      });
    }
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
    final Size screenSize = MediaQuery.sizeOf(context);
    final bool isCompact = screenSize.width < 360 || screenSize.height < 450;
    final bool isLand = const HelperFunctions().isLandScape(context);

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
              style: completeStringStyle(isLand || isCompact),
              controller: myController,
              scrollController: scrollController,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Calculate.',
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: isCompact ? 0 : 2,
                ),
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
                parent: BouncingScrollPhysics(),
              ),
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
                        horizontal: 8,
                        vertical: 3,
                      ),
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

  void onTapFunction(BuildContext context) {
    if (mounted) {
      final TextSelection i = myController.selection;
      final customFocus = Provider.of<CustomFocusEvents>(context, listen: false);
      final int? count = customFocus.getPosition(
        start: i.start,
        calculationString: widget.calculationString,
      );
      if (count == null) return;

      final TextSelection textSelection =
          TextSelection(baseOffset: count, extentOffset: count);
      myController.selection = textSelection;
      customFocus.updateFocus();
    }
  }

  TextStyle completeStringStyle(bool isCompact) => TextStyle(
    fontSize: isCompact ? 26 : 60,
    letterSpacing: 1,
  );
}
