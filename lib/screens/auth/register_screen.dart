import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'login_screen.dart';
import 'package:bandhan/data/model/user_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign Up"),
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Name Field
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Full Name",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
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
                    return "Please enter your name";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

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

              // Register Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // Open Hive box
                      var box = await Hive.openBox<UserModel>('users');

                      // Create new user
                      var user = UserModel(
                        name: nameController.text.trim(),
                        email: emailController.text.trim(),
                        password: passwordController.text.trim(),
                      );

                      // Save user in Hive using email as key
                      await box.put(user.email, user);

                      // Navigate to Login screen
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
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
                  child: const Text("Sign Up"),
                ),
              ),
              const SizedBox(height: 20),

              // Navigate to Login
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                child: const Text.rich(
                  TextSpan(
                    text: "Already have an account? ",
                    style: TextStyle(fontFamily: 'OpenSans', fontSize: 16),
                    children: [
                      TextSpan(
                        text: "Login",
                        style: TextStyle(
                          fontFamily: 'OpenSans',
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
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
