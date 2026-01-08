import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/booking_model.dart';
import '../model/booking_bill_group.dart';
import '../model/response/booking_response.dart';
import '../service/booking_service.dart';
import 'auth_provider.dart';

class MyBookingState {
  final bool initialized;
  final int? userId;
  final List<BookingBillGroup> bookedBookings;
  final List<BookingBillGroup> historyBookings;
  final BookingStatus selectedTab;
  final bool isLoading;
  final String? errorMessage;

  const MyBookingState({
    this.initialized = false,
    this.userId,
    this.bookedBookings = const [],
    this.historyBookings = const [],
    this.selectedTab = BookingStatus.booked,
    this.isLoading = false,
    this.errorMessage,
  });

  MyBookingState copyWith({
    bool? initialized,
    int? userId,
    List<BookingBillGroup>? bookedBookings,
    List<BookingBillGroup>? historyBookings,
    BookingStatus? selectedTab,
    bool? isLoading,
    String? errorMessage,
  }) {
    return MyBookingState(
      initialized: initialized ?? this.initialized,
      userId: userId ?? this.userId,
      bookedBookings: bookedBookings ?? this.bookedBookings,
      historyBookings: historyBookings ?? this.historyBookings,
      selectedTab: selectedTab ?? this.selectedTab,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class MyBookingNotifier extends Notifier<MyBookingState> {
  late final BookingService _bookingService;

  bool _isCancelledStatus(String status) {
    final s = status.toLowerCase().trim();
    return s == 'cancelled' ||
        s == 'canceled' ||
        s == 'cancel' ||
        s == 'đã hủy' ||
        s == 'hủy' ||
        s == 'da huy';
  }

  @override
  MyBookingState build() {
    _bookingService = BookingService();
    return const MyBookingState();
  }

  Future<void> initialize({
    required int userId,
    required String token,
  }) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _bookingService.getAllBookings(
        token: token,
      );

      if (result['success'] != true) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: result['message'] as String? ?? 'Không thể tải booking',
        );
        return;
      }

      final all = (result['data'] as List<BookingResponse>)
          .where((b) => b.customerId == userId)
          .toList()
        ..sort((a, b) => b.id.compareTo(a.id));

      // Group by billId (1 billId = 1 item in MyBooking list)
      final Map<int, List<BookingResponse>> byBill = {};
      for (final b in all) {
        byBill.putIfAbsent(b.billId, () => <BookingResponse>[]).add(b);
      }

      final now = DateTime.now();
      final booked = <BookingBillGroup>[];
      final history = <BookingBillGroup>[];

      for (final entry in byBill.entries) {
        final billId = entry.key;
        final bookings = entry.value;
        // ensure bookings inside a group are sorted by id desc for consistent detail UI
        bookings.sort((a, b) => b.id.compareTo(a.id));

        final bool groupIsHistory = bookings.every((b) =>
            b.actualCheckOutTime != null || b.contractCheckOutTime.isBefore(now));

        final group = BookingBillGroup(billId: billId, bookings: bookings);
        if (groupIsHistory) {
          history.add(group);
        } else {
          booked.add(group);
        }
      }

      // Sort groups by max booking id DESC (keeps your "sort by id" intent)
      booked.sort((a, b) => b.maxBookingId.compareTo(a.maxBookingId));
      history.sort((a, b) => b.maxBookingId.compareTo(a.maxBookingId));

      state = state.copyWith(
        initialized: true,
        userId: userId,
        bookedBookings: booked,
        historyBookings: history,
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Có lỗi không xác định xảy ra: $e',
      );
    }
  }

  void setSelectedTab(BookingStatus tab) {
    state = state.copyWith(selectedTab: tab);
  }

  Future<void> refresh() async {
    final auth = ref.read(authProvider);
    final user = auth.user;
    final token = user?.token;
    if (auth.isLoggedIn != true || user == null || token == null || token.isEmpty) {
      state = const MyBookingState();
      return;
    }
    await initialize(userId: user.id, token: token);
  }

  Future<Map<String, dynamic>> cancelBill(BookingBillGroup group) async {
    final auth = ref.read(authProvider);
    final user = auth.user;
    final token = user?.token;

    if (auth.isLoggedIn != true || user == null || token == null || token.isEmpty) {
      return {
        'success': false,
        'message': 'Vui lòng đăng nhập để thực hiện thao tác này',
      };
    }

    if (group.bookings.isEmpty) {
      return {
        'success': false,
        'message': 'Không có phòng để hủy',
      };
    }

    if (_isCancelledStatus(group.paymentStatus)) {
      return {
        'success': false,
        'message': 'Hóa đơn đã được hủy trước đó',
      };
    }

    // Rule: chỉ cần "chưa check-in" là được hủy
    final canCancel = group.bookings.every((b) => b.actualCheckInTime == null);
    if (!canCancel) {
      return {
        'success': false,
        'message': 'Không thể hủy vì đã có phòng check-in',
      };
    }

    final failed = <String>[];
    for (final b in group.bookings) {
      final res = await _bookingService.cancelBooking(
        bookingId: b.id,
        token: token,
      );
      if (res['success'] != true) {
        final msg = (res['message'] as String?)?.trim();
        failed.add('Phòng ${b.roomNumber}: ${msg ?? 'Hủy thất bại'}');
      }
    }

    if (failed.isNotEmpty) {
      return {
        'success': false,
        'message': failed.join('\n'),
      };
    }

    await refresh();
    return {
      'success': true,
      'message': 'Đã hủy hóa đơn #${group.billId}',
    };
  }
}

final myBookingProvider = NotifierProvider<MyBookingNotifier, MyBookingState>(() {
  return MyBookingNotifier();
});


