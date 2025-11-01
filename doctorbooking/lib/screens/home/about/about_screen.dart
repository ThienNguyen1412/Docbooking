import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  // --- Helper Widgets (Đã thiết kế lại) ---

  // Widget tạo tiêu đề cho mỗi phần, sang trọng hơn
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 12.0, left: 8.0, right: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0D1F3C), // Màu xanh đậm
                ),
          ),
          const SizedBox(height: 6),
          // Thêm 1 dải màu nhấn
          Container(
            height: 3,
            width: 60,
            decoration: BoxDecoration(
              color: Colors.blue.shade700,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  // Widget tạo một mục liên hệ (giữ nguyên cấu trúc ListTile nhưng sẽ đặt trong Card)
  Widget _buildContactItem(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue.shade700, size: 28),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 14)),
      contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
    );
  }

  // Widget tạo một mục thống kê thành tựu (thiết kế lại đẹp hơn)
  Widget _buildStatItem(BuildContext context, String value, String label, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.blue.withOpacity(0.1),
            child: Icon(icon, size: 30, color: Colors.blue.shade800),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54, fontSize: 14, height: 1.3),
          ),
        ],
      ),
    );
  }

  // --- Main Build Method (Thiết kế lại) ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Sử dụng màu nền xám rất nhạt
      backgroundColor: Colors.grey[50],
      // Sử dụng CustomScrollView để có SliverAppBar
      body: CustomScrollView(
        slivers: [
          // 1. APP BAR VÀ ẢNH BÌA
          SliverAppBar(
            expandedHeight: 250.0, // Chiều cao khi mở rộng
            pinned: true, // Ghim AppBar khi cuộn
            floating: false,
            backgroundColor: Colors.blue.shade800,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Về DocBooking',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              centerTitle: false,
              titlePadding: const EdgeInsetsDirectional.only(start: 72.0, bottom: 16.0),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Ảnh bìa
                  Image.network(
                    'https://www.docosan.com/blog/wp-content/uploads/2025/07/tu-van-kham-benh-tu-xa-chi-phi-dia-chi-uy-tin-chuyen-nghiep-1.jpg',
                    fit: BoxFit.cover,
                    // Error builder phòng khi ảnh lỗi
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[200],
                      child: Icon(Icons.image_not_supported, color: Colors.grey[400], size: 50),
                    ),
                  ),
                  // Lớp phủ gradient để tiêu đề dễ đọc hơn
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.5),
                          Colors.transparent,
                          Colors.black.withOpacity(0.6),
                        ],
                        stops: const [0.0, 0.4, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. PHẦN NỘI DUNG
          SliverToBoxAdapter(
            child: Padding(
              // Padding chung cho tất cả nội dung
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // GIỚI THIỆU & SỨ MỆNH
                  _buildSectionTitle(context, 'Sứ Mệnh Của Chúng Tôi'),
                  Card(
                    elevation: 2,
                    shadowColor: Colors.grey.withOpacity(0.1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Text(
                            'DocBooking là nền tảng y tế thông minh, giúp bạn kết nối với các bác sĩ và cơ sở y tế hàng đầu một cách nhanh chóng, tiện lợi và minh bạch.',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  height: 1.5,
                                  color: Colors.grey.shade700,
                                  fontSize: 16,
                                ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Sứ mệnh của chúng tôi là mang đến trải nghiệm chăm sóc sức khỏe dễ dàng, hiệu quả và đáng tin cậy cho mọi người dân Việt Nam.',
                            style: TextStyle(
                              fontSize: 17,
                              height: 1.5,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // THÀNH TỰU NỔI BẬT
                  _buildSectionTitle(context, 'Thành Tựu Nổi Bật'),
                  Card(
                    elevation: 2,
                    shadowColor: Colors.grey.withOpacity(0.1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStatItem(context, '1M+', 'Người dùng\ntin cậy', Icons.people_alt_outlined),
                          _buildStatItem(context, '500+', 'Bác sĩ\nchuyên khoa', Icons.medical_services_outlined),
                          _buildStatItem(context, '100+', 'Bệnh viện\nđối tác', Icons.local_hospital_outlined),
                        ],
                      ),
                    ),
                  ),

                  // HÌNH ẢNH ĐỘI NGŨ
                  _buildSectionTitle(context, 'Đội Ngũ Của Chúng Tôi'),
                  Card(
                    elevation: 2,
                    shadowColor: Colors.grey.withOpacity(0.1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    clipBehavior: Clip.antiAlias, // Cắt ảnh theo bo góc của Card
                    child: Column(
                      children: [
                        Image.network(
                          'https://nld.mediacdn.vn/291774122806476800/2022/7/22/photo-1-16584766661161516646243.jpg',
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 200,
                            color: Colors.grey[200],
                            child: Icon(Icons.image_not_supported, color: Colors.grey[400], size: 50),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            'Với đội ngũ chuyên gia công nghệ và y tế đầy nhiệt huyết, chúng tôi luôn nỗ lực không ngừng để cải tiến sản phẩm, mang lại giá trị tốt nhất cho cộng đồng.',
                            style: const TextStyle(fontSize: 16, height: 1.5),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // THÔNG TIN LIÊN HỆ
                  _buildSectionTitle(context, 'Thông Tin Liên Hệ'),
                  Card(
                    elevation: 2,
                    shadowColor: Colors.grey.withOpacity(0.1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: [
                        _buildContactItem(
                          Icons.email_outlined,
                          'Email hỗ trợ',
                          'support@docbooking.vn',
                        ),
                        const Divider(height: 1, indent: 20, endIndent: 20),
                        _buildContactItem(
                          Icons.phone_outlined,
                          'Hotline 24/7',
                          '1900 1234',
                        ),
                        const Divider(height: 1, indent: 20, endIndent: 20),
                        _buildContactItem(
                          Icons.location_on_outlined,
                          'Trụ sở chính',
                          '123 Đường Sức Khỏe, Phường B, Quận A, TP. Hồ Chí Minh',
                        ),
                      ],
                    ),
                  ),

                  // --- Phần Phiên bản ---
                  const SizedBox(height: 40),
                  Center(
                    child: Text(
                      'Phiên bản ứng dụng 1.0.0',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
