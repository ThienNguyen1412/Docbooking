// File: lib/screens/home/guide_screen.dart
// PHƯƠNG ÁN 2: THIẾT KẾ DÙNG CARD VÀ VISIBILITY

import 'package:flutter/material.dart';

// 1. Class dữ liệu (Giữ nguyên)
class GuideStep {
  final String header;
  final String body;
  bool isExpanded;

  GuideStep({
    required this.header,
    required this.body,
    this.isExpanded = false,
  });
}

// 2. StatefulWidget (Giữ nguyên)
class GuideScreen extends StatefulWidget {
  const GuideScreen({super.key});

  @override
  State<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends State<GuideScreen> {
  // 3. State (Giữ nguyên)
  List<GuideStep> _doctorSteps = [];
  List<GuideStep> _serviceSteps = [];

  // 4. initState (Giữ nguyên)
  @override
  void initState() {
    super.initState();
    _doctorSteps = _getDoctorSteps();
    _serviceSteps = _getServiceSteps();
  }

  // 5. Hàm Build (Thiết kế lại)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hướng Dẫn Đặt Khám'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- PHẦN 1: HƯỚNG DẪN ĐẶT LỊCH BÁC SĨ ---
          _buildSectionHeader(
            context,
            icon: Icons.medical_services_rounded,
            title: 'Hướng dẫn đặt lịch hẹn với bác sĩ',
          ),
          // Dùng Column để build các Card
          Column(
            children: _doctorSteps.asMap().entries.map((entry) {
              int index = entry.key;
              GuideStep step = entry.value;
              return _buildClickableStep(step, index + 1, () {
                setState(() {
                  step.isExpanded = !step.isExpanded;
                });
              });
            }).toList(),
          ),

          // Ngăn cách 2 phần
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: Divider(thickness: 1),
          ),

          // --- PHẦN 2: HƯỚNG DẪN ĐẶT LỊCH DỊCH VỤ ---
          _buildSectionHeader(
            context,
            icon: Icons.inventory_2_rounded,
            title: 'Hướng dẫn đặt lịch khám dịch vụ/gói khám',
          ),
          // Dùng Column để build các Card
          Column(
            children: _serviceSteps.asMap().entries.map((entry) {
              int index = entry.key;
              GuideStep step = entry.value;
              return _buildClickableStep(step, index + 1, () {
                setState(() {
                  step.isExpanded = !step.isExpanded;
                });
              });
            }).toList(),
          ),
        ],
      ),
    );
  }

  // 6. Widget mới: _buildClickableStep (Thay thế _buildStepList)
  Widget _buildClickableStep(GuideStep step, int stepNumber, VoidCallback onTap) {
    bool isExpanded = step.isExpanded;
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias, // Bo góc cho InkWell
      child: InkWell(
        onTap: onTap,
        child: Column(
          // Thêm hiệu ứng animation mượt mà khi xổ ra/thu vào
          children: [
            // Header (ListTile)
            ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    isExpanded ? Colors.blue.shade800 : Colors.grey.shade300,
                foregroundColor: isExpanded ? Colors.white : Colors.black87,
                child: Text(
                  '$stepNumber',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(
                step.header,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isExpanded ? Colors.blue.shade800 : Colors.black87,
                ),
              ),
              trailing: Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
                color: Colors.grey.shade600,
              ),
            ),
            
            // Body (Nội dung chi tiết)
            // Dùng Visibility để ẩn/hiện
            Visibility(
              visible: isExpanded,
              child: Container(
                color: Colors.blue.shade50, // Nền nhẹ cho phần nội dung
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                alignment: Alignment.centerLeft,
                child: Text(
                  step.body,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.4,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Tiêu đề (Giữ nguyên)
  Widget _buildSectionHeader(BuildContext context,
      {required IconData icon, required String title}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue.shade800, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  // Dữ liệu (Giữ nguyên)
  List<GuideStep> _getDoctorSteps() {
    return [
      GuideStep(
        header: 'Bước 1: Chọn chức năng đặt lịch mới',
        body:
            'Tại Trang chủ, bạn có thể nhấn vào nút "Đặt lịch hẹn" hoặc "Tìm bác sĩ" để bắt đầu quy trình đặt khám.',
      ),
      GuideStep(
        header: 'Bước 2: Chọn chuyên khoa và bác sĩ',
        body:
            'Hệ thống sẽ hiển thị danh sách các chuyên khoa. Bạn chọn một chuyên khoa (ví dụ: Tim mạch, Da liễu), sau đó chọn một bác sĩ cụ thể trong khoa đó mà bạn muốn khám.',
      ),
      GuideStep(
        header: 'Bước 3: Điền thông tin đầy đủ',
        body:
            'Chọn ngày và khung giờ khám còn trống. Sau đó, điền thông tin hồ sơ bệnh nhân (cho bạn hoặc cho người thân) và mô tả ngắn gọn lý do khám hoặc triệu chứng.',
      ),
      GuideStep(
        header: 'Bước 4: Hoàn tất',
        body:
            'Xác nhận lại toàn bộ thông tin lịch hẹn. Lịch hẹn của bạn đã được ghi nhận. Vui lòng có mặt tại bệnh viện trước giờ hẹn 15 phút để làm thủ tục.',
      ),
    ];
  }

  List<GuideStep> _getServiceSteps() {
    return [
      GuideStep(
        header: 'Bước 1: Chọn chức năng "Dịch vụ"',
        body:
            'Trên thanh điều hướng chính (ở dưới cùng màn hình) hoặc tại Trang chủ, chọn mục "Dịch vụ" hoặc "Gói khám".',
      ),
      GuideStep(
        header: 'Bước 2: Tìm kiếm dịch vụ phù hợp',
        body:
            'Tìm kiếm và xem chi tiết các gói khám (ví dụ: Gói khám sức khỏe tổng quát, Gói tầm soát ung thư...) và chọn gói phù hợp với nhu cầu của bạn.',
      ),
      GuideStep(
        header: 'Bước 3: Điền đầy đủ thông tin',
        body:
            'Chọn ngày bạn mong muốn đến thực hiện dịch vụ và điền thông tin của người sẽ sử dụng gói khám.',
      ),
      GuideStep(
        header: 'Bước 4: Thanh toán',
        body:
            'Bạn có thể chọn một trong hai hình thức:\n- Thanh toán tại quầy: Hoàn tất đặt lịch và thanh toán sau tại quầy lễ tân của bệnh viện.\n- Thanh toán ngay: Chuyển khoản hoặc thanh toán qua ví điện tử/thẻ để tiết kiệm thời gian chờ đợi.',
      ),
      GuideStep(
        header: 'Bước 5: Hoàn tất',
        body:
            'Sau khi hoàn tất (và thanh toán nếu có), lịch hẹn dịch vụ của bạn đã được xác nhận. Vui lòng đến đúng ngày đã hẹn để được hướng dẫn thực hiện.',
      ),
    ];
  }
}