import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '/services/auth_service.dart';
import '/---audit---/audit_fire.dart';

class InspectFirePage extends StatefulWidget {
  final int assetId;
  final String assetName;

  const InspectFirePage({
    super.key,
    required this.assetId,
    required this.assetName,
  });

  @override
  State<InspectFirePage> createState() => _InspectFirePageState();
}

class _InspectFirePageState extends State<InspectFirePage> {
  bool isLoading = true;
  bool isSubmitting = false;
  String errorMessage = '';
  List checklist = [];

  /// checklistId : true(Y) / false(N)
  Map<int, bool> selectedResult = {};

  /// ✅ API ตรวจสอบ
  final String apiChecklist =
      'https://api.jaroonrat.com/safetyaudit/api/checklist/0/1';

  /// ✅ API บันทึกผล
  final String apiSubmit =
      'https://api.jaroonrat.com/safetyaudit/api/submitaudit';

  @override
  void initState() {
    super.initState();
    fetchChecklist();
  }

  /// 🔹 ดึงหัวข้อการตรวจสอบ
  Future<void> fetchChecklist() async {
    try {
      final response = await http.get(
        Uri.parse('$apiChecklist${widget.assetId}'),
        headers: {
          'Authorization': 'Bearer ${AuthService.token}',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          checklist = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'โหลดข้อมูลไม่สำเร็จ (${response.statusCode})';
          isLoading = false;
        });
      }
    } catch (_) {
      setState(() {
        errorMessage = 'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้';
        isLoading = false;
      });
    }
  }

  /// 🔹 บันทึกผลการตรวจสอบ
  Future<void> submitAudit() async {
    if (selectedResult.length != checklist.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาตรวจสอบให้ครบทุกข้อ')),
      );
      return;
    }

    setState(() => isSubmitting = true);

    final payload = {
      "assetid": widget.assetId,
      "detail": selectedResult.entries.map((e) {
        return {
          "checklist_id": e.key,
          "result": e.value ? "Y" : "N",
        };
      }).toList(),
    };

    try {
      final response = await http.post(
        Uri.parse(apiSubmit),
        headers: {
          'Authorization': 'Bearer ${AuthService.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;

        /// ✅ ไปหน้า audit_fire.dart
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AuditFirePage(assetId: widget.assetId),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('บันทึกไม่สำเร็จ (${response.statusCode})')),
        );
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('เกิดข้อผิดพลาดในการบันทึก')),
      );
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  /// 🔹 popup ยกเลิก
  void showCancelDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('ยืนยันการยกเลิก'),
        content: const Text('คุณต้องการยกเลิกการตรวจสอบครั้งนี้หรือไม่'),
        actions: [
          TextButton(
            child: const Text('ยกเลิก'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('ยืนยัน'),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      /// 🔴 ใช้ชื่อถังจาก fire.dart
      appBar: AppBar(
        backgroundColor: Colors.red,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.assetName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: checklist.length,
                        itemBuilder: (context, index) {
                          final item = checklist[index];
                          final id = item['id'];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border:
                                  Border.all(color: Colors.red, width: 1.5),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['name'],
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                RadioListTile<bool>(
                                  title: Text(item['detail_Y']),
                                  value: true,
                                  groupValue: selectedResult[id],
                                  onChanged: (val) {
                                    setState(() {
                                      selectedResult[id] = val!;
                                    });
                                  },
                                ),
                                RadioListTile<bool>(
                                  title: Text(item['detail_N']),
                                  value: false,
                                  groupValue: selectedResult[id],
                                  onChanged: (val) {
                                    setState(() {
                                      selectedResult[id] = val!;
                                    });
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    /// 🔴 ปุ่มล่าง
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: showCancelDialog,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                              ),
                              child: const Text('ยกเลิก'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isSubmitting ? null : submitAudit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: isSubmitting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'บันทึก',
                                      style: TextStyle(color: Colors.white),
                                    ),
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
