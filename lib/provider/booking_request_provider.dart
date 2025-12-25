import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/response/room_type_response.dart';
import '../model/selected_room_result.dart';

class BookingRequestState {
  final bool initialized;
  final RoomTypeResponse? roomType;
  final SelectedRoomResult? selection;
  final DateTime? checkIn;
  final DateTime? checkOut;

  const BookingRequestState({
    this.initialized = false,
    this.roomType,
    this.selection,
    this.checkIn,
    this.checkOut,
  });

  BookingRequestState copyWith({
    bool? initialized,
    RoomTypeResponse? roomType,
    SelectedRoomResult? selection,
    DateTime? checkIn,
    DateTime? checkOut,
  }) {
    return BookingRequestState(
      initialized: initialized ?? this.initialized,
      roomType: roomType ?? this.roomType,
      selection: selection ?? this.selection,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
    );
  }

  int get nights {
    if (checkIn == null || checkOut == null) return 1;
    final int d = checkOut!.difference(checkIn!).inDays;
    return d <= 0 ? 1 : d;
  }

  int get roomCount => selection?.rooms.length ?? 0;

  double get roomCost {
    final double price = roomType?.price ?? 0.0;
    return price * nights * roomCount;
  }

  double get discountPercent => (selection?.promotion?.discount ?? 0.0);

  double get discountAmount {
    final double percent = discountPercent;
    if (percent <= 0) return 0.0;
    return roomCost * percent / 100.0;
  }

  double get total => roomCost - discountAmount;
}

class BookingRequestNotifier extends Notifier<BookingRequestState> {
  @override
  BookingRequestState build() {
    return const BookingRequestState();
  }

  void initialize({
    required RoomTypeResponse roomType,
  }) {
    if (state.initialized) return;
    final now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    state = state.copyWith(
      initialized: true,
      roomType: roomType,
      selection: null,
      checkIn: today,
      checkOut: today.add(const Duration(days: 1)),
    );
  }

  void setSelection(SelectedRoomResult selection) {
    state = state.copyWith(selection: selection);
  }

  void clearSelection() {
    state = state.copyWith(selection: null);
  }

  void setCheckIn(DateTime date) {
    final DateTime normalized = DateTime(date.year, date.month, date.day);
    DateTime? out = state.checkOut;
    if (out == null || !out.isAfter(normalized)) {
      out = normalized.add(const Duration(days: 1));
    }
    final bool changed = state.checkIn == null ||
        state.checkIn!.year != normalized.year ||
        state.checkIn!.month != normalized.month ||
        state.checkIn!.day != normalized.day ||
        state.checkOut == null ||
        state.checkOut!.year != out.year ||
        state.checkOut!.month != out.month ||
        state.checkOut!.day != out.day;
    state = state.copyWith(checkIn: normalized, checkOut: out);
    if (changed && state.selection != null) {
      state = state.copyWith(selection: null);
    }
  }

  void setCheckOut(DateTime date) {
    final DateTime normalized = DateTime(date.year, date.month, date.day);
    final DateTime inDate = state.checkIn ?? normalized;
    if (!normalized.isAfter(inDate)) return;
    final bool changed = state.checkOut == null ||
        state.checkOut!.year != normalized.year ||
        state.checkOut!.month != normalized.month ||
        state.checkOut!.day != normalized.day;
    state = state.copyWith(checkOut: normalized);
    if (changed && state.selection != null) {
      state = state.copyWith(selection: null);
    }
  }

  void clear() {
    state = const BookingRequestState();
  }
}

final bookingRequestProvider = NotifierProvider.autoDispose<BookingRequestNotifier,
    BookingRequestState>(() {
  return BookingRequestNotifier();
});


