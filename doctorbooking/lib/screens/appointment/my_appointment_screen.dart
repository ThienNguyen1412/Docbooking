import 'package:flutter/material.dart';
import '../../models/appointments.dart' as model;
import '../../services/appointment.dart';
import 'appointment_screen.dart';
import '../../models/doctor.dart';
import '../home/details_screen.dart';

class MyAppointmentsPage extends StatefulWidget {
  const MyAppointmentsPage({super.key});

  @override
  State<MyAppointmentsPage> createState() => _MyAppointmentsPageState();
}

class _MyAppointmentsPageState extends State<MyAppointmentsPage> {
  List<model.Appointment> _appointments = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      debugPrint('MyAppointmentsPage: requesting appointments (page=1,pageSize=200)');
      final list = await AppointmentService.instance.getAppointmentsByPatient(page: 1, pageSize: 200);

      debugPrint('MyAppointmentsPage: fetched ${list.length} appointments');
      if (!mounted) return;
      setState(() {
        _appointments = list;
        _isLoading = false;
        _error = null;
      });
    } catch (e, st) {
      debugPrint('MyAppointmentsPage._loadAppointments error: $e\n$st');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _onDelete(model.Appointment appt) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hủy lịch hẹn'),
        content: const Text('Bạn có chắc chắn muốn hủy lịch hẹn này?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Không')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Hủy', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await AppointmentService.instance.deleteAppointment(appt.id, force: false);
      await _loadAppointments(showLoading: false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hủy lịch thành công'), backgroundColor: Colors.green));
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hủy thất bại: $msg'), backgroundColor: Colors.redAccent));
    }
  }

  // Khi edit xong: reload từ server để đồng bộ dữ liệu
  Future<void> _onEdit(model.Appointment updatedAppointment) async {
    // Option A: reload full list from server (recommended to keep in sync)
    try {
      await _loadAppointments(showLoading: false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cập nhật lịch thành công'), backgroundColor: Colors.green));
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cập nhật thất bại: $msg'), backgroundColor: Colors.redAccent));
    }

    // Option B (alternative): update local list item directly without calling API:
    // final idx = _appointments.indexWhere((a) => a.id == updatedAppointment.id);
    // if (idx >= 0) {
    //   setState(() { _appointments[idx] = updatedAppointment; });
    // }
  }

  // Callback passed to BookNewAppointmentScreen (if you open it here)
  void _onBookAppointment(Doctor doctor, BookingDetails details) async {
    try {
      final created = await AppointmentService.instance.createFromBookingDetails(doctorId: doctor.id, bookingDetails: details);
      await _loadAppointments(showLoading: false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đặt lịch thành công'), backgroundColor: Colors.green));
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đặt lịch thất bại: $msg'), backgroundColor: Colors.redAccent));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lịch Hẹn của bạn')),
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('Lỗi: $_error', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _loadAppointments, child: const Text('Thử lại')),
          ]),
        ),
      );
    }

    return AppointmentScreen(
      appointments: _appointments,
      onDelete: (appt) => _onDelete(appt),
      onEdit: (appt) => _onEdit(appt),
      onBookAppointment: _onBookAppointment,
    );
  }
}