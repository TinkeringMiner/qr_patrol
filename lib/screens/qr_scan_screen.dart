import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class QRScanScreen extends StatefulWidget {
  final String guardId;
  final String guardName;
  final String coyNumber;

  const QRScanScreen({
    Key? key,
    required this.guardId,
    required this.guardName,
    required this.coyNumber,
  }) : super(key: key);

  @override
  State<QRScanScreen> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool scanned = false;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future<void> _handleScan(String code) async {
    if (scanned) return;
    scanned = true;

    try {
      // 1️⃣ Capture geolocation (no permission prompts)
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // 2️⃣ Validate checkpoint
      DocumentSnapshot checkpointDoc =
          await firestore.collection('checkpoints').doc(code).get();

      bool isValid = checkpointDoc.exists;
      String description = isValid ? "Valid scan" : "Invalid QR code";

      // 3️⃣ Save scan to patrol_logs
      await firestore.collection('patrol_logs').add({
        "guardId": widget.guardId,
        "guardName": widget.guardName,
        "coyNumber": widget.coyNumber,
        "checkpointId": code,
        "timestamp": FieldValue.serverTimestamp(),
        "location": {
          "latitude": position.latitude,
          "longitude": position.longitude,
        },
        "status": isValid ? "valid" : "invalid",
        "description": description,
      });

      // 4️⃣ Show confirmation
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(description),
            duration: const Duration(seconds: 2),
          ),
        );
      }

      // 5️⃣ Return to dashboard after short delay
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.pop(context, true);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error scanning: $e"),
            duration: const Duration(seconds: 3),
          ),
        );
      }
      scanned = false; // allow retry
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan QR Checkpoint")),
      body: QRView(
        key: qrKey,
        onQRViewCreated: (controller) {
          this.controller = controller;
          controller.scannedDataStream.listen((scanData) {
            if (scanData.code != null) _handleScan(scanData.code!);
          });
        },
        overlay: QrScannerOverlayShape(
          borderColor: Colors.blue,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: 250,
        ),
      ),
    );
  }
}