// File: lib/data/user_profile_service.dart


// Sử dụng Singleton để đảm bảo chỉ có một đối tượng quản lý dữ liệu người dùng
class UserProfileService {
  // Private constructor
  UserProfileService._privateConstructor();

  // Thực thể duy nhất
  static final UserProfileService instance = UserProfileService._privateConstructor();

  // Dữ liệu người dùng (không phải final để có thể thay đổi)
  String name = 'Nguyễn Minh Thiện';
  String email = 'thiennguyen@gmail.com';
  String phone = '0901 234 567';
  DateTime dob = DateTime(1995, 1, 15);
  String gender = 'Nam';
  String avatarUrl = 'https://img.lovepik.com/free-png/20220101/lovepik-tortoise-png-image_401154498_wh860.png';

  // Hàm để cập nhật thông tin
  void updateProfile({
    required String newName,
    required String newPhone,
    required DateTime newDob,
    required String newGender,
  }) {
    name = newName;
    phone = newPhone;
    dob = newDob;
    gender = newGender;
    // Email và avatar thường được cập nhật qua quy trình riêng
  }
}