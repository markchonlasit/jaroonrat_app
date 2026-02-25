import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '/services/auth_service.dart';

class InspectBallPage extends StatefulWidget {
  final int assetId;
  final String assetName;

  const InspectBallPage({
    super.key,
    required this.assetId,
    required this.assetName,
  });

  @override
  State<InspectBallPage> createState() => _InspectBallPageState();
}

class _InspectBallPageState extends State<InspectBallPage> {
  bool isLoading = true;
  bool isSubmitting = false; // สำหรับแสดงสถานะตอนกดบันทึก
  List checklist = [];
  final Map<int, bool> selectedResult = {};
  final TextEditingController remarkController = TextEditingController();

  File? imageFile;
  final picker = ImagePicker();

  // API ดึงข้อมูล Checklist ของ InspectBall (เลข 1)
  String get checklistApi =>
      'https://api.jaroonrat.com/safetyaudit/api/checklist/1/${widget.assetId}';

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
      } else {
        _showError('โหลด checklist ไม่สำเร็จ (Status: ${res.statusCode})');
        setState(() => isLoading = false);
      }
    } catch (_) {
      _showError('เกิดข้อผิดพลาดในการโหลดข้อมูล');
      setState(() => isLoading = false);
    }
  }

  Future<void> takePhoto() async {
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() => imageFile = File(picked.path));
    }
  }

  Future<String?> _uploadImage() async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.jaroonrat.com/safetyaudit/api/uploadpicture'),
      );

      request.headers['Authorization'] = 'Bearer ${AuthService.token}';
      request.fields['assetid'] = widget.assetId.toString();

      request.files.add(await http.MultipartFile.fromPath(
        'file', 
        imageFile!.path,
      ));

      var response = await request.send();

      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        print('=== Upload Response ===');
        print(respStr);
        
        try {
          final json = jsonDecode(respStr);
          return json['url'] ?? respStr; 
        } catch (e) {
          return respStr;
        }
      } else {
        final errStr = await response.stream.bytesToString();
        print('Upload failed with status: ${response.statusCode}');
        print('=== Error Body (สาเหตุที่แท้จริง) ===');
        print(errStr); 
        return null;
      }
    } catch (e) {
      print('Upload exception: $e');
      return null;
    }
  }

  Future<void> submitAudit() async {
    if (selectedResult.length != checklist.length) {
      _showError('กรุณาตรวจสอบให้ครบทุกข้อ');
      return;
    }

    setState(() => isSubmitting = true); // แสดง Loading ป้องกันกดซ้ำ

    try {
      String imageUrl = ""; // ค่าเริ่มต้นของ url หากไม่มีการถ่ายรูป

      // 1. อัปโหลดรูปภาพก่อน (ถ้ามีการถ่ายรูปไว้)
      if (imageFile != null) {
        final uploadedPath = await _uploadImage();
        
        if (uploadedPath == null) {
          _showError('อัปโหลดรูปภาพไม่สำเร็จ กรุณาลองใหม่');
          setState(() => isSubmitting = false);
          return; // หยุดการทำงานถ้าอัปโหลดรูปไม่ผ่าน
        }
        
        imageUrl = uploadedPath; 
      }

      // 2. เตรียมข้อมูล Payload ให้ตรงกับรูปแบบที่ Backend ต้องการ
      final payload = {
        "assetid": widget.assetId,
        "remark": remarkController.text,
        "url": imageUrl, 
        "ans": checklist.map((item) {
          final id = item['id'];
          return {"id": id, "status": selectedResult[id]! ? 1 : 2};
        }).toList(),
      };

      print('=== Payload for submitAudit ===');
      print(jsonEncode(payload));

      // 3. ส่งข้อมูลทั้งหมดไปบันทึก
      final res = await http.post(
        Uri.parse('https://api.jaroonrat.com/safetyaudit/api/submitaudit'),
        headers: {
          'Authorization': 'Bearer ${AuthService.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      print('=== submitAudit Status ===');
      print(res.statusCode);

      if (res.statusCode == 200) {
        if (mounted) Navigator.pop(context);
      } else {
        _showError('บันทึกข้อมูลไม่สำเร็จ (Status: ${res.statusCode})');
        print('=== Error Response from submitAudit ===');
        print(res.body);
      }
    } catch (e) {
      _showError('เกิดข้อผิดพลาดในการเชื่อมต่อ');
      print(e);
    } finally {
      if (mounted) setState(() => isSubmitting = false); // ปิด Loading
    }
  }

  void _showError(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 5, 47, 233), 
        title: Text(widget.assetName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white))
      ),
      body: Stack(
        children: [
          isLoading
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
                        if (imageFile != null) ...[
                          const SizedBox(height: 12),
                          Image.file(imageFile!, height: 180)
                        ]
                      ],
                    ),
                  ),
                  _bottomButtons()
                ]),
          
          // Overlay แสดงระหว่างกดบันทึก
          if (isSubmitting)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
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
            Icon(selectedResult[id] == true
                ? Icons.check_circle
                : Icons.radio_button_unchecked, color: Colors.green),
            const SizedBox(width: 8),
            Expanded(child: Text(item['detail_Y'])), // ป้องกัน text ล้นจอ
          ]),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => setState(() => selectedResult[id] = false),
          child: Row(children: [
            Icon(selectedResult[id] == false
                ? Icons.cancel
                : Icons.radio_button_unchecked, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(child: Text(item['detail_N'])), // ป้องกัน text ล้นจอ
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
              child: const Text('ยกเลิก'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: isSubmitting ? null : submitAudit, // ปิดปุ่มถ้ากำลังโหลด
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text('บันทึก'),
            ),
          ),
        ],
      ),
    );
  }
}