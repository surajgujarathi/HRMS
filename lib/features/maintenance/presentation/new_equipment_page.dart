import 'package:flutter/material.dart';
import 'package:flutter_app/core/constants/app_colors.dart';
import 'package:flutter_app/features/maintenance/cubit/maintenance_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:flutter_app/l10n/app_localizations.dart';

class NewEquipmentPage extends StatefulWidget {
  const NewEquipmentPage({super.key});

  @override
  State<NewEquipmentPage> createState() => _NewEquipmentPageState();
}

class _NewEquipmentPageState extends State<NewEquipmentPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _serialNoController = TextEditingController();
  final TextEditingController _compSerialNoController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _partnerRefController = TextEditingController();
  final TextEditingController _expectedMtbfController = TextEditingController();
  final TextEditingController _mtbfController = TextEditingController();
  final TextEditingController _mttrController = TextEditingController();

  // Selected Values
  int? _selectedCategoryId;
  int? _selectedCompanyId;
  String _usedBy = 'employee'; // employee, department, other
  int? _selectedDepartmentId;
  int? _selectedEmployeeId;
  int? _selectedTeamId;
  int? _selectedTechnicianId;
  int? _selectedPartnerId;

  DateTime? _scrapDate;
  DateTime? _effectiveDate;
  DateTime? _warrantyDate;
  DateTime? _estimatedNextFailure;
  DateTime? _latestFailureDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, String field) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryPurple,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        switch (field) {
          case 'scrap': _scrapDate = picked; break;
          case 'effective': _effectiveDate = picked; break;
          case 'warranty': _warrantyDate = picked; break;
          case 'est_failure': _estimatedNextFailure = picked; break;
          case 'latest_failure': _latestFailureDate = picked; break;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (context) => MaintenanceCubit()..fetchMasterData(),
      child: Scaffold(
        backgroundColor: AppColors.lavenderBg,
        appBar: AppBar(
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryPurple, AppColors.violet],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(l10n.new_equipment, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: l10n.general),
              Tab(text: l10n.description),
              Tab(text: l10n.product_info),
              Tab(text: l10n.maintenance),
            ],
          ),
        ),
        body: BlocListener<MaintenanceCubit, MaintenanceState>(
          listener: (context, state) {
            if (state.status == MaintenanceStatus.submitted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.equipment_created_success), backgroundColor: AppColors.successGreen),
              );
              Navigator.pop(context);
            } else if (state.status == MaintenanceStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.error_message(state.errorMessage ?? '')), backgroundColor: AppColors.dangerRed),
              );
            }
          },
          child: Form(
            key: _formKey,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildGeneralTab(),
                _buildDescriptionTab(),
                _buildProductInfoTab(),
                _buildMaintenanceTab(),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomAction(context),
      ),
    );
  }

  Widget _buildGeneralTab() {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<MaintenanceCubit, MaintenanceState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildTextField(l10n.equipment_name, _nameController, Icons.label_important_outline, required: true),
              _buildDropdownField(l10n.category, state.categories, _selectedCategoryId, (val) => setState(() => _selectedCategoryId = val)),
              _buildDropdownField(l10n.company, state.companies, _selectedCompanyId, (val) => setState(() => _selectedCompanyId = val)),
              _buildUsedBySelection(),
              if (_usedBy == 'department' || _usedBy == 'other')
                _buildDropdownField(l10n.assigned_department, state.departments, _selectedDepartmentId, (val) => setState(() => _selectedDepartmentId = val)),
              if (_usedBy == 'employee' || _usedBy == 'other')
                _buildDropdownField(l10n.assigned_employee, state.employees, _selectedEmployeeId, (val) => setState(() => _selectedEmployeeId = val)),
              _buildDropdownField(l10n.team, state.teams, _selectedTeamId, (val) => setState(() => _selectedTeamId = val)),
              _buildDropdownField(l10n.technician, state.employees, _selectedTechnicianId, (val) => setState(() => _selectedTechnicianId = val)),
              _buildDateField(l10n.scrap_date, _scrapDate, () => _selectDate(context, 'scrap')),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDescriptionTab() {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: _buildTextField(l10n.note, _noteController, Icons.note_alt_outlined, maxLines: 10),
    );
  }

  Widget _buildProductInfoTab() {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<MaintenanceCubit, MaintenanceState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildDropdownField(l10n.vendor, state.vendors, _selectedPartnerId, (val) => setState(() => _selectedPartnerId = val)),
              _buildTextField(l10n.vendor_reference, _partnerRefController, Icons.tag),
              _buildTextField(l10n.model, _modelController, Icons.settings_input_component),
              _buildTextField(l10n.mfg_serial_number, _serialNoController, Icons.confirmation_number_outlined),
              _buildTextField(l10n.inventory_serial_number, _compSerialNoController, Icons.inventory_outlined, suffix: IconButton(
                icon: const Icon(Icons.refresh, color: AppColors.primaryPurple),
                onPressed: () {
                  // Simulate generating sequence
                  _compSerialNoController.text = 'INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
                },
              )),
              _buildDateField(l10n.effective_date, _effectiveDate, () => _selectDate(context, 'effective')),
              _buildTextField(l10n.cost, _costController, Icons.attach_money, keyboardType: TextInputType.number),
              _buildDateField(l10n.warranty_expiration_date, _warrantyDate, () => _selectDate(context, 'warranty')),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMaintenanceTab() {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildTextField(l10n.expected_mtbf, _expectedMtbfController, Icons.timer_outlined, keyboardType: TextInputType.number),
          _buildTextField(l10n.mean_time_between_failure, _mtbfController, Icons.av_timer, keyboardType: TextInputType.number),
          _buildDateField(l10n.estimated_next_failure, _estimatedNextFailure, () => _selectDate(context, 'est_failure')),
          _buildDateField(l10n.latest_failure, _latestFailureDate, () => _selectDate(context, 'latest_failure')),
          _buildTextField(l10n.mean_time_to_repair, _mttrController, Icons.build_outlined, keyboardType: TextInputType.number),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {bool required = false, int maxLines = 1, TextInputType? keyboardType, Widget? suffix}) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
          prefixIcon: Icon(icon, color: AppColors.primaryPurple),
          suffixIcon: suffix,
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
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), 
            borderSide: const BorderSide(color: AppColors.primaryPurple, width: 2),
          ),
        ),
        validator: (value) {
          if (required && (value == null || value.isEmpty)) return l10n.please_enter(label);
          return null;
        },
      ),
    );
  }

  Widget _buildDropdownField(String label, List<dynamic> items, int? selectedValue, Function(int?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<int>(
        value: selectedValue,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.arrow_drop_down_circle_outlined, color: AppColors.primaryPurple),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
        items: items.map<DropdownMenuItem<int>>((item) {
          return DropdownMenuItem<int>(
            value: item['id'],
            child: Text(item['name'] ?? 'N/A'),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDateField(String label, DateTime? date, VoidCallback onTap) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: const Icon(Icons.calendar_today, color: AppColors.primaryPurple),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
          child: Text(date != null ? DateFormat('dd MMM yyyy').format(date) : l10n.select_date),
        ),
      ),
    );
  }

  Widget _buildUsedBySelection() {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.used_by, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textGrey)),
          Row(
            children: [
              _buildChoiceChip(l10n.employee, 'employee'),
              const SizedBox(width: 8),
              _buildChoiceChip(l10n.department, 'department'),
              const SizedBox(width: 8),
              _buildChoiceChip(l10n.other, 'other'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceChip(String label, String value) {
    final isSelected = _usedBy == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) setState(() => _usedBy = value);
      },
      selectedColor: AppColors.primaryPurple,
      labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textPrimary),
    );
  }

  Widget _buildBottomAction(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryPurple,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        onPressed: () => _submitForm(context),
        child: Text(l10n.save_equipment, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  void _submitForm(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final Map<String, dynamic> data = {
        'name': _nameController.text,
        'category_id': _selectedCategoryId,
        'company_id': _selectedCompanyId,
        'equipment_assign_to': _usedBy,
        'department_id': _selectedDepartmentId,
        'employee_id': _selectedEmployeeId,
        'maintenance_team_id': _selectedTeamId,
        'technician_user_id': _selectedTechnicianId,
        'scrap_date': _scrapDate?.toIso8601String().split('T')[0],
        'note': _noteController.text,
        'partner_id': _selectedPartnerId,
        'partner_ref': _partnerRefController.text,
        'model': _modelController.text,
        'serial_no': _serialNoController.text,
        'comp_serial_no': _compSerialNoController.text,
        'effective_date': _effectiveDate?.toIso8601String().split('T')[0],
        'cost': double.tryParse(_costController.text) ?? 0.0,
        'warranty_date': _warrantyDate?.toIso8601String().split('T')[0],
        'expected_mtbf': double.tryParse(_expectedMtbfController.text) ?? 0.0,
        'mtbf': double.tryParse(_mtbfController.text) ?? 0.0,
        'estimated_next_failure': _estimatedNextFailure?.toIso8601String().split('T')[0],
        'latest_failure_date': _latestFailureDate?.toIso8601String().split('T')[0],
        'mttr': double.tryParse(_mttrController.text) ?? 0.0,
      };
      
      // Need to find a way to get the cubit from the ancestor BlocProvider if needed,
      // or just use the local one.
      // Since BlocProvider is in build, I can use context.read<MaintenanceCubit>()
      context.read<MaintenanceCubit>().createEquipment(data);
    }
  }
}
