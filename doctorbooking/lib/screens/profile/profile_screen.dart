import 'dart:io'; // MỚI: Cần thiết cho File
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // MỚI: Thư viện chọn ảnh
import 'update_profile_screen.dart';
import 'change_password_screen.dart';
import 'support_screen.dart';
import 'policy_screen.dart';
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
  String _authAvatarUrl = ''; // MỚI: Thêm trạng thái cho ảnh đại diện "gốc"
  int? _authRole;
  bool _isLoadingNavigate = false;

  // MỚI: Thêm state để lưu đường dẫn ảnh demo (chỉ lưu tạm ở UI)
  // CẬP NHẬT: Thêm 'static' để biến này tồn tại cho đến khi app bị tắt hẳn
  static String _tempAvatarPath = ''; // Sẽ chứa đường dẫn file cục bộ

  // MỚI: Khởi tạo image picker
  final ImagePicker _picker = ImagePicker();

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
        final name = (user.fullName.isNotEmpty)
            ? user.fullName
            : (user.email.isNotEmpty ? user.email : '');
        setState(() {
          _authName = name;
          _authEmail = user.email;
          _authRole = user.role;
          // CẬP NHẬT: Gán ảnh đại diện "gốc" (từ auth service)
          // Giả sử model User của bạn có trường `avatarUrl`
          
          // LỖI: Dòng "user.avatarUrl" gây lỗi vì class User (trong models/user.dart)
          // của bạn không có thuộc tính "avatarUrl".
          // _authAvatarUrl = user.avatarUrl ?? ''; // <--- DÒNG GÂY LỖI
          
          // SỬA TẠM: Gán rỗng để hết lỗi.
          // Để sửa đúng, hãy mở 'models/user.dart' và thêm 'String? avatarUrl'.
          _authAvatarUrl = ''; 
        });
      } else {
        setState(() {
          _authName = '';
          _authEmail = '';
          _authRole = null;
          _authAvatarUrl = ''; // CẬP NHẬT: Reset avatar
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _authName = '';
        _authEmail = '';
        _authRole = null;
        _authAvatarUrl = ''; // CẬP NHẬT: Reset avatar
      });
    }
  }

  // Điều hướng tới UpdateProfileScreen
  void _navigateToUpdateProfile() async {
    // ... (logic hàm này giữ nguyên)
    setState(() => _isLoadingNavigate = true);
    try {
      final User? user = await AuthService.instance.getUser();
      if (user == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Vui lòng đăng nhập để cập nhật thông tin.'),
          backgroundColor: Colors.orange,
        ));
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false);
        return;
      }
      final result = await Navigator.push<User?>(
        context,
        MaterialPageRoute(builder: (c) => UpdateProfileScreen(user: user)),
      );
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


  Future<void> _pickAndUpdateAvatar() async {
    // 1. Yêu cầu người dùng chọn ảnh
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery, // Lấy từ thư viện, có thể đổi sang .camera
      imageQuality: 80, // Nén ảnh
    );

    // Nếu người dùng không chọn ảnh, hủy
    if (pickedFile == null) return;

    setState(() {
      _tempAvatarPath = pickedFile.path;
    });


    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cập nhật thành công'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Hiển thị chỉ dựa trên dữ liệu lấy từ AuthService (không fallback về sample store)
    final displayName = _authName.isNotEmpty ? _authName : 'Người dùng';
    final displayEmail = _authEmail.isNotEmpty ? _authEmail : '';

    // Xây dựng danh sách features... (Giữ nguyên logic)
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
        onTap: () {
           Navigator.push(context, MaterialPageRoute(builder: (c) => const TermsAndPolicyScreen()));
        },
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
                _buildUserInfoHeader(
                  name: displayName,
                  email: displayEmail,
                  authAvatarUrl: _authAvatarUrl,
                  tempAvatarPath: _tempAvatarPath, // Biến static sẽ được đọc ở đây
                  onEditAvatar: _pickAndUpdateAvatar,
                ),
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

  // CẬP NHẬT: Widget này giờ nhận `authAvatarUrl` và `tempAvatarPath`
  Widget _buildUserInfoHeader({
    required String name,
    required String email,
    required String authAvatarUrl, // Ảnh "gốc"
    required String tempAvatarPath,
    required VoidCallback onEditAvatar,
  }) {
    final initials = _getInitials(name);

    // MỚI: Logic quyết định hiển thị ảnh nào
    ImageProvider? backgroundImage;
    if (tempAvatarPath.isNotEmpty) {
      backgroundImage = FileImage(File(tempAvatarPath));
    } else {
      final bool hasValidAuthAvatar = authAvatarUrl.isNotEmpty && (authAvatarUrl.startsWith('http') || authAvatarUrl.startsWith('https:'));
      if (hasValidAuthAvatar) {
        backgroundImage = NetworkImage(authAvatarUrl);
      } else {
        // CẬP NHẬT: Dùng ảnh rùa làm ảnh mẫu nếu không có gì
        backgroundImage = const NetworkImage('https://img.lovepik.com/free-png/20220101/lovepik-tortoise-png-image_401154498_wh860.png');
      }
    }
    // Ưu tiên 3: Nếu (backgroundImage == null), child (chữ cái) sẽ hiển thị

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.blue.shade800,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.blue.shade100, // Màu nền fallback
                backgroundImage: backgroundImage, // CẬP NHẬT: Dùng 1 imageProvider
                // Chỉ hiển thị chữ nếu không có ảnh nào (kể cả ảnh mẫu)
                child: (backgroundImage == null) 
                    ? Text(
                        initials.isNotEmpty ? initials : '?',
                        style: TextStyle(fontSize: 30, color: Colors.blue.shade800, fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
              // Nút Edit
              Material(
                color: Colors.white,
                shape: const CircleBorder(),
                elevation: 2,
                child: InkWell(
                  onTap: onEditAvatar, // MỚI: Gọi hàm chọn ảnh
                  customBorder: const CircleBorder(),
                  child: const Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Icon(Icons.edit, size: 18, color: Colors.blue),
                  ),
                ),
              )
            ],
          ),
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
    if (fullName.isEmpty || fullName == 'Người dùng') return '';
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  Widget _buildFeaturesList(List<_ProfileFeature> features) {
    // ... (Hàm này giữ nguyên)
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
    // ... (Hàm này giữ nguyên)
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

