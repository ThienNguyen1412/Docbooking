class Specialty {
  final String id;
  final String? name;
  final String? iconKey;

  Specialty({required this.id, required this.name, required this.iconKey});

  factory Specialty.fromJson(Map<String, dynamic> json) {
    return Specialty(
      id: json['id'],
      name: json['name'] ?? '',
      iconKey: json['iconKey'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconKey': iconKey,
    };
  }
}