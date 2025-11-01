// File: screens/service/service_booking_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Cần để định dạng ngày
import '../../models/health_package.dart';
import '../../models/notification.dart';
import 'service_payment_screen.dart';
import '../home/details_screen.dart'; // Cần cho BookingDetails

class ServiceBookingScreen extends StatefulWidget {
  final HealthPackage healthPackage;
  
  // ✨ (CẬP NHẬT) Thêm các tham số bị thiếu
  final Function(AppNotification) addNotification;
  final VoidCallback onBookingCompleteGoToAppointments; // <-- (MỚI)

  const ServiceBookingScreen({
    super.key,
    required this.healthPackage,
    required this.addNotification,
    required this.onBookingCompleteGoToAppointments, // <-- (MỚI)
  });

  @override
  State<ServiceBookingScreen> createState() => _ServiceBookingScreenState();
}

class _ServiceBookingScreenState extends State<ServiceBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _noteController = TextEditingController();
  final _dobController = TextEditingController(); // Controller cho ngày sinh

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _noteController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

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

  void _submitBooking() {
    if (_formKey.currentState!.validate()) {
      // Vì đã validate, chúng ta chắc chắn _selectedDate và _selectedTime không null
      final bookingDetails = BookingDetails(
        name: _nameController.text,
        phone: _phoneController.text,
        address: '', // Có thể thêm trường địa chỉ nếu cần
        note: _noteController.text,
        date: _selectedDate!,
        time: _selectedTime!,
      );
      
      // Chuyển sang màn hình thanh toán
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (ctx) => ServicePaymentScreen(
            healthPackage: widget.healthPackage,
            bookingDetails: bookingDetails, // Truyền BookingDetails
            addNotification: widget.addNotification,
            // ✨ (MỚI) Truyền callback này xuống màn hình Payment
            onBookingCompleteGoToAppointments: widget.onBookingCompleteGoToAppointments,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Điền Thông Tin Đặt Dịch Vụ'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildPackageSummary(),
              const SizedBox(height: 20),
              
              _buildSectionCard(
                title: 'Thông tin cá nhân',
                children: [
                  _buildTextField(controller: _nameController, labelText: 'Họ và Tên (*)', prefixIcon: Icons.person_outline),
                  const SizedBox(height: 16),
                  _buildTextField(controller: _phoneController, labelText: 'Số Điện Thoại (*)', prefixIcon: Icons.phone_outlined, keyboardType: TextInputType.phone),
                ],
              ),

              _buildSectionCard(
                title: 'Thời gian hẹn',
                children: [
                  _buildDateInputField(),
                  const SizedBox(height: 16),
                  _buildTimeInputField(),
                ],
              ),

              _buildSectionCard(
                title: 'Thông tin thêm',
                children: [
                  _buildTextField(controller: _noteController, labelText: 'Ghi chú (Tùy chọn)', prefixIcon: Icons.note_alt_outlined, maxLines: 4, isOptional: true),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _submitBooking,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade600,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 55),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('TIẾP TỤC THANH TOÁN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildPackageSummary() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.medical_services_outlined, color: Colors.blue, size: 32),
        title: Text(widget.healthPackage.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          widget.healthPackage.formattedPrice,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            const Divider(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool isOptional = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(prefixIcon, color: Colors.blue.shade700),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) {
        if (!isOptional && (value == null || value.isEmpty)) {
          return 'Vui lòng không để trống trường này';
        }
        return null;
      },
    );
  }

  Widget _buildDateInputField() {
    return TextFormField(
      controller: _dobController,
      decoration: InputDecoration(
        labelText: 'Ngày Khám (*)',
        prefixIcon: Icon(Icons.calendar_today, color: Colors.blue.shade700),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      readOnly: true,
      onTap: () => _selectDate(context),
      validator: (value) => (value == null || value.isEmpty) ? 'Vui lòng chọn ngày khám' : null,
    );
  }

  Widget _buildTimeInputField() {
    // Sử dụng một controller riêng cho giờ để hiển thị
    final timeController = TextEditingController(
      text: _selectedTime == null ? '' : _selectedTime!.format(context)
    );

    return TextFormField(
      controller: timeController,
      decoration: InputDecoration(
        labelText: 'Giờ Khám (*)',
        prefixIcon: Icon(Icons.access_time_filled_rounded, color: Colors.blue.shade800),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      readOnly: true,
      onTap: () => _selectTime(context),
      validator: (value) => (value == null || value.isEmpty) ? 'Vui lòng chọn giờ khám' : null,
    );
  }
}