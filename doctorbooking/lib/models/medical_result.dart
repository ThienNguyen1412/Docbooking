// File: lib/models/medical_result.dart


class MedicalResult {
  final String id;
  final String title;
  final String patientName;
  final DateTime date;
  final String doctorName;
  final String department;
  final String diagnosis; // Chẩn đoán
  final String notes;     // Ghi chú, kết luận chi tiết

  MedicalResult({
    required this.id,
    required this.title,
    required this.patientName,
    required this.date,
    required this.doctorName,
    required this.department,
    required this.diagnosis,
    required this.notes,
  });
}