import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import 'admin_login_screen.dart';
import '../dashboard/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both username and password'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final user = await DatabaseHelper.instance.loginUser(username, password);

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (user != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Welcome back, ${user.username}!')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const DashboardScreen(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid username or password'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              children: [
                const SizedBox(height: 50),

                // Matching Icon Style
                const Icon(
                  Icons.agriculture,
                  size: 80,
                  color: Colors.green,
                ),
                const SizedBox(height: 20),

                // Header Titles
                const Text(
                  'Farmer Portal',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Welcome Back Farmer',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 40),

               
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    border: Border.all(color: Colors.green.shade200),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: TextField(
                      controller: _usernameController,
                      style: const TextStyle(color: Colors.green),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Username',
                        hintStyle: TextStyle(color: Colors.green),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Password Field (Identical styling to Admin screen)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    border: Border.all(color: Colors.green.shade200),
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
                        hintText: 'Password',
                        hintStyle: TextStyle(color: Colors.green),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Sign In Button
                GestureDetector(
                  onTap: _isLoading ? null : _handleLogin,
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.green.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              color: Color.fromARGB(255, 16, 6, 51),
                            )
                          : const Text(
                              'Sign In',
                              style: TextStyle(
                                color: Color.fromARGB(255, 16, 6, 51),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // Admin Switch Button
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminLoginScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Admin Portal Login',
                    style: TextStyle(
                      color: Colors.green,
                      decoration: TextDecoration.underline,
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