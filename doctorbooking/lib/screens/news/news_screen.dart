// File: screens/news/news_screen.dart (ĐÃ CẬP NHẬT)

import 'package:flutter/material.dart';
import '../../models/news.dart'; // Import model tin tức
// 💥 Import màn hình chi tiết
import 'news_detail_screen.dart'; 

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final newsList = NewsArticle.getNews(); // Lấy danh sách tin tức mẫu

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, 
        title: const Text('Tin Tức Y Tế & Sức Khỏe'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      // Sử dụng ListView.builder để xây dựng danh sách hiệu quả
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: newsList.length,
        itemBuilder: (context, index) {
          return NewsCard(article: newsList[index]);
        },
      ),
    );
  }
}

// ------------------------------------------
// Widget NewsCard - Thẻ hiển thị một bài báo (ĐÃ CẬP NHẬT)
// ------------------------------------------
class NewsCard extends StatelessWidget {
  final NewsArticle article;

  const NewsCard({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    // GestureDetector để xử lý sự kiện khi người dùng nhấn vào thẻ tin tức
    return GestureDetector(
      onTap: () {
        // 💥 Điều hướng sang màn hình chi tiết khi nhấn vào thẻ
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (c) => NewsDetailScreen(article: article),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh bìa
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                article.imageUrl,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                // Thêm một placeholder nếu ảnh lỗi
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 150,
                  color: Colors.grey[200],
                  child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tiêu đề
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D47A1), // Màu xanh đậm
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Tóm tắt
                  Text(
                    article.summary,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),

                  // Ngày đăng
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        article.date,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}