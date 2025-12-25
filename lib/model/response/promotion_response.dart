class PromotionResponse {
  final int? roomPromotionId;
  final int id;
  final String name;
  final String details;
  final String banner;
  final double discount;
  final String startTime;
  final String endTime;
  final bool isActive;

  const PromotionResponse({
    this.roomPromotionId,
    required this.id,
    required this.name,
    required this.details,
    required this.banner,
    required this.discount,
    required this.startTime,
    required this.endTime,
    required this.isActive,
  });

  factory PromotionResponse.fromJson(Map<String, dynamic> json) {
    return PromotionResponse(
      roomPromotionId: (json['roomPromotionId'] as num?)?.toInt(),
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      details: json['details']?.toString() ?? '',
      banner: json['banner']?.toString() ?? '',
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      startTime: json['startTime']?.toString() ?? '',
      endTime: json['endTime']?.toString() ?? '',
      isActive: (json['isActive'] as bool?) ?? false,
    );
  }
}


