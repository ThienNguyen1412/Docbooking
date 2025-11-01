import  'package:flutter/material.dart';

class TermsAndPolicyScreen extends StatelessWidget {
  const TermsAndPolicyScreen({super.key});

  // --- Helper Widgets ---

  // Tiêu đề cho mỗi mục LỚN (I, II, III...)
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0D1F3C), // Màu xanh đậm
            ),
      ),
    );
  }

  // Tiêu đề cho mỗi mục NHỎ (1, 2, 3...)
  Widget _buildSubHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
      ),
    );
  }

  // Một đoạn văn bản thông thường
  Widget _buildParagraph(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.5, // Giãn dòng cho dễ đọc
              color: Colors.grey[700],
              fontSize: 16,
            ),
      ),
    );
  }

  // Một mục trong danh sách (list item)
  Widget _buildListItem(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4.0, right: 8.0),
            child: Icon(Icons.circle, size: 8, color: Colors.blue.shade700),
          ),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.5,
                    color: Colors.grey[700],
                    fontSize: 16,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Main Build Method ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // 1. APP BAR
          SliverAppBar(
            pinned: true, // Ghim AppBar khi cuộn
            backgroundColor: Colors.blue.shade800,
            foregroundColor: Colors.white,
            elevation: 2,
            title: const Text(
              'Điều khoản & Chính sách',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          // 2. NỘI DUNG
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Giới thiệu ---
                      _buildParagraph(
                        context,
                        'Cập nhật lần cuối: 01/11/2025',
                      ),
                      _buildParagraph(
                        context,
                        'Vui lòng đọc kỹ các Điều khoản Sử dụng ("Điều khoản") và Chính sách Bảo mật ("Chính sách") của chúng tôi trước khi sử dụng ứng dụng DocBooking ("Dịch vụ").',
                      ),
                      const Divider(height: 32),

                      // --- Mục I: Điều khoản Sử dụng ---
                      _buildSectionTitle(context, 'I. Điều khoản Sử dụng'),
                      _buildSubHeader(context, '1. Chấp nhận Điều khoản'),
                      _buildParagraph(
                        context,
                        'Bằng cách truy cập hoặc sử dụng Dịch vụ, bạn đồng ý bị ràng buộc bởi các Điều khoản này. Nếu bạn không đồng ý với bất kỳ phần nào của điều khoản, bạn không được phép truy cập Dịch vụ.',
                      ),
                      _buildSubHeader(context, '2. Đặt lịch khám'),
                      _buildParagraph(
                        context,
                        'Dịch vụ cho phép bạn đặt lịch hẹn với các nhà cung cấp dịch vụ y tế (bác sĩ, phòng khám). DocBooking không chịu trách nhiệm về chất lượng dịch vụ y tế được cung cấp. Chúng tôi chỉ là nền tảng kết nối.',
                      ),
                      _buildSubHeader(context, '3. Tài khoản Người dùng'),
                      _buildParagraph(
                        context,
                        'Bạn có trách nhiệm bảo mật thông tin tài khoản và mật khẩu của mình. Bạn phải thông báo ngay cho chúng tôi khi phát hiện bất kỳ hành vi sử dụng trái phép nào đối với tài khoản của bạn.',
                      ),

                      // --- Mục II: Chính sách Bảo mật ---
                      _buildSectionTitle(context, 'II. Chính sách Bảo mật'),
                      _buildParagraph(
                        context,
                        'DocBooking cam kết bảo vệ thông tin cá nhân và dữ liệu sức khỏe của bạn.',
                      ),
                      _buildSubHeader(context, '1. Thông tin chúng tôi thu thập'),
                      _buildParagraph(
                        context,
                        'Chúng tôi có thể thu thập các loại thông tin sau:',
                      ),
                      _buildListItem(
                        context,
                        'Thông tin định danh cá nhân (tên, email, số điện thoại, ngày sinh).',
                      ),
                      _buildListItem(
                        context,
                        'Thông tin sức khỏe (chỉ khi bạn chủ động cung cấp để đặt lịch, ví dụ: triệu chứng, lịch sử khám).',
                      ),
                      _buildListItem(
                        context,
                        'Thông tin kỹ thuật (loại thiết bị, địa chỉ IP, nhật ký sử dụng).',
                      ),
                      _buildSubHeader(context, '2. Cách chúng tôi sử dụng thông tin'),
                      _buildParagraph(
                        context,
                        'Thông tin của bạn được sử dụng để cung cấp và cải thiện Dịch vụ, xác nhận lịch hẹn, gửi thông báo quan trọng và hỗ trợ khách hàng.',
                      ),
                      _buildSubHeader(context, '3. Chia sẻ thông tin'),
                      _buildParagraph(
                        context,
                        'Chúng tôi KHÔNG chia sẻ thông tin sức khỏe cá nhân của bạn với bên thứ ba nào, ngoại trừ việc cung cấp thông tin đó cho bác sĩ hoặc phòng khám mà BẠN đã chọn để đặt lịch hẹn.',
                      ),

                      // --- Mục III: Miễn trừ Trách nhiệm ---
                      _buildSectionTitle(context, 'III. Miễn trừ Trách nhiệm'),
                      _buildParagraph(
                        context,
                        'Thông tin trên DocBooking chỉ mang tính chất tham khảo, không thay thế cho chẩn đoán hoặc tư vấn y tế chuyên nghiệp. Luôn tìm kiếm lời khuyên của bác sĩ có trình độ cho bất kỳ câu hỏi nào liên quan đến tình trạng sức khỏe của bạn.',
                      ),

                      // --- Liên hệ ---
                      const Divider(height: 32),
                      _buildSubHeader(context, 'Liên hệ'),
                      _buildParagraph(
                        context,
                        'Nếu bạn có bất kỳ câu hỏi nào về Điều khoản hoặc Chính sách này, vui lòng liên hệ với chúng tôi tại support@docbooking.vn.',
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
