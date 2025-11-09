import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/response/review_response.dart';
import '../service/review_service.dart';

class ReviewState {
  final List<ReviewResponse> reviews;
  final bool isLoading;
  final String? errorMessage;
  final bool hasLoaded;

  const ReviewState({
    this.reviews = const [],
    this.isLoading = false,
    this.errorMessage,
    this.hasLoaded = false,
  });

  ReviewState copyWith({
    List<ReviewResponse>? reviews,
    bool? isLoading,
    String? errorMessage,
    bool? hasLoaded,
  }) {
    return ReviewState(
      reviews: reviews ?? this.reviews,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      hasLoaded: hasLoaded ?? this.hasLoaded,
    );
  }
}

class ReviewNotifier extends Notifier<ReviewState> {
  late final ReviewService _reviewService;

  @override
  ReviewState build() {
    _reviewService = ReviewService();
    return const ReviewState();
  }

  Future<void> loadLatest({int limit = 4}) async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final result = await _reviewService.getAllReviews();
      if (result['success'] == true) {
        final List<ReviewResponse> allReviews = result['data'] as List<ReviewResponse>;
        final List<ReviewResponse> sorted = [...allReviews]..sort((a, b) {
          final aDay = a.day;
          final bDay = b.day;
          if (aDay != null && bDay != null) {
            return bDay.compareTo(aDay);
          }
          return b.id.compareTo(a.id);
        });
        final reviews = sorted.take(limit).toList();
        state = state.copyWith(
          reviews: reviews,
          isLoading: false,
          hasLoaded: true,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: result['message'] as String,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Có lỗi không xác định xảy ra: $e',
      );
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

final reviewProvider = NotifierProvider.autoDispose<ReviewNotifier, ReviewState>(() {
  return ReviewNotifier();
});


