import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/response/promotion_response.dart';
import '../service/promotion_service.dart';

class RoomTypePromotionState {
  final int? roomTypeId;
  final List<PromotionResponse> promotions;
  final bool isLoading;
  final String? errorMessage;
  final bool hasLoaded;

  const RoomTypePromotionState({
    this.roomTypeId,
    this.promotions = const [],
    this.isLoading = false,
    this.errorMessage,
    this.hasLoaded = false,
  });

  RoomTypePromotionState copyWith({
    int? roomTypeId,
    List<PromotionResponse>? promotions,
    bool? isLoading,
    String? errorMessage,
    bool? hasLoaded,
  }) {
    return RoomTypePromotionState(
      roomTypeId: roomTypeId ?? this.roomTypeId,
      promotions: promotions ?? this.promotions,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      hasLoaded: hasLoaded ?? this.hasLoaded,
    );
  }
}

class RoomTypePromotionNotifier extends Notifier<RoomTypePromotionState> {
  late final PromotionService _promotionService;

  @override
  RoomTypePromotionState build() {
    _promotionService = PromotionService();
    return const RoomTypePromotionState();
  }

  Future<void> loadActivePromotionsByRoomType(int roomTypeId) async {
    if (state.isLoading) return;

    final bool shouldSkip = state.hasLoaded &&
        state.roomTypeId == roomTypeId &&
        state.errorMessage == null;
    if (shouldSkip) return;

    state = state.copyWith(
      roomTypeId: roomTypeId,
      isLoading: true,
      errorMessage: null,
      hasLoaded: false,
    );

    try {
      final result =
          await _promotionService.getActivePromotionsByRoomType(roomTypeId);
      if (result['success'] == true) {
        state = state.copyWith(
          promotions: result['data'] as List<PromotionResponse>,
          isLoading: false,
          hasLoaded: true,
        );
      } else {
        state = state.copyWith(
          promotions: const [],
          isLoading: false,
          errorMessage: result['message'] as String,
          hasLoaded: true,
        );
      }
    } catch (e) {
      state = state.copyWith(
        promotions: const [],
        isLoading: false,
        errorMessage: 'Có lỗi không xác định xảy ra: $e',
        hasLoaded: true,
      );
    }
  }

  void clear() {
    state = const RoomTypePromotionState();
  }
}

final roomTypePromotionProvider = NotifierProvider.autoDispose<
    RoomTypePromotionNotifier, RoomTypePromotionState>(() {
  return RoomTypePromotionNotifier();
});


