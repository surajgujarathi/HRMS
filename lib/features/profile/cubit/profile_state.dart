import 'package:equatable/equatable.dart';
import 'package:flutter_app/features/profile/models/employee_model.dart';

enum ProfileStatus { initial, loading, success, failure }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final Employee? employee;
  final String? errorMessage;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.employee,
    this.errorMessage,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    Employee? employee,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      employee: employee ?? this.employee,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, employee, errorMessage];
}
