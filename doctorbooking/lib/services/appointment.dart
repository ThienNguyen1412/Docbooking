import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/appointments.dart';

class AppointmentService {
  AppointmentService._privateConstructor();
  static final AppointmentService instance =
      AppointmentService._privateConstructor();

  // Change to your backend base URL if different
  static const String _baseUrl = 'https://103f6194a519.ngrok-free.app/api/appointment';
  static const Duration _timeout = Duration(seconds: 15);

  // Try multiple token keys for backwards compatibility
  Future<String?> _getTokenFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final keysToTry = [
      'token',
      'auth_token',
      'authToken',
      'accessToken',
      'Authorization',
    ];
    for (final key in keysToTry) {
      final t = prefs.getString(key);
      if (t != null && t.isNotEmpty) return t;
    }
    // fallback to stored user object possibly containing token
    final rawUser = prefs.getString('auth_user') ?? prefs.getString('user');
    if (rawUser != null && rawUser.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawUser);
        if (decoded is Map<String, dynamic>) {
          final v =
              decoded['token'] ??
              decoded['accessToken'] ??
              decoded['authToken'];
          if (v is String && v.isNotEmpty) return v;
        }
      } catch (_) {}
    }
    return null;
  }

  // Try to get patientId from shared prefs (explicit key), otherwise parse from JWT token ("sub" or "id")
  Future<String?> _getPatientIdFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final keysToTry = ['user_id', 'userId', 'patientId', 'patient_id', 'id'];
    for (final k in keysToTry) {
      final v = prefs.getString(k);
      if (v != null && v.isNotEmpty) return v;
    }

    // Attempt to parse JWT token payload for subject/id
    final token = await _getTokenFromPrefs();
    if (token != null && token.split('.').length >= 2) {
      try {
        final payload = token.split('.')[1];
        String normalized = base64Url.normalize(payload);
        final decoded = utf8.decode(base64Url.decode(normalized));
        final map = jsonDecode(decoded) as Map<String, dynamic>;
        // common claim names
        final idCandidates = ['sub', 'id', 'userId', 'uid'];
        for (final c in idCandidates) {
          final val = map[c];
          if (val != null) return val.toString();
        }
      } catch (_) {}
    }

    return null;
  }

  Future<Map<String, String>> _authHeaders() async {
    final token = await _getTokenFromPrefs();
    if (token == null || token.isEmpty) {
      throw Exception(
        'Authentication token not found. Vui lòng đăng nhập lại.',
      );
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Create appointment using primitive fields
  // appointmentDate should be a DateTime (date part used)
  // appointmentTime should be a TimeOfDay (converted to "HH:mm")
  Future<Appointment> createAppointment({
    required String doctorId,
    required DateTime appointmentDate,
    required TimeOfDay appointmentTime,
    required String patientFullName,
    String? phone,
    String? patientAddress,
    String? note,
    String?
    explicitPatientId, // optional override; otherwise taken from prefs/JWT
  }) async {
    final patientId = explicitPatientId ?? await _getPatientIdFromPrefs();
    if (patientId == null || patientId.isEmpty) {
      throw Exception('Không tìm thấy patientId. Vui lòng đăng nhập lại.');
    }

    final headers = await _authHeaders();

    // Format date and time
    String _formatDate(DateTime d) {
      final y = d.year.toString().padLeft(4, '0');
      final m = d.month.toString().padLeft(2, '0');
      final day = d.day.toString().padLeft(2, '0');
      return '$y-$m-$day';
    }

    String _formatTime(TimeOfDay t) {
      final hh = t.hour.toString().padLeft(2, '0');
      final mm = t.minute.toString().padLeft(2, '0');
      return '$hh:$mm';
    }

    final body = jsonEncode({
      'PatientFullName': patientFullName,
      'PatientId': patientId,
      'DoctorId': doctorId,
      'Phone': phone,
      'PatientAddress': patientAddress,
      'AppointmentDate': _formatDate(appointmentDate),
      'AppointmentTime': _formatTime(appointmentTime),
      'Note': note,
    });

    try {
      final uri = Uri.parse(_baseUrl);
      final resp = await http
          .post(uri, headers: headers, body: body)
          .timeout(_timeout);

      if (resp.statusCode == 201 || resp.statusCode == 200) {
        final jsonBody = jsonDecode(resp.body) as Map<String, dynamic>;
        // Expecting AppointmentReponse shape; normalize for Appointment.fromJson
        return Appointment.fromJson(jsonBody);
      } else {
        String? message;
        try {
          final decoded = jsonDecode(resp.body);
          if (decoded is Map<String, dynamic>) {
            message =
                decoded['message']?.toString() ??
                decoded['error']?.toString() ??
                decoded['detail']?.toString();
          } else if (decoded is String) {
            message = decoded;
          }
        } catch (_) {}
        throw Exception(
          message ?? 'Failed to create appointment. Status: ${resp.statusCode}',
        );
      }
    } on SocketException {
      throw Exception(
        'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng.',
      );
    } on TimeoutException {
      throw Exception('Yêu cầu tạo lịch quá thời gian. Vui lòng thử lại.');
    }
  }

  // Convenience: create from existing BookingDetails and doctorId
  Future<Appointment> createFromBookingDetails({
    required String doctorId,
    required dynamic
    bookingDetails, // any object that has name, phone, address, time, date
  }) {
    // bookingDetails could be the BookingDetails class used in DetailsScreen
    // attempt to read fields defensively
    String name = '';
    String? phone;
    String? address;
    TimeOfDay time = const TimeOfDay(hour: 9, minute: 0);
    DateTime date = DateTime.now();

    try {
      name = (bookingDetails.name ?? '').toString();
    } catch (_) {}
    try {
      phone = bookingDetails.phone?.toString();
    } catch (_) {}
    try {
      address = bookingDetails.address?.toString();
    } catch (_) {}

    try {
      final dt = bookingDetails.date;
      if (dt is DateTime) date = dt;
    } catch (_) {}
    try {
      final t = bookingDetails.time;
      if (t is TimeOfDay)
        time = t;
      else if (t is String) {
        final parts = t.split(':');
        final h = int.tryParse(parts.first) ?? 9;
        final m = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
        time = TimeOfDay(hour: h, minute: m);
      }
    } catch (_) {}

    return createAppointment(
      doctorId: doctorId,
      appointmentDate: date,
      appointmentTime: time,
      patientFullName: name,
      phone: phone,
      patientAddress: address,
      note: bookingDetails.note?.toString(),
    );
  }

  // Get appointment by id
  Future<Appointment> getAppointmentById(String id) async {
    final headers = await _authHeaders();
    final uri = Uri.parse('$_baseUrl/$id');
    try {
      final resp = await http.get(uri, headers: headers).timeout(_timeout);
      if (resp.statusCode == 200) {
        final jsonBody = jsonDecode(resp.body) as Map<String, dynamic>;
        return Appointment.fromJson(jsonBody);
      } else if (resp.statusCode == 404) {
        throw Exception('Lịch hẹn không tìm thấy.');
      } else {
        throw Exception(
          'Failed to load appointment. Status: ${resp.statusCode}',
        );
      }
    } on SocketException {
      throw Exception(
        'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng.',
      );
    } on TimeoutException {
      throw Exception('Yêu cầu quá thời gian. Vui lòng thử lại.');
    }
  }

  Future<Map<String, dynamic>> listAppointments({
    String? patientId,
    String? doctorId,
    String? status,
    DateTime? dateFrom,
    DateTime? dateTo,
    int page = 1,
    int pageSize = 20,
  }) async {
    final headers = await _authHeaders();

    final query = <String, String>{};
    if (patientId != null && patientId.isNotEmpty)
      query['patientId'] = patientId;
    if (doctorId != null && doctorId.isNotEmpty) query['doctorId'] = doctorId;
    if (status != null && status.isNotEmpty) query['status'] = status;
    if (dateFrom != null) {
      final y = dateFrom.year.toString().padLeft(4, '0');
      final m = dateFrom.month.toString().padLeft(2, '0');
      final d = dateFrom.day.toString().padLeft(2, '0');
      query['dateFrom'] = '$y-$m-$d';
    }
    if (dateTo != null) {
      final y = dateTo.year.toString().padLeft(4, '0');
      final m = dateTo.month.toString().padLeft(2, '0');
      final d = dateTo.day.toString().padLeft(2, '0');
      query['dateTo'] = '$y-$m-$d';
    }
    query['page'] = page.toString();
    query['pageSize'] = pageSize.toString();

    final uri = Uri.parse(_baseUrl).replace(queryParameters: query);

    try {
      final resp = await http.get(uri, headers: headers).timeout(_timeout);
      if (resp.statusCode == 200) {
        final decoded = jsonDecode(resp.body);
        int total = 0;
        int respPage = page;
        int respPageSize = pageSize;
        List<Appointment> items = [];

        if (decoded is Map<String, dynamic>) {
          total = decoded['total'] is int
              ? decoded['total'] as int
              : int.tryParse('${decoded['total']}') ?? 0;
          respPage = decoded['page'] is int ? decoded['page'] as int : respPage;
          respPageSize = decoded['pageSize'] is int
              ? decoded['pageSize'] as int
              : respPageSize;

          final raw =
              decoded['data'] ??
              decoded['items'] ??
              decoded['results'] ??
              decoded[''];
          if (raw is List) {
            items = raw.map<Appointment>((e) {
              if (e is Map<String, dynamic>) return Appointment.fromJson(e);
              return Appointment.fromJson(Map<String, dynamic>.from(e));
            }).toList();
          }
        } else if (decoded is List) {
          // fallback: server returned raw list
          items = decoded
              .map<Appointment>(
                (e) => Appointment.fromJson(e as Map<String, dynamic>),
              )
              .toList();
          total = items.length;
        }

        return {
          'total': total,
          'page': respPage,
          'pageSize': respPageSize,
          'data': items,
        };
      } else {
        throw Exception(
          'Failed to list appointments. Status: ${resp.statusCode}',
        );
      }
    } on SocketException {
      throw Exception(
        'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng.',
      );
    } on TimeoutException {
      throw Exception(
        'Yêu cầu lấy danh sách lịch quá thời gian. Vui lòng thử lại.',
      );
    }
  }

  // Convenience wrappers
  Future<List<Appointment>> getAppointmentsByPatient({
    String? patientId,
    int page = 1,
    int pageSize = 50,
  }) async {
    final pid = patientId ?? await _getPatientIdFromPrefs();
    if (pid == null) throw Exception('Không tìm thấy patientId.');
    final res = await listAppointments(
      patientId: pid,
      page: page,
      pageSize: pageSize,
    );
    return List<Appointment>.from(res['data'] as List<Appointment>);
  }

  Future<List<Appointment>> getAppointmentsByDoctor({
    required String doctorId,
    int page = 1,
    int pageSize = 50,
  }) async {
    final res = await listAppointments(
      doctorId: doctorId,
      page: page,
      pageSize: pageSize,
    );
    return List<Appointment>.from(res['data'] as List<Appointment>);
  }

  // ---------------------------
  // UPDATE (PUT)
  // ---------------------------
  // dto is a Map with only fields you want to update; example keys:
  // PatientFullName, Phone, PatientAddress, AppointmentDate (yyyy-MM-dd), AppointmentTime (HH:mm),
  // Note, DoctorId (guid), PatientId (guid), Status, CancelReason
  Future<void> updateAppointment(String id, Map<String, dynamic> dto) async {
    if (dto.isEmpty) return;
    final headers = await _authHeaders();
    final uri = Uri.parse('$_baseUrl/$id');
    try {
      final resp = await http
          .put(uri, headers: headers, body: jsonEncode(dto))
          .timeout(_timeout);
      if (resp.statusCode == 204 || resp.statusCode == 200) {
        return;
      } else {
        String? message;
        try {
          final decoded = jsonDecode(resp.body);
          if (decoded is Map<String, dynamic>) {
            message =
                decoded['message']?.toString() ?? decoded['error']?.toString();
          }
        } catch (_) {}
        throw Exception(
          message ?? 'Failed to update appointment. Status: ${resp.statusCode}',
        );
      }
    } on SocketException {
      throw Exception(
        'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng.',
      );
    } on TimeoutException {
      throw Exception('Yêu cầu cập nhật lịch quá thời gian. Vui lòng thử lại.');
    }
  }

  // ---------------------------
  // UPDATE STATUS (PATCH)
  // ---------------------------
  // Update this method in lib/services/appointment.dart
  Future<void> updateAppointmentStatus(
    String id,
    String status, {
    String? cancelReason,
  }) async {
    // Normalize status string to what backend expects (e.g. "Cancelled")
    final normalized = status.toLowerCase().contains('cancel')
        ? 'Cancelled'
        : status;

    // Build DTO to send in PUT body. Only include fields you want to change.
    final dto = <String, dynamic>{
      'Status': normalized,
      if (cancelReason != null && cancelReason.isNotEmpty)
        'CancelReason': cancelReason,
    };

    debugPrint('PUT $_baseUrl/$id with body: ${jsonEncode(dto)}');

    // Reuse updateAppointment which does PUT with auth headers and error handling
    await updateAppointment(id, dto);
  }

  // ---------------------------
  // DELETE (soft by default)
  // ---------------------------
  Future<void> deleteAppointment(String id, {bool force = false}) async {
    final headers = await _authHeaders();
    final uri = Uri.parse(
      '$_baseUrl/$id',
    ).replace(queryParameters: {'force': force ? 'true' : 'false'});
    try {
      final resp = await http.delete(uri, headers: headers).timeout(_timeout);
      if (resp.statusCode == 204 || resp.statusCode == 200) {
        return;
      } else {
        String? message;
        try {
          final decoded = jsonDecode(resp.body);
          if (decoded is Map<String, dynamic>) {
            message =
                decoded['message']?.toString() ?? decoded['error']?.toString();
          }
        } catch (_) {}
        throw Exception(
          message ?? 'Failed to delete appointment. Status: ${resp.statusCode}',
        );
      }
    } on SocketException {
      throw Exception(
        'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng.',
      );
    } on TimeoutException {
      throw Exception('Yêu cầu xóa lịch quá thời gian. Vui lòng thử lại.');
    }
  }
}
