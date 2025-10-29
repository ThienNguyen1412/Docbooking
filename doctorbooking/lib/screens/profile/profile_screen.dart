import 'package:flutter/material.dart';
import 'update_profile_screen.dart';
import 'change_password_screen.dart';
import 'support_screen.dart';
import '../../services/auth.dart';
import '../../models/user.dart';
import '../admin/admin_home_screen.dart';

/// ProfileScreen - lấy dữ liệu người dùng từ AuthService (không dùng dữ liệu mẫu)
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Trạng thái chứa tên, email và role lấy từ Auth (token / SharedPreferences)
  String _authName = '';
  String _authEmail = '';
  int? _authRole;
  bool _isLoadingNavigate = false;

  @override
  void initState() {
    super.initState();
    _loadUserFromAuth();
  }

  Future<void> _loadUserFromAuth() async {
    try {
      final user = await AuthService.instance.getUser();
      if (!mounted) return;
      if (user != null) {
        // ưu tiên fullname nếu có, fallback sang email
        final name = (user.fullName.isNotEmpty) ? user.fullName : (user.email.isNotEmpty ? user.email : '');
        setState(() {
          _authName = name;
          _authEmail = user.email;
          _authRole = user.role;
        });
      } else {
        setState(() {
          _authName = '';
          _authEmail = '';
          _authRole = null;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _authName = '';
        _authEmail = '';
        _authRole = null;
      });
    }
  }

  // Điều hướng tới UpdateProfileScreen — LẤY NGƯỜI DÙNG TỪ AuthService và truyền vào màn hình
  void _navigateToUpdateProfile() async {
    setState(() => _isLoadingNavigate = true);
    try {
      // Lấy user từ AuthService
      final User? user = await AuthService.instance.getUser();

      if (user == null) {
        // Nếu không có user, yêu cầu đăng nhập
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Vui lòng đăng nhập để cập nhật thông tin.'),
          backgroundColor: Colors.orange,
        ));
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false);
        return;
      }

      // Push màn hình UpdateProfileScreen, truyền user vào
      final result = await Navigator.push<User?>(
        context,
        MaterialPageRoute(builder: (c) => UpdateProfileScreen(user: user)),
      );

      // Nếu màn hình trả về User (hoặc bất kỳ non-null) => load lại dữ liệu từ Auth (để cập nhật hiển thị)
      if (result != null && mounted) {
        await _loadUserFromAuth();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật thông tin thành công!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    } finally {
      if (mounted) setState(() => _isLoadingNavigate = false);
    }
  }

  // Điều hướng tới trang admin
  void _navigateToAdmin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (c) => const AdminHomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Hiển thị chỉ dựa trên dữ liệu lấy từ AuthService (không fallback về sample store)
    final displayName = _authName.isNotEmpty ? _authName : 'Người dùng';
    final displayEmail = _authEmail.isNotEmpty ? _authEmail : '';

    // Xây dựng danh sách features, thêm nút Admin NẾU role == 0
    final List<_ProfileFeature> features = [];

    if (_authRole == 0) {
      features.add(
        _ProfileFeature(
          icon: Icons.account_circle_outlined,
          title: 'Trang Admin',
          onTap: _navigateToAdmin,
        ),
      );
    }

    features.addAll([
      _ProfileFeature(
        icon: Icons.person_outline,
        title: 'Cập nhật thông tin',
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
    ]);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Hồ Sơ Của Tôi', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue.shade800,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                _buildUserInfoHeader(name: displayName, email: displayEmail),
                const SizedBox(height: 20),
                _buildFeaturesList(features),
                const SizedBox(height: 20),
                _buildLogoutButton(context),
                const SizedBox(height: 20),
              ],
            ),
          ),
          if (_isLoadingNavigate)
            Positioned.fill(
              child: Container(
                color: Colors.black38,
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUserInfoHeader({required String name, required String email}) {
    final initials = _getInitials(name);
    String avatarUrl = 'https://img.lovepik.com/free-png/20220101/lovepik-tortoise-png-image_401154498_wh860.png';
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.blue.shade800,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 40, backgroundImage: NetworkImage(avatarUrl)),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isNotEmpty ? name : 'Người dùng',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  email.isNotEmpty ? email : '',
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

  String _getInitials(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
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
                    onPressed: () async {
                      Navigator.of(ctx).pop();
                      await AuthService.instance.clearAuth();
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Bạn đã đăng xuất.'), backgroundColor: Colors.green),
                      );
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