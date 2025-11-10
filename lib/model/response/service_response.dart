class ServiceResponse {
  final int id;
  final String name;
  final String details;
  final double price;
  final int isAvailable;
  final String unit;
  final int quantity;
  final int hotelId;
  final String hotelName;
  final int categoryId;
  final String categoryName;
  final List<String> imageUrls;

  const ServiceResponse({
    required this.id,
    required this.name,
    required this.details,
    required this.price,
    required this.isAvailable,
    required this.unit,
    required this.quantity,
    required this.hotelId,
    required this.hotelName,
    required this.categoryId,
    required this.categoryName,
    required this.imageUrls,
  });

  factory ServiceResponse.fromJson(Map<String, dynamic> json) {
    final dynamic priceRaw = json['price'];
    final double parsedPrice = priceRaw is num ? priceRaw.toDouble() : 0.0;

    final List<String> images = (json['imageUrls'] as List<dynamic>? ?? const [])
        .map((e) => e.toString())
        .toList();

    return ServiceResponse(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?)?.trim() ?? '',
      details: (json['details'] as String?)?.trim() ?? '',
      price: parsedPrice,
      isAvailable: (json['isAvaiable'] as num?)?.toInt() ?? 0,
      unit: (json['unit'] as String?)?.trim() ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      hotelId: (json['hotelId'] as num?)?.toInt() ?? 0,
      hotelName: (json['hotelName'] as String?)?.trim() ?? '',
      categoryId: (json['categoryId'] as num?)?.toInt() ?? 0,
      categoryName: (json['categoryName'] as String?)?.trim() ?? '',
      imageUrls: images,
    );
  }
}


