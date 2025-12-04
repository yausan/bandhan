import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const BandhanApp());
}

class BandhanApp extends StatelessWidget {
  const BandhanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bandhan',
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
