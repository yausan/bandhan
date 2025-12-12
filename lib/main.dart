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
      theme: ThemeData(
        primaryColor: Colors.redAccent,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'OpenSans',
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
          bodyLarge: TextStyle(fontSize: 16),
          labelLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            textStyle: const TextStyle(
              fontFamily: 'OpenSans',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: Colors.redAccent,
        textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'OpenSans'),
      ),
      themeMode: ThemeMode.system, // respects user device preference
      home: const SplashScreen(),
    );
  }
}
