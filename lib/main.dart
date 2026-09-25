import 'package:flutter/material.dart';
import 'package:umkm_app/screens/auth/login_screen.dart';
import 'package:umkm_app/screens/auth/register_screen.dart';
import 'package:umkm_app/screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi SI FIK UBL',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterPage(),
      },
    );
  }
}