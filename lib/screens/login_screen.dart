import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _coyController = TextEditingController();
  bool _loading = false;
  String? _error;

Future<void> _login() async {
  final coy = _coyController.text.trim();

  if (coy.isEmpty) {
    setState(() => _error = 'Enter your coy number');
    return;
  }

  setState(() {
    _loading = true;
    _error = null;
  });

  try {
    final query = await FirebaseFirestore.instance
        .collection('users')
        .where('coyNumber', isEqualTo: coy)
        .where('active', isEqualTo: true)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      setState(() => _error = 'Invalid or inactive coy number');
      return;
    }

    final doc = query.docs.first;
    final data = doc.data();

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('userId', doc.id);
    await prefs.setString('name', data['name'] ?? '');
    await prefs.setString('coyNumber', data['coyNumber'] ?? '');
    await prefs.setString('role', data['role'] ?? '');

    if (!mounted) return;

    final role = data['role'];

    if (role == 'guard') {
      Navigator.pushReplacementNamed(context, '/guardDashboard');
    } else if (role == 'admin') {
      Navigator.pushReplacementNamed(context, '/adminDashboard');
    } else if (role == 'supervisor') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Supervisor dashboard coming soon')),
      );
    } else {
      setState(() => _error = 'Invalid user role');
    }
  } catch (e) {
    setState(() => _error = 'Login failed: $e');
  } finally {
    if (mounted) {
      setState(() => _loading = false);
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _coyController,
                decoration: const InputDecoration(
                  labelText: 'Please enter Coy Number to proceed',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              if (_error != null)
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loading ? null : _login,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}