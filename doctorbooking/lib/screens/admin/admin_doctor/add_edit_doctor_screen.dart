import 'package:flutter/material.dart';
import 'package:doctorbooking/models/doctors.dart';
import 'package:doctorbooking/models/specialty.dart';
import 'package:doctorbooking/services/specialty.dart';
import 'package:doctorbooking/services/doctor.dart'; // adjust if your file name differs

class AddEditDoctorScreen extends StatefulWidget {
  final Doctors? doctor; // dùng model mới

  const AddEditDoctorScreen({super.key, this.doctor});

  @override
  State<AddEditDoctorScreen> createState() => _AddEditDoctorScreenState();
}

class _AddEditDoctorScreenState extends State<AddEditDoctorScreen> {
  final _formKey = GlobalKey<FormState>();
  bool get _isEditing => widget.doctor != null;

  late final TextEditingController _nameController;
  late final TextEditingController _hospitalController;
  late final TextEditingController _phoneController;
  late final TextEditingController _imageController;

  final SpecialityService _specialityService = SpecialityService();
  List<Specialty> _specialties = [];
  bool _loadingSpecialties = true;
  String? _specialtyError;

  // store selected specialty id (this is what backend expects)
  String? _selectedSpecialtyId;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.doctor?.fullName ?? '');
    _hospitalController = TextEditingController(text: widget.doctor?.hospital ?? '');
    _phoneController = TextEditingController(text: widget.doctor?.phone ?? '');
    _imageController = TextEditingController(text: widget.doctor?.avatarUrl ?? '');
    // If your Doctors model includes specialtyId, prefer that; otherwise will try to resolve by name after loading list
    _selectedSpecialtyId = null;
    _loadSpecialties();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _hospitalController.dispose();
    _phoneController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  Future<void> _loadSpecialties() async {
    setState(() {
      _loadingSpecialties = true;
      _specialtyError = null;
    });
    try {
      final list = await _specialityService.ListSpecialty();
      if (!mounted) return;
      setState(() {
        _specialties = list;
        // Try to preselect:
        if (widget.doctor != null) {
          // If your doctor model has specialtyId field, use it; otherwise try match by name
          // Try best-effort: check 'specialtyId' field on doctor (if you added it), else match by specialtyName
          final doc = widget.doctor!;
          // If Doctors has specialtyId property uncomment below:
          // if (doc.specialtyId != null && doc.specialtyId!.isNotEmpty) {
          //   _selectedSpecialtyId = doc.specialtyId;
          // } else
          if ((doc.specialtyName).isNotEmpty) {
            final match = _specialties.firstWhere(
              (s) => (s.name ?? '').toLowerCase() == doc.specialtyName.toLowerCase(),
              orElse: () => Specialty(id: '', name: '', iconKey: ''),
            );
            if (match.id.isNotEmpty) {
              _selectedSpecialtyId = match.id;
            }
          }
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _specialtyError = e.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _loadingSpecialties = false;
      });
    }
  }

  Future<void> _saveForm() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // validate specialty id present
    if (_selectedSpecialtyId == null || _selectedSpecialtyId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn chuyên khoa'), backgroundColor: Colors.redAccent));
      return;
    }

    final fullName = _nameController.text.trim();
    final hospital = _hospitalController.text.trim().isEmpty ? null : _hospitalController.text.trim();
    final phone = _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim();
    final imageText = _imageController.text.trim();
    final avatarUrl = imageText.isEmpty ? null : imageText;
    final specialtyId = _selectedSpecialtyId!; // send id to server

    setState(() => _isSaving = true);

    try {
      final service = DoctorService.instance;

      if (_isEditing) {
        final updated = await service.updateDoctor(
          id: widget.doctor!.id,
          fullName: fullName,
          hospital: hospital,
          specialtyId: specialtyId, // pass id
          phone: phone,
          avatarUrl: avatarUrl,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cập nhật bác sĩ thành công'), backgroundColor: Colors.green));
        Navigator.of(context).pop(updated);
      } else {
        final created = await service.createDoctor(
          fullName: fullName,
          hospital: hospital,
          specialtyId: specialtyId, // pass id
          phone: phone,
          avatarUrl: avatarUrl,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tạo bác sĩ thành công'), backgroundColor: Colors.green));
        Navigator.of(context).pop(created);
      }
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $msg'), backgroundColor: Colors.redAccent));
    } finally {
      if (mounted) setState(() => _isSaving = false);
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
            onPressed: _isSaving ? null : _saveForm,
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
              // Specialty dropdown (value is id)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: _loadingSpecialties
                    ? const SizedBox(height: 56, child: Center(child: CircularProgressIndicator()))
                    : (_specialtyError != null)
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.red.shade100),
                                ),
                                child: Text(
                                  'Không tải được danh sách chuyên khoa.\n${_specialtyError!}',
                                  style: TextStyle(color: Colors.red.shade700),
                                ),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton.icon(
                                onPressed: _loadSpecialties,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Thử lại'),
                              ),
                            ],
                          )
                        : DropdownButtonFormField<String>(
                            value: _selectedSpecialtyId,
                            decoration: InputDecoration(
                              labelText: 'Chuyên khoa',
                              prefixIcon: const Icon(Icons.medical_services),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            items: _specialties.map((s) {
                              final name = s.name ?? '';
                              return DropdownMenuItem<String>(
                                value: s.id,
                                child: Text(name),
                              );
                            }).toList(),
                            onChanged: (v) => setState(() => _selectedSpecialtyId = v),
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Vui lòng chọn chuyên khoa';
                              return null;
                            },
                          ),
              ),
              _buildTextField(controller: _hospitalController, label: 'Bệnh viện', icon: Icons.local_hospital),
              _buildTextField(controller: _phoneController, label: 'Số điện thoại', icon: Icons.phone, keyboardType: TextInputType.phone),
              // Image URL optional (nullable)
              _buildTextField(controller: _imageController, label: 'URL Hình ảnh (tùy chọn)', icon: Icons.image, optional: true),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  icon: _isSaving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.save),
                  label: Text(_isSaving ? 'Đang lưu...' : 'Lưu thông tin'),
                  onPressed: _isSaving ? null : _saveForm,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
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
    bool optional = false,
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
          if (optional) return null;
          if (value == null || value.isEmpty) {
            return 'Vui lòng không để trống trường này';
          }
          return null;
        },
      ),
    );
  }
}