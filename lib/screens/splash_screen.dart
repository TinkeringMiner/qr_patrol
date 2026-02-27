import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  // 🔹 Auto-login logic
  Future<void> _checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('role');

    await Future.delayed(const Duration(seconds: 2)); // optional splash delay

    if (!mounted) return;

    switch (role) {
      case 'guard':
        Navigator.pushReplacementNamed(context, '/guardDashboard');
        break;
      case 'admin':
        Navigator.pushReplacementNamed(context, '/adminDashboard');
        break;
      case 'supervisor':
        Navigator.pushReplacementNamed(context, '/supervisorDashboard');
        break;
      default:
        Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.security, size: 80, color: Colors.blue),
            SizedBox(height: 20),
            Text(
              'QR Patrol App',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}