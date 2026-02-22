import 'package:flutter/material.dart';
import '/services/api_services.dart';
import '/utils/app_alert.dart';
import 'equipment_history_edit.dart';

Future<bool?> showEditAssetDialog(BuildContext context, int assetId) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return FutureBuilder<Map<String, dynamic>>(
        future: ApiService.getAsset(assetId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AlertDialog(
              content: SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              ),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return AlertDialog(
              content: const Text('ไม่สามารถโหลดข้อมูลอุปกรณ์ได้'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('ปิด'),
                ),
              ],
            );
          }

          final asset = snapshot.data!;

          /// =========================
          /// CONTROLLERS
          /// =========================
          final nameCtrl = TextEditingController(text: asset['name'] ?? '');
          final locationCtrl = TextEditingController(
            text: asset['location'] ?? '',
          );

          final String categoryName =
              asset['categoryname']?.toString().trim() ?? '';
          final bool isFireAsset = asset['fireasset'] == true;

          /// =========================
          /// FIRE TYPE LOGIC
          /// =========================
          List<String> fireTypeItems = [];

          if (isFireAsset) {
            if (categoryName.contains('ถังดับเพลิง')) {
              fireTypeItems = ['dry', 'เงิน', 'เขียว', 'แดง'];
            } else if (categoryName.contains('ลูกบอลดับเพลิง')) {
              fireTypeItems = ['เขียว', 'แดง'];
            }
          }

          ValueNotifier<String>? fireTypeNotifier;
          if (fireTypeItems.isNotEmpty) {
            fireTypeNotifier = ValueNotifier<String>(
              fireTypeItems.contains(asset['firetype'])
                  ? asset['firetype']
                  : fireTypeItems.first,
            );
          }
          // 1. ดึงค่าจาก API ถ้าเป็น null ให้เป็น String ว่าง
          String apiDateValue = asset['expdate']?.toString() ?? '';

          // 2. จัดการตัวหนังสือที่จะโชว์ใน TextField (เช่น 01-01-2569)
          String initialText = '';
          if (apiDateValue.isNotEmpty) {
            // ตัดเอาแค่ส่วนวันที่ "01/01/2569" มาเปลี่ยน / เป็น - เพื่อโชว์
            initialText = apiDateValue.split(' ').first.replaceAll('/', '-');
          }
          final expDateCtrl = TextEditingController(text: initialText);

          ValueNotifier<int> activeNotifier = ValueNotifier<int>(
            asset['active'] == 0 ? 0 : 1,
          );

          /// =========================
          /// UI
          /// =========================
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: const BorderSide(color: Colors.black),
            ),
            backgroundColor: Colors.white,
            contentPadding: EdgeInsets.zero,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 24,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// HEADER
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFC107),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(14),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text(
                        'แก้ไขอุปกรณ์',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      /// BRANCH (read-only)
                      _customRowField(
                        icon: Icons.apartment,
                        label: 'สาขา :',
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.black),
                          ),
                          child: Text(
                            asset['branch'] ?? '-',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      /// NAME
                      _customRowField(
                        icon: Icons.h_mobiledata,
                        label: 'ชื่ออุปกรณ์ :',
                        child: TextField(
                          controller: nameCtrl,
                          textAlign: TextAlign.center,
                          decoration: _innerInputDecoration(),
                        ),
                      ),

                      /// FIRE TYPE
                      if (fireTypeNotifier != null)
                        ValueListenableBuilder<String>(
                          valueListenable: fireTypeNotifier,
                          builder: (context, currentType, _) {
                            return _customRowField(
                              icon: Icons.build_circle,
                              label: 'ประเภท :',
                              child: DropdownButtonFormField<String>(
                                initialValue: currentType,
                                isExpanded: true,
                                decoration: _innerInputDecoration(
                                  hasIcon: true,
                                ),
                                items: fireTypeItems
                                    .map(
                                      (e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(e),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) {
                                  if (v != null) {
                                    fireTypeNotifier!.value = v;
                                  }
                                },
                              ),
                            );
                          },
                        ),

                      /// LOCATION
                      _customRowField(
                        icon: Icons.location_on,
                        label: 'ตำแหน่ง :',
                        child: TextField(
                          controller: locationCtrl,
                          textAlign: TextAlign.center,
                          decoration: _innerInputDecoration(),
                        ),
                      ),

                      /// EXP DATE
                      _customRowField(
                        icon: Icons.calendar_month,
                        label: 'วันหมดอายุ :',
                        child: TextField(
                          controller: expDateCtrl,
                          readOnly: true,
                          textAlign: TextAlign.center,
                          decoration: _innerInputDecoration(),
                          onTap: () async {
                            DateTime initialDate = DateTime.now();

                            // 1. ถ้ามีค่าเดิม (เช่น "01/01/2569 00:00:00") ให้แปลงเป็น DateTime เพื่อเปิดปฏิทินให้ถูกปี
                            if (apiDateValue.isNotEmpty) {
                              try {
                                List<String> dateParts = apiDateValue
                                    .split(' ')[0]
                                    .split('/');
                                int d = int.parse(dateParts[0]);
                                int m = int.parse(dateParts[1]);
                                int y = int.parse(
                                  dateParts[2],
                                ); // ใช้ 2569 ตรงๆ เพราะเราใช้ปฏิทินไทย
                                initialDate = DateTime(y, m, d);
                              } catch (e) {
                                initialDate = DateTime.now();
                              }
                            }

                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate: initialDate,
                              firstDate: DateTime(
                                2500,
                              ), // ตั้งให้ครอบคลุมปี พ.ศ.
                              lastDate: DateTime(4000),
                              // ไม่ต้องใส่ locale ตรงนี้แล้วก็ได้ เพราะใน main.dart กำหนดไว้แล้ว
                            );

                            if (pickedDate != null) {
                              // 2. ใช้ปีจาก pickedDate ได้เลย (มันจะเป็น 2569 อยู่แล้ว)
                              // ❌ ห้ามบวก 543 เพิ่มเด็ดขาด
                              final int year = pickedDate.year;
                              final String day = pickedDate.day
                                  .toString()
                                  .padLeft(2, '0');
                              final String month = pickedDate.month
                                  .toString()
                                  .padLeft(2, '0');

                              // ✅ อัปเดต UI (โชว์ 01-01-2569)
                              expDateCtrl.text = '$day-$month-$year';

                              // ✅ เตรียมค่าส่ง API (เก็บ 01/01/2569 00:00:00)
                              apiDateValue = '$day/$month/$year 00:00:00';
                            }
                          },
                        ),
                      ),

                      /// STATUS ACTIVE
                      ValueListenableBuilder<int>(
                        valueListenable: activeNotifier,
                        builder: (context, currentStatus, _) {
                          return _customRowField(
                            icon: Icons.toggle_on,
                            label: 'สถานะ :',
                            child: SizedBox(
                              width: 130, // 👈 ทำให้เล็กลง
                              height: 35,
                              child: DropdownButtonFormField<int>(
                                initialValue: currentStatus,
                                isExpanded: true,
                                decoration: _innerInputDecoration(
                                  hasIcon: false,
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 1,
                                    child: Text('ใช้งาน'),
                                  ),
                                  DropdownMenuItem(
                                    value: 0,
                                    child: Text('ไม่ได้ใช้งาน'),
                                  ),
                                ],
                                onChanged: (v) {
                                  if (v != null) {
                                    activeNotifier.value = v;
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),

                      /// ACTIONS
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _actionButton(
                            label: 'ประวัติ',
                            icon: Icons.history,
                            color: Colors.blue.shade300,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AssetHistoryPage(
                                    assetId: assetId, // 🔥 ต้องมี id ของอุปกรณ์
                                  ),
                                ),
                              );
                            },
                          ),
                          _actionButton(
                            label: 'ยกเลิก',
                            icon: Icons.close,
                            color: Colors.grey.shade300,
                            onPressed: () => Navigator.pop(context, false),
                          ),
                          _actionButton(
                            label: 'แก้ไข',
                            icon: Icons.edit,
                            color: const Color(0xFFFFC107),
                            onPressed: () async {
                              final navigator = Navigator.of(context);

                              AppAlert.successConfirm(
                                context,
                                "คุณต้องการแก้ไขข้อมูลอุปกรณ์นี้หรือไม่?",
                                onConfirm: () async {
                                  final data = {
                                    'name': nameCtrl.text,
                                    'location': locationCtrl.text,
                                    'active': activeNotifier.value,
                                    'expdate': apiDateValue,
                                  };

                                  if (fireTypeNotifier != null) {
                                    data['firetype'] = fireTypeNotifier.value;
                                  }

                                  // 🔄 แสดง Loading
                                  AppAlert.loading(context);

                                  final success = await ApiService.updateAsset(
                                    assetId,
                                    data,
                                  );

                                  if (!context.mounted) return;

                                  AppAlert.close(context); // ปิด loading

                                  if (success) {
                                    // ✅ แสดง success 1 วิ
                                    AppAlert.success(
                                      context,
                                      "แก้ไขข้อมูลสำเร็จ",
                                    );

                                    // ⏳ รอ 1 วินาทีแล้วค่อย pop
                                    Future.delayed(
                                      const Duration(seconds: 1),
                                      () {
                                        if (context.mounted) {
                                          navigator.pop(true);
                                        }
                                      },
                                    );
                                  } else {
                                    AppAlert.error(
                                      context,
                                      "ไม่สามารถแก้ไขข้อมูลได้",
                                    );
                                  }
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

/// =======================================================
/// ROW FIELD
/// =======================================================
Widget _customRowField({
  required IconData icon,
  required String label,
  required Widget child,
  double fontSize = 16,
}) {
  return Container(
    width: double.infinity, // 👈 ให้เต็มความกว้าง
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.grey.shade200,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: Colors.black),
    ),
    child: Row(
      children: [
        Icon(icon, color: Colors.blue.shade600, size: 26),
        const SizedBox(width: 8),
        SizedBox(
          width: 110, // 👈 ล็อกความกว้าง label ให้เท่ากันทุกแถว
          child: Text(
            label,
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: fontSize),
          ),
        ),
        const SizedBox(width: 10),

        /// 🔥 ช่องกรอกข้อมูล
        Expanded(
          child: SizedBox(
            height: 42, // 👈 ความสูงมาตรฐานเดียวกัน
            child: child,
          ),
        ),
      ],
    ),
  );
}

/// =======================================================
/// INPUT DECORATION
/// =======================================================
InputDecoration _innerInputDecoration({bool hasIcon = false}) {
  return InputDecoration(
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    prefixIcon: hasIcon
        ? const Icon(Icons.build_circle_outlined, size: 18)
        : null,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.black),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.black),
    ),
  );
}

/// =======================================================
/// ACTION BUTTON
/// =======================================================
Widget _actionButton({
  required String label,
  required IconData icon,
  required Color color,
  required VoidCallback onPressed,
}) {
  return ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Colors.black),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [Icon(icon, size: 18), const SizedBox(width: 4), Text(label)],
    ),
  );
}
