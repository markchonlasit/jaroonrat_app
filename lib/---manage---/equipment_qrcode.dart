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

  Future<void> _openAsset(int id) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EquipmentViewPage(assetId: id),
      ),
    );

    // reset scanner when return
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
                        scanned = true;

                        int id = int.parse(value);
                        _openAsset(id);
                        break;
                      }
                    }
                  },
                ),

                /// QR Scan Frame (กรอบตรงกลาง)
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),

                /// มุมกรอบแบบในรูป
                Positioned.fill(
                  child: CustomPaint(
                    painter: ScannerOverlayPainter(),
                  ),
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

    /// top-left
    canvas.drawLine(
        Offset(left, top), Offset(left + corner, top), paint);
    canvas.drawLine(
        Offset(left, top), Offset(left, top + corner), paint);

    /// top-right
    canvas.drawLine(
        Offset(left + scanSize, top),
        Offset(left + scanSize - corner, top),
        paint);
    canvas.drawLine(
        Offset(left + scanSize, top),
        Offset(left + scanSize, top + corner),
        paint);

    /// bottom-left
    canvas.drawLine(
        Offset(left, top + scanSize),
        Offset(left + corner, top + scanSize),
        paint);
    canvas.drawLine(
        Offset(left, top + scanSize),
        Offset(left, top + scanSize - corner),
        paint);

    /// bottom-right
    canvas.drawLine(
        Offset(left + scanSize, top + scanSize),
        Offset(left + scanSize - corner, top + scanSize),
        paint);
    canvas.drawLine(
        Offset(left + scanSize, top + scanSize),
        Offset(left + scanSize, top + scanSize - corner),
        paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}