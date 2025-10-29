import 'package:flutter/material.dart';
import '../../models/doctors.dart'; // dùng API model (class Doctors)

// ----------------------------------------------------
// 1. MÀN HÌNH CHI TIẾT BÁC SĨ (DetailsScreen)
// ----------------------------------------------------
class DetailsScreen extends StatelessWidget {
  final Doctors doctor;
  // CẬP NHẬT: nhận callback với API model Doctors
  final void Function(Doctors, BookingDetails) onBookAppointment;

  const DetailsScreen({
    super.key,
    required this.doctor,
    required this.onBookAppointment,
  });

  // Hàm hiển thị Form Đặt lịch Modal
  void _showBookingForm(BuildContext context, Doctors doctor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: BookingFormModal(
            doctor: doctor,
            onConfirm: (bookingDetails) {
              Navigator.pop(context); // Đóng modal
              onBookAppointment(doctor, bookingDetails);
            },
          ),
        );
      },
    );
  }

  Widget _avatarWidget(double radius) {
    final avatarUrl = doctor.avatarUrl;
    final displayName = doctor.fullName ?? '';
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey[200],
        backgroundImage: NetworkImage(avatarUrl),
        onBackgroundImageError: (_, __) {
          // nothing, fallback to initials shown as child
        },
        child: Container(), // image will be shown via backgroundImage
      );
    }
    // fallback: initials
    final initials = displayName.trim().isEmpty
        ? '?'
        : displayName
            .trim()
            .split(RegExp(r'\s+'))
            .map((s) => s.isNotEmpty ? s[0] : '')
            .take(2)
            .join()
            .toUpperCase();
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey.shade200,
      child: Text(initials, style: TextStyle(fontSize: radius / 2.2, color: Colors.blue.shade700)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayName = doctor.fullName ?? 'Không rõ tên';
    final specialty = doctor.specialtyName ?? '';
    final hospital = doctor.hospital ?? '';
    final phone = doctor.phone ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(displayName),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- AVATAR + THÔNG TIN CƠ BẢN ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _avatarWidget(50),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D47A1),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        specialty,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        hospital,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(Icons.phone, color: Colors.green, size: 18),
                          const SizedBox(width: 5),
                          Text(phone),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // NOTE: rating/reviews/comments were removed because API model doesn't provide them.
            // If you later extend the API to include rating/comments, re-add display here.

            const SizedBox(height: 20),

            // --- NÚT ĐẶT LỊCH KHÁM ---
            Center(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showBookingForm(context, doctor);
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: const Text(
                    'Đặt lịch khám ngay',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------
// 2. MODEL TẠM THỜI CHO CHI TIẾT ĐẶT LỊCH (BookingDetails)
// ----------------------------------------------------
class BookingDetails {
  String name;
  String phone;
  String address;
  String note;
  TimeOfDay time;
  DateTime date;

  BookingDetails({
    required this.name,
    required this.phone,
    required this.address,
    required this.note,
    required this.time,
    required this.date,
  });
}

// ----------------------------------------------------
// 3. WIDGET FORM ĐẶT LỊCH (BookingFormModal)
//    Note: accepts API model Doctors
// ----------------------------------------------------
class BookingFormModal extends StatefulWidget {
  final Doctors doctor;
  final Function(BookingDetails) onConfirm;

  const BookingFormModal({super.key, required this.doctor, required this.onConfirm});

  @override
  State<BookingFormModal> createState() => _BookingFormModalState();
}

class _BookingFormModalState extends State<BookingFormModal> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _noteController = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayName = widget.doctor.fullName ?? '';
    final specialty = widget.doctor.specialtyName ?? '';
    final hospital = widget.doctor.hospital ?? '';

    return Container(
      padding: const EdgeInsets.all(20),
      height: MediaQuery.of(context).size.height * 0.9,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Text(
                  'Đặt Lịch Khám Bác sĩ $displayName',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
              ),
              const SizedBox(height: 15),
              Text('Chuyên khoa: $specialty', style: const TextStyle(fontSize: 16)),
              Text('Bệnh viện: $hospital', style: const TextStyle(fontSize: 16)),
              const Divider(height: 25),
              _buildTextField(
                controller: _nameController,
                label: 'Họ tên bệnh nhân (*)',
                icon: Icons.person,
                validator: (value) => (value == null || value.isEmpty) ? 'Vui lòng nhập họ tên' : null,
              ),
              const SizedBox(height: 15),
              _buildTextField(
                controller: _phoneController,
                label: 'Số điện thoại (*)',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (value) => (value == null || value.isEmpty) ? 'Vui lòng nhập số điện thoại' : null,
              ),
              const SizedBox(height: 15),
              _buildTextField(
                controller: _addressController,
                label: 'Địa chỉ (*)',
                icon: Icons.location_on,
                validator: (value) => (value == null || value.isEmpty) ? 'Vui lòng nhập địa chỉ' : null,
              ),
              const SizedBox(height: 20),
              Text('Ngày đến khám (*):', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              _buildDateTimeButton(
                icon: Icons.calendar_today,
                text: 'Ngày: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                onPressed: _selectDate,
              ),
              const SizedBox(height: 15),
              Text('Giờ khám bệnh (*):', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              _buildDateTimeButton(
                icon: Icons.access_time,
                text: 'Giờ: ${_selectedTime.format(context)}',
                onPressed: _selectTime,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _noteController,
                label: 'Ghi chú (Tùy chọn)',
                icon: Icons.notes,
                maxLines: 3,
                validator: (value) => null,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final bookingDetails = BookingDetails(
                        name: _nameController.text,
                        phone: _phoneController.text,
                        address: _addressController.text,
                        note: _noteController.text,
                        time: _selectedTime,
                        date: _selectedDate,
                      );
                      widget.onConfirm(bookingDetails);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Xác nhận Đặt lịch', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      ),
      validator: validator,
    );
  }

  Widget _buildDateTimeButton({
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: Icon(icon, color: Colors.blue),
        label: Text(text, style: const TextStyle(fontSize: 16)),
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black87,
          side: const BorderSide(color: Colors.grey, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          alignment: Alignment.centerLeft,
        ),
      ),
    );
  }
}