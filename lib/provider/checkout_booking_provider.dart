import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/request/booking_create_request.dart';
import '../model/selected_room_result.dart';
import '../provider/booking_request_provider.dart';
import '../provider/auth_provider.dart';
import '../service/booking_service.dart';
import '../utility/app_date_utils.dart';

class CheckoutBookingState {
  final bool isSubmitting;
  final bool success;
  final String? errorMessage;

  const CheckoutBookingState({
    this.isSubmitting = false,
    this.success = false,
    this.errorMessage,
  });

  CheckoutBookingState copyWith({
    bool? isSubmitting,
    bool? success,
    String? errorMessage,
  }) {
    return CheckoutBookingState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      success: success ?? this.success,
      errorMessage: errorMessage,
    );
  }
}

class CheckoutBookingNotifier extends Notifier<CheckoutBookingState> {
  late final BookingService _bookingService;

  @override
  CheckoutBookingState build() {
    _bookingService = BookingService();
    return const CheckoutBookingState();
  }

  Future<bool> submit({
    required BookingRequestState bookingState,
    required SelectedRoomResult selection,
    required User? user,
  }) async {
    if (state.isSubmitting) return false;

    if (user == null) {
      state = state.copyWith(errorMessage: 'Bạn cần đăng nhập để đặt phòng');
      return false;
    }

    final rooms = selection.rooms;
    if (rooms.isEmpty) {
      state = state.copyWith(errorMessage: 'Vui lòng chọn ít nhất 1 phòng');
      return false;
    }

    final checkIn = bookingState.checkIn;
    final checkOut = bookingState.checkOut;
    if (checkIn == null || checkOut == null) {
      state = state.copyWith(errorMessage: 'Vui lòng chọn ngày nhận/trả phòng');
      return false;
    }

    final int? roomPromotionId = (selection.promotion?.roomPromotionId ?? 0) > 0
        ? selection.promotion!.roomPromotionId
        : null;
    final request = BookingCreateRequest(
      customerId: user.id,
      bookings: rooms
          .map(
            (r) => BookingItemRequest(
              roomId: r.id,
              roomPromotionId: roomPromotionId,
              checkInDate: AppDateUtils.formatIsoDate(checkIn),
              checkOutDate: AppDateUtils.formatIsoDate(checkOut),
            ),
          )
          .toList(),
    );

    state = state.copyWith(isSubmitting: true, errorMessage: null);
    final result = await _bookingService.createBooking(
      request,
      token: user.token,
    );
    final ok = result['success'] == true;

    if (ok) {
      state = state.copyWith(
        isSubmitting: false,
        success: true,
        errorMessage: null,
      );
      return true;
    }

    state = state.copyWith(
      isSubmitting: false,
      success: false,
      errorMessage: result['message']?.toString() ?? 'Đặt phòng thất bại',
    );
    return false;
  }

  void clearStatus() {
    state = state.copyWith(success: false, errorMessage: null);
  }
}

final checkoutBookingProvider =
    NotifierProvider.autoDispose<CheckoutBookingNotifier, CheckoutBookingState>(
  () => CheckoutBookingNotifier(),
);


