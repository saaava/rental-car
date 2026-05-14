import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:contoh_modul6/config/api_config.dart';
import 'package:contoh_modul6/models/user_model.dart';

class AuthService {
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    String? role,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', accessToken);
    await prefs.setString('refreshToken', refreshToken);
    if (role != null) {
      await prefs.setString('role', role);
    }
  }

    

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
    await prefs.remove('role');
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<Map<String, String>> _authHeaders([String? token]) async {
    token ??= await getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<http.Response> authenticatedRequest({
    required String method,
    required Uri url,
    Map<String, dynamic>? body,
  }) async {
    var headers = await _authHeaders();
    var response = await _sendRequest(method, url, headers, body);

    if (response.statusCode == 401) {
      final newToken = await refreshToken();
      if (newToken != null) {
        headers = await _authHeaders(newToken);
        response = await _sendRequest(method, url, headers, body);
      }
    }

    return response;
  }

  static Future<http.Response> _sendRequest(
    String method,
    Uri url,
    Map<String, String> headers,
    Map<String, dynamic>? body,
  ) async {
    switch (method.toUpperCase()) {
      case 'GET':
        return await http.get(url, headers: headers);
      case 'POST':
        return await http.post(url, headers: headers, body: json.encode(body));
      case 'PUT':
        return await http.put(url, headers: headers, body: json.encode(body));
      case 'DELETE':
        return await http.delete(url, headers: headers);
      default:
        throw Exception('HTTP method $method tidak didukung');
    }
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}${ApiConfig.authPrefix}/register',
    );

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
      }),
    );

    final body = json.decode(response.body);

    if (response.statusCode == 201) {
      final data = body['data'];
      final user = UserModel.fromJson(data['user']);
      final accessToken = data['accessToken'] as String;
      final refreshToken = data['refreshToken'] as String;

      await saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
        role: user.role,
      );

      return {
        'user': user,
        'accessToken': accessToken,
        'refreshToken': refreshToken,
      };
    } else {
      throw Exception(body['message'] ?? 'Registrasi gagal');
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.authPrefix}/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    final body = json.decode(response.body);

    if (response.statusCode == 200) {
      final data = body['data'];
      final user = UserModel.fromJson(data['user']);
      final accessToken = data['accessToken'] as String;
      final refreshToken = data['refreshToken'] as String;

      // Simpan token
      await saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
        role: user.role,
      );

      return {
        'user': user,
        'accessToken': accessToken,
        'refreshToken': refreshToken,
      };
    } else {
      throw Exception(body['message'] ?? 'Login gagal');
    }
  }

  static Future<UserModel> getMe() async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.authPrefix}/me');

    final response = await authenticatedRequest(method: 'GET', url: url);
    final body = json.decode(response.body);

    if (response.statusCode == 200) {
      return UserModel.fromJson(body['data']['user']);
    } else {
      throw Exception(body['message'] ?? 'Gagal mengambil data profil');
    }
  }

  static Future<void> logout() async {
    try {
      final url = Uri.parse(
        '${ApiConfig.baseUrl}${ApiConfig.authPrefix}/logout',
      );
      await authenticatedRequest(method: 'POST', url: url);
    } catch (e) {
      print("error logout : $e");
    }
    await clearTokens();
  }

  static Future<String?> refreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refreshToken');

    if (refreshToken == null || refreshToken.isEmpty) {
      return null;
    }

    try {
      final url = Uri.parse(
        '${ApiConfig.baseUrl}${ApiConfig.authPrefix}/refresh',
      );

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'refreshToken': refreshToken}),
      );

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        final data = body['data'];
        final newAccessToken = data['accessToken'] as String;
        final newRefreshToken = data['refreshToken'] as String;

        await saveTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
        );

        return newAccessToken;
      } else {
        await clearTokens();
        return null;
      }
    } catch (e) {
      print('Error refresh token: $e');
      await clearTokens();
      return null;
    }
  }
}
