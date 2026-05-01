import 'package:equatable/equatable.dart';
import 'package:flutter_app/features/admin_pannel/user_model.dart';

class UserState extends Equatable {
  final List<UserModel> users;
  final bool isLoading;

  const UserState({this.users = const [], this.isLoading = false});

  UserState copyWith({List<UserModel>? users, bool? isLoading}) {
    return UserState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object> get props => [users, isLoading];
}
