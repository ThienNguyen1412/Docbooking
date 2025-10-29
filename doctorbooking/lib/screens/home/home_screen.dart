import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/notification.dart';
import '../notification/notification_screen.dart';

// ✨ SỬA: dùng API model Doctors thay vì mẫu Doctor
import '../../models/doctors.dart'; // <-- đổi ở đây
import '../appointment/book_new_appointment_screen.dart';
import 'details_screen.dart'; // Import để có thể sử dụng BookingDetails
import 'lookup/lookup_results_screen.dart';
import 'guide/guide_screen.dart';
import 'vaccine/vaccine_booking_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// ✨ IMPORT AUTH SERVICE VÀ USER MODEL
import '../../services/auth.dart';
import '../../models/user.dart';

// Dữ liệu cho các mục trong lưới tính năng
class FeatureItem {
  final IconData icon;
  final String label;
  final String id;
  const FeatureItem({required this.icon, required this.label, required this.id});
}

class HomeScreen extends StatefulWidget {
  final List<AppNotification> notifications;
  final Function(String) markNotificationAsRead;
  // ✨ SỬA LỖI: Cập nhật lại chữ ký hàm để nhận API model Doctors
  final void Function(Doctors, BookingDetails) onBookAppointment;

  const HomeScreen({
    super.key,
    required this.notifications,
    required this.markNotificationAsRead,
    required this.onBookAppointment,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final PageController _pageController;
  Timer? _bannerTimer;
  int _currentPage = 0;

  // ✨ TRẠNG THÁI CHO USER NAME VÀ INITIALS
  String _userName = '';
  String _userInitials = '';

  final List<String> _bannerImages = [
    'https://cdn.phenikaamec.com/phenikaa-mec/image/5-14-2025/6d9f06a3-13cb-4b9a-97a8-84b7b51c9eff-image.webp',
    'https://dakhoa.hungyenweb.com/wp-content/uploads/2018/06/banner-phong-kham-da-khoa-2.jpg',
    'https://phusanthienan.com/wp-content/uploads/2024/12/1banner-web-Chinh-thuc-Hifu.jpg',
  ];

  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};

  final LatLng _hospitalLocation =
      const LatLng(10.774838, 106.667184); // Tọa độ BV 115

  @override
  void initState() {
    super.initState();

    _markers.add(
      Marker(
        markerId: const MarkerId('hospitalLocation'),
        position: _hospitalLocation,
        infoWindow: const InfoWindow(title: 'Bệnh viện Nhân dân 115'),
      ),
    );
    _pageController = PageController(initialPage: 0);
    _startBannerTimer();

    // ✨ TẢI TÊN NGƯỜI DÙNG TỪ TOKEN/SHARED PREFERENCES
    _loadUserFromAuth();
  }

  Future<void> _loadUserFromAuth() async {
    try {
      final User? user = await AuthService.instance.getUser();
      if (!mounted) return;
      if (user != null) {
        // Sử dụng fullName nếu có, fallback sang email hoặc id
        final name = (user.fullName.isNotEmpty) ? user.fullName : (user.email.isNotEmpty ? user.email : 'Người dùng');
        setState(() {
          _userName = name;
          _userInitials = _getInitials(name);
        });
      } else {
        // Chưa đăng nhập -> giữ mặc định rỗng hoặc "Khách"
        setState(() {
          _userName = '';
          _userInitials = '';
        });
      }
    } catch (e) {
      // Nếu parse lỗi, không crash UI, giữ mặc định
      if (!mounted) return;
      setState(() {
        _userName = '';
        _userInitials = '';
      });
    }
  }

  String _getInitials(String fullName) {
    if (fullName.trim().isEmpty) return '';
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    } else {
      final first = parts.first.substring(0, 1);
      final last = parts.last.substring(0, 1);
      return (first + last).toUpperCase();
    }
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _pageController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _startBannerTimer() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) return; // Kiểm tra nếu widget còn tồn tại
      if (_currentPage < _bannerImages.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeIn,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<FeatureItem> features = [
      const FeatureItem(id: 'book_appointment', icon: Icons.description_outlined, label: 'Đặt lịch\nkhám bệnh'),
      const FeatureItem(id: 'lookup_results', icon: Icons.find_in_page_outlined, label: 'Tra cứu kết quả\nkhám bệnh'),
      const FeatureItem(id: 'guide', icon: Icons.info_outline, label: 'Hướng dẫn\nđặt khám'),
      const FeatureItem(id: 'vaccine', icon: Icons.vaccines_outlined, label: 'Đặt lịch\ntiêm chủng'),
      const FeatureItem(id: 'payment', icon: Icons.credit_card_outlined, label: 'Thanh toán\nviện phí'),
      const FeatureItem(id: 'hotline', icon: Icons.phone_in_talk_outlined, label: 'Đặt khám\n1900-2115'),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: _buildHeaderContent(context),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                shadowColor: Colors.grey.withOpacity(0.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 8.0),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: features.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1.0,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemBuilder: (context, index) {
                      final feature = features[index];
                      return InkWell(
                        onTap: () {
                          if (feature.id == 'book_appointment') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookNewAppointmentScreen(
                                  onBookAppointment: widget.onBookAppointment,
                                ),
                              ),
                            );
                          } else if (feature.id == 'lookup_results') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LookupResultsScreen(),
                              ),
                            );
                          } else if (feature.id == 'guide') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const GuideScreen(),
                              ),
                            );
                          } else if (feature.id == 'vaccine') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const VaccineBookingScreen(),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Chức năng "${feature.label.replaceAll('\n', ' ')}" sắp ra mắt!')),
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: _buildFeatureItem(feature),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.only(left: 4.0),
                child: Text(
                  'ĐƯỢC TIN TƯỞNG HỢP TÁC VÀ ĐỒNG HÀNH',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _buildPartnershipBanner(),

              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.only(left: 4.0),
                child: Text(
                  'VỊ TRÍ BỆNH VIỆN',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildGoogleMap(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleMap() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 200,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _hospitalLocation,
            zoom: 16.0,
          ),
          markers: _markers,
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;
            if (mounted) {
              setState(() {
                _markers.add(
                  Marker(
                    markerId: const MarkerId('hospitalLocation'),
                    position: _hospitalLocation,
                    infoWindow: const InfoWindow(title: 'Bệnh viện Nhân dân 115'),
                  ),
                );
              });
            }
          },
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          scrollGesturesEnabled: false,
          zoomGesturesEnabled: false,
        ),
      ),
    );
  }

  Widget _buildHeaderContent(BuildContext context) {
    final unreadCount = widget.notifications.where((n) => !n.isRead).length;
    final displayedName = _userName.isNotEmpty ? _userName : 'Khách';
    String avatarUrl = 'https://img.lovepik.com/free-png/20220101/lovepik-tortoise-png-image_401154498_wh860.png';
    String getGreeting() {
      final hour = DateTime.now().hour;
      if (hour < 12) return 'Chào buổi sáng';
      if (hour < 18) return 'Chào buổi chiều';
      return 'Chào buổi tối';
    }

    return AppBar(
      backgroundColor: const Color(0xFF0D1F3C),
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 16,
      title: Row(
        children: [
          CircleAvatar(radius: 20, backgroundImage: NetworkImage(avatarUrl)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(getGreeting(), style: const TextStyle(fontSize: 12, color: Colors.white70)),
              Text(displayedName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          const Icon(Icons.keyboard_arrow_right, color: Colors.white70),
        ],
      ),
      actions: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.star_border_purple500_outlined, color: Colors.white)),
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(icon: const Icon(Icons.notifications_none, color: Colors.white), onPressed: () => _showNotificationBottomSheet(context)),
            if (unreadCount > 0)
              Positioned(
                top: 12,
                right: 12,
                child: Container(height: 8, width: 8, decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle)),
              ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Material(
      elevation: 2.0,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(30.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Tìm CSYT/bác sĩ/chuyên khoa/dịch vụ',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(FeatureItem item) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(item.icon, color: Colors.blue.shade700, size: 28),
        ),
        const SizedBox(height: 8),
        Text(item.label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, height: 1.2)),
      ],
    );
  }

  Widget _buildPartnershipBanner() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          SizedBox(
            height: 120,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _bannerImages.length,
              onPageChanged: (index) {
                if (mounted) setState(() => _currentPage = index);
              },
              itemBuilder: (context, index) {
                return Image.network(
                  _bannerImages[index],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(color: Colors.grey[300], child: const Center(child: Icon(Icons.image_not_supported, color: Colors.grey)));
                  },
                );
              },
            ),
          ),
          Positioned(
            bottom: 10.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_bannerImages.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  height: 8.0,
                  width: _currentPage == index ? 24.0 : 8.0,
                  decoration: BoxDecoration(color: _currentPage == index ? Colors.white : Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(12)),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  void _showNotificationBottomSheet(BuildContext context) {
    final sortedNotifications = List<AppNotification>.from(widget.notifications)..sort((a, b) => b.date.compareTo(a.date));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Thông Báo Của Bạn', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ]),
              const Divider(),
              Expanded(
                child: sortedNotifications.isEmpty
                    ? const Center(child: Text('Không có thông báo mới.', style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        itemCount: sortedNotifications.length,
                        itemBuilder: (context, index) {
                          final notification = sortedNotifications[index];
                          return ListTile(
                            leading: Icon(notification.isRead ? Icons.notifications_none : Icons.notifications_active, color: notification.isRead ? Colors.grey : Colors.red),
                            title: Text(notification.title, style: TextStyle(fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold)),
                            subtitle: Text('${notification.date.day}/${notification.date.month} | ${notification.body}', maxLines: 1, overflow: TextOverflow.ellipsis),
                            onTap: () {
                              widget.markNotificationAsRead(notification.id);
                              Navigator.pop(ctx);
                              Navigator.push(context, MaterialPageRoute(builder: (c) => NotificationDetailScreen(notification: notification)));
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}