import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PatrolLogScreen extends StatefulWidget {
  final String guardId;
  final String guardName;
  final String coyNumber; // optional if you plan to use it

  const PatrolLogScreen({
    Key? key,
    required this.guardId,
    required this.guardName,
    required this.coyNumber,
  }) : super(key: key);

  @override
  State<PatrolLogScreen> createState() => _PatrolLogScreenState();
}

class _PatrolLogScreenState extends State<PatrolLogScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> patrolLogs = [];
  bool loading = true;

  int totalScans = 0;
  int validScans = 0;
  int invalidScans = 0;

  late GoogleMapController mapController;
  final Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    _loadPatrolLogs();
  }

  Future<void> _loadPatrolLogs() async {
    setState(() => loading = true);

    final snapshot = await firestore
        .collection('patrol_logs')
        .where('guardId', isEqualTo: widget.guardId)
        .orderBy('timestamp', descending: true)
        .get();

    patrolLogs = snapshot.docs.map((doc) {
      final data = doc.data();
      final status = data['status'] ?? 'unknown';
      if (status == 'valid') validScans++;
      if (status == 'invalid') invalidScans++;

      if (data['location'] != null) {
        final lat = data['location']['latitude'] as double;
        final lng = data['location']['longitude'] as double;
        markers.add(Marker(
          markerId: MarkerId(doc.id),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(
            title: data['checkpointId'],
            snippet: "${data['status']} - ${data['timestamp']?.toDate()}",
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            status == 'valid'
                ? BitmapDescriptor.hueGreen
                : BitmapDescriptor.hueRed,
          ),
        ));
      }
      return data;
    }).toList();

    totalScans = patrolLogs.length;
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Patrol Logs - ${widget.guardName}"),
      ),
      body: RefreshIndicator(
        onRefresh: _loadPatrolLogs,
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Summary row
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _summaryCard("Total", totalScans, Colors.blue),
                        _summaryCard("Valid", validScans, Colors.green),
                        _summaryCard("Invalid", invalidScans, Colors.red),
                      ],
                    ),
                  ),
                  // Map view
                  SizedBox(
                    height: 300,
                    child: GoogleMap(
                      onMapCreated: (controller) => mapController = controller,
                      initialCameraPosition: CameraPosition(
                        target: patrolLogs.isNotEmpty &&
                                patrolLogs.first['location'] != null
                            ? LatLng(
                                patrolLogs.first['location']['latitude'],
                                patrolLogs.first['location']['longitude'],
                              )
                            : const LatLng(0, 0),
                        zoom: 14,
                      ),
                      markers: markers,
                    ),
                  ),
                  // List of patrol logs
                  Expanded(
                    child: ListView.builder(
                      itemCount: patrolLogs.length,
                      itemBuilder: (context, index) {
                        final log = patrolLogs[index];
                        final status = log['status'] ?? 'unknown';
                        final time =
                            log['timestamp']?.toDate() ?? DateTime.now();
                        return Card(
                          color: status == 'invalid' ? Colors.red[100] : null,
                          child: ListTile(
                            title: Text(
                                "${log['description']} at checkpoint ${log['checkpointId']}"),
                            subtitle: Text(
                                "Time: $time\nLocation: ${log['location']?['latitude']?.toStringAsFixed(5) ?? 'N/A'}, ${log['location']?['longitude']?.toStringAsFixed(5) ?? 'N/A'}"),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _summaryCard(String label, int count, Color color) {
    return Card(
      color: color.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Column(
          children: [
            Text(label,
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: color, fontSize: 16)),
            const SizedBox(height: 4),
            Text(count.toString(),
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}