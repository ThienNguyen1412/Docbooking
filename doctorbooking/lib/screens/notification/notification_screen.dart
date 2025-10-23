// File: screens/notification_screen.dart
import 'package:flutter/material.dart';
import '../../models/notification.dart';

// ----------------------------------------------------
// MÀN HÌNH CHI TIẾT THÔNG BÁO
// ----------------------------------------------------
class NotificationDetailScreen extends StatelessWidget {
  final AppNotification notification;
  
  const NotificationDetailScreen({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi Tiết Thông Báo'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
            ),
            const SizedBox(height: 10),
            Text(
              'Ngày: ${notification.date.day}/${notification.date.month}/${notification.date.year} | ${notification.date.hour}:${notification.date.minute}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const Divider(height: 30),
            Text(
              notification.body,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------
// MÀN HÌNH DANH SÁCH THÔNG BÁO
// ----------------------------------------------------
class NotificationScreen extends StatefulWidget {
  // Nhận danh sách thông báo và callback để đánh dấu đã đọc
  final List<AppNotification> notifications;
  final Function(String) markAsRead;

  const NotificationScreen({
    super.key,
    required this.notifications,
    required this.markAsRead,
  });

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {

  void _navigateToDetail(AppNotification notification) {
    // Đánh dấu đã đọc trước khi chuyển sang màn hình chi tiết
    if (!notification.isRead) {
      widget.markAsRead(notification.id);
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => NotificationDetailScreen(notification: notification),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.notifications.isEmpty) {
      return const Center(
        child: Text(
          'Không có thông báo mới.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }
    
    // Sắp xếp thông báo theo ngày mới nhất lên đầu
    final sortedNotifications = List<AppNotification>.from(widget.notifications)
      ..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, 
        title: const Text('Thông Báo'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: sortedNotifications.length,
        itemBuilder: (context, index) {
          final notification = sortedNotifications[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            elevation: notification.isRead ? 1 : 3, // Thông báo chưa đọc có độ nổi bật hơn
            child: ListTile(
              leading: Icon(
                notification.isRead ? Icons.notifications_none : Icons.notifications_active,
                color: notification.isRead ? Colors.grey : Colors.red, // Màu đỏ cho thông báo chưa đọc
              ),
              title: Text(
                notification.title,
                style: TextStyle(
                  fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                ),
              ),
              subtitle: Text(
                notification.body,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Text(
                '${notification.date.hour}:${notification.date.minute}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              onTap: () => _navigateToDetail(notification),
            ),
          );
        },
      ),
    );
  }
}