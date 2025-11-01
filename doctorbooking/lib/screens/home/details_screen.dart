import 'package:flutter/material.dart';
import '../../models/doctor.dart';
import '../../services/appointment.dart';

/// DetailsScreen (now Stateful) with safe booking flow and robust dialog handling.
class DetailsScreen extends StatefulWidget {
  final Doctor doctor;
  final void Function(Doctor, BookingDetails) onBookAppointment;

  const DetailsScreen({
    super.key,
    required this.doctor,
    required this.onBookAppointment,
  });

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  // show booking modal bottom sheet
  void _showBookingForm(BuildContext context, Doctor doctor) {
    // ✨ SỬA LỖI: Lưu lại context của màn hình DetailsScreen ("context bên ngoài")
    final BuildContext mainScreenContext = context;

    showModalBottomSheet(
      context: mainScreenContext, // Dùng context chính để mở
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        // Đây là context của riêng BottomSheet ("context bên trong")
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: BookingFormModal(
            doctor: doctor,
            onConfirm: (bookingDetails) async {
              // (A) Đóng BottomSheet bằng context "bên trong"
              try {
                if (Navigator.of(context).canPop()) Navigator.of(context).pop();
              } catch (e, st) {
                // ignore - keep going
                debugPrint('Error popping bottom sheet: $e\n$st');
              }

              // (B) Hiển thị dialog bằng context "bên ngoài"
              try {
                showDialog(
                  context: mainScreenContext, // ✨ SỬ DỤNG CONTEXT ĐÚNG
                  barrierDismissible: false,
                  useRootNavigator: true,
                  builder: (_) =>
                      const Center(child: CircularProgressIndicator()),
                );
              } catch (e, st) {
                debugPrint('Error showing loading dialog: $e\n$st');
              }

              try {
                // (C) Gọi API
                final created =
                    await AppointmentService.instance.createFromBookingDetails(
                  doctorId: doctor.id,
                  bookingDetails: bookingDetails,
                );

                // (D) Đóng loading dialog (root navigator)
                try {
                  final rootNav =
                      Navigator.of(mainScreenContext, rootNavigator: true); // ✨ SỬ DỤNG CONTEXT ĐÚNG
                  if (rootNav.canPop()) rootNav.pop();
                } catch (e, st) {
                  debugPrint('Error popping loading dialog: $e\n$st');
                }

                // (E) Kiểm tra mounted (của DetailsScreen)
                if (!mounted) return;

                // (F) Hiển thị SnackBar thành công bằng context "bên ngoài"
                ScaffoldMessenger.of(mainScreenContext).showSnackBar(const SnackBar( // ✨ SỬ DỤNG CONTEXT ĐÚNG
                  content: Text('Đặt lịch thành công'),
                  backgroundColor: Colors.green,
                ));

                // (G) Báo cho màn hình cha
                widget.onBookAppointment(doctor, bookingDetails);
              } catch (e, st) {
                debugPrint('Create appointment error: $e\n$st');
                
                // (H) Đóng loading dialog (nếu có lỗi)
                try {
                  final rootNav =
                      Navigator.of(mainScreenContext, rootNavigator: true); // ✨ SỬ DỤNG CONTEXT ĐÚNG
                  if (rootNav.canPop()) rootNav.pop();
                } catch (e2, st2) {
                  debugPrint('Error popping loading after failure: $e2\n$st2');
                }

                if (!mounted) return;

                // (I) Hiển thị SnackBar lỗi bằng context "bên ngoài"
                final msg = e.toString().replaceFirst('Exception: ', '');
                ScaffoldMessenger.of(mainScreenContext).showSnackBar(SnackBar( // ✨ SỬ DỤNG CONTEXT ĐÚNG
                  content: Text('Lỗi khi đặt lịch: $msg'),
                  backgroundColor: Colors.redAccent,
                ));
              }
            },
          ),
        );
      },
    );
  }

  Widget _avatarWidget(double radius) {
    final avatarUrl = widget.doctor.avatarUrl;
    final displayName = widget.doctor.fullName ?? '';
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey[200],
        backgroundImage: NetworkImage(avatarUrl),
        onBackgroundImageError: (_, __) {},
        child: Container(),
      );
    }
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
      child: Text(initials,
          style: TextStyle(fontSize: radius / 2.2, color: Colors.blue.shade700)),
    );
  }

  Widget _buildStarRating(int rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 18,
        );
      }),
    );
  }

  Widget _buildReviewItem(Map<String, dynamic> review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.only(bottom: 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.black12, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                review['name'] as String,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Spacer(),
              Text(
                review['date'] as String,
                style: const TextStyle(color: Colors.black54, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 4),
          _buildStarRating(review['rating'] as int),
          const SizedBox(height: 8),
          Text(
            review['comment'] as String,
            style: const TextStyle(fontSize: 15, height: 1.4),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final doctor = widget.doctor;
    final displayName = doctor.fullName ?? 'Không rõ tên';
    final specialty = doctor.specialtyName ?? '';
    final hospital = doctor.hospital ?? '';
    final phone = doctor.phone ?? '';

    final double averageRating = 4.8;
    final int reviewCount = 120;
    final List<Map<String, dynamic>> dummyReviews = [
      {
        'name': 'Nguyễn Văn Trung',
        'rating': 5,
        'comment': 'Bác sĩ rất tận tâm và chuyên nghiệp. Tôi rất hài lòng.',
        'date': '20/10/2025',
      },
      {
        'name': 'Trịnh Ngọc Hằng',
        'rating': 4,
        'comment': 'Tư vấn kỹ càng, rất đúng chuyên môn.',
        'date': '18/10/2025',
      },
      {
        'name': 'Trần Minh Quân',
        'rating': 5,
        'comment': 'Tuyệt vời!',
        'date': '15/10/2025',
      },
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(displayName),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _avatarWidget(50),
            const SizedBox(width: 16),
            Expanded(
              child:
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(displayName,
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D47A1))),
                const SizedBox(height: 5),
                Text(specialty,
                    style: const TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                        fontWeight: FontWeight.w600)),
                Text(hospital,
                    style:
                        const TextStyle(fontSize: 14, color: Colors.black54)),
                const SizedBox(height: 5),
                Row(children: [
                  const Icon(Icons.phone, color: Colors.green, size: 18),
                  const SizedBox(width: 5),
                  Text(phone)
                ]),
              ]),
            ),
          ]),
          const SizedBox(height: 24), // Tăng khoảng cách

          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 22),
              const SizedBox(width: 8),
              Text(
                averageRating.toStringAsFixed(1), // Dùng dữ liệu giả
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Text(
                "($reviewCount đánh giá)",
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ],
          ),

          const Divider(height: 40),

          const Text(
            "Đánh giá & Nhận xét",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          if (dummyReviews.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'Chưa có đánh giá nào.',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ),
            )
          else
            Column(
              children: dummyReviews
                  .map((review) => _buildReviewItem(review))
                  .toList(),
            ),

          const SizedBox(height: 30), // Khoảng cách trước nút đặt lịch

          Center(
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showBookingForm(context, doctor),
                icon: const Icon(Icons.calendar_today),
                label: const Text('Đặt lịch khám ngay',
                    style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

/// BookingDetails + BookingFormModal remain the same as before (copy from your existing code)
class BookingDetails {
  String name;
  String phone;
  String address;
  String note;
  TimeOfDay time;
  DateTime date;

  BookingDetails(
      {required this.name,
      required this.phone,
      required this.address,
      required this.note,
      required this.time,
      required this.date});
}

// You can reuse your existing BookingFormModal implementation here without changes.
class BookingFormModal extends StatefulWidget {
  final Doctor doctor;
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
        lastDate: DateTime.now().add(const Duration(days: 90)));
    if (picked != null && picked != _selectedDate)
      setState(() => _selectedDate = picked);
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked =
        await showTimePicker(context: context, initialTime: _selectedTime);
    if (picked != null && picked != _selectedTime)
      setState(() => _selectedTime = picked);
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
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Center(
                    child: Text('Đặt Lịch Khám Bác sĩ $displayName',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue))),
                const SizedBox(height: 15),
                Text('Chuyên khoa: $specialty',
                    style: const TextStyle(fontSize: 16)),
                Text('Bệnh viện: $hospital',
                    style: const TextStyle(fontSize: 16)),
                const Divider(height: 25),
                _buildTextField(
                    controller: _nameController,
                    label: 'Họ tên bệnh nhân (*)',
                    icon: Icons.person,
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'Vui lòng nhập họ tên' : null),
                const SizedBox(height: 15),
                _buildTextField(
                    controller: _phoneController,
                    label: 'Số điện thoại (*)',
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Vui lòng nhập số điện thoại'
                        : null),
                const SizedBox(height: 15),
                _buildTextField(
                    controller: _addressController,
                    label: 'Địa chỉ (*)',
                    icon: Icons.location_on,
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Vui lòng nhập địa chỉ'
                        : null),
                const SizedBox(height: 20),
                Text('Ngày đến khám (*):',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                _buildDateTimeButton(
                    icon: Icons.calendar_today,
                    text:
                        'Ngày: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    onPressed: _selectDate),
                const SizedBox(height: 15),
                Text('Giờ khám bệnh (*):',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                _buildDateTimeButton(
                    icon: Icons.access_time,
                    text: 'Giờ: ${_selectedTime.format(context)}',
                    onPressed: _selectTime),
                const SizedBox(height: 20),
                _buildTextField(
                    controller: _noteController,
                    label: 'Ghi chú (Tùy chọn)',
                    icon: Icons.notes,
                    maxLines: 3,
                    validator: (value) => null),
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
                                date: _selectedDate);
                            widget.onConfirm(bookingDetails);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10))),
                        child: const Text('Xác nhận Đặt lịch',
                            style: TextStyle(fontSize: 18)))),
              ]),
        ),
      ),
    );
  }

  Widget _buildTextField(
      {required TextEditingController controller,
      required String label,
      required IconData icon,
      TextInputType keyboardType = TextInputType.text,
      String? Function(String?)? validator,
      int maxLines = 1}) {
    return TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, color: Colors.blue),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 15, horizontal: 10)),
        validator: validator);
  }

  Widget _buildDateTimeButton(
      {required IconData icon,
      required String text,
      required VoidCallback onPressed}) {
    return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
            icon: Icon(icon, color: Colors.blue),
            label: Text(text, style: const TextStyle(fontSize: 16)),
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black87,
                side: const BorderSide(color: Colors.grey, width: 1),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                alignment: Alignment.centerLeft)));
  }
}