import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';

class AppAlert {
  /// =========================
  /// 1. SUCCESS
  /// =========================
  static void success(BuildContext context, String message) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      text: message,
      showConfirmBtn: false,
      barrierDismissible: false,
    );

    Future.delayed(const Duration(seconds: 1), () {
      if (context.mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    });
  }

  /// =========================
  /// 2. ERROR
  /// =========================
  static void error(BuildContext context, String message) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      text: message,
    );
  }

  /// =========================
  /// 3. WARNING
  /// =========================
  static void warning(BuildContext context, String message) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.warning,
      text: message,
    );
  }

  /// =========================
  /// 4. LOADING
  /// =========================
  static void loading(BuildContext context, {String message = "กำลังโหลด..."}) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.loading,
      text: message,
      barrierDismissible: false,
    );
  }

  static void close(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  /// =========================
  /// 5. SUCCESS + CONFIRM
  /// =========================
  static void successConfirm(
    BuildContext context,
    String message, {
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
  }) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      text: message,
      confirmBtnText: "ตกลง",
      cancelBtnText: "ยกเลิก",
      showCancelBtn: true,
      barrierDismissible: false,

      onConfirmBtnTap: () {
        Navigator.pop(context); // ปิด dialog
        onConfirm();
      },

      onCancelBtnTap: () {
        Navigator.pop(context); // ปิด dialog
        if (onCancel != null) {
          onCancel();
        }
      },
    );
  }
}
