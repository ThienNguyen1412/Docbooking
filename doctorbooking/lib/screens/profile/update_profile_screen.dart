import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/user.dart'; // chỉnh nếu file service của bạn ở chỗ khác
import '../../models/user.dart';

class UpdateProfileScreen extends StatefulWidget {
  final User user;

  const UpdateProfileScreen({super.key, required this.user});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final _userService = UserService();
  late Future<User> _userFuture;

  @override
  void initState() {
    super.initState();
    // Nếu muốn luôn lấy bản mới nhất từ server:
    _userFuture = _userService.getUserById(widget.user.id);
    // Nếu không cần gọi lại, bạn có thể thay thành: Future.value(widget.user);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cập nhật thông tin')),
      body: FutureBuilder<User>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }
          if (snapshot.hasData) {
            final user = snapshot.data!;
            return ProfileForm(user: user);
          }
          return const Center(
            child: Text('Không tìm thấy dữ liệu người dùng.'),
          );
        },
      ),
    );
  }
}

class ProfileForm extends StatefulWidget {
  final User user;

  const ProfileForm({super.key, required this.user});

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late final TextEditingController _fullNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _birthDayController;
  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    final user = widget.user;
    _fullNameController = TextEditingController(text: user.fullName);
    _emailController = TextEditingController(text: user.email);
    _phoneController = TextEditingController(text: user.phone ?? '');
    _addressController = TextEditingController(text: user.address ?? '');
    _birthDayController = TextEditingController(
      text: user.birthDay != null
          ? DateFormat('yyyy-MM-dd').format(user.birthDay!)
          : '',
    );
    _selectedGender = (user.gender != null && user.gender!.isNotEmpty) ? user.gender : 'Khác';
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _birthDayController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    DateTime initialDate =
        DateTime.tryParse(_birthDayController.text) ?? DateTime(1995, 1, 1);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900, 1),
      lastDate: DateTime.now(),
      helpText: "Chọn ngày sinh",
    );
    if (picked != null) {
      setState(() {
        _birthDayController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _updateProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      try {
        final userService = UserService();
        final updatedUser = await userService.UpdateUserInfo(
          widget.user.id,
          _fullNameController.text.trim(),
          _emailController.text.trim(),
          _phoneController.text.trim(),
          _addressController.text.trim(),
          _birthDayController.text.isNotEmpty
              ? DateTime.parse(_birthDayController.text)
              : widget.user.birthDay ?? DateTime(2000, 1, 1),
          _selectedGender ?? 'Khác',
        );

        setState(() => _isLoading = false);

        // Trả kết quả về màn trước (nếu bạn muốn cập nhật UI parent)
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cập nhật thành công!')));
          Navigator.of(context).pop(updatedUser);
        }
      } on FormatException catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Dữ liệu ngày không hợp lệ: $e')));
      } on Exception catch (e) {
        setState(() => _isLoading = false);
        // Nếu UserService ném message rõ ràng, hiển thị trực tiếp
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              const SizedBox(height: 18),
              TextFormField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  labelText: 'Họ tên',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  hintText: 'Nhập họ tên',
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Vui lòng nhập họ tên'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  hintText: 'Nhập email',
                ),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Vui lòng nhập email'
                    : (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)
                          ? 'Email không hợp lệ'
                          : null),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Số điện thoại',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  hintText: 'Nhập số điện thoại',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return null;
                  if (!RegExp(r'^(?:0|\+84)[0-9]{9,10}$').hasMatch(value)) {
                    return 'Số điện thoại không hợp lệ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Địa chỉ',
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  hintText: 'Nhập địa chỉ',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _birthDayController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Ngày sinh',
                  prefixIcon: const Icon(Icons.cake),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: _selectDate,
                  ),
                  hintText: 'YYYY-MM-DD',
                ),
                onTap: _selectDate,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: InputDecoration(
                  labelText: 'Giới tính',
                  prefixIcon: const Icon(Icons.wc),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: [
                  'Nam',
                  'Nữ',
                  'Khác',
                ].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                onChanged: (value) => setState(() => _selectedGender = value),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Lưu thay đổi'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _isLoading ? null : _updateProfile,
              ),
            ],
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}