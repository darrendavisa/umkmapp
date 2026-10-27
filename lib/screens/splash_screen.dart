import 'package:flutter/material.dart';
import '../services/token_storage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _cekTokenTersimpan();
  }

  Future<void> _cekTokenTersimpan() async {
    final token = await TokenStorage.ambil();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, token == null ? '/login' : '/home');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.indigo,
      body: Center(child: CircularProgressIndicator(color: Colors.white)),
    );
  }
}