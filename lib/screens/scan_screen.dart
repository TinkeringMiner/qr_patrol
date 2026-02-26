import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  bool _isProcessing = false;

  Future<void> _handleScan(String checkpointId, String guardName) async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      // Get checkpoint document
      final checkpointDoc = await FirebaseFirestore.instance
          .collection('checkpoints')
          .doc(checkpointId)
          .get();

      if (!checkpointDoc.exists) {
        throw Exception("Checkpoint not found");
      }

      final checkpointName = checkpointDoc['name'];

      // Get GPS location
      LocationPermission permission =
          await Geolocator.requestPermission();

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception("Location permission denied");
      }

      final position = await Geolocator.getCurrentPosition();

      // Save patrol log
      await FirebaseFirestore.instance.collection('patrol_logs').add({
        'checkpointId': checkpointId,
        'checkpointName': checkpointName,
        'guardName': guardName,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': Timestamp.now(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Scan saved successfully")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }

    _isProcessing = false;
  }

  @override
  Widget build(BuildContext context) {
    final guardName =
        ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(title: const Text("Scan Checkpoint")),
      body: MobileScanner(
        onDetect: (capture) {
          final barcode = capture.barcodes.first;
          final code = barcode.rawValue;

          if (code != null) {
            _handleScan(code, guardName);
          }
        },
      ),
    );
  }
}