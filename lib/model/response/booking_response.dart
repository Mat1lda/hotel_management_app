class BookingServiceInfo {
  final String serviceName;
  final int quantity;
  final double price;
  final double total;

  const BookingServiceInfo({
    required this.serviceName,
    required this.quantity,
    required this.price,
    required this.total,
  });

  factory BookingServiceInfo.fromJson(Map<String, dynamic> json) {
    return BookingServiceInfo(
      serviceName: (json['serviceName'] ?? '').toString(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num?)?.toDouble() ??
          (((json['price'] as num?)?.toDouble() ?? 0) *
              ((json['quantity'] as num?)?.toDouble() ?? 0)),
    );
  }
}

class BookingResponse {
  // Basic Info
  final int id;
  final DateTime contractCheckInTime;
  final DateTime contractCheckOutTime;
  final DateTime? actualCheckInTime;
  final DateTime? actualCheckOutTime;

  // Room Info
  final int roomId;
  final int roomNumber;
  final String roomType;
  final double roomPrice;

  // Customer Info
  final int customerId;
  final String customerName;
  final String customerPhone;

  // Employee Info
  final int? employeeId;
  final String? employeeName;

  // Promotion
  final String? promotionName;
  final double? discount;

  // Bill Info
  final int billId;
  final String paymentStatus;
  final double totalMoney;

  // Services List
  final List<BookingServiceInfo> services;

  const BookingResponse({
    required this.id,
    required this.contractCheckInTime,
    required this.contractCheckOutTime,
    required this.actualCheckInTime,
    required this.actualCheckOutTime,
    required this.roomId,
    required this.roomNumber,
    required this.roomType,
    required this.roomPrice,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.employeeId,
    required this.employeeName,
    required this.promotionName,
    required this.discount,
    required this.billId,
    required this.paymentStatus,
    required this.totalMoney,
    required this.services,
  });

  static DateTime _parseDateTimeRequired(dynamic v) {
    if (v == null) {
      throw const FormatException('DateTime is required but was null');
    }
    return DateTime.parse(v.toString()).toLocal();
  }

  static DateTime? _parseDateTimeNullable(dynamic v) {
    if (v == null) return null;
    final s = v.toString();
    if (s.isEmpty) return null;
    return DateTime.parse(s).toLocal();
  }

  factory BookingResponse.fromJson(Map<String, dynamic> json) {
    final rawServices = json['services'];
    final List<dynamic> servicesList =
        rawServices is List ? rawServices : const <dynamic>[];

    return BookingResponse(
      id: (json['id'] as num?)?.toInt() ?? 0,
      contractCheckInTime: _parseDateTimeRequired(json['contractCheckInTime']),
      contractCheckOutTime: _parseDateTimeRequired(json['contractCheckOutTime']),
      actualCheckInTime: _parseDateTimeNullable(json['actualCheckInTime']),
      actualCheckOutTime: _parseDateTimeNullable(json['actualCheckOutTime']),
      roomId: (json['roomId'] as num?)?.toInt() ?? 0,
      roomNumber: (json['roomNumber'] as num?)?.toInt() ?? 0,
      roomType: (json['roomType'] ?? '').toString(),
      roomPrice: (json['roomPrice'] as num?)?.toDouble() ?? 0,
      customerId: (json['customerId'] as num?)?.toInt() ?? 0,
      customerName: (json['customerName'] ?? '').toString(),
      customerPhone: (json['customerPhone'] ?? '').toString(),
      employeeId: (json['employeeId'] as num?)?.toInt(),
      employeeName: json['employeeName']?.toString(),
      promotionName: json['promotionName']?.toString(),
      discount: (json['discount'] as num?)?.toDouble(),
      billId: (json['billId'] as num?)?.toInt() ?? 0,
      paymentStatus: (json['paymentStatus'] ?? '').toString(),
      totalMoney: (json['totalMoney'] as num?)?.toDouble() ?? 0,
      services: servicesList
          .map((e) => BookingServiceInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}


