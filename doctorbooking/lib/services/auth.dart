import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:doctorbooking/models/user.dart';

class AuthService {
  // Update this to match your backend
  static const String baseUrl = "https://103f6194a519.ngrok-free.app/api/auth";

  // Keys for SharedPreferences
  static const String _kTokenKey = 'auth_token';
  static const String _kUserKey = 'auth_user';
  static const String _kExpiryKey = 'auth_expiry';

  // Singleton
  AuthService._private();
  static final AuthService instance = AuthService._private();

  /// Register user. Returns true on success, otherwise throws an Exception
  Future<bool> register(String fullname, String email, String password) async {
    final url = Uri.parse('$baseUrl/register');
    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'fullname': fullname,
              'email': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }

      // Try parse error message from server
      try {
        final body = jsonDecode(response.body);
        final msg = (body is Map && body['message'] != null) ? body['message'] : response.body;
        throw Exception(msg);
      } catch (_) {
        throw Exception('Đăng ký thất bại. Status: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Yêu cầu đăng ký quá thời gian, vui lòng thử lại.');
    } catch (e) {
      rethrow;
    }
  }

  /// Login and persist token+user with a default validity of 2 days.
  /// Returns the User on success, otherwise throws an Exception.
  Future<User> login(String email, String password, {Duration validity = const Duration(days: 2)}) async {
    final url = Uri.parse('$baseUrl/login');
    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        // Attempt to extract server message
        try {
          final body = jsonDecode(response.body);
          final msg = (body is Map && body['message'] != null) ? body['message'] : response.body;
          throw Exception(msg);
        } catch (_) {
          throw Exception('Đăng nhập thất bại. Status: ${response.statusCode}');
        }
      }

      final dynamic data = jsonDecode(response.body);

      // Defensive extraction of token and user object
      String? token;
      dynamic userJson;
      if (data is Map<String, dynamic>) {
        token = data['token'] ?? data['accessToken'] ?? data['data']?['token'];
        userJson = data['user'] ?? data['data']?['user'] ?? data['data'] ?? data;
      } else {
        throw Exception('Unexpected login response format from server.');
      }

      if (token == null) {
        // Some APIs might return token inside data: { token: ..., user: {...} }
        // If still null, try nested parse
        if (userJson is Map<String, dynamic> && (userJson['token'] != null)) {
          token = userJson['token'];
        }
      }

      if (userJson == null) {
        throw Exception('Server did not return user data.');
      }

      final prefs = await SharedPreferences.getInstance();
      // Persist token, user JSON and expiry
      final expiryMillis = DateTime.now().add(validity).millisecondsSinceEpoch;
      await prefs.setString(_kTokenKey, token ?? '');
      await prefs.setString(_kUserKey, jsonEncode(userJson));
      await prefs.setInt(_kExpiryKey, expiryMillis);

      // Build User instance
      final Map<String, dynamic> userMap = (userJson is Map<String, dynamic>)
          ? userJson
          : (userJson is String ? jsonDecode(userJson) as Map<String, dynamic> : Map<String, dynamic>.from(userJson));

      return User.fromJson(userMap);
    } on TimeoutException {
      throw Exception('Yêu cầu đăng nhập quá thời gian, vui lòng thử lại.');
    } catch (e) {
      rethrow;
    }
  }

  /// Persist an already obtained token & user (useful if you get them elsewhere)
  Future<void> persistLogin({required String token, required User user, Duration validity = const Duration(days: 2)}) async {
    final prefs = await SharedPreferences.getInstance();
    final expiryMillis = DateTime.now().add(validity).millisecondsSinceEpoch;
    await prefs.setString(_kTokenKey, token);
    await prefs.setString(_kUserKey, jsonEncode(user.toJson()));
    await prefs.setInt(_kExpiryKey, expiryMillis);
  }

  /// Clear stored auth data (logout)
  Future<void> clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kTokenKey);
    await prefs.remove(_kUserKey);
    await prefs.remove(_kExpiryKey);
  }

  /// Returns token if exists and not expired, otherwise null (and clears storage)
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_kTokenKey);
    final expiry = prefs.getInt(_kExpiryKey);
    if (token == null || token.isEmpty || expiry == null) return null;
    if (DateTime.now().millisecondsSinceEpoch > expiry) {
      await clearAuth();
      return null;
    }
    return token;
  }

  /// Returns stored User if present and not expired, otherwise null (and clears storage)
  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kUserKey);
    final expiry = prefs.getInt(_kExpiryKey);
    if (raw == null || expiry == null) return null;
    if (DateTime.now().millisecondsSinceEpoch > expiry) {
      await clearAuth();
      return null;
    }
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return User.fromJson(map);
    } catch (e) {
      await clearAuth();
      return null;
    }
  }

  /// Try auto login and return User if successful (not expired), null otherwise
  Future<User?> tryAutoLogin() async {
    return getUser();
  }

  /// Check if logged in (token exists and not expired)
  Future<bool> isLoggedIn() async {
    final t = await getToken();
    return t != null;
  }

  /// Extend expiry by given duration (useful to refresh expiry on user activity)
  Future<void> extendExpiry({Duration extendBy = const Duration(days: 2)}) async {
    final prefs = await SharedPreferences.getInstance();
    final expiry = prefs.getInt(_kExpiryKey);
    if (expiry == null) return;
    final newExpiry = DateTime.now().add(extendBy).millisecondsSinceEpoch;
    await prefs.setInt(_kExpiryKey, newExpiry);
  }

  /// Seconds until expiry, or null if not logged in
  Future<int?> secondsUntilExpiry() async {
    final prefs = await SharedPreferences.getInstance();
    final expiry = prefs.getInt(_kExpiryKey);
    if (expiry == null) return null;
    final diff = expiry - DateTime.now().millisecondsSinceEpoch;
    if (diff <= 0) {
      await clearAuth();
      return null;
    }
    return (diff / 1000).round();
  }
}