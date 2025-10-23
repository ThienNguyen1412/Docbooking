// File: lib/models/appointment.dart

class Appointment {
  final String id;
  final String doctorName;
  final String specialty;
  final String date;
  final String time;
  String status;

  // ✨ THÊM CÁC TRƯỜNG MỚI
  final String patientName;
  final String patientPhone;
  final String patientAddress;
  final String notes;

  Appointment({
    required this.id,
    required this.doctorName,
    required this.specialty,
    required this.date,
    required this.time,
    this.status = 'upcoming',
    // ✨ THÊM VÀO CONSTRUCTOR
    required this.patientName,
    required this.patientPhone,
    this.patientAddress = '', // Không bắt buộc
    this.notes = '', // Không bắt buộc
  });

  // ✨ CẬP NHẬT LẠI `copyWith` ĐỂ HỖ TRỢ TẤT CẢ CÁC TRƯỜNG
  Appointment copyWith({
    String? date,
    String? time,
    String? patientName,
    String? patientPhone,
    String? patientAddress,
    String? notes,
    String? status,
  }) {
    return Appointment(
      id: id,
      doctorName: doctorName,
      specialty: specialty,
      date: date ?? this.date,
      time: time ?? this.time,
      patientName: patientName ?? this.patientName,
      patientPhone: patientPhone ?? this.patientPhone,
      patientAddress: patientAddress ?? this.patientAddress,
      notes: notes ?? this.notes,
      status: status ?? this.status,
    );
  }
}