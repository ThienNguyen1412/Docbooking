// File: screens/admin/admin_appointment/admin_appointment_screen.dart

import 'package:flutter/material.dart';
// ✨ SỬA LỖI: Import model và sử dụng bí danh 'model' để tránh xung đột
import '../../../../models/appointment.dart' as model; 

/// Màn hình quản lý các lịch hẹn (dành cho Admin)
class AdminAppointmentScreen extends StatefulWidget {
  // ✨ CẢI TIẾN: Đổi tên tham số cho chính xác, vì nó chứa tất cả lịch hẹn
  final List<model.Appointment> appointments; 
  final Function(String id, String newStatus) updateAppointmentStatus;

  const AdminAppointmentScreen({
    super.key,
    required this.appointments,
    required this.updateAppointmentStatus,
  });

  @override
  State<AdminAppointmentScreen> createState() => _AdminAppointmentScreenState();
}

class _AdminAppointmentScreenState extends State<AdminAppointmentScreen> {

  // ✨ CẢI TIẾN: Tách thành các hàm lọc riêng biệt cho mỗi tab
  List<model.Appointment> _filterAppointmentsByStatus(String status) {
    return widget.appointments.where((app) => app.status == status).toList();
  }

  // Widget xây dựng Card hiển thị chi tiết lịch hẹn
  Widget _buildAppointmentCard(model.Appointment app) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thông tin bệnh nhân
            _buildInfoRow(Icons.badge_outlined, 'Bệnh nhân:', '${app.patientName} - ${app.patientPhone}'),
            const SizedBox(height: 8),

            // Thông tin Bác sĩ
            _buildInfoRow(Icons.medical_services_outlined, 'Bác sĩ:', '${app.doctorName} (${app.specialty})'),
            const SizedBox(height: 8),

            // Thời gian
            _buildInfoRow(Icons.calendar_today_outlined, 'Thời gian:', '${app.date} lúc ${app.time}'),
            
            // Chỉ hiển thị nút nếu lịch hẹn đang chờ xử lý
            if (app.status == 'Pending') ...[
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text('Hủy'),
                    onPressed: () => widget.updateAppointmentStatus(app.id, 'Canceled'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Xác nhận'),
                    onPressed: () => widget.updateAppointmentStatus(app.id, 'Confirmed'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }

  // Widget helper để tạo các dòng thông tin cho đồng bộ
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.blue.shade700),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 15, color: Colors.black87, fontFamily: 'Roboto'),
              children: [
                TextSpan(text: '$label ', style: const TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✨ CẢI TIẾN: Giao diện sử dụng TabController
    return DefaultTabController(
      length: 3, // Số lượng tab
      child: Scaffold(
        // AppBar được quản lý bởi AdminHomeScreen, ở đây chỉ cần TabBar
        appBar: TabBar(
          labelColor: Colors.red.shade700,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.red.shade700,
          tabs: const [
            Tab(text: 'Chờ xử lý'),
            Tab(text: 'Đã xác nhận'),
            Tab(text: 'Đã hủy'),
          ],
        ),
        body: TabBarView(
          children: [
            // Tab 1: Lịch hẹn chờ xử lý
            _AppointmentListView(
              appointments: _filterAppointmentsByStatus('Pending'),
              emptyMessage: '🎉 Không có lịch hẹn nào đang chờ xử lý.',
              buildCard: _buildAppointmentCard,
            ),
            // Tab 2: Lịch hẹn đã xác nhận
            _AppointmentListView(
              appointments: _filterAppointmentsByStatus('Confirmed'),
              emptyMessage: 'Chưa có lịch hẹn nào được xác nhận.',
              buildCard: _buildAppointmentCard,
            ),
            // Tab 3: Lịch hẹn đã hủy
            _AppointmentListView(
              appointments: _filterAppointmentsByStatus('Canceled'),
              emptyMessage: 'Không có lịch hẹn nào bị hủy.',
              buildCard: _buildAppointmentCard,
            ),
          ],
        ),
      ),
    );
  }
}

// ✨ CẢI TIẾN: Widget con để hiển thị danh sách, có thể tái sử dụng
class _AppointmentListView extends StatelessWidget {
  final List<model.Appointment> appointments;
  final String emptyMessage;
  final Widget Function(model.Appointment) buildCard;

  const _AppointmentListView({
    required this.appointments,
    required this.emptyMessage,
    required this.buildCard,
  });

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 60, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(emptyMessage, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        return buildCard(appointments[index]);
      },
    );
  }
}