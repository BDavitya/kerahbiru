class UserModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? address;
  final String? photo;
  final bool isVerified;
  final int gamificationPoints;
  final double? latitude;
  final double? longitude;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.address,
    this.photo,
    required this.isVerified,
    required this.gamificationPoints,
    this.latitude,
    this.longitude,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      photo: json['photo'],
      isVerified: json['is_verified'] ?? false,
      gamificationPoints: json['gamification_points'] ?? 0,
      latitude: json['latitude'] != null
          ? double.parse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.parse(json['longitude'].toString())
          : null,
    );
  }
}
