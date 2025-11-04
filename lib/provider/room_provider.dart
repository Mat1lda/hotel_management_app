import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/response/room_type_response.dart';
import '../service/room_service.dart';

class RoomState {
  final List<RoomTypeResponse> roomTypes;
  final bool isLoading;
  final String? errorMessage;
  final bool hasLoaded;

  const RoomState({
    this.roomTypes = const [],
    this.isLoading = false,
    this.errorMessage,
    this.hasLoaded = false,
  });

  RoomState copyWith({
    List<RoomTypeResponse>? roomTypes,
    bool? isLoading,
    String? errorMessage,
    bool? hasLoaded,
  }) {
    return RoomState(
      roomTypes: roomTypes ?? this.roomTypes,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      hasLoaded: hasLoaded ?? this.hasLoaded,
    );
  }
}

class RoomNotifier extends Notifier<RoomState> {
  late final RoomService _roomService;

  @override
  RoomState build() {
    _roomService = RoomService();
    return const RoomState();
  }

  Future<void> loadAllRoomTypes() async {
    if (state.isLoading) return;

    print('RoomProvider: Starting to load room types...'); // Debug log
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _roomService.getAllRoomTypes();
      print('RoomProvider: Service result: $result'); // Debug log

      if (result['success'] == true) {
        final List<RoomTypeResponse> roomTypes = result['data'] as List<RoomTypeResponse>;
        print('RoomProvider: Loaded ${roomTypes.length} room types'); // Debug log
        state = state.copyWith(
          roomTypes: roomTypes,
          isLoading: false,
          hasLoaded: true,
        );
      } else {
        print('RoomProvider: API returned error: ${result['message']}'); // Debug log
        state = state.copyWith(
          isLoading: false,
          errorMessage: result['message'] as String,
        );
      }
    } catch (e) {
      print('RoomProvider: Exception occurred: $e'); // Debug log
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Có lỗi không xác định xảy ra: $e',
      );
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  List<RoomTypeResponse> searchRoomTypes(String query) {
    if (query.isEmpty) return state.roomTypes;
    
    return state.roomTypes.where((room) {
      return room.name.toLowerCase().contains(query.toLowerCase()) ||
             room.details.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  List<RoomTypeResponse> filterByPriceRange(double minPrice, double maxPrice) {
    return state.roomTypes.where((room) {
      return room.price >= minPrice && room.price <= maxPrice;
    }).toList();
  }

  List<RoomTypeResponse> filterByAmenities(List<String> requiredAmenities) {
    return state.roomTypes.where((room) {
      final roomAmenities = room.amenities;
      return requiredAmenities.every((amenity) => roomAmenities.contains(amenity));
    }).toList();
  }
}

final roomProvider = NotifierProvider.autoDispose<RoomNotifier, RoomState>(() {
  return RoomNotifier();
});

final roomTypesProvider = Provider<List<RoomTypeResponse>>((ref) {
  return ref.watch(roomProvider).roomTypes;
});

final roomLoadingProvider = Provider<bool>((ref) {
  return ref.watch(roomProvider).isLoading;
});

final roomErrorProvider = Provider<String?>((ref) {
  return ref.watch(roomProvider).errorMessage;
});
