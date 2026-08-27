import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../models/user.dart';
import '../dashboard/dashboard_screen.dart';
import 'admin_login_screen.dart';

class AdminUserManagementScreen extends StatefulWidget {
  const AdminUserManagementScreen({super.key});

  @override
  State<AdminUserManagementScreen> createState() =>
      _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState
    extends State<AdminUserManagementScreen> {
  List<User> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    final users = await DatabaseHelper.instance.getAllUSers();
    setState(() {
      _users = users;
      _isLoading = false;
    });
  }

  void _showAddUserDialog() {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    String selectedRole = 'user';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add New User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedRole,
                items: const [
                  DropdownMenuItem(value: 'user', child: Text('User')),
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setDialogState(() => selectedRole = val);
                  }
                },
                decoration: const InputDecoration(labelText: 'Role'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (usernameController.text.isEmpty ||
                    passwordController.text.isEmpty) {
                  return;
                }

                await DatabaseHelper.instance.insertUser(
                  User(
                    username: usernameController.text.trim(),
                    password: passwordController.text.trim(),
                    role: selectedRole,
                  ),
                );

                if (mounted) {
                  Navigator.pop(context);
                  _fetchUsers();
                }
              },
              child: const Text('Add User'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: const Color.fromARGB(255, 5, 2, 59),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout Admin',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminLoginScreen(),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 5, 2, 59),
        onPressed: _showAddUserDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 80), // Padding for FAB space
              itemCount: _users.length + 1, // Extra 1 item for the Enter App button
              itemBuilder: (context, index) {
                // If it's the last item in the list, render the ENTER APP button right under the users
                if (index == _users.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 16.0),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        backgroundColor: const Color.fromARGB(255, 5, 2, 59),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DashboardScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text(
                        'ENTER APP',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                }

                // Render normal User Card items
                final user = _users[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: user.role == 'admin'
                          ? Colors.deepPurple
                          : Colors.blue,
                      child: Icon(
                        user.role == 'admin'
                            ? Icons.admin_panel_settings
                            : Icons.person,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(user.username),
                    subtitle: Text('Role: ${user.role}'),
                    trailing: user.username == 'admin'
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await DatabaseHelper.instance
                                  .deleteUser(user.id!);
                              _fetchUsers();
                            },
                          ),
                  ),
                );
              },
            ),
    );
  }
}