class BookingItemRequest {
  final int roomId;
  final int? roomPromotionId;
  final String checkInDate;
  final String checkOutDate;

  const BookingItemRequest({
    required this.roomId,
    this.roomPromotionId,
    required this.checkInDate,
    required this.checkOutDate,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {
      'roomId': roomId,
      'checkInDate': checkInDate,
      'checkOutDate': checkOutDate,
    };
    final int? promoId = roomPromotionId;
    if (promoId != null && promoId > 0) {
      map['roomPromotionId'] = promoId;
    }
    return map;
  }
}

class BookingCreateRequest {
  final int customerId;
  final List<BookingItemRequest> bookings;

  const BookingCreateRequest({
    required this.customerId,
    required this.bookings,
  });

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'bookings': bookings.map((e) => e.toJson()).toList(),
    };
  }
}


