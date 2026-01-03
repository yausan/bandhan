class User {
  final String name;
  final String email;
  final String password;

  User({required this.name, required this.email, required this.password});

  // Optional: for convenience
  User copyWith({String? name, String? email, String? password}) {
    return User(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }

  @override
  String toString() {
    return 'User(name: $name, email: $email)';
  }
}
