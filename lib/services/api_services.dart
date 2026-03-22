import 'dart:convert';
import 'api_client.dart';

class ApiResponse {
  final int statusCode;
  final String message;

  ApiResponse({required this.statusCode, required this.message});
}

class ApiService {
  // PROFILE
  static Future<Map<String, dynamic>> getProfile() async {
    final res = await ApiClient.get('/api/profile');
    return jsonDecode(res.body);
  }

  // CATEGORY
  static Future<List<dynamic>> getCategory() async {
    final res = await ApiClient.get('/api/category');
    return jsonDecode(res.body) as List<dynamic>;
  }

  // ASSET LIST (categoryId)
  static Future<Map<String, dynamic>> getAssetList(int categoryId) async {
    final res = await ApiClient.get('/api/assetlist/$categoryId');
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  // ASSET DETAIL (id)
  static Future<Map<String, dynamic>> getAsset(int id) async {
    final res = await ApiClient.get('/api/asset/$id');
    return jsonDecode(res.body);
  }


  // UPDATE ASSET
  static Future<ApiResponse> updateAsset(
    int id,
    Map<String, dynamic> data,
  ) async {
    final res = await ApiClient.put('/api/asset/$id', data);

    String message = "error";

    try {
      final body = jsonDecode(res.body);
      message = body['message'] ?? body['error'] ?? message;
    } catch (_) {}

    return ApiResponse(statusCode: res.statusCode, message: message);
  }

  // CHECKLIST (categoryId / assetId)
  static Future<List<dynamic>> getChecklist(int categoryId, int assetId) async {
    final res = await ApiClient.get('/api/checklist/$categoryId/$assetId');
    return jsonDecode(res.body);
  }

  // SUBMIT AUDIT
  static Future<ApiResponse> submitAudit(Map<String, dynamic> data) async {
    final res = await ApiClient.post('/api/submitaudit', data);

    String message = "error";

    try {
      final body = jsonDecode(res.body);
      message = body['message'] ?? body['error'] ?? message;
    } catch (_) {}

    return ApiResponse(statusCode: res.statusCode, message: message);
  }

  // AUDIT LIST (assetId)
  static Future<List<dynamic>> getAudit(int assetId) async {
    final res = await ApiClient.get('/api/audit/$assetId');
    return jsonDecode(res.body);
  }

  // AUDIT DETAIL (id)
  static Future<Map<String, dynamic>> getAuditDetail(int id) async {
    final res = await ApiClient.get('/api/auditdetail/$id');
    return jsonDecode(res.body);
  }

  // totalDashboard
  static Future<Map<String, dynamic>> gettotalDashboard() async {
    final res = await ApiClient.get('/api/dashboard');
    return jsonDecode(res.body);
  }

  // categoryDashboard (categoryId / assetId)
  static Future<Map<String, dynamic>> getCategoryDashboard(
    int categoryId,
    int month,
  ) async {
    final res = await ApiClient.get('/api/dashboard/$categoryId/$month');
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  // Assetexpdate (categoryid)
  static Future<Map<String, dynamic>> getAssetexpdate(int categoryId) async {
    final res = await ApiClient.get('/api/assetexpdate/$categoryId');
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  // Alert
  static Future<Map<String, dynamic>> getAlert() async {
    final res = await ApiClient.get('/api/alert');
    return jsonDecode(res.body);
  }

  // Asset History(id)
  static Future<List<dynamic>> getAssetHistory(int id) async {
    final res = await ApiClient.get('/api/asset/logs/$id');
    return jsonDecode(res.body);
  }

  // UPLOAD PICTURE
  static Future<bool> uploadpicture(Map<String, dynamic> body) async {
    final res = await ApiClient.post('/api/uploadpicture', jsonEncode(body));
    return res.statusCode == 200;
  }

  // UPDATE AUDIT
  static Future<ApiResponse> updateaudit(
    int id,
    Map<String, dynamic> data,
  ) async {
    final res = await ApiClient.put('/api/audit/$id', data);

    String message = "error";

    try {
      final body = jsonDecode(res.body);
      message = body['message'] ?? body['error'] ?? message;
    } catch (_) {}

    return ApiResponse(statusCode: res.statusCode, message: message);
  }

  // AUDIT HISTORY (assetId)
  static Future<List<dynamic>> getAuditHistory(int assetId) async {
    final res = await ApiClient.get('/api/audit/$assetId');

    final data = jsonDecode(res.body);

    if (data == null) {
      return [];
    }

    if (data is List) {
      return data;
    }

    if (data is Map<String, dynamic>) {
      return [data]; // แปลง Map เป็น List
    }

    return [];
  }
}
