import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../main.dart';
import '/---login---/login.dart';
 import 'package:http_parser/http_parser.dart'; 

class ApiClient {
  static const String baseUrl = 'https://api.jaroonrat.com/safetyaudit';

  static Map<String, String> get headers => {
    'Authorization': 'Bearer ${AuthService.token}',
    'Content-Type': 'application/json',
  };

  static Uri url(String path) {
    return Uri.parse('$baseUrl$path');
  }

  static Future<http.Response> get(String path) async {
    final response = await http.get(url(path), headers: headers);

    _check401(response);
    return response;
  }

  // เพิ่ม import นี้ด้านบน (มีอยู่แล้ว)
  // import 'package:http/http.dart' as http;

// ← เพิ่ม import นี้

static Future<http.Response> postMultipart(
  String path, {
  required File imageFile,
  required Map<String, String> fields,
}) async {
  final request = http.MultipartRequest('POST', url(path));
  request.headers['Authorization'] = 'Bearer ${AuthService.token}';
  request.fields.addAll(fields);

  request.files.add(await http.MultipartFile.fromPath(
    'file',
    imageFile.path,
    contentType: MediaType('image', 'jpeg'), // ← เพิ่มบรรทัดนี้
  ));

  final streamed = await request.send();
  final response = await http.Response.fromStream(streamed);
  _check401(response);
  return response;
}

  static Future<http.Response> post(String path, dynamic body) async {
    final response = await http.post(
      url(path),
      headers: headers,
      body: jsonEncode(body),
    );

    _check401(response);
    return response;
  }

  static Future<http.Response> put(String path, dynamic body) async {
    final response = await http.put(
      url(path),
      headers: headers,
      body: jsonEncode(body),
    );

    _check401(response);
    return response;
  }

  static void _check401(http.Response response) {
    if (response.statusCode == 401) {
      AuthService.logout();

      final context = navigatorKey.currentContext;

      if (context == null) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.lock_outline,
                    size: 48,
                    color: Colors.orange,
                  ),

                  const SizedBox(height: 14),

                  const Text(
                    "การเข้าสู่ระบบหมดอายุ",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 14),

                  const Text(
                    "การเข้าสู่ระบบของคุณหมดอายุ\nกรุณาเข้าสู่ระบบใหม่",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: 140,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue, // สีพื้นปุ่ม
                        foregroundColor: Colors.white, // สีตัวอักษร
                        side: const BorderSide(
                          // สีกรอบปุ่ม
                          color: Colors.blue,
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text("ตกลง"),
                      onPressed: () {
                        navigatorKey.currentState!.pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                          (route) => false,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }
}
