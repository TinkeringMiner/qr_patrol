import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String name = "";

  @override
  void initState() {
    super.initState();
    _protectRoute();  // ✅ Added route protection
    _loadUser();
  }

  // 🔐 Route protection
  Future<void> _protectRoute() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('role');

    if (role != 'admin') {
      Navigator.pushReplacementNamed(context, '/login'); // redirect if not admin
    }
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? "";
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Dashboard")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome, $name",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            const Text("Admin Functions (MVP Placeholder)",
                style: TextStyle(fontSize: 18)),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {},
              child: const Text("Manage Guards"),
            ),

            ElevatedButton(
              onPressed: () {},
              child: const Text("Manage Checkpoints"),
            ),

            ElevatedButton(
              onPressed: () {},
              child: const Text("View Patrol Logs"),
            ),

            const Spacer(),

            ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}
