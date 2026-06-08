import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_app/network/payroll_api_service.dart';

enum ItDeclarationStatus { initial, loading, success, failure, submitting, submitted }

class ItDeclarationState {
  final ItDeclarationStatus status;
  final List<dynamic> declarations;
  final List<dynamic> periods;
  final List<dynamic> periodLines;
  final String? errorMessage;
  final String? successMessage;

  const ItDeclarationState({
    this.status = ItDeclarationStatus.initial,
    this.declarations = const [],
    this.periods = const [],
    this.periodLines = const [],
    this.errorMessage,
    this.successMessage,
  });

  ItDeclarationState copyWith({
    ItDeclarationStatus? status,
    List<dynamic>? declarations,
    List<dynamic>? periods,
    List<dynamic>? periodLines,
    String? errorMessage,
    String? successMessage,
  }) {
    return ItDeclarationState(
      status: status ?? this.status,
      declarations: declarations ?? this.declarations,
      periods: periods ?? this.periods,
      periodLines: periodLines ?? this.periodLines,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

class ItDeclarationCubit extends Cubit<ItDeclarationState> {
  final PayrollApiService _apiService;

  ItDeclarationCubit(this._apiService) : super(const ItDeclarationState());

  Future<void> loadInitialData(int employeeId) async {
    emit(state.copyWith(status: ItDeclarationStatus.loading));
    try {
      final declarations = await _apiService.fetchItDeclarations(employeeId);
      final periods = await _apiService.fetchPayrollPeriods();
      emit(state.copyWith(
        status: ItDeclarationStatus.success,
        declarations: declarations,
        periods: periods,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ItDeclarationStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> fetchPeriodLines(int periodId) async {
    try {
      final lines = await _apiService.fetchPeriodLines(periodId);
      emit(state.copyWith(periodLines: lines));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> createDeclaration(Map<String, dynamic> vals, int employeeId) async {
    emit(state.copyWith(status: ItDeclarationStatus.submitting));
    try {
      final id = await _apiService.createItDeclaration(vals);
      if (id > 0) {
        final declarations = await _apiService.fetchItDeclarations(employeeId);
        emit(state.copyWith(
          status: ItDeclarationStatus.success,
          declarations: declarations,
          successMessage: 'IT Declaration created successfully',
        ));
      } else {
        emit(state.copyWith(
          status: ItDeclarationStatus.failure,
          errorMessage: 'Failed to create IT Declaration',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: ItDeclarationStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> updateDeclaration(int id, Map<String, dynamic> vals, int employeeId) async {
    emit(state.copyWith(status: ItDeclarationStatus.submitting));
    try {
      final success = await _apiService.writeItDeclaration(id, vals);
      if (success) {
        final declarations = await _apiService.fetchItDeclarations(employeeId);
        emit(state.copyWith(
          status: ItDeclarationStatus.success,
          declarations: declarations,
          successMessage: 'IT Declaration updated successfully',
        ));
      } else {
        emit(state.copyWith(
          status: ItDeclarationStatus.failure,
          errorMessage: 'Failed to update IT Declaration',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: ItDeclarationStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> deleteDeclaration(int id, int employeeId) async {
    emit(state.copyWith(status: ItDeclarationStatus.loading));
    try {
      final success = await _apiService.unlinkItDeclaration(id);
      if (success) {
        final declarations = await _apiService.fetchItDeclarations(employeeId);
        emit(state.copyWith(
          status: ItDeclarationStatus.success,
          declarations: declarations,
          successMessage: 'IT Declaration deleted successfully',
        ));
      } else {
        emit(state.copyWith(
          status: ItDeclarationStatus.failure,
          errorMessage: 'Failed to delete IT Declaration',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: ItDeclarationStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> toggleSection(int id, int employeeId) async {
    try {
      await _apiService.toggleSectionVisibility(id);
      final declarations = await _apiService.fetchItDeclarations(employeeId);
      emit(state.copyWith(declarations: declarations));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> submitDeclaration(int id, int employeeId) async {
    emit(state.copyWith(status: ItDeclarationStatus.submitting));
    try {
      final success = await _apiService.submitItDeclaration(id);
      if (success) {
        final declarations = await _apiService.fetchItDeclarations(employeeId);
        emit(state.copyWith(
          status: ItDeclarationStatus.success,
          declarations: declarations,
          successMessage: 'IT Declaration submitted successfully',
        ));
      } else {
        emit(state.copyWith(
          status: ItDeclarationStatus.failure,
          errorMessage: 'Failed to submit IT Declaration',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: ItDeclarationStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> returnToDraft(int id, String reason, int employeeId) async {
    emit(state.copyWith(status: ItDeclarationStatus.loading));
    try {
      final success = await _apiService.returnItDeclarationToDraft(id, reason);
      if (success) {
        final declarations = await _apiService.fetchItDeclarations(employeeId);
        emit(state.copyWith(
          status: ItDeclarationStatus.success,
          declarations: declarations,
          successMessage: 'Declaration returned to draft',
        ));
      } else {
        emit(state.copyWith(
          status: ItDeclarationStatus.failure,
          errorMessage: 'Failed to return declaration to draft',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: ItDeclarationStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<String> getPdfUrl(int id) async {
    try {
      return await _apiService.downloadSubmissionPdf(id);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
      return '';
    }
  }
}
