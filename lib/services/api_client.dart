import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ApiClient {
  static const String baseUrl =
      'https://api.jaroonrat.com/safetyaudit';

  static Map<String, String> get headers => {
        'Authorization': 'Bearer ${AuthService.token}',
        'Content-Type': 'application/json',
      };

  static Uri url(String path) {
    return Uri.parse('$baseUrl$path');
  }

  static Future<http.Response> get(String path) {
    return http.get(url(path), headers: headers);
  }

  static Future<http.Response> post(String path, dynamic body) {
    return http.post(url(path), headers: headers, body: body);
  }

  static Future<http.Response> put(String path, dynamic body) {
    return http.put(url(path), headers: headers, body: body);
  }
}