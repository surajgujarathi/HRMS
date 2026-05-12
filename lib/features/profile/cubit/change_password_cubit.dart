import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/core/constants/api_config.dart';
import 'package:flutter_app/core/utils/shared_pref.dart';
import 'package:flutter_app/network/odoo_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:odoo_rpc/odoo_rpc.dart';

enum ChangePasswordStatus { initial, loading, success, failure }

class ChangePasswordState extends Equatable {
  final ChangePasswordStatus status;
  final String? errorMessage;

  const ChangePasswordState({
    this.status = ChangePasswordStatus.initial,
    this.errorMessage,
  });

  ChangePasswordState copyWith({
    ChangePasswordStatus? status,
    String? errorMessage,
  }) {
    return ChangePasswordState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage];
}

class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  ChangePasswordCubit() : super(const ChangePasswordState());

  Future<void> changePassword({
    required String newPassword,
  }) async {
    debugPrint('ChangePasswordCubit: Starting password change process...');
    emit(state.copyWith(status: ChangePasswordStatus.loading));
    
    final odooService = OdooService(ApiConfig.baseUrl);
    try {
      final prefs = SharedPref();
      final sessionData = await prefs.getObject('session');
      
      if (sessionData == null) {
        throw Exception('User session not found. Please login again.');
      }

      final session = OdooSession.fromJson(sessionData);
      odooService.setSession(session);

      final userId = sessionData['userId'] is int 
          ? sessionData['userId'] 
          : int.parse(sessionData['userId']?.toString() ?? '0');
      final userLogin = sessionData['userLogin']?.toString() ?? '';
      
      debugPrint('ChangePasswordCubit: userId=$userId, userLogin=$userLogin');

      await odooService.changePassword(
        userId: userId,
        userLogin: userLogin,
        newPassword: newPassword,
      );

      debugPrint('ChangePasswordCubit: Password change SUCCESS');
      emit(state.copyWith(status: ChangePasswordStatus.success));
    } catch (e) {
      debugPrint('ChangePasswordCubit: Password change ERROR: $e');
      emit(state.copyWith(
        status: ChangePasswordStatus.failure,
        errorMessage: e.toString(),
      ));
    } finally {
      odooService.close();
    }
  }
}
