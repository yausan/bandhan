import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../home/home_screen.dart';
import 'register_screen.dart';
import 'package:bandhan/data/model/user_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
        backgroundColor: Colors.redAccent,
        titleTextStyle: const TextStyle(
          fontFamily: 'OpenSans',
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Email Field
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                  labelStyle: TextStyle(
                    fontFamily: 'OpenSans',
                    fontStyle: FontStyle.italic,
                    fontSize: 16,
                  ),
                ),
                style: const TextStyle(
                  fontFamily: 'OpenSans',
                  fontStyle: FontStyle.italic,
                  fontSize: 16,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter email";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Password Field
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                  labelStyle: TextStyle(
                    fontFamily: 'OpenSans',
                    fontStyle: FontStyle.italic,
                    fontSize: 16,
                  ),
                ),
                style: const TextStyle(
                  fontFamily: 'OpenSans',
                  fontStyle: FontStyle.italic,
                  fontSize: 16,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter password";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),

              // Login Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // Open Hive box
                      var box = await Hive.openBox<UserModel>('usersBox');

                      // Find user by email
                      final user = box.values.firstWhere(
                        (u) => u.email == emailController.text.trim(),
                        orElse: () => UserModel(
                          email: '',
                          password: '',
                          name: '', // Removed 'id' here
                        ),
                      );

                      if (user.email == '') {
                        // User not found
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("User not found")),
                        );
                        return;
                      }

                      if (user.password != passwordController.text.trim()) {
                        // Wrong password
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Incorrect password")),
                        );
                        return;
                      }

                      // Login successful
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    textStyle: const TextStyle(
                      fontFamily: 'OpenSans',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  child: const Text("Login"),
                ),
              ),
              const SizedBox(height: 20),

              // Navigate to Register
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterScreen(),
                    ),
                  );
                },
                child: const Text.rich(
                  TextSpan(
                    text: "Don't have an account? ",
                    style: TextStyle(fontFamily: 'OpenSans', fontSize: 12),
                    children: [
                      TextSpan(
                        text: "Register",
                        style: TextStyle(
                          fontFamily: 'OpenSans',
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
