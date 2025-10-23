// File: screens/appointment/appointment_detail_screen.dart

import 'package:flutter/material.dart';
import '../../models/appointment.dart';

class AppointmentDetailScreen extends StatelessWidget {
  final Appointment appointment;
  final Function(Appointment) onEdit;
  final Function(Appointment) onDelete;

  const AppointmentDetailScreen({
    super.key, 
    required this.appointment,
    required this.onEdit,
    required this.onDelete,
  });

  // HÀM HIỂN THỊ HỘP THOẠI XÁC NHẬN HỦY
  void _showCancelConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text('Xác nhận hủy'),
          content: const Text('Bạn có chắc chắn muốn hủy lịch hẹn này không? Thao tác này không thể hoàn tác.'),
          actions: [
            TextButton(
              child: const Text('Không'),
              onPressed: () {
                Navigator.of(ctx).pop(); // Chỉ đóng dialog
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Hủy Lịch Hẹn'),
              onPressed: () {
                // ✨ SỬA LỖI TẠI ĐÂY
                onDelete(appointment); // 1. Gọi hàm xóa (sẽ tự gọi setState)
                Navigator.of(ctx).pop(); // 2. Đóng dialog

                // 3. ✨ KHÔNG GỌI Navigator.of(context).pop() Ở ĐÂY NỮA
                // Thay vào đó, chúng ta sẽ pop màn hình này sau khi dialog đã đóng hoàn toàn
                // Sử dụng `Future.delayed` để đảm bảo an toàn
                Future.delayed(const Duration(milliseconds: 100), () {
                  if (Navigator.canPop(context)) {
                    Navigator.of(context).pop();
                  }
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (appointment.status) {
      case 'Pending':
        statusColor = Colors.orange;
        statusText = 'Chờ xác nhận';
        statusIcon = Icons.hourglass_top_rounded;
        break;
      case 'Confirmed':
        statusColor = Colors.blue;
        statusText = 'Đã xác nhận';
        statusIcon = Icons.check_circle_outline_rounded;
        break;
      case 'Completed':
        statusColor = Colors.green;
        statusText = 'Đã hoàn thành';
        statusIcon = Icons.check_circle;
        break;
      case 'Canceled':
        statusColor = Colors.red;
        statusText = 'Đã hủy';
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Không xác định';
        statusIcon = Icons.help_outline;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi Tiết Lịch Hẹn'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- THÔNG TIN LỊCH HẸN VÀ BÁC SĨ ---
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(statusIcon, color: statusColor, size: 30),
                        const SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              statusText,
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: statusColor),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '${appointment.date} lúc ${appointment.time}',
                              style: const TextStyle(fontSize: 16, color: Colors.black87),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(height: 30),
                    _buildDetailRow('Bác sĩ', appointment.doctorName, Icons.medical_services_outlined),
                    _buildDetailRow('Chuyên khoa', appointment.specialty, Icons.healing_outlined),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- THÔNG TIN BỆNH NHÂN ---
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Thông tin bệnh nhân", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const Divider(height: 20),
                    _buildDetailRow('Họ tên', appointment.patientName, Icons.person_outline),
                    _buildDetailRow('Số điện thoại', appointment.patientPhone, Icons.phone_outlined),
                    _buildDetailRow('Địa chỉ', appointment.patientAddress, Icons.location_on_outlined),
                    if (appointment.notes.isNotEmpty)
                      _buildDetailRow('Ghi chú', appointment.notes, Icons.note_alt_outlined),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),

            // --- NÚT HÀNH ĐỘNG ---
            if (appointment.status == 'Pending' || appointment.status == 'Confirmed')
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.edit_calendar_outlined, color: Colors.orange),
                        title: const Text('Sửa lịch hẹn'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          // Pop màn hình chi tiết trước khi mở màn hình sửa
                          Navigator.pop(context); 
                          onEdit(appointment);
                        },
                      ),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      ListTile(
                        leading: const Icon(Icons.cancel_outlined, color: Colors.red),
                        title: const Text('Hủy lịch hẹn'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          _showCancelConfirmationDialog(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  // Widget helper (không đổi)
  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 22),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}