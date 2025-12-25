import 'room_type_response.dart';

class RoomResponse {
  final int id;
  final int roomNumber;
  final String details;
  final String hotelName;
  final String roomStatusName;
  final List<String> imageUrls;
  final RoomTypeResponse roomType;

  const RoomResponse({
    required this.id,
    required this.roomNumber,
    required this.details,
    required this.hotelName,
    required this.roomStatusName,
    required this.imageUrls,
    required this.roomType,
  });

  factory RoomResponse.fromJson(Map<String, dynamic> json) {
    final dynamic rawImageUrls = json['imageUrls'];
    final List<String> imageUrls = (rawImageUrls is List)
        ? rawImageUrls.map((e) => e.toString()).toList()
        : const <String>[];

    final Map<String, dynamic> roomTypeJson =
        (json['roomType'] as Map?)?.cast<String, dynamic>() ??
            const <String, dynamic>{};

    return RoomResponse(
      id: (json['id'] as num?)?.toInt() ?? 0,
      roomNumber: (json['roomNumber'] as num?)?.toInt() ?? 0,
      details: json['details']?.toString() ?? '',
      hotelName: json['hotelName']?.toString() ?? '',
      roomStatusName: json['roomStatusName']?.toString() ?? '',
      imageUrls: imageUrls,
      roomType: RoomTypeResponse.fromJson(roomTypeJson),
    );
  }

  bool get isAvailable => roomStatusName.toLowerCase() == 'available';
}


