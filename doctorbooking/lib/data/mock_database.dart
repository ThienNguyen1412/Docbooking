// File: lib/data/mock_database.dart

import '../models/appointment.dart' as model;

class MockDatabase {
  // Private constructor
  MockDatabase._privateConstructor();

  // Tạo một thực thể (instance) duy nhất
  static final MockDatabase _instance = MockDatabase._privateConstructor();

  // Cổng công khai để truy cập vào thực thể
  static MockDatabase get instance => _instance;

  final List<model.Appointment> _appointments = [

    // ✨ DỮ LIỆU MẪU MỚI CHO TAB "HOÀN THÀNH" ✨
    model.Appointment(
      id: '2001',
      doctorName: 'BS.CKI. Nguyễn Hải Anh',
      specialty: 'Tim mạch',
      date: '15/09/2025',
      time: '11:00 AM',
      status: 'Completed', // Đã hoàn thành
      patientName: 'Nguyễn Viết Khánh Linh',
      patientPhone: '0934567890',
      patientAddress: '456 Đường Trần Hưng Đạo, Quận 5, TP.HCM',
      notes: 'Tái khám sau 1 tháng.',
    ),
    model.Appointment(
      id: '2002',
      doctorName: 'PSG.TS Trần Ngọc Lương',
      specialty: 'Thần kinh',
      date: '10/09/2025',
      time: '16:00 PM',
      status: 'Completed', // Đã hoàn thành
      patientName: 'Nguyễn Thanh Hoài',
      patientPhone: '0901234567',
      patientAddress: '123 Đường Lê Lợi, Quận 1, TP.HCM',
      notes: 'Theo dõi và uống thuốc đúng liều lượng.',
    ),
  ];
  
  // Các hàm quản lý dữ liệu (giữ nguyên)
  List<model.Appointment> get appointments => _appointments;

  void addAppointment(model.Appointment newAppointment) {
    _appointments.add(newAppointment);
  }

  void updateAppointmentStatus(String id, String newStatus) {
    final index = _appointments.indexWhere((app) => app.id == id);
    if (index != -1) {
      _appointments[index].status = newStatus;
    }
  }

  void deleteAppointment(String id) {
    _appointments.removeWhere((a) => a.id == id);
  }

  void updateAppointment(model.Appointment updatedAppointment) {
     final index = _appointments.indexWhere((a) => a.id == updatedAppointment.id);
      if (index != -1) {
        _appointments[index] = updatedAppointment;
      }
  }
}