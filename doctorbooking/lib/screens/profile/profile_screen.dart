// File: lib/screens/profile/profile_screen.dart

import 'package:flutter/material.dart';
import 'update_profile_screen.dart'; 
import 'change_password_screen.dart';
import 'support_screen.dart';
import '../../data/user_profile_service.dart';

// ✨ CHUYỂN THÀNH STATEFULWIDGET
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ✨ TẠO HÀM ĐIỀU HƯỚNG VÀ CHỜ KẾT QUẢ
  void _navigateToUpdateProfile() async {
    // Chờ kết quả trả về từ màn hình UpdateProfileScreen
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (c) => const UpdateProfileScreen()),
    );

    // Nếu kết quả trả về là `true` (tức là đã lưu thành công)
    if (result == true && mounted) {
      // Gọi setState để build lại giao diện và hiển thị dữ liệu mới
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật thông tin thành công!'), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✨ LẤY DỮ LIỆU ĐỘNG TỪ KHO DỮ LIỆU
    final user = UserProfileService.instance;

    final List<_ProfileFeature> features = [
      _ProfileFeature(
        icon: Icons.person_outline,
        title: 'Cập nhật thông tin',
        // ✨ GỌI HÀM ĐIỀU HƯỚNG MỚI
        onTap: _navigateToUpdateProfile,
      ),
      _ProfileFeature(
        icon: Icons.lock_outline,
        title: 'Đổi mật khẩu',
        onTap: () {
           Navigator.push(context, MaterialPageRoute(builder: (c) => const ChangePasswordScreen()));
        },
      ),
      _ProfileFeature(
        icon: Icons.support_agent_outlined,
        title: 'Hỗ trợ & Trợ giúp',
        onTap: () {
           Navigator.push(context, MaterialPageRoute(builder: (c) => const SupportScreen()));
        },
      ),
       _ProfileFeature(
        icon: Icons.policy_outlined,
        title: 'Điều khoản & Chính sách',
        onTap: () {},
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Hồ Sơ Của Tôi'),
        backgroundColor: Colors.blue.shade800,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ✨ TRUYỀN DỮ LIỆU ĐỘNG VÀO HEADER
            _buildUserInfoHeader(
              name: user.name, 
              email: user.email, 
              avatarUrl: user.avatarUrl
            ),
            
            const SizedBox(height: 20),
            _buildFeaturesList(features),
            const SizedBox(height: 20),
            _buildLogoutButton(context),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ... (Các hàm _buildUserInfoHeader, _buildFeaturesList, _buildLogoutButton giữ nguyên)
  Widget _buildUserInfoHeader({required String name, required String email, required String avatarUrl}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.blue.shade800,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            backgroundImage: NetworkImage(avatarUrl),
             onBackgroundImageError: (e, s) { /* Xử lý lỗi tải ảnh */ },
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  email,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesList(List<_ProfileFeature> features) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: features.length,
          itemBuilder: (context, index) {
            final feature = features[index];
            return ListTile(
              leading: Icon(feature.icon, color: Colors.blue.shade700),
              title: Text(feature.title, style: const TextStyle(fontSize: 16)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              onTap: feature.onTap,
            );
          },
          separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
        ),
      ),
    );
  }
  
  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
         elevation: 2,
         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text(
            'Đăng xuất',
            style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          onTap: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Xác nhận Đăng xuất'),
                content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi tài khoản này?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Không'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                    },
                    child: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProfileFeature {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  _ProfileFeature({
    required this.icon,
    required this.title,
    required this.onTap,
  });
}