import 'package:flutter/material.dart';
import 'package:flutter_app/features/admin_pannel/cubit/admin_cubit.dart';
import 'package:flutter_app/features/admin_pannel/state/admai_state.dart';
import 'package:flutter_app/features/admin_pannel/user_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Panel"),
        actions: [
          TextButton(
            onPressed: () => _openAddDialog(context),
            child: const Text(
              "+ Add User",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: BlocBuilder<UserCubit, UserState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: "Search users",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              /// Table Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Expanded(child: Text("Emp ID")),
                  Expanded(child: Text("Name")),
                  Expanded(child: Text("Mobile")),
                  Expanded(child: Text("Role")),
                  Expanded(child: Text("Status")),
                ],
              ),

              const Divider(),

              /// User List
              ...state.users.map((user) => _userTile(context, user)),
            ],
          );
        },
      ),
    );
  }

  Widget _userTile(BuildContext context, UserModel user) {
    return Card(
      child: ListTile(
        title: Text("${user.employeeId} - ${user.name}"),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text(user.email), Text(user.mobile), Text(user.role)],
        ),
        trailing: Column(
          children: [
            Switch(
              value: user.isActive,
              onChanged: (_) => context.read<UserCubit>().toggleStatus(user),
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _openEditDialog(context, user),
            ),
          ],
        ),
      ),
    );
  }
}

void _openAddDialog(BuildContext context) {
  _userDialog(context);
}

void _openEditDialog(BuildContext context, UserModel user) {
  _userDialog(context, user: user);
}

void _userDialog(BuildContext context, {UserModel? user}) {
  final name = TextEditingController(text: user?.name);
  final email = TextEditingController(text: user?.email);
  final mobile = TextEditingController(text: user?.mobile);
  final role = TextEditingController(text: user?.role);

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(user == null ? "Add User" : "Edit User"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            if (user != null)
              TextField(
                controller: TextEditingController(text: user.employeeId),
                readOnly: true, // 🔒 NOT EDITABLE
                decoration: const InputDecoration(labelText: "Employee ID"),
              ),
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: email,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: mobile,
              decoration: const InputDecoration(labelText: "Mobile"),
            ),
            TextField(
              controller: role,
              decoration: const InputDecoration(labelText: "Role"),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            final cubit = context.read<UserCubit>();

            if (user == null) {
              cubit.addUser(
                UserModel(
                  employeeId: "EMP${DateTime.now().millisecondsSinceEpoch}",
                  name: name.text,
                  email: email.text,
                  mobile: mobile.text,
                  role: role.text,
                  isActive: true,
                ),
              );
            } else {
              cubit.updateUser(
                user.copyWith(
                  name: name.text,
                  email: email.text,
                  mobile: mobile.text,
                  role: role.text,
                ),
              );
            }

            Navigator.pop(context);
          },
          child: const Text("Save"),
        ),
      ],
    ),
  );
}
