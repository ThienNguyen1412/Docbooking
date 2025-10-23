// File: models/notification.dart

class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime date;
  final bool isRead;
  

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
    this.isRead = false,
  });

  // Tạo một bản sao với trạng thái đã đọc được cập nhật
  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? date,
    bool? isRead,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      date: date ?? this.date,
      isRead: isRead ?? this.isRead,
    );
  }

  // Dữ liệu mẫu (Sample data)
  static List<AppNotification> initialNotifications() {
    return [
      AppNotification(
        id: 'noti1',
        title: 'Chào mừng đến với hệ thống',
        body: 'Cảm ơn bạn đã tin dùng dịch vụ đặt lịch khám của chúng tôi. Chúc bạn một ngày tốt lành!',
        date: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
      ),
      AppNotification(
        id: 'noti2',
        title: 'Tin tức mới về sức khỏe',
        body: 'Vui lòng kiểm tra mục Tin tức để xem các bài viết mới nhất về phòng chống dịch bệnh.',
        date: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
      ),
    ];
  }
}