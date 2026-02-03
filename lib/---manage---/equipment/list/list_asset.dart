import 'package:flutter/material.dart';
import '/services/api_services.dart';

class AssetListPage extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const AssetListPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<AssetListPage> createState() => _AssetListPageState();
}

class _AssetListPageState extends State<AssetListPage> {
  bool loading = true;
  List<dynamic> assets = [];

  @override
  void initState() {
    super.initState();
    fetchAsset();
  }

  Future<void> fetchAsset() async {
    final res = await ApiService.getAssetList(widget.categoryId);
    setState(() {
      assets = res;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
        backgroundColor: const Color(0xFF0047AB),
      ),
      body: Column(
        children: [
          _filterBar(),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: assets.length,
                    itemBuilder: (context, index) {
                      return _assetCard(assets[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// =========================
  /// 🔍 FILTER BAR
  /// =========================
  Widget _filterBar() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'ค้นหา',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _chip('ประเภท'),
          const SizedBox(width: 6),
          _chip('สถานะ'),
        ],
      ),
    );
  }

  Widget _chip(String label) {
    return Chip(
      label: Text(label),
      avatar: const Icon(Icons.tune, size: 18),
    );
  }

  /// =========================
  /// 🔥 ASSET CARD
  /// =========================
  Widget _assetCard(dynamic asset) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.fire_extinguisher, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    asset['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    children: [
                      _tag(asset['branch'], Colors.blue),
                      _tag(asset['type'], Colors.orange),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          asset['location'],
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: ไปหน้าแก้ไข
              },
              icon: const Icon(Icons.edit, size: 16),
              label: const Text('แก้ไข'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _tag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 12),
      ),
    );
  }
}