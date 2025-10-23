// File: models/doctor.dart (CẬP NHẬT ĐẦY ĐỦ)

import 'package:flutter/material.dart';

/// Lớp Doctor lưu trữ thông tin cho từng bác sĩ
class Doctor {
  final String id; // 💥 THÊM TRƯỜNG ID
  final String name;  // Tên bác sĩ
  final String specialty; // Chuyên khoa
  final String image; // Link ảnh
  final String hospital;  // Bệnh viện làm việc
  final String phone; // Số điện thoại
  final double rating;  // Điểm đánh giá trung bình
  final int reviews; // Số lượng đánh giá
  final Color color;  // Màu nền đại diện
  final List<String> comments; // Danh sách bình luận của bệnh nhân

  Doctor({
    required this.id, // 💥 YÊU CẦU ID
    required this.name,
    required this.specialty,
    required this.image,
    required this.hospital,
    required this.phone,
    required this.rating,
    required this.reviews,
    required this.color,
    required this.comments,
  });

  /// Hàm static trả về danh sách bác sĩ mẫu
  static List<Doctor> getDoctors() {
    return [
      Doctor(
        id: 'd1', // 💥 Thêm ID
        name: 'BS.CKI Nguyễn Công Bình',
        specialty: 'Tim mạch',
        hospital: 'Bệnh viện Nhân dân 115',
        phone: '0901 234 567',
        rating: 4.8,
        reviews: 120,
        image:
            'https://benhviennoitiet.vn/wp-content/uploads/2024/01/Mask-group7-min-2.png',
        color: Colors.redAccent,
        comments: [
          'Bác sĩ rất tận tâm, tư vấn kỹ càng.',
          'Khám nhanh, không phải chờ lâu.',
          'Rất hài lòng với dịch vụ.'
        ],
      ),
      Doctor(
        id: 'd2', // 💥 Thêm ID
        name: 'TS.BS Trần Thị Đoàn',
        specialty: 'Cơ xương khớp',
        hospital: 'Bệnh viện Nhân dân 115',
        phone: '0908 765 432',
        rating: 4.6,
        reviews: 98,
        image:
            'https://benhviennoitiet.vn/wp-content/uploads/2024/01/Mask-group6-min-1.png',
        color: Colors.blueAccent,
        comments: [
          'Bác sĩ thân thiện và chuyên nghiệp.',
          'Giải thích rất dễ hiểu cho bệnh nhân.',
        ],
      ),
      Doctor(
        id: 'd3', // 💥 Thêm ID
        name: 'TS.BS Nguyễn Đăng Quân',
        specialty: 'Hô hấp',
        hospital: 'Bệnh viện Nhân dân 115',
        phone: '0912 111 222',
        rating: 4.9,
        reviews: 150,
        image:
            'https://benhviennoitiet.vn/wp-content/uploads/2023/12/Doi-ngu-chuyen-gia-Tam-1.jpg',
        color: Colors.green,
        comments: [
          'Kinh nghiệm dày dặn, chuẩn đoán chính xác.',
          'Luôn quan tâm đến bệnh nhân.',
          'Rất tin tưởng bác sĩ Quân.'
        ],
      ),
      Doctor(
        id: 'd4', // 💥 Thêm ID
        name: 'BS.CKI. Nguyễn Hải Anh',
        specialty: 'Tim mạch',
        hospital: 'Bệnh viện Nhân dân 115',
        phone: '0933 888 999',
        rating: 4.7,
        reviews: 87,
        image:
            'https://lh6.googleusercontent.com/proxy/w45AMWsqEmaDOECh16nRP6cwMyaPN-GJ5ukBCaAlELTraVInxzjRce88mSbbJoLl1hF6lcfSAhv8VFMpzyRXuEgkGIWdGyxxZqc2JFGNRw19QYZLzRaXGmHCINSdjO_BZZo',
        color: Colors.orange,
        comments: [
          'Rất giỏi và chuyên nghiệp.',
          'Thái độ nhẹ nhàng, dễ chịu.',
        ],
      ),
      Doctor(
        id: 'd5', // 💥 Thêm ID
        name: 'PGS.TS Trần Ngọc Lương',
        specialty: 'Thần kinh',
        hospital: 'Bệnh viện Nhân dân 115',
        phone: '0987 654 321',
        rating: 4.5,
        reviews: 110,
        image:
            'https://benhviennoitiet.vn/wp-content/uploads/2023/12/cg1.jpg',
        color: Colors.purple,
        comments: [
          'Bác sĩ rất tận tâm.',
          'Khám bệnh kỹ lưỡng.',
        ],
      ),
      Doctor(
        id: 'd6', // 💥 Thêm ID
        name: 'BS.CKI Phan Hoàng Hiệp',
        specialty: 'Mắt',
        hospital: 'Bệnh viện Nhân dân 115',
        phone: '0971 222 333',
        rating: 4.4,
        reviews: 75,
        image:
            'https://benhviennoitiet.vn/wp-content/uploads/2023/12/A-Hiep-web.jpg',
        color: Colors.pinkAccent,
        comments: [
          'Bác sĩ nhẹ nhàng với trẻ em.',
          'Tư vấn rất chi tiết.',
        ],
      ),
      Doctor(
        id: 'd7', // 💥 Thêm ID
        name: 'TS.BS Phan Hướng Dương',
        specialty: 'Hô hấp',
        hospital: 'Bệnh viện Nhân dân 115',
        phone: '0912 333 444',
        rating: 4.7,
        reviews: 95,
        image:
            'https://benhviennoitiet.vn/wp-content/uploads/2023/12/cg3.jpg',
        color: Colors.teal,
        comments: [
          'Chuyên môn cao.',
          'Rất hài lòng với bác sĩ.',
        ],
      ),
      Doctor(
        id: 'd8', // 💥 Thêm ID
        name: 'BS.CKI Phạm Thúy Hường',
        specialty: 'Sản phụ khoa',
        hospital: 'Bệnh viện Nhân dân 115',
        phone: '0934 555 666',
        rating: 4.3,
        reviews: 60,
        image:
            'https://benhviennoitiet.vn/wp-content/uploads/2023/12/cg4.jpg',
        color: Colors.brown,
        comments: [
          'Khám đúng quy chuẩn.',
          'Bác sĩ tư vấn tận tình.',
        ],
      ),
      Doctor(
        id: 'd9', // 💥 Thêm ID
        name: 'BS.CKII Phạm Thị Thúy',
        specialty: 'Tai Mũi Họng',
        hospital: 'Bệnh viện Nhân dân 115',
        phone: '0934 555 666',
        rating: 4.3,
        reviews: 60,
        image:
            'https://benhviennoitiet.vn/wp-content/uploads/2023/12/cg5.jpg',
        color: Colors.brown,
        comments: [
          'Khám đúng quy chuẩn.',
          'Bác sĩ tư vấn tận tình.',
        ],
      ),
       Doctor(
        id: 'd10', // 💥 Thêm ID
        name: 'ThS.BS Lương Quỳnh Hoa',
        specialty: 'Nội tiết',
        hospital: 'Bệnh viện Nhân dân 115',
        phone: '0912 333 444',
        rating: 4.7,
        reviews: 95,
        image:
            'https://benhviennoitiet.vn/wp-content/uploads/2023/12/cg6.jpg',
        color: Colors.teal,
        comments: [
          'Chuyên môn cao.',
          'Rất hài lòng với bác sĩ.',
        ],
      ),
      Doctor(
        id: 'd11',
        name: 'BS.CKII Phạm Bá Tuân',
        specialty: 'Tim mạch',
        hospital: 'Bệnh viện Nhân dân 115',
        phone: '0901 222 555',
        rating: 4.9,
        reviews: 150,
        image:
            'https://benhviennoitiet.vn/wp-content/uploads/2024/01/Mask-group4-min.png', // Thay bằng URL ảnh thực tế
        color: Colors.red,
        comments: [
        'Bác sĩ Khôi rất kinh nghiệm và nhiệt tình.',
        'Khám kỹ lưỡng, tư vấn phác đồ điều trị hiệu quả.',
        'Thời gian chờ hơi lâu nhưng rất đáng giá.',
    ],
),

      // 3. BS. Nguyễn Thị Thu Sương
      Doctor(
          id: 'd12',
          name: 'BS.CKI Lương Quốc Hải',
          specialty: 'Sản phụ khoa',
          hospital: 'Bệnh viện Nhân dân 115',
          phone: '0987 654 321',
          rating: 4.8,
          reviews: 210,
          image:
              'https://benhviennoitiet.vn/wp-content/uploads/2025/02/Hai.jpg', // Thay bằng URL ảnh thực tế
          color: Colors.pink,
          comments: [
            'Cô Sương rất nhẹ nhàng và chu đáo.',
            'Địa chỉ tin cậy cho khám thai và phụ khoa.',
            'Phòng khám sạch sẽ, nhân viên thân thiện.',
          ],
      ),

      // 4. BS. Lê Văn Tấn
      Doctor(
          id: 'd13',
          name: 'TS.BS Trần Đoàn Kết',
          specialty: 'Cơ xương khớp',
          hospital: 'Bệnh viện Nhân dân 115',
          phone: '0918 765 432',
          rating: 4.6,
          reviews: 88,
          image:
              'https://benhviennoitiet.vn/wp-content/uploads/2024/01/Mask-group9-min-1.png', // Thay bằng URL ảnh thực tế
          color: Colors.blue,
          comments: [
            'Chẩn đoán chính xác, phương pháp điều trị tiên tiến.',
            'Giúp tôi giảm đau đáng kể chỉ sau 2 lần khám.',
          ],
      ),
      // 11. BS. Lê Hoàng Nam (Nhi Khoa)
Doctor(
    id: 'd20',
    name: 'ThS.BS Vũ Tuấn Thăng',
    specialty: 'Nhi Khoa',
    hospital: 'Bệnh viện Nhân dân 115',
    phone: '0905 123 789',
    rating: 4.7,
    reviews: 160,
    image:
        'https://benhviennoitiet.vn/wp-content/uploads/2023/12/ThS.BS-Vu-Tuan-Thang.png', // Thay bằng URL ảnh thực tế
    color: Colors.lightBlue,
    comments: [
      'Bác sĩ Nam rất chuyên nghiệp, xử lý các ca bệnh khó ở trẻ em tốt.',
      'Con tôi rất hợp với cách thăm khám của bác sĩ.',
      'Tư vấn chế độ dinh dưỡng và tiêm chủng chi tiết.',
    ],
),

// 12. BS. Nguyễn Minh Thư (Da Liễu)
Doctor(
    id: 'd21',
    name: 'ThS.BS Phạm Thị Lan',
    specialty: 'Da Liễu',
    hospital: 'Bệnh viện Nhân dân 115',
    phone: '0988 777 666',
    rating: 4.9,
    reviews: 205,
    image:
        'https://benhviennoitiet.vn/wp-content/uploads/2023/12/Mask-group7-min.png', // Thay bằng URL ảnh thực tế
    color: Colors.amber,
    comments: [
      'Điều trị dứt điểm mụn trứng cá và thâm sau sinh.',
      'Sử dụng các công nghệ làm đẹp da hiện đại.',
      'Giá hơi cao nhưng chất lượng dịch vụ rất tốt.',
    ],
),

// 13. BS. Trần Thanh Xuân (Nhi Khoa - Hô Hấp)
Doctor(
    id: 'd22',
    name: 'BS.CKII Nguyễn Thị Thu Hương',
    specialty: 'Nhi khoa',
    hospital: 'Bệnh viện Nhân dân 115',
    phone: '0913 555 000',
    rating: 4.8,
    reviews: 98,
    image:
        'https://benhviennoitiet.vn/wp-content/uploads/2023/12/Mask-group6-min.png', // Thay bằng URL ảnh thực tế
    color: Colors.cyan,
    comments: [
      'Chuyên gia về các bệnh hô hấp ở trẻ nhỏ.',
      'Rất cẩn thận, không kê đơn kháng sinh bừa bãi.',
    ],
),

// 14. BS. Phan Văn Hùng (Da Liễu - Thẩm Mỹ)
Doctor(
    id: 'd23',
    name: 'TS.BS Vũ Hiền Trinh',
    specialty: 'Da Liễu',
    hospital: 'Bệnh viện Nhân dân 115',
    phone: '0907 444 333',
    rating: 4.6,
    reviews: 135,
    image:
        'https://benhviennoitiet.vn/wp-content/uploads/2023/12/Mask-group3-min.png', // Thay bằng URL ảnh thực tế
    color: Colors.lime,
    comments: [
      'Tư vấn nhiệt tình về các vấn đề lão hóa da.',
      'Tay nghề tiêm filler và botox rất tự nhiên.',
    ],
),

// 15. BS. Đào Thị Kim Chi (Nhi Khoa - Dinh Dưỡng)
Doctor(
    id: 'd24',
    name: 'BS.CKII Trần Văn Đồng',
    specialty: 'Nhi khoa',
    hospital: 'Bệnh viện Nhân dân 115',
    phone: '0906 888 999',
    rating: 5.0,
    reviews: 250,
    image:
        'https://benhviennoitiet.vn/wp-content/uploads/2023/12/Mask-group2-min.png', // Thay bằng URL ảnh thực tế
    color: Colors.pinkAccent,
    comments: [
      'Rất giỏi về dinh dưỡng và chăm sóc trẻ sơ sinh.',
      'Mẹ bỉm sữa rất tin tưởng và giới thiệu cho nhau.',
      'Thăm khám nhanh chóng và hiệu quả.',
    ],
),

    // 8. BS. Võ Trọng Nghĩa
    Doctor(
        id: 'd17',
        name: 'BS.CKII Trần Tuấn Anh',
        specialty: 'Thần kinh',
        hospital: 'Bệnh viện Nhân dân 115',
        phone: '0919 876 543',
        rating: 4.8,
        reviews: 112,
        image:
            'https://benhviennoitiet.vn/wp-content/uploads/2023/12/Mask-group12-min.png', // Thay bằng URL ảnh thực tế
        color: Colors.brown,
        comments: [
          'Bác sĩ có chuyên môn sâu và rất nhân hậu.',
          'Luôn động viên và cho lời khuyên hữu ích cho bệnh nhân.',
          'Quy trình khám và điều trị được tối ưu.',
        ],
    ),

    // 9. BS. Trần Hải Đăng
    Doctor(
        id: 'd18',
        name: 'BS.CKII Nguyễn Minh Tuấn',
        specialty: 'Mắt',
        hospital: 'Bệnh viện Nhân dân 115',
        phone: '0902 345 678',
        rating: 4.6,
        reviews: 79,
        image:
            'https://benhviennoitiet.vn/wp-content/uploads/2023/12/Mask-group9-min.png', // Thay bằng URL ảnh thực tế
        color: Colors.green,
        comments: [
          'Phẫu thuật thành công, phục hồi nhanh chóng.',
          'Rất cẩn thận và trách nhiệm trong công việc.',
        ],
    ),
    ];
  }
}