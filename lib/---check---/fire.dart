import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '/services/auth_service.dart';
import '/---Inspect---/inspectfire.dart';

class FirePage extends StatefulWidget {
  const FirePage({super.key});

  @override
  State<FirePage> createState() => _FirePageState();
}

class _FirePageState extends State<FirePage> {
  bool isLoading = true;
  String errorMessage = '';
  List fireList = [];

  final String apiUrl =
      'https://api.jaroonrat.com/safetyaudit/api/assetlist/0';

  @override
  void initState() {
    super.initState();
    fetchFire();
  }

  Future<void> fetchFire() async {
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer ${AuthService.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          fireList = data['asset'];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'โหลดข้อมูลไม่สำเร็จ (${response.statusCode})';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้';
        isLoading = false;
      });
    }
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
    return Scaffold(
      backgroundColor: Colors.white,

      /// 🔥 APP BAR
      appBar: AppBar(
        backgroundColor: Colors.red,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'ถังดับเพลิงทั้งหมด',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: fireList.length,
                  itemBuilder: (context, index) {
                    final item = fireList[index];

                    return InkWell(
                      borderRadius: BorderRadius.circular(14),

                      /// 👉 ไปหน้า Inspect
                     onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => InspectFirePage(
                            assetId: item['id'],
                            assetName: item['name'] ?? 'ถังดับเพลิง', // ✅ ส่งชื่อถังไปด้วย
                          ),
                      ),
                    );
                },


                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _getColorByType(item['type']),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.fire_extinguisher,
                              color: _getColorByType(item['type']),
                              size: 40,
                            ),
                            const SizedBox(width: 14),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['name'] ?? '-',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),

                                  Text('ID: ${item['id']}'),
                                  Text('สาขา: ${item['branch']}'),
                                  Text('สถานที่: ${item['location']}'),
                                  Text('ประเภทถัง: ${item['type']}'),

                                  const SizedBox(height: 6),

                                  Row(
                                    children: [
                                      Icon(
                                        item['active'] == 1
                                            ? Icons.check_circle
                                            : Icons.cancel,
                                        size: 16,
                                        color: item['active'] == 1
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        item['active'] == 1
                                            ? 'ใช้งานอยู่'
                                            : 'ไม่พร้อมใช้งาน',
                                      ),
                                    ],
                                  ),
                                ],
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
