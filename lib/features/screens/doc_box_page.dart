import 'package:flutter/material.dart';
import 'package:flutter_app/l10n/app_localizations.dart';

class DocBoxPage extends StatelessWidget {
  const DocBoxPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final companyDocs = [
      {"title": "January Salary Slip", "type": "PDF", "date": "01 Feb 2026"},
      {"title": "Offer Letter", "type": "PDF", "date": "15 Jan 2025"},
      {"title": "Experience Letter", "type": "PDF", "date": "20 Dec 2025"},
    ];

    final personalDocs = [
      {"title": "Aadhar Card", "type": "Image", "date": "10 Jan 2025"},
      {"title": "PAN Card", "type": "Image", "date": "05 Jan 2025"},
    ];

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          title: Text(
            l10n.doc_box,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              color: Colors.white,
            ),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          bottom: TabBar(
            indicatorColor: Colors.white,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            tabs: [
              Tab(text: l10n.company_docs),
              Tab(text: l10n.personal_docs),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: const Color(0xFF2A5298),
          onPressed: () {
            // Upload functionality
          },
          icon: const Icon(Icons.upload_file, color: Colors.white),
          label: Text(l10n.upload, style: const TextStyle(color: Colors.white)),
        ),
        body: TabBarView(
          children: [_buildDocList(context, companyDocs, l10n), _buildDocList(context, personalDocs, l10n)],
        ),
      ),
    );
  }

  Widget _buildDocList(BuildContext context, List<Map<String, String>> documents, AppLocalizations l10n) {
    if (documents.isEmpty) {
      return Center(child: Text(l10n.no_documents));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: documents.length,
      itemBuilder: (context, index) {
        final doc = documents[index];
        final isPdf = doc["type"] == "PDF";

        return Card(
          elevation: 4,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            contentPadding: const EdgeInsets.all(14),
            leading: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isPdf
                      ? [Colors.red.shade300, Colors.red.shade100]
                      : [Colors.green.shade300, Colors.green.shade100],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                isPdf ? Icons.picture_as_pdf : Icons.image,
                color: Colors.white,
              ),
            ),
            title: Text(
              doc["title"]!,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                l10n.uploaded_on(doc["date"]!),
                style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
              ),
            ),
            trailing: PopupMenuButton<String>(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (value) {
                // Handle actions
              },
              itemBuilder: (context) => [
                PopupMenuItem(value: "view", child: Text(l10n.view)),
                PopupMenuItem(value: "download", child: Text(l10n.download)),
                PopupMenuItem(value: "delete", child: Text(l10n.delete)),
              ],
            ),
          ),
        );
      },
    );
  }
}
