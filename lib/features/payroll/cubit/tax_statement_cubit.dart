import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_app/network/payroll_api_service.dart';

enum TaxStatementStatus { initial, loading, success, failure, comparing, compared }

class TaxStatementState {
  final TaxStatementStatus status;
  final Map<String, dynamic> wizardData;
  final Map<String, dynamic> comparisonResult;
  final String? errorMessage;
  final String? successMessage;

  const TaxStatementState({
    this.status = TaxStatementStatus.initial,
    this.wizardData = const {},
    this.comparisonResult = const {},
    this.errorMessage,
    this.successMessage,
  });

  TaxStatementState copyWith({
    TaxStatementStatus? status,
    Map<String, dynamic>? wizardData,
    Map<String, dynamic>? comparisonResult,
    String? errorMessage,
    String? successMessage,
  }) {
    return TaxStatementState(
      status: status ?? this.status,
      wizardData: wizardData ?? this.wizardData,
      comparisonResult: comparisonResult ?? this.comparisonResult,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

class TaxStatementCubit extends Cubit<TaxStatementState> {
  final PayrollApiService _apiService;

  TaxStatementCubit(this._apiService) : super(const TaxStatementState());

  Future<void> initWizard(Map<String, dynamic> vals) async {
    emit(state.copyWith(status: TaxStatementStatus.loading));
    try {
      final wizard = await _apiService.createTaxStatementWizard(vals);
      emit(state.copyWith(
        status: TaxStatementStatus.success,
        wizardData: wizard,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TaxStatementStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> compareRegimes(int wizardId) async {
    emit(state.copyWith(status: TaxStatementStatus.comparing));
    try {
      final results = await _apiService.checkRegimeComparison(wizardId);
      emit(state.copyWith(
        status: TaxStatementStatus.compared,
        comparisonResult: results,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TaxStatementStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<String> downloadTaxReport(int wizardId) async {
    try {
      return await _apiService.generateTaxReport(wizardId);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
      return '';
    }
  }

  Future<String> downloadComparisonReport(int wizardId) async {
    try {
      return await _apiService.generateComparisonReport(wizardId);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
      return '';
    }
  }
}
