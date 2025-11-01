import 'package:flutter/material.dart';
import '../../../models/health_package.dart';
import '../../../models/notification.dart';
// Đảm bảo đường dẫn này đúng
import '../../service/service_detail_screen.dart';

class HomeHealthcareScreen extends StatelessWidget {
  // Hai callback này vẫn cần thiết để truyền cho màn hình tiếp theo
  final VoidCallback onBookingCompleteGoToAppointments;
  final Function(AppNotification) addNotification;

  const HomeHealthcareScreen({
    Key? key,
    required this.onBookingCompleteGoToAppointments,
    required this.addNotification,
  }) : super(key: key);

  // === HÀM ĐIỀU HƯỚNG (GIỮ NGUYÊN) ===
  // Nút "Đặt lịch" sẽ gọi hàm này
  void _navigateToDetail(BuildContext context) {
    final HealthPackage homeCarePackage = HealthPackage(
      id: 'pk003',
      name: 'Kiểm tra sức khỏe tại nhà',
      description: 'Hướng dẫn điều trị cho gia đình chăm sóc người bệnh tại nhà.',
      price: 1090000,
      image: 'https://benhviendakhoatinhphutho.vn/wp-content/uploads/2022/07/77c24dc12186e3d8ba97.jpg.webp',
      steps: [
        'Chăm sóc và thay băng vết thương, thay ống nuôi ăn, thay ống thông tiểu',
        'Đặt đường truyền tĩnh mạch',
        'Vật lý trị liệu và phục hồi chức năng',
        'Lấy mẫu xét nghiệm',
        'Điều dưỡng chăm sóc sau khi xuất viện'
      ],
    );

    // Điều hướng đến ServiceDetailScreen với gói pk003
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => ServiceDetailScreen(
          healthPackage: homeCarePackage,
          addNotification: addNotification,
          onBookingCompleteGoToAppointments: onBookingCompleteGoToAppointments,
        ),
      ),
    );
  }

  // === GIAO DIỆN MỚI ===
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. NÚT ĐẶT LỊCH (Floating Action Button)
      // Thiết kế này khác biệt: nút sẽ nổi trên màn hình
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToDetail(context),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.calendar_today_outlined),
        label: const Text(
          'ĐẶT GÓI KIỂM TRA TẠI NHÀ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      // 2. NỘI DUNG (Sử dụng CustomScrollView)
      // Cho phép thanh AppBar co dãn khi cuộn
      body: CustomScrollView(
        slivers: [
          // 2.1. Thanh AppBar co dãn với hình ảnh
          SliverAppBar(
            expandedHeight: 250.0, // Chiều cao của hình ảnh
            pinned: true, // Giữ lại AppBar khi cuộn
            backgroundColor: Colors.blue.shade800,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Chăm Sóc Tại Nhà',
                style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    'https://xetnghiemykhoa.vn/wp-content/uploads/2020/06/bn-cham-soc-suc-khoe-tai-nha.jpg',
                    fit: BoxFit.cover,
                  ),
                  // Lớp phủ mờ để tên trang nổi bật
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                        stops: const [0.5, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2.2. Phần nội dung chi tiết
          SliverList(
            delegate: SliverChildListDelegate(
              [
                // === PHẦN GIỚI THIỆU ===
                _buildSection(
                  context,
                  title: 'Giới thiệu dịch vụ',
                  child: Text(
                    'Dịch vụ Chăm sóc sức khỏe tại nhà mang đến giải pháp y tế toàn diện, tiện lợi và chuyên nghiệp ngay tại ngôi nhà của bạn. Đội ngũ y bác sĩ và điều dưỡng giàu kinh nghiệm của chúng tôi sẽ trực tiếp đến tận nơi để thăm khám, thực hiện các thủ thuật và theo dõi sức khỏe, đảm bảo sự an tâm tuyệt đối cho bệnh nhân và gia đình.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade800,
                      height: 1.5,
                    ),
                  ),
                ),

                // === PHẦN LỢI ÍCH ===
                _buildSection(
                  context,
                  title: 'Lợi ích nổi bật',
                  child: Column(
                    children: [
                      _buildBenefitItem(
                        Icons.home_work_outlined,
                        'Tiện lợi tối đa',
                        'Không cần di chuyển, không mất thời gian chờ đợi. Bác sĩ đến tận nhà bạn.',
                      ),
                      _buildBenefitItem(
                        Icons.verified_user_outlined,
                        'Chuyên môn cao',
                        'Đội ngũ y bác sĩ và điều dưỡng chuyên nghiệp, đúng chuyên khoa.',
                      ),
                      _buildBenefitItem(
                        Icons.family_restroom_outlined,
                        'An tâm cho gia đình',
                        'Người thân được chăm sóc trong môi trường quen thuộc, thoải mái nhất.',
                      ),
                    ],
                  ),
                ),

                // === PHẦN CÁC BƯỚC KHÁM (Lấy từ pk003) ===
                _buildSection(
                  context,
                  title: 'Cách thức & Quy trình',
                  child: Card(
                    elevation: 0,
                    color: Colors.blue.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Colors.blue.shade100),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildStepItem(Icons.check_circle_outline, 'Chăm sóc và thay băng vết thương, thay ống nuôi ăn, thay ống thông tiểu'),
                          _buildStepItem(Icons.check_circle_outline, 'Đặt đường truyền tĩnh mạch'),
                          _buildStepItem(Icons.check_circle_outline, 'Vật lý trị liệu và phục hồi chức năng'),
                          _buildStepItem(Icons.check_circle_outline, 'Lấy mẫu xét nghiệm'),
                          _buildStepItem(Icons.check_circle_outline, 'Điều dưỡng chăm sóc sau khi xuất viện'),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Đệm một khoảng trống để nội dung không bị che bởi nút FAB
                const SizedBox(height: 100), 
              ],
            ),
          ),
        ],
      ),
    );
  }

  // === CÁC WIDGET HỖ TRỢ ===

  // Widget chung để tạo một khối nội dung (Giới thiệu, Lợi ích,...)
  Widget _buildSection(BuildContext context, {required String title, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade900,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  // Widget để hiển thị các Lợi ích
  Widget _buildBenefitItem(IconData icon, String title, String subtitle) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, size: 30, color: Colors.blue.shade700),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 15)),
    );
  }

  // Widget để hiển thị các Bước/Quy trình
  Widget _buildStepItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.green.shade700, size: 22),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16, height: 1.4))),
        ],
      ),
    );
  }
}