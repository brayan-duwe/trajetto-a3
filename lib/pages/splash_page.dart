import 'package:flutter/material.dart';
import 'login_page.dart'; // ou a página para onde você quer redirecionar

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF252121), // cor do fundo
      body: Center(
        child: Image.asset(
          'assets/logo_branca.png', // sua logo aqui
          width: 180,
        ),
      ),
    );
  }
}
