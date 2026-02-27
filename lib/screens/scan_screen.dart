import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanScreen extends StatefulWidget {
  final String guardId;
  final String guardName;
  final String coyNumber;

  const ScanScreen({
    super.key,
    required this.guardId,
    required this.guardName,
    required this.coyNumber,
  });

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  bool _isProcessing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleScannedCode(String code) async {
    if (_isProcessing) return;

    _isProcessing = true;

    try {
      // 🔥 Call your existing Firestore validation logic here
      print("Scanned QR: $code");
      print("Guard ID: ${widget.guardId}");
      print("Guard Name: ${widget.guardName}");
      print("Coy Number: ${widget.coyNumber}");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Scanned: $code")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error processing QR")),
      );
    }

    await Future.delayed(const Duration(seconds: 2));
    _isProcessing = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan Checkpoint"),
      ),
      body: MobileScanner(
        controller: _controller,
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;

          for (final barcode in barcodes) {
            final String? code = barcode.rawValue;

            if (code != null) {
              _handleScannedCode(code);
              break; // prevent multiple triggers
            }
          }
        },
      ),
    );
  }
}