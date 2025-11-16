import 'worker_model.dart';

class OrderModel {
  final int id;
  final int userId;
  final int workerId;
  final String orderDate;
  final String timeSlot;
  final double distanceKm;
  final double totalPrice;
  final String status;
  final String? photoBefore;
  final String? photoAfter;
  final double? userRating;
  final String? userReview;
  final DateTime? workerArrivedAt;
  final DateTime? workStartedAt;
  final DateTime? workCompletedAt;

  // Relasi
  final WorkerModel? worker;

  OrderModel({
    required this.id,
    required this.userId,
    required this.workerId,
    required this.orderDate,
    required this.timeSlot,
    required this.distanceKm,
    required this.totalPrice,
    required this.status,
    this.photoBefore,
    this.photoAfter,
    this.userRating,
    this.userReview,
    this.workerArrivedAt,
    this.workStartedAt,
    this.workCompletedAt,
    this.worker,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      userId: json['user_id'],
      workerId: json['worker_id'],
      orderDate: json['order_date'],
      timeSlot: json['time_slot'],
      distanceKm: double.parse(json['distance_km'].toString()),
      totalPrice: double.parse(json['total_price'].toString()),
      status: json['status'],
      photoBefore: json['photo_before'],
      photoAfter: json['photo_after'],
      userRating: json['user_rating'] != null
          ? double.parse(json['user_rating'].toString())
          : null,
      userReview: json['user_review'],
      workerArrivedAt: json['worker_arrived_at'] != null
          ? DateTime.parse(json['worker_arrived_at'])
          : null,
      workStartedAt: json['work_started_at'] != null
          ? DateTime.parse(json['work_started_at'])
          : null,
      workCompletedAt: json['work_completed_at'] != null
          ? DateTime.parse(json['work_completed_at'])
          : null,
      worker: json['worker'] != null
          ? WorkerModel.fromJson(json['worker'])
          : null,
    );
  }

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'Menunggu Konfirmasi';
      case 'accepted':
        return 'Diterima';
      case 'on_the_way':
        return 'Sedang Menuju Lokasi';
      case 'in_progress':
        return 'Sedang Bekerja';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return 'Unknown';
    }
  }
}
