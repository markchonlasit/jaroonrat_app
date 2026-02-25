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

  int typeFilter = 0; 
  // 0 = ทั้งหมด
  // 1 = เขียว
  // 2 = แดง

  int statusFilter = 0;
  // 0 = ทั้งหมด
  // 1 = ใช้งานอยู่
  // 2 = ไม่พร้อมใช้งาน

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

  // ================= SEARCH =================
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

  // ================= TYPE FILTER =================
  Widget _typeButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _typeButton("ทั้งหมด", 0),
          _typeButton("เขียว", 1),
          _typeButton("แดง", 2),
        ],
      ),
    );
  }

  Widget _typeButton(String text, int value) {
    final selected = typeFilter == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => typeFilter = value),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? const Color.fromARGB(255, 5, 47, 233) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color.fromARGB(255, 5, 47, 233)),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: selected ? Colors.white : const Color.fromARGB(255, 5, 47, 233),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // ================= STATUS FILTER =================
  Widget _statusButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _statusButton("ทั้งหมด", 0),
          _statusButton("ใช้งานอยู่", 1),
          _statusButton("ไม่พร้อมใช้งาน", 2),
        ],
      ),
    );
  }

  Widget _statusButton(String text, int value) {
    final selected = statusFilter == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => statusFilter = value),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? const Color.fromARGB(255, 5, 47, 233) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color.fromARGB(255, 5, 47, 233)),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? Colors.white : const Color.fromARGB(255, 5, 47, 233),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
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
      final active = item['active'];

      final search = keyword.toLowerCase();

      final matchKeyword =
          name.contains(search) ||
              location.contains(search) ||
              branch.contains(search);

      final matchType = typeFilter == 0
          ? true
          : typeFilter == 1
              ? type == 'เขียว'
              : type == 'แดง';

      final matchStatus = statusFilter == 0
          ? true
          : statusFilter == 1
              ? active == 1
              : active != 1;

      return matchKeyword &&
          matchType &&
          matchStatus;
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
            fontWeight: FontWeight.bold,
          ),
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
                      const AuditBallDetailPage(
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
                    const SizedBox(height: 8),
                    _typeButtons(),
                    const SizedBox(height: 8),
                    _statusButtons(),
                    const SizedBox(height: 8),

                    Expanded(
                      child: filteredList.isEmpty
                          ? const Center(
                              child: Text('ไม่พบข้อมูล'))
                          : ListView.builder(
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
                                              item['name'] ??
                                                  '-',
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    margin:
                                        const EdgeInsets.all(
                                            12),
                                    padding:
                                        const EdgeInsets.all(
                                            14),
                                    decoration:
                                        BoxDecoration(
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                                  14),
                                      border: Border.all(
                                        color:
                                            Colors.blue,
                                        width: 2,
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                      children: [
                                        Icon(
                                          Icons
                                              .sports_baseball,
                                          color:
                                              _getColorByType(
                                                  item[
                                                      'type']),
                                          size: 40,
                                        ),
                                        const SizedBox(
                                            width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                            children: [
                                              Text(
                                                item['name'] ??
                                                    '-',
                                                style:
                                                    const TextStyle(
                                                  fontSize:
                                                      15,
                                                  fontWeight:
                                                      FontWeight
                                                          .bold,
                                                ),
                                              ),
                                              const SizedBox(
                                                  height:
                                                      6),
                                              Text(
                                                  'ID: ${item['id']}'),
                                              Text(
                                                  'สาขา: ${item['branch']}'),
                                              Text(
                                                  'วันหมดอายุ: ${item['expdate'] ?? '-'}'),
                                              Text(
                                                  'สถานที่: ${item['location']}'),
                                              Text(
                                                'ประเภทสีของลูกบอล: ${item['type']}',
                                                style:
                                                    TextStyle(
                                                  color:
                                                      _getColorByType(
                                                          item[
                                                              'type']),
                                                  fontWeight:
                                                      FontWeight
                                                          .bold,
                                                ),
                                              ),
                                              const SizedBox(
                                                  height:
                                                      6),
                                              Row(
                                                children: [
                                                  Icon(
                                                    item['active'] ==
                                                            1
                                                        ? Icons
                                                            .check_circle
                                                        : Icons
                                                            .cancel,
                                                    size: 16,
                                                    color: item[
                                                                'active'] ==
                                                            1
                                                        ? Colors
                                                            .green
                                                        : Colors
                                                            .red,
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