import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GuardDashboard extends StatefulWidget {
  const GuardDashboard({super.key});

  @override
  State<GuardDashboard> createState() => _GuardDashboardState();
}

class _GuardDashboardState extends State<GuardDashboard> {
  String _guardName = 'Loading...';
  String _coyNumber = '';

  @override
  void initState() {
    super.initState();
    _protectRoute(); // ✅ Route protection
    _loadSession();
  }

  // 🔐 Route protection
  Future<void> _protectRoute() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('role');

    if (role != 'guard') {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login'); // redirect if not guard
    }
  }

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();

    final name = prefs.getString('name');
    final coy = prefs.getString('coyNumber');

    setState(() {
      _guardName = name ?? 'Unknown Guard';
      _coyNumber = coy ?? '';
    });
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guard Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, $_guardName',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Coy: $_coyNumber',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),

            // Patrol Stats Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Patrol Stats',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text('Scans Today: 0'),
                    Text('Last Scan: N/A'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Scan Button
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // QR Scan will be implemented next
                },
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Scan QR Code'),
              ),
            ),

            const Spacer(),

            // 🔴 LOG OUT BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                icon: const Icon(Icons.logout),
                label: const Text('Log Out'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}