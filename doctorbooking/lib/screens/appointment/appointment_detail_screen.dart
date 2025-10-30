import 'package:flutter/material.dart';
import '../../models/appointments.dart' as model;
import '../../services/appointment.dart';

/// Helper loading dialog so multiple widgets in this file can show/close it safely.
/// Returns a VoidCallback that will close the dialog when called.
Future<VoidCallback> showLoadingDialog(BuildContext context, {String message = 'Đang xử lý...'}) async {
  showDialog<void>(
    barrierDismissible: false,
    context: context,
    useRootNavigator: true,
    builder: (ctx) => WillPopScope(
      onWillPop: () async => false,
      child: AlertDialog(
        content: Row(children: [
          const SizedBox(width: 4),
          const CircularProgressIndicator(),
          const SizedBox(width: 16),
          Expanded(child: Text(message)),
        ]),
      ),
    ),
  );

  // return close function that safely pops the root dialog
  return () {
    try {
      if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    } catch (_) {
      // ignore
    }
  };
}

/// Detail screen for a single appointment.
/// - Uses the frontend Appointment model (lib/models/appointments.dart)
/// - Calls onEdit/onDelete callbacks provided by parent after successful API calls
class AppointmentDetailScreen extends StatelessWidget {
  final model.Appointment appointment;
  final void Function(model.Appointment) onEdit;
  final void Function(model.Appointment) onDelete;

  const AppointmentDetailScreen({
    super.key,
    required this.appointment,
    required this.onEdit,
    required this.onDelete,
  });

  Future<bool?> _showConfirmDialog(BuildContext context, {required String title, required String message, String okText = 'Đồng ý', String cancelText = 'Hủy'}) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(cancelText)),
            TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(okText, style: const TextStyle(color: Colors.red))),
          ],
        );
      },
    );
  }

  // Helper: format date as yyyy-MM-dd for backend
  String _formatDateForApi(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  // Now we only open the edit screen and wait for the edit screen to perform API update.
  // The edit screen returns updated model.Appointment on success, or null if cancelled.
  Future<void> _onTapEdit(BuildContext context) async {
    final updated = await Navigator.push<model.Appointment>(
      context,
      MaterialPageRoute(
        builder: (ctx) => EditAppointmentScreenShim(initialAppointment: appointment),
      ),
    );

    if (updated == null) return; // user cancelled or save failed

    // notify parent to update local list
    try {
      onEdit(updated);
    } catch (_) {}

    // pop detail screen to go back to list
    if (Navigator.canPop(context)) Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cập nhật lịch hẹn thành công'), backgroundColor: Colors.green));
  }

  // Cancel appointment as patient -> call DELETE (soft cancel) on backend
  Future<void> _onTapCancel(BuildContext context) async {
    final confirm = await _showConfirmDialog(
      context,
      title: 'Xác nhận hủy',
      message: 'Bạn có chắc chắn muốn hủy lịch hẹn này không? Thao tác này không thể hoàn tác.',
      okText: 'Hủy',
      cancelText: 'Không',
    );
    if (confirm != true) return;

    final closeLoading = await showLoadingDialog(context, message: 'Đang hủy lịch hẹn...');
    try {
      await AppointmentService.instance.deleteAppointment(appointment.id, force: false);
      // notify parent
      try {
        onDelete(appointment);
      } catch (_) {}
      closeLoading();
      if (Navigator.canPop(context)) Navigator.of(context).pop(); // pop detail screen
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hủy lịch hẹn thành công'), backgroundColor: Colors.green));
    } catch (e) {
      closeLoading();
      final msg = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hủy thất bại: $msg'), backgroundColor: Colors.redAccent));
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusText = model.appointmentStatusToString(appointment.status);
    final sLow = statusText.toLowerCase();

    Color statusColor;
    IconData statusIcon;
    String statusLabel;

    if (sLow.contains('pending')) {
      statusColor = Colors.orange;
      statusIcon = Icons.hourglass_top_rounded;
      statusLabel = 'Chờ xác nhận';
    } else if (sLow.contains('confirm')) {
      statusColor = Colors.blue;
      statusIcon = Icons.check_circle_outline_rounded;
      statusLabel = 'Đã xác nhận';
    } else if (sLow.contains('complete')) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      statusLabel = 'Đã hoàn thành';
    } else if (sLow.contains('cancel')) {
      statusColor = Colors.red;
      statusIcon = Icons.cancel;
      statusLabel = 'Đã hủy';
    } else {
      statusColor = Colors.grey;
      statusIcon = Icons.help_outline;
      statusLabel = 'Không xác định';
    }

    final date = appointment.appointmentDate;
    final dateStr = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    final timeStr = appointment.appointmentTime;

    final doctorDisplay = (appointment.doctorName != null && appointment.doctorName!.isNotEmpty)
        ? appointment.doctorName!
        : (appointment.doctorId ?? 'Không rõ bác sĩ');

    final patientName = appointment.patientFullName;
    final patientPhone = appointment.phone ?? '-';
    final patientAddress = appointment.patientAddress ?? '-';
    final note = appointment.note ?? '';
    final cancelReason = appointment.cancelReason;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi Tiết Lịch Hẹn'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Appointment / doctor card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(children: [
                Row(children: [
                  Icon(statusIcon, color: statusColor, size: 30),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(statusLabel, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: statusColor)),
                      const SizedBox(height: 6),
                      Text('$dateStr lúc $timeStr', style: const TextStyle(fontSize: 16, color: Colors.black87)),
                    ]),
                  ),
                ]),
                const Divider(height: 30),
                _buildDetailRow('Bác sĩ', doctorDisplay, Icons.medical_services_outlined),
                if (cancelReason != null && cancelReason.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildDetailRow('Lý do hủy', cancelReason, Icons.note_alt_outlined),
                ],
              ]),
            ),
          ),

          const SizedBox(height: 18),

          // Patient info
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text("Thông tin bệnh nhân", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Divider(height: 20),
                _buildDetailRow('Họ tên', patientName, Icons.person_outline),
                _buildDetailRow('Số điện thoại', patientPhone, Icons.phone_outlined),
                _buildDetailRow('Địa chỉ', patientAddress, Icons.location_on_outlined),
                if (note.isNotEmpty) const SizedBox(height: 8),
                if (note.isNotEmpty) _buildDetailRow('Ghi chú', note, Icons.note_alt_outlined),
              ]),
            ),
          ),

          const SizedBox(height: 18),

          // Actions
          if (sLow.contains('pending') || sLow.contains('confirm'))
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(children: [
                  ListTile(
                    leading: const Icon(Icons.edit_calendar_outlined, color: Colors.orange),
                    title: const Text('Sửa lịch hẹn'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _onTapEdit(context),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    leading: const Icon(Icons.cancel_outlined, color: Colors.red),
                    title: const Text('Hủy lịch hẹn'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _onTapCancel(context),
                  ),
                ]),
              ),
            ),
        ]),
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value, IconData icon) {
    final display = (value == null || value.isEmpty) ? '-' : value;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: Colors.grey.shade600, size: 22),
        const SizedBox(width: 15),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(display, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ]),
        ),
      ]),
    );
  }
}


/// Simple shim edit screen inside this file to avoid circular imports.
/// If you already have a dedicated edit screen, replace this with your screen.
class EditAppointmentScreenShim extends StatefulWidget {
  final model.Appointment initialAppointment;
  const EditAppointmentScreenShim({super.key, required this.initialAppointment});

  @override
  State<EditAppointmentScreenShim> createState() => _EditAppointmentScreenShimState();
}

class _EditAppointmentScreenShimState extends State<EditAppointmentScreenShim> {
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final a = widget.initialAppointment;
    _selectedDate = a.appointmentDate;
    final parts = (a.appointmentTime ?? '00:00').split(':');
    _selectedTime = TimeOfDay(hour: int.tryParse(parts[0]) ?? 0, minute: int.tryParse(parts[1]) ?? 0);
    _nameController = TextEditingController(text: a.patientFullName);
    _phoneController = TextEditingController(text: a.phone ?? '');
    _addressController = TextEditingController(text: a.patientAddress ?? '');
    _notesController = TextEditingController(text: a.note ?? '');
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime.now(), lastDate: DateTime(2101));
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _selectedTime);
    if (picked != null) setState(() => _selectedTime = picked);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // helper to format TimeOfDay -> "HH:mm"
  String _timeOfDayToString(TimeOfDay t) {
    return '${t.hour.toString().padLeft(2,'0')}:${t.minute.toString().padLeft(2,'0')}';
  }

  Future<void> _saveChanges() async {
    final a = widget.initialAppointment;

    // basic validation
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập tên bệnh nhân'), backgroundColor: Colors.redAccent));
      return;
    }
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập số điện thoại'), backgroundColor: Colors.redAccent));
      return;
    }

    // Prepare updated model (local)
    final updated = a.copyWith(
      appointmentDate: _selectedDate,
      appointmentTime: _timeOfDayToString(_selectedTime),
      patientFullName: name,
      phone: phone,
    );

    // Build DTO for API
    final dto = <String, dynamic>{
      'PatientFullName': updated.patientFullName,
      'Phone': updated.phone,
      'AppointmentDate': '${updated.appointmentDate.year.toString().padLeft(4,'0')}-${updated.appointmentDate.month.toString().padLeft(2,'0')}-${updated.appointmentDate.day.toString().padLeft(2,'0')}',
      'AppointmentTime': updated.appointmentTime,
      if (updated.note != null && updated.note!.trim().isNotEmpty) 'Note': updated.note!.trim(),
    };

    final closeLoading = await showLoadingDialog(context, message: 'Đang lưu thay đổi...');
    try {
      await AppointmentService.instance.updateAppointment(updated.id, dto);
      closeLoading();
      // show toast before pop to ensure ScaffoldMessenger context is valid
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lưu thay đổi thành công'), backgroundColor: Colors.green));
      }
      // Return the updated appointment to caller (detail screen)
      if (Navigator.canPop(context)) Navigator.of(context).pop(updated);
    } catch (e) {
      closeLoading();
      final msg = e.toString().replaceFirst('Exception: ', '');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lưu thất bại: $msg'), backgroundColor: Colors.redAccent));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.initialAppointment;
    final dateDisplay = '${_selectedDate.day.toString().padLeft(2,'0')}/${_selectedDate.month.toString().padLeft(2,'0')}/${_selectedDate.year}';

    return Scaffold(
      appBar: AppBar(title: const Text('Chỉnh Sửa Lịch Hẹn'), backgroundColor: Colors.blue.shade800),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Tên bệnh nhân')),
          const SizedBox(height: 12),
          TextField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Số điện thoại'), keyboardType: TextInputType.phone),
          const SizedBox(height: 12),
          ListTile(leading: const Icon(Icons.calendar_today), title: Text('Ngày: $dateDisplay'), onTap: _pickDate),
          ListTile(leading: const Icon(Icons.access_time), title: Text('Giờ: ${_selectedTime.format(context)}'), onTap: _pickTime),
          TextField(controller: _notesController, decoration: const InputDecoration(labelText: 'Ghi chú'), maxLines: 3),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveChanges,
              child: const Text('Lưu'),
            ),
          )
        ]),
      ),
    );
  }
}