// File: lib/screens/admin/admin_doctor/add_edit_doctor_screen.dart

import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../models/doctor.dart';

class AddEditDoctorScreen extends StatefulWidget {
  // We can pass an existing doctor to edit, or null to add a new one
  final Doctor? doctor;

  const AddEditDoctorScreen({super.key, this.doctor});

  @override
  State<AddEditDoctorScreen> createState() => _AddEditDoctorScreenState();
}

class _AddEditDoctorScreenState extends State<AddEditDoctorScreen> {
  final _formKey = GlobalKey<FormState>();
  bool get _isEditing => widget.doctor != null;

  // Controllers for each form field
  late final TextEditingController _nameController;
  late final TextEditingController _specialtyController;
  late final TextEditingController _imageController;
  late final TextEditingController _hospitalController;
  late final TextEditingController _phoneController;
  late final TextEditingController _ratingController;
  late final TextEditingController _reviewsController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.doctor?.name ?? '');
    _specialtyController = TextEditingController(text: widget.doctor?.specialty ?? '');
    _imageController = TextEditingController(text: widget.doctor?.image ?? '');
    _hospitalController = TextEditingController(text: widget.doctor?.hospital ?? '');
    _phoneController = TextEditingController(text: widget.doctor?.phone ?? '');
    _ratingController = TextEditingController(text: widget.doctor?.rating.toString() ?? '0.0');
    _reviewsController = TextEditingController(text: widget.doctor?.reviews.toString() ?? '0');
  }

  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed.
    _nameController.dispose();
    _specialtyController.dispose();
    _imageController.dispose();
    _hospitalController.dispose();
    _phoneController.dispose();
    _ratingController.dispose();
    _reviewsController.dispose();
    super.dispose();
  }

  void _saveForm() {
    // Validate returns true if the form is valid, or false otherwise.
    if (_formKey.currentState!.validate()) {
      final newDoctor = Doctor(
        id: widget.doctor?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        specialty: _specialtyController.text,
        image: _imageController.text.isNotEmpty ? _imageController.text : 'https://www.w3schools.com/w3images/avatar2.png', // Default image
        hospital: _hospitalController.text,
        phone: _phoneController.text,
        rating: double.tryParse(_ratingController.text) ?? 0.0,
        reviews: int.tryParse(_reviewsController.text) ?? 0,
        // Assign a random color for new doctors
        color: widget.doctor?.color ?? Colors.primaries[Random().nextInt(Colors.primaries.length)],
        comments: widget.doctor?.comments ?? [], // Keep old comments or start with empty
      );
      
      // Pop the screen and return the new doctor object
      Navigator.of(context).pop(newDoctor);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Sửa thông tin Bác sĩ' : 'Thêm Bác sĩ mới'),
        backgroundColor: Colors.red.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveForm,
            tooltip: 'Lưu',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(controller: _nameController, label: 'Tên Bác sĩ', icon: Icons.person),
              _buildTextField(controller: _specialtyController, label: 'Chuyên khoa', icon: Icons.medical_services),
              _buildTextField(controller: _hospitalController, label: 'Bệnh viện', icon: Icons.local_hospital),
              _buildTextField(controller: _phoneController, label: 'Số điện thoại', icon: Icons.phone, keyboardType: TextInputType.phone),
              _buildTextField(controller: _imageController, label: 'URL Hình ảnh', icon: Icons.image),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(controller: _ratingController, label: 'Đánh giá', icon: Icons.star, keyboardType: TextInputType.number),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(controller: _reviewsController, label: 'Số lượt review', icon: Icons.reviews, keyboardType: TextInputType.number),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Lưu thông tin'),
                  onPressed: _saveForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700
                  ),
                ),
              )
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
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        keyboardType: keyboardType,
        validator: (value) {
          if (value == null || value.isEmpty) {
            // Image URL is optional
            if (label == 'URL Hình ảnh') return null;
            return 'Vui lòng không để trống trường này';
          }
          return null;
        },
      ),
    );
  }
}