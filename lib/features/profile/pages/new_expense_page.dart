import 'package:flutter/material.dart';
import 'package:flutter_app/features/profile/cubit/expense_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:flutter_app/features/profile/cubit/expense_cubit.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_app/l10n/app_localizations.dart';

class NewExpensePage extends StatefulWidget {
  const NewExpensePage({super.key});

  @override
  State<NewExpensePage> createState() => _NewExpensePageState();
}

class _NewExpensePageState extends State<NewExpensePage> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _taxAmountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  
  int? _selectedProductId;
  int? _selectedCurrencyId;
  int? _selectedVendorId;
  String _selectedPaymentMode = 'own_account';
  DateTime _selectedDate = DateTime.now();
  List<int> _selectedTaxIds = [];
  File? _selectedFile;

  @override
  void initState() {
    super.initState();
    context.read<ExpenseCubit>().fetchInitialData().then((_) {
      if (mounted) {
        setState(() {
          if (context.read<ExpenseCubit>().currencies.isNotEmpty) {
            _selectedCurrencyId = context.read<ExpenseCubit>().currencies.first['id'];
          }
        });
      }
    });
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'pdf', 'png', 'jpeg'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
      debugPrint('File picked: ${result.files.single.name}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExpenseCubit>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.new_expense, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(l10n.general_information),
              const SizedBox(height: 15),
              
              _buildTextField(
                controller: _nameController,
                label: l10n.expense_title,
                hint: "e.g. Office Supplies",
                icon: Icons.description_outlined,
                validator: (val) => val == null || val.isEmpty ? l10n.required_field : null,
              ),
              
              const SizedBox(height: 15),
              
              _buildDropdown(
                label: l10n.category,
                value: _selectedProductId,
                items: cubit.products.map((p) => DropdownMenuItem(
                  value: p['id'] as int,
                  child: Text(p['name'].toString()),
                )).toList(),
                onChanged: (val) => setState(() => _selectedProductId = val),
                icon: Icons.category_outlined,
              ),

              const SizedBox(height: 25),
              _buildSectionTitle(l10n.amount_taxes),
              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildTextField(
                      controller: _amountController,
                      label: l10n.total_amount,
                      hint: "0.00",
                      keyboardType: TextInputType.number,
                      icon: Icons.payments_outlined,
                      validator: (val) => val == null || val.isEmpty ? l10n.required_field : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: _buildDropdown(
                      label: l10n.currency,
                      value: _selectedCurrencyId,
                      items: cubit.currencies.map((c) => DropdownMenuItem(
                        value: c['id'] as int,
                        child: Text(c['name'].toString()),
                      )).toList(),
                      onChanged: (val) => setState(() => _selectedCurrencyId = val),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              _buildTaxSelector(cubit),

              const SizedBox(height: 15),

              _buildTextField(
                controller: _taxAmountController,
                label: l10n.tax_amount,
                hint: "0.00",
                keyboardType: TextInputType.number,
                icon: Icons.receipt_long_outlined,
              ),

              const SizedBox(height: 25),
              _buildSectionTitle(l10n.payment_date),
              const SizedBox(height: 15),

              _buildDropdown(
                label: l10n.paid_by,
                value: _selectedPaymentMode,
                items: [
                  DropdownMenuItem(value: 'own_account', child: Text(l10n.paid_by_employee)),
                  DropdownMenuItem(value: 'company_account', child: Text(l10n.paid_by_company)),
                ],
                onChanged: (val) {
                  setState(() {
                    _selectedPaymentMode = val!;
                    if (_selectedPaymentMode == 'own_account') _selectedVendorId = null;
                  });
                },
                icon: Icons.payment_outlined,
              ),

              if (_selectedPaymentMode == 'company_account') ...[
                const SizedBox(height: 15),
                _buildDropdown(
                  label: l10n.vendor,
                  value: _selectedVendorId,
                  items: cubit.vendors.map((v) => DropdownMenuItem(
                    value: v['id'] as int,
                    child: Text(v['name'].toString()),
                  )).toList(),
                  onChanged: (val) => setState(() => _selectedVendorId = val),
                  icon: Icons.storefront_outlined,
                ),
              ],

              const SizedBox(height: 15),

              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => _selectedDate = picked);
                },
                child: _buildFakeField(
                  label: l10n.expense_date,
                  value: DateFormat('yyyy-MM-dd').format(_selectedDate),
                  icon: Icons.calendar_today_outlined,
                ),
              ),

              const SizedBox(height: 15),

              _buildTextField(
                controller: _notesController,
                label: l10n.internal_notes,
                hint: "Add notes...",
                maxLines: 3,
                icon: Icons.note_alt_outlined,
              ),

              const SizedBox(height: 25),
              _buildSectionTitle(l10n.supporting_documents),
              const SizedBox(height: 15),

              InkWell(
                onTap: _pickFile,
                child: _buildFakeField(
                  label: l10n.attach_receipt,
                  value: _selectedFile != null 
                      ? _selectedFile!.path.split(Platform.pathSeparator).last 
                      : l10n.no_file_selected,
                  icon: Icons.attach_file_outlined,
                ),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A4E69),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 0,
                  ),
                  onPressed: _submitForm,
                  child: Text(
                    l10n.create_expense,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaxSelector(ExpenseCubit cubit) {
    final l10n = AppLocalizations.of(context)!;
    return _buildDropdown<int>(
      label: l10n.included_taxes,
      value: _selectedTaxIds.isNotEmpty ? _selectedTaxIds.first : null,
      items: cubit.taxes.map((t) => DropdownMenuItem(
        value: t['id'] as int,
        child: Text(t['name'].toString()),
      )).toList(),
      onChanged: (val) {
        setState(() {
          if (val != null) {
            _selectedTaxIds = [val];
          } else {
            _selectedTaxIds = [];
          }
        });
      },
      icon: Icons.receipt_long_outlined,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade600,
        letterSpacing: 1.1,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null ? Icon(icon, size: 20) : null,
            filled: true,
            fillColor: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          isExpanded: true,
          value: value,
          items: items,
          onChanged: onChanged,
          decoration: InputDecoration(
            prefixIcon: icon != null ? Icon(icon, size: 20) : null,
            filled: true,
            fillColor: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildFakeField({required String label, required String value, IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: Colors.grey.shade600),
                const SizedBox(width: 12),
              ],
              Text(value, style: const TextStyle(fontSize: 15)),
              const Spacer(),
              const Icon(Icons.arrow_drop_down, color: Colors.grey),
            ],
          ),
        ),
      ],
    );
  }

  void _submitForm() {
    final l10n = AppLocalizations.of(context)!;
    debugPrint('Submitting Expense Form...');
    if (_formKey.currentState!.validate()) {
      if (_selectedProductId == null) {
        debugPrint('Validation Failed: Category not selected');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.please_select_category), backgroundColor: Colors.orange));
        return;
      }
      if (_selectedCurrencyId == null) {
        debugPrint('Validation Failed: Currency not selected');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.please_select_currency), backgroundColor: Colors.orange));
        return;
      }

      final data = {
        'name': _nameController.text,
        'product_id': _selectedProductId,
        'total_amount_currency': double.tryParse(_amountController.text) ?? 0.0,
        'currency_id': _selectedCurrencyId,
        'tax_ids': [[6, 0, _selectedTaxIds]],
        'tax_amount_currency': double.tryParse(_taxAmountController.text) ?? 0.0,
        'payment_mode': _selectedPaymentMode,
        'vendor_id': _selectedVendorId,
        'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
        'description': _notesController.text,
      };

      debugPrint('Form Data Validated: $data');

      final expenseCubit = context.read<ExpenseCubit>();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.creating_expense), duration: const Duration(seconds: 1)),
      );

      expenseCubit.addExpense(data, file: _selectedFile).then((success) {
        if (success) {
          debugPrint('Expense added successfully.');
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.expense_created_success), backgroundColor: Colors.green),
          );
        } else {
          final errorState = expenseCubit.state;
          String errorMsg = "Failed to create expense";
          if (errorState is ExpenseError) {
            errorMsg = errorState.message;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMsg), backgroundColor: Colors.redAccent),
          );
        }
      });
    } else {
      debugPrint('Form Validation Failed');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.fill_required_fields),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
}
