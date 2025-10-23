import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/medical_result.dart';

class ResultDetailsScreen extends StatelessWidget {
  final MedicalResult result;

  const ResultDetailsScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50, // Nền nhẹ nhàng
      appBar: AppBar(
        title: const Text('Chi Tiết Kết Quả'), // Tiêu đề chung hơn
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        elevation: 0, // Bỏ bóng AppBar để hợp với thiết kế mới
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header với tiêu đề kết quả chính
            _buildHeaderCard(context),
            const SizedBox(height: 16),

            // Thông tin chi tiết bệnh nhân, ngày khám...
            _buildInfoCard(context),
            const SizedBox(height: 16),

            // Chẩn đoán của bác sĩ
            if (result.diagnosis.isNotEmpty) // Chỉ hiển thị nếu có chẩn đoán
              _buildDiagnosisCard(context),
            if (result.diagnosis.isNotEmpty) const SizedBox(height: 16),

            // Kết luận & Ghi chú
            if (result.notes.isNotEmpty) // Chỉ hiển thị nếu có ghi chú
              _buildNotesCard(context),
          ],
        ),
      ),
    );
  }

  // Widget Header Card (Tiêu đề kết quả, ID)
  Widget _buildHeaderCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: EdgeInsets.zero, // Bỏ margin mặc định của Card
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          // Gradient màu xanh đẹp mắt
          gradient: LinearGradient(
            colors: [Colors.blue.shade700, Colors.blue.shade900],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              result.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Mã kết quả: ${result.id}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Info Card (Bệnh nhân, Ngày khám, Khoa, Bác sĩ)
  Widget _buildInfoCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'THÔNG TIN CHUNG',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(height: 20, thickness: 1),
            _buildDetailRow(
              context,
              icon: Icons.person_outline,
              title: 'Bệnh nhân',
              value: result.patientName,
            ),
            _buildDetailRow(
              context,
              icon: Icons.calendar_today_outlined,
              title: 'Ngày khám',
              value: DateFormat('dd/MM/yyyy').format(result.date),
            ),
            _buildDetailRow(
              context,
              icon: Icons.medical_services_outlined,
              title: 'Khoa',
              value: result.department,
            ),
            _buildDetailRow(
              context,
              icon: Icons.person_pin_outlined,
              title: 'Bác sĩ',
              value: result.doctorName,
            ),
          ],
        ),
      ),
    );
  }

  // Widget Diagnosis Card
  Widget _buildDiagnosisCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CHẨN ĐOÁN CỦA BÁC SĨ',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(height: 20, thickness: 1),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.monitor_heart, size: 24, color: Colors.red.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    result.diagnosis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.red.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget Notes Card
  Widget _buildNotesCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'KẾT LUẬN & GHI CHÚ CHI TIẾT',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(height: 20, thickness: 1),
            Container(
              padding: const EdgeInsets.all(12.0),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.blue.shade50, // Nền nhẹ nhàng
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Text(
                result.notes,
                style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget helper để hiển thị một hàng thông tin
  Widget _buildDetailRow(BuildContext context,
      {required IconData icon, required String title, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blue.shade600), // Thay đổi màu icon
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:
                      const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87), // Thay đổi màu chữ
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}