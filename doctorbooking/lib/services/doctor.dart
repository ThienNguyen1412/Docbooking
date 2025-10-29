import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:doctorbooking/models/doctors.dart';
import 'package:doctorbooking/models/specialty.dart';
import 'package:doctorbooking/services/specialty.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:doctorbooking/models/user.dart';

class DoctorService {
  DoctorService._private();
  static final DoctorService instance = DoctorService._private();

  static const String baseUrl = "http://192.168.111.219:5101/api/doctor";
  static const Duration _timeout = Duration(seconds: 15);

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, String>> _authHeaders() async {
    final token = await _getToken();
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  String? _extractMessage(String body) {
    if (body.isEmpty) return null;
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded['message']?.toString() ??
            decoded['error']?.toString() ??
            decoded['detail']?.toString();
      }
    } catch (_) {}
    return null;
  }

  /// GET /api/doctor
  /// Optionally pass specialtyId to filter on server if the backend supports it
  Future<List<Doctors>> fetchDoctors({String? specialtyId}) async {
    try {
      // 1) fetch specialties and build id->name map (so we can resolve specialtyId -> name)
      Map<String, String> specialityMap = {};
      try {
        final specialityService = SpecialityService(); // dùng service của bạn
        final List<Specialty> specials =
            await specialityService.ListSpecialty();
        for (final s in specials) {
          if (s.id != null && s.id.isNotEmpty) {
            specialityMap[s.id] = s.name ?? '';
          }
        }
      } catch (e) {
        // nếu không fetch được specialties, chúng ta vẫn tiếp tục; doctors sẽ có specialtyName trống
        debugPrint('Warning: failed to load specialties map: $e');
      }

      // 2) fetch doctors
      final headers = await _authHeaders();
      final uri = Uri.parse(baseUrl).replace(
        queryParameters: {
          if (specialtyId != null && specialtyId.isNotEmpty)
            'specialtyId': specialtyId,
        },
      );

      final response = await http.get(uri, headers: headers).timeout(_timeout);

      // debug logging (tắt trong production)
      // debugPrint(
      //   'fetchDoctors: status=${response.statusCode}, body=${response.body}',
      // );

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);

        List<dynamic> rawList = [];
        if (decoded is List) {
          rawList = decoded;
        } else if (decoded is Map<String, dynamic>) {
          // try common wrappers
          if (decoded['data'] is List)
            rawList = decoded['data'] as List;
          else if (decoded['items'] is List)
            rawList = decoded['items'] as List;
          else if (decoded['doctors'] is List)
            rawList = decoded['doctors'] as List;
          else {
            // fallback: try to find first list in values
            rawList =
                decoded.values.firstWhere(
                      (v) => v is List,
                      orElse: () => <dynamic>[],
                    )
                    as List<dynamic>;
          }
        } else {
          throw Exception('Unexpected response format from server.');
        }

        final doctors = rawList.map<Doctors>((e) {
          final map = e as Map<String, dynamic>;
          // pass specialityMap so fromJson can resolve specialtyId -> name
          return Doctors.fromJson(map, specialityMap: specialityMap);
        }).toList();

        return doctors;
      } else if (response.statusCode == 204) {
        return <Doctors>[];
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please log in again.');
      } else {
        String msg = 'HTTP ${response.statusCode}';
        try {
          final parsed = jsonDecode(response.body);
          if (parsed is Map && parsed['message'] != null)
            msg = parsed['message'].toString();
        } catch (_) {}
        throw Exception('Failed to load doctors: $msg');
      }
    } on SocketException {
      throw Exception(
        'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng.',
      );
    } on TimeoutException {
      throw Exception('Yêu cầu quá thời gian. Vui lòng thử lại.');
    }
  }

  /// GET /api/doctor/{id}
  Future<Doctors> getDoctorById(String id) async {
    try {
      final headers = await _authHeaders();
      final uri = Uri.parse('$baseUrl/$id');

      final response = await http.get(uri, headers: headers).timeout(_timeout);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        // If API returns wrapper { data: { ... } }
        if (decoded is Map<String, dynamic> && decoded['data'] is Map) {
          return Doctors.fromJson(decoded['data'] as Map<String, dynamic>);
        }
        return Doctors.fromJson(decoded as Map<String, dynamic>);
      } else if (response.statusCode == 404) {
        throw Exception('Doctor not found.');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please log in again.');
      } else {
        final msg =
            _extractMessage(response.body) ?? 'HTTP ${response.statusCode}';
        throw Exception('Failed to load doctor: $msg');
      }
    } on SocketException {
      throw Exception('No network connection. Please check your internet.');
    } on TimeoutException {
      throw Exception('Request timed out. Please try again later.');
    }
  }

  /// POST /api/doctor
  /// Accepts either specialtyId OR specialtyName (backend supports both per your API)
  Future<Doctors> createDoctor({
    required String fullName,
    String? hospital,
    String? specialtyId,
    String? specialtyName,
    String? phone,
    String? avatarUrl,
  }) async {
    if ((specialtyId == null || specialtyId.isEmpty) &&
        (specialtyName == null || specialtyName.isEmpty)) {
      throw Exception('Either specialtyId or specialtyName must be provided.');
    }

    final body = <String, dynamic>{
      'fullName': fullName,
      if (hospital != null) 'hospital': hospital,
      if (specialtyId != null && specialtyId.isNotEmpty)
        'specialtyId': specialtyId,
      if (specialtyName != null && specialtyName.isNotEmpty)
        'specialtyName': specialtyName,
      if (phone != null) 'phone': phone,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
    };

    try {
      final headers = await _authHeaders();
      final uri = Uri.parse(baseUrl);

      final response = await http
          .post(uri, headers: headers, body: jsonEncode(body))
          .timeout(_timeout);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        // If API returns wrapper with data
        if (decoded is Map<String, dynamic> && decoded['data'] is Map) {
          return Doctors.fromJson(decoded['data'] as Map<String, dynamic>);
        }
        return Doctors.fromJson(decoded as Map<String, dynamic>);
      } else if (response.statusCode == 400) {
        final msg = _extractMessage(response.body) ?? 'Bad request';
        throw Exception(msg);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please log in again.');
      } else {
        final msg =
            _extractMessage(response.body) ?? 'HTTP ${response.statusCode}';
        throw Exception('Failed to create doctor: $msg');
      }
    } on SocketException {
      throw Exception('No network connection. Please check your internet.');
    } on TimeoutException {
      throw Exception('Request timed out. Please try again later.');
    }
  }

  /// PUT /api/doctor/{id}
  Future<Doctors> updateDoctor({
    required String id,
    String? fullName,
    String? hospital,
    String? specialtyId,
    String? specialtyName,
    String? phone,
    String? avatarUrl,
  }) async {
    final body = <String, dynamic>{
      if (fullName != null) 'fullName': fullName,
      if (hospital != null) 'hospital': hospital,
      if (specialtyId != null) 'specialtyId': specialtyId,
      if (specialtyName != null) 'specialtyName': specialtyName,
      if (phone != null) 'phone': phone,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
    };

    try {
      final headers = await _authHeaders();
      final uri = Uri.parse('$baseUrl/$id');

      final response = await http
          .put(uri, headers: headers, body: jsonEncode(body))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded['data'] is Map) {
          return Doctors.fromJson(decoded['data'] as Map<String, dynamic>);
        }
        return Doctors.fromJson(decoded as Map<String, dynamic>);
      } else if (response.statusCode == 400) {
        final msg = _extractMessage(response.body) ?? 'Bad request';
        throw Exception(msg);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please log in again.');
      } else {
        final msg =
            _extractMessage(response.body) ?? 'HTTP ${response.statusCode}';
        throw Exception('Failed to update doctor: $msg');
      }
    } on SocketException {
      throw Exception('No network connection. Please check your internet.');
    } on TimeoutException {
      throw Exception('Request timed out. Please try again later.');
    }
  }

  /// DELETE /api/doctor/{id}
  Future<void> deleteDoctor(String id) async {
    try {
      final headers = await _authHeaders();
      final uri = Uri.parse('$baseUrl/$id');

      final response = await http
          .delete(uri, headers: headers)
          .timeout(_timeout);

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please log in again.');
      } else {
        final msg =
            _extractMessage(response.body) ?? 'HTTP ${response.statusCode}';
        throw Exception('Failed to delete doctor: $msg');
      }
    } on SocketException {
      throw Exception('No network connection. Please check your internet.');
    } on TimeoutException {
      throw Exception('Request timed out. Please try again later.');
    }
  }
}
