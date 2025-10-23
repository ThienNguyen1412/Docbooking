// File: lib/screens/appointment/edit_appointment_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/appointment.dart' as model;

class EditAppointmentScreen extends StatefulWidget {
  final model.Appointment initialAppointment;

  const EditAppointmentScreen({super.key, required this.initialAppointment});

  @override
  State<EditAppointmentScreen> createState() => _EditAppointmentScreenState();
}

class _EditAppointmentScreenState extends State<EditAppointmentScreen> {
  // Controller cho ngày và giờ
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  // ✨ THÊM CONTROLLER CHO CÁC TRƯỜDNG TEXT
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final appointment = widget.initialAppointment;
    
    // Khởi tạo ngày và giờ
    try {
      _selectedDate = DateFormat('dd/MM/yyyy').parse(appointment.date);
      _selectedTime = TimeOfDay.fromDateTime(DateFormat('h:mm a').parse(appointment.time));
    } catch (e) {
      _selectedDate = DateTime.now();
      _selectedTime = TimeOfDay.now();
    }
    
    // ✨ KHỞI TẠO CÁC TEXT CONTROLLER VỚI DỮ LIỆU CÓ SẴN
    _nameController = TextEditingController(text: appointment.patientName);
    _phoneController = TextEditingController(text: appointment.patientPhone);
    _addressController = TextEditingController(text: appointment.patientAddress);
    _notesController = TextEditingController(text: appointment.notes);
  }

  @override
  void dispose() {
    // ✨ HỦY CÁC CONTROLLER ĐỂ TRÁNH RÒ RỈ BỘ NHỚ
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // ... (Hàm _pickDate và _pickTime giữ nguyên)
  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime.now(), lastDate: DateTime(2101));
    if (picked != null && picked != _selectedDate) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(context: context, initialTime: _selectedTime);
    if (picked != null && picked != _selectedTime) setState(() => _selectedTime = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh Sửa Lịch Hẹn'),
        backgroundColor: Colors.blue.shade800,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- THÔNG TIN BỆNH NHÂN ---
            const Text('Thông tin bệnh nhân', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Tên bệnh nhân', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person_outline)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Số điện thoại', border: OutlineInputBorder(), prefixIcon: Icon(Icons.phone_outlined)),
              keyboardType: TextInputType.phone,
            ),
             const SizedBox(height: 16),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Địa chỉ (Tùy chọn)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.location_on_outlined)),
            ),

            const Divider(height: 32),

            // --- THÔNG TIN LỊCH HẸN ---
            const Text('Thông tin lịch hẹn', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.medical_services_outlined, color: Colors.blue),
                title: Text(widget.initialAppointment.doctorName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(widget.initialAppointment.specialty),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today, color: Colors.blue),
                title: Text('Ngày hẹn: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}'),
                trailing: const Icon(Icons.keyboard_arrow_down),
                onTap: () => _pickDate(context),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.access_time, color: Colors.blue),
                title: Text('Giờ hẹn: ${_selectedTime.format(context)}'),
                trailing: const Icon(Icons.keyboard_arrow_down),
                onTap: () => _pickTime(context),
              ),
            ),
            const SizedBox(height: 16),
             TextField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Ghi chú (Tùy chọn)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.note_alt_outlined)),
              maxLines: 3,
            ),

            const SizedBox(height: 32),

            // Nút Cập nhật
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Cập nhật lịch hẹn'),
                onPressed: () {
                  // ✨ SỬ DỤNG `copyWith` VỚI ĐẦY ĐỦ CÁC TRƯỜNG
                  final updatedAppointment = widget.initialAppointment.copyWith(
                    date: DateFormat('dd/MM/yyyy').format(_selectedDate),
                    time: _selectedTime.format(context),
                    patientName: _nameController.text,
                    patientPhone: _phoneController.text,
                    patientAddress: _addressController.text,
                    notes: _notesController.text,
                  );
                  Navigator.pop(context, updatedAppointment);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}