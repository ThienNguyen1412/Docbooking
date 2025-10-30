import 'package:flutter/material.dart';
import '../../models/doctor.dart'; // use API model (Doctors) for booking callback
import 'book_new_appointment_screen.dart';
import 'appointment_detail_screen.dart';
import '../../models/appointments.dart' as model;
import '../home/details_screen.dart';

/// Stateless UI that receives a list of model.Appointment and callbacks.
/// The list should be provided by a parent widget (e.g. MyAppointmentsPage).
class AppointmentScreen extends StatelessWidget {
  final List<model.Appointment> appointments;
  final void Function(model.Appointment) onDelete;
  final void Function(model.Appointment) onEdit;

  // Use Doctors (API model) to match BookNewAppointmentScreen and DetailsScreen
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
    debugPrint('AppointmentScreen.build: appointments.length=${appointments.length}');
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
            // Tab 4: Chỉ hiển thị 'Canceled' / 'Cancelled'
            AppointmentListView(
              appointments: appointments,
              onDelete: onDelete,
              onEdit: onEdit,
              statusFilter: const ['Canceled', 'Cancelled'],
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

class AppointmentListView extends StatelessWidget {
  final List<model.Appointment> appointments;
  final void Function(model.Appointment) onDelete;
  final void Function(model.Appointment) onEdit;
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
    showDialog<bool>(
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
                Navigator.of(ctx).pop(false); // Đóng dialog trả false
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Hủy Lịch Hẹn'),
              onPressed: () {
                Navigator.of(ctx).pop(true); // Đóng dialog trả true
              },
            ),
          ],
        );
      },
    ).then((confirmed) {
      if (confirmed == true) {
        onDelete(appointment); // Gọi hàm xóa/hủy (parent sẽ call API)
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // filter by comparing the display status string (model.appointmentStatusToString)
    final filteredAppointments = appointments.where((a) {
      final s = model.appointmentStatusToString(a.status).toLowerCase();
      return statusFilter.any((f) => s.contains(f.toLowerCase()));
    }).toList();

    debugPrint('AppointmentListView.build: filteredAppointments=${filteredAppointments.length} for filter=$statusFilter');

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

        final statusText = model.appointmentStatusToString(appointment.status);
        Color statusColor;
        IconData statusIcon;
        final sLow = statusText.toLowerCase();
        if (sLow.contains('pending')) {
          statusColor = Colors.orange;
          statusIcon = Icons.hourglass_top_rounded;
        } else if (sLow.contains('confirm')) {
          statusColor = Colors.blue;
          statusIcon = Icons.check_circle_outline_rounded;
        } else if (sLow.contains('complete')) {
          statusColor = Colors.green;
          statusIcon = Icons.check_circle;
        } else if (sLow.contains('cancel')) {
          statusColor = Colors.red;
          statusIcon = Icons.cancel;
        } else {
          statusColor = Colors.grey;
          statusIcon = Icons.help_outline;
        }

        final date = appointment.appointmentDate;
        final dateStr = '${date.day.toString().padLeft(2,'0')}/${date.month.toString().padLeft(2,'0')}/${date.year}';
        final timeStr = appointment.appointmentTime;

        final doctorDisplay = (appointment.doctorName != null && appointment.doctorName!.isNotEmpty)
            ? appointment.doctorName!
            : (appointment.doctorId ?? '-');

        // If cancelled, include cancel reason in subtitle
        final isCancelled = sLow.contains('cancel');
        final cancelReason = (appointment.cancelReason != null && appointment.cancelReason!.trim().isNotEmpty)
            ? appointment.cancelReason!.trim()
            : null;

        // Build subtitle widget — show patient name, date/time, and cancel reason when applicable
        final subtitleWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(appointment.patientFullName),
            const SizedBox(height: 4),
            Text('$dateStr lúc $timeStr'),
            if (isCancelled) ...[
              const SizedBox(height: 6),
              Text(
                'Lý do hủy: ${cancelReason ?? '-'}',
                style: TextStyle(color: Colors.red.shade700, fontStyle: FontStyle.italic, fontSize: 13),
              ),
            ],
          ],
        );

        // Ensure trailing controls don't overflow: constrain width
        final trailingWidget = (statusText.toLowerCase() == 'pending' || statusText.toLowerCase().contains('confirm'))
            ? SizedBox(
                width: 96,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_calendar_outlined, color: Colors.orange),
                      onPressed: () => onEdit(appointment),
                      tooltip: 'Sửa lịch hẹn',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _showCancelConfirmationDialog(context, appointment),
                      tooltip: 'Hủy lịch hẹn',
                    ),
                  ],
                ),
              )
            : null;

        return Card(
          key: ValueKey(appointment.id),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: statusColor.withAlpha(26),
              child: Icon(statusIcon, color: statusColor),
            ),
            title: Text(
              doctorDisplay,
              style: const TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: subtitleWidget,
            isThreeLine: isCancelled ? true : true,
            trailing: trailingWidget,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AppointmentDetailScreen(
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