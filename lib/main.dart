import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trajetto/pages/dashboard_page.dart';
import 'package:trajetto/pages/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ycfppkiisfusoxcoqrlv.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InljZnBwa2lpc2Z1c294Y29xcmx2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk2NzYwNjcsImV4cCI6MjA2NTI1MjA2N30.KW9u9WcXRDaV3N9LJH49dXO2VphjqJSHUgkyBNLu0Wk',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const SplashScreen(),
    );
  }
}
