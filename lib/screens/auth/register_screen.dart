import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'login_screen.dart';
import 'package:bandhan/data/model/user_model.dart';
import 'package:bandhan/core/api_client/api_client.dart';

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
  final ApiClient apiClient = ApiClient();

  bool isLoading = false;

  Future<void> registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    debugPrint("Attempting API registration for: $email");

    // 1️⃣ Try API registration
    try {
      final response = await apiClient.userRegister(
        name: name,
        email: email,
        password: password,
      );

      debugPrint("API Response: ${response.data}");

      if (response.data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.data['message'] ?? "Sign up successful"),
          ),
        );

        // Optional: Save to Hive for offline fallback
        var box = await Hive.openBox<UserModel>('usersBox');
        var user = UserModel(name: name, email: email, password: password);
        await box.put(email, user);

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      } else {
        throw Exception(response.data['message'] ?? "API failed");
      }
    } catch (e) {
      debugPrint("API registration failed: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("API failed: $e\nUsing local registration..."),
          ),
        );
      }

      // 2️⃣ Fallback to Hive registration
      var box = await Hive.openBox<UserModel>('usersBox');

      if (box.containsKey(email)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User already exists locally")),
        );
        setState(() => isLoading = false);
        return;
      }

      var user = UserModel(name: name, email: email, password: password);
      await box.put(email, user);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sign up successful (Hive fallback)")),
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }

    setState(() => isLoading = false);
  }

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
                ),
                validator: (value) => (value == null || value.isEmpty)
                    ? "Please enter name"
                    : null,
              ),
              const SizedBox(height: 20),

              // Email Field
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) => (value == null || value.isEmpty)
                    ? "Please enter email"
                    : null,
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
                ),
                validator: (value) => (value == null || value.isEmpty)
                    ? "Please enter password"
                    : null,
              ),
              const SizedBox(height: 30),

              // Register Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : registerUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text("Sign Up"),
                ),
              ),
              const SizedBox(height: 20),

              // Navigate to Login
              TextButton(
                onPressed: () {
                  if (!mounted) return;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                child: const Text("Already have an account? Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
