import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Patrol Reports")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('patrol_logs')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final logs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              final timestamp =
                  (log['timestamp'] as Timestamp).toDate();

              return ListTile(
                title: Text(log['checkpointName']),
                subtitle: Text(
                    "${log['guardName']} • ${DateFormat('yyyy-MM-dd HH:mm').format(timestamp)}"),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Lat: ${log['latitude']}"),
                    Text("Lng: ${log['longitude']}"),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}