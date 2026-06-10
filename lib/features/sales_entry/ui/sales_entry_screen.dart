import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/error/exceptions.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_suggestion_field.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../domain/entities/sales_entry.dart';
import '../controller/sales_entry_controller.dart';

class SalesEntryScreen extends ConsumerStatefulWidget {
  final SalesEntry? existingEntry;

  const SalesEntryScreen({super.key, this.existingEntry});

  @override
  ConsumerState<SalesEntryScreen> createState() => _SalesEntryScreenState();
}

class _SalesEntryScreenState extends ConsumerState<SalesEntryScreen> {
  static final TextInputFormatter _amountFormatter =
      TextInputFormatter.withFunction((oldValue, newValue) {
        final next = newValue.text;
        final isValid = RegExp(r'^\d{0,9}(\.\d{0,2})?$').hasMatch(next);
        return next.isEmpty || isValid ? newValue : oldValue;
      });
  static final TextInputFormatter _shopCountFormatter =
      TextInputFormatter.withFunction((oldValue, newValue) {
        final next = newValue.text;
        final isValid = RegExp(r'^\d{0,5}$').hasMatch(next);
        return next.isEmpty || isValid ? newValue : oldValue;
      });

  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _salesmanController = TextEditingController();
  final _areaController = TextEditingController();
  final _valueController = TextEditingController();
  final _shopCountController = TextEditingController();
  final _cashController = TextEditingController();
  final _checkController = TextEditingController();

  final _salesmanFocus = FocusNode();
  final _areaFocus = FocusNode();
  final _valueFocus = FocusNode();
  final _shopCountFocus = FocusNode();
  final _cashFocus = FocusNode();
  final _checkFocus = FocusNode();

  DateTime _currentDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    final entry = widget.existingEntry;
    if (entry != null) {
      _currentDate = entry.date;
      _salesmanController.text = entry.salesmanName;
      _areaController.text = entry.area;
      _valueController.text = entry.value.toStringAsFixed(2);
      _shopCountController.text = entry.shopCount.toString();
      _cashController.text = entry.cashCollection.toStringAsFixed(2);
      _checkController.text = entry.checkCollection.toStringAsFixed(2);
    }

    _updateDateDisplay();
    if (entry == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _salesmanFocus.requestFocus();
        }
      });
    }
  }

  void _updateDateDisplay() {
    _dateController.text = DateFormat('yyyy-MM-dd').format(_currentDate);
  }

  Future<void> _pickDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _currentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (selectedDate != null && mounted) {
      setState(() {
        _currentDate = selectedDate;
        _updateDateDisplay();
      });
    }
  }

  String? _validateRequiredText(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required';
    }
    return null;
  }

  String? _validateAmount(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required';
    }

    final parsed = double.tryParse(value);
    if (parsed == null) {
      return 'Enter a valid number';
    }
    if (parsed < 0) {
      return 'Must be 0 or more';
    }
    if (parsed > SalesEntry.maxAmount) {
      return 'Value is too large';
    }
    return null;
  }

  String? _validateShopCount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Shop count is required';
    }

    final parsed = int.tryParse(value);
    if (parsed == null) {
      return 'Enter a whole number';
    }
    if (parsed < 0) {
      return 'Must be 0 or more';
    }
    if (parsed > SalesEntry.maxShopCount) {
      return 'Shop count is too large';
    }
    return null;
  }

  void _showFeedback(String message, {required bool isError}) {
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? colorScheme.errorContainer
            : colorScheme.primaryContainer,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _resetFormAfterSave() {
    _salesmanController.clear();
    _areaController.clear();
    _valueController.clear();
    _shopCountController.clear();
    _cashController.clear();
    _checkController.clear();
    setState(() {
      _currentDate = DateTime.now();
      _updateDateDisplay();
    });
    _salesmanFocus.requestFocus();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    FocusScope.of(context).unfocus();

    final controller = ref.read(salesEntryControllerProvider.notifier);
    final entryDate = _currentDate;
    final salesmanName = _salesmanController.text.trim();
    final area = _areaController.text.trim();
    final value = double.parse(_valueController.text);
    final shopCount = int.parse(_shopCountController.text);
    final cashCollection = double.parse(_cashController.text);
    final checkCollection = double.parse(_checkController.text);

    if (widget.existingEntry != null) {
      await controller.updateEntry(
        widget.existingEntry!.copyWith(
          date: entryDate,
          salesmanName: salesmanName,
          area: area,
          value: value,
          shopCount: shopCount,
          cashCollection: cashCollection,
          checkCollection: checkCollection,
        ),
      );
      return;
    }

    await controller.createEntry(
      date: entryDate,
      salesmanName: salesmanName,
      area: area,
      value: value,
      shopCount: shopCount,
      cashCollection: cashCollection,
      checkCollection: checkCollection,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingEntry != null;
    final state = ref.watch(salesEntryControllerProvider);

    ref.listen<AsyncValue<void>>(salesEntryControllerProvider, (previous, next) {
      if (!mounted) {
        return;
      }

      if (next is AsyncData<void> && previous is AsyncLoading<void>) {
        _showFeedback(
          isEditing ? 'Entry updated successfully.' : 'Entry saved successfully.',
          isError: false,
        );
        if (isEditing) {
          Navigator.of(context).pop();
        } else {
          _resetFormAfterSave();
        }
      } else if (next is AsyncError<void>) {
        _showFeedback(next.error.toUserMessage(), isError: true);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Sales Entry' : 'New Sales Entry'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              CustomTextField(
                label: 'Date',
                controller: _dateController,
                readOnly: true,
                onTap: _pickDate,
              ),
              CustomSuggestionField(
                label: 'Salesman Name',
                controller: _salesmanController,
                focusNode: _salesmanFocus,
                autofocus: !isEditing,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_areaFocus),
                getSuggestions: (value) => ref
                    .read(salesEntryControllerProvider.notifier)
                    .fetchSuggestions('salesman', value),
                validator: (value) => _validateRequiredText(
                  value,
                  'Salesman name',
                ),
              ),
              CustomSuggestionField(
                label: 'Area',
                controller: _areaController,
                focusNode: _areaFocus,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_valueFocus),
                getSuggestions: (value) => ref
                    .read(salesEntryControllerProvider.notifier)
                    .fetchSuggestions('area', value),
                validator: (value) => _validateRequiredText(value, 'Area'),
              ),
              CustomTextField(
                label: 'Value',
                controller: _valueController,
                focusNode: _valueFocus,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [_amountFormatter],
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_shopCountFocus),
                validator: (value) => _validateAmount(value, 'Value'),
              ),
              CustomTextField(
                label: 'Shop Count',
                controller: _shopCountController,
                focusNode: _shopCountFocus,
                keyboardType: TextInputType.number,
                inputFormatters: [_shopCountFormatter],
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_cashFocus),
                validator: _validateShopCount,
              ),
              CustomTextField(
                label: 'Cash Collection',
                controller: _cashController,
                focusNode: _cashFocus,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [_amountFormatter],
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_checkFocus),
                validator: (value) => _validateAmount(value, 'Cash collection'),
              ),
              CustomTextField(
                label: 'Check Collection',
                controller: _checkController,
                focusNode: _checkFocus,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [_amountFormatter],
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                validator: (value) => _validateAmount(
                  value,
                  'Check collection',
                ),
              ),
              const SizedBox(height: 16),
              CustomButton(
                label: isEditing ? 'Update Entry' : 'Save Entry',
                isLoading: state.isLoading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _dateController.dispose();
    _salesmanController.dispose();
    _areaController.dispose();
    _valueController.dispose();
    _shopCountController.dispose();
    _cashController.dispose();
    _checkController.dispose();
    _salesmanFocus.dispose();
    _areaFocus.dispose();
    _valueFocus.dispose();
    _shopCountFocus.dispose();
    _cashFocus.dispose();
    _checkFocus.dispose();
    super.dispose();
  }
}
