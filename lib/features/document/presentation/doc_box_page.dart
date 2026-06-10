import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter_app/core/constants/app_colors.dart';
import 'package:flutter_app/features/document/cubit/document_cubit.dart';
import 'package:flutter_app/features/document/models/document_model.dart';
import 'package:flutter_app/features/document/state/document_state.dart';
import 'package:flutter_app/l10n/app_localizations.dart';
import 'package:shimmer/shimmer.dart';

class DocBoxPage extends StatefulWidget {
  const DocBoxPage({super.key});

  @override
  State<DocBoxPage> createState() => _DocBoxPageState();
}

class _DocBoxPageState extends State<DocBoxPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'All'; // 'All', 'Binary', 'URL', 'Archived'
  String? _selectedFolderFilter;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DocumentCubit>().fetchDocuments();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<DocumentCubit, DocumentState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.dangerRed,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
          context.read<DocumentCubit>().clearMessages();
        } else if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: AppColors.successGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
          context.read<DocumentCubit>().clearMessages();
        }
      },
      builder: (context, state) {
        // Apply Filters & Search
        List<AppDocument> filteredDocs = state.documents.where((doc) {
          // 1. Search Query
          final nameMatch = doc.name.toLowerCase().contains(_searchQuery.toLowerCase());
          final ownerMatch = doc.ownerName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false;
          final partnerMatch = doc.partnerName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false;
          final queryMatch = nameMatch || ownerMatch || partnerMatch;

          // 2. Tab Filter
          bool filterMatch = true;
          if (_selectedFilter == 'Binary') {
            filterMatch = doc.type == 'binary' && doc.active;
          } else if (_selectedFilter == 'URL') {
            filterMatch = doc.type == 'url' && doc.active;
          } else if (_selectedFilter == 'Archived') {
            filterMatch = !doc.active;
          } else {
            filterMatch = doc.active; // All active docs
          }

          // 3. Folder Filter
          bool folderMatch = true;
          if (_selectedFolderFilter != null) {
            folderMatch = doc.folderName == _selectedFolderFilter;
          }

          return queryMatch && filterMatch && folderMatch;
        }).toList();

        // Extract folder list
        final folders = state.documents
            .map((d) => d.folderName)
            .whereType<String>()
            .toSet()
            .toList();

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Column(
            children: [
              _buildHeader(context, state.documents.length, l10n),
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.indigo,
                  onRefresh: () => context.read<DocumentCubit>().fetchDocuments(),
                  child: CustomScrollView(
                    slivers: [
                      // Folder section
                      if (folders.isNotEmpty)
                        SliverToBoxAdapter(
                          child: _buildFolderList(folders, l10n),
                        ),
                      // Filter tabs (All, Files, Links, Archived)
                      SliverToBoxAdapter(
                        child: _buildFilterTabs(l10n),
                      ),
                      // Document list
                      if (state.status == DocumentStatus.loading)
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          sliver: SliverToBoxAdapter(
                            child: Shimmer.fromColors(
                              baseColor: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey[800]!
                                  : Colors.grey[300]!,
                              highlightColor: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey[700]!
                                  : Colors.grey[100]!,
                              child: Column(
                                children: List.generate(
                                  5,
                                  (index) => Container(
                                    height: 80,
                                    margin: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      else if (filteredDocs.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: _buildEmptyState(l10n),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => _buildDocCard(context, filteredDocs[index], l10n),
                              childCount: filteredDocs.length,
                            ),
                          ),
                        ),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 100), // Space to avoid bottom fab/nav bar
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: AppColors.brightBlue,
            elevation: 8,
            onPressed: () => _showAddDocumentDialog(context, l10n),
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: const Text("Add Document", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        );
      },
    );
  }
  Widget _buildHeader(BuildContext context, int totalCount, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 12, 20, 20),
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
                  l10n.doc_box,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 22),
                onPressed: () => context.read<DocumentCubit>().fetchDocuments(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Search & Counters
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.black87, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: l10n.search_placeholder_doc,
                      hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                      prefixIcon: const Icon(Icons.search_rounded, color: Colors.black54),
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      fillColor: Colors.transparent,
                      filled: false,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  l10n.total_count_label(totalCount),
                  style: const TextStyle(color: AppColors.indigo, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFolderList(List<String> folders, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Text(
            l10n.folders,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: folders.length + 1,
            itemBuilder: (context, index) {
              final isAll = index == 0;
              final folderName = isAll ? l10n.all_folders : folders[index - 1];
              final isSelected = isAll ? _selectedFolderFilter == null : _selectedFolderFilter == folderName;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(folderName),
                  selected: isSelected,
                  selectedColor: AppColors.indigo.withOpacity(0.15),
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.indigo : Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
                  onSelected: (selected) {
                    setState(() {
                      _selectedFolderFilter = isAll ? null : folderName;
                    });
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterTabs(AppLocalizations l10n) {
    final filters = ['All', 'Binary', 'URL', 'Archived'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: (Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface).withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: filters.map((f) {
            final isSelected = _selectedFilter == f;
            String label = f;
            if (f == 'Binary') label = "Files";
            if (f == 'URL') label = "Links";
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedFilter = f),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.indigo : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDocCard(BuildContext context, AppDocument doc, AppLocalizations l10n) {
    final isPdf = doc.datasFname?.toLowerCase().endsWith('.pdf') ?? false;
    final isImage = doc.datasFname?.toLowerCase().endsWith('.png') ?? 
                    doc.datasFname?.toLowerCase().endsWith('.jpg') ?? 
                    doc.datasFname?.toLowerCase().endsWith('.jpeg') ?? false;
    final isUrl = doc.type == 'url';

    IconData fileIcon = Icons.insert_drive_file_rounded;
    Color accentColor = Colors.grey.shade600;
    Color iconBg = Colors.grey.shade50;
    String typeLabel = "FILE";

    if (isPdf) {
      fileIcon = Icons.picture_as_pdf_rounded;
      accentColor = Colors.red.shade600;
      iconBg = Colors.red.shade50;
      typeLabel = "PDF";
    } else if (isImage) {
      fileIcon = Icons.image_rounded;
      accentColor = Colors.blue.shade600;
      iconBg = Colors.blue.shade50;
      typeLabel = "IMAGE";
    } else if (isUrl) {
      fileIcon = Icons.link_rounded;
      accentColor = Colors.green.shade600;
      iconBg = Colors.green.shade50;
      typeLabel = "LINK";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.08), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showDocDetailsSheet(context, doc, l10n),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left side border color index strip
                  Container(
                    width: 6,
                    color: Colors.primaries[doc.name
                                 .hashCode % Colors.primaries.length],
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Row(
                        children: [
                          // Beautiful Double Container for Icon
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: iconBg,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(fileIcon, color: accentColor, size: 22),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Text Column
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  doc.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: -0.1),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                // Meta Chips Row
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    // Type Badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: accentColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        typeLabel,
                                        style: TextStyle(fontSize: 9, color: accentColor, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                                      ),
                                    ),
                                    // Folder Tag (if available)
                                    if (doc.folderName != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryPurple.withOpacity(0.08),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          doc.folderName!,
                                          style: const TextStyle(fontSize: 9, color: AppColors.primaryPurple, fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                    // Created Date
                                    Text(
                                      doc.createDate != null
                                          ? DateFormat('dd MMM yyyy').format(DateTime.parse(doc.createDate!))
                                          : "No Date",
                                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Trailing Arrow or Archived Badge
                          if (!doc.active)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).dividerColor.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.15)),
                              ),
                              child: Text(
                                l10n.archived,
                                style: TextStyle(fontSize: 10, color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7) ?? Colors.grey, fontWeight: FontWeight.bold),
                              ),
                            )
                          else
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Theme.of(context).dividerColor.withOpacity(0.05),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.indigo.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.folder_open_rounded, size: 70, color: AppColors.indigo.withOpacity(0.3)),
          ),
          const SizedBox(height: 16),
          Text(l10n.no_documents_found, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(l10n.no_documents_matching, style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  void _showDocDetailsSheet(BuildContext context, AppDocument doc, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (ctx) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).padding.bottom + 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        doc.name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: Icon(doc.active ? Icons.archive_outlined : Icons.unarchive_outlined, color: AppColors.indigo),
                      onPressed: () {
                        final cubit = context.read<DocumentCubit>();
                        Navigator.pop(ctx);
                        cubit.toggleActive(doc.id);
                      },
                    ),
                  ],
                ),
                const Divider(height: 24),
                 // Meta details
                _buildDetailRow(l10n.type, doc.type == 'url' ? 'Link (URL)' : 'File (Binary)'),
                if (doc.datasFname != null) _buildDetailRow(l10n.file_name, doc.datasFname!),
                if (doc.url != null) _buildDetailRow(l10n.url_label, doc.url!),
                if (doc.ownerName != null) _buildDetailRow(l10n.owner, doc.ownerName!),
                if (doc.folderName != null) _buildDetailRow(l10n.folder, doc.folderName!),
                if (doc.partnerName != null) _buildDetailRow(l10n.contact, doc.partnerName!),
                // if (doc.createByName != null) _buildDetailRow("Created By", doc.createByName!),
                if (doc.createDate != null) 
                  _buildDetailRow(l10n.created_on, DateFormat('dd MMM yyyy HH:mm').format(DateTime.parse(doc.createDate!))),
                // if (doc.writeByName != null) _buildDetailRow("Modified By", doc.writeByName!),
                if (doc.writeDate != null)
                  _buildDetailRow(l10n.modified_on, DateFormat('dd MMM yyyy HH:mm').format(DateTime.parse(doc.writeDate!))),
                
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.indigo,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          final cubit = context.read<DocumentCubit>();
                          Navigator.pop(ctx);
                          cubit.openDocument(doc.id);
                        },
                        icon: const Icon(Icons.open_in_new_rounded, color: Colors.white),
                        label: Text(l10n.open_label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brightBlue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          final cubit = context.read<DocumentCubit>();
                          Navigator.pop(ctx);
                          cubit.downloadDocument(doc.id);
                        },
                        icon: const Icon(Icons.download_rounded, color: Colors.white),
                        label: Text(l10n.download, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.indigo,
                          backgroundColor: AppColors.indigo.withOpacity(0.08),
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _showEditDocumentDialog(context, doc, l10n);
                        },
                        icon: const Icon(Icons.edit_outlined),
                        label: Text(l10n.edit_details, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.dangerRed,
                          backgroundColor: AppColors.dangerRed.withOpacity(0.08),
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _showDeleteConfirmDialog(context, doc.id);
                        },
                        icon: const Icon(Icons.delete_outline_rounded, color: AppColors.dangerRed),
                        label: Text(l10n.delete, style: const TextStyle(color: AppColors.dangerRed, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey, fontSize: 13)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  void _showAddDocumentDialog(BuildContext context, AppLocalizations l10n) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final urlCtrl = TextEditingController();
    String type = 'binary';
    File? selectedFile;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text(l10n.add_document, style: const TextStyle(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        value: type,
                        items: [
                          DropdownMenuItem(value: 'binary', child: Text(l10n.upload_file)),
                          DropdownMenuItem(value: 'url', child: Text(l10n.url_link)),
                        ],
                        onChanged: (val) {
                          setDialogState(() {
                            type = val!;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: l10n.type_label,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: nameCtrl,
                        decoration: InputDecoration(
                          labelText: l10n.full_name,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (v) => v == null || v.isEmpty ? "Required field" : null,
                      ),
                      const SizedBox(height: 16),
                      if (type == 'binary') ...[
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.indigo,
                            backgroundColor: AppColors.indigo.withOpacity(0.08),
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                          ),
                          onPressed: () async {
                            final result = await FilePicker.platform.pickFiles(
                              type: FileType.any,
                            );
                            if (result != null && result.files.single.path != null) {
                              setDialogState(() {
                                selectedFile = File(result.files.single.path!);
                                if (nameCtrl.text.isEmpty) {
                                  nameCtrl.text = result.files.single.name;
                                }
                              });
                            }
                          },
                          icon: const Icon(Icons.attach_file_rounded),
                          label: Text(selectedFile != null ? l10n.file_chosen : l10n.choose_file),
                        ),
                        if (selectedFile != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(selectedFile!.path.split('/').last, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                      ] else ...[
                        TextFormField(
                          controller: urlCtrl,
                          decoration: InputDecoration(
                            labelText: l10n.url_label,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          validator: (v) => v == null || v.isEmpty ? "Required field" : null,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(l10n.cancel),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final data = <String, dynamic>{
                        'name': nameCtrl.text,
                        'type': type,
                      };

                      final messenger = ScaffoldMessenger.of(context);
                      final cubit = context.read<DocumentCubit>();
                      final navigator = Navigator.of(ctx);

                      if (type == 'binary') {
                        if (selectedFile == null) {
                          messenger.showSnackBar(
                            const SnackBar(content: Text("Please select a file to upload")),
                          );
                          return;
                        }
                        final bytes = await selectedFile!.readAsBytes();
                        data['datas'] = base64Encode(bytes);
                      } else {
                        String urlText = urlCtrl.text.trim();
                        if (!urlText.startsWith('http://') && !urlText.startsWith('https://') && !urlText.startsWith('ftp://')) {
                          urlText = 'https://$urlText';
                        }
                        data['url'] = urlText;
                      }

                      navigator.pop();
                      cubit.createDocument(data);
                    }
                  },
                  child: Text(l10n.save),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditDocumentDialog(BuildContext context, AppDocument doc, AppLocalizations l10n) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: doc.name);
    final urlCtrl = TextEditingController(text: doc.url ?? '');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(l10n.edit_details, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: l10n.full_name,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (v) => v == null || v.isEmpty ? "Required field" : null,
                  ),
                  if (doc.type == 'url') ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: urlCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.url_label,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (v) => v == null || v.isEmpty ? "Required field" : null,
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final data = <String, dynamic>{
                    'name': nameCtrl.text,
                  };
                  if (doc.type == 'url') {
                    String urlText = urlCtrl.text.trim();
                    if (!urlText.startsWith('http://') && !urlText.startsWith('https://') && !urlText.startsWith('ftp://')) {
                      urlText = 'https://$urlText';
                    }
                    data['url'] = urlText;
                  }

                  final cubit = context.read<DocumentCubit>();
                  Navigator.pop(ctx);
                  cubit.updateDocument(doc.id, data);
                }
              },
              child: Text(l10n.save),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, int docId) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(l10n.delete, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Text(l10n.delete_draft_confirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.dangerRed),
              onPressed: () {
                final cubit = context.read<DocumentCubit>();
                Navigator.pop(ctx);
                cubit.deleteDocument(docId);
              },
              child: Text(l10n.delete, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
