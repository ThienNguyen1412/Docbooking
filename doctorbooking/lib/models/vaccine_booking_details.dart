// File: lib/models/appointment.dart

// ✨ ADD ENUM IF YOU DON'T HAVE IT
enum AppointmentType { doctor, vaccine, service }

class Appointment {
  final String id;
  final String? doctorName; // Keep fields from doctor booking
  final String? specialty;
  final String date; // Keep original date String
  final String time; // Keep original time String
  String status; // Keep original status
  final String patientName;
  final String? patientPhone;
  final String? patientAddress;
  final String? notes;

  // ✨ --- ADD NEW FIELDS --- ✨
  final AppointmentType type;     // To distinguish appointment types
  final String title;          // A general title (e.g., "Khám BS X", "Tiêm Y")
  final DateTime? dateTime;     // For accurate sorting and comparison
  final String? vaccineName;  // Specific to vaccine appointments
  final String? patientDob;   // Specific to vaccine appointments (optional)
  // Add other fields if needed (e.g., serviceName for service appointments)

  Appointment({
    required this.id,
    this.doctorName,
    this.specialty,
    required this.date, // Keep required if doctor booking needs it
    required this.time, // Keep required if doctor booking needs it
    required this.status,
    required this.patientName,
    this.patientPhone,
    this.patientAddress,
    this.notes,

    // ✨ --- ADD NEW PARAMETERS TO CONSTRUCTOR --- ✨
    required this.type,
    required this.title,
    this.dateTime,      // Make optional if old doctor appointments don't have it
    this.vaccineName,
    this.patientDob,
  });

  // Optional: Add copyWith method for easier updates
  Appointment copyWith({
    String? id,
    AppointmentType? type,
    String? title,
    DateTime? dateTime,
    String? status,
    String? patientName,
    String? doctorName,
    String? specialty,
    String? date,
    String? time,
    String? patientPhone,
    String? patientAddress,
    String? notes,
    String? vaccineName,
    String? patientDob,
  }) {
    return Appointment(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      dateTime: dateTime ?? this.dateTime,
      status: status ?? this.status,
      patientName: patientName ?? this.patientName,
      doctorName: doctorName ?? this.doctorName,
      specialty: specialty ?? this.specialty,
      date: date ?? this.date,
      time: time ?? this.time,
      patientPhone: patientPhone ?? this.patientPhone,
      patientAddress: patientAddress ?? this.patientAddress,
      notes: notes ?? this.notes,
      vaccineName: vaccineName ?? this.vaccineName,
      patientDob: patientDob ?? this.patientDob,
    );
  }
}