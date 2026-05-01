import 'package:flutter_app/features/admin_pannel/state/admai_state.dart';
import 'package:flutter_app/features/admin_pannel/user_mock.dart';
import 'package:flutter_app/features/admin_pannel/user_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserCubit extends Cubit<UserState> {
  final UserRepository repo;

  UserCubit(this.repo) : super(const UserState());

  void loadUsers() {
    emit(state.copyWith(isLoading: true));
    final users = repo.getUsers();
    emit(state.copyWith(users: users, isLoading: false));
  }

  void addUser(UserModel user) {
    repo.addUser(user);
    loadUsers();
  }

  void updateUser(UserModel user) {
    repo.updateUser(user);
    loadUsers();
  }

  void toggleStatus(UserModel user) {
    final updated = user.copyWith(isActive: !user.isActive);
    updateUser(updated);
  }
}
