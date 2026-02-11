import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '/services/auth_service.dart';
import '/---Inspect---/inspecteyewash.dart';

class EyewashPage extends StatefulWidget {
  const EyewashPage({super.key});

  @override
  State<EyewashPage> createState() => _EyewashPageState();
}

class _EyewashPageState extends State<EyewashPage> {
  bool isLoading = true;
  String errorMessage = '';
  List<dynamic> eyewashList = [];

  String keyword = '';

  final String apiUrl =
      'https://api.jaroonrat.com/safetyaudit/api/assetlist/6';

  @override
  void initState() {
    super.initState();
    fetchEyewash();
  }

  Future<void> fetchEyewash() async {
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
          eyewashList = data['asset'] ?? [];
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
        errorMessage = 'เชื่อมต่อเซิร์ฟเวอร์ไม่ได้';
        isLoading = false;
      });
    }
  }

  /// 🔍 Filter List
  List<dynamic> get filteredList {
    if (keyword.isEmpty) return eyewashList;

    return eyewashList.where((item) {
      final name = item['name']?.toString().toLowerCase() ?? '';
      final branch = item['branch']?.toString().toLowerCase() ?? '';
      final location = item['location']?.toString().toLowerCase() ?? '';

      return name.contains(keyword.toLowerCase()) ||
          branch.contains(keyword.toLowerCase()) ||
          location.contains(keyword.toLowerCase());
    }).toList();
  }

  /// 🔍 SearchBar Widget
  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
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
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: const Color(0xFF2196F3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'ที่ล้างตาทั้งหมด',
          style: TextStyle(
            color: Colors.white,
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
              : Column(
                  children: [
                    /// 🔍 SearchBar
                    _searchBar(),

                    /// 📋 List
                    Expanded(
                      child: filteredList.isEmpty
                          ? const Center(child: Text('ไม่พบข้อมูล'))
                          : ListView.builder(
                              padding: const EdgeInsets.all(12),
                              itemCount: filteredList.length,
                              itemBuilder: (context, index) {
                                final item = filteredList[index];

                                return InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            InspectEyewashPage(
                                          assetId: item['id'],
                                          assetName: item['name'] ?? '-',
                                        ),
                                      ),
                                    );
                                  },


                                child : Container(
                                  margin:
                                      const EdgeInsets.all(12),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(14),
                                    border: Border.all(
                                      color: Colors.blue,
                                      width: 2,
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.opacity,
                                        color: Colors.blue,
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
                                                fontSize: 15,
                                                fontWeight:
                                                    FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 6),

                                            Text(
                                                'ID: ${item['id'] ?? '-'}'),
                                            Text(
                                                'สาขา: ${item['branch'] ?? '-'}'),
                                            Text('วันหมดอายุ : ${item['expdate'] ?? '-'}'),
                                            Text(
                                                'สถานที่: ${item['location'] ?? '-'}'),

                                            const SizedBox(height: 6),

                                            Row(
                                              children: [
                                                Icon(
                                                  item['active'] == 1
                                                      ? Icons.check_circle
                                                      : Icons.cancel,
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
