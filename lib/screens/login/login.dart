import 'package:flutter/material.dart';
 

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 5, 2, 59),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 25),
              Text(
                'Hello Again',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Colors.white,
                )
              ),
              SizedBox(height: 10),
              Text(
                'Welcome Back Farmer',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                )
              ),
              SizedBox(height: 20),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 5, 2, 59),
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: TextField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Username',
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 5, 2, 59),
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Password',
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal:25.0),
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'Sign In',
                      style: TextStyle(
                        color: Color.fromARGB(255, 5, 2, 59),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        ),
                    ),
                  ),
                ),
              ),
            ],
          )
        )
      ) 
    );
  }
}