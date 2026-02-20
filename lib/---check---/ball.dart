import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '/services/auth_service.dart';
import '/---Inspect---/inspectball.dart';
import '/---audit---/audit_ball_detail.dart';

class BallPage extends StatefulWidget {
  const BallPage({super.key});

  @override
  State<BallPage> createState() => _BallPageState();
}

class _BallPageState extends State<BallPage> {
  bool isLoading = true;
  String errorMessage = '';
  List fireList = [];
  String keyword = '';

  final String apiUrl =
      'https://api.jaroonrat.com/safetyaudit/api/assetlist/1';

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
          fireList = data['asset'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage =
              'โหลดข้อมูลไม่สำเร็จ (${response.statusCode})';
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
    switch (type.toLowerCase()) {
      case 'เขียว':
        return Colors.green;
      case 'แดง':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        onChanged: (v) => setState(() => keyword = v),
        decoration: InputDecoration(
          hintText: 'ค้นหา',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = fireList.where((item) {
      final name =
          (item['name'] ?? '').toString().toLowerCase();
      final location =
          (item['location'] ?? '').toString().toLowerCase();
      final branch =
          (item['branch'] ?? '').toString().toLowerCase();
      final type =
          (item['type'] ?? '').toString().toLowerCase();

      final search = keyword.toLowerCase();

      return name.contains(search) ||
          location.contains(search) ||
          branch.contains(search) ||
          type.contains(search);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor:
            const Color.fromARGB(255, 5, 47, 233),
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'ลูกบอลดับเพลิงทั้งหมด',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AuditBallDetailPage(
                    auditedAssetIds: [],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    errorMessage,
                    style:
                        const TextStyle(color: Colors.red),
                  ),
                )
              : Column(
                  children: [
                    _searchBar(),
                    Expanded(
                      child: ListView.builder(
                        padding:
                            const EdgeInsets.all(12),
                        itemCount:
                            filteredList.length,
                        itemBuilder:
                            (context, index) {
                          final item =
                              filteredList[index];

                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      InspectBallPage(
                                    assetId:
                                        item['id'],
                                    assetName:
                                        item['name'] ?? '-',
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.all(12),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(14),

                                /// ✅ กรอบสีดำทั้งหมด
                                border: Border.all(
                                  color: Colors.black,
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.sports_baseball,
                                    color: _getColorByType(
                                        item['type']),
                                    size: 40,
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['name'] ?? '-',
                                          style:
                                              const TextStyle(
                                            fontSize: 15,
                                            fontWeight:
                                                FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                            'ID: ${item['id']}'),
                                        Text(
                                            'สาขา: ${item['branch']}'),
                                        Text(
                                            'วันหมดอายุ: ${item['expdate'] ?? '-'}'),
                                        Text(
                                            'สถานที่: ${item['location']}'),

                                        /// ✅ สีข้อความตามสีลูกบอล
                                        Text(
                                          'ประเภทสีของลูกบอล: ${item['type']}',
                                          style: TextStyle(
                                            color: _getColorByType(
                                                item['type']),
                                            fontWeight:
                                                FontWeight.bold,
                                          ),
                                        ),

                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Icon(
                                              item['active'] == 1
                                                  ? Icons
                                                      .check_circle
                                                  : Icons
                                                      .cancel,
                                              size: 16,
                                              color:
                                                  item['active'] == 1
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
                    ),
                  ],
                ),
    );
  }
}
