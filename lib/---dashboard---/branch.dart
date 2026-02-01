import 'package:flutter/material.dart';
import '/services/api_services.dart';


class BranchCard extends StatefulWidget {
  const BranchCard({super.key});

  @override
  State<BranchCard> createState() => _BranchCardState();
}

class _BranchCardState extends State<BranchCard> {
  String branchName = '-';
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadBranch();
  }

Future<void> _loadBranch() async {
  try {
    final profile = await ApiService.getProfile();

    final branch = profile['branch'] ?? '';

    setState(() {
      branchName = branch.isNotEmpty
          ? 'บริษัทจรุรัตน์โปรดักส์ จำกัด $branch'
          : 'บริษัทจรุรัตน์โปรดักส์ จำกัด';
      loading = false;
    });
  } catch (e) {
    setState(() {
      branchName = 'บริษัทจรุรัตน์โปรดักส์ จำกัด';
      loading = false;
    });
  }
}
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Colors.black),
      ),
      child: ListTile(
        leading: const Icon(
          Icons.home,
          color: Color(0xFF0047AB),
        ),
        title: loading
            ? const Text('กำลังโหลดข้อมูลสาขา...')
            : Text(branchName),
      ),
    );
  }
}