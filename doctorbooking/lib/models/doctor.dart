class Doctor {
  final String id;
  final String? fullName;
  final String? hospital;
  final String specialtyName; // trường hiển thị (luôn non-null để UI dễ dùng)
  final String? phone;
  final String? avatarUrl;
  final String? specialtyId; // mới: backend trả id -> lưu để dùng nếu cần

  Doctor({
    required this.id,
    required this.fullName,
    required this.hospital,
    required this.specialtyName,
    required this.phone,
    required this.avatarUrl,
    this.specialtyId,
  });

  factory Doctor.fromJson(Map<String, dynamic> json, {Map<String, String>? specialityMap}) {
    // specialityMap: optional map id -> name được truyền từ service khi có
    String resolvedSpecialtyName = '';

    // 1) If backend already returns specialtyName directly
    if (json['specialtyName'] != null && json['specialtyName'].toString().trim().isNotEmpty) {
      resolvedSpecialtyName = json['specialtyName'].toString();
    }

    // 2) If backend returns nested object: { "specialty": { "id": "...", "name": "..." } }
    if ((resolvedSpecialtyName.isEmpty) && (json['specialty'] is Map)) {
      final sp = json['specialty'] as Map<String, dynamic>;
      if (sp['name'] != null && sp['name'].toString().trim().isNotEmpty) {
        resolvedSpecialtyName = sp['name'].toString();
      }
    }

    // 3) If backend returns string at 'specialty' key
    if (resolvedSpecialtyName.isEmpty && json['specialty'] is String && json['specialty'].toString().trim().isNotEmpty) {
      resolvedSpecialtyName = json['specialty'].toString();
    }

    // 4) Try alternative key names
    if (resolvedSpecialtyName.isEmpty && json['specialityName'] != null && json['specialityName'].toString().trim().isNotEmpty) {
      resolvedSpecialtyName = json['specialityName'].toString();
    }

    // 5) If backend returns only specialtyId, try to map using specialityMap
    String? resolvedSpecialtyId;
    if (json['specialtyId'] != null) {
      resolvedSpecialtyId = json['specialtyId'].toString();
      if (resolvedSpecialtyName.isEmpty && specialityMap != null) {
        final nameFromMap = specialityMap[resolvedSpecialtyId];
        if (nameFromMap != null && nameFromMap.isNotEmpty) {
          resolvedSpecialtyName = nameFromMap;
        }
      }
    } else if (json['specialityId'] != null) {
      resolvedSpecialtyId = json['specialityId'].toString();
      if (resolvedSpecialtyName.isEmpty && specialityMap != null) {
        final nameFromMap = specialityMap[resolvedSpecialtyId];
        if (nameFromMap != null && nameFromMap.isNotEmpty) {
          resolvedSpecialtyName = nameFromMap;
        }
      }
    } else if (json['specialty'] is Map && (json['specialty']['id'] != null)) {
      resolvedSpecialtyId = json['specialty']['id'].toString();
      if (resolvedSpecialtyName.isEmpty && specialityMap != null) {
        final nameFromMap = specialityMap[resolvedSpecialtyId];
        if (nameFromMap != null && nameFromMap.isNotEmpty) {
          resolvedSpecialtyName = nameFromMap;
        }
      }
    }

    // Final fallback: empty string if not found
    if (resolvedSpecialtyName.isEmpty) resolvedSpecialtyName = '';

    return Doctor(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString(),
      hospital: json['hospital']?.toString(),
      specialtyName: resolvedSpecialtyName,
      phone: json['phone']?.toString(),
      avatarUrl: json['avatarUrl']?.toString(),
      specialtyId: resolvedSpecialtyId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (fullName != null) 'fullName': fullName,
      if (hospital != null) 'hospital': hospital,
      'specialtyName': specialtyName,
      if (phone != null) 'phone': phone,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      if (specialtyId != null) 'specialtyId': specialtyId,
    };
  }
}