import 'response/booking_response.dart';

class BookingBillGroup {
  final int billId;
  final List<BookingResponse> bookings;

  const BookingBillGroup({
    required this.billId,
    required this.bookings,
  });

  int get maxBookingId =>
      bookings.isEmpty ? 0 : bookings.map((b) => b.id).reduce((a, b) => a > b ? a : b);

  DateTime get contractCheckInTime => bookings
      .map((b) => b.contractCheckInTime)
      .reduce((a, b) => a.isBefore(b) ? a : b);

  DateTime get contractCheckOutTime => bookings
      .map((b) => b.contractCheckOutTime)
      .reduce((a, b) => a.isAfter(b) ? a : b);

  DateTime? get actualCheckInTime {
    final times = bookings.map((b) => b.actualCheckInTime).whereType<DateTime>().toList();
    if (times.isEmpty) return null;
    return times.reduce((a, b) => a.isBefore(b) ? a : b);
  }

  DateTime? get actualCheckOutTime {
    final times = bookings.map((b) => b.actualCheckOutTime).whereType<DateTime>().toList();
    if (times.isEmpty) return null;
    return times.reduce((a, b) => a.isAfter(b) ? a : b);
  }

  String get paymentStatus => bookings.isEmpty ? '' : bookings.first.paymentStatus;

  double get totalMoney => bookings.isEmpty ? 0 : bookings.first.totalMoney;

  String? get promotionName => bookings.isEmpty ? null : bookings.first.promotionName;

  double? get discount => bookings.isEmpty ? null : bookings.first.discount;

  String get customerName => bookings.isEmpty ? '' : bookings.first.customerName;

  String get customerPhone => bookings.isEmpty ? '' : bookings.first.customerPhone;

  int get customerId => bookings.isEmpty ? 0 : bookings.first.customerId;
}


