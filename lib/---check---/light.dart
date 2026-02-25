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
  List<dynamic> lightList = [];

  String keyword = '';
  int statusFilter = 0; // 0=ทั้งหมด, 1=ใช้งานอยู่, 2=ไม่พร้อม

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
        final data = json.decode(response.body);
        setState(() {
          lightList = data['asset'] ?? [];
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

  List<dynamic> get filteredList {
    final search = keyword.toLowerCase();

    return lightList.where((item) {
      final name = (item['name'] ?? '').toString().toLowerCase();
      final branch = (item['branch'] ?? '').toString().toLowerCase();
      final location = (item['location'] ?? '').toString().toLowerCase();
      final active = item['active'] ?? 0;

      final matchSearch =
          name.contains(search) ||
          branch.contains(search) ||
          location.contains(search);

      final matchStatus = statusFilter == 0
          ? true
          : statusFilter == 1
              ? active == 1
              : active != 1;

      return matchSearch && matchStatus;
    }).toList();
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: TextField(
        onChanged: (value) {
          setState(() {
            keyword = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'ค้นหา',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _statusFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildFilterButton('ทั้งหมด', 0),
          const SizedBox(width: 8),
          _buildFilterButton('ใช้งานอยู่', 1),
          const SizedBox(width: 8),
          _buildFilterButton('ไม่พร้อม', 2),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String text, int value) {
    final isSelected = statusFilter == value;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            statusFilter = value;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.green : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.green),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(dynamic item) {
    final isActive = item['active'] == 1;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InspectLightPage(
              assetId: item['id'],
              assetName: item['name'] ?? '-',
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.green,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.flash_on,
                color: Colors.green,
                size: 30,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'] ?? '-',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('ID: ${item['id'] ?? '-'}'),
                  Text('สาขา: ${item['branch'] ?? '-'}'),
                  Text('วันหมดอายุ: ${item['expdate'] ?? '-'}'),
                  Text('สถานที่: ${item['location'] ?? '-'}'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        isActive
                            ? Icons.check_circle
                            : Icons.cancel,
                        size: 16,
                        color:
                            isActive ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isActive
                            ? 'ใช้งานอยู่'
                            : 'ไม่พร้อมใช้งาน',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color:
                              isActive ? Colors.green : Colors.red,
                        ),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'ไฟฉุกเฉินทั้งหมด',
          style: TextStyle(
            color: Colors.white,
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
                  builder: (_) => const AuditLightDetailPage(
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
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : Column(
                  children: [
                    _searchBar(),
                    const SizedBox(height: 8),
                    _statusFilter(),
                    const SizedBox(height: 8),
                    Expanded(
                      child: filteredList.isEmpty
                          ? const Center(child: Text('ไม่พบข้อมูล'))
                          : ListView.builder(
                              itemCount: filteredList.length,
                              itemBuilder: (context, index) {
                                return _buildCard(filteredList[index]);
                              },
                            ),
                    ),
                  ],
                ),
    );
  }
}