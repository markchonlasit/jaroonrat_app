import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '/services/auth_service.dart';

class AuditAlarmDetailPage extends StatefulWidget {
  const AuditAlarmDetailPage({super.key, required List<dynamic> auditedAssetIds});

  @override
  State<AuditAlarmDetailPage> createState() => _AuditFireDetailPageState();
}

class _AuditFireDetailPageState extends State<AuditAlarmDetailPage> {
  bool isLoading = true;
  List assetList = [];

  final String apiUrl =
      'https://api.jaroonrat.com/safetyaudit/api/audit/3';

  @override
  void initState() {
    super.initState();
    fetchAsset();
  }

  Future<void> fetchAsset() async {
    try {
      final res = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer ${AuthService.token}',
        },
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        assetList = data['asset'] ?? [];
      }
    } catch (_) {}

    setState(() => isLoading = false);
  }

  Color _getColorByType(String type) {
    switch (type) {
      case 'เขียว':
        return Colors.green;
      case 'แดง':
        return Colors.red;
      case 'เงิน':
        return Colors.grey;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateText =
        DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 110, 64),
        title: const Text(
          'รายการสัญญาณเเจ้งเหตุที่ตรวจสอบแล้ว',
         style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: assetList.length,
              itemBuilder: (context, index) {
                final item = assetList[index];

                return InkWell(
                  onTap: () {
                    // 🔜 ต่อไปเอา assetId ไปดึงผลตรวจย้อนหลัง
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _getColorByType(item['type']),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// 🔥 ชื่อถัง
                        Text(
                          item['name'] ?? '-',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),

                        /// 📋 ข้อมูล
                        Text('ID : ${item['id']}'),
                        Text('สาขา : ${item['branch']}'),
                        Text('สถานที่ : ${item['location']}'),
                        Text('ประเภท : ${item['type']}'),

                        const SizedBox(height: 10),

                        /// 🔴 สถานะ
                        Row(
                          children: [
                            Icon(
                              item['active'] == 1
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color: item['active'] == 1
                                  ? Colors.green
                                  : Colors.red,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              item['active'] == 1
                                  ? 'พร้อมใช้งาน'
                                  : 'ไม่พร้อมใช้งาน',
                              style: TextStyle(
                                color: item['active'] == 1
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        /// 📅 วันที่ตรวจ (ขวาล่าง)
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            dateText,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
