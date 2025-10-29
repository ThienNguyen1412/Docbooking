import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class UserService {
  static const String baseUrl = "http://192.168.111.219:5101/api/user";
  static const Duration _timeout = Duration(seconds: 15);

  // Try multiple keys for backwards compatibility with different token keys
  Future<String?> _getTokenFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final keysToTry = ['token', 'auth_token', 'authToken', 'accessToken', 'Authorization'];
    for (final key in keysToTry) {
      final t = prefs.getString(key);
      if (t != null && t.isNotEmpty) return t;
    }
    // Fallback: try stored user object that might include token
    final rawUser = prefs.getString('auth_user') ?? prefs.getString('user');
    if (rawUser != null && rawUser.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawUser);
        if (decoded is Map<String, dynamic>) {
          final v = decoded['token'] ?? decoded['accessToken'] ?? decoded['authToken'];
          if (v is String && v.isNotEmpty) return v;
        }
      } catch (_) {}
    }
    return null;
  }

  Future<Map<String, String>> _authHeaders() async {
    final token = await _getTokenFromPrefs();
    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found. Vui lòng đăng nhập lại.');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  String? _extractMessage(String body) {
    if (body.isEmpty) return null;
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded['message']?.toString() ?? decoded['error']?.toString() ?? decoded['detail']?.toString();
      }
    } catch (_) {}
    return null;
  }

  Map<String, dynamic> _normalizeUserJson(dynamic jsonBody) {
    if (jsonBody is Map<String, dynamic>) {
      if (jsonBody['data'] is Map && (jsonBody['data']['id'] != null || jsonBody['data']['fullName'] != null)) {
        return Map<String, dynamic>.from(jsonBody['data'] as Map);
      }
      if (jsonBody['user'] is Map && (jsonBody['user']['id'] != null || jsonBody['user']['fullName'] != null)) {
        return Map<String, dynamic>.from(jsonBody['user'] as Map);
      }
      return jsonBody;
    } else {
      try {
        final parsed = jsonDecode(jsonBody.toString());
        if (parsed is Map<String, dynamic>) return parsed;
      } catch (_) {}
    }
    return <String, dynamic>{};
  }

  // Change password
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    final url = Uri.parse('$baseUrl/change-password');
    try {
      final headers = await _authHeaders();
      final response = await http
          .put(
            url,
            headers: headers,
            body: jsonEncode({'oldPassword': oldPassword, 'newPassword': newPassword}),
          )
          .timeout(_timeout);

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      }

      final msg = _extractMessage(response.body);
      throw Exception(msg ?? 'Thay đổi mật khẩu thất bại. Status: ${response.statusCode}');
    } on SocketException {
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng.');
    } on TimeoutException {
      throw Exception('Yêu cầu quá thời gian. Vui lòng thử lại.');
    }
  }

  // Get user by id
  Future<User> getUserById(String id) async {
    final url = Uri.parse('$baseUrl/$id');
    try {
      final headers = await _authHeaders();
      final response = await http.get(url, headers: headers).timeout(_timeout);

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        return User.fromJson(_normalizeUserJson(jsonBody));
      } else if (response.statusCode == 404) {
        throw Exception('User not found.');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please log in again.');
      } else {
        final msg = _extractMessage(response.body);
        throw Exception(msg ?? 'Failed to load user data. Status: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng.');
    } on TimeoutException {
      throw Exception('Yêu cầu quá thời gian. Vui lòng thử lại.');
    }
  }

  // Update user - camelCase name and also keep legacy UpdateUserInfo
  Future<User> updateUserInfo(
    String id,
    String fullName,
    String email,
    String phone,
    String address,
    DateTime birthDay,
    String gender,
  ) async {
    final url = Uri.parse('$baseUrl/update-user/$id');
    try {
      final headers = await _authHeaders();
      final response = await http
          .put(
            url,
            headers: headers,
            body: jsonEncode({
              'fullName': fullName,
              'email': email,
              'phone': phone,
              'address': address,
              'birthDay': birthDay.toIso8601String(),
              'gender': gender,
            }),
          )
          .timeout(_timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonBody = jsonDecode(response.body);
        return User.fromJson(_normalizeUserJson(jsonBody));
      } else {
        final msg = _extractMessage(response.body);
        throw Exception(msg ?? 'Failed to update user information. Status: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng.');
    } on TimeoutException {
      throw Exception('Yêu cầu quá thời gian. Vui lòng thử lại.');
    }
  }

  // Legacy alias (keeps existing call sites working)
  Future<User> UpdateUserInfo(
    String id,
    String fullName,
    String email,
    String phone,
    String address,
    DateTime birthDay,
    String gender,
  ) {
    return updateUserInfo(id, fullName, email, phone, address, birthDay, gender);
  }

  // Get current user
  Future<User> getCurrentUser() async {
    final url = Uri.parse('$baseUrl/me');
    try {
      final headers = await _authHeaders();
      final response = await http.get(url, headers: headers).timeout(_timeout);

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        return User.fromJson(_normalizeUserJson(jsonBody));
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please log in again.');
      } else {
        final msg = _extractMessage(response.body);
        throw Exception(msg ?? 'Failed to load current user data. Status: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng.');
    } on TimeoutException {
      throw Exception('Yêu cầu quá thời gian. Vui lòng thử lại.');
    }
  }

  // Get list of users (supports different response formats)
  Future<List<User>> getAllUsers({int? page, int? pageSize, String? query}) async {
    try {
      final headers = await _authHeaders();
      final uri = Uri.parse(baseUrl).replace(queryParameters: {
        if (page != null) 'page': page.toString(),
        if (pageSize != null) 'pageSize': pageSize.toString(),
        if (query != null && query.isNotEmpty) 'q': query,
      });

      final response = await http.get(uri, headers: headers).timeout(_timeout);

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);

        List<dynamic> rawList = [];
        if (decoded is List) {
          rawList = decoded;
        } else if (decoded is Map<String, dynamic>) {
          if (decoded['data'] is List) {
            rawList = decoded['data'] as List;
          } else if (decoded['users'] is List) {
            rawList = decoded['users'] as List;
          } else if (decoded['items'] is List) {
            rawList = decoded['items'] as List;
          } else {
            rawList = decoded.values.firstWhere(
              (v) => v is List,
              orElse: () => <dynamic>[],
            ) as List<dynamic>;
          }
        } else {
          throw Exception('Unexpected response format from server.');
        }

        final users = rawList.where((e) => e != null).map<User>((e) {
          if (e is Map<String, dynamic>) {
            return User.fromJson(_normalizeUserJson(e));
          } else if (e is String) {
            final parsed = jsonDecode(e);
            return User.fromJson(_normalizeUserJson(parsed as Map<String, dynamic>));
          } else {
            return User.fromJson(_normalizeUserJson(Map<String, dynamic>.from(e as Map)));
          }
        }).toList();

        return users;
      } else if (response.statusCode == 204) {
        return <User>[];
      } else {
        final msg = _extractMessage(response.body);
        throw Exception(msg ?? 'Failed to load users: HTTP ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng.');
    } on TimeoutException {
      throw Exception('Yêu cầu quá thời gian. Vui lòng thử lại.');
    }
  }

  // Delete user
  Future<String> deleteUser(String id) async {
    final url = Uri.parse('$baseUrl/$id');
    try {
      final headers = await _authHeaders();
      final response = await http.delete(url, headers: headers).timeout(_timeout);

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (response.body.isEmpty) return 'Xóa người dùng thành công.';
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        return jsonData['message'] ?? 'Xóa người dùng thành công.';
      } else {
        final msg = _extractMessage(response.body);
        throw Exception(msg ?? 'Không thể xóa người dùng. Status: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng.');
    } on TimeoutException {
      throw Exception('Yêu cầu quá thời gian. Vui lòng thử lại.');
    }
  }
}