import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'equipment_view.dart';

class QrScanPage extends StatefulWidget {
  const QrScanPage({super.key});

  @override
  State<QrScanPage> createState() => _QrScanPageState();
}

class _QrScanPageState extends State<QrScanPage> {
  bool scanned = false;

  void _openAsset(int id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EquipmentViewPage(assetId: id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("สแกน QR Code"),
        backgroundColor: Colors.cyan,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: MobileScanner(
              onDetect: (BarcodeCapture capture) {
                if (scanned) return;

                final List<Barcode> barcodes = capture.barcodes;

                for (final barcode in barcodes) {
                  final String? value = barcode.rawValue;

                  if (value != null) {
                    scanned = true;

                    int id = int.parse(value);

                    _openAsset(id);
                    break;
                  }
                }
              },
            ),
          ),

          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.qr_code_scanner, size: 40),
                  SizedBox(height: 10),
                  Text(
                    "กรุณาสแกน QRCode บนอุปกรณ์",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}