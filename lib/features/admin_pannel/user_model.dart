class UserModel {
  final String employeeId;
  String name;
  String email;
  String mobile;
  String role;
  bool isActive;

  UserModel({
    required this.employeeId,
    required this.name,
    required this.email,
    required this.mobile,
    required this.role,
    required this.isActive,
  });

  UserModel copyWith({
    String? name,
    String? email,
    String? mobile,
    String? role,
    bool? isActive,
  }) {
    return UserModel(
      employeeId: employeeId,
      name: name ?? this.name,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
    );
  }
}
