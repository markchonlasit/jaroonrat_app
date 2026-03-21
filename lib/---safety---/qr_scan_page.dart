import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '/services/api_services.dart';

import 'audit.dart';

class QrScanPage extends StatefulWidget {
  const QrScanPage({super.key});

  @override
  State<QrScanPage> createState() => _QrScanPageState();
}

class _QrScanPageState extends State<QrScanPage> {
  bool scanned = false;

  Future<void> _openAsset(int assetId) async {
    try {
      /// 1️⃣ ดึง asset
      final asset = await ApiService.getAsset(assetId);

      final String categoryName = asset['categoryname'];
      final String assetName = asset['name'];

      /// 2️⃣ ดึง category
      final categories = await ApiService.getCategory();

      int categoryId = 0;

      for (var c in categories) {
        if (c['name'] == categoryName) {
          categoryId = c['id'];
          break;
        }
      }

      /// 3️⃣ เปิดหน้า Audit
      await Navigator.push(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
          builder: (_) => AuditPage(
            assetId: assetId,
            categoryId: categoryId,
            assetName: assetName,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        // ignore: use_build_context_synchronously
        context,
      ).showSnackBar(const SnackBar(content: Text("ไม่พบข้อมูลอุปกรณ์")));
    }

    /// reset scanner เมื่อกลับมา
    setState(() {
      scanned = false;
    });
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
            child: Stack(
              alignment: Alignment.center,
              children: [
                MobileScanner(
                  onDetect: (BarcodeCapture capture) {
                    if (scanned) return;

                    final List<Barcode> barcodes = capture.barcodes;

                    for (final barcode in barcodes) {
                      final String? value = barcode.rawValue;

                      if (value != null) {
                        int? id = int.tryParse(value);

                        if (id == null) return;

                        scanned = true;

                        _openAsset(id);

                        break;
                      }
                    }
                  },
                ),

                /// กรอบสแกน
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),

                Positioned.fill(
                  child: CustomPaint(painter: ScannerOverlayPainter()),
                ),
              ],
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

class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double scanSize = 250;
    double left = (size.width - scanSize) / 2;
    double top = (size.height - scanSize) / 2;

    Paint paint = Paint()
      ..color = Colors.cyan
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    double corner = 30;

    canvas.drawLine(Offset(left, top), Offset(left + corner, top), paint);
    canvas.drawLine(Offset(left, top), Offset(left, top + corner), paint);

    canvas.drawLine(
      Offset(left + scanSize, top),
      Offset(left + scanSize - corner, top),
      paint,
    );
    canvas.drawLine(
      Offset(left + scanSize, top),
      Offset(left + scanSize, top + corner),
      paint,
    );

    canvas.drawLine(
      Offset(left, top + scanSize),
      Offset(left + corner, top + scanSize),
      paint,
    );
    canvas.drawLine(
      Offset(left, top + scanSize),
      Offset(left, top + scanSize - corner),
      paint,
    );

    canvas.drawLine(
      Offset(left + scanSize, top + scanSize),
      Offset(left + scanSize - corner, top + scanSize),
      paint,
    );
    canvas.drawLine(
      Offset(left + scanSize, top + scanSize),
      Offset(left + scanSize, top + scanSize - corner),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
