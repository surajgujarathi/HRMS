import 'package:flutter_app/features/admin_pannel/user_model.dart';

class UserRepository {
  final List<UserModel> _users = [
    UserModel(
      employeeId: "EMP001",
      name: "John Doe",
      email: "john@example.com",
      mobile: "1234567890",
      role: "Admin",
      isActive: true,
    ),
  ];

  List<UserModel> getUsers() => List.from(_users);

  void addUser(UserModel user) {
    _users.add(user);
  }

  void updateUser(UserModel updatedUser) {
    final index = _users.indexWhere(
      (u) => u.employeeId == updatedUser.employeeId,
    );
    if (index != -1) {
      _users[index] = updatedUser;
    }
  }
}
