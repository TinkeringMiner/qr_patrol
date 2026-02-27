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
        // Use onGenerateRoute for routes that need parameters
      },

      // Use onGenerateRoute for dynamic parameter passing
      onGenerateRoute: (settings) {
        if (settings.name == '/guardDashboard') {
          final args = settings.arguments as Map<String, dynamic>?;

          if (args == null) {
            // Fallback dummy values (for testing)
            return MaterialPageRoute(
              builder: (_) => const GuardDashboard(
                guardId: 'dummyId',
                guardName: 'John Doe',
                coyNumber: 'C001',
              ),
            );
          }

          return MaterialPageRoute(
            builder: (_) => GuardDashboard(
              guardId: args['guardId'],
              guardName: args['guardName'],
              coyNumber: args['coyNumber'],
            ),
          );
        }

        if (settings.name == '/adminDashboard') {
          return MaterialPageRoute(builder: (_) => const AdminDashboard());
        }

        if (settings.name == '/supervisorDashboard') {
          return MaterialPageRoute(builder: (_) => const SupervisorDashboard());
        }

        return null; // Unknown route
      },

      initialRoute: '/',
    );
  }
}