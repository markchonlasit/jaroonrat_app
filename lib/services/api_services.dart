import 'dart:convert';
import 'api_client.dart';

class ApiService {
  // PROFILE
  static Future<Map<String, dynamic>> getProfile() async {
    final res = await ApiClient.get('/api/profile');
    return jsonDecode(res.body);
  }

  // CATEGORY
  // CATEGORY
  static Future<List<dynamic>> getCategory() async {
    final res = await ApiClient.get('/api/category');
    return jsonDecode(res.body);
  }

  // ASSET LIST (categoryId)
  static Future<List<dynamic>> getAssetList(int categoryId) async {
    final res = await ApiClient.get('/api/assetlist/$categoryId');
    return jsonDecode(res.body);
  }

  // ASSET DETAIL (id)
  static Future<Map<String, dynamic>> getAsset(int id) async {
    final res = await ApiClient.get('/api/asset/$id');
    return jsonDecode(res.body);
  }

  // UPDATE ASSET
  static Future<bool> updateAsset(int id, Map<String, dynamic> data) async {
    final res = await ApiClient.put('/api/asset/$id', jsonEncode(data));
    return res.statusCode == 200;
  }

  // CHECKLIST (categoryId / assetId)
  static Future<List<dynamic>> getChecklist(int categoryId, int assetId) async {
    final res = await ApiClient.get('/api/checklist/$categoryId/$assetId');
    return jsonDecode(res.body);
  }

  // SUBMIT AUDIT
  static Future<bool> submitAudit(Map<String, dynamic> body) async {
    final res = await ApiClient.post('/api/submitaudit', jsonEncode(body));
    return res.statusCode == 200;
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
}
