class BookingModel {
  final String id;
  final String hotelName;
  final String hotelImage;
  final double rating;
  final String dates;
  final int guests;
  final int rooms;
  final String price;
  final BookingStatus status;

  const BookingModel({
    required this.id,
    required this.hotelName,
    required this.hotelImage,
    required this.rating,
    required this.dates,
    required this.guests,
    required this.rooms,
    required this.price,
    required this.status,
  });

  BookingModel copyWith({
    String? id,
    String? hotelName,
    String? hotelImage,
    double? rating,
    String? dates,
    int? guests,
    int? rooms,
    String? price,
    BookingStatus? status,
  }) {
    return BookingModel(
      id: id ?? this.id,
      hotelName: hotelName ?? this.hotelName,
      hotelImage: hotelImage ?? this.hotelImage,
      rating: rating ?? this.rating,
      dates: dates ?? this.dates,
      guests: guests ?? this.guests,
      rooms: rooms ?? this.rooms,
      price: price ?? this.price,
      status: status ?? this.status,
    );
  }
}

enum BookingStatus {
  booked,
  history,
}

extension BookingStatusExtension on BookingStatus {
  String get displayName {
    switch (this) {
      case BookingStatus.booked:
        return 'Đã đặt';
      case BookingStatus.history:
        return 'Lịch sử';
    }
  }
}
