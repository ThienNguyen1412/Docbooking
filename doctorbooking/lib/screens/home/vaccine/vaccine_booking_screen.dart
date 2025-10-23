// File: lib/screens/vaccine/vaccine_booking_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Cần để định dạng ngày

class VaccineBookingScreen extends StatefulWidget {
  const VaccineBookingScreen({super.key});

  @override
  State<VaccineBookingScreen> createState() => _VaccineBookingScreenState();
}

class _VaccineBookingScreenState extends State<VaccineBookingScreen> {
  final _formKey = GlobalKey<FormState>();

  // --- Mock Data ---
  final List<String> _vaccineTypes = [
    'Vắc xin 6 trong 1 (Infanrix Hexa)',
    'Vắc xin Phế cầu (Prevenar 13)',
    'Vắc xin Cúm mùa',
    'Vắc xin Sởi - Quai bị - Rubella (MMR)',
    'Vắc xin Thủy đậu',
    'Vắc xin Viêm gan B',
  ];
  // ---------------

  String? _selectedVaccine;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime; // Hoặc dùng các slot cố định nếu muốn

  final _patientNameController = TextEditingController();
  final _patientDobController = TextEditingController(); // Controller cho ngày sinh
  final _phoneController = TextEditingController();

  // Hàm để chọn ngày
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(), // Chỉ cho chọn từ ngày hiện tại trở đi
      lastDate: DateTime.now().add(const Duration(days: 90)), // Giới hạn 3 tháng
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        // Có thể tự động chọn giờ mặc định hoặc để người dùng chọn
      });
    }
  }

  // Hàm để chọn giờ (Ví dụ đơn giản, bạn có thể thay bằng chọn slot)
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

   // Hàm để chọn ngày sinh
  Future<void> _selectDob(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 5)), // Gợi ý 5 tuổi
      firstDate: DateTime(1920), // Giới hạn năm sinh
      lastDate: DateTime.now(),   // Không cho chọn ngày tương lai
    );
    if (picked != null) {
      setState(() {
        _patientDobController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }


  @override
  void dispose() {
    _patientNameController.dispose();
    _patientDobController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submitBooking() {
    if (_formKey.currentState!.validate()) {
      // Logic xử lý đặt lịch ở đây (ví dụ: gọi API)
      // Lấy thông tin: _selectedVaccine, _selectedDate, _selectedTime,
      // _patientNameController.text, _patientDobController.text, _phoneController.text

      // Hiển thị thông báo thành công (ví dụ)
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Đặt lịch thành công!'),
          content: Text(
              'Bạn đã đặt lịch tiêm $_selectedVaccine\nvào lúc ${_selectedTime?.format(context) ?? "--:--"} ngày ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}\n cho bệnh nhân ${_patientNameController.text}.\nVui lòng kiểm tra lại thông tin và đến đúng giờ.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop(); // Đóng dialog
                Navigator.of(context).pop(); // Quay lại trang trước
              },
              child: const Text('Đồng ý'),
            )
          ],
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đặt Lịch Tiêm Chủng'),
        backgroundColor: Colors.teal.shade700, // Sử dụng màu Teal
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Bước 1: Chọn Vắc xin ---
              _buildSectionTitle(context, '1. Chọn loại vắc xin'),
              DropdownButtonFormField<String>(
                value: _selectedVaccine,
                hint: const Text('Chọn loại vắc xin bạn muốn tiêm'),
                isExpanded: true,
                items: _vaccineTypes.map((String vaccine) {
                  return DropdownMenuItem<String>(
                    value: vaccine,
                    child: Text(vaccine),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedVaccine = newValue;
                  });
                },
                validator: (value) =>
                    value == null ? 'Vui lòng chọn loại vắc xin' : null,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.vaccines_rounded),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 24),

              // --- Bước 2: Chọn Thời gian ---
              _buildSectionTitle(context, '2. Chọn ngày giờ tiêm'),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Ngày tiêm',
                          prefixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          _selectedDate == null
                              ? 'Chọn ngày'
                              : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectTime(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Giờ tiêm',
                          prefixIcon: Icon(Icons.access_time),
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          _selectedTime == null
                              ? 'Chọn giờ'
                              : _selectedTime!.format(context),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Thêm validation riêng cho ngày giờ nếu cần
              if (_selectedDate == null || _selectedTime == null)
              Padding(
                 padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                 child: Text(
                  (_selectedDate == null && _selectedTime == null) ? 'Vui lòng chọn ngày và giờ tiêm' :
                  (_selectedDate == null) ? 'Vui lòng chọn ngày tiêm' : 'Vui lòng chọn giờ tiêm',
                  style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
                 ),
              ),
              const SizedBox(height: 24),

              // --- Bước 3: Thông tin người tiêm ---
              _buildSectionTitle(context, '3. Thông tin người tiêm'),
              TextFormField(
                controller: _patientNameController,
                decoration: const InputDecoration(
                  labelText: 'Họ và tên người tiêm',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Vui lòng nhập họ tên' : null,
              ),
              const SizedBox(height: 16),
              // TextFormField cho ngày sinh (chỉ đọc, dùng DatePicker)
              TextFormField(
                controller: _patientDobController,
                readOnly: true, // Không cho sửa trực tiếp
                onTap: () => _selectDob(context), // Mở DatePicker khi nhấn vào
                decoration: const InputDecoration(
                  labelText: 'Ngày sinh',
                  hintText: 'Chọn ngày sinh',
                  prefixIcon: Icon(Icons.cake_outlined),
                  border: OutlineInputBorder(),
                ),
                 validator: (value) =>
                    value == null || value.isEmpty ? 'Vui lòng chọn ngày sinh' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Số điện thoại liên hệ',
                  prefixIcon: Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                 validator: (value) =>
                    value == null || value.isEmpty ? 'Vui lòng nhập số điện thoại' : null,
              ),
              const SizedBox(height: 32),

              // --- Nút Xác nhận ---
              ElevatedButton.icon(
                onPressed: _submitBooking,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('XÁC NHẬN ĐẶT LỊCH'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget helper cho tiêu đề mỗi phần
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade800,
            ),
      ),
    );
  }
}