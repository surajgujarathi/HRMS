import 'package:flutter/material.dart';
import 'package:flutter_app/core/constants/app_colors.dart';
import 'package:flutter_app/features/maintenance/cubit/maintenance_cubit.dart';
import 'package:flutter_app/features/maintenance/models/maintenance_equipment.dart';
import 'package:flutter_app/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class AssignedAssetsPage extends StatelessWidget {
  const AssignedAssetsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (context) => MaintenanceCubit()..fetchAssignedEquipment(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: BlocBuilder<MaintenanceCubit, MaintenanceState>(
          builder: (context, state) {
            return Column(
              children: [
                _buildHeader(context, l10n, state),
                Expanded(
                  child: state.status == MaintenanceStatus.loading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.primaryPurple))
                      : state.equipments.isEmpty
                          ? _buildEmptyState(context, l10n)
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                              physics: const BouncingScrollPhysics(),
                              itemCount: state.equipments.length,
                              itemBuilder: (context, index) {
                                final equipment = state.equipments[index];
                                return _AssetCard(equipment: equipment);
                              },
                            ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n, MaintenanceState state) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.indigo, AppColors.brightBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
              ),
              Expanded(
                child: Text(
                  l10n.my_assets,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.hello(state.employeeName ?? l10n.employee),
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    l10n.active_assets_assigned(state.equipments.length.toString()),
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.indigo.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.inventory_2_outlined, size: 80, color: AppColors.indigo.withOpacity(0.2)),
          ),
          const SizedBox(height: 24),
           Text(
            l10n.no_assets_found,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.assets_assigned_desc,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _AssetCard extends StatelessWidget {
  final MaintenanceEquipment equipment;
  const _AssetCard({required this.equipment});

  @override
  Widget build(BuildContext context) {
    final bool isScrapped = equipment.scrapDate != null;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: () => _showAssetDetails(context, equipment),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.indigo.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getIconForCategory(equipment.categoryId?.name),
                        color: AppColors.indigo,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            equipment.name,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            equipment.categoryId?.name ?? l10n.general_asset,
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(l10n, isScrapped),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant ?? Theme.of(context).dividerColor.withOpacity(0.1),
                  border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoItem(context, l10n.model, equipment.model ?? '---'),
                    _buildInfoItem(context, l10n.serial_number, equipment.serialNo ?? '---'),
                    _buildInfoItem(context, l10n.cost, equipment.cost != null && equipment.cost! > 0 ? '\$${equipment.cost!.toStringAsFixed(0)}' : '---'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(AppLocalizations l10n, bool isScrapped) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (isScrapped ? AppColors.dangerRed : AppColors.successGreen).withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        isScrapped ? l10n.scrapped : l10n.in_use,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: isScrapped ? AppColors.dangerRed : AppColors.successGreen,
        ),
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Theme.of(context).colorScheme.onSurface)),
      ],
    );
  }

  IconData _getIconForCategory(String? category) {
    if (category == null) return Icons.inventory_2_outlined;
    final cat = category.toLowerCase();
    if (cat.contains('laptop') || cat.contains('computer')) return Icons.laptop_mac;
    if (cat.contains('phone') || cat.contains('mobile')) return Icons.smartphone;
    if (cat.contains('car') || cat.contains('vehicle')) return Icons.directions_car_filled_outlined;
    if (cat.contains('furniture')) return Icons.chair_outlined;
    if (cat.contains('monitor')) return Icons.monitor;
    return Icons.inventory_2_outlined;
  }

  void _showAssetDetails(BuildContext context, MaintenanceEquipment asset) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AssetDetailSheet(asset: asset),
    );
  }
}

class _AssetDetailSheet extends StatelessWidget {
  final MaintenanceEquipment asset;
  const _AssetDetailSheet({required this.asset});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.indigo.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.inventory_2_rounded, color: AppColors.indigo, size: 48),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      asset.name,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Center(
                    child: Text(
                      asset.categoryId?.name ?? l10n.general_asset,
                      style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildDetailSection(context, l10n.asset_specifications, [
                    _buildDetailRow(context, l10n.model, asset.model),
                    _buildDetailRow(context, l10n.serial_number, asset.serialNo),
                    _buildDetailRow(context, l10n.company, asset.companyId?.name),
                    _buildDetailRow(context, l10n.vendor, asset.partnerId?.name),
                  ]),
                  _buildDetailSection(context, l10n.maintenance_history, [
                    _buildDetailRow(context, l10n.effective_date, asset.effectiveDate != null ? DateFormat('dd MMM yyyy').format(asset.effectiveDate!) : null),
                    _buildDetailRow(context, l10n.warranty_expiration_date, asset.warrantyDate != null ? DateFormat('dd MMM yyyy').format(asset.warrantyDate!) : null),
                    _buildDetailRow(context, l10n.estimated_next_failure, asset.estimatedNextFailure != null ? DateFormat('dd MMM yyyy').format(asset.estimatedNextFailure!) : null),
                  ]),
                  if (asset.note != null && asset.note!.isNotEmpty) ...[
                    Text(l10n.additional_notes, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.indigo)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant ?? Theme.of(context).dividerColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(asset.note!, style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface)),
                    ),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.indigo)),
        const SizedBox(height: 12),
        Container(
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.indigo.withOpacity(0.1)),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String? value) {
    if (value == null || value == 'null' || value.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.indigo.withOpacity(0.05))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          Text(value, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Theme.of(context).colorScheme.onSurface)),
        ],
      ),
    );
  }
}
