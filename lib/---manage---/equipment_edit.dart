import 'package:flutter/material.dart';
import '/services/api_services.dart';
import 'package:intl/intl.dart';

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
          final expDateCtrl = TextEditingController(
            text: asset['expdate'] ?? '',
          );

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
                              label: 'ประเภทอุปกรณ์ :',
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

                            if (expDateCtrl.text.isNotEmpty) {
                              initialDate =
                                  DateTime.tryParse(expDateCtrl.text) ??
                                  DateTime.now();
                            }

                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate: initialDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );

                            if (pickedDate != null) {
                              expDateCtrl.text = DateFormat(
                                'dd-MM-yyyy',
                              ).format(pickedDate);
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
                                value: currentStatus,
                                isExpanded: true,
                                decoration: _innerInputDecoration(
                                  hasIcon: false,
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 1,
                                    child: Text('Active'),
                                  ),
                                  DropdownMenuItem(
                                    value: 0,
                                    child: Text('Inactive'),
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
                            onPressed: () => Navigator.pop(context, false),
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

                              final data = {
                                'name': nameCtrl.text,
                                'location': locationCtrl.text,
                                'active': activeNotifier.value,
                                'expdate': expDateCtrl.text,
                              };

                              if (fireTypeNotifier != null) {
                                data['firetype'] = fireTypeNotifier.value;
                              }

                              final success = await ApiService.updateAsset(
                                assetId,
                                data,
                              );

                              if (success && navigator.mounted) {
                                navigator.pop(true);
                              }
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
  double fontSize = 18,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.grey.shade200,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: Colors.black),
    ),
    child: Row(
      children: [
        Icon(icon, color: Colors.blue.shade600, size: 30),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: fontSize),
        ),
        const SizedBox(width: 10),
        Expanded(child: SizedBox(height: 35, child: child)),
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
