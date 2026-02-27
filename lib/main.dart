import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Screens
import 'screens/login_screen.dart';
import 'screens/guard_dashboard.dart';
import 'screens/admin_dashboard.dart';
import 'screens/splash_screen.dart';
import 'screens/supervisor_dashboard.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // Routes
      routes: {
        '/': (context) => const SplashScreen(),
  '/login': (context) => const LoginScreen(),
  '/guardDashboard': (context) => const GuardDashboard(),
  '/adminDashboard': (context) => const AdminDashboard(),
  '/supervisorDashboard': (context) => const SupervisorDashboard(), 
      },

      initialRoute: '/',
    );
  }
}