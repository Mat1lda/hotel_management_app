import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/response/room_promotion_offer_response.dart';
import '../service/promotion_service.dart';

class RoomPromotionOfferState {
  final List<RoomPromotionOfferResponse> offers;
  final bool isLoading;
  final String? errorMessage;
  final bool hasLoaded;

  const RoomPromotionOfferState({
    this.offers = const [],
    this.isLoading = false,
    this.errorMessage,
    this.hasLoaded = false,
  });

  RoomPromotionOfferState copyWith({
    List<RoomPromotionOfferResponse>? offers,
    bool? isLoading,
    String? errorMessage,
    bool? hasLoaded,
  }) {
    return RoomPromotionOfferState(
      offers: offers ?? this.offers,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      hasLoaded: hasLoaded ?? this.hasLoaded,
    );
  }
}

class RoomPromotionOfferNotifier extends Notifier<RoomPromotionOfferState> {
  late final PromotionService _promotionService;

  @override
  RoomPromotionOfferState build() {
    _promotionService = PromotionService();
    return const RoomPromotionOfferState();
  }

  Future<void> load() async {
    if (state.isLoading) return;

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      hasLoaded: false,
    );

    try {
      final result = await _promotionService.getActiveRoomPromotionOffers();
      if (result['success'] == true) {
        state = state.copyWith(
          offers: result['data'] as List<RoomPromotionOfferResponse>,
          isLoading: false,
          hasLoaded: true,
        );
      } else {
        state = state.copyWith(
          offers: const [],
          isLoading: false,
          errorMessage: result['message'] as String,
          hasLoaded: true,
        );
      }
    } catch (e) {
      state = state.copyWith(
        offers: const [],
        isLoading: false,
        errorMessage: 'Có lỗi không xác định xảy ra: $e',
        hasLoaded: true,
      );
    }
  }

  void clear() {
    state = const RoomPromotionOfferState();
  }
}

final roomPromotionOfferProvider = NotifierProvider.autoDispose<
    RoomPromotionOfferNotifier, RoomPromotionOfferState>(() {
  return RoomPromotionOfferNotifier();
});


