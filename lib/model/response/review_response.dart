class ReviewResponse {
  final int id;
  final String details;
  final int star;
  final String? type;
  final DateTime? day;
  final String customerName;
  final List<String> imageUrls;

  ReviewResponse({
    required this.id,
    required this.details,
    required this.star,
    required this.customerName,
    this.type,
    this.day,
    this.imageUrls = const [],
  });

  factory ReviewResponse.fromJson(Map<String, dynamic> json) {
    final dynamic dayValue = json['day'];
    DateTime? parsedDay;
    if (dayValue is String && dayValue.isNotEmpty) {
      try {
        parsedDay = DateTime.parse(dayValue);
      } catch (_) {
        parsedDay = null;
      }
    }

    final dynamic images = json['imageUrls'];
    final List<String> imageUrls = images is List
        ? images.map((e) => e.toString()).toList()
        : const [];

    return ReviewResponse(
      id: (json['id'] as num).toInt(),
      details: (json['details'] ?? '').toString(),
      star: ((json['star'] ?? 0) as num).toInt(),
      type: json['type']?.toString(),
      day: parsedDay,
      customerName: (json['customerName'] ?? '').toString(),
      imageUrls: imageUrls,
    );
  }
}


