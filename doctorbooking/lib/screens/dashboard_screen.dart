// File: dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'home/home_screen.dart';
import 'home/details_screen.dart';
import 'profile/profile_screen.dart';
import '../models/doctor.dart';
import '../models/notification.dart';
import 'news/news_screen.dart';
import 'appointment/appointment_screen.dart';
import 'service/service_screen.dart';
import 'appointment/edit_appointment_screen.dart';
import '../data/mock_database.dart';
import '../models/appointment.dart' as model;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  int _nextAppointmentId = MockDatabase.instance.appointments.length + 1;

  final List<AppNotification> _notifications = AppNotification.initialNotifications();

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
    if (notification.title.contains('dịch vụ')) {
    // Nếu là thông báo dịch vụ, chuyển về tab Dịch vụ (index 2)
    _onItemTapped(2); 
  } else if (notification.title.contains('đặt lịch')) {
    // Nếu là thông báo đặt bác sĩ, chuyển về tab Lịch hẹn (index 1)
    _onItemTapped(1);
  }
  }

  void _addAppointment(Doctor doctor, BookingDetails details) {
    final newAppointment = model.Appointment(
      id: 'appt${_nextAppointmentId++}',
      doctorName: doctor.name,
      specialty: doctor.specialty,
      date: DateFormat('dd/MM/yyyy').format(details.date),
      time: details.time.format(context),
      status: 'Pending',
      patientName: details.name,
      patientPhone: details.phone,
      patientAddress: details.address,
      notes: details.note,
    );

    setState(() {
      MockDatabase.instance.addAppointment(newAppointment);
    });
  }

  void _addNotificationForAppointment(Doctor doctor, BookingDetails details) {
    final newNotification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Yêu cầu đặt lịch đã được gửi!',
      body: 'Yêu cầu đặt lịch với BS ${doctor.name} đang chờ xác nhận.',
      date: DateTime.now(),
      isRead: false,
    );

    setState(() {
      _notifications.add(newNotification);
    });
    _addAppointment(doctor, details);

    _onItemTapped(1);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Yêu cầu đặt lịch đã gửi đi. Vui lòng chờ xác nhận.')),
    );
    _onItemTapped(2);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Yêu cầu đặt lịch dịch vụ đã gửi đi. Vui lòng chờ xác nhận.')),
    );
  }

  // ✨ **1. ĐỔI TÊN HÀM VÀ THAY ĐỔI LOGIC**
  // Thay vì xóa, hàm này giờ sẽ cập nhật trạng thái thành 'Canceled'.
  void _cancelAppointment(model.Appointment appt) {
    setState(() {
      MockDatabase.instance.updateAppointmentStatus(appt.id, 'Canceled');
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã hủy lịch hẹn với ${appt.doctorName}')),
    );
  }
  
  // (Hàm _deleteAppointment cũ đã được thay thế bằng _cancelAppointment)

  void _updateAppointmentState(model.Appointment updatedAppointment) {
    setState(() {
      MockDatabase.instance.updateAppointment(updatedAppointment);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✅ Cập nhật lịch hẹn với ${updatedAppointment.doctorName} thành công!')),
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
    final List<Widget> screens = <Widget>[
      HomeScreen(
        notifications: _notifications,
        markNotificationAsRead: _markNotificationAsRead,
        onBookAppointment: (doctor, details) => _addNotificationForAppointment(doctor, details),
      ),
      AppointmentScreen(
        appointments: MockDatabase.instance.appointments,
        // ✨ **2. TRUYỀN HÀM MỚI VÀO THAM SỐ `onDelete`**
        // Mặc dù tên tham số là onDelete, nó sẽ thực hiện logic hủy của chúng ta.
        onDelete: _cancelAppointment,
        onEdit: _editAppointment,
        onBookAppointment: (doctor, details) => _addNotificationForAppointment(doctor, details),
      ),
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