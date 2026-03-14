import 'package:flutter/material.dart';
import 'api_services.dart';
import '../utils/app_alert.dart';

class ApiAlert {

  /// -------------------------
  /// GET API
  /// ถ้า status = 200 ไม่ต้อง popup
  /// ถ้า error ค่อย popup
  /// -------------------------
  static Future<void> handleGet(
    BuildContext context,
    ApiResponse res,
  ) async {

    if (res.statusCode == 200) {
      return; // ไม่ต้องแสดงอะไร
    }

    final message = res.message;

    if (res.statusCode == 401 || res.statusCode == 404) {
      AppAlert.warning(context, message);
    }

    else if (res.statusCode >= 400 && res.statusCode < 500) {
      AppAlert.error(context, message);
    }

    else if (res.statusCode >= 500) {
      AppAlert.error(context, message);
    }

    else {
      AppAlert.error(context, message);
    }
  }

  /// -------------------------
  /// POST / PUT / DELETE
  /// ดักทุก status
  /// -------------------------
  static Future<void> handleAction(
    BuildContext context,
    ApiResponse res,
  ) async {

    final message = res.message;

    // 🟢 success
    if (res.statusCode == 200) {
      AppAlert.success(context, message);
    }

    // 🔵 conflict
    else if (res.statusCode == 409) {
      AppAlert.warning(context, message);
    }

    // 🟡 auth / not found
    else if (res.statusCode == 401 || res.statusCode == 404) {
      AppAlert.warning(context, message);
    }

    // 🔴 client error
    else if (res.statusCode >= 400 && res.statusCode < 500) {
      AppAlert.error(context, message);
    }

    // 🔴 server error
    else if (res.statusCode >= 500) {
      AppAlert.error(context, message);
    }

    else {
      AppAlert.error(context, message);
    }
  }
}