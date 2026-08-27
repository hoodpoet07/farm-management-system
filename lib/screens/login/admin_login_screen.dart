import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../login/login.dart';
import 'admin_user_management_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleAdminLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both username and password')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final user = await DatabaseHelper.instance.loginUser(username, password);

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (user != null && user.role == 'admin') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const AdminUserManagementScreen(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Access Denied: Invalid admin credentials'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 16, 6, 51),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              children: [
                const SizedBox(height: 30),
                const Icon(
                  Icons.admin_panel_settings,
                  size: 80,
                  color: Colors.white,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Admin Portal',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Restricted Access System',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
                const SizedBox(height: 40),

                // Username Field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    border: Border.all(color: Colors.white30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: TextField(
                      controller: _usernameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Admin Username',
                        hintStyle: TextStyle(color: Colors.white54),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Password Field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    border: Border.all(color: Colors.white30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Admin Password',
                        hintStyle: TextStyle(color: Colors.white54),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Login Button
                GestureDetector(
                  onTap: _isLoading ? null : _handleAdminLogin,
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.deepPurpleAccent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Log In as Admin',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}