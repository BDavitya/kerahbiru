class WorkerModel {
  final int id;
  final String name;
  final String jobTitle;
  final String? description;
  final String gender;
  final double rating;
  final int totalOrders;
  final double pricePerHour;
  final String? photo;
  final double latitude;
  final double longitude;
  final String phone;
  final String whatsapp;
  final bool isAvailable;
  final double? distance; // jarak dari user

  WorkerModel({
    required this.id,
    required this.name,
    required this.jobTitle,
    this.description,
    required this.gender,
    required this.rating,
    required this.totalOrders,
    required this.pricePerHour,
    this.photo,
    required this.latitude,
    required this.longitude,
    required this.phone,
    required this.whatsapp,
    required this.isAvailable,
    this.distance,
  });

  factory WorkerModel.fromJson(Map<String, dynamic> json) {
    return WorkerModel(
      id: json['id'],
      name: json['name'],
      jobTitle: json['job_title'],
      description: json['description'],
      gender: json['gender'],
      rating: double.parse(json['rating'].toString()),
      totalOrders: json['total_orders'],
      pricePerHour: double.parse(json['price_per_hour'].toString()),
      photo: json['photo'],
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
      phone: json['phone'],
      whatsapp: json['whatsapp'],
      isAvailable: json['is_available'] ?? true,
      distance: json['distance'] != null
          ? double.parse(json['distance'].toString())
          : null,
    );
  }
}
