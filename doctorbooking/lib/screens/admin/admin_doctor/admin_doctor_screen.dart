import 'package:flutter/material.dart';
import 'package:doctorbooking/models/doctor.dart';
import 'add_edit_doctor_screen.dart';
import 'package:doctorbooking/services/doctor.dart';

class AdminDoctorScreen extends StatefulWidget {
  const AdminDoctorScreen({super.key});

  @override
  State<AdminDoctorScreen> createState() => _AdminDoctorScreenState();
}

class _AdminDoctorScreenState extends State<AdminDoctorScreen> {
  List<Doctor> _doctors = [];
  String _searchQuery = '';

  bool _isLoading = true;
  String? _loadingError;

  // track id of item being deleted to show progress on that item
  String? _deletingId;

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    setState(() {
      _isLoading = true;
      _loadingError = null;
    });

    try {
      final list = await DoctorService.instance.fetchDoctors();
      if (!mounted) return;
      setState(() {
        _doctors = list;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingError = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  List<Doctor> get _filteredDoctors {
    if (_searchQuery.isEmpty) {
      return _doctors;
    }
    final query = _searchQuery.toLowerCase();
    return _doctors.where((doctor) {
      final name = (doctor.fullName ?? '').toLowerCase();
      final spec = (doctor.specialtyName).toLowerCase();
      return name.contains(query) || spec.contains(query);
    }).toList();
  }

  void _navigateAndAddDoctor(BuildContext context) async {
    final newDoctor = await Navigator.of(context).push<Doctor>(
      MaterialPageRoute(builder: (ctx) => const AddEditDoctorScreen()),
    );

    if (newDoctor != null) {
      setState(() {
        _doctors.add(newDoctor);
      });
      _showSnack('Đã thêm thành công Bác sĩ ${newDoctor.fullName ?? ''}');
    }
  }

  void _navigateAndEditDoctor(
    BuildContext context,
    Doctor doctorToEdit,
  ) async {
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
      _showSnack(
        'Đã cập nhật thông tin Bác sĩ ${updatedDoctor.fullName ?? ''}',
      );
    }
  }

  Future<void> _confirmAndDelete(BuildContext context, Doctor doctor) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Bạn có chắc chắn muốn xóa Bác sĩ ${doctor.fullName ?? ''} không? Thao tác này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            child: const Text('Không'),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _deletingId = doctor.id);

    try {
      await DoctorService.instance.deleteDoctor(doctor.id);
      if (!mounted) return;
      setState(() => _doctors.removeWhere((d) => d.id == doctor.id));
      _showSnack('Đã xóa Bác sĩ ${doctor.fullName ?? ''}', isError: true);
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '');
      _showSnack('Xóa thất bại: $msg', isError: true);
    } finally {
      if (!mounted) return;
      setState(() => _deletingId = null);
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError
              ? Colors.red.shade600
              : Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Widget _buildAvatar(Doctor doctor) {
    final avatar = doctor.avatarUrl;
    final displayName = doctor.fullName ?? '';
    final initials = displayName.isEmpty
        ? '?'
        : displayName
              .trim()
              .split(RegExp(r'\s+'))
              .map((s) => s.isNotEmpty ? s[0] : '')
              .take(2)
              .join()
              .toUpperCase();

    if (avatar != null && avatar.isNotEmpty) {
      return CircleAvatar(
        radius: 30,
        backgroundColor: Colors.grey[200],
        backgroundImage: NetworkImage(avatar),
        onBackgroundImageError: (_, __) {
          // fallback will show child
        },
        child: Container(),
      );
    }

    return CircleAvatar(
      radius: 30,
      backgroundColor: Colors.grey.shade200,
      child: Text(
        initials,
        style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
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
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
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
                  labelStyle: TextStyle(
                    color: Colors.blue.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : (_loadingError != null)
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Lỗi khi tải danh sách: $_loadingError',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: _loadDoctors,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadDoctors,
                    child: _filteredDoctors.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [
                              SizedBox(height: 80),
                              Center(child: Text('Không tìm thấy bác sĩ nào.')),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(bottom: 80),
                            itemCount: _filteredDoctors.length,
                            itemBuilder: (context, index) {
                              final doctor = _filteredDoctors[index];
                              final deletingThis = _deletingId == doctor.id;
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  leading: _buildAvatar(doctor),
                                  title: Text(
                                    doctor.fullName ?? 'Không rõ tên',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color(0xFF0D47A1),
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Text(
                                        doctor.specialtyName,
                                        style: TextStyle(
                                          color: Colors.blue.shade700,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      if ((doctor.hospital ?? '').isNotEmpty)
                                        Text(
                                          doctor.hospital!,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      if ((doctor.phone ?? '').isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 6.0,
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.phone,
                                                size: 14,
                                                color: Colors.black45,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                doctor.phone!,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                  trailing: deletingThis
                                      ? const SizedBox(
                                          width: 36,
                                          height: 36,
                                          child: Center(
                                            child: SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            ),
                                          ),
                                        )
                                      : PopupMenuButton<String>(
                                          icon: const Icon(Icons.more_vert),
                                          onSelected: (value) {
                                            if (value == 'edit') {
                                              _navigateAndEditDoctor(
                                                context,
                                                doctor,
                                              );
                                            } else if (value == 'delete') {
                                              _confirmAndDelete(
                                                context,
                                                doctor,
                                              );
                                            }
                                          },
                                          itemBuilder: (BuildContext context) =>
                                              <PopupMenuEntry<String>>[
                                                const PopupMenuItem<String>(
                                                  value: 'edit',
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.edit_outlined,
                                                        color: Colors.blue,
                                                      ),
                                                      SizedBox(width: 8),
                                                      Text('Sửa'),
                                                    ],
                                                  ),
                                                ),
                                                const PopupMenuItem<String>(
                                                  value: 'delete',
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.delete_outline,
                                                        color: Colors.red,
                                                      ),
                                                      SizedBox(width: 8),
                                                      Text('Xóa'),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                        ),
                                ),
                              );
                            },
                          ),
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
}
