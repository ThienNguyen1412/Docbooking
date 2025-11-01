import 'package:flutter/material.dart';
// (MỚI) Thêm intl để format ngày
import 'package:intl/intl.dart'; 
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
        // ✨ Đảm bảo bạn gọi đúng màn hình EditAppointmentScreenShim
        builder: (ctx) => EditAppointmentScreenShim(initialAppointment: appointment),
      ),
    );

    // Nếu 'updated' là null, nghĩa là người dùng đã nhấn back
    // hoặc nhấn 'Lưu' khi không có gì thay đổi (nếu bạn dùng logic Cách 2)
    // Hoặc người dùng chỉ nhấn back (nếu dùng logic Cách 1 - vô hiệu hóa nút)
    if (updated == null) return; // user cancelled

    // Chỉ khi 'updated' không null (tức là đã lưu thành công)
    // chúng ta mới gọi onEdit và hiển thị SnackBar
    
    // notify parent to update local list
    try {
      onEdit(updated);
    } catch (_) {}

    // pop detail screen to go back to list
    if (Navigator.canPop(context)) Navigator.of(context).pop();

    // Hiển thị SnackBar ở màn hình danh sách (sau khi pop)
    // (Ghi chú: Đoạn code này có thể không chạy được nếu context đã bị pop,
    // tốt hơn là nên hiển thị SnackBar ở màn hình danh sách, 
    // giống như cách bạn làm trong _onEdit của MyAppointmentsPage)
    // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cập nhật lịch hẹn thành công'), backgroundColor: Colors.green));
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
      // Hiển thị SnackBar ở màn hình danh sách (sau khi pop)
      // (Giống như trên, nên để MyAppointmentsPage xử lý việc này)
      // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hủy lịch hẹn thành công'), backgroundColor: Colors.green));
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


// ====================================================================
// === ✨ BẮT ĐẦU SỬA LỖI LOGIC CHO EDITAPPOINTMENTSHIM ✨ ===
// ====================================================================

/// Simple shim edit screen inside this file to avoid circular imports.
/// If you already have a dedicated edit screen, replace this with your screen.
class EditAppointmentScreenShim extends StatefulWidget {
  final model.Appointment initialAppointment;
  const EditAppointmentScreenShim({super.key, required this.initialAppointment});

  @override
  State<EditAppointmentScreenShim> createState() => _EditAppointmentScreenShimState();
}

class _EditAppointmentScreenShimState extends State<EditAppointmentScreenShim> {
  // === Dữ liệu ban đầu (để so sánh) ===
  late DateTime _initialDate;
  late TimeOfDay _initialTime;
  late String _initialName;
  late String _initialPhone;
  late String _initialAddress;
  late String _initialNotes;
  // ==================================

  // === Dữ liệu đã chọn (đang thay đổi) ===
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  // ===================================

  // === Biến cờ theo dõi thay đổi ===
  bool _isChanged = false;
  // ==============================
  
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final a = widget.initialAppointment;
    
    // --- 1. Lưu giá trị gốc ---
    _initialDate = a.appointmentDate;
    final parts = (a.appointmentTime ?? '00:00').split(':');
    _initialTime = TimeOfDay(hour: int.tryParse(parts[0]) ?? 0, minute: int.tryParse(parts[1]) ?? 0);
    _initialName = a.patientFullName ?? '';
    _initialPhone = a.phone ?? '';
    _initialAddress = a.patientAddress ?? '';
    _initialNotes = a.note ?? '';

    // --- 2. Gán giá trị ban đầu cho các biến sẽ thay đổi ---
    _selectedDate = _initialDate;
    _selectedTime = _initialTime;
    _nameController = TextEditingController(text: _initialName);
    _phoneController = TextEditingController(text: _initialPhone);
    _addressController = TextEditingController(text: _initialAddress);
    _notesController = TextEditingController(text: _initialNotes);

    // --- 3. Thêm listeners để theo dõi thay đổi ---
    _nameController.addListener(_checkForChanges);
    _phoneController.addListener(_checkForChanges);
    _addressController.addListener(_checkForChanges);
    _notesController.addListener(_checkForChanges);
  }
  
  /// (MỚI) Hàm kiểm tra xem có thay đổi nào không
  void _checkForChanges() {
    // So sánh ngày tháng năm
    final bool dateChanged = !DateUtils.isSameDay(_selectedDate, _initialDate);
        
    final bool timeChanged = _selectedTime.hour != _initialTime.hour ||
        _selectedTime.minute != _initialTime.minute;

    final bool nameChanged = _nameController.text != _initialName;
    final bool phoneChanged = _phoneController.text != _initialPhone;
    final bool addressChanged = _addressController.text != _initialAddress;
    final bool notesChanged = _notesController.text != _initialNotes;

    final bool hasChanged = dateChanged || timeChanged || nameChanged || phoneChanged || addressChanged || notesChanged;

    // Chỉ cập nhật state nếu trạng thái thay đổi (từ true -> false hoặc ngược lại)
    if (hasChanged != _isChanged) {
      setState(() {
        _isChanged = hasChanged;
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime.now().subtract(const Duration(days: 30)), lastDate: DateTime(2101));
    if (picked != null && !DateUtils.isSameDay(picked, _selectedDate)) {
      setState(() => _selectedDate = picked);
      _checkForChanges(); // (MỚI) Kiểm tra
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _selectedTime);
    if (picked != null && (picked.hour != _selectedTime.hour || picked.minute != _selectedTime.minute)) {
      setState(() => _selectedTime = picked);
      _checkForChanges(); // (MỚI) Kiểm tra
    }
  }

  @override
  void dispose() {
    // (MỚI) Gỡ listeners
    _nameController.removeListener(_checkForChanges);
    _phoneController.removeListener(_checkForChanges);
    _addressController.removeListener(_checkForChanges);
    _notesController.removeListener(_checkForChanges);

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
    // (MỚI) Thêm kiểm tra ở đây, mặc dù nút đã bị vô hiệu hóa
    if (!_isChanged) {
      Navigator.of(context).pop(); // Chỉ pop, không trả về gì
      return;
    }

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
      note: _notesController.text.trim(), // (SỬA) Cập nhật note
    );

    // Build DTO for API
    final dto = <String, dynamic>{
      'PatientFullName': updated.patientFullName,
      'Phone': updated.phone,
      'AppointmentDate': DateFormat('yyyy-MM-dd').format(updated.appointmentDate), // (SỬA) Dùng DateFormat
      'AppointmentTime': updated.appointmentTime,
      'PatientAddress': updated.patientAddress, // (SỬA) Thêm address
      'Note': updated.note, // (SỬA) Thêm note
    };

    final closeLoading = await showLoadingDialog(context, message: 'Đang lưu thay đổi...');
    try {
      await AppointmentService.instance.updateAppointment(updated.id, dto);
      closeLoading();
      
      // (Bỏ SnackBar ở đây, để màn hình trước (Detail) tự hiển thị)
      
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
    final dateDisplay = DateFormat('dd/MM/yyyy').format(_selectedDate); // (SỬA) Dùng DateFormat

    return Scaffold(
      appBar: AppBar(title: const Text('Chỉnh Sửa Lịch Hẹn'), backgroundColor: Colors.blue.shade800,foregroundColor: Colors.white,),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // (SỬA) Thêm border cho đẹp hơn
          TextField(
            controller: _nameController, 
            decoration: const InputDecoration(
              labelText: 'Tên bệnh nhân (*)', 
              border: OutlineInputBorder(), 
              prefixIcon: Icon(Icons.person_outline)
            )
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phoneController, 
            decoration: const InputDecoration(
              labelText: 'Số điện thoại (*)', 
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.phone_outlined)
            ), 
            keyboardType: TextInputType.phone
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _addressController, 
            decoration: const InputDecoration(
              labelText: 'Địa chỉ (Tùy chọn)', 
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.location_on_outlined)
            ),
          ),
          const SizedBox(height: 12),
          // (SỬA) Dùng Card cho đẹp
          Card(
            child: ListTile(
              leading: const Icon(Icons.calendar_today, color: Colors.blue), 
              title: Text('Ngày: $dateDisplay'), 
              trailing: const Icon(Icons.keyboard_arrow_down),
              onTap: _pickDate
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.access_time, color: Colors.blue), 
              title: Text('Giờ: ${_selectedTime.format(context)}'), 
              trailing: const Icon(Icons.keyboard_arrow_down),
              onTap: _pickTime
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController, 
            decoration: const InputDecoration(
              labelText: 'Ghi chú (Tùy chọn)', 
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.note_alt_outlined)
            ), 
            maxLines: 3
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50, // (MỚI) Thêm chiều cao
            child: ElevatedButton(
              // ======================================================
              // === ✨ THAY ĐỔI: VÔ HIỆU HÓA NÚT KHI KHÔNG THAY ĐỔI ===
              onPressed: _isChanged ? _saveChanges : null,
              // ======================================================
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                backgroundColor: Colors.blue.shade700,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
              ),
              child: const Text('Lưu thay đổi', style: TextStyle(fontSize: 16)), // (SỬA)
            ),
          )
        ]),
      ),
    );
  }
}