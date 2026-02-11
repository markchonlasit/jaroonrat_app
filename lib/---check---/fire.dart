import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '/services/auth_service.dart';
import '/---Inspect---/inspectfire.dart';
import '/---audit---/audit_fire_detail.dart';

class FirePage extends StatefulWidget {
  const FirePage({super.key});

  @override
  State<FirePage> createState() => _FirePageState();
}

class _FirePageState extends State<FirePage> {
  bool isLoading = true;
  String errorMessage = '';
  List fireList = [];
  String keyword = '';

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
        fireList = data['asset'] ?? [];
      } else {
        errorMessage = 'โหลดข้อมูลไม่สำเร็จ (${response.statusCode})';
      }
    } catch (e) {
      errorMessage = 'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้';
    }

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

  // ✅ SEARCH BAR
  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
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
          ),
          const SizedBox(width: 8),
          _squareIcon(Icons.build),
          const SizedBox(width: 8),
          _squareIcon(Icons.tune),
        ],
      ),
    );
  }

  Widget _squareIcon(IconData icon) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ filter list ตาม keyword
    final filteredList = fireList.where((item) {
      final name = (item['name'] ?? '').toString().toLowerCase();
      final location = (item['location'] ?? '').toString().toLowerCase();
      final branch = (item['branch'] ?? '').toString().toLowerCase();

      return name.contains(keyword.toLowerCase()) ||
          location.contains(keyword.toLowerCase()) ||
          branch.contains(keyword.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text(
          'ถังดับเพลิงทั้งหมด',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AuditFireDetailPage(
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
              ? Center(child: Text(errorMessage))
              : Column(
                  children: [
                    _searchBar(), // ✅ ใส่ searchBar ตรงนี้
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final item = filteredList[index];

                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => InspectFirePage(
                                    assetId: item['id'],
                                    assetName:
                                        item['name'] ?? 'ถังดับเพลิง',
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              margin:const EdgeInsets.all(12),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(14),
                                border: Border.all(
                                  color: _getColorByType(
                                      item['type']),
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.fire_extinguisher,
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
                                          style: const TextStyle(
                                              fontWeight:
                                                  FontWeight.bold),
                                        ),
                                        Text('ID: ${item['id']}'),
                                        Text(
                                            'สาขา: ${item['branch']}'),
                                        Text('วันหมดอายุ : ${item['expdate'] ?? '-'}'),
                                        Text(
                                            'สถานที่: ${item['location']}'),
                                        Text(
                                            'ประเภท: ${item['type']}'),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Icon(
                                              item['active'] == 1
                                                  ? Icons
                                                      .check_circle
                                                  : Icons.cancel,
                                              size: 16,
                                              color: item['active'] ==
                                                      1
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
