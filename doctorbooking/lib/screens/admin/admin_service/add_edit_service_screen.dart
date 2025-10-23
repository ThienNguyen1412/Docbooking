// File: lib/screens/admin/admin_service/add_edit_service_screen.dart

import 'package:flutter/material.dart';
import '../../../models/health_package.dart';

class AddEditServiceScreen extends StatefulWidget {
  final HealthPackage? healthPackage;

  const AddEditServiceScreen({super.key, this.healthPackage});

  @override
  State<AddEditServiceScreen> createState() => _AddEditServiceScreenState();
}

class _AddEditServiceScreenState extends State<AddEditServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  bool get _isEditing => widget.healthPackage != null;

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _oldPriceController;
  late TextEditingController _imageController;
  late TextEditingController _stepsController;

  // Checkbox states
  bool _isDiscount = false;
  bool _isFeatured = false;

  @override
  void initState() {
    super.initState();
    final pkg = widget.healthPackage;
    _nameController = TextEditingController(text: pkg?.name ?? '');
    _descriptionController = TextEditingController(text: pkg?.description ?? '');
    _priceController = TextEditingController(text: pkg?.price.toString() ?? '');
    _oldPriceController = TextEditingController(text: pkg?.oldPrice?.toString() ?? '');
    _imageController = TextEditingController(text: pkg?.image ?? '');
    _stepsController = TextEditingController(text: pkg?.steps.join('\n') ?? '');
    _isDiscount = pkg?.isDiscount ?? false;
    _isFeatured = pkg?.isFeatured ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _oldPriceController.dispose();
    _imageController.dispose();
    _stepsController.dispose();
    super.dispose();
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final newPackage = HealthPackage(
        id: widget.healthPackage?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        description: _descriptionController.text,
        price: int.tryParse(_priceController.text) ?? 0,
        oldPrice: _oldPriceController.text.isNotEmpty ? int.tryParse(_oldPriceController.text) : null,
        image: _imageController.text,
        steps: _stepsController.text.split('\n').where((s) => s.trim().isNotEmpty).toList(),
        isDiscount: _isDiscount,
        isFeatured: _isFeatured,
      );
      Navigator.of(context).pop(newPackage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(_isEditing ? 'Sửa Gói Khám' : 'Thêm Gói Khám Mới'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        actions: [IconButton(icon: const Icon(Icons.save), onPressed: _saveForm, tooltip: 'Lưu')],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Card cho thông tin cơ bản ---
              _buildSectionCard(
                title: 'Thông tin Gói khám',
                children: [
                  _buildTextField(controller: _nameController, label: 'Tên gói khám', icon: Icons.title),
                  _buildTextField(controller: _descriptionController, label: 'Mô tả ngắn', icon: Icons.description, maxLines: 3),
                  _buildTextField(controller: _imageController, label: 'URL Hình ảnh', icon: Icons.image, isOptional: true),
                ],
              ),
              
              // --- Card cho thiết lập giá ---
              _buildSectionCard(
                title: 'Thiết lập giá',
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildTextField(controller: _priceController, label: 'Giá (VNĐ)', icon: Icons.attach_money, keyboardType: TextInputType.number)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTextField(controller: _oldPriceController, label: 'Giá cũ (nếu có)', icon: Icons.money_off, keyboardType: TextInputType.number, isOptional: true)),
                    ],
                  ),
                  SwitchListTile(
                    title: const Text('Kích hoạt ưu đãi'),
                    value: _isDiscount,
                    onChanged: (bool value) => setState(() => _isDiscount = value),
                    activeColor: Colors.red,
                    secondary: const Icon(Icons.local_offer),
                  ),
                ],
              ),
              
              // --- Card cho chi tiết và phân loại ---
              _buildSectionCard(
                title: 'Chi tiết & Phân loại',
                children: [
                  _buildTextField(controller: _stepsController, label: 'Các bước khám (mỗi bước một dòng)', icon: Icons.format_list_numbered, maxLines: 5),
                  SwitchListTile(
                    title: const Text('Đánh dấu là gói nổi bật'),
                    value: _isFeatured,
                    onChanged: (bool value) => setState(() => _isFeatured = value),
                    secondary: const Icon(Icons.star),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Nút lưu
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text('Lưu Gói Khám', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  onPressed: _saveForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget helper để tạo một Card cho mỗi section
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
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  // Widget helper đã được cải tiến để tạo TextFormField
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool isOptional = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.grey.shade600),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (value) {
          if (!isOptional && (value == null || value.isEmpty)) {
            return 'Vui lòng không để trống trường này';
          }
          if (keyboardType == TextInputType.number && value != null && value.isNotEmpty && int.tryParse(value) == null) {
            return 'Vui lòng nhập một số hợp lệ';
          }
          return null;
        },
      ),
    );
  }
}