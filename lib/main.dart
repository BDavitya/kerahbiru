import 'package:flutter/material.dart';
import 'views/splash_screen.dart';

void main() {
  runApp(const KerahBiruApp());
}

class KerahBiruApp extends StatelessWidget {
  const KerahBiruApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KerahBiru',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0A73FF)),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      home: const SplashScreen(),
    );
  }
}
