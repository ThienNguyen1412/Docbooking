import 'package:flutter/material.dart';

enum AppointmentStatus { pending, confirmed, completed, cancelled }

AppointmentStatus appointmentStatusFromString(String? s) {
  if (s == null) return AppointmentStatus.pending;
  final v = s.toLowerCase();
  if (v.contains('confirm')) return AppointmentStatus.confirmed;
  if (v.contains('complete')) return AppointmentStatus.completed;
  if (v.contains('cancel')) return AppointmentStatus.cancelled;
  // allow numeric strings "0","1","2","3"
  final n = int.tryParse(s);
  if (n != null) {
    switch (n) {
      case 1:
        return AppointmentStatus.confirmed;
      case 2:
        return AppointmentStatus.completed;
      case 3:
        return AppointmentStatus.cancelled;
      default:
        return AppointmentStatus.pending;
    }
  }
  return AppointmentStatus.pending;
}

String appointmentStatusToString(AppointmentStatus s) {
  switch (s) {
    case AppointmentStatus.confirmed:
      return 'Confirmed';
    case AppointmentStatus.completed:
      return 'Completed';
    case AppointmentStatus.cancelled:
      return 'Cancelled';
    case AppointmentStatus.pending:
    default:
      return 'Pending';
  }
}

class Appointment {
  final String id;
  final String patientFullName;
  final String patientId;
  final String? doctorId;
  final String? doctorName;
  final String? phone;
  final String? patientAddress;

  // Store date as DateTime (date part used). When serializing we output yyyy-MM-dd.
  final DateTime appointmentDate;

  // Store time as "HH:mm" string for easier JSON interchange.
  final String appointmentTime;

  final String? note;
  final AppointmentStatus status;
  final String? cancelReason;

  const Appointment({
    required this.id,
    required this.patientFullName,
    required this.patientId,
    this.doctorId,
    this.doctorName,
    this.phone,
    this.patientAddress,
    required this.appointmentDate,
    required this.appointmentTime, // "HH:mm"
    this.note,
    this.status = AppointmentStatus.pending,
    this.cancelReason,
  });

  // Helper to convert a dynamic time input to "HH:mm"
  static String _normalizeTime(dynamic value) {
    if (value == null) return '00:00';
    if (value is String) {
      final s = value.trim();
      if (s.contains(':')) {
        final parts = s.split(':');
        if (parts.length >= 2) {
          final hh = parts[0].padLeft(2, '0');
          final mm = parts[1].padLeft(2, '0');
          return '$hh:$mm';
        }
      }
      try {
        final dt = DateTime.parse(s);
        final hh = dt.hour.toString().padLeft(2, '0');
        final mm = dt.minute.toString().padLeft(2, '0');
        return '$hh:$mm';
      } catch (_) {}
      final regex = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?');
      final m = regex.firstMatch(s.toUpperCase());
      if (m != null) {
        final h = (m.group(1) ?? '0').padLeft(2, '0');
        final min = (m.group(2) ?? '0').padLeft(2, '0');
        return '$h:$min';
      }
      return s;
    } else if (value is int) {
      final totalSeconds = value;
      final hh = (totalSeconds ~/ 3600).toString().padLeft(2, '0');
      final mm = ((totalSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
      return '$hh:$mm';
    } else if (value is DateTime) {
      final hh = value.hour.toString().padLeft(2, '0');
      final mm = value.minute.toString().padLeft(2, '0');
      return '$hh:$mm';
    } else {
      return value.toString();
    }
  }

  // Parse date tolerant (accepts "yyyy-MM-dd" or ISO). Returns null if can't parse.
  static DateTime? _parseDateNullable(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return DateTime(value.year, value.month, value.day);
    if (value is String) {
      final s = value.trim();
      try {
        final dt = DateTime.parse(s);
        return DateTime(dt.year, dt.month, dt.day);
      } catch (_) {
        final regex = RegExp(r'^(\d{4})-(\d{1,2})-(\d{1,2})');
        final m = regex.firstMatch(s);
        if (m != null) {
          final y = int.parse(m.group(1)!);
          final mo = int.parse(m.group(2)!);
          final d = int.parse(m.group(3)!);
          return DateTime(y, mo, d);
        }
      }
    }
    return null;
  }

  factory Appointment.fromJson(Map<String, dynamic> json) {
    String? readString(List<String> keys) {
      for (final k in keys) {
        if (json.containsKey(k) && json[k] != null) return json[k].toString();
      }
      return null;
    }

    final id =
        readString(['id', 'Id', 'appointmentId', 'AppointmentId']) ??
        UniqueKey().toString();
    final patientFullName =
        readString(['patientFullName', 'PatientFullName', 'fullName']) ?? '';
    final patientId =
        readString(['patientId', 'PatientId', 'patient_id']) ?? '';
    final doctorId = readString(['doctorId', 'DoctorId', 'doctor_id']);
    final doctorName = readString(['doctorName', 'DoctorName']);
    final phone = readString(['phone', 'Phone']);
    final address = readString([
      'patientAddress',
      'PatientAddress',
      'patient_address',
      'address',
    ]);

    final aptDate =
        _parseDateNullable(
          json['appointmentDate'] ?? json['AppointmentDate'] ?? json['date'],
        ) ??
        DateTime.now();
    final aptTime = _normalizeTime(
      json['appointmentTime'] ?? json['AppointmentTime'] ?? json['time'],
    );

    final note = readString(['note', 'Note']);
    final statusRaw = readString(['status', 'Status']);
    final status = appointmentStatusFromString(statusRaw);
    final cancelReason = readString(['cancelReason', 'CancelReason']);

    return Appointment(
      id: id,
      patientFullName: patientFullName,
      patientId: patientId,
      doctorId: doctorId,
      doctorName: doctorName,
      phone: phone,
      patientAddress: address,
      appointmentDate: aptDate,
      appointmentTime: aptTime,
      note: note,
      status: status,
      cancelReason: cancelReason,
    );
  }

  Map<String, dynamic> toJson() {
    String formatDate(DateTime d) {
      final y = d.year.toString().padLeft(4, '0');
      final m = d.month.toString().padLeft(2, '0');
      final day = d.day.toString().padLeft(2, '0');
      return '$y-$m-$day';
    }

    return {
      'id': id,
      'patientFullName': patientFullName,
      'patientId': patientId,
      if (doctorId != null) 'doctorId': doctorId,
      if (doctorName != null) 'doctorName': doctorName,
      if (phone != null) 'phone': phone,
      if (patientAddress != null) 'patientAddress': patientAddress,
      'appointmentDate': formatDate(appointmentDate),
      'appointmentTime': appointmentTime,
      if (note != null) 'note': note,
      'status': appointmentStatusToString(status),
      if (cancelReason != null) 'cancelReason': cancelReason,
    };
  }

  // Convenience: get a TimeOfDay for UI
  TimeOfDay get timeOfDay {
    final parts = appointmentTime.split(':');
    if (parts.length >= 2) {
      final h = int.tryParse(parts[0]) ?? 0;
      final m = int.tryParse(parts[1]) ?? 0;
      return TimeOfDay(hour: h, minute: m);
    }
    return const TimeOfDay(hour: 0, minute: 0);
  }

  static String timeOfDayToString(TimeOfDay t) {
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  Appointment copyWith({
    String? id,
    String? patientFullName,
    String? patientId,
    String? doctorId,
    String? doctorName,
    String? phone,
    String? patientAddress,
    DateTime? appointmentDate,
    String? appointmentTime,
    String? note,
    AppointmentStatus? status,
    String? cancelReason,
  }) {
    return Appointment(
      id: id ?? this.id,
      patientFullName: patientFullName ?? this.patientFullName,
      patientId: patientId ?? this.patientId,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      phone: phone ?? this.phone,
      patientAddress: patientAddress ?? this.patientAddress,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      appointmentTime: appointmentTime ?? this.appointmentTime,
      note: note ?? this.note,
      status: status ?? this.status,
      cancelReason: cancelReason ?? this.cancelReason,
    );
  }

  @override
  String toString() {
    final dateStr =
        '${appointmentDate.year.toString().padLeft(4, '0')}-${appointmentDate.month.toString().padLeft(2, '0')}-${appointmentDate.day.toString().padLeft(2, '0')}';
    return 'Appointment(id: $id, patientFullName: $patientFullName, doctorId: $doctorId, date: $dateStr $appointmentTime, status: ${appointmentStatusToString(status)})';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Appointment &&
            other.id == id &&
            other.patientFullName == patientFullName &&
            other.patientId == patientId &&
            other.doctorId == doctorId &&
            other.appointmentDate == appointmentDate &&
            other.appointmentTime == appointmentTime);
  }

  @override
  int get hashCode =>
      id.hashCode ^
      patientFullName.hashCode ^
      patientId.hashCode ^
      (doctorId?.hashCode ?? 0) ^
      appointmentDate.hashCode ^
      appointmentTime.hashCode;
}
