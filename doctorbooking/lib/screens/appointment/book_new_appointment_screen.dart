import 'package:flutter/material.dart';
import '../../models/doctor.dart'; // API model (Doctor)
import '../../models/specialty.dart';
import '../../services/specialty.dart';
import '../../services/doctor.dart';
import '../home/details_screen.dart'; // nếu DetailsScreen trước đó nhận Doctor (UI model), bạn cần cập nhật DetailsScreen để chấp nhận Doctor

class BookNewAppointmentScreen extends StatefulWidget {
  final void Function(Doctor, BookingDetails) onBookAppointment;

  const BookNewAppointmentScreen({super.key, required this.onBookAppointment});

  @override
  State<BookNewAppointmentScreen> createState() =>
      _BookNewAppointmentScreenState();
}

class _BookNewAppointmentScreenState extends State<BookNewAppointmentScreen> {
  // list of API Doctors
  List<Doctor> allDoctors = [];
  String? _selectedSpecialty; // specialty id selected

  // specialties
  List<Specialty> _specialties = [];
  bool _isLoadingSpecialities = true;
  String? _specialityError;

  // doctors loading state
  bool _isLoadingDoctors = true;
  String? _doctorsError;

  late final SpecialityService _specialityService;
  late final DoctorService _doctorService;

  @override
  void initState() {
    super.initState();
    _specialityService = SpecialityService();
    _doctorService = DoctorService.instance;
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() {
      _isLoadingSpecialities = true;
      _specialityError = null;
      _isLoadingDoctors = true;
      _doctorsError = null;
    });

    // run both in parallel
    await Future.wait([_loadSpecialities(), _loadDoctors()]);
  }

  Future<void> _loadSpecialities() async {
    setState(() {
      _isLoadingSpecialities = true;
      _specialityError = null;
    });
    try {
      final list = await _specialityService.ListSpecialty();
      if (!mounted) return;
      setState(() => _specialties = list);
    } catch (e) {
      if (!mounted) return;
      setState(
        () => _specialityError = e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (!mounted) return;
      setState(() => _isLoadingSpecialities = false);
    }
  }

  Future<void> _loadDoctors() async {
    setState(() {
      _isLoadingDoctors = true;
      _doctorsError = null;
    });
    try {
      // fetch from API (returns List<Doctors>)
      final apiDoctors = await _doctorService.fetchDoctors();
      if (!mounted) return;

      // Keep API model directly
      setState(() => allDoctors = apiDoctors);
    } catch (e) {
      if (!mounted) return;
      setState(
        () => _doctorsError = e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (!mounted) return;
      setState(() => _isLoadingDoctors = false);
    }
  }

  void _selectSpecialty(String id) {
    setState(() {
      _selectedSpecialty = (_selectedSpecialty == id) ? null : id;
    });
  }

  // Filter doctors by selected specialty (compare by id or name)
  List<Doctor> get _filteredDoctors {
    if (_selectedSpecialty == null) {
      return allDoctors;
    }
    return allDoctors.where((doctor) {
      final docSpec = (doctor.specialtyName ?? '').toString();
      // match by specialty id if API doctor had specialtyId stored in specialtyName (unlikely)
      if (docSpec == _selectedSpecialty) return true;

      // match by name using loaded _specialties map
      final selected = _specialties.firstWhere(
        (s) => s.id == _selectedSpecialty,
        orElse: () => Specialty(id: '', name: '', iconKey: ''),
      );
      if (selected.name != null &&
          selected.name!.isNotEmpty &&
          docSpec.toLowerCase() == selected.name!.toLowerCase()) {
        return true;
      }

      // fallback: direct compare doctor's specialtyName with selected.name
      if (docSpec.toLowerCase() == (selected.name ?? '').toLowerCase()) return true;
      return false;
    }).toList();
  }

  IconData iconFromKey(String? rawKey) {
    if (rawKey == null || rawKey.trim().isEmpty) return Icons.medical_services;
    final key = rawKey.trim().toLowerCase().replaceAll(' ', '_');
    const Map<String, IconData> iconMap = {
      'child_care': Icons.child_care,
      'remove_red_eye': Icons.remove_red_eye,
      'hearing': Icons.hearing,
      'self_improvement': Icons.self_improvement, // Da Liễu
      'favorite': Icons.favorite, // Tim Mạch
      'psychology': Icons.psychology, // Thần Kinh
      'accessible_forward': Icons.accessible_forward, // Cơ Xương Khớp
      'air': Icons.air, // Hô Hấp
      'medical_services': Icons.medical_services,
      'pregnant_woman': Icons.pregnant_woman,
    };
    if (iconMap.containsKey(key)) return iconMap[key]!;
    for (final entry in iconMap.entries) {
      if (key.contains(entry.key) || entry.key.contains(key)) return entry.value;
    }
    return Icons.medical_services;
  }

  @override
  Widget build(BuildContext context) {
    // show combined loading if either specialties or doctors loading
    final isLoading = _isLoadingSpecialities || _isLoadingDoctors;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Chọn Bác sĩ để Đặt lịch'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Chọn Chuyên khoa',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),

          // specialties area
          if (_isLoadingSpecialities) ...[
            const SizedBox(height: 140, child: Center(child: CircularProgressIndicator())),
          ] else if (_specialityError != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(children: [
                Container(
                  height: 120,
                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                  child: Center(child: Text('Không thể tải chuyên khoa. Vui lòng thử lại.\n${_specialityError!}', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[700]))),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(onPressed: _loadSpecialities, icon: const Icon(Icons.refresh), label: const Text('Thử lại')),
              ]),
            ),
          ] else if (_specialties.isEmpty) ...[
            const SizedBox(height: 120, child: Center(child: Text('Hiện chưa có chuyên khoa nào.'))),
          ] else ...[
            SizedBox(
              height: 250, // Giữ chiều cao để cuộn 2 hàng
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  crossAxisCount: 4, // 4 ô mỗi hàng
                  mainAxisSpacing: 18, // Khoảng cách dọc
                  crossAxisSpacing: 18, // Khoảng cách ngang
                  // ======================================================
                  // === ✨ THAY ĐỔI: SỬA LỖI OVERFLOW ===
                  childAspectRatio: 0.7, // Giảm tỷ lệ để tăng chiều cao cho ô
                  // ======================================================
                  children: _specialties.map((s) {
                    final name = s.name ?? '';
                    final id = s.id;
                    final isSelected = _selectedSpecialty == id;
                    final icon = iconFromKey(s.iconKey ?? s.name);

                    return InkWell(
                      onTap: () => _selectSpecialty(id),
                      borderRadius: BorderRadius.circular(100),
                      child: Column(
                        children: [
                          Container(
                            width: 65,
                            height: 65,
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.blue.shade800 : Colors.blue.shade50,
                              shape: BoxShape.circle,
                              border: isSelected ? Border.all(color: Colors.blue.shade900, width: 2.0) : null,
                            ),
                            child: Center(
                              child: Icon(
                                icon,
                                color: isSelected ? Colors.white : Colors.blue.shade700,
                                size: 28,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            name,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected ? Colors.blue.shade900 : const Color.fromARGB(255, 0, 0, 0),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                            )
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],

          Container(height: 8, color: Colors.grey[100]),
          const Padding(padding: EdgeInsets.all(16.0), child: Text('Chọn Bác Sĩ', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87))),

          // doctors list area
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _isLoadingDoctors
                  ? const Center(child: CircularProgressIndicator())
                  : (_doctorsError != null)
                      ? Center(child: Text('Lỗi khi tải bác sĩ: $_doctorsError'))
                      : _filteredDoctors.isEmpty
                          ? const Center(child: Text('Không tìm thấy bác sĩ nào thuộc chuyên khoa này.', style: TextStyle(color: Colors.black54)))
                          : ListView.separated(
                              itemCount: _filteredDoctors.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                return DoctorCard(doctor: _filteredDoctors[index], onBookAppointment: widget.onBookAppointment);
                              },
                            ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// === DOCTOR CARD KHÔNG THAY ĐỔI ===
// ============================================================

class DoctorCard extends StatelessWidget {
  final Doctor doctor;
  final void Function(Doctor, BookingDetails) onBookAppointment;

  const DoctorCard({super.key, required this.doctor, required this.onBookAppointment});

  @override
  Widget build(BuildContext context) {
    final displayName = doctor.fullName ?? doctor.id ?? '';
    final avatarUrl = (doctor.avatarUrl != null && doctor.avatarUrl!.isNotEmpty) ? doctor.avatarUrl : null;

    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailsScreen(
                doctor: doctor,
                onBookAppointment: (bookingDoctor, bookingDetails) {
                  // propagate callback with API model
                  onBookAppointment(bookingDoctor as Doctor, bookingDetails);
                },
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              ClipOval(
                child: avatarUrl != null
                    ? Image.network(
                        avatarUrl,
                        width: 65,
                        height: 65,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _avatarPlaceholder(65, displayName),
                      )
                    : _avatarPlaceholder(65, displayName),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(displayName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))),
                  const SizedBox(height: 4),
                  Text(doctor.specialtyName ?? '', style: const TextStyle(fontSize: 15, color: Colors.blue)),
                  const SizedBox(height: 4),
                  Text(doctor.hospital ?? '', style: const TextStyle(fontSize: 14, color: Colors.black54), maxLines: 1, overflow: TextOverflow.ellipsis),
                ]),
              ),
              const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.blue),
            ],
          ),
        ),
      ),
    );
  }

  Widget _avatarPlaceholder(double size, String name) {
    final initials = name.trim().isEmpty ? '?' : name.trim().split(RegExp(r'\s+')).map((s) => s.isNotEmpty ? s[0] : '').take(2).join().toUpperCase();
    return Container(width: size, height: size, color: Colors.grey.shade200, child: Center(child: Text(initials, style: TextStyle(fontSize: size / 3, color: Colors.blue.shade700))));
  }
}