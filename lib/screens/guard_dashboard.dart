import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'scan_screen.dart';

class GuardDashboard extends StatefulWidget {
  final String guardId;
  final String guardName;
  final String coyNumber;

  const GuardDashboard({
    super.key,
    required this.guardId,
    required this.guardName,
    required this.coyNumber,
  });

  @override
  State<GuardDashboard> createState() => _GuardDashboardState();
}

class _GuardDashboardState extends State<GuardDashboard> {
  Map<String, dynamic>? latestScan;
  int validScansToday = 0;
  int invalidScansToday = 0;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadPatrolStats();
  }

  Future<void> _loadPatrolStats() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    // Latest scan
    final latestDoc = await firestore
        .collection('patrol_logs')
        .where('guardId', isEqualTo: widget.guardId)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    // Today's scans
    final todayDocs = await firestore
        .collection('patrol_logs')
        .where('guardId', isEqualTo: widget.guardId)
        .where(
          'timestamp',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
        )
        .get();

    int valid = 0;
    int invalid = 0;

    for (var doc in todayDocs.docs) {
      final status = doc.data()['status'] ?? 'invalid';
      if (status == 'valid') {
        valid++;
      } else {
        invalid++;
      }
    }

    setState(() {
      latestScan =
          latestDoc.docs.isNotEmpty ? latestDoc.docs.first.data() : null;
      validScansToday = valid;
      invalidScansToday = invalid;
    });
  }

  Future<void> _startScan() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScanScreen(
          guardId: widget.guardId,
          guardName: widget.guardName,
          coyNumber: widget.coyNumber,
        ),
      ),
    );

    if (result == true) {
      await _loadPatrolStats();
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = latestScan?['status'] ?? 'valid';
    final location = latestScan?['location'];
    final timestamp = latestScan?['timestamp'];

    String locationText = "Unknown location";
    if (location != null &&
        location['latitude'] != null &&
        location['longitude'] != null) {
      locationText =
          "${location['latitude'].toStringAsFixed(5)}, ${location['longitude'].toStringAsFixed(5)}";
    }

    String timeText = "Unknown time";
    if (timestamp != null && timestamp is Timestamp) {
      timeText = timestamp.toDate().toString();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Guard Dashboard - ${widget.guardName}'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadPatrolStats,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text("Scan Checkpoint"),
              onPressed: _startScan,
            ),
            const SizedBox(height: 24),

            // Latest Scan Card
            Card(
              color: status == 'invalid' ? Colors.red[100] : null,
              child: ListTile(
                title: const Text("Latest Scan"),
                subtitle: latestScan != null
                    ? Text(
                        "${latestScan!['description'] ?? 'No description'}\n"
                        "Checkpoint: ${latestScan!['checkpointId'] ?? 'Unknown'}\n"
                        "Location: $locationText\n"
                        "Time: $timeText",
                      )
                    : const Text("No scans yet"),
              ),
            ),

            const SizedBox(height: 16),

            // Stats Card
            Card(
              child: ListTile(
                title: const Text("Scans Today"),
                subtitle: Text(
                  "Valid: $validScansToday\nInvalid: $invalidScansToday",
                  style: TextStyle(
                    color: invalidScansToday > 0 ? Colors.red : null,
                    fontWeight: invalidScansToday > 0
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}