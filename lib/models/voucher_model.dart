class VoucherModel {
  final int id;
  final String code;
  final int discountPercentage;
  final int pointsRequired;
  final bool isUsed;
  final DateTime? usedAt;
  final DateTime expiresAt;

  VoucherModel({
    required this.id,
    required this.code,
    required this.discountPercentage,
    required this.pointsRequired,
    required this.isUsed,
    this.usedAt,
    required this.expiresAt,
  });

  factory VoucherModel.fromJson(Map<String, dynamic> json) {
    return VoucherModel(
      id: json['id'],
      code: json['code'],
      discountPercentage: json['discount_percentage'],
      pointsRequired: json['points_required'],
      isUsed: json['is_used'] ?? false,
      usedAt: json['used_at'] != null ? DateTime.parse(json['used_at']) : null,
      expiresAt: DateTime.parse(json['expires_at']),
    );
  }

  bool get isValid => !isUsed && expiresAt.isAfter(DateTime.now());
}
