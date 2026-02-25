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

  final TextEditingController searchController = TextEditingController();

  String selectedType = "ทั้งหมด";
  String selectedStatus = "ทั้งหมด";
  DateTime? selectedDate;

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
        errorMessage =
            'โหลดข้อมูลไม่สำเร็จ (${response.statusCode})';
      }
    } catch (e) {
      errorMessage = 'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้';
    }

    setState(() => isLoading = false);
  }

  Color _getColorByType(String type) {
    switch (type.toLowerCase()) {
      case 'เขียว':
        return Colors.green;
      case 'แดง':
        return Colors.red;
      case 'เงิน':
        return Colors.grey;
      case 'dry':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  Widget _buildChip(
      String text,
      String groupValue,
      Function(String) onTap) {
    final bool isSelected = groupValue == text;

    return GestureDetector(
      onTap: () => onTap(text),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.red : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.red),
        ),
        child: Text(
          text,
          style: TextStyle(
            color:
                isSelected ? Colors.white : Colors.red,
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

          // 🔍 Search Field
          TextField(
            controller: searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: "ค้นหา",
              prefixIcon:
                  const Icon(Icons.search),
              filled: true,
              fillColor:
                  Colors.grey.shade200,
              contentPadding:
                  const EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 16),
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ประเภท
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildChip("ทั้งหมด", selectedType,
                  (v) => setState(() => selectedType = v)),
              _buildChip("dry", selectedType,
                  (v) => setState(() => selectedType = v)),
              _buildChip("เขียว", selectedType,
                  (v) => setState(() => selectedType = v)),
              _buildChip("แดง", selectedType,
                  (v) => setState(() => selectedType = v)),
              _buildChip("เงิน", selectedType,
                  (v) => setState(() => selectedType = v)),
            ],
          ),

          const SizedBox(height: 16),

          // สถานะ
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

          // เลือกวันหมดอายุ
          GestureDetector(
            onTap: () async {
              final picked =
                  await showDatePicker(
                context: context,
                initialDate:
                    selectedDate ??
                        DateTime.now(),
                firstDate:
                    DateTime(2000),
                lastDate:
                    DateTime(2100),
              );

              if (picked != null) {
                setState(() =>
                    selectedDate = picked);
              }
            },
            child: Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14),
              decoration: BoxDecoration(
                color:
                    Colors.grey.shade200,
                borderRadius:
                    BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    color: Colors.red,
                  ),
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
    final keyword =
        searchController.text.toLowerCase();

    final filteredList =
        fireList.where((item) {

      final name =
          (item['name'] ?? '')
              .toString()
              .toLowerCase();
      final branch =
          (item['branch'] ?? '')
              .toString()
              .toLowerCase();
      final location =
          (item['location'] ?? '')
              .toString()
              .toLowerCase();
      final type =
          (item['type'] ?? '')
              .toString();
      final active =
          item['active'];

      final matchKeyword =
          keyword.isEmpty ||
              name.contains(keyword) ||
              branch.contains(keyword) ||
              location.contains(keyword);

      final matchType =
          selectedType == "ทั้งหมด" ||
              type.toLowerCase() ==
                  selectedType.toLowerCase();

      final matchStatus =
          selectedStatus == "ทั้งหมด" ||
              (selectedStatus ==
                      "ใช้งานอยู่" &&
                  active == 1) ||
              (selectedStatus ==
                      "ไม่พร้อม" &&
                  active != 1);

      final matchDate =
          selectedDate == null ||
              (item['expdate'] != null &&
                  item['expdate']
                      .toString()
                      .contains(
                          "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}"));

      return matchKeyword &&
          matchType &&
          matchStatus &&
          matchDate;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text(
          'ถังดับเพลิงทั้งหมด',
          style:
              TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history,
                color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const AuditFireDetailPage(
                    auditedAssetIds: [],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator())
          : Column(
              children: [
                _searchBar(),

                Expanded(
                  child: filteredList.isEmpty
                      ? const Center(
                          child:
                              Text("ไม่พบข้อมูล"))
                      : ListView.builder(
                          itemCount:
                              filteredList.length,
                          itemBuilder:
                              (context, index) {
                            final item =
                                filteredList[
                                    index];

                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) =>
                                            InspectFirePage(
                                      assetId:
                                          item[
                                              'id'],
                                      assetName:
                                          item['name'],
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                margin:
                                    const EdgeInsets
                                        .all(12),
                                padding:
                                    const EdgeInsets
                                        .all(14),
                                decoration:
                                    BoxDecoration(
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                              14),
                                  border: Border.all(
                                    color:
                                        _getColorByType(
                                            item[
                                                'type']),
                                    width: 2,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons
                                          .fire_extinguisher,
                                      size: 40,
                                      color:
                                          _getColorByType(
                                              item[
                                                  'type']),
                                    ),
                                    const SizedBox(
                                        width:
                                            14),
                                    Expanded(
                                      child:
                                          Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['name'] ??
                                                '',
                                            style: const TextStyle(
                                                fontWeight:
                                                    FontWeight.bold),
                                          ),
                                          Text(
                                              'ID: ${item['id']}'),
                                          Text(
                                              'สาขา: ${item['branch']}'),
                                          Text(
                                              'วันหมดอายุ: ${item['expdate'] ?? '-'}'),
                                          Text(
                                              'สถานที่: ${item['location']}'),
                                          Text(
                                              'ประเภท: ${item['type']}'),
                                          Row(
                                            children: [
                                              Icon(
                                                item['active'] ==
                                                        1
                                                    ? Icons.check_circle
                                                    : Icons.cancel,
                                                size:
                                                    16,
                                                color: item['active'] ==
                                                        1
                                                    ? Colors.green
                                                    : Colors.red,
                                              ),
                                              const SizedBox(
                                                  width:
                                                      6),
                                              Text(
                                                item['active'] ==
                                                        1
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