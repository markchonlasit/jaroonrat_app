import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import '/services/auth_service.dart';

class InspectFirePage extends StatefulWidget {
  final int assetId;
  final String assetName;

  const InspectFirePage({
    super.key,
    required this.assetId,
    required this.assetName,
  });

  @override
  State<InspectFirePage> createState() => _InspectFirePageState();
}

class _InspectFirePageState extends State<InspectFirePage> {
  bool isLoading = true;
  List<dynamic> checklist = [];
  final Map<int, bool> selectedResult = {};

  PlatformFile? selectedImage;

  String get checklistApi =>
      'https://api.jaroonrat.com/safetyaudit/api/checklist/0/${widget.assetId}';

  @override
  void initState() {
    super.initState();
    fetchChecklist();
  }

  /// โหลด checklist
  Future<void> fetchChecklist() async {
    try {
      final res = await http.get(
        Uri.parse(checklistApi),
        headers: {
          'Authorization': 'Bearer ${AuthService.token}',
        },
      );

      if (res.statusCode == 200) {
        setState(() {
          checklist = jsonDecode(res.body);
          isLoading = false;
        });
      } else {
        _showError('โหลด checklist ไม่สำเร็จ (${res.statusCode})');
      }
    } catch (e) {
      _showError('เชื่อมต่อเซิร์ฟเวอร์ไม่ได้');
    }
  }

  /// เลือกรูป (เปิด file explorer / gallery)
 Future<void> pickImage() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.image,
    withData: true,   // ต้องมีอันนี้
  );

  if (result != null) {
    print("เลือกรูปแล้ว: ${result.files.first.name}");
    setState(() {
      selectedImage = result.files.first;
    });
  } else {
    print("ผู้ใช้ยกเลิก");
  }
}


  /// ส่งข้อมูล
  Future<void> submitAudit() async {
    if (selectedResult.length != checklist.length) {
      _showError('กรุณาตรวจสอบให้ครบทุกข้อ');
      return;
    }

    var uri = Uri.parse(
        'https://api.jaroonrat.com/safetyaudit/api/uploadpicture');

    var request = http.MultipartRequest("POST", uri);

    request.headers['Authorization'] = 'Bearer ${AuthService.token}';

    request.fields['assetid'] = widget.assetId.toString();
    request.fields['remark'] = "ตรวจจากแอป";

    request.fields['ans'] = jsonEncode(
      checklist.map((item) {
        final id = item['id'];
        return {
          "id": id,
          "status": selectedResult[id]! ? 1 : 2,
        };
      }).toList(),
    );

    /// แนบรูป
    if (selectedImage != null && selectedImage!.bytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'picture', // ⚠️ ถ้า 500 ลองเปลี่ยนเป็น 'file'
          selectedImage!.bytes!,
          filename: selectedImage!.name,
        ),
      );
    }

    try {
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      print("STATUS => ${response.statusCode}");
      print("BODY => $responseBody");

      if (response.statusCode == 200) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('บันทึกสำเร็จ')),
        );

        Navigator.pop(context);
      } else {
        _showError('บันทึกไม่สำเร็จ (${response.statusCode})');
      }
    } catch (e) {
      _showError('เชื่อมต่อเซิร์ฟเวอร์ไม่ได้');
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(
          widget.assetName,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: checklist.length,
                    itemBuilder: (_, i) {
                      final item = checklist[i];
                      final int id = item['id'];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name'],
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Checkbox(
                                  value: selectedResult[id] == true,
                                  onChanged: (_) =>
                                      setState(() => selectedResult[id] = true),
                                ),
                                Text(item['detail_Y']),
                              ],
                            ),
                            Row(
                              children: [
                                Checkbox(
                                  value: selectedResult[id] == false,
                                  onChanged: (_) => setState(
                                      () => selectedResult[id] = false),
                                ),
                                Text(item['detail_N']),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                /// ปุ่มเลือกรูป (UI เดิม)
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "แนบรูปภาพประกอบ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: pickImage,
                        icon: const Icon(Icons.photo),
                        label: const Text("เลือกรูป"),
                      ),
                      const SizedBox(height: 10),

                      if (selectedImage != null &&
                          selectedImage!.bytes != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            selectedImage!.bytes!,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: submitAudit,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red),
                      child: const Text('บันทึก'),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
