import 'promotion_response.dart';

class RoomPromotionOfferResponse {
  final int roomPromotionId;
  final String roomPromotionDetails;

  final int roomTypeId;
  final String roomTypeName;

  final PromotionResponse promotion;

  const RoomPromotionOfferResponse({
    required this.roomPromotionId,
    required this.roomPromotionDetails,
    required this.roomTypeId,
    required this.roomTypeName,
    required this.promotion,
  });
}


