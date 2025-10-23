// File: lib/screens/admin/admin_doctor/admin_doctor_screen.dart

import 'package:flutter/material.dart';
import '../../../../models/doctor.dart';
import 'add_edit_doctor_screen.dart';

class AdminDoctorScreen extends StatefulWidget {
  const AdminDoctorScreen({super.key});

  @override
  State<AdminDoctorScreen> createState() => _AdminDoctorScreenState();
}

class _AdminDoctorScreenState extends State<AdminDoctorScreen> {
  // Tạo bản sao có thể thay đổi của danh sách bác sĩ
  List<Doctor> _doctors = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Khởi tạo danh sách từ model để có thể thêm/sửa/xóa
    _doctors = List.from(Doctor.getDoctors());
  }

  List<Doctor> get _filteredDoctors {
    if (_searchQuery.isEmpty) {
      return _doctors;
    }
    final query = _searchQuery.toLowerCase();
    return _doctors.where((doctor) {
      return doctor.name.toLowerCase().contains(query) ||
             doctor.specialty.toLowerCase().contains(query);
    }).toList();
  }

  // --- CÁC HÀM XỬ LÝ THÊM/SỬA/XÓA ---

  // 1. Điều hướng đến trang Thêm Bác sĩ
  void _navigateAndAddDoctor(BuildContext context) async {
    final newDoctor = await Navigator.of(context).push<Doctor>(
      MaterialPageRoute(builder: (ctx) => const AddEditDoctorScreen()),
    );

    if (newDoctor != null) {
      setState(() {
        _doctors.add(newDoctor);
      });
      _showSuccessSnackBar('Đã thêm thành công Bác sĩ ${newDoctor.name}');
    }
  }

  // 2. Điều hướng đến trang Sửa Bác sĩ
  void _navigateAndEditDoctor(BuildContext context, Doctor doctorToEdit) async {
    final updatedDoctor = await Navigator.of(context).push<Doctor>(
      MaterialPageRoute(
        builder: (ctx) => AddEditDoctorScreen(doctor: doctorToEdit),
      ),
    );

    if (updatedDoctor != null) {
      setState(() {
        final index = _doctors.indexWhere((d) => d.id == updatedDoctor.id);
        if (index != -1) {
          _doctors[index] = updatedDoctor;
        }
      });
      _showSuccessSnackBar('Đã cập nhật thông tin Bác sĩ ${updatedDoctor.name}');
    }
  }

  // 3. Hiển thị dialog xác nhận Xóa
  void _showDeleteConfirmationDialog(BuildContext context, Doctor doctor) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa Bác sĩ ${doctor.name} không? Thao tác này không thể hoàn tác.'),
        actions: [
          TextButton(
            child: const Text('Không'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
            onPressed: () {
              setState(() {
                _doctors.removeWhere((d) => d.id == doctor.id);
              });
              Navigator.of(ctx).pop();
              _showSuccessSnackBar('Đã xóa Bác sĩ ${doctor.name}', isError: true);
            },
          ),
        ],
      ),
    );
  }

  // Hàm helper để hiển thị SnackBar
  void _showSuccessSnackBar(String message, {bool isError = false}) {
     ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
      ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Tìm kiếm Bác sĩ theo tên hoặc chuyên khoa...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Danh sách Bác sĩ',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Chip(
                  label: Text('Tổng: ${_filteredDoctors.length}'),
                  backgroundColor: Colors.blue.withOpacity(0.1),
                  labelStyle: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
          Expanded(
            child: _filteredDoctors.isEmpty
                ? const Center(child: Text('Không tìm thấy bác sĩ nào.'))
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: _filteredDoctors.length,
                    itemBuilder: (context, index) {
                      final doctor = _filteredDoctors[index];
                      return _buildDoctorCard(context, doctor);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateAndAddDoctor(context),
        backgroundColor: Colors.red.shade700,
        tooltip: 'Thêm Bác sĩ mới',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildDoctorCard(BuildContext context, Doctor doctor) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: NetworkImage(doctor.image),
          onBackgroundImageError: (exception, stackTrace) {
             // Có thể hiển thị icon mặc định khi ảnh lỗi
          },
        ),
        title: Text(
          doctor.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0D47A1)),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              doctor.specialty,
              style: TextStyle(color: doctor.color, fontWeight: FontWeight.w600),
            ),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text('${doctor.rating} (${doctor.reviews} đánh giá)'),
              ],
            ),
            Text(doctor.hospital, style: const TextStyle(fontSize: 13, color: Colors.black54)),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            if (value == 'edit') {
              _navigateAndEditDoctor(context, doctor);
            } else if (value == 'delete') {
              _showDeleteConfirmationDialog(context, doctor);
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit_outlined, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Sửa'),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Xóa'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}