import 'package:flutter_app/features/document/models/document_model.dart';

enum DocumentStatus { initial, loading, success, failure, submitting, submitted }

class DocumentState {
  final DocumentStatus status;
  final List<AppDocument> documents;
  final String? errorMessage;
  final String? successMessage;

  const DocumentState({
    this.status = DocumentStatus.initial,
    this.documents = const [],
    this.errorMessage,
    this.successMessage,
  });

  DocumentState copyWith({
    DocumentStatus? status,
    List<AppDocument>? documents,
    String? errorMessage,
    String? successMessage,
  }) {
    return DocumentState(
      status: status ?? this.status,
      documents: documents ?? this.documents,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}
