import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '/services/auth_service.dart';
import '/---Inspect---/inspectlight.dart';
import '/---audit---/audit_light_detail.dart';

class LightPage extends StatefulWidget {
  const LightPage({super.key});

  @override
  State<LightPage> createState() => _LightPageState();
}

class _LightPageState extends State<LightPage> {
  bool isLoading = true;
  String errorMessage = '';

  List<Map<String, dynamic>> lightList = [];

  final TextEditingController searchController = TextEditingController();

  String selectedStatus = "ทั้งหมด";
  DateTime? selectedDate;

  final String apiUrl =
      'https://api.jaroonrat.com/safetyaudit/api/assetlist/7';

  @override
  void initState() {
    super.initState();
    fetchLight();
  }

  Future<void> fetchLight() async {
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer ${AuthService.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            json.decode(response.body);

        lightList = List<Map<String, dynamic>>.from(
          data['asset'] ?? [],
        );
      } else {
        errorMessage =
            'โหลดข้อมูลไม่สำเร็จ (${response.statusCode})';
      }
    } catch (e) {
      errorMessage = 'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้';
    }

    setState(() => isLoading = false);
  }

  Widget _countBar(int total, int filtered) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.green.withValues(alpha: 0.08),
      child: Text(
        filtered == total
            ? "อุปกรณ์ทั้งหมด $total รายการ"
            : "แสดง $filtered จากทั้งหมด $total รายการ",
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.green,
        ),
      ),
    );
  }

  Widget _buildChip(
      String text,
      String groupValue,
      Function(String) onTap) {
    final bool isSelected = groupValue == text;

    return GestureDetector(
      onTap: () => onTap(text),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.green),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [

          TextField(
            controller: searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: "ค้นหา",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey.shade200,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 16),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildChip("ทั้งหมด", selectedStatus,
                  (v) => setState(() => selectedStatus = v)),
              _buildChip("ใช้งานอยู่", selectedStatus,
                  (v) => setState(() => selectedStatus = v)),
              _buildChip("ไม่พร้อม", selectedStatus,
                  (v) => setState(() => selectedStatus = v)),
            ],
          ),

          const SizedBox(height: 16),

          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );

              if (picked != null) {
                setState(() => selectedDate = picked);
              }
            },
            child: Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.green),
                  const SizedBox(width: 10),
                  Text(
                    selectedDate == null
                        ? "เลือกวันหมดอายุ"
                        : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyword = searchController.text.toLowerCase();

    final List<Map<String, dynamic>> filteredList =
        lightList.where((Map<String, dynamic> item) {
      final name = (item['name'] ?? '').toString().toLowerCase();
      final branch = (item['branch'] ?? '').toString().toLowerCase();
      final location =
          (item['location'] ?? '').toString().toLowerCase();
      final active = item['active'];

      final matchKeyword = keyword.isEmpty ||
          name.contains(keyword) ||
          branch.contains(keyword) ||
          location.contains(keyword);

      final matchStatus = selectedStatus == "ทั้งหมด" ||
          (selectedStatus == "ใช้งานอยู่" && active == 1) ||
          (selectedStatus == "ไม่พร้อม" && active != 1);

      final matchDate = selectedDate == null ||
          (item['expdate'] != null &&
              item['expdate']
                  .toString()
                  .contains(
                      "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}"));

      return matchKeyword && matchStatus && matchDate;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        title: const Text(
          'ไฟฉุกเฉินทั้งหมด',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const AuditLightDetailPage(auditedAssetIds: []),
                ),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _countBar(lightList.length, filteredList.length),
                _searchBar(),

                Expanded(
                  child: filteredList.isEmpty
                      ? const Center(child: Text("ไม่พบข้อมูล"))
                      : ListView.builder(
                          itemCount: filteredList.length,
                          itemBuilder: (context, index) {
                            final item = filteredList[index];

                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => InspectLightPage(
                                      assetId: item['id'] as int,
                                      assetName:
                                          (item['name'] ?? '').toString(),
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.all(12),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: Colors.green,
                                    width: 2,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.flash_on,
                                      size: 40,
                                      color: Colors.green,
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            (item['name'] ?? '').toString(),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text('ID: ${item['id']}'),
                                          Text('สาขา: ${item['branch']}'),
                                          Text(
                                              'วันหมดอายุ: ${item['expdate'] ?? '-'}'),
                                          Text('สถานที่: ${item['location']}'),
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
                ),
              ],
            ),
    );
  }
}