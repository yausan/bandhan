import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../home/home_screen.dart';
import 'register_screen.dart';
import 'package:bandhan/data/model/user_model.dart';
import 'package:bandhan/core/api_client/api_client.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final ApiClient apiClient = ApiClient();

  bool isLoading = false;

  Future<void> loginUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // 1️⃣ Try API login first
    debugPrint("Attempting API login for: $email");
    try {
      final response = await apiClient.userLogin(
        email: email,
        password: password,
      );

      debugPrint("API Response: ${response.statusCode} | ${response.data}");

      if (response.statusCode == 200) {
        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Login successful (API)")));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
        setState(() => isLoading = false);
        return;
      }
    } catch (e) {
      debugPrint("API login failed: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("API login failed, trying local login..."),
          ),
        );
      }
    }

    // 2️⃣ Fallback to Hive local login
    debugPrint("Trying Hive login for: $email");
    var box = await Hive.openBox<UserModel>('usersBox');
    final user = box.get(email);

    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("User not found (Hive)")));
      setState(() => isLoading = false);
      return;
    }

    if (user.password != password) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Incorrect password (Hive)")),
      );
      setState(() => isLoading = false);
      return;
    }

    // Hive login successful
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Login successful (Hive)")));

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );

    setState(() => isLoading = false);
  }

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
              // Email
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

              // Password
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

              // Login Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : loginUser,
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
                      : const Text("Login"),
                ),
              ),
              const SizedBox(height: 20),

              // Navigate to Register
              TextButton(
                onPressed: () {
                  if (!mounted) return;
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
                    children: [
                      TextSpan(
                        text: "Register",
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
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
