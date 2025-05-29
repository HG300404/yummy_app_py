import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl;

  ApiService(this.baseUrl);

  // Hàm lấy user_id từ SharedPreferences (nên để ngoài hoặc trong service user riêng)
  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }

  // Hàm lấy thông tin user qua API
  Future<Map<String, dynamic>?> getUserInfo(int userId) async {
    final url = Uri.parse('$baseUrl/user/getUser/$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'name': data['name'],
        'email': data['email'],
      };
    } else {
      print('Lỗi lấy thông tin user: ${response.statusCode}');
      return null;
    }
  }
}
