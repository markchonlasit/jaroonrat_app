// import 'package:flutter/material.dart';
// import 'package:awesome_dialog/awesome_dialog.dart';

// class Alert {
//   /// =========================
//   /// SUCCESS
//   /// =========================
//   static void success(
//     BuildContext context,
//     String message, {
//     String title = 'สำเร็จ',
//     VoidCallback? onOk,
//   }) {
//     AwesomeDialog(
//       context: context,
//       dialogType: DialogType.success,
//       animType: AnimType.scale,
//       title: title,
//       desc: message,
//       btnOkOnPress: onOk,
//     ).show();
//   }

//   /// =========================
//   /// ERROR
//   /// =========================
//   static void error(
//     BuildContext context,
//     String message, {
//     String title = 'เกิดข้อผิดพลาด',
//   }) {
//     AwesomeDialog(
//       context: context,
//       dialogType: DialogType.error,
//       animType: AnimType.shake,
//       title: title,
//       desc: message,
//       btnOkOnPress: () {},
//     ).show();
//   }

//   /// =========================
//   /// WARNING
//   /// =========================
//   static void warning(
//     BuildContext context,
//     String message, {
//     String title = 'คำเตือน',
//   }) {
//     AwesomeDialog(
//       context: context,
//       dialogType: DialogType.warning,
//       animType: AnimType.topSlide,
//       title: title,
//       desc: message,
//       btnOkOnPress: () {},
//     ).show();
//   }

//   /// =========================
//   /// INFO
//   /// =========================
//   static void info(
//     BuildContext context,
//     String message, {
//     String title = 'ข้อมูล',
//   }) {
//     AwesomeDialog(
//       context: context,
//       dialogType: DialogType.info,
//       animType: AnimType.fade,
//       title: title,
//       desc: message,
//       btnOkOnPress: () {},
//     ).show();
//   }

//   /// =========================
//   /// CONFIRM (YES / NO)
//   /// =========================
//   static void confirm(
//     BuildContext context, {
//     String title = 'ยืนยัน',
//     required String message,
//     String okText = 'ตกลง',
//     String cancelText = 'ยกเลิก',
//     required VoidCallback onConfirm,
//     VoidCallback? onCancel,
//   }) {
//     AwesomeDialog(
//       context: context,
//       dialogType: DialogType.question,
//       animType: AnimType.scale,
//       title: title,
//       desc: message,
//       btnCancelText: cancelText,
//       btnOkText: okText,
//       btnCancelOnPress: onCancel ?? () {},
//       btnOkOnPress: onConfirm,
//     ).show();
//   }

//   /// =========================
//   /// LOADING
//   /// =========================
//   static void loading(BuildContext context, {String message = 'กำลังโหลด...'}) {
//     AwesomeDialog(
//       context: context,
//       dialogType: DialogType.noHeader,
//       dismissOnTouchOutside: false,
//       dismissOnBackKeyPress: false,
//       body: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           const CircularProgressIndicator(),
//           const SizedBox(height: 16),
//           Text(message),
//         ],
//       ),
//     ).show();
//   }

//   /// =========================
//   /// CLOSE CURRENT DIALOG
//   /// =========================
//   static void close(BuildContext context) {
//     Navigator.of(context, rootNavigator: true).pop();
//   }
// }
