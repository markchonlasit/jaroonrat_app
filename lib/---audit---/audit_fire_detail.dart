import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '/services/auth_service.dart';
import '/---Inspect---/inspectfire.dart';

class AuditFireDetailPage extends StatefulWidget {
  final int assetId;
  final String assetName;
  final String assetType;

  const AuditFireDetailPage({
    super.key,
    required this.assetId,
    required this.assetName,
    required this.assetType,
  });

  @override
  State<AuditFireDetailPage> createState() => _AuditFireDetailPageState();
}

class _AuditFireDetailPageState extends State<AuditFireDetailPage> {
  bool isLoading = true;
  List<Map<String, dynamic>> auditList = [];

  late String apiUrl;

  @override
  void initState() {
    super.initState();

    apiUrl =
        'https://api.jaroonrat.com/safetyaudit/api/audit/${widget.assetId}';

    fetchAudit();
  }

  Future<void> fetchAudit() async {
    try {
      final res = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer ${AuthService.token}',
        },
      );

      debugPrint("AUDIT API: ${res.body}");

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        List<Map<String, dynamic>> list = [];

        if (data is List) {
          list = List<Map<String, dynamic>>.from(data);
        } else if (data is Map && data['audit'] != null) {
          list = List<Map<String, dynamic>>.from(data['audit']);
        } else if (data is Map) {
          list = [Map<String, dynamic>.from(data)];
        }

        setState(() {
          auditList = list;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("ERROR: $e");
      setState(() => isLoading = false);
    }
  }

  Widget _chip(String text, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color ?? Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }

  /// การ์ดประวัติ
  Widget _assetCard(dynamic item) {
    final rawType =
        item['type'] ??
        item['typename'] ??
        item['type_name'] ??
        widget.assetType ??
        '';

    final type = rawType.toString().toLowerCase();

    final Map<String, Color> typeColors = {
      'dry': Colors.blue.shade200,
      'เขียว': Colors.green.shade200,
      'แดง': Colors.red.shade200,
      'เงิน': Colors.grey.shade400,
    };

    final remark =
        item['remark'] ??
        item['note'] ??
        item['remark_text'] ??
        '';

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => InspectFirePage(
              assetId: widget.assetId,
              assetName: widget.assetName,
              auditId: item['id'], assetType: widget.assetType,
            ),
          ),
        );

        if (result == true) {
          fetchAudit();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                const Icon(
                  Icons.fire_extinguisher,
                  size: 46,
                  color: Colors.red,
                ),
                const SizedBox(height: 8),
                _chip("Audit", color: Colors.blue.shade50),
              ],
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _chip(
                    item['assetname'] ?? widget.assetName,
                    color: const Color.fromARGB(255, 235, 235, 235),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 18,
                        color: Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item['locationname'] ?? '-',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  _chip(
                    'ประเภท ${rawType.isEmpty ? '-' : rawType}',
                    color: typeColors[type] ?? Colors.grey.shade200,
                  ),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 18,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          "วันที่ตรวจ ${item['checkdate'] ?? '-'}",
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),

                  if (remark.toString().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.notes,
                            size: 18,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              remark,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
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
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(
          'ประวัติการตรวจ ${widget.assetName}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : auditList.isEmpty
              ? const Center(child: Text("ไม่มีประวัติการตรวจ"))
              : RefreshIndicator(
                  onRefresh: fetchAudit,
                  color: Colors.red,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: auditList.length,
                    itemBuilder: (context, index) {
                      return _assetCard(auditList[index]);
                    },
                  ),
                ),
    );
  }
}