// File: lib/screens/lookup/lookup_results_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/medical_result.dart'; // Import model
import 'result_details_screen.dart'; // Import trang chi tiết

class LookupResultsScreen extends StatefulWidget {
  const LookupResultsScreen({super.key});

  @override
  State<LookupResultsScreen> createState() => _LookupResultsScreenState();
}

class _LookupResultsScreenState extends State<LookupResultsScreen> {
  final _patientNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _searchAttempted = false; // Đã bấm tìm kiếm chưa
  List<MedicalResult> _foundResults = [];

  // --- MOCK DATABASE ---
  // (Giả lập dữ liệu trả về từ server)
  final List<MedicalResult> _mockDatabase = [
    MedicalResult(
      id: 'KQ123',
      title: 'Kết quả xét nghiệm thần kinh',
      patientName: 'Nguyễn Minh Thiện',
      date: DateTime(2025, 10, 18),
      doctorName: 'PGS.TS Trần Ngọc Lương',
      department: 'Khoa Thần kinh',
      diagnosis: 'Các chỉ số trong giới hạn bình thường',
      notes:
          '- Glucose: 5.2 mmol/L\n- Cholesterol: 4.8 mmol/L\n- Triglyceride: 1.7 mmol/L\n\nKết luận: Bình thường.',
    ),
    MedicalResult(
      id: 'KQ124',
      title: 'Kết quả Chụp X-Quang Nội tiết',
      patientName: 'Nguyễn Minh Thiện',
      date: DateTime(2025, 10, 17),
      doctorName: 'ThS.BS Lương Quỳnh Hoa',
      department: 'Khoa Chẩn đoán Hình ảnh',
      diagnosis: 'Viêm phế quản nhẹ',
      notes:
          '- Hình ảnh phổi sáng đều.\n- Có dày nhẹ thành phế quản 2 bên.\n\nKết luận: Theo dõi viêm phế quản.',
    ),
    MedicalResult(
      id: 'KQ125',
      title: 'Kết quả khám dịch vụ',
      patientName: 'Nguyễn Minh Thiện',
      date: DateTime(2025, 8, 21),
      doctorName: 'BS. Trần Thị Đoàn ',
      department: 'Khoa Cơ xương khớp',
      // --- CẬP NHẬT CHO KQ125 ---
      diagnosis: 'Đau mỏi vai gáy - Thoái hóa cột sống cổ',
      notes:
          '- Bệnh nhân than phiền đau mỏi vai gáy kéo dài.\n- Chụp X-Quang cột sống cổ.\n- Kê toa thuốc giảm đau, kháng viêm.\n- Hẹn tái khám sau 2 tuần.',
    ),
    // --- BỆNH NHÂN MỚI: HUỲNH QUỐC NAM ---
    MedicalResult(
      id: 'KQ126',
      title: 'Kết quả nội soi tai mũi họng',
      patientName: 'Huỳnh Quốc Nam',
      date: DateTime(2025, 10, 19),
      doctorName: 'BS. Phạm Văn Dũng',
      department: 'Khoa Tai Mũi Họng',
      diagnosis: 'Viêm xoang cấp',
      notes:
          '- Nội soi thấy niêm mạc xoang phù nề, có dịch.\n- Kê toa kháng sinh, kháng viêm, xịt mũi.\n- Tái khám sau 7 ngày.',
    ),
  ];
  // --- END MOCK DATABASE ---

  // --- Giả lập bảng User (Tên -> SĐT) để kiểm tra đăng nhập ---
  final Map<String, String> _mockUserPhonebook = {
    'Nguyễn Minh Thiện': '0386006055',
    'Huỳnh Quốc Nam': '0909123456', // SĐT mới cho bệnh nhân mới
  };
  // --------------------------------------------------------

  Future<void> _performSearch() async {
    if (!_formKey.currentState!.validate()) {
      return; // Nếu form không hợp lệ, không làm gì cả
    }

    setState(() {
      _isLoading = true;
      _searchAttempted = true;
      _foundResults = []; // Xóa kết quả cũ
    });

    // Giả lập gọi API trong 2 giây
    await Future.delayed(const Duration(seconds: 2));

    final patientName = _patientNameController.text;
    final phone = _phoneController.text;

    // --- LOGIC TÌM KIẾM ĐƯỢC CẬP NHẬT ---
    // 1. Kiểm tra xem tên và sđt có khớp trong "sổ điện thoại" giả lập không
    final bool credentialsMatch = _mockUserPhonebook.containsKey(patientName) &&
        _mockUserPhonebook[patientName] == phone;

    if (credentialsMatch) {
      // 2. Nếu khớp, lọc tất cả kết quả của bệnh nhân đó
      final results = _mockDatabase
          .where((result) => result.patientName == patientName)
          .toList();

      setState(() {
        _foundResults = results;
      });
    }
    // Nếu không khớp, _foundResults sẽ vẫn rỗng (đã set ở trên)
    // --- KẾT THÚC CẬP NHẬT LOGIC TÌM KIẾM ---

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _patientNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tra Cứu Kết Quả'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSearchForm(),
            const SizedBox(height: 24),
            _buildResultsArea(),
          ],
        ),
      ),
    );
  }

  // Widget cho biểu mẫu tìm kiếm
  Widget _buildSearchForm() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Vui lòng nhập thông tin để tra cứu',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _patientNameController,
                decoration: const InputDecoration(
                  labelText: 'Tên bệnh nhân (có dấu)',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên bệnh nhân';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Số điện thoại đăng ký',
                  prefixIcon: Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập số điện thoại';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _performSearch,
                icon: const Icon(Icons.search),
                label: const Text('TRA CỨU'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget hiển thị kết quả (loading, rỗng, hoặc danh sách)
  Widget _buildResultsArea() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_searchAttempted) {
      // Chưa tìm kiếm, không hiển thị gì
      return const SizedBox.shrink();
    }

    if (_foundResults.isEmpty) {
      // Đã tìm nhưng không thấy
      return Center(
        child: Column(
          children: [
            Icon(Icons.search_off, size: 60, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'Không tìm thấy kết quả',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Vui lòng kiểm tra lại Tên bệnh nhân và Số điện thoại.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Đã tìm thấy kết quả
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tìm thấy ${_foundResults.length} kết quả cho BN "${_foundResults.first.patientName}"',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true, // Quan trọng khi lồng ListView trong Column
          physics:
              const NeverScrollableScrollPhysics(), // Tắt cuộn của ListView
          itemCount: _foundResults.length,
          itemBuilder: (context, index) {
            final result = _foundResults[index];
            return _buildResultItem(result);
          },
        ),
      ],
    );
  }

  // Widget cho 1 mục kết quả trong danh sách
  Widget _buildResultItem(MedicalResult result) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Icon(Icons.description_outlined, color: Colors.blue.shade800),
        ),
        title: Text(result.title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle:
            Text('Ngày khám: ${DateFormat('dd/MM/yyyy').format(result.date)}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResultDetailsScreen(result: result),
            ),
          );
        },
      ),
    );
  }
}