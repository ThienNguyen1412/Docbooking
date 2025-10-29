// File: screens/service/service_screen.dart

import 'package:flutter/material.dart';
import '../../models/notification.dart'; 
import '../../models/health_package.dart'; 
import '../notification/notification_screen.dart'; 
import 'service_detail_screen.dart'; 
// ✨ 1. THÊM IMPORT NÀY ĐỂ CÓ THỂ SỬ DỤNG `BookingDetails`


class ServiceScreen extends StatelessWidget { 
  // ✨ 2. CẬP NHẬT "CHỮ KÝ" (SIGNATURE) CỦA HÀM TẠI ĐÂY

  final List<AppNotification> unreadNotifications; 
  final Function(String) markNotificationAsRead; 
  final Function(AppNotification) addNotification;
  

  // Dữ liệu gói khám
  final List<HealthPackage> packages = HealthPackage.getPackages(); 

  ServiceScreen({ 
    super.key,
    required this.unreadNotifications, 
    required this.markNotificationAsRead, 
    required this.addNotification,
  });

// --- Các hàm build UI (không thay đổi logic bên trong) ---

// 1. HEADER
Widget _buildWelcomeHeader(BuildContext context) {
  final unreadCount = unreadNotifications.where((n) => !n.isRead).length;
  String avatarUrl = 'https://img.lovepik.com/free-png/20220101/lovepik-tortoise-png-image_401154498_wh860.png';
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      const Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Các dịch vụ chăm sóc 👋', style: TextStyle(fontSize: 14, color: Colors.black54)),
            Text('Y tế tốt nhất', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0D47A1))),
          ],
        ),
      ),
      Row(
        children: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none, size: 30, color: Colors.blue),
                onPressed: () => _showNotificationBottomSheet(context), 
              ),
              if (unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                    constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                    child: Text('$unreadCount', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 25,
            backgroundImage: NetworkImage(avatarUrl)
          ),
        ],
      ),
    ],
  );
}

// 2. BOTTOM SHEET THÔNG BÁO
void _showNotificationBottomSheet(BuildContext context) {
  final sortedNotifications = List<AppNotification>.from(unreadNotifications)
    ..sort((a, b) => b.date.compareTo(a.date));

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext ctx) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Thông Báo Của Bạn', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const Divider(),
            Expanded(
              child: sortedNotifications.isEmpty 
                ? const Center(child: Text('Không có thông báo mới.', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: sortedNotifications.length,
                    itemBuilder: (context, index) {
                      final notification = sortedNotifications[index];
                      return ListTile(
                        leading: Icon(
                          notification.isRead ? Icons.notifications_none : Icons.notifications_active,
                          color: notification.isRead ? Colors.grey : Colors.red,
                        ),
                        title: Text(notification.title, style: TextStyle(fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold)),
                        subtitle: Text('${notification.date.day}/${notification.date.month} | ${notification.body}', maxLines: 2, overflow: TextOverflow.ellipsis),
                        onTap: () {
                          markNotificationAsRead(notification.id);
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

// 3. THANH TÌM KIẾM
Widget _buildSearchBar() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
    child: const TextField(
      decoration: InputDecoration(
        hintText: 'Tìm kiếm gói khám, dịch vụ...',
        border: InputBorder.none,
        prefixIcon: Icon(Icons.search, color: Colors.grey),
      ),
    ),
  );
}

// --- Card hiển thị thông tin gói khám ---
Widget _buildPackageCard(BuildContext context, HealthPackage pkg, {required Color cardColor, required Color borderColor, required Color titleColor, required bool showDiscountTag}) {
  final String priceText = pkg.formattedPrice;
  final String? oldPriceText = pkg.formattedOldPrice;

  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (c) => ServiceDetailScreen(
            healthPackage: pkg,
            addNotification: addNotification,
          ),
        ),
      );
    },
    child: Container(
      width: 280, 
      margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: borderColor),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 3, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (pkg.image != null) 
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  pkg.image!, 
                  height: 80,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(height: 80, color: Colors.grey[200], child: const Center(child: Text('Lỗi tải ảnh'))),
                ),
              ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(pkg.name, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: titleColor), overflow: TextOverflow.ellipsis)),
                if (showDiscountTag) 
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(8)),
                      child: const Text('ƯU ĐÃI', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 5),
            Text(pkg.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, color: Colors.black54)),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (pkg.isDiscount && oldPriceText != null)
                      Text(oldPriceText, style: const TextStyle(fontSize: 13, color: Colors.grey, decoration: TextDecoration.lineThrough)),
                    Text(priceText, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: pkg.isDiscount ? Colors.red.shade700 : Colors.green.shade700)),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (c) => ServiceDetailScreen(
                          healthPackage: pkg,
                          addNotification: addNotification,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Xem chi tiết'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

// 1. GÓI KHÁM ĐANG ƯU ĐÃI
Widget _buildDiscountPackages(BuildContext context) {
  final discountPackages = packages.where((p) => p.isDiscount).toList();
  if (discountPackages.isEmpty) return const SizedBox.shrink(); 

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Ưu đãi đặc biệt hôm nay 🔥', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
          TextButton(onPressed: () {}, child: const Text('Xem tất cả')),
        ],
      ),
      const SizedBox(height: 15),
      SizedBox(
        height: 250, 
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: discountPackages.length,
          itemBuilder: (context, index) {
            return _buildPackageCard(context, discountPackages[index], cardColor: Colors.orange[50]!, borderColor: Colors.orange.shade200, titleColor: Colors.red.shade800, showDiscountTag: true);
          },
        ),
      ),
      const SizedBox(height: 25),
    ],
  );
}

// 2. GÓI KHÁM ĐẶC BIỆT NỔI BẬT
Widget _buildFeaturedPackages(BuildContext context) {
  final featuredPackages = packages.where((p) => !p.isDiscount && p.isFeatured).toList();
  if (featuredPackages.isEmpty) return const SizedBox.shrink();

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Gói Khám Đặc Biệt Nổi Bật ✨', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.purple)),
      const SizedBox(height: 15),
      SizedBox(
        height: 250, 
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: featuredPackages.length,
          itemBuilder: (context, index) {
            return _buildPackageCard(context, featuredPackages[index], cardColor: Colors.purple[50]!, borderColor: Colors.purple.shade200, titleColor: Colors.purple.shade800, showDiscountTag: false);
          },
        ),
      ),
      const SizedBox(height: 25),
    ],
  );
}

// 3. GÓI KHÁM TIÊU CHUẨN
Widget _buildStandardPackages(BuildContext context) {
  final standardPackages = packages.where((p) => !p.isDiscount && !p.isFeatured).toList();
  if (standardPackages.isEmpty) return const SizedBox.shrink();

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Các Gói Khám Sức Khỏe Tiêu Chuẩn', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      const SizedBox(height: 15),
      ListView.builder(
        shrinkWrap: true, 
        physics: const NeverScrollableScrollPhysics(), 
        itemCount: standardPackages.length,
        itemBuilder: (context, index) {
          final pkg = standardPackages[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: const Icon(Icons.medical_services_outlined, size: 30, color: Colors.blue),
                title: Text(pkg.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${pkg.description}\nGiá: ${pkg.formattedPrice}', maxLines: 2, overflow: TextOverflow.ellipsis),
                trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.blue),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (c) => ServiceDetailScreen(
                        healthPackage: pkg,

                        addNotification: addNotification,
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
      const SizedBox(height: 30),
    ],
  );
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: false,
      title: const Text('Dịch Vụ & Gói Khám'),
      backgroundColor: Colors.white,
      foregroundColor: Colors.blue.shade800,
      elevation: 1,
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeHeader(context), 
          const SizedBox(height: 20),
          _buildSearchBar(),
          const SizedBox(height: 30),
          _buildDiscountPackages(context),
          _buildFeaturedPackages(context),
          _buildStandardPackages(context),
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(10)),
            child: const Text(
              'Sử dụng tab "Trang Chủ" để tìm kiếm và đặt lịch bác sĩ',
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    ),
  );
}
}