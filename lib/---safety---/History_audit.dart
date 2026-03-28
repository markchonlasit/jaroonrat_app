import 'package:flutter/material.dart';
import '/services/api_services.dart';
import 'audit.dart';

class HistoryauditPage extends StatefulWidget {
  final int assetId;
  final String assetName;
  final int categoryId;
  final String branch;
  final String type;

  const HistoryauditPage({
    super.key,
    required this.assetId,
    required this.assetName,
    required this.categoryId,
    required this.branch,
    required this.type,
  });

  @override
  State<HistoryauditPage> createState() => _HistoryauditPageState();
}

class _HistoryauditPageState extends State<HistoryauditPage> {
  List history = [];
  bool loading = true;

  // ✅ เก็บ URL รูปของแต่ละ auditId  {auditId: url}
  Map<int, String?> auditImageUrls = {};

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  /// =========================
  /// LOAD HISTORY
  /// =========================
  Future<void> loadHistory() async {
    try {
      final data = await ApiService.getAuditHistory(widget.assetId);

      setState(() {
        history = data;
        loading = false;
      });

      // ✅ หลัง load list สำเร็จ ให้โหลด detail ของแต่ละรายการเพื่อดึง URL รูป
      _loadAllAuditImages(data);
    } catch (e) {
      setState(() {
        loading = false;
      });
      debugPrint("HISTORY ERROR: $e");
    }
  }

  /// =========================
  /// LOAD IMAGE URL ของทุก audit
  /// =========================
  Future<void> _loadAllAuditImages(List data) async {
    for (var item in data) {
      final int? auditId = item['id'];
      if (auditId == null) continue;
      if (item['message'] == "History not found") continue;

      try {
        final detail = await ApiService.getAuditDetail(auditId);
        final url = detail['url'];
        
        debugPrint("AUDIT $auditId → url = $url");

        if (!mounted) return;

        setState(() {
          auditImageUrls[auditId] = (url != null && url.toString().isNotEmpty)
              ? url.toString()
              : null;
        });
      } catch (e) {
        debugPrint("LOAD IMAGE ERROR auditId=$auditId : $e");
      }
    }
  }

  /// =========================
  /// UI
  /// =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff2f2f2),

      appBar: AppBar(
        backgroundColor: _getColorByCategory(widget.categoryId),
        title: Text(
          "ประวัติ ${widget.assetName}",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : history.isEmpty
              ? const Center(child: Text("ไม่มีประวัติการตรวจ"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final item = history[index];
                    final int isedit = item['isedit'] ?? 0;
                    final int? auditId = item['id'];

                    /// ถ้า API ส่ง History not found
                    if (item['message'] == "History not found") {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade300),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.history, color: Colors.grey, size: 40),
                            SizedBox(width: 12),
                            Text(
                              "ไม่มีประวัติการตรวจ",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    }

                    // ✅ ดึง URL รูปของ audit นี้ (ถ้ามี)
                    final String? imageUrl =
                        auditId != null ? auditImageUrls[auditId] : null;

                    /// ======================
                    /// CARD HISTORY
                    /// ======================
                    return GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AuditPage(
                              assetId: item['assetid'] ?? widget.assetId,
                              categoryId: widget.categoryId,
                              assetName: widget.assetName,
                              auditId: item['id'],
                              checkdate: item['checkdate'],
                              isedit: item['isedit'],
                            ),
                          ),
                        );

                        // รีโหลดหลัง pop กลับมา
                        loadHistory();
                      },

                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.grey,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ===========================
                            // ✅ รูปภาพ (ถ้ามี URL)
                            // ===========================
                            if (imageUrl != null && imageUrl.isNotEmpty)
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                                child: Image.network(
                                  imageUrl,
                                  width: double.infinity,
                                  height: 180,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, progress) {
                                    if (progress == null) return child;
                                    return Container(
                                      height: 180,
                                      color: Colors.grey.shade100,
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stack) =>
                                      Container(
                                    height: 100,
                                    color: Colors.grey.shade100,
                                    child: const Center(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.broken_image,
                                              color: Colors.grey),
                                          SizedBox(width: 6),
                                          Text(
                                            "โหลดรูปไม่สำเร็จ",
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 13),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            else if (auditId != null &&
                                !auditImageUrls.containsKey(auditId))
                              // กำลังโหลด detail อยู่ (ยังไม่มี key)
                              Container(
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
                                ),
                                child: const Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  ),
                                ),
                              ),

                            // ===========================
                            // CONTENT ROW
                            // ===========================
                            Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  /// LEFT ICON
                                  Column(
                                    children: [
                                      Icon(
                                        _getIconByCategory(widget.categoryId),
                                        size: 46,
                                        color: _getColorByCategory(
                                            widget.categoryId),
                                      ),
                                      const SizedBox(height: 8),
                                      _chip(widget.branch,
                                          color: Colors.blue.shade100),
                                      const SizedBox(height: 4),
                                    ],
                                  ),

                                  const SizedBox(width: 12),

                                  /// RIGHT CONTENT
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _chip(
                                          '${item['assetname'] ?? widget.assetName}',
                                          color: const Color.fromARGB(
                                              255, 212, 211, 211),
                                        ),

                                        const SizedBox(height: 6),

                                        Builder(
                                          builder: (context) {
                                            final type =
                                                widget.type.toLowerCase();

                                            final Map<String, Color>
                                                typeColors = {
                                              'dry': Colors.blue.shade200,
                                              'เขียว':
                                                  Colors.green.shade200,
                                              'แดง': Colors.red.shade200,
                                              'เงิน': Colors.grey.shade400,
                                            };

                                            final chipColor =
                                                typeColors[type] ??
                                                    Colors.grey.shade200;

                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                _chip(
                                                  'ประเภท ${widget.type}',
                                                  color: chipColor,
                                                ),
                                                const SizedBox(height: 8),
                                              ],
                                            );
                                          },
                                        ),

                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.location_on,
                                              size: 20,
                                              color: Colors.red,
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                item['locationname'] ?? '-',
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 6),

                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.calendar_today,
                                              size: 20,
                                              color: Colors.orange,
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                item['checkdate'] ?? '-',
                                                style: const TextStyle(
                                                    fontSize: 15),
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 6),

                                        _chip(
                                          isedit == 1 ? "แก้ไขได้" : "ล็อก",
                                          color: isedit == 1
                                              ? Colors.green.shade200
                                              : Colors.grey.shade400,
                                        ),

                                        const SizedBox(height: 6),
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
                  },
                ),
    );
  }

  /// =========================
  /// CHIP UI
  /// =========================
  Widget _chip(String text, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color ?? Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: const TextStyle(fontSize: 15)),
    );
  }

  IconData _getIconByCategory(int id) {
    switch (id) {
      case 0:
        return Icons.fire_extinguisher;
      case 1:
        return Icons.sports_baseball;
      case 2:
        return Icons.fire_hydrant_alt;
      case 3:
        return Icons.warning_amber;
      case 4:
        return Icons.grain;
      case 6:
        return Icons.opacity;
      case 7:
        return Icons.lightbulb;
      default:
        return Icons.inventory_2;
    }
  }

  Color _getColorByCategory(int id) {
    switch (id) {
      case 0:
        return Colors.red;
      case 1:
        return const Color(0xFF0047AB);
      case 2:
        return Colors.deepOrangeAccent;
      case 3:
        return Colors.amber;
      case 4:
        return Colors.brown;
      case 6:
        return Colors.blue;
      case 7:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}