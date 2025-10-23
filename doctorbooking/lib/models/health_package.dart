// File: models/health_package.dart (Giả định)

class HealthPackage {
  final String id;
  final String name;
  final String description;
  final int price;
  final int? oldPrice; 
  final bool isDiscount; 
  // 💥 Thêm cờ mới để đánh dấu gói tiêu chuẩn nổi bật (Premium/Featured)
  final bool isFeatured; 
  final String? image; 
  final List<String> steps;

  const HealthPackage({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.oldPrice, 
    this.isDiscount = false, 
    this.isFeatured = false, // 💥 Khởi tạo giá trị mặc định
    this.image,
    required this.steps, 
  });

  // 💥 THAY THẾ HÀM ĐỊNH DẠNG GIÁ THỦ CÔNG
  // Hàm tiện ích định dạng giá tiền (ví dụ: 5000000 -> 5.000.000 VNĐ)
  String _formatPriceManual(int amount) {
    String priceStr = amount.toString();
    String result = '';
    int counter = 0;
    for (int i = priceStr.length - 1; i >= 0; i--) {
      result = priceStr[i] + result;
      counter++;
      if (counter % 3 == 0 && i != 0) {
        result = '.' + result;
      }
    }
    return result + ' VNĐ';
  }

  // Getter để hiển thị giá hiện tại đã định dạng
  String get formattedPrice => _formatPriceManual(price);

  // Getter để hiển thị giá cũ đã định dạng
  String? get formattedOldPrice => oldPrice != null ? _formatPriceManual(oldPrice!) : null;


  HealthPackage copyWith({
    String? id,
    String? name,
    String? description,
    int? price,
    int? oldPrice,
    bool? isDiscount,
    bool? isFeatured, // Cập nhật copyWith
    String? image,
    List<String>? steps, 
  }) {
    return HealthPackage(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      oldPrice: oldPrice ?? this.oldPrice,
      isDiscount: isDiscount ?? this.isDiscount,
      isFeatured: isFeatured ?? this.isFeatured, // Cập nhật copyWith
      image: image ?? this.image,
      steps: steps ?? this.steps, 
    );
  }

  // Phương thức tĩnh cung cấp dữ liệu giả định (ĐÃ CẬP NHẬT)
  static List<HealthPackage> getPackages() {
    return const [
      // 1. GÓI KHÁM CÓ ƯU ĐÃI (isDiscount = true)
      HealthPackage(
        id: 'pk001',
        name: 'Gói Chăm Sóc Gia Đình',
        description: 'Kiểm tra tổng quát cho 4 thành viên trong gia đình.',
        price: 3990000,
        oldPrice: 5000000,
        isDiscount: true,
        image: 'https://nld.mediacdn.vn/k:2016/hoanmy-1466943086757/goi-cham-soc-suc-khoe-gia-dinh-cua-hoan-my.jpg',
        steps: [
          'Tư vấn và khám lâm sàng 4 thành viên (Người lớn & Trẻ em)',
          'Xét nghiệm máu tổng quát cho Người lớn',
          'Siêu âm bụng tổng quát',
          'Tư vấn dinh dưỡng và sức khỏe cho cả gia đình',
          'Kiểm tra sức khỏe mắt và răng miệng cơ bản',
          'Hỗ trợ đặt lịch khám định kỳ trong 1 năm'
        ],
      ),
      HealthPackage(
        id: 'pk002',
        name: 'Sàng Lọc Ung Thư Toàn Diện',
        description: 'Bao gồm các xét nghiệm chuyên sâu và thăm khám với bác sĩ Ung Bướu.',
        price: 5500000,
        oldPrice: 7000000,
        isDiscount: true,
        image: 'https://online.benhvienphuongdong.vn/wp-content/uploads/2022/02/kham-suc-khoe-dinh-ky-4.png.webp',
        steps: [
          'Thăm khám và tư vấn chuyên sâu với Bác sĩ Ung Bướu',
          'Xét nghiệm dấu ấn ung thư tổng quát (AFP, CEA, CA 19-9, PSA/CA 125)',
          'Nội soi tiêu hóa (Thực quản - Dạ dày - Đại tràng)',
          'Chụp CT/MRI ngực bụng',
          'Phân tích kết quả và xây dựng kế hoạch theo dõi 5 năm'
        ],
      ),
      
      // 2. GÓI KHÁM ĐẶC BIỆT (isFeatured = true, isDiscount = false)
      HealthPackage(
        id: 'pk007',
        name: 'Gói Cao Cấp Toàn Diện',
        description: 'Kiểm tra chuyên sâu tim mạch, gan, thận, và tầm soát ung thư ban đầu.',
        price: 4500000,
        isFeatured: true, // 💥 GÓI ĐẶC BIỆT NỔI BẬT
        image: 'https://benhvienphuongdong.vn/public/uploads/dich-vu/img-9982.jpg',
        steps: [
          'Khám tổng quát, đo điện tim, X-quang',
          'Xét nghiệm chuyên sâu chức năng gan, thận, mỡ máu',
          'Siêu âm Doppler tim và mạch máu',
          'Nội soi tiêu hóa không đau (có gây mê)',
          'Tư vấn riêng 1-1 với bác sĩ chuyên khoa cấp cao'
        ],
      ),
      HealthPackage(
        id: 'pk008',
        name: 'Gói Phục Hồi Hậu COVID',
        description: 'Đánh giá chức năng phổi, tim mạch sau khi mắc COVID-19.',
        price: 2500000,
        isFeatured: true, // 💥 GÓI ĐẶC BIỆT NỔI BẬT
        image: 'https://media.benhvienhathanh.vn/media/service/kham_suc_khoe-08.jpg',
        steps: [
          'Khám và tư vấn với bác sĩ chuyên khoa Hô hấp',
          'Đo chức năng hô hấp chuyên sâu',
          'Chụp CT ngực liều thấp',
          'Siêu âm tim và xét nghiệm D-Dimer',
          'Lập kế hoạch tập luyện và phục hồi chức năng'
        ],
      ),

      // 3. GÓI KHÁM TIÊU CHUẨN (isDiscount = false, isFeatured = false)
      HealthPackage(
        id: 'pk003',
        name: 'Kiểm tra Sức khỏe Tổng quát Cơ bản',
        description: 'Bao gồm khám lâm sàng, xét nghiệm máu, nước tiểu, X-quang phổi.',
        price: 850000,
        image: 'https://th.hopluchospital.com/wp-content/uploads/2024/03/kiem-tra-suc-khoe-tong-quat.jpg',
        steps: [
          'Khám tổng quát, đo huyết áp, cân nặng',
          'Tổng phân tích máu (18 chỉ số)',
          'Tổng phân tích nước tiểu',
          'Chụp X-quang phổi thẳng',
          'Siêu âm bụng tổng quát'
        ],
      ),
      HealthPackage(
        id: 'pk004',
        name: 'Gói Khám Tiền Hôn Nhân Cơ bản',
        description: 'Kiểm tra sức khỏe sinh sản và tư vấn về kế hoạch hóa gia đình.',
        price: 1200000,
        image: 'https://online.benhvienphuongdong.vn/wp-content/uploads/2025/02/3P6A0129-1.jpg',
        steps: [
          'Khám và tư vấn chuyên khoa Sản/Nam khoa',
          'Xét nghiệm các bệnh lây truyền qua đường tình dục',
          'Phân tích tinh dịch đồ (Nam)',
          'Siêu âm tử cung phần phụ (Nữ)',
          'Xét nghiệm tiền sử tiêm chủng và sàng lọc bệnh Thalassemia'
        ],
      ),
      HealthPackage(
        id: 'pk005',
        name: 'Gói Khám Nhi khoa 0-6 tuổi',
        description: 'Theo dõi sự phát triển, tiêm chủng và tư vấn dinh dưỡng cho bé.',
        price: 900000,
        image: 'https://cdn.phenikaamec.com/phenikaa-mec/image/5-14-2025/185514e8-dec7-47b3-9847-87b0c4f2fb7a-image.webp',
        steps: [
          'Khám tổng quát, đánh giá cột mốc phát triển',
          'Tư vấn dinh dưỡng theo lứa tuổi',
          'Khám nha khoa cơ bản',
          'Kiểm tra thị lực và thính lực ban đầu',
          'Cập nhật lịch tiêm chủng'
        ],
      ),
    ];
  }
}