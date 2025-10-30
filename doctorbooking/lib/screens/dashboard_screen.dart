import 'package:flutter/material.dart';
import 'home/home_screen.dart';
import 'home/details_screen.dart';
import 'profile/profile_screen.dart';
import '../models/doctor.dart';
import '../models/notification.dart';
import 'news/news_screen.dart';
// Removed direct AppointmentScreen import — use the self-loading MyAppointmentsPage instead
import '../screens/appointment/my_appointment_screen.dart';
import 'service/service_screen.dart';
import 'appointment/edit_appointment_screen.dart';
import '../models/appointments.dart' as model;

/// DashboardScreen - đã loại bỏ mọi dữ liệu mẫu (MockDatabase)
/// - Notifications: bắt đầu rỗng
/// - Appointments: màn MyAppointmentsPage sẽ tự load dữ liệu từ API
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  // Bắt đầu với danh sách thông báo rỗng (không còn dữ liệu mẫu)
  final List<AppNotification> _notifications = [];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _markNotificationAsRead(String id) {
    setState(() {
      final index = _notifications.indexWhere((noti) => noti.id == id);
      if (index >= 0 && !_notifications[index].isRead) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
      }
    });
  }

  void _addNotification(AppNotification notification) {
    setState(() {
      _notifications.add(notification);
    });
    if (notification.title.toLowerCase().contains('dịch vụ')) {
      // Nếu là thông báo dịch vụ, chuyển về tab Dịch vụ (index 2)
      _onItemTapped(2);
    } else if (notification.title.toLowerCase().contains('đặt lịch')) {
      // Nếu là thông báo đặt lịch, chuyển về tab Lịch hẹn (index 1)
      _onItemTapped(1);
    }
  }

  // Khi người dùng đặt lịch (từ DetailsScreen / BookNewAppointmentScreen),
  // ta chỉ thêm 1 thông báo (không thêm dữ liệu mẫu vào danh sách appointments).
  void _addNotificationForAppointment(Doctor doctor, BookingDetails details) {
    final newNotification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Yêu cầu đặt lịch đã được gửi!',
      body: 'Yêu cầu đặt lịch với ${doctor.fullName ?? doctor.id} đang chờ xác nhận.',
      date: DateTime.now(),
      isRead: false,
    );

    setState(() {
      _notifications.add(newNotification);
    });

    // Chuyển sang tab Lịch hẹn
    _onItemTapped(1);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Yêu cầu đặt lịch đã gửi đi. Vui lòng chờ xác nhận.')),
      );
    }
  }

  // Hủy lịch (không thao tác với dữ liệu mẫu)
  void _cancelAppointment(model.Appointment appt) {
    // Ở đây bạn nên gọi API (AppointmentService) để hủy trên backend.
    // Hiện tại chỉ hiển thị thông báo UI và chuyển tab nếu cần.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã gửi yêu cầu hủy lịch hẹn với ${appt.doctorName ?? appt.doctorId}')),
    );
    // Optionally switch to appointments tab
    _onItemTapped(1);
  }

  // Cập nhật appointment (nên gọi API ở đây nếu có)
  void _updateAppointmentState(model.Appointment updatedAppointment) {
    // Gọi API update nếu cần; hiện chỉ show snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✅ Cập nhật lịch hẹn với ${updatedAppointment.doctorName ?? updatedAppointment.doctorId} thành công!')),
    );
  }

  void _editAppointment(model.Appointment appt) async {
    final updatedAppointment = await Navigator.push<model.Appointment>(
      context,
      MaterialPageRoute(
        builder: (context) => EditAppointmentScreen(initialAppointment: appt),
      ),
    );

    if (updatedAppointment != null) {
      _updateAppointmentState(updatedAppointment);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sử dụng MyAppointmentsPage cho tab Lịch hẹn để màn này tự gọi API và quản lý state.
    final List<Widget> screens = <Widget>[
      HomeScreen(
        notifications: _notifications,
        markNotificationAsRead: _markNotificationAsRead,
        onBookAppointment: (doctor, details) => _addNotificationForAppointment(doctor, details),
      ),

      // Đây là thay đổi: MyAppointmentsPage tự gọi API và hiển thị dữ liệu
      const MyAppointmentsPage(),

      ServiceScreen(
        unreadNotifications: _notifications,
        markNotificationAsRead: _markNotificationAsRead,
        addNotification: _addNotification,
      ),
      const NewsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue.shade800,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Lịch hẹn'),
          BottomNavigationBarItem(icon: Icon(Icons.medical_services), label: 'Dịch vụ'),
          BottomNavigationBarItem(icon: Icon(Icons.article), label: 'Tin tức'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Hồ sơ'),
        ],
      ),
    );
  }
}