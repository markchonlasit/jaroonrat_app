import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import '/services/auth_service.dart';

class InspectFirePage extends StatefulWidget {
  final int assetId;
  final String assetName;
  final int? auditId;

  const InspectFirePage({
    super.key,
    required this.assetId,
    required this.assetName,
    this.auditId,
  });

  @override
  State<InspectFirePage> createState() => _InspectFirePageState();
}

class _InspectFirePageState extends State<InspectFirePage> {
  bool isLoading = true;
  bool isSubmitting = false;

  List<Map<String, dynamic>> checklist = [];
  final Map<int, bool> selectedResult = {};
  final TextEditingController remarkController = TextEditingController();

  File? imageFile;
  String imageUrl = "";

  final ImagePicker picker = ImagePicker();

  String get checklistApi =>
      'https://api.jaroonrat.com/safetyaudit/api/checklist/0/${widget.assetId}';

  @override
  void initState() {
    super.initState();

    if (widget.auditId != null) {
      fetchAuditDetail();
    } else {
      fetchChecklist();
    }
  }

  @override
  void dispose() {
    remarkController.dispose();
    super.dispose();
  }

  Future<void> fetchChecklist() async {
    try {
      final http.Response res = await http.get(
        Uri.parse(checklistApi),
        headers: {'Authorization': 'Bearer ${AuthService.token}'},
      );

      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);

        if (!mounted) return;

        setState(() {
          checklist = List<Map<String, dynamic>>.from(data);
          isLoading = false;
        });
      } else {
        _showError('โหลด checklist ไม่สำเร็จ');
        if (!mounted) return;
        setState(() => isLoading = false);
      }
    } catch (e) {
      _showError('เกิดข้อผิดพลาดในการโหลดข้อมูล');
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchAuditDetail() async {
    try {
      final detailRes = await http.get(
        Uri.parse(
            'https://api.jaroonrat.com/safetyaudit/api/auditdetail/${widget.auditId}'),
        headers: {'Authorization': 'Bearer ${AuthService.token}'},
      );

      debugPrint("AUDIT DETAIL: ${detailRes.body}");

      if (detailRes.statusCode == 200) {
        final data = jsonDecode(detailRes.body);

        checklist = List<Map<String, dynamic>>.from(data['checklist']);

        for (var item in data['checklist']) {
          selectedResult[item['id']] = item['status'] == 1;
        }

        imageUrl = data['url'] ?? "";
      }

      final auditRes = await http.get(
        Uri.parse(
            'https://api.jaroonrat.com/safetyaudit/api/audit/${widget.auditId}'),
        headers: {'Authorization': 'Bearer ${AuthService.token}'},
      );

      debugPrint("AUDIT API: ${auditRes.body}");

      if (auditRes.statusCode == 200) {
        final auditData = jsonDecode(auditRes.body);

        remarkController.text =
            auditData['remark'] ??
            auditData['note'] ??
            auditData['audit']?['remark'] ??
            "";
      }

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      debugPrint("AUDIT DETAIL ERROR: $e");
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  Future<void> takePhoto() async {
    final XFile? picked = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 35,
      maxWidth: 1600,
      maxHeight: 1600,
    );

    if (picked != null) {
      setState(() => imageFile = File(picked.path));
    }
  }

  Future<String?> _uploadImage() async {
    try {
      if (imageFile == null) return null;

      final DateTime now = DateTime.now();
      final String yyyymm =
          "${now.year}${now.month.toString().padLeft(2, '0')}";

      final uri =
          Uri.parse('https://api.jaroonrat.com/safetyaudit/api/uploadpicture');

      final request = http.MultipartRequest('POST', uri);

      request.headers['Authorization'] = 'Bearer ${AuthService.token}';

      request.fields['assetid'] = widget.assetId.toString();
      request.fields['yyyymm'] = yyyymm;

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile!.path,
          filename: "upload.jpg",
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return json['message'].toString();
      }

      return null;
    } catch (e) {
      debugPrint("UPLOAD ERROR: $e");
      return null;
    }
  }

  Future<void> submitAudit() async {
    if (selectedResult.length != checklist.length) {
      _showError('กรุณาตรวจสอบให้ครบทุกข้อ');
      return;
    }

    setState(() => isSubmitting = true);

    try {
      String imgUrl = imageUrl;

      if (imageFile != null) {
        final String? uploadedPath = await _uploadImage();
        if (uploadedPath == null) {
          _showError('อัปโหลดรูปภาพไม่สำเร็จ');
          setState(() => isSubmitting = false);
          return;
        }
        imgUrl = uploadedPath;
      }

      final Map<String, dynamic> payload = {
        "assetid": widget.assetId,
        "remark": remarkController.text,
        "url": imgUrl,
        "ans": checklist.map((item) {
          final int id = item['id'];
          return {"id": id, "status": selectedResult[id]! ? 1 : 2};
        }).toList(),
      };

      final Uri url = widget.auditId != null
          ? Uri.parse(
              'https://api.jaroonrat.com/safetyaudit/api/audit/${widget.auditId}')
          : Uri.parse(
              'https://api.jaroonrat.com/safetyaudit/api/submitaudit');

      final http.Response res = widget.auditId != null
          ? await http.put(
              url,
              headers: {
                'Authorization': 'Bearer ${AuthService.token}',
                'Content-Type': 'application/json',
              },
              body: jsonEncode(payload),
            )
          : await http.post(
              url,
              headers: {
                'Authorization': 'Bearer ${AuthService.token}',
                'Content-Type': 'application/json',
              },
              body: jsonEncode(payload),
            );

      debugPrint("SUBMIT RESULT: ${res.body}");

      if (res.statusCode == 200) {
        if (!mounted) return;
        Navigator.pop(context, true);
      } else {
        _showError('บันทึกข้อมูลไม่สำเร็จ');
      }
    } catch (e) {
      debugPrint("SUBMIT ERROR $e");
      _showError('เกิดข้อผิดพลาดในการเชื่อมต่อ');
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  void _confirmCancel() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('ยืนยันการยกเลิก'),
        content: const Text('ข้อมูลที่กรอกจะไม่ถูกบันทึก'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ไม่ยกเลิก'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text(
              'ยกเลิก',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _checkCard(Map<String, dynamic> item, int id) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item['name'],
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          InkWell(
            onTap: () => setState(() => selectedResult[id] = true),
            child: Row(children: [
              Icon(
                selectedResult[id] == true
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: Colors.green,
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(item['detail_Y'])),
            ]),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => setState(() => selectedResult[id] = false),
            child: Row(children: [
              Icon(
                selectedResult[id] == false
                    ? Icons.cancel
                    : Icons.radio_button_unchecked,
                color: Colors.red,
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(item['detail_N'])),
            ]),
          ),
        ],
      ),
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
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

  Widget _bottomButtons() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _confirmCancel,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                minimumSize: const Size.fromHeight(50),
              ),
              child:
                  const Text('ยกเลิก', style: TextStyle(color: Colors.white)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: isSubmitting ? null : submitAudit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size.fromHeight(50),
              ),
              child:
                  const Text('บันทึก', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(widget.assetName,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: Stack(
        children: [
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          ...checklist.map((item) {
                            final int id = item['id'];
                            return _checkCard(item, id);
                          }),
                          const SizedBox(height: 10),
                          _remarkField(),
                          const SizedBox(height: 12),
                          _cameraButton(),
                          if (imageFile != null) ...[
                            const SizedBox(height: 12),
                            Image.file(imageFile!, height: 180)
                          ] else if (imageUrl.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Image.network(imageUrl, height: 180)
                          ]
                        ],
                      ),
                    ),
                    _bottomButtons()
                  ],
                ),
          if (isSubmitting)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}