// File: models/news.dart (ĐÃ CẬP NHẬT VỚI NHIỀU TIN TỨC HƠN)

class NewsArticle {
  final String id; 
  final String title;
  final String date;
  final String summary;
  final String imageUrl;
  final String content; 

  const NewsArticle({
    required this.id,
    required this.title,
    required this.date,
    required this.summary,
    required this.imageUrl,
    required this.content,
  });

  // Dữ liệu mẫu (Static data) ĐÃ MỞ RỘNG
  static List<NewsArticle> getNews() {
    return const [ 
      // 1. Dữ liệu cũ (4 bài)
      NewsArticle(
        id: 'n001',
        title: 'Thực phẩm giúp tăng cường miễn dịch mùa cúm',
        date: '05/10/2025',
        summary: 'Các chuyên gia dinh dưỡng khuyên dùng cam, quýt và rau xanh lá để bảo vệ sức khỏe trong thời tiết giao mùa.',
        imageUrl: 'https://suckhoedoisong.qltns.mediacdn.vn/324455921873985536/2023/12/1/nen-an-nhung-thuc-pham-giau-kem-de-tang-mien-dich-1701399884175555789826.jpg',
        content: 'Mùa cúm đến, việc tăng cường hệ miễn dịch là điều tối quan trọng. Các thực phẩm giàu Vitamin C như cam, quýt, bưởi, và các loại rau xanh đậm như cải bó xôi, bông cải xanh chứa nhiều chất chống oxy hóa giúp cơ thể chống lại virus. Ngoài ra, tỏi và gừng cũng là những "siêu thực phẩm" giúp làm ấm cơ thể và kháng viêm tự nhiên. Hãy bổ sung đầy đủ và cân đối để có một sức khỏe tốt nhất.',
      ),
      NewsArticle(
        id: 'n002',
        title: 'Công nghệ AI trong chẩn đoán sớm ung thư',
        date: '02/10/2025',
        summary: 'Bệnh viện chúng tôi áp dụng thành công công nghệ mới giúp tăng độ chính xác trong phát hiện các tế bào ác tính.',
        imageUrl: 'https://media.vietnamplus.vn/images/7255a701687d11cb8c6bbc58a6c80785887a91cede1358e5f0cc2ef27925ad6991f4ba4d4e3749cbc6e0c8cbce7b01d94f9efb0c8972265f49d8f86164867992/ung_thu_vu.jpg',
        content: 'Trí tuệ nhân tạo (AI) đang cách mạng hóa ngành y tế, đặc biệt là trong lĩnh vực chẩn đoán ung thư. Các thuật toán học sâu (Deep Learning) có khả năng phân tích hình ảnh y khoa (như X-quang, MRI, CT) với tốc độ và độ chính xác vượt trội so với mắt người. Điều này giúp bác sĩ phát hiện các dấu hiệu ung thư ở giai đoạn rất sớm, tăng tỷ lệ điều trị thành công. Đây là một bước tiến lớn, hứa hẹn giảm thiểu sai sót trong chẩn đoán và cứu sống nhiều bệnh nhân hơn.',
      ),
      NewsArticle(
        id: 'n003',
        title: 'Lịch tiêm chủng mở rộng cho trẻ em Quý IV',
        date: '28/09/2025',
        summary: 'Thông báo về lịch tiêm phòng các loại vaccine cần thiết. Phụ huynh vui lòng theo dõi và đưa trẻ đi đúng hẹn.',
        imageUrl: 'https://www.vinmec.com/static/uploads/20191126_053315_907320_tiem_vacxin_cho_tre_max_1800x1800_jpg_49d307b742.jpg',
        content: 'Sở Y tế thông báo lịch tiêm chủng mở rộng Quý IV (từ tháng 10 đến tháng 12) bao gồm các vaccine phòng ngừa Sởi, Rubella, Bạch hầu, Ho gà, Uốn ván và Bại liệt. Phụ huynh cần kiểm tra sổ tiêm chủng của con và đảm bảo trẻ được tiêm đúng và đủ liều. Việc tiêm chủng đầy đủ là biện pháp bảo vệ tốt nhất cho sức khỏe của trẻ và cộng đồng.',
      ),
      NewsArticle(
        id: 'n004',
        title: 'Tác hại của việc lạm dụng kháng sinh',
        date: '20/09/2025',
        summary: 'Bài viết cảnh báo về tình trạng kháng thuốc và những hậu quả nghiêm trọng đối với sức khỏe cộng đồng.',
        imageUrl: 'https://tracybee.vn/wp-content/uploads/2023/02/1-6.webp',
        content: 'Tình trạng kháng kháng sinh đang là mối đe dọa toàn cầu. Việc tự ý mua và sử dụng kháng sinh khi không có chỉ định của bác sĩ dẫn đến vi khuẩn biến đổi, khiến thuốc mất tác dụng. Điều này làm cho các bệnh nhiễm trùng thông thường trở nên khó chữa, kéo dài thời gian nằm viện và tăng nguy cơ tử vong. Chúng tôi khuyến cáo mọi người chỉ sử dụng kháng sinh theo đơn và tuân thủ tuyệt đối hướng dẫn của bác sĩ.',
      ),

      NewsArticle(
        id: 'n005',
        title: 'Lợi ích bất ngờ của việc đi bộ 30 phút mỗi ngày',
        date: '15/09/2025',
        summary: 'Chỉ cần dành 30 phút đi bộ, bạn có thể cải thiện sức khỏe tim mạch, giảm căng thẳng và kiểm soát cân nặng hiệu quả.',
        imageUrl: 'https://suckhoedoisong.qltns.mediacdn.vn/324455921873985536/2024/8/28/photo-1724840072492-17248400725701545135551.jpeg',
        content: 'Đi bộ là hình thức tập thể dục đơn giản và dễ thực hiện nhất. Các nghiên cứu đã chỉ ra rằng đi bộ nhanh 30 phút mỗi ngày giúp giảm 30% nguy cơ mắc bệnh tim mạch, cải thiện tâm trạng bằng cách giải phóng endorphin, và hỗ trợ quá trình đốt cháy calo. Đây là một thói quen tuyệt vời để bắt đầu một lối sống khỏe mạnh mà không cần thiết bị phức tạp.',
      ),
      NewsArticle(
        id: 'n006',
        title: 'Cảnh báo về bệnh sốt xuất huyết bùng phát',
        date: '08/09/2025',
        summary: 'Các khu vực đô thị cần tăng cường phòng chống muỗi vằn và vệ sinh môi trường để kiểm soát dịch bệnh sốt xuất huyết.',
        imageUrl: 'https://cdn.nhathuoclongchau.com.vn/unsafe/800x0/https://cms-prod.s3-sgn09.fptcloud.com/canh_bao_benh_sot_xuat_huyet_tang_sau_mua_mua_lu_1_6b16f4c0e2.png',
        content: 'Sốt xuất huyết đang có dấu hiệu tăng mạnh trong mùa mưa. Triệu chứng bao gồm sốt cao đột ngột, đau đầu dữ dội và đau nhức cơ thể. Điều quan trọng là phải loại bỏ các vật dụng chứa nước đọng xung quanh nhà để ngăn chặn sự sinh sản của muỗi Aedes. Nếu có triệu chứng, cần đến cơ sở y tế ngay lập tức, tránh tự ý dùng thuốc hạ sốt Ibuprofen có thể gây biến chứng xuất huyết.',
      ),
      NewsArticle(
        id: 'n007',
        title: 'Vai trò của Vitamin D đối với xương và miễn dịch',
        date: '01/09/2025',
        summary: 'Nhiều người Việt Nam thiếu hụt Vitamin D. Bài viết này sẽ chỉ rõ nguồn cung cấp và tầm quan trọng của nó.',
        imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQyvlGAYZTXuJnf656gZoGcq71StIzPjfuq6g&s',
        content: 'Vitamin D, thường được gọi là "vitamin ánh nắng", đóng vai trò cốt yếu trong việc hấp thụ Canxi, giúp xương chắc khỏe. Ngoài ra, nó còn hỗ trợ chức năng miễn dịch, giúp cơ thể chống lại bệnh tật. Nguồn cung cấp chính là ánh nắng mặt trời buổi sáng sớm, cá béo, và các sản phẩm sữa được bổ sung Vitamin D. Xét nghiệm máu định kỳ có thể giúp xác định mức độ thiếu hụt của bạn.',
      ),
      NewsArticle(
        id: 'n008',
        title: 'Phương pháp giảm đau thắt lưng không dùng thuốc',
        date: '25/08/2025',
        summary: 'Các bài tập kéo giãn và vật lý trị liệu là chìa khóa để cải thiện tình trạng đau thắt lưng mãn tính.',
        imageUrl: 'https://prod-cdn.pharmacity.io/blog/dauthatlung2.jpg?X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAUYXZVMJMURHIYJSN%2F20240813%2Fap-southeast-1%2Fs3%2Faws4_request&X-Amz-Date=20240813T014001Z&X-Amz-SignedHeaders=host&X-Amz-Expires=600&X-Amz-Signature=87b4330822825975fdcd452d4c50f7672fe2ac69d21d6861b68a7fb35f074140',
        content: 'Đau thắt lưng mãn tính là vấn đề phổ biến ở người làm việc văn phòng. Thay vì phụ thuộc vào thuốc giảm đau, các chuyên gia khuyên nên kết hợp vật lý trị liệu, các bài tập yoga nhẹ nhàng và chườm nóng/lạnh. Quan trọng nhất là điều chỉnh tư thế ngồi làm việc, sử dụng ghế hỗ trợ và thường xuyên đứng dậy vận động để giảm áp lực lên cột sống.',
      ),
      NewsArticle(
        id: 'n009',
        title: 'Dinh dưỡng cho phụ nữ mang thai: Những điều cần biết',
        date: '18/08/2025',
        summary: 'Tập trung vào Acid Folic, Sắt và Canxi để đảm bảo sự phát triển khỏe mạnh của cả mẹ và bé.',
        imageUrl: 'https://suckhoedoisong.qltns.mediacdn.vn/324455921873985536/2023/8/28/bai-dinh-duong-30-1693210719066316275954.jpg',
        content: 'Trong thai kỳ, chế độ dinh dưỡng đóng vai trò cực kỳ quan trọng. Bà bầu cần tăng cường Acid Folic (từ rau xanh, ngũ cốc) để ngăn ngừa dị tật ống thần kinh ở thai nhi. Sắt là cần thiết để phòng chống thiếu máu, và Canxi giúp phát triển xương và răng cho bé. Hãy tham khảo ý kiến bác sĩ để có một kế hoạch dinh dưỡng phù hợp và bổ sung vitamin tổng hợp đúng cách.',
      ),
    ];
  }
}