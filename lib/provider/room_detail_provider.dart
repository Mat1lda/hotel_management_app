import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/response/room_type_response.dart';
import 'room_provider.dart';

class RoomDetailState {
  final RoomTypeResponse? room;
  final bool isLoading;
  final String? errorMessage;

  const RoomDetailState({
    this.room,
    this.isLoading = false,
    this.errorMessage,
  });

  RoomDetailState copyWith({
    RoomTypeResponse? room,
    bool? isLoading,
    String? errorMessage,
  }) {
    return RoomDetailState(
      room: room ?? this.room,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class RoomDetailNotifier extends Notifier<RoomDetailState> {
  @override
  RoomDetailState build() {
    return const RoomDetailState();
  }

  void setRoom(RoomTypeResponse room) {
    state = state.copyWith(room: room, isLoading: false, errorMessage: null);
  }

  Future<void> loadFromId(int id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final roomState = ref.read(roomProvider);
      if (!roomState.hasLoaded && !roomState.isLoading) {
        await ref.read(roomProvider.notifier).loadAllRoomTypes();
      }
      final allRooms = ref.read(roomProvider).roomTypes;
      final result = allRooms.firstWhere(
        (r) => r.id == id,
        orElse: () => throw StateError('Không tìm thấy phòng'),
      );
      state = state.copyWith(room: result, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Không thể tải chi tiết phòng',
      );
    }
  }

  void clear() {
    state = const RoomDetailState();
  }
}

final roomDetailProvider =
    NotifierProvider.autoDispose<RoomDetailNotifier, RoomDetailState>(() {
  return RoomDetailNotifier();
});


