import 'package:flutter/material.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dữ liệu mẫu cho FAQ
    final List<Map<String, String>> faqs = [
      {
        'question': 'Làm thế nào để đặt lịch khám?',
        'answer': 'Bạn vào mục Đặt lịch, chọn bác sĩ, ngày và giờ phù hợp, sau đó xác nhận đặt lịch.'
      },
      {
        'question': 'Tôi muốn hủy lịch hẹn thì làm sao?',
        'answer': 'Truy cập "Lịch hẹn của tôi", chọn lịch cần hủy, nhấn nút Hủy lịch.'
      },
      {
        'question': 'Liên hệ hỗ trợ qua đâu?',
        'answer': 'Bạn có thể gọi hotline: 1900 1234 hoặc gửi email đến support@benhvienabc.com.'
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Hỗ trợ')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.phone, color: Colors.teal),
              title: const Text('Hotline hỗ trợ'),
              subtitle: const Text('1900 1234'),
              onTap: () {
                // Tính năng gọi điện thoại (nếu muốn)
              },
            ),
            ListTile(
              leading: const Icon(Icons.email, color: Colors.teal),
              title: const Text('Email hỗ trợ'),
              subtitle: const Text('support@benhvienabc.com'),
              onTap: () {
                // Tính năng gửi email (nếu muốn)
              },
            ),
            const Divider(height: 32),
            const Text('Câu hỏi thường gặp', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...faqs.map((faq) => ExpansionTile(
              leading: const Icon(Icons.help_outline, color: Colors.blue),
              title: Text(faq['question'] ?? ''),
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(faq['answer'] ?? ''),
                )
              ],
            )),
          ],
        ),
      ),
    );
  }
}