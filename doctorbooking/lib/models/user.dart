class User {
  final String id;
  final String email;
  final String fullName;
  final String? phone;
  final String? password;
  final String? address;
  final DateTime? birthDay;
  final String? gender;
  final int role;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.password,
    required this.address,
    required this.birthDay,
    required this.gender,
    required this.role,
  });
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      phone: json['phone']?.toString(),
      password: json['password']?.toString(),
      address: json['address']?.toString(),
      birthDay: json['birthDay'] != null && json['birthDay'] != ''
          ? DateTime.tryParse(json['birthDay'])
          : null,
      gender: json['gender']?.toString(),
      role: json['role'] is int
          ? json['role']
          : int.tryParse(json['role']?.toString() ?? '0') ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'phone': phone,
      'password': password,
      'address': address,
      'birthDay': birthDay,
      'gender': gender,
      'role': role,
    };
  }
}
