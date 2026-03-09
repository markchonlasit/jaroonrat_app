import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/services/api_services.dart';

class AssetHistoryPage extends StatefulWidget {
  final int assetId;

  const AssetHistoryPage({super.key, required this.assetId});

  @override
  State<AssetHistoryPage> createState() => _AssetHistoryPageState();
}

class _AssetHistoryPageState extends State<AssetHistoryPage> {
  List<dynamic> allLogs = [];
  List<dynamic> filteredLogs = [];

  String searchText = "";
  String selectedPeriod = "ทั้งหมด";
  String selectedType = "ทั้งหมด";

  bool isLoading = true;

  // Local styling helpers (inline so no extra files are required)
  static const double _pagePadding = 16.0;

  @override
  void initState() {
    super.initState();
    fetchLogs();
  }

  Future<void> fetchLogs() async {
    try {
      final data = await ApiService.getAssetHistory(widget.assetId);

      if (!mounted) return;

      setState(() {
        allLogs = data;
        filteredLogs = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        allLogs = [];
        filteredLogs = [];
        isLoading = false;
      });
    }
  }

  void applyFilter() {
    List<dynamic> temp = List.from(allLogs);

    /// 🔎 SEARCH (เฉพาะ field ที่กำหนด)
    if (searchText.isNotEmpty) {
      final keyword = searchText.toLowerCase();

      temp = temp.where((item) {
        final name = (item['name'] ?? '').toString().toLowerCase();
        final location = (item['location'] ?? '').toString().toLowerCase();
        final firetype = (item['firetype'] ?? '').toString().toLowerCase();
        final expdate = (item['expdate'] ?? '').toString().toLowerCase();
        final active = (item['active'] ?? '').toString().toLowerCase();

        return name.contains(keyword) ||
            location.contains(keyword) ||
            firetype.contains(keyword) ||
            expdate.contains(keyword) ||
            active.contains(keyword);
      }).toList();
    }

    /// 📅 PERIOD FILTER (อ้างอิง createdate)
    if (selectedPeriod != "ทั้งหมด") {
      final now = DateTime.now();

      temp = temp.where((item) {
        try {
          final createdStr = item["createdate"] ?? "";

          // parse dd/MM/yyyy HH:mm:ss (ปี พ.ศ.)
          DateTime date = DateFormat("dd/MM/yyyy HH:mm:ss").parse(createdStr);

          // แปลง พ.ศ. -> ค.ศ.
          date = DateTime(
            date.year - 543,
            date.month,
            date.day,
            date.hour,
            date.minute,
            date.second,
          );

          if (selectedPeriod == "วันนี้") {
            return date.year == now.year &&
                date.month == now.month &&
                date.day == now.day;
          }

          if (selectedPeriod == "สัปดาห์นี้") {
            final startOfWeek = DateTime(
              now.year,
              now.month,
              now.day - (now.weekday - 1),
            );

            final endOfWeek = startOfWeek.add(const Duration(days: 7));

            return date.isAfter(
                  startOfWeek.subtract(const Duration(seconds: 1)),
                ) &&
                date.isBefore(endOfWeek);
          }

          if (selectedPeriod == "เดือนนี้") {
            return date.year == now.year && date.month == now.month;
          }
        } catch (e) {
          return false;
        }

        return true;
      }).toList();
    }

    setState(() {
      filteredLogs = temp;
    });
  }

  Widget buildField(String title, String value) {
    // choose icon based on title
    IconData leadingIcon = Icons.label;
    switch (title) {
      case 'ชื่ออุปกรณ์':
        leadingIcon = Icons.devices;
        break;
      case 'ตำแหน่ง':
        leadingIcon = Icons.place;
        break;
      case 'สถานะ':
        leadingIcon = Icons.info;
        break;
      case 'วันหมดอายุ':
        leadingIcon = Icons.event;
        break;
    }

    Widget valueWidget;
    if (value.contains('->')) {
      final parts = value.split('->');
      valueWidget = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'จาก ${parts[0].trim()}',
            style: const TextStyle(color: Colors.red),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            'เป็น ${parts[1].trim()}',
            style: const TextStyle(color: Colors.green),
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    } else if (title == 'สถานะ') {
      // colorize status
      final valLower = value.toLowerCase();
      Color statusColor = Colors.orange;
      if (valLower.contains('ใช้งาน') || valLower.contains('active')) {
        statusColor = Colors.green;
      } else if (valLower.contains('ไม่') ||
          valLower.contains('inactive') ||
          valLower.contains('เสีย')) {
        statusColor = Colors.red;
      }

      valueWidget = Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      );
    } else {
      valueWidget = Text(value);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(leadingIcon, size: 18, color: Theme.of(context).primaryColor),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              valueWidget,
            ],
          ),
        ),
      ],
    );
  }

  Widget buildCard(dynamic log) {
    // card layout: left icon box, middle content, right meta (user/time)
    final String created = log["createdate"] ?? "";

    Widget buildFieldBlock(String title, String value) {
      // small label then value (value may contain -> changes)
      Widget v;
      if (value.contains('->')) {
        final parts = value.split('->');
        v = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'จาก ${parts[0].trim()}',
              style: const TextStyle(color: Colors.red),
            ),
            Text(
              'เป็น ${parts[1].trim()}',
              style: const TextStyle(color: Colors.green),
            ),
          ],
        );
      } else {
        v = Text(value);
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              title,
              style: const TextStyle(fontSize: 15, color: Colors.black),
            ),
          ),
          const SizedBox(height: 8),
          v,
        ],
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // middle content as vertical column (stacked fields)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildFieldBlock('ชื่ออุปกรณ์', log['name'] ?? '-'),
                  const SizedBox(height: 12),
                  buildFieldBlock('ประเภทอุปกรณ์', log['firetype'] ?? '-'),
                  const SizedBox(height: 12),
                  buildFieldBlock('ตำแหน่ง', log['location'] ?? '-'),
                  const SizedBox(height: 12),
                  buildFieldBlock('วันหมดอายุ', log['expdate'] ?? '-'),
                  const SizedBox(height: 12),
                  buildFieldBlock('สถานะ', log['active'] ?? '-'),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // right meta: user and time
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.access_time, size: 16, color: Colors.blue),
                    const SizedBox(width: 6),
                    Text(
                      created,
                      style: const TextStyle(fontSize: 15, color: Colors.black),
                    ),
                  ],
                ),
              ],
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
        backgroundColor: const Color(0xFF0047AB),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'การจัดการข้อมูลของอุปกรณ์',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(_pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: boxed title with icon and total count pill
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.blue[50], // light blue background
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.history,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'ประวัติการแก้ไข',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0047AB),
                            ),
                      ),
                    ],
                  ),

                  // total count pill (same box)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'จำนวนทั้งหมด ${allLogs.length}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            /// 🔎 Search + Period
            buildSearchSection(),

            const SizedBox(height: 16),

            /// 🔄 Loading
            if (isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else
              Expanded(
                child: filteredLogs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.inbox, size: 64, color: Colors.black26),
                            SizedBox(height: 12),
                            Text(
                              'ไม่มีประวัติการแก้ไขของอุปกรณ์นี้',
                              style: TextStyle(color: Colors.black45),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredLogs.length,
                        itemBuilder: (context, index) {
                          return buildCard(filteredLogs[index]);
                        },
                      ),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                onChanged: (value) {
                  searchText = value;
                  applyFilter();
                },
                decoration: const InputDecoration(
                  icon: Icon(Icons.search, color: Colors.grey),
                  hintText: "ค้นหา...",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FA),
              borderRadius: BorderRadius.circular(30),
            ),
            child: DropdownButton<String>(
              value: selectedPeriod,
              underline: const SizedBox(),
              items: [
                "ทั้งหมด",
                "วันนี้",
                "สัปดาห์นี้",
                "เดือนนี้",
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (value) {
                setState(() {
                  selectedPeriod = value!;
                });
                applyFilter();
              },
            ),
          ),
        ],
      ),
    );
  }
}
