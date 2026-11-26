import 'dart:io' show File;
import 'package:calculator_lite/Backend/hive_initializer.dart';
import 'package:calculator_lite/HistoryTab/commons_history.dart';
import 'package:calculator_lite/HistoryTab/history_item.dart';
import 'package:calculator_lite/fixed_values.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:hive_ce/hive.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'export_commons.dart';
import 'export_helpers.dart';
import 'export_method.dart';
import 'validate_functions.dart';

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    final buffer = StringBuffer();

    for (int i = 0; i < text.length && i < 8; i++) {
      if (i == 2 || i == 4) {
        buffer.write('-');
      }
      buffer.write(text[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  final _formKey = GlobalKey<FormState>();

  String _status = '';
  bool _visibility = false;
  bool _isError = false;
  bool _isLoading = false;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _dateFrom = TextEditingController();
  final TextEditingController _dateTo = TextEditingController();
  static const platform = MethodChannel('kotlin.flutter.dev');
  late Future<bool> isNewerOS;

  @override
  void initState() {
    super.initState();
    isNewerOS = isAboveOreo();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _dateFrom.dispose();
    _dateTo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final primaryColor = theme.primaryColor;

    final int historyCount = Hive.isBoxOpen(CommonsHistory.historyBox)
        ? Hive.box<HistoryItem>(CommonsHistory.historyBox).length
        : 0;
    final bool hasData = historyCount > 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Export History'),
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: FutureBuilder<bool>(
          future: isNewerOS,
          builder: (context, snapshot) {
            final bool canSave = snapshot.data ?? false;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 540),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18.0,
                      vertical: 16.0,
                    ),
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    children: [
                      _buildHeader(primaryColor, isLight),
                      const SizedBox(height: 20),
                      _buildSummaryCard(historyCount, primaryColor, isLight),
                      const SizedBox(height: 16),
                      _buildDateRangeCard(
                        theme: theme,
                        primaryColor: primaryColor,
                        isLight: isLight,
                        enabled: hasData,
                      ),
                      const SizedBox(height: 20),
                      _buildActionButtons(
                        canSave: canSave,
                        hasData: hasData,
                        theme: theme,
                        isLight: isLight,
                      ),
                      if (_visibility) ...[
                        const SizedBox(height: 16),
                        _buildStatusBanner(isLight),
                      ],
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(Color primaryColor, bool isLight) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.table_chart_rounded,
            size: 40,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Export Calculations',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Download or share your calculation history as a Microsoft Excel (.xlsx) spreadsheet.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: isLight ? Colors.grey[700] : Colors.grey[400],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(int count, Color primaryColor, bool isLight) {
    final bool hasData = count > 0;

    return Card(
      shape: FixedValues.roundShapeLarge,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Row(
          children: [
            Icon(
              hasData ? Icons.history_rounded : Icons.info_outline_rounded,
              color: hasData ? primaryColor : Colors.grey,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasData ? 'Available History' : 'No Calculations Saved',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasData
                        ? '$count calculation${count == 1 ? '' : 's'} ready to export'
                        : 'Calculate expressions to export records here',
                    style: TextStyle(
                      fontSize: 12,
                      color: isLight ? Colors.grey[600] : Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 5.0,
              ),
              decoration: BoxDecoration(
                color: isLight ? Colors.grey[100] : Colors.grey[850],
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: isLight
                      ? const Color(0x1F000000)
                      : const Color(0x22FFFFFF),
                  width: 0.8,
                ),
              ),
              child: Text(
                hasData ? 'Excel (.xlsx)' : 'Empty',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: hasData ? null : Colors.grey,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeCard({
    required ThemeData theme,
    required Color primaryColor,
    required bool isLight,
    required bool enabled,
  }) {
    return Card(
      shape: FixedValues.roundShapeLarge,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.date_range_rounded,
                  size: 20,
                  color: enabled ? primaryColor : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  'Date Range',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: enabled ? null : Colors.grey,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 3.0,
                  ),
                  decoration: BoxDecoration(
                    color: isLight ? Colors.grey[100] : Colors.grey[850],
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: Text(
                    'Optional',
                    style: TextStyle(
                      fontSize: 11,
                      color: isLight ? Colors.grey[600] : Colors.grey[400],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _buildDateField(
              controller: _dateFrom,
              label: 'From Date',
              hint: 'DD-MM-YYYY',
              theme: theme,
              isLight: isLight,
              enabled: enabled,
            ),
            const SizedBox(height: 12),
            _buildDateField(
              controller: _dateTo,
              label: 'To Date',
              hint: 'DD-MM-YYYY',
              theme: theme,
              isLight: isLight,
              enabled: enabled,
            ),
            if (enabled) ...[
              const SizedBox(height: 12),
              _buildQuickChips(theme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required ThemeData theme,
    required bool isLight,
    required bool enabled,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.number,
      inputFormatters: [DateInputFormatter()],
      validator: (text) {
        if (!enabled) return null;
        if (text == null || text.trim().isEmpty) return null;
        if (text.trim().length < 10) return 'Enter complete date (DD-MM-YYYY)';
        return checkDateFormat(controller);
      },
      onChanged: (_) => clearStatusTips(),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: enabled
            ? (isLight ? Colors.grey[50] : Colors.grey[900])
            : (isLight ? Colors.grey[100] : Colors.grey[900]),
        prefixIcon: Icon(
          Icons.calendar_today_outlined,
          size: 20,
          color: enabled ? theme.primaryColor : Colors.grey,
        ),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (controller.text.isNotEmpty && enabled)
              IconButton(
                icon: const Icon(Icons.clear_rounded, size: 18),
                onPressed: () {
                  setState(() {
                    controller.clear();
                    clearStatusTips();
                  });
                },
              ),
            IconButton(
              icon: Icon(
                Icons.date_range_rounded,
                size: 20,
                color: enabled ? null : Colors.grey,
              ),
              onPressed: enabled
                  ? () => _pickDate(controller: controller, title: label)
                  : null,
            ),
          ],
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.0),
          borderSide: BorderSide(
            color: isLight ? const Color(0x1F000000) : const Color(0x22FFFFFF),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.0),
          borderSide: BorderSide(
            color: isLight ? const Color(0x1F000000) : const Color(0x22FFFFFF),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.0),
          borderSide: BorderSide(color: theme.primaryColor, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildQuickChips(ThemeData theme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildChip(
            label: 'All History',
            onTap: () {
              setState(() {
                _dateFrom.clear();
                _dateTo.clear();
                clearStatusTips();
              });
            },
            isSelected: _dateFrom.text.isEmpty && _dateTo.text.isEmpty,
            theme: theme,
          ),
          const SizedBox(width: 8),
          _buildChip(
            label: 'This Month',
            onTap: () {
              final now = DateTime.now();
              final firstDay = DateTime(now.year, now.month, 1);
              setState(() {
                _dateFrom.text =
                    DateFormat(CommonStrings.dateFormat).format(firstDay);
                _dateTo.text = DateFormat(CommonStrings.dateFormat).format(now);
                clearStatusTips();
              });
            },
            theme: theme,
          ),
          const SizedBox(width: 8),
          _buildChip(
            label: 'Last 7 Days',
            onTap: () {
              final now = DateTime.now();
              final past = now.subtract(const Duration(days: 7));
              setState(() {
                _dateFrom.text =
                    DateFormat(CommonStrings.dateFormat).format(past);
                _dateTo.text = DateFormat(CommonStrings.dateFormat).format(now);
                clearStatusTips();
              });
            },
            theme: theme,
          ),
          const SizedBox(width: 8),
          _buildChip(
            label: 'Last 30 Days',
            onTap: () {
              final now = DateTime.now();
              final past = now.subtract(const Duration(days: 30));
              setState(() {
                _dateFrom.text =
                    DateFormat(CommonStrings.dateFormat).format(past);
                _dateTo.text = DateFormat(CommonStrings.dateFormat).format(now);
                clearStatusTips();
              });
            },
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required VoidCallback onTap,
    required ThemeData theme,
    bool isSelected = false,
  }) {
    final primary = theme.primaryColor;
    return ActionChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected ? primary : null,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? primary : Colors.grey.withValues(alpha: 0.3),
        ),
      ),
      backgroundColor: isSelected ? primary.withValues(alpha: 0.1) : null,
      onPressed: onTap,
    );
  }

  Widget _buildActionButtons({
    required bool canSave,
    required bool hasData,
    required ThemeData theme,
    required bool isLight,
  }) {
    final primary = theme.primaryColor;
    final bool canExport = hasData && !_isLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            backgroundColor: isLight ? primary : const Color(0xFF222222),
            foregroundColor: isLight ? Colors.white : primary,
            disabledBackgroundColor:
                isLight ? Colors.grey[300] : Colors.grey[850],
            disabledForegroundColor: Colors.grey,
            shape: FixedValues.roundShapeBtns,
            elevation: isLight ? 2.0 : 4.0,
            side: isLight
                ? BorderSide.none
                : BorderSide(
                    color: canExport
                        ? primary.withValues(alpha: 0.8)
                        : Colors.transparent,
                    width: 1.5,
                  ),
          ),
          onPressed: canExport ? () => exportEvent(save: false) : null,
          icon: const Icon(Icons.share_rounded, size: 20),
          label: const Text(
            'Share Spreadsheet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (canSave) ...[
          const SizedBox(height: 12),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              backgroundColor: isLight ? Colors.white : Colors.grey[900],
              foregroundColor: isLight
                  ? primary
                  : Colors.white.withValues(alpha: 0.87),
              disabledBackgroundColor:
                  isLight ? Colors.grey[200] : Colors.grey[900],
              disabledForegroundColor: Colors.grey,
              shape: FixedValues.roundShapeBtns,
              elevation: isLight ? 1.0 : 2.0,
              side: BorderSide(
                color: isLight
                    ? (canExport
                        ? primary.withValues(alpha: 0.3)
                        : Colors.grey.withValues(alpha: 0.2))
                    : const Color(0x33FFFFFF),
                width: 1.0,
              ),
            ),
            onPressed: canExport ? () => exportEvent(save: true) : null,
            icon: const Icon(Icons.download_rounded, size: 20),
            label: const Text(
              'Save to Device',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        if (hasData &&
            (_dateFrom.text.isNotEmpty || _dateTo.text.isNotEmpty)) ...[
          const SizedBox(height: 8),
          Center(
            child: TextButton.icon(
              onPressed: clearStatus,
              icon: const Icon(Icons.restart_alt_rounded, size: 18),
              label: const Text('Reset Date Filters'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatusBanner(bool isLight) {
    if (_isLoading) {
      return Card(
        shape: FixedValues.roundShapeBtns,
        child: const Padding(
          padding: EdgeInsets.all(14.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
              SizedBox(width: 12),
              Text(
                'Generating spreadsheet...',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      );
    }

    final Color bgColor = _isError
        ? (isLight ? const Color(0xFFFDE8E8) : const Color(0xFF3B1E1E))
        : (isLight ? const Color(0xFFE8F5E9) : const Color(0xFF1E3A24));

    final Color textColor = _isError ? Colors.redAccent : Colors.green;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: FixedValues.large,
        border: Border.all(
          color: textColor.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isError
                ? Icons.error_outline_rounded
                : Icons.check_circle_outline_rounded,
            color: textColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _status,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate({
    required TextEditingController controller,
    required String title,
  }) async {
    FocusScope.of(context).unfocus();
    DateTime initial = DateTime.now();
    if (controller.text.isNotEmpty) {
      try {
        initial =
            DateFormat(CommonStrings.dateFormat).parse(controller.text.trim());
      } catch (_) {}
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1980),
      lastDate: DateTime.now(),
      helpText: 'Select $title',
    );

    if (!mounted) return;
    if (picked != null) {
      setState(() {
        controller.text = DateFormat(CommonStrings.dateFormat).format(picked);
        clearStatusTips();
      });
    }
  }

  String generateFileName() {
    final DateTime now = DateTime.now();
    final String date = DateFormat(CommonStrings.dateFormat).format(now);
    final String time = DateFormat('H_m_ss').format(now);
    return 'History_${date}_$time';
  }

  Future<void> kotlinFile(String path) async {
    try {
      final String? result = await platform.invokeMethod<String>('createFile', {
        'path': path,
        'fileName': generateFileName(),
      });

      if (result == 'success') {
        setStatus(text: 'Exported successfully!');
      } else {
        setStatus(isError: true, text: 'Unable to export file');
      }
    } on PlatformException catch (_) {
      setStatus(isError: true, text: 'Permission or export error');
    }
  }

  void setStatus({
    String text = '',
    bool isError = false,
    bool isLoading = false,
  }) {
    if (!mounted) return;
    setState(() {
      _status = text;
      _visibility = true;
      _isError = isError;
      _isLoading = isLoading;
    });

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void clearStatus() {
    _formKey.currentState?.reset();
    _dateFrom.clear();
    _dateTo.clear();
    clearStatusTips();
  }

  void clearStatusTips() {
    if (!mounted) return;
    setState(() {
      _status = '';
      _visibility = false;
      _isError = false;
      _isLoading = false;
    });
  }

  void exportEvent({bool save = false}) async {
    try {
      clearStatusTips();
      final bool isValid = _formKey.currentState?.validate() ?? false;
      if (!isValid) return;

      // Validate date order if both dates are present
      if (_dateFrom.text.isNotEmpty && _dateTo.text.isNotEmpty) {
        try {
          final from = getDateTime(_dateFrom.text);
          final to = getDateTime(_dateTo.text);
          if (from.isAfter(to)) {
            setStatus(
              text: '"From" date cannot be after "To" date.',
              isError: true,
            );
            return;
          }
        } catch (_) {}
      }

      setStatus(isLoading: true);

      await HiveInitializer.ensureInitialized();
      if (!Hive.isBoxOpen(CommonsHistory.historyBox)) {
        await Hive.openBox<HistoryItem>(CommonsHistory.historyBox);
      }
      final Box<HistoryItem> history =
          Hive.box<HistoryItem>(CommonsHistory.historyBox);
      final List<HistoryItem> data = history.values.toList();

      if (data.isEmpty) {
        setStatus(text: 'No history items to export!', isError: true);
        return;
      }

      final List<Map<String, String>> allData = [];

      final bool hasFrom = _dateFrom.text.trim().isNotEmpty &&
          checkDateFormat(_dateFrom) == null;
      final bool hasTo = _dateTo.text.trim().isNotEmpty &&
          checkDateFormat(_dateTo) == null;

      final DateTime? fromDate = hasFrom ? getDateTime(_dateFrom.text) : null;
      final DateTime? toDate = hasTo ? getDateTime(_dateTo.text) : null;
      final DateFormat itemDateFormat = DateFormat(CommonStrings.dateFormat);
      final DateFormat displayDateFormat = DateFormat.yMMMMd('en_US').add_jm();

      for (final element in data) {
        final String formattedDate = itemDateFormat.format(element.dateTime);
        final DateTime itemDate = getDateTime(formattedDate);

        bool include = true;
        if (fromDate != null && itemDate.isBefore(fromDate)) {
          include = false;
        }
        if (toDate != null && itemDate.isAfter(toDate)) {
          include = false;
        }

        if (include) {
          allData.add({
            CommonStrings.historyTitle: element.title,
            CommonStrings.dateTitle: displayDateFormat.format(element.dateTime),
            CommonStrings.expTextTitle: element.expression,
            CommonStrings.valTextTile: element.value,
          });
        }
      }

      if (allData.isEmpty) {
        setStatus(
          text: 'No calculations found in this date range.',
          isError: true,
        );
        return;
      }

      final String? status = await ExportExcel(
        fileName: generateFileName(),
      ).writeExcel(data: allData);

      if (status == null) {
        setStatus(text: 'Unable to generate spreadsheet.', isError: true);
        return;
      }

      final File file = File(status);
      if (!await file.exists()) {
        setStatus(text: 'Unable to create file.', isError: true);
        return;
      }

      try {
        if (save) {
          await kotlinFile(file.path);
        } else {
          final List<XFile> files = [XFile(file.path)];
          final ShareResult shareResult = await SharePlus.instance.share(
            ShareParams(files: files, text: 'Calculator History Export'),
          );

          if (shareResult.status != ShareResultStatus.success) {
            setStatus(text: 'Share cancelled or unavailable.', isError: true);
            return;
          }
          clearStatus();
        }
      } finally {
        if (await file.exists()) {
          await file.delete();
        }
      }
    } catch (e) {
      debugPrint('Export error: $e');
      setStatus(text: 'Unable to proceed with export.', isError: true);
    }
  }
}
