import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;

import '/services/auth_service.dart';

import '/---Inspect---/inspectfire.dart';
import '/---Inspect---/inspectball.dart';
import '/---Inspect---/inspectfhc.dart';
import '/---Inspect---/inspectalarm.dart';
import '/---Inspect---/inspectsand.dart';
import '/---Inspect---/inspecteyewash.dart';
import '/---Inspect---/inspectlight.dart';

class QrScanPage extends StatefulWidget {
  const QrScanPage({super.key});

  @override
  State<QrScanPage> createState() => _QrScanPageState();
}

class _QrScanPageState extends State<QrScanPage> {
  bool scanned = false;

  Color appBarColor = Colors.cyan;

  Future<void> openAsset(int assetId) async {
    try {
      final res = await http.get(
        Uri.parse("https://api.jaroonrat.com/safetyaudit/api/asset/$assetId"),
        headers: {
          'Authorization': 'Bearer ${AuthService.token}',
        },
      );

      if (res.statusCode != 200) {
        throw Exception("API Error");
      }

      final data = jsonDecode(res.body);

      String assetName = data["name"];

      /// 🔥 FIX category
      String category =
          data["categoryname"].toString().trim().toLowerCase();

      debugPrint("CATEGORY = [$category]");

      Widget page;
      Color color;

      if (category == "ถังดับเพลิง") {
        color = Colors.red;

        page = InspectFirePage(
          assetId: assetId,
          assetName: assetName,
        );
      }

      else if (category == "ลูกบอลดับเพลิง") {
        color = const Color.fromARGB(255, 5, 47, 233);

        page = InspectBallPage(
          assetId: assetId,
          assetName: assetName,
        );
      }

      else if (category == "fhc") {
        color = Colors.deepOrangeAccent;

        page = InspectfhcPage(
          assetId: assetId,
          assetName: assetName,
        );
      }

      else if (category == "สัญญาณเตือนไฟไหม้") {
        color = Colors.orange;

        page = InspectAlarmPage(
          assetId: assetId,
          assetName: assetName,
        );
      }

      else if (category == "ทรายดับเพลิง") {
        color = Colors.brown;

        page = InspectSandPage(
          assetId: assetId,
          assetName: assetName,
        );
      }

      else if (category == "ที่ล้างตา") {
        color = Colors.blue;

        page = InspectEyewashPage(
          assetId: assetId,
          assetName: assetName,
        );
      }

      else {
        color = Colors.green;

        page = InspectLightPage(
          assetId: assetId,
          assetName: assetName,
        );
      }

      if (!mounted) return;

      setState(() {
        appBarColor = color;
      });

      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => page),
      );

      scanned = false;

    } catch (e) {

      scanned = false;

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("ไม่พบอุปกรณ์"),
        ),
      );

    }
  }

  void handleQR(String code) {
    if (scanned) return;

    scanned = true;

    debugPrint("QR CODE = $code");

    int assetId = int.parse(code);

    openAsset(assetId);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("สแกน QR Code"),
        backgroundColor: appBarColor,
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

                        handleQR(value);

                        break;

                      }

                    }

                  },
                ),

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

/// วาดมุมกรอบ Scanner
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

    canvas.drawLine(
        Offset(left, top), Offset(left + corner, top), paint);
    canvas.drawLine(
        Offset(left, top), Offset(left, top + corner), paint);

    canvas.drawLine(
        Offset(left + scanSize, top),
        Offset(left + scanSize - corner, top),
        paint);
    canvas.drawLine(
        Offset(left + scanSize, top),
        Offset(left + scanSize, top + corner),
        paint);

    canvas.drawLine(
        Offset(left, top + scanSize),
        Offset(left + corner, top + scanSize),
        paint);
    canvas.drawLine(
        Offset(left, top + scanSize),
        Offset(left, top + scanSize - corner),
        paint);

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