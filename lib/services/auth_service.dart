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
          'token': token
        };

      }

      if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'username หรือ password ไม่ถูกต้อง'
        };
      }

      return {
        'success': false,
        'message': 'ไม่สามารถเข้าสู่ระบบได้'
      };

    } catch (e) {

      return {
        'success': false,
        'message': 'ไม่สามารถเชื่อมต่อ Server ได้'
      };

    }

  }

  static void logout() {
    token = null;
    username = null;
  }
}