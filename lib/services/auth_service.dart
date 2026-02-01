import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl =
      'https://api.jaroonrat.com/safetyaudit';

  static String? token;
  static String? username;

  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        token = data['token'];

        return {
          'success': true,
          'token': token,
        };
      }

      return {
        'success': false,
        'message': 'Login ไม่สำเร็จ',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'เชื่อมต่อเซิร์ฟเวอร์ไม่ได้',
      };
    }
  }
}