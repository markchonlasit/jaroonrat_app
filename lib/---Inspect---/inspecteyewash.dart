import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '/services/auth_service.dart';

class InspectEyewashPage extends StatefulWidget {
  final int assetId;
  final String assetName;

  const InspectEyewashPage({
    super.key,
    required this.assetId,
    required this.assetName,
  });

  @override
  State<InspectEyewashPage> createState() => _InspectEyewashPageState();
}

class _InspectEyewashPageState extends State<InspectEyewashPage> {
  bool isLoading = true;
  List checklist = [];
  final Map<int, bool> selectedResult = {};
  final TextEditingController remarkController = TextEditingController();

  File? imageFile;
  final picker = ImagePicker();

  String get checklistApi =>
      'https://api.jaroonrat.com/safetyaudit/api/checklist/6/${widget.assetId}';

  @override
  void initState() {
    super.initState();
    fetchChecklist();
  }

  Future<void> fetchChecklist() async {
    try {
      final res = await http.get(
        Uri.parse(checklistApi),
        headers: {'Authorization': 'Bearer ${AuthService.token}'},
      );

      if (res.statusCode == 200) {
        setState(() {
          checklist = jsonDecode(res.body);
          isLoading = false;
        });
      }
    } catch (_) {
      _showError('โหลด checklist ไม่สำเร็จ');
    }
  }

  Future<void> takePhoto() async {
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() => imageFile = File(picked.path));
    }
  }

  Future<void> submitAudit() async {
    if (selectedResult.length != checklist.length) {
      _showError('กรุณาตรวจสอบให้ครบทุกข้อ');
      return;
    }

    final payload = {
      "assetid": widget.assetId,
      "remark": remarkController.text,
      "ans": checklist.map((item) {
        final id = item['id'];
        return {"id": id, "status": selectedResult[id]! ? 1 : 2};
      }).toList(),
    };

    final res = await http.post(
      Uri.parse('https://api.jaroonrat.com/safetyaudit/api/submitaudit'),
      headers: {
        'Authorization': 'Bearer ${AuthService.token}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );

    if (res.statusCode == 200 && mounted) Navigator.pop(context);
  }

  void _showError(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    return _buildUI();
  }

  Widget _buildUI() {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(backgroundColor: Colors.red, title: Text(widget.assetName)),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    ...checklist.map((item) {
                      final id = item['id'];
                      return _checkCard(item, id);
                    }),
                    const SizedBox(height: 10),
                    _remarkField(),
                    const SizedBox(height: 12),
                    _cameraButton(),
                    if (imageFile != null) Image.file(imageFile!, height: 180)
                  ],
                ),
              ),
              _submitButton()
            ]),
    );
  }

  Widget _checkCard(item, id) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        InkWell(
          onTap: () => setState(() => selectedResult[id] = true),
          child: Row(children: [
            Icon(selectedResult[id] == true ? Icons.check_circle : Icons.radio_button_unchecked, color: Colors.green),
            const SizedBox(width: 8),
            Text(item['detail_Y']),
          ]),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => setState(() => selectedResult[id] = false),
          child: Row(children: [
            Icon(selectedResult[id] == false ? Icons.cancel : Icons.radio_button_unchecked, color: Colors.red),
            const SizedBox(width: 8),
            Text(item['detail_N']),
          ]),
        ),
      ]),
    );
  }

  Widget _remarkField() {
    return TextField(
      controller: remarkController,
      maxLines: 3,
      decoration: InputDecoration(
        hintText: 'หมายเหตุ',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _cameraButton() {
    return ElevatedButton.icon(
      onPressed: takePhoto,
      icon: const Icon(Icons.camera_alt),
      label: const Text('ถ่ายรูป'),
    );
  }

  Widget _submitButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: submitAudit,
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            minimumSize: const Size.fromHeight(50)),
        child: const Text('บันทึก'),
      ),
    );
  }
}
