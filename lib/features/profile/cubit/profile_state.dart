import 'package:equatable/equatable.dart';

enum ProfileStatus { initial, loading, success, failure }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final Map<String, dynamic>? employeeData;
  final String? errorMessage;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.employeeData,
    this.errorMessage,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    Map<String, dynamic>? employeeData,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      employeeData: employeeData ?? this.employeeData,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, employeeData, errorMessage];
}
