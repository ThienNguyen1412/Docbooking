import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/appointments.dart' as model;

class EditAppointmentScreen extends StatefulWidget {
  final model.Appointment initialAppointment;

  const EditAppointmentScreen({super.key, required this.initialAppointment});

  @override
  State<EditAppointmentScreen> createState() => _EditAppointmentScreenState();
}

class _EditAppointmentScreenState extends State<EditAppointmentScreen> {
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

  // text controllers
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final appointment = widget.initialAppointment;

    // --- 1. Lưu giá trị gốc ---
    _initialDate = appointment.appointmentDate;
    _initialTime = _parseTimeStringToTimeOfDay(appointment.appointmentTime) ?? TimeOfDay.now();
    _initialName = appointment.patientFullName ?? '';
    _initialPhone = appointment.phone ?? '';
    _initialAddress = appointment.patientAddress ?? '';
    _initialNotes = appointment.note ?? '';

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

  @override
  void dispose() {
    // Gỡ listeners trước khi dispose
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

  /// (MỚI) Hàm kiểm tra xem có thay đổi nào không
  void _checkForChanges() {
    final bool dateChanged = _selectedDate.day != _initialDate.day ||
        _selectedDate.month != _initialDate.month ||
        _selectedDate.year != _initialDate.year;
        
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

  TimeOfDay? _parseTimeStringToTimeOfDay(String? time) {
    if (time == null || time.isEmpty) return null;
    try {
      // Expect "HH:mm" or "H:mm"
      final parts = time.split(':');
      if (parts.length >= 2) {
        final h = int.tryParse(parts[0]) ?? 0;
        final m = int.tryParse(parts[1]) ?? 0;
        return TimeOfDay(hour: h, minute: m);
      }
      // fallback attempt parse via DateTime
      final dt = DateTime.parse(time);
      return TimeOfDay(hour: dt.hour, minute: dt.minute);
    } catch (_) {
      return null;
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _checkForChanges(); // (MỚI) Kiểm tra thay đổi sau khi chọn
    }
  }

  Future<void> _pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(context: context, initialTime: _selectedTime);
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
      _checkForChanges(); // (MỚI) Kiểm tra thay đổi sau khi chọn
    }
  }

  /// (MỚI) Hàm lưu thay đổi
  void _saveChanges() {
    // Bạn vẫn có thể kiểm tra _isChanged ở đây một lần nữa cho chắc chắn
    if (!_isChanged) return; 
    
    final appointment = widget.initialAppointment;

    // build updated appointment using copyWith from model.Appointment
    final updated = appointment.copyWith(
      appointmentDate: _selectedDate,
      appointmentTime: model.Appointment.timeOfDayToString(_selectedTime),
      patientFullName: _nameController.text.trim().isEmpty ? appointment.patientFullName : _nameController.text.trim(),
      phone: _phoneController.text.trim().isEmpty ? appointment.phone : _phoneController.text.trim(),
      patientAddress: _addressController.text.trim().isEmpty ? appointment.patientAddress : _addressController.text.trim(),
      note: _notesController.text.trim().isEmpty ? appointment.note : _notesController.text.trim(),
    );

    // Chỉ trả về 'updated' (gây ra SnackBar) khi có thay đổi
    Navigator.pop(context, updated);
  }

  @override
  Widget build(BuildContext context) {
    final appointment = widget.initialAppointment;

    final dateDisplay = DateFormat('dd/MM/yyyy').format(_selectedDate);
    final timeDisplay = _selectedTime.format(context);

    final doctorDisplay = (appointment.doctorName != null && appointment.doctorName!.isNotEmpty)
        ? appointment.doctorName!
        : (appointment.doctorId ?? 'Không rõ bác sĩ');

    // Note: model.Appointment does not have 'specialty' by default in the provided model.
    // If you added specialty to your model, show it here. Otherwise skip or show empty.
    final specialty = (appointment.toJson()['specialty'] ?? '').toString();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh Sửa Lịch Hẹn'),
        backgroundColor: Colors.blue.shade800,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Thông tin bệnh nhân', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Tên bệnh nhân',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Số điện thoại',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.phone_outlined),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: 'Địa chỉ (Tùy chọn)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Thông tin lịch hẹn', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.medical_services_outlined, color: Colors.blue),
              title: Text(doctorDisplay, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: specialty.isNotEmpty ? Text(specialty) : null,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.calendar_today, color: Colors.blue),
              title: Text('Ngày hẹn: $dateDisplay'),
              trailing: const Icon(Icons.keyboard_arrow_down),
              onTap: () => _pickDate(context),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.access_time, color: Colors.blue),
              title: Text('Giờ hẹn: $timeDisplay'),
              trailing: const Icon(Icons.keyboard_arrow_down),
              onTap: () => _pickTime(context),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Ghi chú (Tùy chọn)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.note_alt_outlined),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Cập nhật lịch hẹn'),
              // ======================================================
              // === ✨ THAY ĐỔI: VÔ HIỆU HÓA NÚT KHI KHÔNG THAY ĐỔI ===
              onPressed: _isChanged ? _saveChanges : null,
              // ======================================================
              style: ElevatedButton.styleFrom(
                // (MỚI) Thêm màu xám khi nút bị vô hiệu hóa
                disabledBackgroundColor: const Color.fromARGB(255, 224, 224, 224),
                backgroundColor: Colors.blue.shade700,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}