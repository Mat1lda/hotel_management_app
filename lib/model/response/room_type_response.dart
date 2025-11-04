class RoomTypeResponse {
  final int id;
  final String name;
  final String details;
  final int bedCount;
  final int maxOccupancy;
  final double price;
  final double area;
  final bool isPrivateBathroom;
  final bool isFreeToiletries;
  final bool isAirConditioning;
  final bool isSoundproofing;
  final bool isTV;
  final bool isMiniBar;
  final bool isWorkDesk;
  final bool isSeatingArea;
  final bool isSafetyFeatures;
  final bool isSmoking;
  final List<String> images;

  const RoomTypeResponse({
    required this.id,
    required this.name,
    required this.details,
    required this.bedCount,
    required this.maxOccupancy,
    required this.price,
    required this.area,
    required this.isPrivateBathroom,
    required this.isFreeToiletries,
    required this.isAirConditioning,
    required this.isSoundproofing,
    required this.isTV,
    required this.isMiniBar,
    required this.isWorkDesk,
    required this.isSeatingArea,
    required this.isSafetyFeatures,
    required this.isSmoking,
    required this.images,
  });

  factory RoomTypeResponse.fromJson(Map<String, dynamic> json) {
    return RoomTypeResponse(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      details: json['details']?.toString() ?? '',
      bedCount: (json['bedCount'] as num?)?.toInt() ?? 0,
      maxOccupancy: (json['maxOccupancy'] as num?)?.toInt() ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      area: (json['area'] as num?)?.toDouble() ?? 0.0,
      isPrivateBathroom: (json['isPrivateBathroom'] as bool?) ?? false,
      isFreeToiletries: (json['isFreeToiletries'] as bool?) ?? false,
      isAirConditioning: (json['isAirConditioning'] as bool?) ?? false,
      isSoundproofing: (json['isSoundproofing'] as bool?) ?? false,
      isTV: (json['isTV'] as bool?) ?? false,
      isMiniBar: (json['isMiniBar'] as bool?) ?? false,
      isWorkDesk: (json['isWorkDesk'] as bool?) ?? false,
      isSeatingArea: (json['isSeatingArea'] as bool?) ?? false,
      isSafetyFeatures: (json['isSafetyFeatures'] as bool?) ?? false,
      isSmoking: (json['isSmoking'] as bool?) ?? false,
      images: (json['images'] as List?)?.map((e) => e.toString()).toList() ?? const <String>[],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'details': details,
      'bedCount': bedCount,
      'maxOccupancy': maxOccupancy,
      'price': price,
      'area': area,
      'isPrivateBathroom': isPrivateBathroom,
      'isFreeToiletries': isFreeToiletries,
      'isAirConditioning': isAirConditioning,
      'isSoundproofing': isSoundproofing,
      'isTV': isTV,
      'isMiniBar': isMiniBar,
      'isWorkDesk': isWorkDesk,
      'isSeatingArea': isSeatingArea,
      'isSafetyFeatures': isSafetyFeatures,
      'isSmoking': isSmoking,
      'images': images,
    };
  }

  String get formattedPrice => '${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} VNĐ';
  
  String get formattedArea => '${area.toStringAsFixed(0)} m²';
  
  String get bedInfo => '$bedCount giường';
  
  String get guestInfo => 'Tối đa $maxOccupancy khách';

  List<String> get amenities {
    List<String> amenityList = [];
    if (isPrivateBathroom) amenityList.add('Phòng tắm riêng');
    if (isFreeToiletries) amenityList.add('Đồ vệ sinh miễn phí');
    if (isAirConditioning) amenityList.add('Điều hòa');
    if (isSoundproofing) amenityList.add('Cách âm');
    if (isTV) amenityList.add('TV');
    if (isMiniBar) amenityList.add('Mini Bar');
    if (isWorkDesk) amenityList.add('Bàn làm việc');
    if (isSeatingArea) amenityList.add('Khu vực ngồi');
    if (isSafetyFeatures) amenityList.add('Tính năng an toàn');
    if (isSmoking) amenityList.add('Cho phép hút thuốc');
    return amenityList;
  }
}
