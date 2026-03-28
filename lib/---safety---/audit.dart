import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '/services/api_services.dart';
import '/utils/app_alert.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class AuditPage extends StatefulWidget {
  final int assetId;
  final int categoryId;
  final String assetName;
  final int? auditId;
  final String? checkdate;
  final int? isedit;

  const AuditPage({
    super.key,
    required this.assetId,
    required this.categoryId,
    required this.assetName,
    this.auditId,
    this.checkdate,
    this.isedit,
  });

  @override
  State<AuditPage> createState() => _AuditPageState();
}

class _AuditPageState extends State<AuditPage> {
  bool loading = true;
  bool isLocked = false;

  List checklist = [];

  Map<int, String> answers = {};

  final TextEditingController remarkController = TextEditingController();

  File? image;
  String? imageUrl;

  @override
  void initState() {
    super.initState();

    if (widget.isedit != null) {
      isLocked = widget.isedit == 0;
    }

    loadChecklist();

    if (widget.auditId != null) {
      loadOldAudit();
    }
  }

  @override
  void dispose() {
    remarkController.dispose();
    super.dispose();
  }

  Future<File> compressImage(File file) async {
    final targetPath = file.path.replaceAll(".jpg", "_compressed.jpg");

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 60, // 🔥 ลดขนาด (50–70 ดีสุด)
    );

    return File(result!.path);
  }

  /// LOAD CHECKLIST
  Future<void> loadChecklist() async {
    final data = await ApiService.getChecklist(
      widget.categoryId,
      widget.assetId,
    );

    if (!mounted) return;

    setState(() {
      checklist = data;
      loading = false;
    });
  }

  /// LOAD OLD AUDIT
  Future<void> loadOldAudit() async {
    try {
      final data = await ApiService.getAuditDetail(widget.auditId!);

      if (!mounted) return;

      setState(() {
        for (var item in data['checklist']) {
          int id = item['id'];
          int status = item['status'];

          if (status == 1) {
            answers[id] = "Y";
          } else if (status == 2) {
            answers[id] = "N";
          }
        }

        if (data['remark'] != null) {
          remarkController.text = data['remark'];
        }

        if (data['url'] != null && data['url'] != "") {
          imageUrl = data['url'];
        }
      });
    } catch (e) {
      debugPrint("LOAD OLD AUDIT ERROR: $e");
    }
  }

  /// PICK IMAGE
  Future<void> pickImage() async {
    final picker = ImagePicker();

    final img = await picker.pickImage(source: ImageSource.camera);

    if (img != null) {
      setState(() {
        image = File(img.path);
        imageUrl = null; // ล้าง URL เก่าเมื่อเลือกรูปใหม่
      });
    }
  }

  /// SUBMIT
  Future<void> submit() async {
    if (isLocked) {
      AppAlert.warning(context, "รายการนี้เกิน 7 วันแล้ว ไม่สามารถแก้ไขได้");
      return;
    }

    if (answers.length != checklist.length) {
      AppAlert.warning(context, "กรุณาตอบคำถามให้ครบ");
      return;
    }

    bool hasNG = answers.values.contains("N");

    if (hasNG && remarkController.text.trim().isEmpty) {
      AppAlert.warning(context, "กรุณาระบุหมายเหตุเมื่อมีข้อที่ไม่ผ่าน");
      return;
    }

    AppAlert.successConfirm(
      context,
      "คุณต้องการบันทึกการตรวจสภาพนี้หรือไม่?",
      onConfirm: () async {
        AppAlert.loading(context);

        // ===========================
        // STEP 1 : UPLOAD PICTURE
        // ===========================
        String? finalImageUrl = imageUrl; // ใช้ URL เดิมถ้าไม่ได้เลือกรูปใหม่

        if (image != null) {
          // 🔥 STEP 1: บีบรูปก่อน
          File compressedImage = await compressImage(image!);

          // 🔥 STEP 2: อัปโหลดรูปที่บีบแล้ว
          final uploadedUrl = await ApiService.uploadpicture(
            imageFile: compressedImage,
            assetId: widget.assetId,
            imagePath: "", // ไม่ใช้แล้ว
          );

          if (uploadedUrl != null) {
            finalImageUrl = uploadedUrl;
          } else {
            finalImageUrl = "";
          }
        }

        // ===========================
        // STEP 2 : BUILD ANS LIST
        // ===========================
        List ans = [];

        for (var item in checklist) {
          final id = item['id'];
          ans.add({"id": id, "status": answers[id] == "Y" ? 1 : 2});
        }

        // ===========================
        // STEP 3 : SUBMIT / UPDATE AUDIT
        // ===========================
        Map<String, dynamic> data = {
          "assetid": widget.assetId,
          "remark": remarkController.text,
          "url": finalImageUrl ?? "", // ✅ ส่ง URL จริงที่ได้จาก upload
          "ans": ans,
        };

        ApiResponse res;

        if (widget.auditId != null) {
          res = await ApiService.updateaudit(widget.auditId!, data);
        } else {
          res = await ApiService.submitAudit(data);
        }

        if (!mounted) return;

        AppAlert.close(context);

        final message = res.message;

        if (res.statusCode == 200) {
          AppAlert.success(
            context,
            message,
            onComplete: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop(true);
              }
            },
          );
        } else if (res.statusCode == 409) {
          AppAlert.warning(context, message);
        } else if (res.statusCode == 401 || res.statusCode == 404) {
          AppAlert.warning(context, message);
        } else {
          AppAlert.error(context, message);
        }
      },
    );
  }

  /// CANCEL
  Future<void> cancelAudit() async {
    final confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("ยกเลิก"),
        content: const Text("ต้องการยกเลิกการตรวจหรือไม่"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("ไม่"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("ใช่"),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (confirm == true) {
      Navigator.pop(context);
    }
  }

  /// UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff2f2f2),
      appBar: AppBar(
        backgroundColor: _getColorByCategory(widget.categoryId),
        title: Text(
          widget.assetName,
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
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      /// IMAGE PREVIEW
                      if (image != null ||
                          (imageUrl != null && imageUrl!.isNotEmpty))
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: image != null
                                  ? Image.file(
                                      image!,
                                      width: double.infinity,
                                      height: 260,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.network(
                                      imageUrl!,
                                      width: double.infinity,
                                      height: 260,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, progress) {
                                        if (progress == null) return child;
                                        return SizedBox(
                                          height: 260,
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              value:
                                                  progress.expectedTotalBytes !=
                                                      null
                                                  ? progress.cumulativeBytesLoaded /
                                                        progress
                                                            .expectedTotalBytes!
                                                  : null,
                                            ),
                                          ),
                                        );
                                      },
                                      errorBuilder: (context, error, stack) =>
                                          Container(
                                            height: 260,
                                            color: Colors.grey.shade200,
                                            child: const Center(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.broken_image,
                                                    size: 48,
                                                    color: Colors.grey,
                                                  ),
                                                  SizedBox(height: 8),
                                                  Text(
                                                    "โหลดรูปไม่สำเร็จ",
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                    ),
                            ),
                            if (!isLocked)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      image = null;
                                      imageUrl = null;
                                    });
                                  },
                                  child: const CircleAvatar(
                                    backgroundColor: Colors.red,
                                    radius: 16,
                                    child: Icon(
                                      Icons.close,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),

                      const SizedBox(height: 10),

                      if (!isLocked)
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: pickImage,
                            icon: const Icon(Icons.camera_alt),
                            label: Text(
                              image != null ||
                                      (imageUrl != null && imageUrl!.isNotEmpty)
                                  ? "ถ่ายรูปใหม่"
                                  : "ถ่ายรูป",
                            ),
                          ),
                        ),

                      const SizedBox(height: 20),

                      ...checklist.map((item) {
                        final id = item['id'];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(blurRadius: 4, color: Colors.black12),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 10),

                              Row(
                                children: [
                                  Expanded(
                                    child: RadioListTile<String>(
                                      value: "Y",
                                      // ignore: deprecated_member_use
                                      groupValue: answers[id],
                                      activeColor: Colors.green,
                                      title: Text(item['detail_Y']),
                                      // ignore: deprecated_member_use
                                      onChanged: isLocked
                                          ? null
                                          : (v) {
                                              setState(() {
                                                answers[id] = v!;
                                              });
                                            },
                                    ),
                                  ),

                                  Expanded(
                                    child: RadioListTile<String>(
                                      value: "N",
                                      // ignore: deprecated_member_use
                                      groupValue: answers[id],
                                      activeColor: Colors.red,
                                      title: Text(item['detail_N']),
                                      // ignore: deprecated_member_use
                                      onChanged: isLocked
                                          ? null
                                          : (v) {
                                              setState(() {
                                                answers[id] = v!;
                                              });
                                            },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),

                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        child: TextField(
                          controller: remarkController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            hintText: "หมายเหตุ",
                            border: InputBorder.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 80),
                    ],
                  ),
                ),

                if (!isLocked)
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: cancelAudit,
                            child: const Text(
                              "ยกเลิก",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            onPressed: submit,
                            child: const Text(
                              "บันทึก",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
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
