import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_app/core/utils/shared_pref.dart';
import 'package:flutter_app/network/odoo_service.dart';
import 'package:flutter_app/features/document/models/document_model.dart';
import 'package:flutter_app/features/document/state/document_state.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:url_launcher/url_launcher.dart';

class DocumentCubit extends Cubit<DocumentState> {
  DocumentCubit() : super(const DocumentState());

  void clearData() {
    emit(const DocumentState());
  }

  Future<void> fetchDocuments() async {
    if (isClosed) return;
    emit(state.copyWith(status: DocumentStatus.loading));
    final prefs = SharedPref();
    final baseUrl = await prefs.getString('baseUrl');
    final sessionObj = await prefs.getObject('session');

    if (baseUrl == null || sessionObj == null) {
      if (!isClosed) emit(state.copyWith(status: DocumentStatus.failure, errorMessage: "Session expired"));
      return;
    }

    final session = OdooSession.fromJson(sessionObj);
    final odooService = OdooService(baseUrl, session: session);

    try {
      final results = await odooService.fetchDocuments(userId: session.userId);
      final documents = results.map((d) => AppDocument.fromJson(d)).toList();

      if (!isClosed) {
        emit(state.copyWith(
          status: DocumentStatus.success,
          documents: documents,
        ));
      }
    } catch (e) {
      debugPrint('DocumentCubit fetchDocuments ERROR: $e');
      if (!isClosed) {
        emit(state.copyWith(
          status: DocumentStatus.failure,
          errorMessage: _getErrorMessage(e),
        ));
      }
    } finally {
      odooService.close();
    }
  }

  Future<void> createDocument(Map<String, dynamic> data) async {
    if (isClosed) return;
    emit(state.copyWith(status: DocumentStatus.submitting));
    final prefs = SharedPref();
    final baseUrl = await prefs.getString('baseUrl');
    final sessionObj = await prefs.getObject('session');

    if (baseUrl == null || sessionObj == null) {
      if (!isClosed) emit(state.copyWith(status: DocumentStatus.failure, errorMessage: "Session expired"));
      return;
    }

    final session = OdooSession.fromJson(sessionObj);
    final odooService = OdooService(baseUrl, session: session);

    try {
      final payload = Map<String, dynamic>.from(data);
      if (!payload.containsKey('owner_id')) {
        payload['owner_id'] = session.userId;
      }
      final docId = await odooService.createDocument(payload);
      if (docId > 0) {
        if (!isClosed) {
          emit(state.copyWith(
            status: DocumentStatus.submitted,
            successMessage: "Document created successfully",
          ));
        }
        await fetchDocuments();
      } else {
        throw Exception("Failed to create document");
      }
    } catch (e) {
      debugPrint('DocumentCubit createDocument ERROR: $e');
      if (!isClosed) {
        emit(state.copyWith(
          status: DocumentStatus.failure,
          errorMessage: _getErrorMessage(e),
        ));
      }
    } finally {
      odooService.close();
    }
  }

  Future<void> updateDocument(int documentId, Map<String, dynamic> data) async {
    if (isClosed) return;
    emit(state.copyWith(status: DocumentStatus.submitting));
    final prefs = SharedPref();
    final baseUrl = await prefs.getString('baseUrl');
    final sessionObj = await prefs.getObject('session');

    if (baseUrl == null || sessionObj == null) {
      if (!isClosed) emit(state.copyWith(status: DocumentStatus.failure, errorMessage: "Session expired"));
      return;
    }

    final session = OdooSession.fromJson(sessionObj);
    final odooService = OdooService(baseUrl, session: session);

    try {
      final success = await odooService.writeDocument(documentId, data);
      if (success) {
        if (!isClosed) {
          emit(state.copyWith(
            status: DocumentStatus.submitted,
            successMessage: "Document updated successfully",
          ));
        }
        await fetchDocuments();
      } else {
        throw Exception("Failed to update document");
      }
    } catch (e) {
      debugPrint('DocumentCubit updateDocument ERROR: $e');
      if (!isClosed) {
        emit(state.copyWith(
          status: DocumentStatus.failure,
          errorMessage: _getErrorMessage(e),
        ));
      }
    } finally {
      odooService.close();
    }
  }

  Future<void> deleteDocument(int documentId) async {
    if (isClosed) return;
    final prefs = SharedPref();
    final baseUrl = await prefs.getString('baseUrl');
    final sessionObj = await prefs.getObject('session');

    if (baseUrl == null || sessionObj == null) return;

    final session = OdooSession.fromJson(sessionObj);
    final odooService = OdooService(baseUrl, session: session);

    try {
      final success = await odooService.unlinkDocument(documentId);
      if (success) {
        if (!isClosed) {
          emit(state.copyWith(
            successMessage: "Document deleted successfully",
          ));
        }
        await fetchDocuments();
      } else {
        throw Exception("Failed to delete document");
      }
    } catch (e) {
      debugPrint('DocumentCubit deleteDocument ERROR: $e');
      if (!isClosed) {
        emit(state.copyWith(
          status: DocumentStatus.failure,
          errorMessage: _getErrorMessage(e),
        ));
      }
    } finally {
      odooService.close();
    }
  }

  Future<void> toggleActive(int documentId) async {
    if (isClosed) return;
    final prefs = SharedPref();
    final baseUrl = await prefs.getString('baseUrl');
    final sessionObj = await prefs.getObject('session');

    if (baseUrl == null || sessionObj == null) return;

    final session = OdooSession.fromJson(sessionObj);
    final odooService = OdooService(baseUrl, session: session);

    try {
      await odooService.toggleActiveDocument(documentId);
      await fetchDocuments();
    } catch (e) {
      debugPrint('DocumentCubit toggleActive ERROR: $e');
      if (!isClosed) {
        emit(state.copyWith(
          status: DocumentStatus.failure,
          errorMessage: _getErrorMessage(e),
        ));
      }
    } finally {
      odooService.close();
    }
  }

  Future<Map<String, dynamic>?> getDocumentData(int documentId) async {
    final prefs = SharedPref();
    final baseUrl = await prefs.getString('baseUrl');
    final sessionObj = await prefs.getObject('session');

    if (baseUrl == null || sessionObj == null) return null;

    final session = OdooSession.fromJson(sessionObj);
    final odooService = OdooService(baseUrl, session: session);

    try {
      return await odooService.fetchDocumentData(documentId);
    } catch (e) {
      debugPrint('DocumentCubit getDocumentData ERROR: $e');
      return null;
    } finally {
      odooService.close();
    }
  }

  Future<void> downloadDocument(int documentId) async {
    if (isClosed) return;
    final data = await getDocumentData(documentId);
    if (data == null) {
      if (!isClosed) emit(state.copyWith(errorMessage: "Failed to download document: data is empty"));
      return;
    }

    final type = data['type']?.toString();
    final name = data['name']?.toString() ?? 'document';
    
    if (type == 'url') {
      final urlStr = data['url']?.toString();
      if (urlStr != null) {
        final uri = Uri.tryParse(urlStr);
        if (uri != null && await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          if (!isClosed) emit(state.copyWith(errorMessage: "Invalid or unopenable URL"));
        }
      }
    } else {
      final base64Content = data['datas']?.toString();
      if (base64Content == null || base64Content.isEmpty) {
        if (!isClosed) emit(state.copyWith(errorMessage: "File content is empty"));
        return;
      }
      try {
        final bytes = base64Decode(base64Content.trim().replaceAll('\n', '').replaceAll('\r', ''));
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/$name');
        await file.writeAsBytes(bytes);
        if (!isClosed) emit(state.copyWith(successMessage: "Document downloaded to ${file.path}"));
        await OpenFile.open(file.path);
      } catch (e) {
        if (!isClosed) emit(state.copyWith(errorMessage: "Failed to save file: $e"));
      }
    }
  }

  Future<void> openDocument(int documentId) async {
    if (isClosed) return;
    final data = await getDocumentData(documentId);
    if (data == null) {
      if (!isClosed) emit(state.copyWith(errorMessage: "Failed to open document: data is empty"));
      return;
    }

    final type = data['type']?.toString();
    final name = data['name']?.toString() ?? 'document';
    
    if (type == 'url') {
      final urlStr = data['url']?.toString();
      if (urlStr != null) {
        final uri = Uri.tryParse(urlStr);
        if (uri != null && await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          if (!isClosed) emit(state.copyWith(errorMessage: "Invalid or unopenable URL"));
        }
      }
    } else {
      final base64Content = data['datas']?.toString();
      if (base64Content == null || base64Content.isEmpty) {
        if (!isClosed) emit(state.copyWith(errorMessage: "File content is empty"));
        return;
      }
      try {
        final bytes = base64Decode(base64Content.trim().replaceAll('\n', '').replaceAll('\r', ''));
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/$name');
        await file.writeAsBytes(bytes);
        await OpenFile.open(file.path);
      } catch (e) {
        if (!isClosed) emit(state.copyWith(errorMessage: "Failed to open file: $e"));
      }
    }
  }

  Future<void> shareDocument(int documentId) async {
    final prefs = SharedPref();
    final baseUrl = await prefs.getString('baseUrl');
    final sessionObj = await prefs.getObject('session');

    if (baseUrl == null || sessionObj == null) return;

    final session = OdooSession.fromJson(sessionObj);
    final odooService = OdooService(baseUrl, session: session);

    try {
      await odooService.actionShareDocument(documentId);
    } catch (e) {
      debugPrint('DocumentCubit shareDocument ERROR: $e');
    } finally {
      odooService.close();
    }
  }

  Future<void> checkAccess() async {
    final prefs = SharedPref();
    final baseUrl = await prefs.getString('baseUrl');
    final sessionObj = await prefs.getObject('session');

    if (baseUrl == null || sessionObj == null) return;

    final session = OdooSession.fromJson(sessionObj);
    final odooService = OdooService(baseUrl, session: session);

    try {
      await odooService.checkAccessDocument();
    } catch (e) {
      debugPrint('DocumentCubit checkAccess ERROR: $e');
    } finally {
      odooService.close();
    }
  }

  String _getErrorMessage(Object e) {
    if (e is OdooException) {
      try {
        final data = e.error;
        if (data is Map && data['message'] != null) {
          return data['message'].toString();
        }
      } catch (_) {}
      return e.message;
    }
    return e.toString();
  }

  void clearMessages() {
    emit(state.copyWith(errorMessage: null, successMessage: null));
  }
}
