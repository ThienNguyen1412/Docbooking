// File: screens/appointment/appointment_screen.dart

import 'package:flutter/material.dart';
import '../../models/doctor.dart';
import 'book_new_appointment_screen.dart';
import 'appointment_detail_screen.dart';
import '../../models/appointment.dart' as model;
import '../home/details_screen.dart';

// --- WIDGET CHÍNH ---
class AppointmentScreen extends StatelessWidget {
  final List<model.Appointment> appointments;
  final Function(model.Appointment) onDelete;
  final Function(model.Appointment) onEdit;
  final void Function(Doctor, BookingDetails) onBookAppointment;
  

  const AppointmentScreen({
    super.key,
    required this.appointments,
    required this.onDelete,
    required this.onEdit,
    required this.onBookAppointment,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // 4 tabs
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Lịch Hẹn Của Bạn'),
          backgroundColor: Colors.blue.shade800,
          elevation: 0,
          automaticallyImplyLeading: false,
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Chờ Xử Lý'),
              Tab(text: 'Đã Xác Nhận'),
              Tab(text: 'Đã Hoàn Thành'),
              Tab(text: 'Đã Hủy'),
            ],
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Chỉ hiển thị 'Pending'
            AppointmentListView(
              appointments: appointments,
              onDelete: onDelete,
              onEdit: onEdit,
              statusFilter: const ['Pending'], 
            ),
            // Tab 2: Chỉ hiển thị 'Confirmed'
            AppointmentListView(
              appointments: appointments,
              onDelete: onDelete,
              onEdit: onEdit,
              statusFilter: const ['Confirmed'],
            ),
            // Tab 3: Chỉ hiển thị 'Completed'
            AppointmentListView(
              appointments: appointments,
              onDelete: onDelete,
              onEdit: onEdit,
              statusFilter: const ['Completed'], 
            ),
            // Tab 4: Chỉ hiển thị 'Canceled'
            AppointmentListView(
              appointments: appointments,
              onDelete: onDelete,
              onEdit: onEdit,
              statusFilter: const ['Canceled'], 
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BookNewAppointmentScreen(
                  onBookAppointment: onBookAppointment,
                ),
              ),
            );
          },
          label: const Text('Đặt Lịch Mới'),
          icon: const Icon(Icons.add),
          backgroundColor: Colors.blueAccent,
        ),
      ),
    );
  }
}

// --- WIDGET HIỂN THỊ DANH SÁCH ---
class AppointmentListView extends StatelessWidget {
  final List<model.Appointment> appointments;
  final Function(model.Appointment) onDelete;
  final Function(model.Appointment) onEdit;
  final List<String> statusFilter;

  const AppointmentListView({
    super.key,
    required this.appointments,
    required this.onDelete,
    required this.onEdit,
    required this.statusFilter,
  });
  
    // HÀM HIỂN THỊ HỘP THOẠI XÁC NHẬN HỦY
  void _showCancelConfirmationDialog(BuildContext context, model.Appointment appointment) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text('Xác nhận hủy'),
          content: const Text('Bạn có chắc chắn muốn hủy lịch hẹn này không?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Không'),
              onPressed: () {
                Navigator.of(ctx).pop(); // Đóng dialog
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Hủy Lịch Hẹn'),
              onPressed: () {
                onDelete(appointment); // Gọi hàm xóa/hủy
                Navigator.of(ctx).pop(); // Đóng dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Lọc dựa trên danh sách các trạng thái được phép
    final filteredAppointments =
        appointments.where((a) => statusFilter.contains(a.status)).toList();

    if (filteredAppointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_outlined,
                size: 60, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'Không có lịch hẹn nào.',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8.0, bottom: 80.0),
      itemCount: filteredAppointments.length,
      itemBuilder: (context, index) {
        final appointment = filteredAppointments[index];

        Color statusColor;
        IconData statusIcon;
        switch (appointment.status) {
          case 'Pending':
            statusColor = Colors.orange;
            statusIcon = Icons.hourglass_top_rounded;
            break;
          case 'Confirmed':
            statusColor = Colors.blue;
            statusIcon = Icons.check_circle_outline_rounded;
            break;
          case 'Completed':
            statusColor = Colors.green;
            statusIcon = Icons.check_circle;
            break;
          case 'Canceled':
            statusColor = Colors.red;
            statusIcon = Icons.cancel;
            break;
          default:
            statusColor = Colors.grey;
            statusIcon = Icons.help_outline;
        }

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          elevation: 3,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: statusColor.withAlpha(26),
              child: Icon(statusIcon, color: statusColor),
            ),
            title: Text(
              appointment.doctorName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${appointment.specialty}\n${appointment.date} lúc ${appointment.time}',
            ),
            isThreeLine: true,
            trailing: (appointment.status == 'Pending' || appointment.status == 'Confirmed')
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_calendar_outlined,
                            color: Colors.orange),
                        onPressed: () => onEdit(appointment),
                        tooltip: 'Sửa lịch hẹn',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _showCancelConfirmationDialog(context, appointment),
                        tooltip: 'Hủy lịch hẹn',
                      ),
                    ],
                  )
                : null,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AppointmentDetailScreen(
                        appointment: appointment,
                        onEdit: onEdit,
                        onDelete: onDelete,
                      ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}