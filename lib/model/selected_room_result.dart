import 'response/promotion_response.dart';
import 'response/room_response.dart';

class SelectedRoomResult {
  final List<RoomResponse> rooms;
  final PromotionResponse? promotion;

  const SelectedRoomResult({
    required this.rooms,
    this.promotion,
  });
}


