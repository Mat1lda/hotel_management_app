import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/response/room_response.dart';
import '../provider/auth_provider.dart';
import '../service/room_service.dart';
import '../utility/app_date_utils.dart';

class AvailableRoomState {
  final int? roomTypeId;
  final String? checkIn;
  final String? checkOut;
  final List<RoomResponse> rooms;
  final bool isLoading;
  final String? errorMessage;
  final bool hasLoaded;

  const AvailableRoomState({
    this.roomTypeId,
    this.checkIn,
    this.checkOut,
    this.rooms = const [],
    this.isLoading = false,
    this.errorMessage,
    this.hasLoaded = false,
  });

  AvailableRoomState copyWith({
    int? roomTypeId,
    String? checkIn,
    String? checkOut,
    List<RoomResponse>? rooms,
    bool? isLoading,
    String? errorMessage,
    bool? hasLoaded,
  }) {
    return AvailableRoomState(
      roomTypeId: roomTypeId ?? this.roomTypeId,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      rooms: rooms ?? this.rooms,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      hasLoaded: hasLoaded ?? this.hasLoaded,
    );
  }
}

class AvailableRoomNotifier extends Notifier<AvailableRoomState> {
  late final RoomService _roomService;

  @override
  AvailableRoomState build() {
    _roomService = RoomService();
    return const AvailableRoomState();
  }

  Future<void> loadAvailableRoomsByRoomType({
    required int roomTypeId,
    required DateTime checkIn,
    required DateTime checkOut,
  }) async {
    if (state.isLoading) return;

    final String inIso = AppDateUtils.formatIsoDate(checkIn);
    final String outIso = AppDateUtils.formatIsoDate(checkOut);

    final bool shouldSkip = state.hasLoaded &&
        state.roomTypeId == roomTypeId &&
        state.checkIn == inIso &&
        state.checkOut == outIso &&
        state.errorMessage == null;
    if (shouldSkip) return;

    state = state.copyWith(
      roomTypeId: roomTypeId,
      checkIn: inIso,
      checkOut: outIso,
      isLoading: true,
      errorMessage: null,
      hasLoaded: false,
    );

    try {
      final auth = ref.read(authProvider);
      final String token = auth.user?.token ?? '';
      if (token.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Bạn cần đăng nhập để xem phòng trống',
          hasLoaded: true,
        );
        return;
      }

      final result = await _roomService.getAvailableRooms(
        checkIn: inIso,
        checkOut: outIso,
        token: token,
      );
      if (result['success'] == true) {
        final List<RoomResponse> all = result['data'] as List<RoomResponse>;
        final List<RoomResponse> available = all
            .where((r) => r.roomType.id == roomTypeId)
            .toList()
          ..sort((a, b) => a.roomNumber.compareTo(b.roomNumber));

        state = state.copyWith(
          rooms: available,
          isLoading: false,
          hasLoaded: true,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: result['message'] as String,
          hasLoaded: true,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Có lỗi không xác định xảy ra: $e',
        hasLoaded: true,
      );
    }
  }

  void clear() {
    state = const AvailableRoomState();
  }
}

final availableRoomProvider =
    NotifierProvider.autoDispose<AvailableRoomNotifier, AvailableRoomState>(() {
  return AvailableRoomNotifier();
});


