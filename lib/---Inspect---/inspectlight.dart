import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '/services/auth_service.dart';


class InspectLightPage extends StatefulWidget {
  final int assetId;
  final String assetName;

  const InspectLightPage({
    super.key,
    required this.assetId,
    required this.assetName,
  });

  @override
  State<InspectLightPage> createState() => _InspectFirePageState();
}

class _InspectFirePageState extends State<InspectLightPage> {
  bool isLoading = true;
  List<dynamic> checklist = [];

  /// checklistId -> true(ผ่าน) / false(ไม่ผ่าน)
  final Map<int, bool> selectedResult = {};

  /// 🔥 checklist ของถังนั้นจริง ๆ
  String get checklistApi =>
      'https://api.jaroonrat.com/safetyaudit/api/checklist/7/${widget.assetId}';

  @override
  void initState() {
    super.initState();
    fetchChecklist();
  }

  /// 🔽 โหลด checklist ตาม assetId
  Future<void> fetchChecklist() async {
    try {
      setState(() => isLoading = true);

      final res = await http.get(
        Uri.parse(checklistApi),
        headers: {
          'Authorization': 'Bearer ${AuthService.token}',
        },
      );

      if (res.statusCode == 200) {
        setState(() {
          checklist = jsonDecode(res.body);
          isLoading = false;
        });
      } else {
        isLoading = false;
        _showError('โหลด checklist ไม่สำเร็จ (${res.statusCode})');
      }
    } catch (e) {
      isLoading = false;
      _showError('เชื่อมต่อเซิร์ฟเวอร์ไม่ได้');
    }
  }

  /// 🔥 ส่งข้อมูลตรวจสอบ
  Future<void> submitAudit() async {
    if (selectedResult.length != checklist.length) {
      _showError('กรุณาตรวจสอบให้ครบทุกข้อ');
      return;
    }

    /// ✅ PAYLOAD ตรง backend (Postman)
    final payload = {
      "assetid": widget.assetId,
      "remark": "ทดสอบ",
      "ans": checklist.map((item) {
        final int id = item['id'];
        final bool isPass = selectedResult[id] ?? false;

        return {
          "id": id,
          "status": isPass ? 1 : 2, // 1 = ผ่าน, 2 = ไม่ผ่าน
        };
      }).toList(),
    };

    debugPrint('📦 PAYLOAD => ${jsonEncode(payload)}');

    try {
      final res = await http.post(
        Uri.parse(
          'https://api.jaroonrat.com/safetyaudit/api/submitaudit',
        ),
        headers: {
          'Authorization': 'Bearer ${AuthService.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      debugPrint('STATUS => ${res.statusCode}');
      debugPrint('BODY => ${res.body}');

      if (res.statusCode == 200) {
        if (!mounted) return;

        /// 📋 เตรียมข้อมูลไปหน้า detail
        final detailResult = checklist.map<Map<String, dynamic>>((item) {
          final int id = item['id'];
          return {
            "name": item['name'],
            "answer": selectedResult[id]!
                ? item['detail_Y']
                : item['detail_N'],
          };
        }).toList();

      } else {
        _showError('บันทึกไม่สำเร็จ (${res.statusCode})');
      }
    } catch (e) {
      _showError('เชื่อมต่อเซิร์ฟเวอร์ไม่ได้');
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  void _confirmCancel() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('ยืนยันการยกเลิก'),
        content: const Text('ข้อมูลที่กรอกจะไม่ถูกบันทึก'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ไม่ยกเลิก'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text(
              'ยกเลิก',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(widget.assetName),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: checklist.length,
                    itemBuilder: (_, i) {
                      final item = checklist[i];
                      final int id = item['id'];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 10),

                            /// ✅ ผ่าน
                            InkWell(
                              onTap: () =>
                                  setState(() => selectedResult[id] = true),
                              child: Row(
                                children: [
                                  Icon(
                                    selectedResult[id] == true
                                        ? Icons.check_circle
                                        : Icons.radio_button_unchecked,
                                    color: Colors.green,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(item['detail_Y']),
                                ],
                              ),
                            ),

                            const SizedBox(height: 8),

                            /// ❌ ไม่ผ่าน
                            InkWell(
                              onTap: () =>
                                  setState(() => selectedResult[id] = false),
                              child: Row(
                                children: [
                                  Icon(
                                    selectedResult[id] == false
                                        ? Icons.cancel
                                        : Icons.radio_button_unchecked,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(item['detail_N']),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                /// 🔘 ปุ่มล่าง
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _confirmCancel,
                          child: const Text('ยกเลิก'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: submitAudit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text('บันทึก'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
