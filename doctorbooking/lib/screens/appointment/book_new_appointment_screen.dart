// File: screens/appointment/book_new_appointment_screen.dart

import 'package:flutter/material.dart';
import '../../models/doctor.dart';
import '../home/details_screen.dart'; // Import để có thể sử dụng BookingDetails

// ----------------------------------------------------
// 1. MÀN HÌNH ĐẶT LỊCH HẸN MỚI
// ----------------------------------------------------
class BookNewAppointmentScreen extends StatefulWidget {
  final void Function(Doctor, BookingDetails) onBookAppointment;

  const BookNewAppointmentScreen({
    super.key,
    required this.onBookAppointment,
  });

  @override
  State<BookNewAppointmentScreen> createState() =>
      _BookNewAppointmentScreenState();
}

class _BookNewAppointmentScreenState extends State<BookNewAppointmentScreen> {
  final List<Doctor> allDoctors = Doctor.getDoctors();
  String? _selectedSpecialty;

  void _selectSpecialty(String specialty) {
    setState(() {
      _selectedSpecialty = (_selectedSpecialty == specialty) ? null : specialty;
    });
  }

  List<Doctor> get _filteredDoctors {
    if (_selectedSpecialty == null) {
      return allDoctors;
    }
    return allDoctors
        .where((doctor) => doctor.specialty == _selectedSpecialty)
        .toList();
  }

  // Cập nhật tên chuyên khoa để xuống dòng đẹp hơn
  final List<Map<String, dynamic>> categories = const [
    {'name': 'Nhi khoa', 'icon': Icons.child_care},
    {'name': 'Mắt', 'icon': Icons.remove_red_eye},
    {'name': 'Tai Mũi Họng', 'icon': Icons.hearing},
    {'name': 'Da Liễu', 'icon': Icons.self_improvement},
    {'name': 'Tim mạch', 'icon': Icons.favorite},
    {'name': 'Thần kinh', 'icon': Icons.psychology},
    {'name': 'Cơ xương khớp', 'icon': Icons.accessible_forward},
    {'name': 'Hô hấp', 'icon': Icons.air},
    {'name': 'Nội tiết', 'icon': Icons.medical_services},
    {'name': 'Sản phụ khoa', 'icon': Icons.pregnant_woman},
  ];

  // ✨ WIDGET ĐÃ ĐƯỢC CẬP NHẬT LẠI THÀNH GRIDVIEW CÓ THỂ CUỘN DỌC
  Widget _buildCategoryGrid() {
    // Chiều cao ước tính của một mục trong lưới
    const double itemHeight = 110.0;
    // Khoảng cách giữa các mục
    const double spacing = 12.0;
    // Chiều cao của container để hiển thị đúng 2 dòng
    const double containerHeight = (2 * itemHeight) + spacing;

    return SizedBox(
      height: containerHeight,
      child: GridView.builder(
        // Cho phép cuộn dọc nếu nội dung vượt quá chiều cao
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,      // 4 mục trên một hàng
          childAspectRatio: 0.75, // Điều chỉnh tỉ lệ (rộng/cao) cho cân đối
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
        ),
        itemBuilder: (context, index) {
          final category = categories[index];
          final categoryName = category['name'] as String;
          final isSelected = _selectedSpecialty == categoryName;

          return InkWell(
            onTap: () => _selectSpecialty(categoryName),
            borderRadius: BorderRadius.circular(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: isSelected ? Colors.blue.shade700 : Colors.blue.withOpacity(0.1),
                  child: Icon(
                    category['icon'] as IconData,
                    color: isSelected ? Colors.white : Colors.blue.shade700,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  categoryName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.blue.shade800 : Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Đổi màu nền cho sạch sẽ
      appBar: AppBar(
        title: const Text('Chọn Bác sĩ để Đặt lịch'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Phần chọn chuyên khoa
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    const Text(
                    'Chọn Chuyên khoa',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  _buildCategoryGrid(),
                ],
              ),
            ),
            
            // Dải phân cách
            Container(height: 8, color: Colors.grey[100]),
            
            // Phần danh sách bác sĩ
            Padding(
               padding: const EdgeInsets.all(16.0),
              child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        _selectedSpecialty == null
                            ? 'Danh sách Bác sĩ'
                            : 'Bác sĩ chuyên khoa: $_selectedSpecialty',
                        style:
                            const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ),

                    if (_filteredDoctors.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40.0),
                          child: Text('Không tìm thấy bác sĩ nào thuộc chuyên khoa này.'),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _filteredDoctors.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                           return DoctorCard(
                              doctor: _filteredDoctors[index],
                              onBookAppointment: widget.onBookAppointment,
                            );
                        },
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =======================================================================
// DOCTOR CARD WIDGET (Không thay đổi)
// =======================================================================

class DoctorCard extends StatelessWidget {
  final Doctor doctor;
  final void Function(Doctor, BookingDetails) onBookAppointment;

  const DoctorCard({
    super.key,
    required this.doctor,
    required this.onBookAppointment,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailsScreen(
                doctor: doctor,
                onBookAppointment: onBookAppointment,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              ClipOval(
                child: Image.network(
                  doctor.image,
                  width: 65,
                  height: 65,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D47A1),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      doctor.specialty,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      doctor.hospital,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: Colors.blue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}