import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirestoreTest extends StatefulWidget {
  const FirestoreTest({super.key});

  @override
  State<FirestoreTest> createState() => _FirestoreTestState();
}

class _FirestoreTestState extends State<FirestoreTest> {
  String _result = 'Press Test to query Firestore';

  Future<void> _testQuery() async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('guards')
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        setState(() => _result = 'No documents found in guards');
        return;
      }

      final doc = query.docs.first;
      setState(() => _result = 'Found: ${doc.data()}');
    } catch (e) {
      setState(() => _result = 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firestore Test'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_result),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _testQuery,
              child: const Text('Test Firestore Query'),
            ),
          ],
        ),
      ),
    );
  }
}