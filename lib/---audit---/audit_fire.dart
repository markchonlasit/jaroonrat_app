import 'package:flutter/material.dart';

class AuditFirePage extends StatelessWidget {
  final int assetId;

  const AuditFirePage({super.key, required this.assetId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text(
          'รายการที่ตรวจสอบแล้ว',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Center(
        child: Text(
          'Asset ID ที่ตรวจสอบแล้ว: $assetId',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
